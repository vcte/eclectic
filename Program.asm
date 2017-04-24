; ===============================================================
; ECLECTIC
; ===============================================================

; ---------------------------------------------------------------
; Glitches
; --------------------------------------------------------------

;trend grapher
	;ymax (glitch) (maybe 'bar' graph)
	;Corrupted prog
;Export: Alpha -> quit -> Enter -> ?

; ---------------------------------------------------------------
; Optimization
; ---------------------------------------------------------------

; ---------------------------------------------------------------
; Finalization
; ---------------------------------------------------------------

;data
	;IUPAC masses
;port

; ---------------------------------------------------------------
; More features
; ---------------------------------------------------------------

; Graph - conductivities
; Preferences
	;Units
	;Table main data
	;Highlight
; Set data

.NOLIST
#include "ti83plus.inc
.LIST

#include "Program.bin.inc"

.exportmode Assembly
.export

;--random macros--
#define Line(X1, Y1, X2, Y2) ld 	HL, Y1 + 256 * X1 \ ld DE, Y2 + 256 * X2 \ call fastlineb
#define CEASE		call ifastcopy \ b_call(_GetCSC) \ or A \ jr z, $ - 1 - 3			;halts execution, disps buffer and waits for keypress. Used for testing purposes.
#define STOP		di \ jp $ \ ei

;--data storage--
#define buf		AppBackUpScreen ;9872;
#define elex		buf			;x position of cursor
#define eley		buf + 1		;y position of cursor
#define size		buf + 2		;current size of input
#define temp		buf + 3		;temp storage (used by geta)
#define counter	buf + 4		;counts down blinker
#define curele	buf + 5		;current element number (set by geta & LR movement, among others)
#define curpage	buf + 6		;current element data page, 0 relative
#define curperiod	buf + 7		;current element period (set by GetPeriod)
#define curcolumn	buf + 8		;current element column (set by GetColumn)
#define menuopt	buf + 9		;menu option, 0 relative
#define maxopt	buf + 10		;maximum value of menuopt							;987C;
#define tempHL	buf + 11		;temp 2 byte storage (used by menu)
#define cursorA	buf + 13		;character for cursor
#define cursorwid	buf + 14		;width of above cursor
#define alphanum	buf + 15		;alpha-num status (0 = num, 1 = alpha, 2 = lower)
#define tempele	buf + 16		;temp storage of curele
#define block9	buf + 17		;9 byte block of RAM (used by BCDFP conversion)				;9883;
#define block18	buf + 26		;18 byte block of RAM (used during BCDFP conv.)				;988C;
#define block18A	buf + 44		;18 byte block of RAM (used during BCDFP conv.)				;989E;
#define sig1		buf + 62		;temp data used by BCDFP conversion					;98B0;
#define commapos	buf + 63		;temp data used by BCDFP conversion
#define lengthbcd	buf + 64		;temp data used by BCDFP conversion
#define ele1num	buf + 66		;temp data used by Electroneg. dif calc					;98B4;
#define menusel	buf + 67		;menu option, 0 relative
#define tokenpt	buf + 68		;storage of 2 byte token							;98B6;
#define numtoskip	buf + 70		;# data entries to skip (Export)
#define tempele	buf + 71		;temporarily stores curele
#define maxlist	buf + 72		;max # of elements in export list						;98BA;
#define GYMax		buf + 73		;9 byte storage for graph's ymax
#define LastPoint	buf + 82		;2 byte storage of x-y of last point on graph
#define xval		buf + 84		;current x value of graph							;98C6;
#define trace		buf + 85		;current x value of trace function
#define shift		buf + 86		;0 = graph at left, 1 = graph at right
#define traceE	buf + 87		;current element being traced
#define tempSP	buf + 100		;stores SP at prog start

#define buf2		SaveSScreen	;86EC;
#define buffer	buf2			;buffer for input of search box (max 14 bytes)	
#define conv		buf2 + 14		;output of integer to string conversion (max 4 bytes)
#define bcd		buf2 + 18		;output of BCD to string conversion (max 8 bytes so far)
#define input		buf2 + 26		;input of string to integer conversion (max 4 bytes)
#define tokenstr	buf2 + 30		;output of char string to list name conversion (max 9 bytes)
#define tempstr	buf2 + 39		;temporary string data (Molar Mass computation)				;874F;
#define tempstr2	buf2 + 70		;temporary string data (Error message)					;8782;
#define tempstr3	buf2 + 100		;temporary string data (centertext)
#define templine	buf2 + 150		;temp data for fastlineB

#define buf3		TempSwapArea 	;82A5;
#define vGraphStyle	buf3			;graph style: 0 = dot, 1 = line, 2 = bar
;#define IsNew		buf3 + 50	;whether appvar needs to be created (1) or not (0)
#define sizevar	2 + 1 + 1		;size of AppVar

