; ===============================================================
; Features
; ===============================================================

features:
	ld HL, array1
	jp menu
	
Calculate:
	ld HL, array2
	jp menu
		
; ---------------------------------------------------------------
; Preferences
; ---------------------------------------------------------------

Preferences:
	ld HL, array3
	jp menu
	
Units:
	
	
	
MainDatum:
	ld HL, tChooseData
	call SelectProp
	
	
GraphStyle:
	xor A
	ld (vGraphStyle), A
	ld HL, array4
	jp menu
	
GraphStyleBar:
	ld HL, vGraphStyle
	inc (HL)
GraphStyleLine:
	ld HL, vGraphStyle
	inc (HL)
GraphStyleDot:
	jr Preferences
	
	
	
About:
	ld HL, tAbout
	call DrawTitle
	
	ld A, 29
	ld HL, tDescription
	call centertext
	
	ld A, 35
	ld HL, tVersion
	call centertext
	
	ld A, 41
	ld HL, tMe
	call centertext
	
	ld A, 47
	ld HL, tMail
	call centertext
	
	call ifastcopy
AboutLp:
	b_call(_GetCSC)
	or A
	jr z, AboutLp
	
	jr features
	
#include "Export.asm"
#include "Molar Mass.asm"
#include "Electronegativity.asm"
#include "Grapher.asm"