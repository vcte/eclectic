; ===============================================================
; Query (Data-related routines)
; ===============================================================

; ===============================================================
; SkipData:
; Skips over data entry of element (BCD | 0)
; Input: HL = pointer to elements data entry #1
;	  (CurEle) = current element #
; Output: HL = pointer to elements data entry #2
; ===============================================================

SkipData:
	ld A, (HL)
	or A
	
	jr nz, SkipData2
	inc HL
	ret
SkipData2:
	call NextBCD
	ret
	
	
; ===============================================================
; SkipMass:
; Skips over mass data of element
; Input: HL = pointer to elements mass
;	  (CurEle) = current element #
; Output: HL = pointer to element state/phase
; ===============================================================

SkipMass:
	push HL
	call GetData
	ld A, (HL)
	pop HL
	
	bit 7, A
	jr z, SkipMassa
	inc HL
	ret
SkipMassa:
	call NextBCD
	ret
	
; ===============================================================
; SkipFlagged:
; Skips over data with flag
; Input: HL = pointer to element data
;	  (CurEle) = current element #
;	  A = bitmask to AND flag with
; Output: HL = pointer to next element data
; ===============================================================

SkipFlagged:
	push AF
	push HL
	call GetData
	ld B, (HL)
	pop HL
	pop AF
	
	and B
	ret nz
	call NextBCD
	ret
	
; ===============================================================
; SkipToPhys:
; Skips over data to reach physical data
; Input: HL = pointer to elements mass
;	  (CurEle) = current element #
; Output: HL = pointer to element physical data
; ===============================================================

SkipToPhys:
	call SkipMass
	inc HL
	ret
	
; ===============================================================
; SkipToTemp:
; Skips over data to reach temperature data
; Input: HL = pointer to elements mass
;	  (CurEle) = current element #
; Output: HL = pointer to elements temperature data
; ===============================================================

SkipToTemp:
	call SkipToPhys
	call SkipData			;skip density
	call SkipData			;skip volume
	ret
	
; ===============================================================
; SkipToAtomic:
; Skips over data to reach radius of element  / atomic data
; Input: HL = pointer to elements mass
;	  (CurEle) = current element #
; Output: HL = pointer to element radius
; ===============================================================

SkipToAtomic:
	call SkipToTemp
	call SkipData			;skip melting point
	call SkipData			;skip boiling point
	call SkipData			;skip heat of fusion
	call SkipData			;skip heat of vaporization
	call SkipData			;skip specific heat
	ret
	
; ===============================================================
; SkipToMisc:
; Skips over data to reach misc. data
; Input: HL = pointer to elements mass
;	  (CurEle) = current element #
; Output: HL = pointer to element misc data
; ===============================================================

SkipToMisc:
	call SkipToAtomic
	call SkipData			;skip radius
	call SkipData			;skip cov radius
	ld A, %01000000
	call SkipFlagged		;skip ionization energy
	ld A, %00100000
	call SkipFlagged		;skip electronegativity
	ld A, %00010000
	call SkipFlagged		;skip e-affinity
	ld A, %00001000
	call SkipFlagged		;skip oxidation states
	ret
	
; ===============================================================
; SkipA:
; Skips A number of data entries
; Input: HL = pointer to elements mass
;	  (CurEle) = current element #
;	  A = # entries to skip
; ===============================================================

SkipA:
	ld DE, SkipAArray
SkipALp:
	or A
	ret z
	push AF
	ld A, (DE)
	or A
	jr z, SkipAData
	cp $FF
	jr z, SkipAMass
	cp $FE
	jr z, SkipAByte
	cp $FD
	jr z, SkipANBTS
	call SkipFlagged
SkipAEnd:
	pop AF
	dec A
	inc DE
	jr SkipALp
	
SkipAData:
	call SkipData
	jr SkipAEnd
	
SkipAMass:
	call SkipMass
	jr SkipAEnd
	
SkipAByte:
	inc HL
	jr SkipAEnd
	
SkipANBTS:
	call nextstr
	jr SkipAEnd
	
SkipAArray:				;contains info on how data is stored
.db $FF, $FE, 0, 0, 0, 0, 0, 0, 0, 0, $01000000, %00100000, %00010000, %0001000, $FD, $FE, 0
	;$FF = mass, $FE = 1 byte, $FD = NBTS, 0 = BCD, else flag
	
; ===============================================================
; TestA
; Tests whether data is un/known
; Input: HL = pointer to data
;	  A = data type #
;	  (CurEle) = current element
; Output: c = unknown
; ===============================================================

TestA:
	push HL
	ld HL, SkipAArray
	ld B, 0
	ld C, A
	add HL, BC
	ld A, (HL)
	pop HL
	
	or A
	jr z, TestAData
	cp $FF			;Atomic mass is always known, but c is set when ele is synthetic
	jr z, TestAMass
	cp $FD			;if string value, then its probably 'known'
	ret z
	cp $FE
	jr z, TestAData
	
	push AF
	call GetData
	ld B, (HL)
	pop AF
	and B
	
	jr TestADone
	
TestAData:
	ld A, (HL)
	or A
	
	scf
	ret z
	ccf
	ret
	
TestAMass:
	call GetData
	ld A, (HL)
	and %10000000
TestADone:
	or A
	scf
	ret nz
	ccf
	ret
	
; ===============================================================
; SearchStr:
; Searches for an element based off string input
; Input: DE = pointer to input string
;	  C = 0 for symbol | 1 for name
; Output: A = element #
;	   c = not found
; ===============================================================

SearchStr:
	ld HL, Elements
	ld B, 118
SearchStrLp:
	push HL \ push BC			;search loop
	push DE
	call LdHLInd
	ld A, C
	or A
	jr z, SearchStrEnd
	
	call nextstr
SearchStrEnd:
	pop DE
	push DE
	call compstrs
	pop DE
	pop BC \ pop HL
	jr z, SearchStrFound
	inc HL
	inc HL
	djnz SearchStrLp
	
	ld HL, Tin + 3			;account for exception
	call compstrs
	jr z, SearchStrTin
	
	scf
	ret
SearchStrFound:
	ld A, 118
	sub B
	inc A
	or A
	ret
	
SearchStrTin:
	ld A, 50
	or A
	ret