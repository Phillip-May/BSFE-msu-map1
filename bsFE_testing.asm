//******************************************************************************
// bsFE_testing.asm
// 
// Author:        hibber22
// Date Created:  22 Feb 2018
// Date Modified: 26 Feb 2018
// Date Modified: 08 Mar 2018
// Assembler:     bass v14
//
// Intended to be a full and commented reimpletation of joesteve1914's code
// Afterwords it will fix potential miscelaneous other issues in the hack 
//
// This patch is intended to be applied directly by bass.  Patch should be
// applied to an unheadered ROM.  Requires expanded ROM, but bass can expand the
// ROM if EXPAND_ROM is defined below.
//
// Unheadered ROM MD5: 608C22B8FF930C62DC2DE54BCD6EBA72
//
// Usage: bass -o [romfile] alttp_msu.asm
//
// See README.md for more information
//
//******************************************************************************

arch snes.cpu

include "LIB/SNES.INC"        // Include SNES Definitions
include "LIB/SNES_SPC700.INC" // Include SPC700 Definitions & Macros
include "LIB/SNES_MSU1.INC"   // Include MSU1 Definitions & Macros


// =============
// = Variables =
// =============
// Game Variables

// My own variables

// **********
// * Macros *
// **********
// seek converts SNES LoROM address to physical ROM address
macro seek(variable offset) {
    origin ((offset & $7F0000) >> 1) | (offset & $7FFF)
	base offset
}

macro CheckMSUPresence(labelToJump) {
	lda MSU_ID
	cmp.b #'S'
	bne {labelToJump}
}


macro WaitMulResult() {
	nop
	nop
	nop
	nop
}

macro WaitDivResult() {
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
}

// =============
// Msu-1 stuff
// =============
include "code\original\MSU-1Audio.asm"


// =============
//Text insertion code
// =============

//Menu overwritting code
include "code/overwritting/Menus.asm"	


// =============
//Header file changes
// =============

include "misc/header.asm"


// =============
//Image file stuff
// =============
	
//Inserting image bitmap binaries
//origin $0A7EE0
//	insert "images/maintext.bin"

//Code to overwrite the font for the menus
origin $0A0000
	insert "images/mainmenufont.bin"
	
// =============
// Miscelaneous
// =============	

//Code to make sure programmed fully compiled
//Check this address manually in the compiled rom
origin $FFFF0
	nop
	
