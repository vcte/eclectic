; ---------------------------------------------------------------
; Grapher
; ---------------------------------------------------------------

Grapher:
	xor A
	ld (menusel), A
Grapher2:
	ld HL, tGraphProp
	call SelectProp			;prompt user to select a property
	call GetNumToSkip			;gets # data entires to skip when finding property -> (NumToSkip)
	call GetMaxList			;gets max # of elements -> (MaxList)
	call InitCurEle			;1 -> (curele)
	
	ld A, 2
	ld HL, xval
	ld (HL), A				;2 into xval
	inc HL
	ld (HL), A				;2 into trace
	inc HL
	xor A
	ld (HL), A				;0 into shift
	inc HL
	inc A
	ld (HL), A				;1 into traceE
	
	call GetMax
Grapher3:
	call GrapherStoYMax
	b_call(_Op1ToOp2)			;OP5 = (GraphMax) / (Max)
	ld HL, GraphMax
	rst rMov9ToOp1
	b_call(_FPDiv)
	b_call(_Op1ToOp5)
	
Grapher4:
	call ClrBuff
	Line(0,0,0,56)
	Line(0,57,95,57)
	
	ld HL, 0				;initialize last point for line graphing
	ld (LastPoint), HL
	
	ld A, (curele)
	call GetEle2
	ld B, 94
	di					;speed up the process a little
GrapherLp:
	push BC
	push HL
	
	call GetInfo				;if data is unknown
	jr nc, GrapherKnown
	
	ld A, (menusel)			;and property is mass
	or A
	jr nz, GrapherSkip
	
	call GetSyntMass			;then get synthetic mass
	jr GrapherMass
	
GrapherKnown:
	call BCDFP
GrapherMass:	
	call GetPoint				;converts OP1 to point coordinates
	ld A, (vGraphStyle)
	or A
	jr z, GrapherDot
	cp 1
	jr z, GrapherLine
	
	ld A, H
	ld E, L
	push DE
	call igetpix
	pop DE
	
	push AF
	ld A, 57
	sub E
	ld B, A
	pop AF
	
	ld DE, 12
GrapherBarLp:
	or (HL)
	ld (HL), A
	add HL, DE
	djnz GrapherBarLp
	jr GrapherSkip
	
GrapherDot:
	call pixelonhl
	jr GrapherSkip
GrapherLine:
	ld DE, (LastPoint)
	xor A
	cp D
	jr nz, GrapherLineDraw
	push HL
	call pixelonhl
	pop HL
	jr GrapherLineSkip
	
GrapherLineDraw:
	push HL
	call fastlineb
	pop HL
GrapherLineSkip:
	ld (LastPoint), HL
GrapherSkip:
	ld HL, CurEle
	inc (HL)
	
	ld HL, XVal
	inc (HL)
	
	pop HL
	inc HL
	inc HL
	
	pop BC
	djnz GrapherLp
	
	ei
	
GrapherDraw:
	call GrapherClear
			
	ld A, (TraceE)		;draw left arrow, or ' ' if element is hydrogen
	cp 1
	ld A, $CF
	jr nz, GrapherNotH
	sub $CF - $06
GrapherNotH:
	b_call(_VPutMap)
	ld A, $20			;pad w/ space
	b_call(_VPutMap)
		
	ld A, (TraceE)		;draw element's symbol
	call GetEle1
	push HL
	b_call(_VPutS)
	ld A, $20			;pad w/ space
	b_call(_VputMap)
	ld A, (TraceE)		;draw right arrow, or ' ' if element is at max
	ld HL, MaxList
	cp (HL)
	jr z, GrapherMax
	ld A, $05
	b_call(_VPutMap)
GrapherMax:
	ld HL, 58 * 256 + 22
	ld (PenCol), HL
	pop HL
	
	call nextstr
	push HL
	b_call(_VPutS)
	ld HL, sphyphen
	b_call(_VPutS)
	pop HL
	
	ld A, (TraceE)			;set parameter
	ld (CurEle), A
	call GetInfo2
	jr nc, GrapherKnown2			;if data is unknown
	
	ld A, (menusel)			;and property is mass
	or A
	jr nz, GrapherUnknown
	
	push HL
	b_call(_PushOp5)
	pop HL
	
	call GetSyntMass			;then get synthetic mass
	
	ld A, 8
	b_call(_DispOp1A)
	
	b_call(_PopOp5)
	
	jr GrapherCursor
	
GrapherKnown2:
	push HL
	call BCDStr
	b_call(_VPutS)
	pop HL
	
	call BCDFP
GrapherCursor:			;takes OP1, and disps cursor at that position
	call GetPoint
	ld A, (trace)
	sub 2
	ld (PenCol), A
	ld A, L
	sub 7
	cp 64				;skip ahead if out of range
	jr nc, GrapherCopy
	ld (PenRow), A
	call ifastcopy
	res textWrite, (IY + sGrFlags)
	ld A, $07
	b_call(_VPutMap)
	set textWrite, (IY + sGrFlags)
	jr GrapherHandler
	
GrapherUnknown:
	call WriteUnknown
GrapherCopy:
	call ifastcopy
GrapherHandler:			;handles keypresses
	b_call(_GetCSC)
	or A
	jr z, GrapherHandler
	
	ld HL, keygrapher
	call HandleKey
	
	jr GrapherHandler
	
GrapherRight:
	ld A, (TraceE)
	ld HL, MaxList
	cp (HL)
	jr z, GrapherHandler
	cp 94
	jr z, GrapherRightShift
GrapherRightnvm:
	inc A
	ld (TraceE), A
	ld HL, trace
	inc (HL)
	jp GrapherDraw
	
GrapherRightShift:
	ld A, (shift)
	or A
	ld A, (TraceE)
	jr nz, GrapherRightnvm
	
GrapherRightShift2:
	ld HL, curele
	ld A, (MaxList)
	sub 94
	ld B, A
	ld (HL), A			;(curele) = (MaxList) - 94
	ld HL, xval
	ld (HL), 2			;xval = 2
	inc HL
	ld A, (HL)			;trace = trace - (MaxList - 94) + 2
	sub B
	add A, 2
	ld (HL), A
	inc HL
	ld (HL), 1			;shift = 1
	inc HL
	inc (HL)			;inc (TraceE)
	jp Grapher4
	
GrapherLeft:
	ld A, (TraceE)
	cp 1
	jr z, GrapherHandler
	ld C, A
	ld A, (MaxList)
	sub 94
	ld B, A			;save to B for later shifting
	ld A, C
	cp B
	jr z, GrapherLeftShift
GrapherLeftnvm:
	dec A
	ld (TraceE), A
	ld HL, trace
	dec (HL)
	jp GrapherDraw
	
GrapherLeftShift:
	ld A, (shift)
	or A
	ld A, (TraceE)
	jr z, GrapherLeftnvm
	
GrapherLeftShift2:
	ld HL, curele
	ld (HL), 1			;(curele) = 1
	ld HL, xval
	ld (HL), 2			;xval = 2
	inc HL
	ld A, (HL)			;trace = trace + (MaxList - 94) - 2
	add A, B
	sub 2
	ld (HL), A
	inc HL
	xor A
	ld (HL), A			;shift = 0
	inc HL
	dec (HL)			;dec (TraceE)
	jp Grapher4
	
GrapherYMax:
	call GrapherClear
	ld HL, tGrapherYMax
	b_call(_VPutS)
	
	b_call(_PushOp5)
	call GrapherGetYMax
	ld A, 4
	b_call(_FormReal)
	push BC				;save length of str
	ld HL, OP3
	ld DE, buffer
	ldir
	b_call(_PopOp5)
	
	ld HL, OP3
	b_call(_VPutS)
	pop BC
	
	ld A, C
	ld (size), A
	call InitInput2
	
GrapherYMaxLp:
	call GetCSCCur
	
	ld HL, keyymax
	call HandleKey
	
	ld B, A
	ld A, (size)
	cp 4
	jr z, GrapherYMaxLp
	ld A, B
	
	call GetNum
	jr c, GrapherYMaxLp
	
	call SaveIn
	b_call(_VPutMap)
	call curson
	jr GrapherYMaxLp
	
GrapherYMaxDel:
	call Delete
	jr GrapherYMaxLp
	
GrapherYMaxClr:
	ld A, (size)
	or A
	jp z, GrapherDraw
	
	ld A, 24
	call ClearIn
	jr GrapherYMaxLp
	
