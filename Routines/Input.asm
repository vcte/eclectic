; ===============================================================
; Input (Input related routines)
; ===============================================================

; ===============================================================
; InitInput:
; Initializes input system
; ===============================================================

InitInput:
	ld HL, 16 * 256 + 2
	ld (PenCol), HL
InitInput1: 
	xor A
	ld (size), A
InitInput2:
	ld A, 1
	ld (alphanum), A
	ld A, $7C
	ld (cursorA), A
	ld A, 2
	ld (cursorwid), A
	
	set 1, (IY + Asm_Flag1)
	call curson
	
	ret
	
; ===============================================================
; GetCSCCur
; Waits for GetCSC input while blinking cursor
; Output: A = GetCSC keycode
; ===============================================================

GetCSCCur:
	bit 1, (IY + Asm_Flag1)
	jr z, GetCSCCurLp
	ei \ halt
	ld A, (counter)
	dec A
	ld (counter), A
	or A
	jr nz, GetCSCCurLp
	bit 0, (IY + Asm_Flag1)
	jr z, GetCSCCurOff
	call curson
	jr GetCSCCurLp
GetCSCCurOff:
	call curoff
GetCSCCurLp:
	b_call(_GetCSC)
	or A
	jr z, GetCSCCur
	ret
	
; ===============================================================
; Delete
; Deletion routine, part of input system
; Input: (size)
;	  (PenCol)
; ===============================================================

Delete:
	ld A, (size)			;if nothing inputted,
	or A				;then return
	ret z
	dec A
	ld (size), A
	call curoff
	call GetBufChar
	b_call(_LoadPattern)
	ld HL, sFont_record
	ld B, (HL)
	ld A, (PenCol)
	sub B
	ld (PenCol), A
	push AF
	ld A, $06
	b_call(_VPutMap)
	ld A, $20
	b_call(_VPutMap)
	pop AF
	ld (PenCol), A
	call encur
	ret
	
GetBufChar:
	ld A, (size)			;(size) is dec'ed from pointing to an empty space
	ld B, 0			;to pointing to the last character of the str
	ld C, A			;which is the char passed to the b_call
	ld HL, buffer
	add HL, BC
	ld A, (HL)
	ret
	
; ===============================================================
; ClearIn
; Clearing routine, part of input system
; Input: A = PenCol value to back up to
;	  (size)
; ===============================================================
	
ClearIn:
	ld C, A			;save input
	ld A, (size)			;if nothing inputted
	or A				;then return
	ret z
	call curoff
	ld A, C			;back up PenCol to input value
	ld (PenCol), A
	ld A, (size)
	ld B, A
ClearInLp:
	ld A, $06
	b_call(_VPutMap)
	ld A, $20
	b_call(_VPutMap)
	ld A, $20
	b_call(_VPutMap)
	djnz ClearInLp
	ld A, C
	ld (PenCol), A
	xor A				;zero out size
	ld (size), A
	call encur
	ret
	
; ===============================================================
; SaveIn
; Saves inputted char to buffer
; Input: A = ASCII value to save
;	  (size)
; ===============================================================

SaveIn:
	ld HL, size			;save char to buffer
	ld B, 0
	ld C, (HL)
	inc (HL)
	ld HL, buffer
	add HL, BC
	ld (HL), A
	ret
	
; ===============================================================
; SaveUpLow
; Smart saves inputted char as either upper or lower case
; Input: A = ASCII value to save
;	  (size)
; ===============================================================

SaveUpLow:
	ld B, A
	ld A, (size)
	or A
	ld A, B
	jr z, SaveUp
	add A, $20
SaveUp:
	call SaveIn
	ret