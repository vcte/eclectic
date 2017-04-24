; ---------------------------------------------------------------
; Export
; ---------------------------------------------------------------

Export:
	xor A
	ld (menusel), A
Export2:
	ld HL, tExportProp
	call SelectProp
	
	call GetMaxlist
	
	ld H, A				;list size = 12 + 9 * #elements
	ld L, 9
	call multhl
	ld BC, 12
	add HL, BC
	b_call(_EnoughMem)			;checks if enough RAM is available
	jp c, ExportNotEnoughRAM
	
ExportPrompt:
	call PromptList
	call CharListNm
	rst rMov9ToOP1
	rst rFindSym
	
	jp nc, ExportExistErr		;if list exists, prompt for deletion
	
ExportMain:
	ld A, (maxlist)				;else, create list
	ld H, 0
	ld L, A
	b_call(_CreateRList)
	
	inc DE
	inc DE
	
	call GetNumToSkip
	call InitCurEle
	
	ld HL, Elements
	ld A, (maxlist)
	ld B, A
	
ExportMainLp:
	push BC
	push HL
	push DE
	
	call GetInfo
	jr nc, ExportMainKnown		;if data is known, export as normal
	
	ld A, (menusel)			;and, if exporting mass, then get synthetic mass
	or A
	jr nz, ExportMainNotMass
	
	call GetSyntMass
	
	jr ExportMainStore
	
ExportMainNotMass:
	ld HL, FPZero				;else, load 0 into list element
	pop DE
	ld BC, 9
	ldir
	jr ExportMainCont
	
ExportMainKnown:
	call BCDFP
ExportMainStore:
	ld HL, OP1
	pop DE
	ld BC, 9
	ldir
	
ExportMainCont:
	ld HL, CurEle
	inc (HL)
	
	pop HL
	inc HL
	inc HL
	
	pop BC
	djnz ExportMainLp
	
	ld A, (tempele)
	ld (curele), A
	
	ld HL, ExportSuccessful
	call DispErr
	
	jp Export2
	
ExportExistErr:
	push BC
	push DE
	push HL
	ld HL, ErrorListExists
	ld DE, tempstr2
	call CopyStr

	ld HL, buffer
	ld A, (HL)
	cp 2
	jr nz, ExportExistErr2
	inc HL
ExportExistErr2:
	call CopyStr
	ld HL, ErrorListExists2
	call CopyStr
	xor A
	ld (DE), A
	pop HL
	pop DE
	pop BC
ExportExistErr3:
	push BC
	push DE
	push HL
	b_call(_PushOP1)
	ld HL, tempstr2
	call DispErr
	push AF
	b_call(_PopOp1)
	pop AF
	pop HL
	pop DE
	pop BC
	cp skLog			;'N'
	jp z, ExportPrompt
	cp sk1				;'Y'
	jr z, ExportDelete
	jr ExportExistErr3		;else, keep displaying error
	
ExportDelete:
	b_call(_DelVarArc)
	jp ExportMain
	
ExportNotEnoughRAM:
	ld HL, ErrorNotEnoughRAM
	call DispErr
	jp Export2
	
; ---------------------------------------------------------------
; Select Property subroutine
; Input: HL = header
; Output: A = option #
; ---------------------------------------------------------------

SelectProp:
	call DrawHeader
	ld HL, proparray
	ld A, 5
	ld (PenCol), A
SelectPropDispLp:
	ld A, (PenCol)
	push AF
	push HL
	call LdHLInd
	b_call(_VPutS)
	pop HL
	inc HL
	inc HL
	pop AF
	ld (PenCol), A
	ld A, (PenRow)
	cp 52
	jr c, SelectPropDispSkip
	ld A, 96 / 2 + 5
	ld (PenCol), A
	ld A, 10 - 6
	ld (PenRow), A
SelectPropDispSkip:
	add A, 6
	ld (PenRow), A
	
	ld B, (HL)			;If 2 bytes @ (HL) = 0, 
	inc HL
	ld A, (HL)
	dec HL
	or B
	jr nz, SelectPropDispLp	;then skip
	
	call SelectPropDispArr
SelectPropCpy:
	call SelectPropDispArr
	call ifastcopy
SelectPropLp:
	b_call(_GetCSC)
	or A
	jr z, SelectPropLp
	
	ld HL, keyprops
	call HandleKey
	
	ld C, 0
	ld HL, keyProp
	call HandleKey
	
	jr SelectPropLp
	
SelectPropUp:
	ld A, (menusel)
	or A
	jr z, SelectPropLp
	call SelectPropDispSpace
	ld A, (menusel)
	dec A
	ld (menusel), A
	jr SelectPropCpy
	
SelectPropDown:
	ld A, (menusel)
	cp 12
	jr z, SelectPropLp
	call SelectPropDispSpace
	ld A, (menusel)
	inc A
	ld (menusel), A
	jr SelectPropCpy
	
