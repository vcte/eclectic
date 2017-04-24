; ===============================================================
; Tables
; ===============================================================

chartable:				;getcsc to alpha character, $0B relative, extends to $2F
.db 'W'
.db 'R'
.db 'M'
.db 'H'
.db 0
.db 0		;'?'
.db 0
.db 0
.db 'V'
.db 'Q'
.db 'L'
.db 'G'
.db 0
.db 0
.db 0
.db 'Z'
.db 'U'
.db 'P'
.db 'K'
.db 'F'
.db 'C'
.db 0
.db 0
.db 'Y'
.db 'T'
.db 'O'
.db 0
.db 'E'
.db 'B'
.db 'X'
.db 0
.db 'X'
.db 'S'
.db 'N'
.db 'I'
.db 'D'
.db 'A'

numtable:				;getcsc to numerical character, $12 relative, extends to $24
.db '3'
.db '6'
.db '9'
.db ')'  ;r paranthesis
.db 0
.db 0
.db 0
.db '.'  ;'.' point
.db '2'
.db '5'
.db '8'
.db '('  ; l paranthesis
.db 0
.db 0
.db 0
.db '0'
.db '1'
.db '4'
.db '7'

rowtable:				;row number to minimum atomic number
.db 1
.db 3
.db 11
.db 19
.db 37
.db 55
.db 87

menutable:				;menu option to displacement #
.db 0
.db 2
.db 3
.db 4
.db 5
.db 6
.db 7
.db 8
.db 9
.db 10
.db 11
.db 12
.db 13

blocktable:				;block # to subshell letter
.db 's', 'p', 'd', 'f'

ngshorttable:				;period # to noble gas shorthand beginning string
.db $C1, "He]", 0
.db $C1, "Ne]", 0
.db $C1, "Ar]", 0
.db $C1, "Kr]", 0
.db $C1, "Xe]", 0
.db $C1, "Rn]", 0


category:				;category keycode to string location
.dw Unknown
.dw alkalimetals
.dw aearthmetals
.dw pnictogens
.dw chalcogens
.dw halogens
.dw noble
.dw lanthanoids
.dw rarearth
.dw actinoids
.dw transitions
.dw ometals
.dw metalloids
.dw onmetals

crystaltab:				;structure keycode to string location
.dw Unknown
.dw tHCP
.dw tCCP
.dw tBCC
.dw tBCT
.dw tCOR
.dw tRH
.dw tCStruc
.dw tCUB
.dw tFCC
.dw tDiamCub
.dw tSpecTetra
.dw tCrysHex

states:				;state keycode to string location
.dw tSynthetic
.dw tSolid
.dw tLiquid
.dw tGas

pages:					;Jump table: page # to memory location of page
.dw second1
.dw second2
.dw second3
.dw second4
.dw second5

Elements:				;atomic number to element location in memory
.dw Hydrogen
.dw Helium
.dw Lithium
.dw Beryllium
.dw Boron
.dw Carbon
.dw Nitrogen
.dw Oxygen
.dw Fluorine
.dw Neon
.dw Sodium
.dw Magnesium
.dw Aluminum
.dw Silicon
.dw Phosphorus
.dw Sulfur
.dw Chlorine
.dw Argon
.dw Potassium
.dw Calcium
.dw Scandium
.dw Titanium
.dw Vanadium
.dw Chromium
.dw Manganese
.dw Iron
.dw Colbalt
.dw Nickel
.dw Copper
.dw Zinc
.dw Gallium
.dw Germanium
.dw Arsenic
.dw Selenium
.dw Bromine
.dw Krypton
.dw Rubidium
.dw Strontium
.dw Yttrium
.dw Zirconium
.dw Niobium
.dw Molybdenum
.dw Technetium
.dw Ruthenium
.dw Rhodium
.dw Palladium
.dw Silver
.dw Cadmium
.dw Indium
.dw Tin
.dw Antimony
.dw Tellurium
.dw Iodine
.dw Xenon
.dw Cesium
.dw Barium
.dw Lanthanum
.dw Cerium
.dw Praseodymium
.dw Neodymium
.dw Promethium
.dw Samarium
.dw Europium
.dw Gadolinium
.dw Terbium
.dw Dysprosium
.dw Holmium
.dw Erbium
.dw Thulium
.dw Ytterbium
.dw Lutetium
.dw Hafnium
.dw Tantalum
.dw Tungsten
.dw Rhenium
.dw Osmium
.dw Iridium
.dw Platinum
.dw Gold
.dw Mercury
.dw Thallium
.dw Lead
.dw Bismuth
.dw Polonium
.dw Astatine
.dw Radon
.dw Francium
.dw Radium
.dw Actinium
.dw Thorium
.dw Protactinium
.dw Uranium
.dw Neptunium
.dw Plutonium
.dw Americium
.dw Curium
.dw Berkelium
.dw Californium
.dw Einsteinium
.dw Fermium
.dw Mendelevium
.dw Nobelium
.dw Lawrencium
.dw Rutherfordium
.dw Dubnium
.dw Seaborgium
.dw Bohrium
.dw Hassium
.dw Meitnerium
.dw Darmstadtium
.dw Roentgenium
.dw Copernicium
.dw Ununtrium
.dw Ununquadium
.dw Ununpentium
.dw Ununhexium
.dw Ununseptium
.dw Ununoctium
Elements_End: