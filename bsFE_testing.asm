//******************************************************************************
// bsFE_testing.asm
// 
// Author:        hibber22
// Date Created:  22 Feb 2018
// Date Modified: 22 Feb 2018
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

// SNES Multiply register
constant SNES_MUL_OPERAND_A($004202)
constant SNES_MUL_OPERAND_B($004203)
constant SNES_DIV_DIVIDEND_L($004204)
constant SNES_DIV_DIVIDEND_H($004205)
constant SNES_DIV_DIVISOR($004206)
constant SNES_DIV_QUOTIENT_L($004214)
constant SNES_DIV_QUOTIENT_H($004215)
constant SNES_MUL_DIV_RESULT_L($004216)
constant SNES_MUL_DIV_RESULT_H($004217)

// Constants
constant FULL_VOLUME($FF)

constant BATTLE1_MUSIC($45)
constant THEME_LOOP($18)
constant THEME_ATTRACT($54)

constant ENDING_MUSIC($3F)
constant EPOCH_1999AD_MUSIC($50)

// =============
// = Variables =
// =============
// Game Variables
variable musicCommand($1E00)
variable musicRequested($1E01)
variable targetVolume($1E02)
variable soundBankRequested($1E10)

// My own variables
variable currentSong($7E1EE0)
variable fadeCount($7E1EE1)
variable fadeVolume($7E1EE2)
variable fadeStep($7E1EE4)
variable counter($7E1EE6)
variable frameCounter($7E1EE8)
variable inCombatHack($7E1EE9)

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

//Main code

//Simple code to test if it compiled
//Equivilant to almost rom address
//origin and rom address can also be used
//seek($9FFFF5)
//	nop

//
//Header file stuff
//

//Overwrite the value for limited starts in the header
//Allows for game to played more than 0 times.
	origin $007FD5
	db $00


//Inserting test binary files
//Ideally used to insert text
//origin $0A7EE0
//	insert "images/maintext.bin"

//Inserting test binary files
//Ideally used to insert text
origin $0A0000
	insert "images/sometext.bin"
	
origin $FFFF0
	nop
	

	
