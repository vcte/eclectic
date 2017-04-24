; ===============================================================
; Data
; ===============================================================

; ---------------------------------------------------------------
; Sprites
; ---------------------------------------------------------------

cursor:
.db %10010000
.db %01100000
.db %01100000
.db %10010000

title:
.incbmp "../Sprites/title2.png"

antisigma:
.incbmp "../Sprites/antisigma.png"

; ---------------------------------------------------------------
; Text
; ---------------------------------------------------------------

prompt:
.db "  Search: ", 0

tNA:
.db "N/A", 0

sphyphen: 
.db $06, '-', $06, 0

tElectronegDiff2:
.db "Electroneg. Diff: ", 0

tPredBond:
.db "Predicted bond: ", 0

tPerIonChar:
.db "% Ionic Character: ", 0

tPromptForm:
.db "Enter Formula:", 0

tPromptEle1:
.db "Enter 1st element's symbol:", 0

tPromptEle2:
.db "Enter 2nd element's symbol:", 0

tExportToList:
.db "Export to list: ", 0

ExportSuccessful:
.db "Export Successful", 0

MassStorePrompt:
.db $C1, "STO] - Store mass to Ans", 0

MassEditPrompt:
.db $C1, "DEL] - Edit formula", 0

MassBackPrompt:
.db $C1, "CLEAR] - Return to menu", 0

tGrapherYMax:
.db "Ymax = ", 0

tGrapherX:
.db "X: Atomic #", 0

tGrapherY:
.db "Y: ", 0

tGrapherPrompt:
.db "Go to element #: ", 0

tGoodbye:
.db "  Goodbye  ", 0

tQuitting:
.db "Quitting to MirageOS...", 0

; ---------------------------------------------------------------
; Arrays
; ---------------------------------------------------------------

array1:
.db "  Options  ", 0
.db "Periodic Table", 0
.db "Calculate...", 0
.db "Export", 0
.db "Grapher", 0
.db "Preferences", 0
.db "About", 0
.db 1
.db 5
.dw Main
.dw Calculate
.dw Export
.dw Grapher
.dw Preferences
.dw About

array2:
.db "  Calculators  ", 0
.db "Molar Mass", 0
.db "Electroneg. Diff.", 0
.db "Back", 0
.db 1
.db 2
.dw MolarMass
.dw ElectronegDiff
.dw features

array3:
.db "  Preferences  ", 0
;.db "Units", 0
;.db "Main datum", 0
.db "Graph style", 0
.db "Back", 0
.db 1
.db 1;3
;.dw Units
;.dw MainDatum
.dw GraphStyle
.dw features

array4:
.db "  Graph Styles  ", 0
.db "Dot", 0
.db "Line", 0
.db "Bar", 0
.db 1
.db 2
.dw GraphStyleDot
.dw GraphStyleLine
.dw GraphStyleBar

proparray:
.dw tWeight
.dw tDensity
.dw tVolume
.dw tMeltingPt
.dw tBoilingPt
.dw tHFusion
.dw tHVapor
.dw tSpecHeat
.dw tRadius
.dw tCovRadius
.dw tIonizationE
.dw tElectroneg
.dw tEAffinity
.dw 0

sizearray:				;size of properties list
.db 118
.db 96
.db 96
.db 103
.db 95
.db 92
.db 92
.db 94
.db 95
.db 92
.db 102
.db 102
.db 86

maxarray:				;max data value as int
.dw 296
.dw 23
.dw 70
.dw 3825
.dw 5870
.dw 51
.dw 737
.dw 15
.dw 3
.dw 3
.dw 25
.dw 4
.dw 4

; ---------------------------------------------------------------
; Keys
; ---------------------------------------------------------------

keyProp:
.db skSub \ .dw SelectPropW
.db skRecip \ .dw SelectPropD
.db sk6 \ .dw SelectPropV
.db skDiv \ .dw SelectPropM
.db skMatrix \ .dw SelectPropB
.db skCos \ .dw SelectPropF
.db skPower \ .dw SelectPropH
.db skLn \ .dw SelectPropS
.db skMath \ .dw SelectPropA
.db skPrgm \ .dw SelectPropC
.db skSquare \ .dw SelectPropI
.db skLog \ .dw SelectPropN
.db skSin \ .dw SelectPropE
.db 0

keyMain:
.db skUp \ .dw Up
.db skDown \ .dw down
.db skLeft \ .dw left
.db skRight \ .dw right
.db skEnter \ .dw enter
.db sk2nd \ .dw second
.db skDel \ .dw del
.db skClear \ .dw clear
.db skAlpha \ .dw alpha
.db skGraphVar \ .dw features
.db skAdd \ .dw Calculate
.db skYEqu \ .dw second1
.db skWindow \ .dw second2
.db skZoom \ .dw second3
.db skTrace \ .dw second4
.db skGraph \ .dw second5
.db skStat \ .dw Export
.db skVars \ .dw Grapher
.db skChs \ .dw togglecur
.db 0

