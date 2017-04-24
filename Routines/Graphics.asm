; ===============================================================
; Graphical routines
; ===============================================================

; ===============================================================
; ClrBuff:
; Clears PlotSScreen buffer
; ===============================================================

ClrBuff:
	ld HL, PlotSScreen
	ld (HL), 0
	ld DE, PlotSScreen + 1
	ld BC, 768
	ldir
	ret
	
; ===============================================================
; Drawbox:
; draws a 5 x 5 box
; Input: A = x position
;	  B = y position
; ===============================================================

drawbox:
	call getpixel
	ld B, A
	ld D, %10000100
	ld E, 0
	ld A, %11111100
	ld C, 0
	jr z, drawboxnorm
	or A
drawboxtop:
	rra
	rr C
	rr D
	rr E
	djnz drawboxtop
drawboxnorm:
	push AF
	or (HL)
	ld (HL), A
	inc HL
	ld A, C
	push AF
	or (HL)
	ld (HL), A
	
	ld C, 11
	ld B, 4
drawboxmid:
	push BC
	ld B, 0
	add HL, BC
	ld A, D
	or (HL)
	ld (HL), A
	inc HL
	ld A, E
	or (HL)
	ld (HL), A
	pop BC
	djnz drawboxmid
	inc C
	add HL, BC
	pop AF
	or (HL)
	ld (HL), A
	dec HL
	pop AF
	or (HL)
	ld (HL), A
	
	ret
	
; ===============================================================
; DrawEle:
; Draws element box
; ===============================================================

DrawEle:
	Line(17,0,30,0)		;draw element box
	Line(16,1,16,14)
	Line(17,15,30,15)
	Line(31,1,31,14)
	ret
	
; ===============================================================
; DrawPromptBox:
; Draws a prompt box in middle of screen
; ===============================================================

DrawPromptBox:
	Line(1,27,94,27)				;draw input box
	Line(95,28,95,35)
	Line(94,36,1,36)
	Line(0,35,0,28)
	ret
	
; ===============================================================
; Drawrow:
; Draws a row of boxes
; Input: A = x position
;	  B = y position
;	  C = number of boxes
; ===============================================================

drawrow:
	push AF
	push BC
	call drawbox
	pop BC
	ld A, 5
	add A, B
	ld B, A
	pop AF
	dec C
	jr nz, drawrow
	ret
	
; ===============================================================
; Drawcol:
; Draws a column of boxes
; Input: A = x position
;	  B = y position
;	  C = number of boxes
; ===============================================================

drawcol:
	push AF
	push BC
	call drawbox
	pop BC
	pop AF
	add A, 5
	dec C
	jr nz, drawcol
	ret
	
; ===============================================================
; Drawcur:
; Draws the XOR cursor at the given element
; Input: (elex) = x position
;	  (eley) = y position
; ===============================================================

drawcur:
	ld A, (eley)	
	ld B, A
	inc B
	ld A, (elex)
	inc A
	call getpixel
	ld B, A
	ld DE, cursor
	ld C, 4
drawcur1:
	push BC
	ld A, B
	or A
	ld A, (DE)
	ld C, 0
	jr z, drawcur3
	or A
drawcur2:
	rra
	rr C
	djnz drawcur2
drawcur3:
	xor (HL)
	ld (HL), A
	inc HL
	ld A, C
	xor (HL)
	ld (HL), A
	ld BC, 11
	add HL, BC
	inc DE
	pop BC
	dec C
	jr nz, drawcur1
	ret
		
; ===============================================================
; clrele
; Clears element box
; ===============================================================

clrele:
	ld A, 8
	ld HL, PlotSScreen + 16 / 8
	ld DE, PLotSScreen + 16 / 8 + 1
	ld B, 0
	ld C, 7
	call clrelelp
	
	ld A, 8
	ld B, %00000001
	ld C, 4
	call clrelelp
	
	call drawele
	ret
		
clrelelp:					;"subroutine", accepts HL, DE, A, B, C as params
	push HL
	push DE
	push BC
	ld B, 0
	ld (HL), 0
	ldir
	pop BC
	inc HL
	ld (HL), B
	pop DE
	pop HL
	push BC
	ld BC, 12
	add HL, BC
	ex DE, HL
	add HL, BC
	ex DE, HL
	pop BC
	dec A
	jr nz, clrelelp
	
	ret
	
; ===============================================================
; CursOn:
; Displays input cursor
; Input: (PenCol) = column of cursor
;	  (PenRow) = row of cursor
; Destroys: AF, DE
; ===============================================================

