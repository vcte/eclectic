; ===============================================================
; Routines
; ===============================================================

; ===============================================================
; Getpixel:
; Calculates the buffer location of a pixel
; Input: A = x position
;	  B = y position
; Output: HL = location in buffer
;	   A = position of pixel in byte (0 - 7)
; ===============================================================

getpixel:
	ld H, 0			;HL = PlotSScreen + xpos + 12 * ypos
	ld L, B
	ld D, H
	ld E, L
	add HL, HL
	add HL, DE
	add HL, HL
	add HL, HL
	ld E, A
	srl E
	srl E
	srl E
	add HL, DE
	ld DE, PlotSScreen
	add HL, DE
	and 7				;A = A % 8
	ret
	
; ===============================================================
; GetEle:
; Gets location of element data in table
; Input: (CurEle) = current element #
; Output: HL = location of data in table
; ===============================================================

GetEle:
	ld A, (curele)
GetEle1:
	call GetEle2
	call LdHLInd
	ret

GetEle2:
	dec A				;A = 2 * (A - 1)
	sla A
	ld HL, Elements		;get element data
	ld D, 0
	ld E, A
	add HL, DE
	ret
	
; ===============================================================
; GetData:
; Gets location of element data in flag table
; Input: (CurEle) = current element #, 1 relative
; Output: HL = location of data in table
; ===============================================================

GetData:
	ld A, (curele)
GetData1:
	dec A
	ld B, 0
	ld C, A
	ld HL, Element
	add HL, BC
	ret
	
; ===============================================================
; GetDataA:
; Get location of element in flag table, data into A, preserve HL
; Input: (CurEle) = current element #
; Output: A = first entry in flag table
; ===============================================================

GetDataA:
	push HL
	call GetData
	ld A, (HL)
	pop HL
	ret
	

; ===============================================================
; GetBlock:
; Gets block of current element
; Input: (elex) = x coordinate of cursor
; 	  (eley) = y coordinate of cursor
;	  (curele) = current element #
; Output: A = block, l quantum# (see consts)
; ===============================================================

GetBlock:
	ld A, (elex)
	cp 13
	jr nc, getblock2
getblock1:
	ld A, 0
	ret
getblock2:
	cp 63
	jr c, getblock3
	ld A, (eley)
	cp 41
	jr nc, getblock3
	cp 3
	jr z, getblock1
	ld A, 1
	ret
getblock3:
	ld A, (eley)
	cp 41
	jr nc, getblock4
	
	ld A, (curele)
	cp 57
	jr z, getblock4a
	cp 89
	jr z, getblock4a
getblock3a:
	ld A, 2
	ret
getblock4:
	ld A, (curele)
	cp 71
	jr z, getblock3a
	cp 103
	jr z, getblock3a
getblock4a:
	ld A, 3
	ret
	
; ===============================================================
; GetPeriod
; Gets period # of current element
; Input: (eley) = y coordinate of cursor
; Output: A = period
; ===============================================================

GetPeriod:
	ld A, (eley)
	cp 41
	jr c, GetPeriod1
	sub 16
	jr GetPeriod2
GetPeriod1:
	sub 3
GetPeriod2:
	ld D, 5
	call Div
	ld A, L
	inc A
	ld (CurPeriod), A
	ret
	
; ===============================================================
; GetColumn
; Gets column # of current element
; Input: (elex) = x coordinate of cursor
; Output: A = period
; ===============================================================

GetColumn:
	ld A, (eley)
	cp 41
	jr c, GetColumn2
	xor A
	ret
GetColumn2:
	ld A, (elex)
	sub 3
	ld D, 5
	call Div
	ld A, L
	inc A
	ret
	
; ===============================================================
; GetNumToSkip:
; Gets # of data entries to skip based on menusel
; Input: (menusel) = Menu Selection
; Output: (NumToSkip) = # of data to skip
; ===============================================================

GetNumToSkip:
	ld A, (menusel)
	ld HL, menutable
	ld B, 0
	ld C, A
	add HL, BC
	ld A, (HL)
	ld (NumToSkip), A
	ret
	
