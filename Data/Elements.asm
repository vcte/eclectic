; ===============================================================
; Element Data (1 - 25)
; ---------------------------------------------------------------
;Element:
; .db Symbol			(NBTS)
; .db Name 			(NBTS)
;-----------------------------General-----------------------------
; .db Atomic weight		(BCD | int (0 - 196)) (max 4 bytes)
; .db Category (1 nibble keycode) && Phase (2 bit keycode)
;	0 = unknown
;	1 = alkali metals		--IUPAC approved
;	2 = alkaline earth metals
;	3 = pnictogens (not IUPAC approved)
;	4 = chalcogens
;	5 = halogens
;	6 = noble gases 
;	7 = lanthanoids
;	8 = rare earth metals
;	9 = actinoids
;	A = transition metals
;	B = other metals		--wiki
;	C = metalloids
;	D = other non-metals
;     Phase:
;	0 = unknown			--various sources
;	1 = solid
;	2 = liquid
;	3 = gas

;-----------------------------Physical-----------------------------
; .db Density 		(BCD) (max 4 bytes) (MIT) (g/cm3)
; .db Volume			(BCD) (max 3 bytes) (MIT) (cm3/mol)

;-----------------------------Temperature-----------------------------
; .db Melting point		(BCD) (max 4 bytes) (MIT) (K)
; .db Boiling point		(BCD) (max 4 bytes) (MIT) (K)
; .db Heat of Fusion		(BCD) (max 4 bytes) (MIT) (kJ/mol)
; .db Heat of Vaporization	(BCD) (max 4 bytes) (MIT) (kJ/mol)
; .db Specific Heat		(BCD) (max 4 bytes) (MIT) (J/g/K)

;-----------------------------Atomic-----------------------------
; .db Radius 			(BCD) (max 3 bytes) (MIT) (Angstroms)
; .db Cov Radius 		(BCD) (max 3 bytes) (MIT) (Angstroms)
; .db Ionization E 		(BCD) (max 4 bytes) (MIT) (electron volts)
; .db Electronegativity 	(BCD) (max 3 bytes) (MIT)
; .db E- Affinity 		(BCD) (max 3 bytes) (Txt | Cengage | wiki) (electron volts)
; .db Oxidation states 	(NBT Keycodes) (lbl)
;	Nibble 0:
;		0 = null terminate
;		1 = +
;		2 = -
;		4 = * (Plus / Minus)
;		8 = no sign
;	Nibble 1:
;		# = oxidation #
;
;-----------------------------Misc.-----------------------------
; .db Crystal structure	(keycode) (1 byte) (Txt | CC | wiki)
;	0 = unknown
;	1 = hcp
;	2 = ccp
;	3 = bcc
;	4 = bct
;	5 = or
;	6 = rh
;	7 = hex layers | tetra
;	8 = cubic
;	9 = fcc (face centered cubic)
;	10 = diamond cubic
;	11 = spec tetra
;	12 = cryst. hex
; .db Thermal conductivity (BCD) (max 4 bytes) (CC | MIT)
; .db Electric conductivity	(BCD) (max 4 bytes) (CC | MIT)

;				General (8x)
; (1) Category (2) group (3) period (4) block
;				Physical
; (1) phase (2) density (3) volume, +hardness, +color, d @ mp, d @ bp, 
;				Temp.
; (1) melting pt (2) boiling pt (3) q of fusion (4) q of vap (5) spec q c, 3x pt, crit pt,
;				Atomic
; (1) E- config (2) radius (3) covalent radius (4) ion E  (5) electroneg (6) e- affinity (7) Ox states, 
;				Misc
; (1) crystal (2) therm cond (3) elect cond, *abundance, *Heat atomization, *polarizability, a/b type, mag order

; vapor P, s of sound

; ---------------------------------------------------------------
; BCD Format:
; .db byte
; 	bit 0-3 = 1st number
;	bit 4-7 = 2nd number
;	Nibble Range (0 - 15)
;		0 = null terminate
;		1 = . point
;		2 = / reserved
;		3 = numerical zero
;		4 = numerical 1
;		5 = numerical 2
;		6 = numerical 3
;		7 = numerical 4
;		8 = numerical 5
;		9 = numerical 6
;		A = numerical 7
;		B = numerical 8
;		C = numerical 9
;	value of 0 usually indicates data is 'unknown'

