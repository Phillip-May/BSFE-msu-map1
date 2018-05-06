arch snes.cpu
constant originalSTARTvector($8091D8)
constant originalNMIvector($809111)
constant originalIRQvector($8090F1)

//Words input need to be formated as little endian
endian lsb
constant MSU_STATUS($2000)
constant MSU_READ($2001)
constant MSU_ID($2002)

constant MSU_SEEK_OFFSET($2000)
constant MSU_SEEK_BANK($2002)
constant MSU_TRACK($2004)
constant MSU_VOLUME($2006)
constant MSU_CONTROL($2007)


//Convert snes address to pc file address
macro seekMSU(variable offset) {
	print "seeking address: "
	print offset,"\n"
	
	origin ((offset & $7F0000) >> 1) | (offset & $7FFF)
	base offset
	print "Seek result address: "
	print origin(),"\n"
	print "seek result base: "
	print base(),"\n"
	print "\n"
}

macro CheckMSUPresence($8000) {
	lda MSU_ID
	cmp.b #'S'
	bne {$8000}
}

// =============
// Hijack code
// =============
//This overwrites the original reset vector
//Snes LoRom 5F10 coresponds to
//PC DF10
origin	$007FFC
db	0x10,0xDF

//THis is a conveniently empty bit of bank 0
//Jump out of crowded bank zero
seekMSU($DF10)
db	0x42, 0x00
nop
jml MSU1STUFF




// SPC initiallisation is not needed as it's handled by the BIOS
// =============
// MSU-1 stuff
// =============
seekMSU($A08000)
MSU1STUFF:
//New code in expanded rom space


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
db	0x42, 0x00
nop
//Jump back to original start vector
jml originalSTARTvector









