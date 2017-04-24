; ===============================================================
; HEADERS.ASM - Benjamin Ryves 2005-2006
; ---------------------------------------------------------------
; This template file is designed for use with Latenite. It 
; requires the Brass Z80 assembler.
;
; It takes two environment variables; shell and platform. It also
; assumes the following directory structure:
;
; .\Program.asm          <- Main program source code
; .\Includes\Headers.asm <- This file
; .\Includes\?.inc       <- Various include files...
; .\Includes\?.lbl       <- ...and label files.
;
; You do NOT assemble Program.asm directly - you must assemble
; this file, which will in turn assemble Program.asm
;
; Always use bcall(_xxxx) and variants to call TIOS routines.
; This will get expanded to the more usual call _xxxx for non-83+
; calculators.
;
; This template assumes all labels are local and that you are
; using nestable modules. The entry point for your program is
; Main in the Program modules (found in Program.asm).
;
; All TIOS and shell equates are in the global scope. If you need
; to do something platform or shell specific, you can test the
; current settings via the global labels Shell and Platform. (See
; the below code for many examples).
; ===============================================================

; ===============================================================
; General assembler directives
; ===============================================================

.nestmodules		; Allow nestable modules

; ===============================================================
; Set the variable name for the calculator binary 
; ===============================================================

.variablename [%PROJECT_BINARY%]

; ===============================================================
; Define shell and platform from environment variables
; (passed in by the various build scripts).
; ===============================================================

.global

	None		= 0	; No shell	All
	Ion		= 1	; Ion		83, 83+
	MirageOS	= 2	; MirageOS	83+
	Venus		= 3	; Venus		83
	
	TI8X		= 1	; TI-83 Plus
	TI83		= 2	; TI-83
	
	Shell		= [%SHELL%]
	Platform	= [%PLATFORM%]

; ===============================================================
; Set up the platform-specific settings: origins, include files,
; BCALL macros &c. Also includes shell includes for those which
; require them.
; ===============================================================

	.if Platform == TI8X
		.inclabels "ti8x.lbl"
		.org $9D93
		.db t2ByteTok, tAsmCmp ;$BB,$6D ; AsmPrgm
		.define bcall(label) rst rBR_CALL \ .dw label
		.define	bcallz(label) jr nz,$+5 \ rst rBR_CALL \ .dw label
		.define	bcallnz(label) jr z,$+5 \ rst rBR_CALL \ .dw label
		.define	bcallc(label) jr nc,$+5 \ rst rBR_CALL \ .dw label
		.define	bcallnc(label) jr c,$+5	\ rst rBR_CALL \ .dw label
		.define bjump(label) call 50h \ .dw label	
		.define	bjumpz(label) jr nz,$+7 \ call 50h \ .dw label
		.define	bjumpnz(label) jr z,$+7 \ call 50h \ .dw label
		.define	bjumpc(label) jr nc,$+7 \ call 50h \ .dw label
		.define	bjumpnc(label) jr c,$+7	\ call 50h \ .dw label
		.binarymode TI8X
		.if Shell == Ion
			.include "ion8x.inc"
			ret \ jr nc, Start			; jump to beginning of ION program
		.elseif Shell == Mirageos
			.include "mirage.inc"
			ret \ .db 1
			.incbmp "../Resources/15x15 Icon.gif", width = 15, height = 15
		.elseif Shell == None
			; Nothing special required
		.else
			.fail "Invalid TI-83 Plus shell.\n";
		.endif
		.varloc saveSScreen, 768
	.elseif Platform == TI83
		; TI-83
		.inclabels "ti83.lbl"
		.org Shell == Venus ? $9329 : $9327
		.define bcall(label) call label
		.define	bcallz(label) call z,label
		.define	bcallnz(label) call nz,label
		.define	bcallc(label) call c,label
		.define	bcallnc(label) call nc,label	
		.define bjump(label) jp label
		.binarymode TI83
		.if Shell == Ion
			.include "ion83.inc"
			ret \ jr nc,Program.Main
		.elseif Shell == None
			.unsquish
		.elseif Shell == Venus
			.include "venus.inc"
			.db $E7,"9_[V?",0
			jr nc,Program.main
		.else
			.fail "Invalid TI-83 shell.\n";
		.endif
		.varloc saveSScreen, 768
	.else
		; Invalid platform
		.fail "Invalid platform selection.\n"
		.end
	.endif
.endglobal

; ===============================================================
; Set up TIOS ASCII-mapping
; ===============================================================

.include "ASCII Mapping.asm"

; ===============================================================
; Description field
; ===============================================================

.if Shell != None
	.asc "Periodic Table", 0
.endif

; ===============================================================
; Defines for code that requires them
; ===============================================================

.if Platform == TI8X
	.if Shell == None
		.define TI83P
	.elseif Shell == Ion
		.define TI83PI
	.elseif Shell == MirageOS
		.define TI83PM
	.endif
.elseif Platform == TI83
	.if Shell == None
		.define TI83
	.elseif Shell == Ion
		.define TI83I
	.endif
.endif

; ===============================================================
; The main source code
; ===============================================================

.local	; Force labels to be local to their modules
.include "../Program.asm"
.endlocal

; ===============================================================
; Any footers required
; ===============================================================

.if Platform == TI83 && Shell == None
	.squish
	.db tEnter, tEnd
	.db tEnter, "0000"
	.db tEnter, tEnd
.endif

; ===============================================================
; Definitions for TI-OS variables
; ===============================================================

.include "TIOS Variables.asm"