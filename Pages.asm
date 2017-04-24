; ===============================================================
; Pages
; ===============================================================

; ---------------------------------------------------------------
; PAGE 1 (General)
; ---------------------------------------------------------------

second1:
	xor A
	ld (curpage), A
	call page
	
	ld A, 1
	ld (PenRow), A
	
	ld DE, tWeight
	call WriteTagline
	
	push HL
	
	call WriteWeight
	
	ld HL, tGPerMol
	b_call(_VPutS)
	pop HL
	call NextBCD
	
	push HL
	ld DE, 2 + 256 * 13			;display category
	ld (PenCol), DE
	ld A, (HL)
	and %11110000
	srl A
	srl A
	srl A
	ld B, 0
	ld C, A
	ld HL, category
	add HL, BC
	call LdHLInd
	b_call(_VPutS)
	
	ld DE, tGroup			;display group #
	call WriteTagline
	
	call GetColumn
	or A
	jr nz, second1a
	
	ld HL, tNA			;"NA"
	b_call(_VPutS)
	jr second1b
second1a:
	call IntStr
	b_call(_VPutS)
	
second1b:
	ld DE, tPeriod			;display period #
	call WriteTagline
	
	call GetPeriod
	
	call IntStr
	b_call(_VPutS)
	
second1d:
	ld DE, tBlock				;display block 
	call WriteTagline
	
	call GetBlock
	ld HL, blocktable
	ld B, 0
	ld C, A
	add HL, BC
	ld A, (HL)
	b_call(_VPutMap)
	pop HL
	
	call ifastcopy
	
	jp secondhandle
	
; ---------------------------------------------------------------
; Page 2 (Physical)
; ---------------------------------------------------------------
	
second2:
	ld A, 1
	ld (curpage), A
	call page
	
	ld DE, 2 + 256
	ld (PenCol), DE
	
	call SkipMass
	
	ld DE, tState				;write state
	call WriteTagline
	push HL
	ld A, (HL)
	and %00001111
	add A, A
	ld B, 0
	ld C, A
	ld HL, states
	add HL, BC
	call LdHLInd
	b_call(_VPutS)
	pop HL
	
	inc HL
	
	ld DE, tDensity			;write density
	call WriteTagline
	ld DE, tGperCm3
	call WriteData
	
	ld DE, tVolume			;write volume
	call WriteTagline
	ld DE, tCm3perMol
	call WriteData
	
	
	call ifastcopy
	
	jp secondhandle

; ---------------------------------------------------------------
; PAGE 3 (Temperature)
; ---------------------------------------------------------------

second3:
	ld A, 2
	ld (curpage), A
	call page
	
	ld DE, 2 + 256
	ld (PenCol), DE
	
	ld DE, tMeltingPt			;write melting point
	call WriteTagline
	call SkipToTemp
	ld DE, tKelvin
	call WriteData
	
	ld DE, tBoilingPt			;write boiling point
	call WriteTagline
	ld DE, tKelvin
	call WriteData
	
	ld DE, tHFusion			;write heat of fusion
	call WriteTagline
	ld DE, tkJMol
	call WriteData
	
	ld DE, tHVapor			;write heat of vaporization
	call WriteTagline
	ld DE, tkJMol
	call WriteData
	
	ld DE, tSpecHeat
	call WriteTagline
	ld DE, tJgK
	call WriteData
	
	
	call ifastcopy
	
	jp secondhandle
	
; ---------------------------------------------------------------
; PAGE 4 (Atomic)
; ---------------------------------------------------------------

second4:
	ld A, 3
	ld (curpage), A
	call page
	
	ld DE, 2 + 256 * 7
	ld (PenCol), DE
	
	push HL
	call WriteEConf
	
	ld DE, tRadius			;write atomic Radius
	call WriteTagline
	pop HL
	
	call SkipToAtomic
	ld DE, tAngstrom
	call WriteData
	
	ld DE, tCovRadius			;write covalent radius
	call WriteTagline
	ld DE, tAngstrom
	call WriteData
	
	ld DE, tIonizationE			;write ionization energy
	call WriteTagline	
	
	call GetDataA
	bit 6, A
	jr z, second4c
	call WriteUnknown
	jr second4d
second4c:
	push HL
	call BCDStr
	b_call(_VPutS)
	ld HL, tVolt
	b_call(_VPutS)
	pop HL
	call NextBCD
second4d:
	ld DE, tElectroneg
	call WriteTagline
		
	call GetDataA
	bit 5, A
	jr z, second4e
	call WriteUnknown
	jr second4f
second4e:
	push HL
	call BCDStr
	b_call(_VPutS)
	pop HL
	call NextBCD
second4f:
	ld DE, tEAffinity
	call WriteTagline
	
	call GetDataA
	bit 4, A
	jr z, second4g
	call WriteUnknown
	jr second4h
second4g:
	push HL
	call BCDStr
	b_call(_VPutS)
	ld HL, tVolt
	b_call(_VPutS)
	pop HL
	call NextBCD
second4h:
	ld DE, tOxidationSts
	call WriteTagline
	
	call GetDataA
	bit 3, A
	jr z, second4i
	call WriteUnknown
	jr second4j
second4i:
	push HL
	call WriteOxidation
	pop HL
	call nextstr
second4j:
	
	
	
		
	call ifastcopy
	
	jr secondhandle
	
; ---------------------------------------------------------------
; PAGE 5 (Misc.)
; ---------------------------------------------------------------

second5:
	ld A, 4
	ld (curpage), A
	call page
	
	ld DE, 2 + 256 * 7
	ld (PenCol), DE
	
	call SkipToMisc
	
	push HL
	ld A, (HL)
	add A, A
	ld HL, crystaltab
	ld B, 0
	ld C, A
	add HL, BC
	call LdHLInd
	b_call(_VPutS)
	pop HL
	
	inc HL
	ld DE, tThermalCond
	call WriteTagline
	ld DE, tWmK
	call WriteData
	
	ld DE, tElectCond
	call WriteTagline
	
	call WriteElectCond
	
	
	call ifastcopy
	
;	jr secondhandle	;jumps to next code section