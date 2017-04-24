; ===============================================================
; Display Routines (Element properties and stuff)
; ===============================================================

; ===============================================================
; dispele
; Displays element atomic number, symbol, name and weight
; Input: (elex) = x position of cursor
;	  (eley) = y position of cursor
; ===============================================================

dispele:
	ld HL, (PenCol)
	push HL
	
	call geta
	
	call clrele	
	
	ld A, (curele)
	call intstr
	
	ld DE, 18 + 256
	ld (PenCol), DE
	b_call(_VPutS)
	
	call GetEle
	
	ld DE, 18 + 256 * 7
	ld (PenCol), DE
	b_call(_VPutS)
	
	ld DE, 34 + 256
	ld (PenCol), DE
	b_call(_VPutS)
	
	ld DE, 34 + 256 * 9
	ld (PenCol), DE
	
	
	call WriteWeight
	
	
dispele2:
	pop HL
	ld (PenCol), HL
	
	ret
	
; ===============================================================
; Menu:
; Implements a menu
; Input: HL = pointer to array
;		Array
;		{
;			[0] = padded title as Str
;			[1...rest] = option as Str
;			[rest...rest2] = pointer as 2 byte val
;		}
; Output: HL = location to jump to
; ===============================================================

Menu:
	call DrawTitle
	call nextstr
	
	ld A, $31
	ld DE, 24 * 256 + 1
	ld (PenCol), DE
MenuLp:
	push AF
	b_call(_VPutMap)
	ld A, ')'
	b_call(_VPutMap)
	ld A, ' '
	b_call(_VPutMap)
	push HL
	b_call(_VPutS)
	pop HL
	call nextstr
	ld A, (PenRow)
	add A, 6
	ld (PenRow), A
	ld A, 1
	ld (PenCol), A
	pop AF
	inc A
	ld B, (HL)			;if value at HL is 1, then skip; else, lp
	djnz MenuLp
	
	inc HL
	ld A, (HL)
	ld (MaxOpt), A
	inc HL
	ld (tempHL), HL
	
	xor A
	ld (MenuOpt), A
MenuSelect:
	call MenuInv
	call ifastcopy
MenuSelectLp:
	b_call(_GetCSC)
	
	cp skUp 
	jr z, MenuSelectUp
	cp skDown 
	jr z, MenuSelectDown
	cp skEnter 
	jr z, MenuSelectEnter
	cp sk2nd 
	jr z, MenuSelectEnter
	cp skClear 
	jp z, Main
	cp skMode
	jp z, done
	
	call GetNum
	jr c, MenuSelectLp
	sub '0'
	or A				;lp if zero is pressed
	jr z, MenuSelectLp
	
	dec A
	ld B, A
	ld A, (MaxOpt)
	cp B
	ld A, B
	jr c, MenuSelectLp
	jr MenuSelectEnter2
	
MenuSelectUp:
	call MenuInv
	ld A, (MenuOpt)
	or A
	jr nz, MenuSelectUp2
	ld A, (MaxOpt)
	jr MenuSelectUp3
MenuSelectUp2:
	dec A
MenuSelectUp3:
	ld (MenuOpt), A
	jr MenuSelect
	
MenuSelectDown:
	call MenuInv
	ld A, (MenuOpt)
	ld HL, MaxOpt
	cp (HL)
	jr c, MenuSelectDown2
	xor A
	jr MenuSelectDown3
MenuSelectDown2:
	inc A
MenuSelectDown3:
	ld (MenuOpt), A
	jr MenuSelect
	
MenuSelectEnter:
	ld A, (MenuOpt)
MenuSelectEnter2:
	add A, A
	ld HL, (tempHL)
	ld B, 0
	ld C, A
	add HL, BC
	
	call LdHLInd
	jp (HL)
	
MenuInv:				;'subroutine' that inverts selection at MenuOpt
	ld A, (MenuOpt)
	ld H, A
	ld L, 72
	call multhl
	ld DE, PlotSScreen + 12 * 25
	add HL, DE
	ld B, 6 * 12
