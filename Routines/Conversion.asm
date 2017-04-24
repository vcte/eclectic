; ===============================================================
; Conversion Routines
; ===============================================================

; ===============================================================
; IntStr:
; Converts an integer to a NTBS string
; Input: A = integer to convert
; Output: (conv) = converted string
;	   HL = pointer to conv
;	   A = str length
; ===============================================================

IntStr:
	ld C, 3
	
IntStrlp:
	dec C
	ld D, 10
	call div		;A / 10
	ld B, $30		;find ASCII equivalent of remainder
	add A, B
	ex DE, HL
	ld HL, conv		;sto to (conv)
	ld B, 0
	add HL, BC
	ld (HL), A
	ex DE, HL
	ld A, L		;ret if quotient is zero
	or A
	jr nz, IntStrlp	;else, loop
	
	ld B, C
	ld A, B
	or A
	jr z, intstr0		;skip if already left aligned
IntStrlp2:
	push BC		;shift bytes to the left until C = 0 
	ld HL, conv + 1
	ld DE, conv
	ld BC, 2
	ldir
	pop BC
	djnz intstrlp2
IntStr0:
	ld A, 3
	sub C
	push AF
	ld HL, conv
	ld B, 0
	ld C, A
	add HL, BC
	ld (HL), 0
	ld HL, conv
	pop AF
	
	ret
	
; ===============================================================
; BCDStr:
; Converts BCD to a NTBS string
; Input: HL = pointer to start of BCD
; Output: (BCD) = converted string
;	   HL = pointer to bcd
; ===============================================================

BCDStr:
	ld DE, bcd ;86FE
BCDStrlp:
	ld A, (HL)
	ld B, 4
BCDStr1:
	srl A			;upper 4 bits of A into A
	rr C			;lower 4 bits of A into C
	djnz BCDStr1
	ld B, 4
BCDStr2:
	srl C
	djnz BCDStr2
	
	or A			;exit if null terminated
	jr z, BCDStr0
	ld B, $2D
	add A, B
	ld (DE), A
	inc DE
	
	ld A, C
	or A
	jr z, BCDStr0
	ld B, $2D
	add A, B
	ld (DE), A
	inc DE
	
	inc HL
	jr BCDStrlp
BCDStr0:
	xor A
	ld (DE), A
	ld HL, bcd
	ret
	
; ===============================================================
; StrInt:
; Converts a string to an 8 bit unsigned integer
; Input: (input) = string input
; Output: B = converted integer
;	   c = error
; ===============================================================

StrInt:
	ld HL, input
StrInt2:
	ld B, 0
StrIntLp:
	ld A, (HL)
	inc HL
	or A
	ret z			;end if no more chars
	sub '0'
	ret c			;end if non-numerical char
	cp 10
	ccf
	ret c
	ld C, A
	ld A, B
	cp 26			;end if overflow (260+)
	ccf
	ret c
	ld D, B		;save num in case of overflow
	add A, A		;mult current number by 10
	add A, A
	add A, B
	add A, A
	add A, C		;add new num
	ld B, A		;sto to B
	jr nc, StrIntLp
	ld B, D		;exit in case of overflow
	ret
	
; ===============================================================
; StrFP:
; Converts a NBTS string to an FP number
; Input: HL = pointer to string start
;	  B = max size of str
; Output: OP1 = FP number
;	   c = error
;	   HL = pointer to string end
; ===============================================================

StrFp:
	push BC
	call BCDFPClear
	pop BC
	
	ld A, (HL)			;if character after the element symbol is a number or dot...
	cp '.'
	ret c
	cp '9' + 1
	ccf
	ret c
	
	ld DE, block18		;...then find the number's value
	sub '.' - 1
	ld (DE), A
	inc HL
	inc DE
StrFPLp:
	ld A, (HL)
	cp '.'
	jr c, StrFPNotNum
	cp '9' + 1
	jr nc, StrFPNotNum
	
	sub '.' - 1
	ld (DE), A
	inc DE
	inc HL
	djnz StrFPLp
StrFPNotNum:
	xor A
	ld (DE), A
	
	push HL
	call BCDFPDone1		;subscript value into OP1
	pop HL
	or A
	ret
	
; ===============================================================
; BCDFP
; Converts a BCD to floating point number
; Input: HL = pointer to BCD
; Output: OP1 = FP number
; ===============================================================

BCDFP:
	ld A, (HL)
	cp $30				;if BCD is zero
	jp z, BCDFPZero		;set OP1 to 0
	
	call BCDFPClear
	
	ld DE, block18		;extracts BCD to 18 byte data block
BCDFPLp:				;ex: $41, $33, $AC, $70 would become
	ld A, (HL)			;    $04, $01, $03, $03, $0A, $0C, $07, $00
	inc HL
	call BCDFPNib
	ld B, A
	ld A, C
	ld (DE), A
	inc DE
	or A
	jr z, BCDFPDone1
	ld A, B
	ld (DE), A
	inc DE
	or A
	jr z, BCDFPDone1
	jr BCDFPLp
	
BCDFPDone1:
	ld A, $FF			;default value of CommaPos - if comma not found, then (CommPos) = $FF
	ld (CommaPos), A
	
	ld HL, block18
	ld DE, block18A
	ld B, 0			;set counter to find first significant digit
BCDFPLp2:				;move HL to first significant, nonzero digit
	ld A, (HL)
	cp 4
	jr nc, BCDFPDone2
	or A
	jr z, BCDFPDone2
	cp 1				;if comma is encountered
	jr nz, BCDFPSkip0
	ld A, B			;then mark its position in the BCD
	ld (CommaPos), A
BCDFPSkip0:
	inc HL
	inc B
	jr BCDFPLp2
BCDFPDone2:
	ld A, B
	ld (sig1), A
	
;	ld B, 0			;set counter to find pos of comma
BCDFPLp3:
	ld A, (HL)
	inc HL
	or A
	jr z, BCDFPDone3
	cp 1				;if comma is encountered
	jr nz, BCDFPSkip
	ld A, B			;then mark its position in the BCD
	ld (CommaPos), A
	jr BCDFPLp3
BCDFPSkip:
	sub 3				;convert each digit in block18 to TI's FP format, store in block18A
	ld (DE), A
	inc DE
	inc B
	jr BCDFPLp3
BCDFPDone3:
	ld A, B			;set length (from first sig to end of bcd)		
	ld (LengthBCD), A
					;find exponent through divide and conquer
	ld HL, commapos		;3 possibilities:
	ld A, $FF
	cp (HL)
	jr z, BCDFPSkip2
	ld A, (sig1)
	cp (HL)
	jr z, BCDFPSkip2
	cp (HL)
	jr c, BCDFPSkip2		;(1): (sig1) > (commapos), therefore, FP exponent < $80 && FP is a NonInt < 1
	
	ld A, $80			;Exp = $80 + (CommaPos) - (Sig1)
	ld HL, CommaPos
	ld B, (HL)
	add A, B
	dec HL
	ld B, (HL)
	sub B
	jr BCDFPExp
	
BCDFPSkip2:
	ld A, (CommaPos)
	cp $FF
	jr z, BCDFPSkip3		;(2): (CommaPos) /= 0, therefore, FP exponent > $80 && FP is a NonInt > 1
	
	ld A, $80			;Exp = $80 + (CommaPos) - (sig1) - 1
	ld HL, CommaPos
	ld B, (HL)
	add A, B
	dec HL
	sub (HL)
	dec A
	jr BCDFPExp
	
BCDFPSkip3:				;(3): Else, FP exponent > $80 and FP is whole #
	ld A, $80			;Exp = $80 + (length) - (sig1) - 1
	ld HL, LengthBCD
	add A, (HL)
	dec HL
	dec HL
	sub (HL)
	dec A
	
BCDFPExp:
	ld (block9 + 1), A		;enter exponent
	ld HL, block18A
	ld DE, block9 + 2
	ld B, 7
	
BCDFPLp4:
	push BC			;compress data in 18 byte block back into 9 byte OP stuff
	ld C, 0
	ld A, (HL)
	inc HL
	ld B, 4