;--CONSTANTS--
#define S_BLOCK	0
#define P_BLOCK	1
#define D_BLOCK	2
#define F_BLOCK	3

#define HCP		1
#define CCP		2
#define BCC		3
#define BCT		4
#define COR		5
#define RH		6
;#define Hex|Tetra	7
#define CUB		8
#define FCC		9
;#define Diamond cub	10
;#define spec tetra	11
;#define cryst hex	12

#ifdef TI83P
#define ifastcopy 		ionFastCopy		; override Mirage functions
#define isprite		ionPutSprite
#define Largespritehl	ionLargeSprite
#define igetpix		IonGetPixel
#endif

#ifdef TI83PI
#define ifastcopy 		ionFastCopy		; override Mirage functions
#define isprite		ionPutSprite
#define Largespritehl	ionLargeSprite
#define igetpix		IonGetPixel
#endif

Start:
	ret
	
	ld (tempSP), SP			;zStart patch
	
Settings:
	ld HL, VECLECT			; Settings (VECLECT : AppVar)
	rst rMov9ToOp1			; If (Exists(VECLECT) == true)				;first, try to find the appvar w/ save data
	b_call(_ChkFindSym)			; {
	jr c, SettingsNew			;	If (IsAppVar(VECLECT) == true)
						;	{
	and $1F				;		If (IsRAM(VECLECT) == true)			;if in RAM, then get data
	cp AppVarObj				;		{
	jr nz, SettingsNew0			;			If (IdentifierGood(VECLECT)) == true) ;check identifier
						;			{
	xor A					;				GetData(VECLECT)		;load data into 'settings' portion of memory
	or B					;				return 
	jr z, SettingsRAM			;			}
						;			Else
	push DE				;			{
	ld HL, sizevar			;				DelVar(VECLECT)		;if not equal, then create new settings and delete the appvar
	b_call(_EnoughMem)			;				NewSettings() 
	pop DE					;			}
	jr nc, SettingsEnough		;		Else If (EnoughMem(Appvar.size)) 		;check if enough mem is available for unarchiving appvar
						;		{
	ld HL, ErrorCantUnarc		;			Unarc(VECLECT)			;find data location after ArcUnarc modifies it
	call DispErr				;			GetData(VECLECT)
	jr SettingsNew			;		}
						;		Else
SettingsEnough:				;		{
	b_call(_Arc_Unarc)			;			DispErr(CantUnarc)			;throw error if unarchivable
	ld HL, VECLECT			;			NewSettings()
	rst rMov9ToOp1			;		}
	b_call(_ChkFindSym)			;	Else							;if not appvar, then create new settings and delete the var
SettingsRAM:					;	{
	inc DE					;		DelVar(VECLECT)
	inc DE					;		NewSettings()
	ld A, (DE)				;	}
	cp $13					; Else								;if not found, then create new settings
	jr nz, SettingsNew1			; {
						;	NewSettings()
	inc DE					; }
	ex DE, HL
	ld DE, buf3
	ld BC, sizevar - 3
	ldir
	
	jr Main
	
SettingsNew1:
	ld HL, VECLECT			;get params for DelVarArc
	rst rMov9ToOp1
	b_call(_FindSym)
SettingsNew0:
	b_call(_DelVarArc)
SettingsNew:
	xor A					;set graph style to dot
	ld (vGraphStyle), A
Main:	
	res textInverse, (IY + textFlags)
	set textWrite, (IY + sGrFlags)
	res fracDrawLFont, (IY + fontFlags) 
	res AppTextSave, (IY + AppFlags)
	res indicOnly, (IY + indicFlags)
	res indicRun, (IY + indicFlags)
	res lwrCaseActive, (IY + appLwrCaseFlag)
	res ShiftKeepAlph, (IY + ShiftFlags)
	res ShiftAlpha, (IY + ShiftFlags)
	res fmtExponent, (IY + fmtFlags)
	res fmtEng, (IY + fmtFlags) 
	res 0, (IY + Asm_Flag1)		;whether cursor is displayed (1) or not (0)
	res 1, (IY + Asm_Flag1)		;1 = enable input cursor, 0 = disable input cursor
	res 2, (IY + Asm_Flag2)		;1 = '2nd' mode, 0 = 'alpha' mode
		
	call init
		
	ld A, 3			;(3, 3)
	ld (elex), A	
	ld (eley), A
	
selectinit:
	xor A
	ld (size), A
selectinit2:
	ld A, $7C
	ld (cursorA), A
	ld A, 2
	ld (cursorwid), A
	
	call discur
selectele:
	call dispele
select:
	bit 1, (IY + Asm_Flag1)
	call z, drawcur
	call ifastcopy
	
	call GetCSCCur
	
	push AF
	bit 1, (IY + Asm_Flag1)
	call z, drawcur
	pop AF
select2:
	ld HL, keyMain
	call HandleKey
	
	bit ShiftAlpha, (IY + ShiftFlags)
	jr z, numerical
	
	ld C, A			;return to loop if at max chars
	ld A, (size)
	cp 13
	jp z, select
	
	ld A, (PenCol)		;if char can't fit on scrn,
	cp 96 - 10			;then return to loop
	jp nc, select
	ld A, C
	
	call GetChar
	jp c, select
	
	call SaveUpLow
	b_call(_VPutMap)
	call encur
	
	jp select
	
numerical:
	ld C, A
	ld A, (size)
	cp 3
	jp z, select
	ld A, C
	
	call GetNum
	jp c, select
	
	call SaveIn
	b_call(_VPutMap)
	call encur
	
	jp select
up:
	call discur
	call goup
	
	jp selectele
down:
	call discur
	call godown
	
	jp selectele	
left:
	call discur
	call GoLeft
	
	jp selectele
right:
	call discur
	call GoRight
	
	jp selectele
	
del:
	call Delete
	jp select
	
clear:
	ld A, (size)
	or A
	jr z, togglecuroff
	
	ld A, 37
	call ClearIn
	
	jp select
alpha:
	call encur
	ld A, (size)
	or A
	jp nz, select
	ld A, 2
	ld (PenCol), A
	bit ShiftAlpha, (IY + ShiftFlags)
	jr z, alpha1
	res ShiftAlpha, (IY + ShiftFlags)
	ld A, $23
	b_call(_VPutMap)
	ld A, 37
	ld (PenCol), A
	jp select
	
alpha1:
	set ShiftAlpha, (IY + ShiftFlags)
	ld A, $41
	b_call(_VPutMap)
	ld A, $20
	b_call(_VPutMap)
	ld A, 37
	ld (PenCol), A
	jp select
	
togglecur:
	bit 1, (IY + Asm_Flag1)
	jr z, togglecuren
togglecuroff:
	call discur
	jp select
	
togglecuren:
	call encur
	jp select
	
done:
	ld HL, tGoodbye
	call DrawTitle
	ld HL, 24 * 256 + 1
	ld (PenCol), HL
	ld HL, tQuitting
	b_call(_VPutS)
	call ifastcopy
	
	ld HL, VECLECT
	rst rMov9ToOp1
	b_call(_ChkFindSym)
	jr nc, doneexists			;if appvar found, then store data
	
	ld HL, sizevar			;else, create appvar
	b_call(_CreateAppVar)
doneexists:
	inc DE					;skip over size bytes
	inc DE
	ld A, $13				;set identifier
	ld (DE), A
	inc DE
	ld HL, buf3				;load save data
	ld BC, sizevar - 3
	ldir
	
	ld HL, (tempSP)
	ld SP, HL
	ret					;zStart patch
	;call quittoshell
	
enter:
	bit 1, (IY + Asm_Flag1)
	jp z, second
	
	ld A, (size)				;check if input string exists
	or A
	jp z, select
	
	xor A
	call SaveIn
	ld HL, size				;account for a glitch
	dec (HL)
	
	bit ShiftAlpha, (IY + ShiftFlags)	;string | numerical input
	jr nz, enteralp
	
	ld HL, buffer
	ld DE, input
	ld BC, 4
	ldir
	
	call strint
	jr c, enternfound
	ld A, B
	or A
	jr z, enternfound
	cp 119
	jr nc, enternfound
	jr enterfoundnum
		
enteralp:
	ld C, 0
	ld DE, buffer
	
	ld A, (size)				;atomic symbol | name
	cp 4
	jr c, entera
	
	inc C
entera:
	call SearchStr
	jr nc, enter1found
	
enternfound:
	ld HL, error
	call DispErr
	
	call init
	ld HL, buffer
	b_call(_VPutS)
	call curson
	
	jp select
	
enter1found:
	
enterfoundnum:
	call GetPos				;find element position in periodic table from number
	
enter0:
	call curoff
	
	jp selectinit2
	
second:
	;progress into page 1
	
#include "Pages.asm"
	
secondhandle:				;handles keypresses
	b_call(_GetCSC)
	or A
	jr z, secondhandle
	
	ld HL, keysecond
	call HandleKey
	
	jr secondhandle
	
nextele:
	call GoRight
	jr gotopage
	
prevele:
	call GoLeft
	jr gotopage
	
upele:
	call GoUp
	jr gotopage
	
downele:
	call GoDown
;	jr gotopage
	
gotopage:				;'subroutine' that goes to the page specified by (curpage)
	ld A, (curpage)
	sla A
	ld D, 0
	ld E, A
	ld HL, pages
	add HL, DE
	call LdHLInd
	jp (HL)
	
secondret:
	call init
	call discur
	call dispele
	
	xor A
	ld (size), A
	
	jp select
	
#include "../Options/Features.asm"
#include "../Routines/Routines.asm"
;#include "../Data/Data.asm"

.fill 267, 0 ; 58 + 192 + 1

.end