; ===============================================================
; GetMaxList:
; Gets # elements a list of a given property would have
; Input: (menusel) = Menu Selection
; Output: (MaxList) = # elements
; ===============================================================

GetMaxList:
	ld A, (menusel)
	ld HL, sizearray
	ld B, 0
	ld C, A
	add HL, BC
	ld A, (HL)
	ld (maxlist), A
	ret
	
; ===============================================================
; GetInfo:
; Gets info on an element
; Input: HL = pointer to elements position in table
;	  (NumToSkip) = # data entries to skip
;	  (menusel) = menu selection
;	  (CurEle) = current element #
; Output: HL = pointer to element data
;	   c = 1 if unknown, 0 if known
; ===============================================================

GetInfo:
	call LdHLInd
GetInfo1:
	call nextstr
GetInfo2:
	call nextstr
	
	ld A, (NumToSkip)
	call SkipA
	
	push HL
	ld A, (menusel)
	call TestA
	pop HL
	ret
	
; ===============================================================
; GetSyntMass:
; Gets synthetic mass of an element in FP
; Input: HL = pointer to elements synthetic mass (integer)
; Output: OP1 = FP synthetic mass
; ===============================================================

GetSyntMass:
	ld A, (HL)
	call IntFP
	
	ld HL, FP98
	b_call(_Mov9ToOP2)
	rst rFPAdd
	ret
	
; ===============================================================
; GetMass:
; Gets to the mass data of an element
; Input: A = element's atomic number
; Output: HL = pointer to element's mass
; ===============================================================

GetMass:
	call GetEle1
	call nextstr
	call nextstr
	ret
	
; ===============================================================
; GetPoint:
; Gets x-y position of point
; Input: OP1 = FP number
;	  OP5 = GraphMax / Max ratio
;	  (CurEle) = current element
; Output: H = x coordinate
;	   L = y coordinate
; ===============================================================

GetPoint:
	call Op5ToOp2		;Point.y = (GraphMax) - (GraphMax / Max) (FP)
	b_call(_FPMult)
	
	b_call(_ConvOP1)
	ld B, A			;this subtraction removes the need for an InvSub bcall
	ld A, 55			;(GraphMax) = 55
	sub B
	
	ld HL, XVal
	ld H, (HL)
	ld L, A
	ret
	
; ===============================================================
; GetMax:
; Gets maximum value of a property from array
; Input: (menusel) = Menu Selection
; Output: OP1 = FP max
; ===============================================================

GetMax:
	ld A, (menusel)
	add A, A
	ld HL, maxarray
	ld B, 0
	ld C, A
	add HL, BC
	call LdHLInd
	call Int2FP
	ret
	
; ===============================================================
; InitCurEle:
; Saves (CurEle) and puts 1 into (CurEle)
; ===============================================================

InitCurEle:
	ld A, (curele)
	ld (tempele), A
	ld A, 1
	ld (curele), A
	ret
	
; ===============================================================
; MultA5:
; Multiply A by 5
; ===============================================================

multa5:
	ld B, A
	sla A
	sla A
	add A, B
	ret	
	
; ===============================================================
; SetY:
; Sets (eley) with C and preserves A
; ===============================================================

sety:
	ld B, A
	ld A, C
	ld (eley), A
	ld A, B
	ret
	
; ===============================================================
; Div:
; Divides A by D
; Input: A = dividend
;	  D = divisor
; Output: L = quotient
;	   A = remainder
; ===============================================================

div:
	ld H, 0
	ld L, A
	xor A
	ld B, 16
divlp:
	add HL, HL
	rla
	jr c, divv
	cp d
	jr c, divs
divv:
	sub D
	inc L
divs:
	djnz divlp
	ret 
	
; ===============================================================
; NextBCD:
; Finds next thing after a 0-terminating BCD 
; Input: HL = start of first BCD
; Output: HL = start of next thing
; ===============================================================

NextBCD:
	ld A, (HL)
	inc HL
	ld B, A
	and %00001111
	ret z
	ld A, B
	and %11110000
	ret z
	jr NextBCD
	