BCDFPLp42:
	srl A
	rr C
	djnz BCDFPLp42
	ld A, (HL)
	inc HL
	or C
	ld (DE), A
	inc DE
	pop BC
	djnz BCDFPLp4
	
	ld HL, block9
	rst rMov9ToOp1
	ret
	
BCDFPNib:				;'subroutine' that extracts nibbles from A and outputs to CA
	ld B, 4
	ld C, 0
BCDFPNibLp:	
	sla A
	rl C
	djnz BCDFPNibLp
	ld B, 4
BCDFPNibLp2:
	srl A
	djnz BCDFPNibLp2
	ret
	
BCDFPClear:	
	push HL			;clears out both 18 byte data blocks and temp data and 9 byte block
	ld HL, block9
	xor A
	ld (HL), A
	ld DE, block9 + 1
	ld BC, 18 * 2 + 3 + 9
	ldir
	pop HL
	ret
	
BCDFPZero:
	b_call(_OP1Set0)
	ret
	
; ===============================================================
; IntFP:
; Converts a 1-byte integer to FP
; Input: A = integer
; Output: OP1 = FP
; ===============================================================

IntFP:
	or A
	jr z, IntFPZero
	call IntStr
	call BCDFPClear
	ld HL, conv
	ld DE, block18
IntFPLp:
	ld A, (HL)
	or A
	jr z, IntFPDone
	
	sub '0' - 3
	ld (DE), A
	inc DE
	inc HL
	jr IntFPLp
IntFPDone:
	xor A
	ld (DE), A
	
	call BCDFPDone1
	ret
	
IntFPZero:
	b_call(_OP1Set0)
	ret
	
; ===============================================================
; Int2FP:
; Converts a 2-byte integer to FP
; Input: HL = integer
; Output: OP1 = FP
; ===============================================================

Int2FP:
	push HL				;OP1 = 256 * H (as FP) + L (as FP)
	ld A, H
	call IntFP
	ld HL, FP256
	b_call(_Mov9ToOp2)
	b_call(_FPMult)
	b_call(_Op1ToOp2)
	pop HL
	ld A, L
	call IntFP
	rst rFPAdd
	ret
	
; ===============================================================
; GetNum:
; Get ASCII number from GetCSC table
; Input: A = Scan code
; Output: A = ASCII
;	   c = error
; ===============================================================

GetNum:
	sub $12			;discard chars under '3' and over '7'
	ret c
	cp $24 - $12 + 1
	ccf
	ret c
	
	ld HL, numtable
	ld D, 0
	ld E, A
	add HL, DE
	ld A, (HL)
	or A
	ret nz
	scf
	ret

; ===============================================================
; GetChar:
; Get ASCII character from GetCSC table
; Input: A = Scan code
; Output: A = ASCII
; 	   c = error
; ===============================================================

GetChar:
	sub $0B			;discard characters under 'W' and over 'A'
	ret c
	cp $2F - $0B + 1
	ccf
	ret c
	
	ld HL, chartable		;get char from table
	ld D, 0
	ld E, A
	add HL, DE
	ld A, (HL)
	or A
	ret nz
	scf
	ret
	
; ===============================================================
; CharListNm:
; Converts a string of ASCII chars to a list name
; Input: HL = pointer to ASCII string
; Output: tokenstr = Token string
;	   HL = tokenstr
; ===============================================================

CharListNm:
	ld DE, tokenstr
	ld A, RealObj				;OPTIMIZE w/ 2 byte regs
	ld (DE), A
	inc DE
	ld A, tVarLst
	ld (DE), A
	inc DE
	ld A, (HL)				;special value of 2 denotes L1 | L2, or the like
	cp 2
	jr z, CharListNm1
CharListNmLp:
	ld A, (HL)
	or A
	jr z, CharListNmDone
	ld (DE), A
	inc DE
	inc HL
	jr CharListNmLp
	
CharListNm1:
	inc HL
	ld A, (HL)
	sub '1'
	ld (DE), A
	inc DE
CharListNmDone:
	xor A
	ld (DE), A
	ld HL, tokenstr
	ret
	