keysecond:
.db skClear \ .dw secondret
.db sk2nd \ .dw secondret
.db skEnter \ .dw secondret
.db skRight \ .dw nextele
.db skLeft \ .dw prevele
.db skUp \ .dw upele
.db skDown \ .dw downele
.db skYEqu \ .dw second1
.db skWindow \ .dw second2
.db skZoom \ .dw second3
.db skTrace \ .dw second4
.db skGraph \ .dw second5
.db 0

keyElectro:
.db skStore \ .dw ElectronegDiffSto
.db skClear \ .dw features
.db skEnter \ .dw ElectronegDiff
.db sk2nd \ .dw ElectronegDiff
.db 0

keyElectro2:
.db skDel \ .dw ElectronegDiffDel
.db skLeft \ .dw ElectronegDiffDel
.db skClear \ .dw ElectronegDiffClr
.db skMode \ .dw Calculate
.db skEnter \ .dw ElectronegDiffEnter
.db 0

keyprops:
.db skUp \ .dw SelectPropUp
.db skDown \ .dw SelectPropDown
.db skRight \ .dw SelectPropRight
.db skLeft \ .dw SelectPropLeft
.db skEnter \ .dw SelectPropEnter
.db sk2nd \ .dw SelectPropEnter
.db skClear \ .dw features
.db 0

keylist:
.db skDel \ .dw PromptListDel
.db skClear \ .dw PromptListClr
.db skMode \ .dw PromptListQuit
.db sk2nd \ .dw PromptListInv
.db skAlpha \ .dw PromptListInv
.db skEnter \ .dw PromptListEnter
.db 0

keygrapher:
.db skRight \ .dw GrapherRight
.db skLeft \ .dw GrapherLeft
.db skClear \ .dw Grapher2
.db skYEqu \ .dw GrapherYEqu
.db skWindow \ .dw GrapherYMax
.db skZoom \ .dw GrapherZoom
.db skTrace \ .dw GrapherGoto
.db skGraph \ .dw GrapherDraw
.db 0

keyymax:
.db skDel \ .dw GrapherYMaxDel
.db skLeft \ .dw GrapherYMaxDel
.db skClear \ .dw GrapherYMaxClr
.db skMode \ .dw GrapherDraw
;.db skEnter \ .dw GrapherYMaxEnter			;NONFUNCTIONAL, cannot be trusted yet

.db skYEqu \ .dw GrapherYEqu
.db skTrace \ .dw GrapherGoto
.db skGraph \ .dw GrapherDraw
.db 0

keygoto:
.db skDel \ .dw GrapherGotoDel
.db skLeft \ .dw GrapherGotoDel
.db skClear \ .dw GrapherGotoClr
.db skMode \ .dw GrapherDraw
.db skEnter \ .dw GrapherGotoEnter	
.db skYEqu \ .dw GrapherYEqu
.db skWindow \ .dw GrapherYMax
.db skGraph \ .dw GrapherDraw
.db 0

keymass:
.db skDel \ .dw MolarMassDel
.db skLeft \ .dw MolarMassDel
.db skClear \ .dw MolarMassClr
.db skMode \ .dw Calculate
.db skAlpha \ .dw MolarMassAlpha
.db skEnter \ .dw MolarMassEnter
.db 0

keymass2:
.db skStore \ .dw MolarMassStoreAns
.db skDel \ .dw MolarMassEdit
.db skEnter \ .dw MolarMass
.db sk2nd \ .dw MolarMass
.db skClear \ .dw features
.db 0
	
; ---------------------------------------------------------------
; Property footers
; ---------------------------------------------------------------

generalprop:
.db "  Main  ", 0

physicalprop:
.db " Phys  ", 0

physical2prop:
.db " Tmp   ", 0

atomicprop:
.db " Atom", 0

miscprop:
.db " Misc.  ", 0

; ---------------------------------------------------------------
; Elemental states
; ---------------------------------------------------------------

tState:
.db "State at STP", 0

tSolid:
.db "Solid", 0

tLiquid:
.db "Liquid", 0

tGas:
.db "Gas", 0

tSynthetic:
.db "Synthetic", 0

; ---------------------------------------------------------------
; Categories
; ---------------------------------------------------------------

unknown:
.db "Unknown", 0

alkalimetals:
.db "Alkali metals", 0

aearthmetals:
.db "Alkaline earth metals", 0

pnictogens:
.db "Pnictogens", 0

chalcogens:
.db "Chalcogens", 0

halogens:
.db "Halogens", 0

noble:
.db "Noble Gases", 0

lanthanoids:
.db "Lanthanoids", 0

rarearth:
.db "Rare earth metals", 0

actinoids:
.db "Actinoids", 0

transitions:
.db "Transition metals", 0

ometals:
.db "Other metals", 0

metalloids:
.db "Metalloids", 0

