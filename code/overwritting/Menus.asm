
//Macro to insert "Wpn LVL" 
//for Weapon level required
//Used for every staff in the game
macro Wpnleveldisp(variable offset) {
origin	offset
//Wpn
db	0x16,0x00,0x29,0x00,0x27,0x00
//Space
db	0xC2,0x00
//LV code
db	0x0B,0x00,0x15,0x00


//This is valid code
//origin	(offset+1000000)
//nop

}

//Macro to 


//Simple code to test if it compiled
//Equivilant to almost rom address
//origin and rom address can also be used
//Check this address manually in the compiled rom
seek($9FFFF5)
	nop
	db 0x50,0x50
	
	
//Navigation menu code
//I opted to change a few things as it has the same function as item from FE12
//and thus matches the translation used in FE12


//Insert "Wait" menu option
origin $05AC14
db  0x16
db  0x00
db  0x1A
db  0x00
db 	0x22
db 	0x00
db 	0x2D
db 	0x00

//Insert "Staff"
//Previously "Heal"
origin $05AC26
db	0x12,0x00,0x2D,0x00,0x1A,0x00,0x1F,0x00,0x1F,0x00

//Insert "Mount"
//
origin $05AC6E
db	0x0C,0x00,0x28,0x00,0x5B,0x00,0x27,0x00,0x2D,0x00

//Insert "Dismt"
//
origin $05AC80
db	0x03,0x00,0x22,0x00,0x2C,0x00,0x26,0x00,0x2D,0x00

//Insert "Weapn" menu code
//Previously called Weapn
origin $05AC92
db	0x16,0x00,0x1E,0x00,0x1A,0x00,0x29,0x00,0x27,0x00

//Insert "Item" menu code
//Previously called Item
//Item is correct
origin $05ACA4
db 0x08,0x00,0x2D,0x00,0x1E,0x00,0x26,0x00

//Insert "Spply" menu code
//Optimally should be convoy
origin $05ACB6
db	0x12,0x00,0x29,0x00,0x29,0x00,0x25,0x00,0x52,0x00


// =============
//Stat screen inserts
// =============
//
//2 letter calculated stat abreviations



//Insert At for attack
//Ideally called Mt for mite
origin $05ADA2
db	0x00,0x00,0x2D,0x00

//Insert Ac for acuracy
//Ideally called hit
origin $05ADAA
db	0x00,0x00,0x1C,0x00

//Insert Av for avoid
origin $05ADB2
db	0x00,0x00,0x5C,0x00

//Insert Cr for critical
origin $05ADBA
db	0x02,0x00,0x2B,0x00

//Insert As for attack speed
origin $05ADC2
db	0x00,0x00,0x2C,0x00

//Insert Ef for ?
origin $05ADCA
db	0x04,0x00,0x1F,0x00

//
//3 letter level based stats
//

//Insert "Str" for strenght
origin $05ADD2
db	0x12,0x00,0x2D,0x00,0x2B,0x00

//Insert "Skl" for skill
origin $05ADDC
db	0x12,0x00,0x24,0x00,0x25,0x00

//Insert "Spd" for speed
origin $05ADE6
db	0x12,0x00,0x29,0x00,0x1D,0x00

//Insert "Lck" for luck
origin $05ADF0
db	0x0B,0x00,0x1C,0x00,0x24,0x00

//Insert "Wlv" for weapon level
origin $05ADFA
db	0x16,0x00,0x25,0x00,0x5C,0x00

//Insert "Def" for defence
origin $05AE04
db	0x03,0x00,0x1E,0x00,0x1F,0x00

//Insert "Res" for resistance
origin $05AE0E
db	0x11,0x00,0x1E,0x00,0x2C,0x00


//
//Mend staff stat previews
//

//Insert "Wpn LVL"Weapon level required
//Need to this for every staff in the game
origin 	$05E886
Wpnleveldisp($05E8B2)
Wpnleveldisp($05E902)
Wpnleveldisp($05E94C)
Wpnleveldisp($05E9B2)
Wpnleveldisp($05EA02)
Wpnleveldisp($05EA5C)
Wpnleveldisp($05EABC)
Wpnleveldisp($05EB18)
Wpnleveldisp($05EB78)
Wpnleveldisp($05EC2C)
Wpnleveldisp($05EC88)
Wpnleveldisp($05ECF4)
Wpnleveldisp($05EBD2)
Wpnleveldisp($05ED38)
Wpnleveldisp($05ED90)
Wpnleveldisp($05EDEA)
Wpnleveldisp($05F136)



//
// Misc other menu edits
//

//Insert "Max HP"
//Changing Borderless font for
//boardered one to be consistent
origin $05AE18
//Max
db	0x0C,0x00,0x1A,0x00,0x51,0x00
//Space
db	0xC2,0x00
//HP
db	0x07,0x00,0x0F,0x00

//Insert "Move" for character movment display
origin $05AE28
db	0xC2,0x00,0xC2,0x00,0x0C,0x00,0x28,0x00,0x5C,0x00,0x1E,0x00


// =============
// Insert graphics
// =============

// Insert New symbol for EXP
// Old one simply said EX
// This was done directly on the graphics binary
// I shifted the sprite over one and fixed up the edge
// I went with "E" to match FE12


