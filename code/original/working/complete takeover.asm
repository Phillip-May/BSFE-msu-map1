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

//Start of hijack code
//Snes LoRom 5F10 coresponds to
//PC DF10
origin	$007FFC
db	0x10,0xDF

//Prety much the bare minimum needed to get out of bank 0
seek($DF10)
//Jump out of crowded bank zero

SNES_INIT(SLOWROM) // Run SNES Initialisation Routine
SPCWaitBoot()
TransferBlockSPC(SPCROM, SPCRAM, SPCROM.size) // Load SPC File To SMP/DSP
SPCExecute(SPCRAM) // Execute SPC At $0200

db	0x42
nop

lda.b #$FF       // Load Audio Volume Byte
sta.w MSU_VOLUME // $2006: MSU1 Volume Register

ldx.w #$0000    // Load Track Number 0
stx.w MSU_TRACK // $2004: MSU1 Track Register
MSUWaitAudioBusy() // Wait For MSU1 Audio Busy Flag Status Bit To Clear

lda.b #%00000011  // Play & Repeat Sound (%000000RP R = Repeat On/Off, P = Play On/Off)
sta.w MSU_CONTROL // $2007: MSU1 Control Register

db	0x42
nop
lda $2000
nop
nop



jmp Loop10


Loop7:
sei


Loop10:
nop
sei



Loop5:
nop
nop
nop
jmp Loop5


jml $9FE8B0
origin	$FE8B0

//Non bank 0 initialization
// =============
//System stuff
// =============


// =============
// Everything else
// =============


//Breakpoint opcde
db	0x42
nop
nop
nop



lda.b #$FF       // Load Audio Volume Byte
sta.w MSU_VOLUME // $2006: MSU1 Volume Register

ldx.w #$0000    // Load Track Number 0
stx.w MSU_TRACK // $2004: MSU1 Track Register
MSUWaitAudioBusy() // Wait For MSU1 Audio Busy Flag Status Bit To Clear

lda.b #%00000011  // Play & Repeat Sound (%000000RP R = Repeat On/Off, P = Play On/Off)
sta.w MSU_CONTROL // $2007: MSU1 Control Register


nop
nop
nop
Loop2:
	nop
	nop
	sei
	nop
	nop
	//Breakpoint opcde
	//db	0x42
	nop
	nop
	nop
	nop
	nop
	Loop3:
	//Loop doing no op
	jmp	-
	jml $8091D8
	
	

//Insert SPC code
//In the middle of the free space
//This can be anywhere
origin	$7EF0
insert SPCROM, "AUDIO.spc"