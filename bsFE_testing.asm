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

// MSU memory map I/O
constant MSU_STATUS($002000)
constant MSU_ID($002002)
constant MSU_AUDIO_TRACK_LO($002004)
constant MSU_AUDIO_TRACK_HI($002005)
constant MSU_AUDIO_VOLUME($002006)
constant MSU_AUDIO_CONTROL($002007)

// SPC communication ports
constant SPC_COMM_0($2140)
constant SPC_COMM_1($2141)
constant SPC_COMM_2($2142)
constant SPC_COMM_3($2143)

// MSU_STATUS possible values
constant MSU_STATUS_TRACK_MISSING($8)
constant MSU_STATUS_AUDIO_PLAYING(%00010000)
constant MSU_STATUS_AUDIO_REPEAT(%00100000)
constant MSU_STATUS_AUDIO_BUSY($40)
constant MSU_STATUS_DATA_BUSY(%10000000)


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
	
