arch snes.cpu

macro seek(variable offset) {
    origin ((offset & $7F0000) >> 1) | (offset & $7FFF)
	base offset
}

macro CheckMSUPresence($8000) {
	lda MSU_ID
	cmp.b #'S'
	bne {$8000}
}

// =============
// Hijack code
// =============

//Snes LoRom 5F10 coresponds to
//PC DF10
origin	$007FFC
db	0x10,0xDF

//Jump out of crowded bank zero
seek($DF10)
//9FE8B0 coresponds to rom address 0F:E8B0
//$A0:8010 coresponds to rom address 100010
db	0x42
nop
nop
jml $A08010




// Initiallisation is not needed as it's handled by the BIOS
// =============
// MSU-1 stuff
// =============

//New code in expanded rom space
origin	$100010

lda.b #$FF       // Load Audio Volume Byte
sta.w MSU_VOLUME // $2006: MSU1 Volume Register

ldx.w #$0000    // Load Track Number 0
stx.w MSU_TRACK // $2004: MSU1 Track Register
MSUWaitAudioBusy() // Wait For MSU1 Audio Busy Flag Status Bit To Clear

lda.b #%00000011  // Play & Repeat Sound (%000000RP R = Repeat On/Off, P = Play On/Off)
sta.w MSU_CONTROL // $2007: MSU1 Control Register

// =============
// Everything else
// =============


//Breakpoint opcde
db	0x42
nop
nop
nop
//Jump back to original start vector
jml $8091D8
	
	

//Insert SPC code
//In the middle of the free space
//This can be anywhere
origin	$7EF0
insert SPCROM, "AUDIO.spc"