onmetals:
.db "Other non-metals", 0

; ---------------------------------------------------------------
; Crystal Structures
; ---------------------------------------------------------------

tHCP:
.db "Hexagonal close-packed", 0

tCCP:
.db "Cubic close-packed", 0

tBCC:
.db "Body-centered cubic", 0

tBCT:
.db "Body-centered tetragonal", 0

tCOR:
.db "Orthorhombic", 0

tRH:
.db "Rhombohedral", 0

tCStruc:
.db "Hexagonal or Tetrahedral", 0

tCUB:
.db "Cubic", 0

tFCC:
.db "Face-centered cubic", 0

tDiamCub:
.db "Diamond cubic", 0

tSpecTetra:
.db "Special Tetrahedral", 0

tCrysHex:
.db "Crystal Hexagonal", 0

; ---------------------------------------------------------------
; Taglines
; ---------------------------------------------------------------

tGroup:
.db "Group", 0

tPeriod:
.db "Period", 0

tBlock:
.db "Block", 0

tWeight:
.db "Weight", 0

tDensity:
.db "Density", 0

tVolume:
.db "Volume", 0

tMeltingPt:
.db "Melting point", 0

tBoilingPt:
.db "Boiling point", 0

tHFusion:
.db "H of Fusion", 0

tHVapor:
.db "H of Vapor", 0

tSpecHeat:
.db "Spec. Heat", 0

tRadius:
.db "Atom. Radius", 0

tCovRadius:
.db "Cov. Radius", 0

tIonizationE:
.db "Ionization E", 0

tElectroneg:
.db "Electroneg", 0

tEAffinity:
.db "e- Affinity", 0

tOxidationSts:
.db "Oxidation Sts", 0

tThermalCond:
.db "Therm. Cond", 0

tElectCond:
.db "Elect. Cond", 0

; ---------------------------------------------------------------
; Units
; ---------------------------------------------------------------

tGperMol:
.db "g/mol", 0

tGperCm3:
.db "g/cm", $0E, 0

tCm3perMol:
.db "cm", $0E, "/mol", 0

tKelvin:
.db "K", 0

tAngstrom:
.db $8C, 0

tVolt:
.db "eV", 0

tkJMol:
.db "kJ/mol", 0

tJgK:
.db "J/g/K", 0

tWmK:
.db "W/m/K", 0

tScm:
.db "S/cm", 0

; ---------------------------------------------------------------
; Header taglines
; ---------------------------------------------------------------

tMolarMass:
.db "Molar Mass Calculator", 0

tElectronegDiff:
.db "Electroneg. Diff. Calculator", 0

tExportProp:
.db "Export property:", 0

tGraphProp:
.db "Graph property:", 0

tChooseData:
.db "Choose Data:", 0

; ---------------------------------------------------------------
; Polarity 
; ---------------------------------------------------------------

tNonpolar:
.db "Nonpolar", 0

tIsPolar:
.db "Polar", 0

tIonic:
.db "Ionic", 0

; ---------------------------------------------------------------
; Error msgs
; ---------------------------------------------------------------

error:
.db "Element not found", 0

ErrorIDK:
.db " not recognized", 0

ErrorInvalid:
.db "Invalid number", 0

ErrorListExists:
.db "Overwrite ", $DC, 0

ErrorListExists2:
.db "? (Y/N)", 0

ErrorNotEnoughRAM:
.db "Not enough memory", 0

ErrorCantUnarc:
.db "Can't unarc. settings AppVar", 0

ErrorMissingP:
.db "Missing ')'", 0

; ---------------------------------------------------------------
; About
; ---------------------------------------------------------------

tAbout:
.db "  About  ", 0

tDescription:
.db "Eclectic - Periodic Table", 0

tVersion:
.db "v 1.1", 0

tMe:
.db "Victor Ge", 0

tMail:
.db "victorge10@yahoo.com", 0

; ---------------------------------------------------------------
; Floating point
; ---------------------------------------------------------------

PolarThres:
.db $00, $7F, $40, $00, $00, $00, $00, $00, $00

NegPt25:
.db $80, $7F, $25, $00, $00, $00, $00, $00, $00

OneHundred:
.db $00, $82, $10, $00, $00, $00, $00, $00, $00

FPZero:
.db $00, $80, $00, $00, $00, $00, $00, $00, $00

FP98:
.db $00, $81, $98, $00, $00, $00, $00, $00, $00

FP256:
.db $00, $82, $25, $60, $00, $00, $00, $00, $00

GraphMax:
.db $00, $81, $55, $00, $00, $00, $00, $00, $00

; ---------------------------------------------------------------
; Variable Names
; ---------------------------------------------------------------

VECLECT:
.db AppVarObj, tV, tE, tC, tL, tE, tC, tT, 0

#include "Elements.asm"
#include "Flags.asm"
#include "Tables.asm"
#include "Fonts.asm"