; ===============================================================
; CopyStr
; Copies a NBTS string to a location in memory
; Input: HL = string to copy from
; 	  DE = location to copy to
; Output: DE = end of copied string
; ===============================================================

CopyStr:
	ldi
	ld A, (HL)
	or A
	ret z
	jr CopyStr

; ===============================================================
; IsNumber:
; Checks if the value in A is an ASCII number
; Input: A = number
; Output: c = is not a number
; ===============================================================

IsNumber:
	cp '0'
	ret c
	cp '9' + 1
	ccf
	ret c
	or A
	ret
	
; ===============================================================
; IsNumDot:
; Checks if the value in A is an ASCII number or dot
; Input: A = number
; Output: c = is not a number / dot
; ===============================================================

IsNumDot:
	cp '.'
	ret z
	jr IsNumber
	
; ===============================================================
; EnCur:
; Enables input cursor
; ===============================================================

encur:
	bit 1, (IY + Asm_Flag1)
	call z, clrele
	set 1, (IY + Asm_Flag1)
	call curson
	ret

; ===============================================================
; DisCur:
; Disables input cursor
; ===============================================================

discur:
	bit 1, (IY + Asm_Flag1)
	call nz, dispele
	bit 1, (IY + Asm_Flag1)
	call nz, curoff
	res 1, (IY + Asm_Flag1)
	ret
	
; ===============================================================
; GoUp:
; Moves the cursor 1 box up
; ===============================================================

GoUp:
	ld A, (eley)			;test for row 1
	cp 3
	ret z
	cp 8
	jr nz, goup1
	ld A, (elex)			;test row 2
	cp 3
	jr z, goup2
	cp 88
	jr z, goup2
	ret
Goup1:
	ld A, (eley)
	cp 18
	jr nz, goup2			;test row 4
	ld A, (elex)
	cp 13
	jr c, goup2
	cp 63
	jr nc, goup2
	ret
Goup2:
	ld A, (eley)
	sub 5
	cp 36
	jr nz, goup3
	sub 3
Goup3:
	ld (eley), A
	ret
	
; ===============================================================
; GoDown:
; Moves the cursor 1 box down
; ===============================================================

GoDown:
	ld A, (eley)
	cp 33
	jr nz, godown2
	ld A, (elex)			;test row 7
	cp 13
	ret c
	cp 83				;test far right,  SUBJECT TO CHANGE
	ret nc
	ld A, (eley)
	add A, 3
	ld (eley), A
	jr godown3
Godown2:
	ld A, (eley)			;test actinides
	cp 46
	ret z
Godown3:
	ld A, (eley)
	add A, 5
	ld (eley), A
	ret
	
; ===============================================================
; GoLeft:
; Moves the cursor 1 element left
; ===============================================================

GoLeft:
	ld A, (curele)
	cp 1
	ret z
	dec A
	ld (curele), A
	call GetPos
	
	ret
	
; ===============================================================
; GoRight:
; Moves cursor 1 element right
; ===============================================================

GoRight:
	ld A, (curele)
	cp 118
	ret z
	inc A
	ld (curele), A
	call GetPos
	
	ret
	
; ===============================================================
; HandleKey:
; Handles keypresses by cp-ing values and jumping to associated lbls
; Input: A = Scan code
;	  HL = pointer to array
; ===============================================================

HandleKey:
	pop DE
HandleKeyLp:
	ld B, (HL)
	inc HL
	cp B
	jr z, HandleKeyJp
	inc HL
	inc HL
	inc B				;if B = 1, then quit to address
	djnz HandleKeyLp
	
	cp skMode
	jp z, done
	
	ex DE, HL
	jp (HL)
	
HandleKeyJp:
	call LdHLInd
	jp (HL)

#include "BCall.asm"
#include "Conversion.asm"
#include "Display.asm"
#include "Graphics.asm"
#include "Input.asm"
#include "Periodic.asm"
#include "Query.asm"

#ifdef TI83PI
#include "Mirage.asm"
#endif

#ifdef TI83P
#include "Mirage.asm"
#include "Ion.asm"
#endif