MenuInvLp:
	ld A, (HL)
	xor $FF
	ld (HL), A
	inc HL
	djnz MenuInvLp
	
	ret
	
	

; ===============================================================
; WriteEConf
; Writes Electron Configuration of current element to display
; Input: (curele) = Current Element atomic #
;	  (PenCol) = Column to display in
;	  (PenRow) = Row to display in
; ===============================================================

WriteEConf:
	call GetPeriod
	sub 2
	jr c, WriteEConf1
	ld HL, ngshorttable
	ld B, A
	add A, A
	add A, A
	add A, B
	ld B, 0
	ld C, A
	add HL, BC
	b_call(_VPutS)
	
WriteEConf1:
	ld A, (CurEle)		;skip if palladium
	cp 46
	jp z, WriteEConfdp
	
	ld A, (CurPeriod)
	call IntStr
	b_call(_VPutS)
	ld A, 's'
	b_call(_VPutMap)
	call GetBlock
	or A
	jr z, WriteEConfS
	cp P_BLOCK
	jr z, WriteEConfP
	cp D_BLOCK
	jp z, WriteEConfd
	
	ld A, 2
	call PutSScript
	
	ld A, (CurEle)
	cp 57
	jp z, WriteEConfda
	cp 89
	jp z, WriteEConfda
	cp 90
	jp z, WriteEConfda
	
	call WriteEConfChk
	push AF
	jr c, WriteEConf1a
	ld A, (CurPeriod)
	call WriteEConfdd
	ld A, 1
	call PutSScript
WriteEConf1a:
	ld A, (CurPeriod)
	dec A
	dec A
	call IntStr
	ld A, (HL)
	b_call(_VPutMap)
	ld A, 'f'
	b_call(_VPutMap)
	
	call GetColumn2
	ld B, A
	dec B
	dec B
	pop AF
	ld A, B
	adc A, 0
	call PutSScript
	
	ret
WriteEConfs:
	ld B, 1
	ld A, (EleX)
	cp 3
	jr z, WriteEConfs1
	inc B
WriteEConfs1:
	ld A, B
	call PutSScript
	ret
WriteEConfp:
	ld A, 2
	call PutSScript
	ld A, (CurPeriod)
	cp 4
	jr c, WriteEConfpa
	
	call WriteEConfdd
	
	ld A, 10
	call PutSScript
WriteEConfpa:
	ld A, (CurPeriod)
	cp 6
	jr c, WriteEConfpb
	
	call WriteEConfFfull
WriteEConfpb:
	ld A, (CurPeriod)
	call IntStr
	ld A, (HL)
	b_call(_VPutMap)
	ld A, 'p'
	b_call(_VPutMap)
	
	call GetColumn
	sub 12
	call PutSScript
	
	ret
WriteEConfd:
	call WriteEConfChk
	ld A, 1
	adc A, 0
	call PutSScript
WriteEConfdp:
	ld A, (CurPeriod)
	cp 6
	jr c, WriteEConfda
	
	call WriteEConfFfull
WriteEConfda:
	ld A, (CurPeriod)
	
	call WriteEConfdd
	
	call GetColumn
	ld C, A
	
	ld D, 0
	ld A, (CurEle)
	cp 46
	jr z, WriteEConfdb
	cp 90
	jr z, WriteEConfdc
	jr WriteEConfde
WriteEConfdb:
	inc D
WriteEConfdc:
	inc D
WriteEConfde:
	call WriteEConfChk
	ld A, C
	sbc A, 1
	add A, D
	call PutSScript
	
	ret
	
WriteEConfFfull:
	dec A
	dec A
	call IntStr
	ld A, (HL)
	b_call(_VPutMap)
	ld A, 'f'
	b_call(_VPutMap)
	ld A, 14
	call PutSScript
	ret
	
WriteEConfdd:
	dec A
	call IntStr
	ld A, (HL)
	b_call(_VPutMap)
	ld A, 'd'
	b_call(_VPutMap)
	ret
	