SelectPropRight:
	ld A, (menusel)
	cp 5
	jr nc, SelectPropCpy
	call SelectPropDispSpace
	ld A, (menusel)
	add A, 8
	ld (menusel), A
	jr SelectPropCpy
	
SelectPropLeft:
	ld A, (menusel)
	cp 8
	jr c, SelectPropCpy
	call SelectPropDispSpace
	ld A, (menusel)
	sub 8
	ld (menusel), A
	jp SelectPropCpy
	
SelectPropEnter:
	ld A, (menusel)
	ret
	
SelectPropGetCur:			;subroutine that returns PenCol/Row based on menusel
	xor A
	ld (PenCol), A
	ld A, (menusel)
	cp 8
	jr c, SelectPropGetCur2
	
	sub 8
	ld B, 96 / 2
	ld HL, PenCol
	ld (HL), B
SelectPropGetCur2:
	ld B, A			;(PenRow) = 10 + 6 * A
	add A, A
	add A, B
	add A, A
	ld B, 10
	add A, B
	ld (PenRow), A
	ret
	
SelectPropDispArr:			;subroutine that displays cursor arrow
	call SelectPropGetCur
	ld A, $05
	b_call(_VPutMap)
	ret
	
SelectPropDispSpace:
	call SelectPropGetCur
	ld A, $06
	b_call(_VPutMap)
	ret
	
SelectPropE:
	inc C
SelectPropN:
	inc C
SelectPropI:
	inc C
SelectPropC:
	inc C
SelectPropA:
	inc C
SelectPropS:
	inc C
SelectPropH:
	inc C
SelectPropF:
	inc C
SelectPropB:
	inc C
SelectPropM:
	inc C
SelectPropV:
	inc C
SelectPropD:
	inc C
SelectPropW:
	ld A, C
	push AF
	call SelectPropDispSpace
	pop AF
	ld (menusel), A
	call SelectPropDispArr
	call ifastcopy
	jr SelectPropEnter

	
; ---------------------------------------------------------------
; PromptList:
; Subroutine that prompts list name
; Output: HL = pointer to list name
; ---------------------------------------------------------------

PromptList:
	ld HL, PlotSScreen + 12 * (64/2 - 10/2)		;clear out area of input box
	ld DE, PlotSScreen + 12 * (64/2 - 10/2) + 1
	ld BC, 10 * 12 - 1
	ld (HL), 0
	ldir
	
	call DrawPromptBox
	
	ld HL, 256 * 29 + 3				;prompt for list name
	ld (PenCol), HL
	ld HL, tExportToList
	b_call(_VPutS)
	
	call InitInput1
PromptListLp:
	call ifastcopy
	call GetCSCCur
	
	ld HL, keylist
	call HandleKey
	
	bit 2, (IY + Asm_Flag2)
	jr nz, PromptListSecond
	
	ld B, A
	ld A, (size)
	cp 5		;list can only be 5 letters long
	jr z, PromptListLp
	ld A, B
	
	call GetChar			;in case of alpha char
	jr c, PromptListLp
	call SaveIn
	b_call(_VPutMap)
	call curson
	jr PromptListLp

PromptListSecond:
	ld B, A			;in case of lists 1-6
	ld A, (size)
	cp 1
	jr nc, PromptListLp
	ld A, B
	
	call GetNum
	jr c, PromptListLp
	
	cp '1'
	jr c, PromptListLp
	cp '6' + 1
	jr nc, PromptListLp
	
	push AF
	ld A, 2
	call SaveIn
	ld A, 'L'
	b_call(_VPutMap)
	pop AF
	
	call SaveIn
	b_call(_VPutMap)
	
	call curson
	jr PromptListLp
	
	
PromptListDel:
	call Delete
	jr PromptListLp
	
PromptListClr:
	ld A, (size)
	or A
	jr z, PromptListQuit
	ld A, 49
	call ClearIn
	jp PromptListLp
	
PromptListInv:
	ld A, (size)
	or A
	jp nz, PromptListLp
	bit 2, (IY + Asm_Flag2)
	jr z, PromptListInv0
	
	res 2, (IY + Asm_Flag2)
	ld A, $7C
	ld (CursorA), A
	ld A, 2
	ld (CursorWid), A
	
	call curoff
	call curson
	jp PromptListLp
	
PromptListInv0:
	set 2, (IY + Asm_Flag2)
	ld A, $1E
	ld (CursorA), A
	ld A, 3
	ld (CursorWid), A
	
	call curoff
	call curson
	jp PromptListLp
	
PromptListEnter:
	ld A, (size)
	or A
	jp z, PromptListLp
	xor A
	call SaveIn
	ld HL, size
	dec (HL)
	ld HL, buffer
	ret

PromptListQuit:
	pop HL
	jp Export2