; ===============================================================
; GetA:
; Calculates the atomic number based on cursor position
; Input: (elex) = x position
;	  (eley) = y position
; Output: A = atomic number of element
; ===============================================================

geta:
	xor A
	ld (temp), A
	ld A, (eley)			;row = ((eley) - 3) / 5
	sub 3
	cp 38
	jr c, getat
	sub 13
	ld HL, temp			;f group
	ld (HL), 1
getat:
	ld D, 5
	call div
	ld D, 0			;get min atomic number from row
	ld E, L
	ld HL, rowtable
	add HL, DE
	ld E, (HL)
	ld A, (elex)
	sub 3
	ld D, 5
	call div
	ld A, L			;case by case analysis of L (col) (0 - 17) and E (row) (1, 3, 11, 19, 37, 55, 87)
	cp 17
	jr nz, geta1
	ld A, E
	cp 1
	jr nz, geta1
	ld A, 2			;Helium
	ld (curele), A
	ret
geta1:
	ld A, L
	cp 12
	jr c, geta2
	ld A, E
	cp 19
	jr nc, geta2
	ld A, L
	sub 10				;Groups 2p and 3p
	ld L, A
	jr geta0
geta2:
	ld A, (temp)
	or A
	jr nz, geta3
	ld A, E
	cp 55
	jr c, geta0
	ld A, L
	cp 3
	jr c, geta0
	add A, 14			;Groups 6d and 7d
	ld L, A
	jr geta0
geta3:
	inc L				;inner transition metals
geta0:
	ld A, E
	add A, L
	ld (curele), A
	
	ret
	
; ===============================================================
; GetPos:
; Gets cursor position based on atomic number
; Input: A = atomic number
; Output: (elex) 
; 	   (eley)
; ===============================================================

GetPos:
	cp 3
	jr c, enterr1
	cp 11
	jr c, enterr2
	cp 19
	jr c, enterr3
	cp 37
	jr c, enterr4
	cp 55
	jr c, enterr5
	cp 87
	jr c, enterr6
	;//row 7
	
	cp 90
	jr c, enterr7a
	cp 104
	jp c, enterr7b
	ld C, 33
	call sety
	sub 104			;A = (A - 104) * 5 + 18
	jp enter61
enterr7a:
	ld C, 33
	call sety
	sub 87				;A = (A - 87) * 5 + 3
	jp enter62
enterr7b:
	ld C, 46
	call sety
	sub 90				;A = (A - 90) * 5 + 3		;GLITCH
	jp enter63
enterr1:
	ld C, 3
	call sety
	cp 1
	jr z, enterr1a
	ld A, 88
	ld (elex), A
	ret
enterr1a:
	ld A, 3
	ld (elex), A
	ret
enterr2:
	ld C, 8
	call sety
	call multa5			;A = (A - 3) * 5 + 3 = 5 * A - 12
	sub 12
enterr20:
	cp 13
	jr c, enterr2a
	add A, 50
enterr2a:
	ld (elex), A
	ret
enterr3:
	ld C, 13
	call sety
	call multa5			;A = (A - 11) * 5 + 3 = 5 * A - 52
	sub 52
	jr enterr20
enterr4:
	ld C, 18
	call sety
	call multa5			;A = (A - 19) * 5 + 3 = 5 * A - 92
	sub 92
	ld (elex), A
	ret
enterr5:
	ld C, 23
	call sety
	call multa5			;A = (A - 37) * 5 + 3 = 5 * A - 182
	sub 182
	ld (elex), A
	ret
enterr6:
	cp 58
	jr c, enterr6a
	cp 72
	jr c, enterr6b
	ld C, 28
	call sety
	sub 72				;A = (A - 72) * 5 + 18
enter61:
	call multa5
	add A, 18
	ld (elex), A
	ret
enterr6a:
	ld C, 28
	call sety
	sub 55				;A = (A - 55) * 5 + 3
enter62:
	call multa5
	add A, 3
	ld (elex), A
	ret
enterr6b:
	ld C, 41
	call sety
	sub 58				;A = (A - 58) * 5 + 13
enter63:
	call multa5
	add A, 13
	ld (elex), A
	
	ret