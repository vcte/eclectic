; ===============================================================
; MirageOS Routines
; ===============================================================

; ===============================================================
; NextStr
; ===============================================================

NextStr:
	push AF
	push BC
	xor A
	ld B, 1
	cpir
	pop BC
	pop AF
	ret
	
; ===============================================================
; CenterText
; ===============================================================

CenterText:
	ld (PenRow), A
	ld DE, tempstr3
	push DE
	call MCopyStr
	pop HL
	b_call(_StrLength)
	dec HL
	ld (HL), C
	b_call(_SStringLength)
	sra B
	ld A, $30
	sub B
	ld (PenCol), A
	inc HL
	b_call(_VPutS)
	ret
	
MCopyStr:
	ld A, (HL)
	ld (DE), A
	or A
	ret z
	inc HL
	inc DE
	jr MCopyStr
	
; ===============================================================
; MultHL
; ===============================================================

MultHL:
	ld E, L
	jp MutlHE
	
; ===============================================================
; MultHE
; ===============================================================

MutlHE:
	ld L, 0
	ld D, L
	ld B, 8
MultHE2:
	add HL, HL
	jr nc, MultHE3
	add HL, DE
MultHE3:
	djnz MultHE2
	ret
	
; ===============================================================
; FastLineD
; ===============================================================

FastLineD:
	ld A, $AA
	ld ($FE70), A
	jr FastLineB0

; ===============================================================
; FastLineB
; ===============================================================

FastLineB:
	ld A, 1
FastLineB0:
	di
	cp 1
	ex AF, AF'
	ld A, 1
	ld (iMathPtr5), A
	ld (templine), A
	ld A, D
	sub H
	ld B, A
	jp nc, FastLineB2
	neg
	ld B, A
	ld A, $FF
	ld (iMathPtr5), A
FastLineB2:
	ld A, E
	sub L
	ld C, A
	jp nc, FastLineB3
	neg
	ld C, A
	ld A, $FF
	ld (templine), A
FastLineB3:
	ld E, 0
	ld A, B
	cp C
	jp c, FastLineB5
	ld D, B
	inc B
	
FastLineB6:
	call FastLineRout
	ld A, (iMathPtr5)
	add A, H
	ld H, A
	ld A, E
	add A, C
	ld E, A
	cp D
	jp c, FastLineB4
	sub D
	ld E, A
	ld A, (templine)
	add A, L
	ld L, A
FastLineB4:
	djnz FastLineB6
	ei
	ret
	
FastLineB5:
	ld A, B
	ld B, C
	ld C, A
	ld D, B
	inc B
FastLineB7:
	call FastLineRout
	ld A, (templine)
	add A, L
	ld L, A
	ld A, E
	add A, C
	ld E, A
	cp D
	jr c, FastLineB8
	sub D
	ld E, A
	ld A, (iMathPtr5)
	add A, H
	ld H, A
FastLineB8:
	djnz FastLineB7
	ei
	ret
	
; subroutine - sets pixel
	
FastLineRout: ;44F1
	push HL
	exx
	ex AF, AF'
	jp z, FastLineRout2
	jp c, FastLineRout3
	push AF
	ex AF, AF'
	pop AF
	pop DE
	cp 2
	jr nz, FastLineRout4
	ld A, D
	call ionGetPixel
	xor (HL)
	ld (HL), A
	exx
	ret
	
FastLineRout4:
	ld HL, $FE70
	rlc (HL)
	jr c, FastLineRout5
	jr FastLineRout6
FastLineRout2:
	ex AF, AF'
	pop DE
FastLineRout5:
	ld A, D
	call ionGetPixel
	or (HL)
	ld (HL), A
	exx
	ret
	
FastLineRout3:
	ex AF, AF'
	pop DE
FastLineRout6:
	ld A, D
	call ionGetPixel
	cpl
	and (HL)
	ld (HL), A
	exx
	ret
	
; ===============================================================
; PixelonHL
; ===============================================================

PixelOnHL:
	ld A, H
	ld E, L
	call setPix
	ret
	
; subroutine - sets pixel
	
setPix:
	push HL
	call ionGetPixel
	or (HL)
	ld (HL), A
	pop HL
	ret
	
; ===============================================================
; FastCopyS
; ===============================================================

FastCopyS:
	push HL
	push DE
	push BC
	push AF
	call ionFastCopy
	pop AF
	pop BC
	pop DE
	pop HL
	ret
	
; ===============================================================
; CompStrs
; ===============================================================

CompStrs:
	ld A, (DE)
	cp (HL)
	jp nz, NextStr
	inc HL
	inc DE
	or A
	ret z
	jr CompStrs