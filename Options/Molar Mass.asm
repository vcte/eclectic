; ---------------------------------------------------------------
; Molar Mass Calculator
; ---------------------------------------------------------------

MolarMass:
	ld HL, tMolarMass
	call DrawHeader
	ld HL, tPromptForm
	b_call(_VPutS)
	
	call InitInput
MolarMassLp:
	call ifastcopy
	call GetCSCCur
	
	ld HL, keymass
	call HandleKey
	
	ld B, A
	ld A, (size)
	cp 96 / 4 - 2; max
	jr z, MolarMassLp
	ld A, (alphanum)
	or A
	ld A, B
	jr z, MolarMassInNum
	
	call GetChar
	jr c, MolarMassLp
	
	ld B, A
	ld A, (alphanum)
	cp 1
	ld A, B
	jr z, MolarMassAlphaUp
	add A, $20
MolarMassAlphaUp:
	call SaveIn
	b_call(_VPutMap)
	
	jr MolarMassLp
MolarMassInNum:
	call GetNum
	jr c, MolarMassLp
	
	call IsNumber
	jr c, MolarMassAlphaUp
	
	push AF
	call SaveIn
	call curoff
	pop AF
	sub '0'
	
	call PutSubScript
	
	call curson
	jr MolarMassLp
	
MolarMassDel:
	call Delete
	jr MolarMassLp
	
MolarMassClr:
	ld A, (size)
	or A
	jp z, calculate
	
	ld A, 2
	call ClearIn
	jr MolarMassLp
	
MolarMassAlpha:
	ld A, (alphanum)
	or A
	jr z, MolarMassAlpha0
	cp 1
	jr z, MolarMassAlpha1
	xor A
	
	ld C, $5F
	ld B, 4
	
	jr MolarMassAlphaEnd2
MolarMassAlpha1:
	ld C, $1F
	ld B, 3
	
	jr MolarMassAlphaEnd
MolarMassAlpha0:
	ld C, $7C
	ld B, 2
	
MolarMassAlphaEnd:
	inc A
MolarMassAlphaEnd2:
	ld HL, cursorA
	ld (HL), C			;ld into cursorA
	inc HL
	ld (HL), B			;ld into cursorwid
	inc HL
	ld (HL), A			;ld into alphanum
	
	call curoff
	call curson
	
	jp MolarMassLp
	
MolarMassEnter:
	ld A, (size)			;return if nothing is inputted
	or A
	jp z, MolarMassLp
	xor A				;null terminate
	call SaveIn
	ld HL, size			;to compensate for some odd glitch
	dec (HL)
	call curoff
	
