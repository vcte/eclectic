; ===============================================================
; Periodic
; Function draws periodic table
; ===============================================================

periodic:				;Draws periodic table
	ld A, 3			;Alkali row
	ld B, 3
	ld C, 7
	call drawrow
	
	ld A, 8			;Alkaline Earth row
	ld B, 8
	ld C, 6
	call drawrow	
	
	ld A, 13
transition:				;Transition metals		
	push AF
	ld B, 18
	ld C, 4
	call drawrow
	pop AF
	add A, 5
	cp 63
	jr nz, transition
	
	ld A, 63
main2:					;right group of main elements
	push AF
	ld B, 8
	ld C, 6
	call drawrow
	pop AF
	add A, 5
	cp 88
	jr nz, main2
	
	ld A, 88			;Noble Gases
	ld B, 3
	ld C, 7
	call drawrow
	
	ld A, 13			;Lanthanides
	ld B, 41
	ld C, 14
	call drawcol
	
	ld A, 13			;Actinides
	ld B, 46
	ld C, 14
	call drawcol
	
	ret