; ---------------------------------------------------------------
; Sources:
; IUPAC -- International Union of Pure & Applied Chemistry
; Wiki -- duh
; MIT -- http://web.mit.edu/course/3/3.091/www3/pt/pert1.html
; Txt -- Textbook (Essentials of General Chemistry: Second Edition)
; Cengage -- http://college.cengage.com/chemistry/intro/zumdahl/intro_chemistry/5e/students/protected/periodictables/pt/pt/pt_ea2.html
; lbl -- Lawrence Berkeley Nat Lab (http://www.sciencegeek.net/tables/lblcolortable.pdf)
; CC -- ChemiCool (http://www.chemicool.com/)
; ===============================================================

; ---------------------------------------------------------------
; Element 1
; ---------------------------------------------------------------

Hydrogen:
.db "H", 0
.db "Hydrogen", 0
.db $41, $33, $AC, $70		;1.00794
.db $D3				;nonmetal / gas
;----Physical----;
.db $31, $3B, $CC, $00
.db $47, $14, $00

;----Temperature----;
.db $46, $1B, $40
.db $53, $15, $B0
.db $31, $38, $B8, $00
.db $31, $78, $B4, $00
.db $47, $16, $37, $00

;----Atomic----;
.db $51, $3B, $00
.db $31, $65, $00
.db $46, $18, $CB, $00
.db $51, $50				; electroneg changed from 2.1 to 2.2
.db $31, $A9, $00
.db $11, $21, 0

;---Miscellaneous---;
.db HCP
.db $31, $4B, $38, $00
.db 0

; ---------------------------------------------------------------
; Element 2
; ---------------------------------------------------------------

Helium:
.db "He", 0
.db "Helium", 0
.db $71, $33, $59, $30		;"4.00260", 0
.db $63				;noble / gas
;----Physical----;
.db $31, $4A, $B8, $00
.db $64, $1B, $00

;----Temperature----;
.db $31, $C8, $00
.db $71, $54, $90
.db $31, $35, $40
.db $31, $3B, $70
.db $81, $4C, $60

;----Atomic----;
.db 0
.db $31, $C6, $00
.db $57, $18, $BA, $00
.db $30
.db $30
.db $80

;---Miscellaneous---;
.db HCP				;'ususually'
.db $31, $48, $00
.db 0

; ---------------------------------------------------------------
; Element 3
; ---------------------------------------------------------------

Lithium:
.db "Li", 0
.db "Lithium", 0
.db $91, $C7, $40			;"6.941", 0
.db $11				;alkaline / solid
;----Physical----;
.db $31, $86, $00
.db $46, $14, $00

;----Temperature----;
.db $78, $61, $A0
.db $49, $48, $00
.db $60
.db $47, $A1, $40
.db $61, $8B, $50

;----Atomic----;
.db $41, $88, $00
.db $41, $56, $00
.db $81, $6C, $50
.db $31, $CB, $00
.db $31, $95, $00
.db $11, 0

;---Miscellaneous---;
.db BCC
.db $B7, $1B, $00
.db $44, $1A, $00

; ---------------------------------------------------------------
; Element 4
; ---------------------------------------------------------------

Beryllium:
.db "Be", 0
.db "Beryllium", 0
.db $C1, $34, $54, $B0		;"9.01218", 0
.db $21				;earth / solid
;----Physical----;
.db $41, $B8, $00
.db $80

;----Temperature----;
.db $48, $93, $00
.db $65, $76, $00
.db $44, $1A, $40
.db $5C, $A0
.db $41, $B5, $80

;----Atomic----;
.db $41, $45, $00
.db $31, $C0
.db $C1, $65, $50
.db $41, $8A, $00
.db $30
.db $12, 0

;---Miscellaneous---;
.db HCP
.db $53, $30
.db $31, $58, $00

; ---------------------------------------------------------------
; Element 5
; ---------------------------------------------------------------

Boron:
.db "B", 0
.db "Boron", 0
.db $43, $1B, $44, $00		;"10.811", 0
.db $C1				;metalloid / solid
;----Physical----;
.db $51, $67, $00
.db $71, $90

;----Temperature----;
.db $56, $98, $00
.db $75, $A8, $00
.db $55, $19, $00
.db $83, $A1, $B0
.db $41, $35, $90

;----Atomic----;
.db $31, $CB, $00
.db $31, $B5, $00
.db $B1, $5C, $B0
.db $51, $37, $00
.db $31, $5B, $00
.db $13, 0

;---Miscellaneous---;
.db RH					;B12 is icosahedral
.db $5A, $17, $00
.db $81, $30, 4

; ---------------------------------------------------------------
; Element 6
; ---------------------------------------------------------------

Carbon:
.db "C", 0
.db "Carbon", 0
.db $45, $13, $43, $A0		;"12.0107", 0
.db $D1				;
;----Physical----;
.db $51, $59, $00
.db $81, $60

;----Temperature----;
.db $6B, $58, $00
.db $84, $33, $00
.db 0
.db $A4, $80
.db $31, $A3, $C0

;----Atomic----;
.db $31, $C4, $00
.db $31, $AA, $00
.db $44, $15, $90
.db $51, $88, $00
.db $41, $59, $00
.db $12, $14, $24, 0

;---Miscellaneous---;
.db 7
.db $7A, $30				;depends on allotrope
.db $31, $3A, $00

; ---------------------------------------------------------------
; Element 7
; ---------------------------------------------------------------

Nitrogen:
.db "N", 0
.db "Nitrogen", 0
.db $47, $13, $39, $A0		;"14.0067", 0
.db $33
;----Physical----;
.db $41, $58, $40
.db $4A, $16, $00

;----Temperature----;
.db $96, $14, $80
.db $AA, $16, $77, $00
.db $31, $69, $00
.db $51, $AC, $5B, $00
.db $41, $37, $50

;----Atomic----;
.db $31, $C5, $00
.db $31, $A8, $00
.db $47, $18, $67, $00
.db $61, $37, $00
.db $30
.db $41, $42, $43, $14, $15, 0	;NOTE: Oxidation states don't fit on screen

;---Miscellaneous---;
.db HCP
.db $31, $35, $8B, $60
.db 0

; ---------------------------------------------------------------
; Element 8
; ---------------------------------------------------------------

Oxygen:
.db "O", 0
.db "Oxygen", 0
.db $48, $1C, $CC, $70		;"15.9994", 0
.db $43
;----Physical----;
.db $41, $75, $C0
.db $47, $00

;----Temperature----;
.db $87, $1B, $00
.db $C3, $14, $BB, $00
.db $31, $55, $50
.db $61, $74, $3C, $00
.db $31, $C5, $00

;----Atomic----;
.db $31, $98, $00
.db $31, $A6, $00
.db $46, $19, $4B, $00
.db $61, $77, $00
.db $41, $79, $00
.db $22, 0

;---Miscellaneous---;
.db 0
.db $31, $35, $8B, $60		;wtf, same value as Nitrogen...
.db 0

; ---------------------------------------------------------------
; Element 9
; ---------------------------------------------------------------

Fluorine:
.db "F", 0
.db "Fluorine", 0
.db $4B, $1C, $CB, $70		;"18.9984", 0 
.db $53
;----Physical----;
.db $41, $9C, $90
.db $4A, $14, $00

;----Temperature----;
.db $86, $18, $80
.db $B8, $00
.db $31, $59, $00
.db $61, $59, $CB, $00
.db $31, $B5, $70

;----Atomic----;
.db $31, $8A, $00
.db $31, $A5, $00
.db $4A, $17, $55, $00
.db $61, $CB, $00
.db $61, $73, $00
.db $21, 0

;---Miscellaneous---;
.db CUB
.db $31, $35, $AA, $00
.db 0

; ---------------------------------------------------------------
; Element 10
; ---------------------------------------------------------------

Neon:
.db "Ne", 0
.db "Neon", 0
.db $53, $14, $AC, $A0		;"20.1797", 0
.db $63
;----Physical----;
.db $31, $C3, $30
.db $49, $1C, $00

;----Temperature----;
.db $57, $18, $80
.db $5A, $14, $00
.db $31, $67, $00
.db $41, $AA, $00
.db $41, $36, $00

;----Atomic----;
.db $31, $84, $00
.db $31, $A4, $00
.db $54, $18, $97, $00
.db $30
.db $30
.db $80

;---Miscellaneous---;
.db FCC
.db $31, $38, $00
.db 0

; ---------------------------------------------------------------
; Element 11
; ---------------------------------------------------------------

Sodium:
.db "Na", 0
.db "Sodium", 0
.db $55, $1C, $BC, $B0		;"22.9898", 0
.db $11
;----Physical----;
.db $31, $CA, $00
.db $56, $1A, $00

;----Temperature----;
.db $6A, $40
.db $44, $89, $00
.db $51, $93, $40
.db $CB, $13, $40
.db $41, $56, $00

;----Atomic----;
.db $41, $C0
.db $41, $87, $00
.db $81, $46, $C0
.db $31, $C6, $00
.db $31, $88, $00
.db $11, 0

;---Miscellaneous---;
.db BCC
.db $47, $50
.db $31, $54, $00

; ---------------------------------------------------------------
; Element 12
; ---------------------------------------------------------------

Magnesium:
.db "Mg", 0
.db "Magnesium", 0
.db $57, $16, $38, $30		;"24.3050", 0
.db $21
;----Physical----;
.db $41, $A7, $00
.db $47, $00

;----Temperature----;
.db $C5, $50
.db $46, $B3, $00
.db $B1, $C8, $00
.db $45, $A1, $90
.db $41, $35, $00

;----Atomic----;
.db $41, $90
.db $41, $69, $00
.db $A1, $97, $90
.db $41, $64, $00
.db $30
.db $12, 0

;---Miscellaneous---;
.db HCP
.db $48, $90
.db $55, $17, $00

; ---------------------------------------------------------------
; Element 13
; ---------------------------------------------------------------

Aluminum:
.db "Al", 0
.db "Aluminum", 0
.db $59, $1C, $B4, $80		;"26.9815", 0
.db $B1
;----Physical----;
.db $51, $A0
.db $43, $00

;----Temperature----;
.db $C6, $61, $80
.db $5A, $73, $00
.db $43, $1A, $00
.db $5C, $31, $B0
.db $31, $C0

;----Atomic----;
.db $41, $76, $00
.db $41, $4B, $00
.db $81, $CB, $90
.db $41, $94, $00
.db $31, $78, $00		;srcs disagree
.db $13, 0

;---Miscellaneous---;
.db CCP
.db $56, $A0
.db $6A, $19, $9A, $90

; ---------------------------------------------------------------
; Element 14
; ---------------------------------------------------------------

Silicon:
.db "Si", 0
.db "Silicon", 0
.db $5B, $13, $B8, $80		;"28.0855", 0
.db $C1
;----Physical----;
.db $51, $66, $00
.db $45, $14, $00

;----Temperature----;
.db $49, $B6, $00
.db $59, $63, $00
.db $83, $15, $00
.db $68, $C0
.db $31, $A3, $00

;----Atomic----;
.db $41, $65, $00
.db $41, $44, $00
.db $B1, $48, $40
.db $41, $C0
.db $41, $6C, $00
.db $12, $14, $24, 0

;---Miscellaneous---;
.db 10					;'diamond structure'
.db $47, $C0
.db $41, $50, 5

; ---------------------------------------------------------------
; Element 15
; ---------------------------------------------------------------

Phosphorus:
.db "P", 0
.db "Phosphorus", 0
.db $63, $1C, $A6, $B0		;"30.9738", 0
.db $31
;----Physical----;
.db $41, $B5, $00
.db $4A, $00

;----Temperature----;
.db $64, $A1, $60
.db $88, $60
.db $31, $96, $00
.db $45, $17, $00
.db $31, $A9, $C0

;----Atomic----;
.db $41, $5B, $00
.db $41, $39, $00
.db $43, $17, $B9, $00
.db $51, $4C, $00
.db $31, $A8, $00
.db $13, $15, $23, 0

;---Miscellaneous---;
.db 11
.db $31, $57, $00
.db $41, $30, 11

; ---------------------------------------------------------------
; Element 16
; ---------------------------------------------------------------

Sulfur:
.db "S", 0
.db "Sulfur", 0
.db $65, $13, $98, $00		;"32.065", 0
.db $D1
;----Physical----;
.db $51, $3A, $00
.db $48, $18, $00

;----Temperature----;
.db $6C, $51, $50
.db $A4, $A1, $B5, $00
.db $41, $A6, $00
.db $43, $00
.db $31, $A4, $00

;----Atomic----;
.db $41, $5A, $00
.db $41, $35, $00
.db $43, $16, $90
.db $51, $8B, $00
.db $51, $3A, $00
.db $14, $16, $22, 0

;---Miscellaneous---;
.db COR
.db $31, $53, $80
.db $81, $30, 14

; ---------------------------------------------------------------
; Element 17
; ---------------------------------------------------------------

Chlorine:
.db "Cl", 0
.db "Chlorine", 0
.db $68, $17, $86, 0			;"35.453", 0
.db $53
;----Physical----;
.db $61, $54, $70
.db $4B, $1A, $00

;----Temperature----;
.db $4A, $51, $4A, $00
.db $56, $C1, $4B, $00
.db $61, $54, $00
.db $43, $15, $00
.db $31, $7B, $00

;----Atomic----;
.db $31, $CA, $00
.db $31, $CC, $00
.db $45, $1C, $9A, $00
.db $61, $49, $00
.db $61, $95, $00
.db $11, $15, $17, $21, 0

;---Miscellaneous---;
.db COR
.db $31, $33, $BC, $00
.db 0

; ---------------------------------------------------------------
; Element 18
; ---------------------------------------------------------------

Argon:
.db "Ar", 0
.db "Argon", 0
.db $6C, $1C, $7B, 0			;"39.948", 0
.db $63
;----Physical----;
.db $41, $AB, $70
.db $57, $15, $00

;----Temperature----;
.db $B6, $1C, $80
.db $BA, $17, $80
.db $41, $4B, $B0
.db $91, $83, $90
.db $31, $85, $00

;----Atomic----;
.db $31, $BB, $00
.db $31, $CB, $00
.db $48, $1A, $8C, $00
.db $30
.db $30
.db $80

;---Miscellaneous---;
.db FCC
.db $31, $34, $AA, $00
.db 0

; ---------------------------------------------------------------
; Element 19
; ---------------------------------------------------------------

Potassium:
.db "K", 0
.db "Potassium", 0
.db $6C, $13, $CB, $60		;"39.0983", 0
.db $11
;----Physical----;
.db $31, $B9, $00
.db $78, $16, $00

;----Temperature----;
.db $66, $91, $B0
.db $43, $66, $00
.db $51, $66, $00
.db $A9, $1C, $00
.db $31, $A8, $A0

;----Atomic----;
.db $51, $68, $00
.db $51, $36, $00
.db $71, $67, $40
.db $31, $B5, $00
.db $31, $83, $00
.db $11, 0

;---Miscellaneous---;
.db BCC
.db $43, $51, $80
.db $31, $49, $70		;srcs disagree

; ---------------------------------------------------------------
; Element 20
; ---------------------------------------------------------------

Calcium:
.db "Ca", 0
.db "Calcium", 0
.db $73, $13, $AB, 0			;"40.078", 0
.db $21
;----Physical----;
.db $41, $88, $00
.db $5C, $1C, $00

;----Temperature----;
.db $44, $45, $00
.db $4A, $8A, $00
.db $B1, $86, $00
.db $48, $71, $9A, $00
.db $31, $97, $A0

;----Atomic----;
.db $41, $CA, $00
.db $41, $A7, $00
.db $91, $44, $60
.db $40
.db $30
.db $12, 0

;---Miscellaneous---;
.db CCP
.db $53, $40
.db $31, $64, $60		;srcs disagree

; ---------------------------------------------------------------
; Element 21
; ---------------------------------------------------------------

Scandium:
.db "Sc", 0
.db "Scandium", 0
.db $77, $1C, $88, $C0		;"44.9559", 0
.db $A1
;----Physical----;
.db $51, $CC, $00
.db $48, $00

;----Temperature----;
.db $4B, $47, $00
.db $64, $3C, $00
.db $49, $14, $40
.db $63, $71, $B0
.db $31, $89, $B0

;----Atomic----;
.db $41, $95, $00
.db $41, $77, $00
.db $91, $87, $00
.db $41, $69, $00
.db $31, $4C, $00
.db $13, 0

;---Miscellaneous---;
.db HCP
.db $48, $1B, $00
.db $41, $80

; ---------------------------------------------------------------
; Element 22
; ---------------------------------------------------------------

Titanium:
.db "Ti", 0
.db "Titanium", 0
.db $7A, $1B, $9A, 0			;"47.867", 0
.db $A1
;----Physical----;
.db $71, $87, $00
.db $43, $19, $00

;----Temperature----;
.db $4C, $78, $00
.db $68, $93, $00
.db $4B, $19, $00
.db $75, $81, $50
.db $31, $85, $60

;----Atomic----;
.db $41, $78, $00
.db $41, $65, $00
.db $91, $B5, $00
.db $41, $87, $00
.db $31, $3B, $00
.db $12, $13, $14, 0

;---Miscellaneous---;
.db HCP
.db $54, $1C, $00
.db $51, $90

; ---------------------------------------------------------------
; Element 23
; ---------------------------------------------------------------

Vanadium:
.db "V", 0
.db "Vanadium", 0
.db $83, $1C, $74, $80		;"50.9415", 0
.db $A1
;----Physical----;
.db $91, $44, $00
.db $B1, $68, $00

;----Temperature----;
.db $54, $96, $00
.db $69, $83, $00
.db $53, $1B, $00
.db $77, $91, $A0
.db $31, $7B, $C0

;----Atomic----;
.db $41, $67, $00
.db $41, $55, $00
.db $91, $A7, $00
.db $41, $96, $00
.db $31, $86, $00
.db $12, $13, $14, $15, 0

;---Miscellaneous---;
.db BCC
.db $63, $1A, $00
.db $70

; ---------------------------------------------------------------
; Element 24
; ---------------------------------------------------------------

Chromium:
.db "Cr", 0
.db "Chromium", 0
.db $84, $1C, $C9, $40		;"51.9961", 0
.db $A1
;----Physical----;
.db $A1, $4C, $00
.db $A1, $56, $00

;----Temperature----;
.db $54, $63, $00
.db $5C, $78, $00
.db $53, $00
.db $66, $C1, $80
.db $31, $77, $C0

;----Atomic----;
.db $41, $60
.db $41, $4B, $00
.db $91, $A9, $90
.db $41, $99, $00
.db $31, $9A, $00
.db $12, $13, $16, 0

;---Miscellaneous---;
.db BCC
.db $C6, $1C, $00
.db $A1, $C0

; ---------------------------------------------------------------
; Element 25
; ---------------------------------------------------------------

Manganese:
.db "Mn", 0
.db "Manganese", 0
.db $87, $1C, $6B, $30		;"54.9380", 0
.db $A1
;----Physical----;
.db $A1, $77, $00
.db $A1, $6C, $00

;----Temperature----;
.db $48, $4B, $00
.db $56, $68, $00
.db $47, $19, $70
.db $54, $C1, $A7, $00
.db $31, $7B, $00

;----Atomic----;
.db $41, $68, $00
.db $41, $4A, $00
.db $A1, $76, $80
.db $41, $88, $00
.db $30
.db $12, $13, $14, $17, 0

;---Miscellaneous---;
.db BCC
.db $A1, $B4, $00
.db $31, $80

#include "Elements2.asm"
#include "Elements3.asm"
#include "Elements4.asm"