; MassTotal = 0	
; For (each element E)
; MassTotal = MassTotal + (E.Mass * Subscript# * ParanthesisSub#)
; End
; Disp MassTotal
	
	b_call(_OP3Set0)		;OP3 shall hold MassTotal, initial value of 0
	b_call(_OP4Set1)		;OP4 shall hold ParanSub#, initial value of 1
	ld HL, buffer
	
MolarMassEnterLp:
	ld A, (HL)			;if character is an uppercase letter...
	cp 'A'
	jp c, MolarMassEnterNotEle
	cp 'Z' + 1
	jp nc, MolarMassEnterNotEle
	
	ld DE, tempstr		;...then find element
	ld (DE), A
	inc HL
	inc DE
MolarMassEnterLpLp:
	ld A, (HL)
	cp 'a'
	jr c, MolarMassEnterNotLow
	cp 'z' + 1
	jr nc, MolarMassEnterNotLow
	
	ld (DE), A
	inc DE
	inc HL
	jr MolarMassEnterLpLp
MolarMassEnterNotLow:
	xor A
	ld (DE), A
	
	ld DE, tempstr
	ld C, 0
	push HL
	call SearchStr
	pop HL
	jp c, MolarMassEnterErr
	
	push HL
	push AF
	call GetData1
	pop AF
	ld B, (HL)
	bit 7, B
	jr z, MolarMassBCD
	
	call GetMass
	call GetSyntMass
	jr MolarMassStoreOP
	
MolarMassBCD:
	call GetMass
	call BCDFP
MolarMassStoreOP:
	rst rOP1ToOP2		;put elemental molar mass into OP2
	
	pop HL
	
	ld B, 6
	call StrFP
	jr c, MolarMassEnterNoSub
	
	push HL
	b_call(_PushOP3)
	b_call(_FPMult)		;(elemental mass) * (subscript) -> OP1
	b_call(_PopOp3)
	pop HL
MolarMassEnterSkipMult:
	push HL
	b_call(_PushOp3)
	b_call(_OP4ToOp2)		;OP1 * (Paranthesis subscript) -> OP1
	b_call(_FPMult)
	b_call(_PopOp3)
	
	b_call(_OP3ToOp2)
	rst rFPAdd			;OP1 + MassTotal -> MassTotal
	b_call(_OP1ToOp3)
	pop HL
	
	jp MolarMassEnterLp
	
MolarMassEnterNoSub:
	push HL
	b_call(_OP2ToOp1)
	pop HL
	jr MolarMassEnterSkipMult
	
MolarMassEnterNotEle:
	ld A, (HL)			;...else if char is opening paranthesis...
	cp '('
	jr nz, MolarMassEnterNotParan
	
	push HL			;...then look for closing paranthesis and find subscript value
	pop DE				;DE saveguards HL
	inc HL
	ld B, 1			;B = (# of '(') - (# of ')')  (for djnz trick)
MolarMassEnterParanLp:		;when B = 1, then corresponding closing paran has been found
	ld A, (HL)
	cp '('
	jr z, MolarMassEnterParanL
	cp ')'
	jr z, MolarMassEnterParanR
	or A
	jp z, MolarMassEnterErr3
	
MolarMassEnterParanEnd:
	inc HL
	jr MolarMassEnterParanLp
	
MolarMassEnterParanL:
	inc B
	jr MolarMassEnterParanEnd
	
MolarMassEnterParanR:
	djnz MolarMassEnterParanEnd	;keep looping if B /= 1
	
	push DE
	inc HL				;move to subscript value and find FP value
	ld A, (HL)			;if not # or dot, then skip ahead
	call IsNumDot
	jr c, MolarMassEnterNotNum
	
	push HL
	ld B, 24
	call StrFp
;	jp c, MolarMassEnterErr2	;error if user inputted invalid # ;redundant
	
	b_call(_Op2Set0)		;if ParanSub# = 0
	b_call(_CpOp1Op2)
	pop HL
	jr nz, MolarMassEnterOP1N0
	
	pop BC				;level SP, but preserve HL
	jr MolarMassEnterNotParan	;then skip entire contents of paran
	
MolarMassEnterOP1N0:
	b_call(_PushOp3)		;ParanSub# = ParanSub# * NewParanSub#
	b_call(_Op4ToOp2)		;value is cumulative, 
	b_call(_FPMult)		;for hypothetical cases like (Ba(NO3)2)2
	b_call(_Op1ToOp4)
	b_call(_PopOp3)
	
MolarMassEnterNotNum:
	pop HL				;pop DE into HL
MolarMassEnterNotParan:
	ld A, (HL)			;...else if char is closing paranthesis...
	cp ')'
	jr nz, MolarMassEnterNotParan2
	
	push HL
	inc HL
	ld A, (HL)
	dec HL				;so current char not skipped
	call IsNumDot
	jr c, MolarMassEnterNotNum2
	inc HL
	ld B, 24
	call StrFP
;	jp c, MolarMassEnterErr2	;redundant
	
	b_call(_PushOp3)		;ParanSub# = ParanSub# / NewParanSub#
	b_call(_Op1ToOp2)
	b_call(_Op4ToOp1)
	b_call(_FPDiv)
	b_call(_Op1ToOp4)
	b_call(_PopOp3)
	
MolarMassEnterNotNum2:
	pop HL
MolarMassEnterNotParan2:
	ld A, (HL)
	inc HL				;...else try next character
	or A
	jp nz, MolarMassEnterLp
	
	ld HL, 28 * 256 + 2		;when done, display MassTotal
	ld (PenCol), HL
	
	b_call(_OP3ToOp1)
	ld A, 8
	b_call(_DispOP1A)
	ld HL, tGperMol		;disp g/mol
	b_call(_VPutS)
	
	ld HL, 40 * 256 + 2
	ld (PenCol), HL
	ld HL, MassStorePrompt
	b_call(_VPutS)
	
	ld HL, 46 * 256 + 2
	ld (PenCol), HL
	ld HL, MassEditPrompt
	b_call(_VPutS)
	
	ld HL, 52 * 256 + 2
	ld (PenCol), HL
	ld HL, MassBackPrompt
	b_call(_VPutS)
	
	call ifastcopy
MolarMassEnterPause:
	b_call(_GetCSC)
	or A
	jr z, MolarMassEnterPause
	
	ld HL, keymass2
	call HandleKey
	
	jr MolarMassEnterPause
	
MolarMassStoreAns:
	b_call(_StoAns)
	jp features
	
MolarMassEdit:
	ld HL, tMolarMass
	call DrawHeader
	ld HL, tPromptForm
	b_call(_VPutS)
	ld HL, 16 * 256 + 2
	ld (PenCol), HL
	ld HL, buffer
	call SPutS
	jp MolarMassLp
	
MolarMassEnterErr:			;error: user inputted unrecognized element
	ld HL, tempstr
	ld DE, tempstr2
	call CopyStr
	ld HL, ErrorIDK
	call CopyStr
	xor A
	ld (DE), A
	ld HL, tempstr2
	call DispErr
	
	jp MolarMassLp
	
MolarMassEnterErr2:
	ld HL, ErrorInvalid		;error: user inputted invalid number
	call DispErr
	
	jp MolarMassLp
	
MolarMassEnterErr3:
	ld HL, ErrorMissingP		;error: user is missing ')'
	call DispErr
	
	jp MolarMassLp