WriteEConfChk:				;'subroutine' that checks for exceptions to aufbau principle, returns nc if exception, c otherwise
	ld A, (CurEle)
	ld HL, WriteEConfTbl
	ld B, WriteEConfTblEnd - WriteEConfTbl
WriteEConfChkLp:
	cp (HL)
	ret z
	inc HL
	djnz WriteEConfChkLp
	
	scf
	ret
	
WriteEConfTbl:
.db 24, 29, 41, 42, 44, 45, 47, 58, 64, 78, 79, 91, 92, 93, 96, 110, 111
WriteEConfTblEnd:
	
	
; ===============================================================
; PutSScript:
; Puts a small font superscript onto the buffer
; Input: A = number (0 - 19)
;	  (PenCol)
;	  (PenRow)
; ===============================================================

PutSScript:
	cp 10
	jr c, PutSScript0
	sub 10
	push AF
	ld A, 1
	call PutSScript0
	pop AF
PutSScript0:
	add A, A
	add A, A
	ld IX, FontTable
	ld B, 0
	ld C, A
	add IX, BC
	ld A, (PenRow)
	ld L, A
	ld A, (PenCol)
	ld B, 4
	call isprite
	ld A, (PenCol)
	add A, 4
	ld (PenCol), A
	ret
	
; ===============================================================
; PutSubScript:
; Puts a small font subscript onto the buffer
; Input: A = number (0 - 19)
;	  (PenCol)
;	  (PenRow)
; ===============================================================

PutSubScript:
	ld B, A
	ld A, (PenRow)
	add A, 2
	ld (PenRow), A
	ld A, B
	call PutSScript
	ld A, (PenRow)
	sub 2
	ld (PenRow), A
	ret
	
; ===============================================================
; WriteWeight:
; Writes elemental atomic weight to the graph buffer
; Input: HL = pointer to atomic weight
;	  (CurEle) = current element #
; ===============================================================

WriteWeight:
	push HL
	call GetData
	ld A, (HL)
	pop HL
	
	bit 7, A
	jr z, WriteWeight1
	
	ld A, '('
	b_call(_VPutMap)
	ld A, (HL)
	cp 159
	jr c, WriteWeight2
	
	ld B, A
	ld A, '2'
	b_call(_VPutMap)
	ld A, B
	sub 200
	
WriteWeight2:
	add A, 98
	call intstr
	b_call(_VPutS)
	ld A, ')'
	b_call(_VPutMap)
	ret
WriteWeight1:	
	call bcdstr
	b_call(_VPutS)
	ret
	
; ===============================================================
; WriteElectCond:
; Writes electrical conductivity
; Input: HL = pointer to electrical conductivity
;	  (CurEle) = current element #
; Output: HL = pointer to next data
; ===============================================================

WriteElectCond:
	ld A, (HL)
	or A
	jr z, WriteElectCondUnknown
	
	push HL
	call BCDStr
	b_call(_VPutS)
	ld A, $1B
	b_call(_VPutMap)
	call GetDataA
	bit 2, A
	jr z, WriteElectCondMill
	
	ld A, $2D
	b_call(_VPutMap)
	pop HL
	call NextBCD
	ld A, (HL)
	inc HL
	push HL
	call IntStr
	b_call(_VPutS)
	ld A, $20
	b_call(_VPutMap)
	ld HL, tScm
	b_call(_VPutS)
	pop HL
	ret
	
WriteElectCondMill:
	ld A, '6'
	b_call(_VPutMap)
	ld A, $20
	b_call(_VPutMap)
	ld HL, tScm
	b_call(_VPutS)
	pop HL
	call NextBCD
	ret
	
WriteElectCondUnknown:
	call WriteData0
	ret
	
; ===============================================================
; WriteTagline:
; Writes the property tagline and preserves HL and increases row
; Input: DE = pointer to tagline string
; ===============================================================

