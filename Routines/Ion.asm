; ===============================================================
; Ion Routines
; ===============================================================

; ===============================================================
; IonFastCopy
; ===============================================================

IonFastCopy:
	di
	ld	a,$80				; 7
	out	($10),a			; 11
	ld	hl,PlotSScreen-12-(-(12*64)+1)	; 10
	ld	a,$20				; 7
	ld	c,a				; 4
	inc	hl				; 6 waste
	dec	hl				; 6 waste
IonFastCopyAgain:
	ld	b,64				; 7
	inc	c				; 4
	ld	de,-(12*64)+1			; 10
	out	($10),a			; 11
	add	hl,de				; 11
	ld	de,10				; 10
IonFastCopyLp:
	add	hl,de				; 11
	inc	hl				; 6 waste
	inc	hl				; 6 waste
	inc	de				; 6
	ld	a,(hl)				; 7
	out	($11),a			; 11
	dec	de				; 6
	djnz	IonFastCopyLp			; 13/8
	ld	a,c				; 4
	cp	$2B+1				; 7
	jr	nz, IonFastCopyAgain		; 10/1
	ret					; 10
	
; ===============================================================
; IonGetPixel
; ===============================================================

IonGetPixel:
	ld	d,$00
	ld	h,d
	ld	l,e
	add	hl,de
	add	hl,de
	add	hl,hl
	add	hl,hl
	ld	de, PlotSScreen
	add	hl,de
	ld	b,$00
	ld	c,a
	and	%00000111
	srl	c
	srl	c
	srl	c
	add	hl,bc
	ld	b,a
	inc	b
	ld	a,%00000001
IonGetPixelLp:
	rrca
	djnz	IonGetPixelLp
	ret
	
; ===============================================================
; IonPutSprite
; ===============================================================

IonPutSprite:
	ld	e,l
	ld	h,$00
	ld	d,h
	add	hl,de
	add	hl,de
	add	hl,hl
	add	hl,hl
	ld	e,a
	and	$07
	ld	c,a
	srl	e
	srl	e
	srl	e
	add	hl,de
	ld	de, PlotSScreen
	add	hl,de
IonPutSpriteLp1:
	ld	d,(ix)
	ld	e,$00
	ld	a,c
	or	a
	jr	z,IonPutSpriteSkip1
IonPutSpriteLp2:
	srl	d
	rr	e
	dec	a
	jr	nz,IonPutSpriteLp2
IonPutSpriteSkip1:
	ld	a,(hl)
	xor	d
	ld	(hl),a
	inc	hl
	ld	a,(hl)
	xor	e
	ld	(hl),a
	ld	de,$0B
	add	hl,de
	inc	ix
	djnz	IonPutSpriteLp1
	ret
	
; ===============================================================
; IonLargeSprite
; ===============================================================

IonLargeSprite:
	di
	ex	af,af'
	ld	a,c
	push	af
	ex	af,af'
	ld	e,l
	ld	h,$00
	ld	d,h
	add	hl,de
	add	hl,de
	add	hl,hl
	add	hl,hl
	ld	e,a
	and	$07
	ld	c,a
	srl	e
	srl	e
	srl	e
	add	hl,de
	ld	de, PlotSScreen
	add	hl,de
IonLargeSpriteLoop1:
	push	hl
IonLargeSpriteLoop2:
	ld	d,(ix)
	ld	e,$00
	ld	a,c
	or	a
	jr	z,IonLargeSpriteSkip1
IonLargeSpriteLoop3:
	srl	d
	rr	e
	dec	a
	jr	nz,IonLargeSpriteLoop3
IonLargeSpriteSkip1:
	ld	a,(hl)
	xor	d
	ld	(hl),a
	inc	hl
	ld	a,(hl)
	xor	e
	ld	(hl),a
	inc	ix
	ex	af,af'
	dec	a
	push	af
	ex	af,af'
	pop	af
	jr	nz,IonLargeSpriteLoop2
	pop	hl
	pop	af
	push	af
	ex	af,af'
	ld	de,$0C
	add	hl,de
	djnz	IonLargeSpriteLoop1
	pop	af
	ret