curson:
	res 0, (IY + Asm_Flag1)
	ld A, 60
	ld (counter), A
	ld A, (cursorA)
	b_call(_VPutMap)
	ld A, (PenCol)
	ld HL, cursorwid
	ld B, (HL)
	sub B
	ld (PenCol), A
	call fastcopys
	ret

; ===============================================================
; CurOff:
; Clears input cursor
; Input: (PenCol) = column of cursor
;	  (PenRow) = row of cursor
; Destroy: AF, DE
; ===============================================================

curoff:
	set 0, (IY + Asm_Flag1)
	ld A, 60
	ld (counter), A
	ld A, $06
	b_call(_VPutMap)
	ld A, (PenCol)
	sub 4
	ld (PenCol), A
	call fastcopys
	ret

; ===============================================================
; Init:
; Sets up periodic table and other stuff
; ===============================================================

init:
	call ClrBuff
	call periodic
	call DrawEle
	
	Line(1,54,94,54)		;draw input box
	Line(0,55,0,62)
	Line(1,63,94,63)
	Line(95,55,95,62)
	
	ld HL, 2 + 256 * 56
	ld (PenCol), HL
	ld A, $23
	bit ShiftAlpha, (IY + ShiftFlags)
	jr z, init1
	ld A, $41
init1:
	b_call(_VPutMap)
	ld A, 8
	ld (PenCol), A
	ld HL, prompt	
	b_call(_VPutS)
	
	Line(8,54,8,63)
	ret
	
; ===============================================================
; Page:
; Sets up element page
; Input: (curpage) = # of current page
; Output: HL = pointer to current element's mass
; ===============================================================

Page:
	ld HL, PlotSScreen
	ld (HL), $FF
	ld DE, PlotSScreen+1
	ld BC, 7 * 12
	ldir
	
	ld (HL), 0
	ld BC, 768 - (7 * 12)
	ldir
	
	call geta
	call GetEle1
	
	ld DE, 2
	ld (PenCol), DE
	set textInverse, (IY + textFlags)
	push HL
	ld A, (curele)
	call IntStr
	b_call(_VPutS)
	pop HL
	
	push HL
	ld A, 82
	ld (PenCol), A
	b_call(_VPutS)
	xor A
	call centertext
	
	res textInverse, (IY + textFlags)
	
	Line(0,55,95,55)
	Line(0,63,95,63)
	
	ld H, 0
	ld D, 0
PageLnLp:
	push HL
	push DE
	ld L, 55
	ld E, 63
	call fastlineb
	pop DE
	pop HL
	ld A, 19
	add A, H
	ld H, A
	ld A, 19
	add A, D
	ld D, A
	cp 95 + 19
	jr nz, PageLnLp
	
	set TextEraseBelow, (IY + TextFlags)
	ld HL, 1 + 56 * 256
	ld (PenCol), HL
	ld HL, generalprop
	ld B, 5
PageTxtLp:
	call PageChk
	jr nz, PageTxtLpSkp
	set textInverse, (IY + textFlags)
PageTxtLpSkp:
	b_call(_VPutS)
	ld A, (PenCol)
	inc A
	ld (PenCol), A
	call PageChk
	jr nz, PageTxtLpSkp2
	res textInverse, (IY + textFlags)
PageTxtLpSkp2:
	djnz PageTxtLp
	
	pop HL
	call nextstr
	call nextstr
	
	ret

PageChk:
	ld A, (CurPage)
	ld C, A
	ld A, 5
	sub C
	cp B
	ret
	
; ===============================================================
; DrawHeader
; Draws a header
; Input: HL = pointer to string
; ===============================================================

DrawHeader:
	push HL
	call ClrBuff
	pop HL
	xor A
	call centertext
	ld HL, 8
	ld DE, 95 * 256 + 8
	call fastlined
	ld HL, 10 * 256 + 2
	ld (PenCol), HL
	ret
	
; ===============================================================
; DrawTitle:
; Draws the Eclectic title and menu header
; Input: HL = pointer to menu header str (must be padded)
; ===============================================================

DrawTitle:
	push HL
	call ClrBuff
	
	xor A				;ion parameter
	ld B, 15			;display title
	ld C, 96/8
	ld HL, 0
	ld IX, title
	call Largespritehl
	
	ld HL, 16 * 256 + 2
	ld (PenCol), HL
	ld A, $C6
	b_call(_VPutMap)
		
	ld B, 5
	ld A, 90
	ld L, 17
	ld IX, antisigma
	call isprite
	
	Line(8,19,88,19)
	pop HL
	
	push HL
	ld A, 16
	call centertext
	pop HL
	ret