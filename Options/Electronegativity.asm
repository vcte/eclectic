; ---------------------------------------------------------------
; Electronegativity Difference Calculator
; ---------------------------------------------------------------

ElectronegDiff:
	ld HL, tElectronegDiff
	call DrawHeader
	ld HL, tPromptEle1
	b_call(_VPutS)
	
	call InitInput
ElectronegDiff1:
	call ElectronegDiffLp
	
	call ElectronegDiffSub1
	ld (ele1num), A
	
	ld HL, 25 * 256 + 2
	ld (PenCol), HL
	
	call InitInput1
	ld HL, tPromptEle2
	b_call(_VPutS)
	ld HL, 31 * 256 + 2
	ld (PenCol), HL
		
ElectronegDiff2:
	call ElectronegDiffLp
	
	call ElectronegDiffSub2
	
	call GetElectroneg
	call BCDFP			;conv electroneg to FP
	rst rOP1ToOP2
	
	ld A, (ele1num)
	call GetElectroneg
	call BCDFP
	b_call(_FPSub)
	ld A, OPAbs
	b_call(_UnOPExec)
	
	b_call(_PushOp1)
	
	ld HL, 40 * 256 + 2		;disp electroneg diff
	ld (PenCol), HL
	ld HL, tElectronegDiff2
	b_call(_VPutS)
	ld A, 4
	b_call(_DispOp1A)
	
	ld HL, 46 * 256 + 2		;"predicted bond: "
	ld (PenCol), HL
	ld HL, tPredBond
	b_call(_VPutS)
	
	ld HL, PolarThres		;if 0 <= x < .4
	b_call(_Mov9ToOp2)
	
	b_call(_CpOP1OP2)
	jr c, ElectronegDiffNonpolar; then, nonpolar
	
	ld A, $17		;if .4 <= x < 1.7
	b_call(_OP2SetA)
	b_call(_CpOP1OP2)
	jr c, ElectronegDiffPolar	;then, polar
	
	ld HL, tIonic			;else, if x > 1.7
	jr ElectronegDiffDisp	;ionic
ElectronegDiffPolar:
	ld HL, tIsPolar
	jr ElectronegDiffDisp
ElectronegDiffNonpolar:
	ld HL, tNonpolar
ElectronegDiffDisp:
	b_call(_VPutS)
	
	ld HL, 52 * 256 + 2		;"Percent Ionic Character"
	ld (PenCol), HL
	ld HL, tPerIonChar
	b_call(_VPutS)
	
	b_call(_FPSquare)		;%IonChar = 1 - e ^ (-1/4 (Xa - Xb)^2)
	ld HL, NegPt25
	b_call(_Mov9ToOp2)
	b_call(_FPMult)
	b_call(_EToX)
	b_call(_OP2Set1)
	b_call(_InvSub)
	ld HL, OneHundred
	b_call(_Mov9ToOp2)
	b_call(_FPMult)
	
	ld A, 4
	b_call(_DispOp1A)
	
	b_call(_PopOp1)		;retrieve electroneg diff
	
	call ifastcopy
ElectronegDiffPause:
	b_call(_GetCSC)
	or A
	jr z, ElectronegDiffPause
	
	ld HL, KeyElectro
	call HandleKey
	
	jp ElectronegDiffPause
	
ElectronegDiffSto:
	b_call(_StoAns)
	jp features

ElectronegDiffLp:			;'subroutine' where user inputs element symbol, OUTPUT: buffer
	call ifastcopy
	call GetCSCCur
	
	ld HL, keyElectro2
	call HandleKey
	
	ld B, A
	ld A, (size)
	cp 3;max
	jr z, ElectronegDiffLp
	ld A, B
	
	call GetChar
	jr c, ElectronegDiffLp
	
	call SaveUpLow
	b_call(_VPutMap)
	jr ElectronegDiffLp
	
ElectronegDiffDel:
	call Delete
	jr ElectronegDiffLp

ElectronegDiffClr:
	ld A, (size)
	or A
	jp z, calculate
	
	ld A, 2
	call ClearIn
	jr ElectronegDiffLp
	
ElectronegDiffEnter:
	ld A, (size)
	or A
	jr z, ElectronegDiffLp
	xor A
	call SaveIn
	ld HL, size
	dec (HL)
	call curoff
	ret
	
ElectronegDiffErr1:
	ld HL, error
	call DispErr
	jp ElectronegDiff1
	
ElectronegDiffErr2:
	ld HL, error
	call DispErr
	
	ld HL, 25 * 256 + 2
	ld (PenCol), HL
	ld HL, tPromptEle2
	b_call(_VPutS)
	ld HL, 31 * 256 + 2
	ld (PenCol), HL
	ld HL, buffer
	b_call(_VPutS)
	
	jp ElectronegDiff2
	
ElectronegDiffSub:			;subroutine that searches elements
	ld DE, buffer
	ld C, 0
	call SearchStr
	ret
	
ElectronegDiffSub1:
	call ElectronegDiffSub
	jr c, ElectronegDiffErr1
	ret
	
ElectronegDiffSub2:
	call ElectronegDiffSub
	jr c, ElectronegDiffErr2
	ret
	
GetElectroneg:			;subroutine that takes atomic number (A) and outputs pointer to electroneg (HL)
	call GetEle1
	call nextstr
	call nextstr
	call SkipToAtomic		;skip to electronegativity
	call SkipData			;skip radius
	call SkipData			;skip cov radius
	ld A, %01000000
	call SkipFlagged		;skip ionization energy
	ret