GrapherYMaxEnter:
	ld A, (size)
	or A
	jr z, GrapherYMaxLp
	xor A
	call SaveIn
	
	ld HL, buffer
	ld B, 4
	call StrFP
	
	ld DE, OP2
	call GrapherGetYMax2
	
	b_call(_CpOP1OP2)			;if both values are equal, then nothing happened
	jp z, GrapherDraw			;go back to graph tracer
	jp Grapher3				;else, regraph
	
GrapherYEqu:
	call GrapherClear			;"X: Atomic #" at (56, 0)
	ld HL, tGrapherX
	b_call(_VPutS)
	ld A, 96 / 2 - 4			;"Y: " + CurrentProp at (56, 48)
	ld (PenCol), A
	ld HL, tGrapherY
	b_call(_VPutS)
	ld A, (menusel)
	rlca
	ld HL, proparray
	ld B, 0
	ld C, A
	add HL, BC
	call LdHLInd
	b_call(_VPutS)
	call ifastcopy
	jp GrapherHandler
	
GrapherGoto:
	call GrapherClear
	ld HL, tGrapherPrompt
	b_call(_VPutS)
	
	ld A, (TraceE)
	call IntStr
	push HL
	ld (size), A
	b_call(_VPutS)
	pop HL
	ld DE, buffer
	call CopyStr
	
	call InitInput2
GrapherGotoLp:
	call GetCSCCur
	
	ld HL, keygoto
	call HandleKey
	
	ld B, A
	ld A, (size)
	cp 3
	jr z, GrapherGotoLp
	ld A, B
	
	call GetNum
	jr c, GrapherGotoLp
	
	call SaveIn
	b_call(_VPutMap)
	call encur
	jr GrapherGotoLp
	
GrapherGotoDel:
	call Delete
	jr GrapherGotoLp
	
GrapherGotoClr:
	ld A, (size)
	or A
	jp z, GrapherDraw
	ld A, 55
	call ClearIn
	jr GrapherGotoLp
	
GrapherGotoEnter:
	ld A, (size)
	or A
	jr z, GrapherGotoLp
	xor A
	call SaveIn
	ld HL, size
	dec (HL)
	
	ld HL, buffer
	call StrInt2
	jr c, GrapherGotoLp
	
	ld A, B
	dec A
	ld HL, MaxList
	cp (HL)
	jr nc, GrapherGotoLp
	inc A
	
	ld (TraceE), A
	ld A, (shift)
	or A
	jr z, GrapherGoto0
	
	ld A, B				;if shift = 1
	add A, 94
	ld HL, MaxList
	sub (HL)
	ld (trace), A
	jr c, GrapherGoto1
	
	add A, 2				;and goto# - ((MaxList) - 94) > 0
	ld (trace), A
	
	jp GrapherDraw
	
GrapherGoto1:
	ld HL, TraceE				;to offset the dec (TraceE) in the shift
	inc (HL)
	
	ld A, (MaxList)
	sub 94 - 3
	ld B, A
	jp GrapherLeftShift2
	
GrapherGoto0:
	ld A, B				;if shift = 0
	ld (trace), A
	cp 92
	jr nc, GrapherGoto02
	
	ld HL, trace				;and goto # < 92
	inc (HL)
	jp GrapherDraw			;then redraw w/ new coordinates
	
GrapherGoto02:
	ld HL, TraceE				;to offset the inc (TraceE) in the shift
	dec (HL)
	jp GrapherRightShift2
	
GrapherZoom:						;INCOMPLETE, sets default YMax value
	ld A, 2
	ld (XVal), A
	
	ld A, (shift)
	or A
	jr z, GrapherZoom0
	
	ld A, (MaxList)
	sub 94
	ld (CurEle), A
	jp Grapher4
	
GrapherZoom0:
	ld A, 1
	ld (CurEle), A
	jp Grapher4
	
GrapherClear:					;subroutine
	ld HL, PlotSScreen + 58 * 12	;clears out (58, 0) to (64, 96), sets (PenCol) and (PenRow)
	ld DE, PlotSScreen + 58 * 12 + 1
	ld BC, (64 - 58) * 12 - 1
	ld (HL), 0
	ldir
	ld HL, 58 * 256
	ld (PenCol), HL
	ret
	
GrapherStoYMax:
	ld HL, OP1				;store ymax
	ld DE, GYMax
	ld BC, 9
	ldir
	ret
	
GrapherGetYMax:
	ld DE, OP1
GrapherGetYMax2:
	ld HL, GYMax				;recall Ymax variable
	ld BC, 9
	ldir
	ret