WriteTagline:
	ld A, (PenRow)
	add A, 6
	ld (PenRow), A
	ld A, 2
	ld (PenCol), A
	ex DE, HL
	b_call(_VPutS)
	push DE
	ld A, ':'
	b_call(_VPutMap)
	pop DE
	ex DE, HL
	ld A, 48
	ld (PenCol), A
	
	ret
	
; ===============================================================
; WriteUnknown:
; Writes 'Unknown' and preserves HL
; ===============================================================

WriteUnknown:
	push HL
	ld HL, unknown
	b_call(_VPutS)
	pop HL
	ret
	
; ===============================================================
; WriteOxidation:
; Writes oxidation states from given keycodes
; Input: HL = pointer to elements keycodes
; ===============================================================

WriteOxidation:
	ld A, (HL)
	inc HL
	ld B, A
	bit 4, A			; If Nib = 1
	jr nz, WriteOxidation1	;    Write +
	bit 5, A			; If Nib = 2
	jr nz, WriteOxidation2	;    Write -
	bit 6, A			; If Nib = 4
	jr nz, WriteOxidation3	;    Write [both]
	bit 7, A			; If Nib = 8
	jr nz, WriteOxidationB	;    Skip write
	
	ld A, (PenCol)		; Else (Nib = 0)
	sub 4				; Delete last comma
	ld (PenCol), A
	ld A, $06
	b_call(_VPutMap)
	ret
	
WriteOxidation1:
	ld A, '+'
	jr WriteOxidationA
WriteOxidation2:
	ld A, '-'
	jr WriteOxidationA
WriteOxidation3:
	ld A, $BF
WriteOxidationA:
	b_call(_VPutMap)
WriteOxidationB:
	ld A, B
	and %00001111
	ld B, '0'
	add A, B
	b_call(_VPutMap)
	ld A, ','
	b_call(_VPutMap)
	ld A, ' '
	b_call(_VPutMap)
	jr WriteOxidation
	
; ===============================================================
; WriteData:
; Writes a generic piece of data (BCD | 0)
; Input: HL = pointer to data
;	  DE = pointer to unit
; Output: HL = pointer to next data
; ===============================================================

WriteData:
	ld A, (HL)
	or A
	jr nz, WriteData2
WriteData0:
	push HL
	call WriteUnknown
	pop HL
	inc HL
	ret
WriteData2:
	push HL
	push DE
	call BCDStr
	b_call(_VPutS)
	ld A, $20
	b_call(_VPutMap)
	pop DE
	ex DE, HL
	b_call(_VPutS)
	pop HL
	call NextBCD
	ret
	
; ===============================================================
; DispErr:
; Displays an error message, then waits for keypress
; Input: HL = pointer to error string
; Output: A = keypress
; ===============================================================

DispErr:
	ld DE, (PenCol)
	push DE
	
	push HL
	
	ld HL, PlotSScreen + 12 * 28
	ld (HL), $FF
	ld DE, PlotSScreen + 12 * 28 + 1
	ld BC, 7 * 12 - 1
	ldir
		
	pop HL
	set textInverse, (IY + textFlags)
	ld A, 28
	call centertext
	call ifastcopy
	res textInverse, (IY + textFlags)
	pop HL
	ld (PenCol), HL
	
DispErrLp:
	b_call(_GetCSC)
	or A
	jr z, DispErrLp
	
	ld HL, PlotSScreen + 12 * 28
	ld (HL), 0
	ld DE, PlotSScreen + 12 * 28 + 1
	ld BC, 7 * 12 - 1
	ldir
	ret
	
; ===============================================================
; SPutS:
; Puts a string along with subscripts
; Input: HL = pointer to string
; ===============================================================

SPutS:
	ld A, (HL)
	inc HL
	or A
	ret z
	cp '0'			;checks if A is a number
	jr c, SPutSA
	cp '9' + 1
	jr nc, SPutSA
	
	sub '0'
	push HL
	call PutSubScript
	pop HL
	jr SPutS
	
SPutSA:
	b_call(_VPutMap)
	jr nc, SPutS		;disp rest of string only if it fits
	ret