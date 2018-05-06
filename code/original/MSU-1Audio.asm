arch snes.cpu
constant originalSTARTvector($8091D8)
constant originalNMIvector($809111)
constant originalIRQvector($8090F1)

//Words input need to be formated as little endian
endian lsb

constant MSU_SEEK_OFFSET($2000)
constant MSU_SEEK_BANK($2002)
//constant MSU_TRACK($2004)
//constant MSU_VOLUME($2006)
//constant MSU_CONTROL($2007)

//Variables
constant dispcnt($7E0000)

constant stddur($7E0001)
constant altdur($7E0002)
constant altcnt($7E0003)
constant curdur($7E0004)
constant curcnt($7E0005)
constant numframes($7E0006)
constant numframes2($7E0007)
constant firstframe($7E0008)
constant charptr($7E0009)

constant dma_a_bank($7E000A)
constant dma_a_addr($7E000B)
constant dma_b_reg($7E000D)
constant dma_len($7E000E)
constant dma_mode($7E0010)

constant isr_flag($7E0011)

constant videointerupt($125010)

//Sram variable



macro DMA0M(mode, len, a_bank, a_addr, b_reg) {
	lda {mode}
	sta dma_mode
	ldx.w {a_addr}
	lda.b {a_bank}
	stx dma_a_addr
	sta dma_a_bank
	ldx {len}
	stx dma_len
	lda {b_reg}
	sta dma_b_reg
	jsr dma0
}


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

//Check if msu1 is connected
macro CheckMSUPresence($8000) {
	lda MSU_ID
	cmp.b #'S'
	bne {$8000}
}

// =============
// Header hacking
// =============
//This overwrites the original reset vector
//Snes LoRom 5F10 coresponds to
//PC DF10
origin	$007FFC
//db	0x10,0xDF
dw Reset_hacked

origin	$007FEA
//db	0x10,0xDF
//dw NMI_16bit_hacked

origin	$007FEE
//db	0x10,0xDF
dw IRQ_16bit_hacked


// =============
// Hijack code
// =============
//THis is a conveniently empty bit of bank 0
//Jump out of crowded bank zero
seekMSU($DF10)
Reset_hacked:
jml MSU1STUFF

NMI_16bit_hacked:
	db 0x42,0x00
	jml NMI_16bit_REAL;
    //rti

IRQ_16bit_hacked:
	db 0x42,0x00
	jml IRQ_16bit_REAL

INTERUPT_BANK0_RETURN:
	rti


// SPC initiallisation is not needed as it's handled by the BIOS
// =============
// MSU-1 stuff
// =============
seekMSU($A08000)
MSU1STUFF:
	//New code in expanded rom space
	realstart:	
	php
	sei
	clc
	xce
	sep #$20
	stz $4200 // inhibit IRQs
	
	lda #0x00
	sta videointerupt
	
	
	jsr waitblank
	jsr killdma
	jsr waitblank
	jsr waitblank
	jsr waitblank
	jsr waitblank
	//SNES_INIT(FASTROM)
	jsr snes_init
	//SPC initialisation is not needed as the bsx bios handles for me.
	//In standalone the spc initialisation routine needs to be called.
	lda #$01
	sta $420d //fast cpu
	jml (fastspeed+0x800000)
	fastspeed:
	//I somehow missed the setup_gfx code the first time
	jsr setup_gfx
	//End of graphics code
	//Colour test code
	sep #$20
	rep #$10
	stz $2130
	//Colour test end
	jsr screen_init
	jsr setup_hdma	
	sep #$20
	-;
	jsr msu1init
	cli
	jsr waitblank
	jsr msu1loop
	sei

	lda #0xFF
	sta videointerupt

	//jml Customcodeexit
	Customcodeexit:
	//Jump back to original start vector after video loop
	//Probably disable fast cpu as well
	//Set flag to disable video interupt routine and return to normal
	//Any other context restoring that may be needed
	plp
jml originalSTARTvector

// =============
// Subroutines for video
// =============
//Around 1b00 in ram seems unused by the game
//So I used it for the video mode toggle
//NMI seems completly unused in the video code.
//Leaving the original vector broke nothing.

NMI_16bit_REAL:
//Not actually needed.

IRQ_16bit_REAL:
	php
	pha
	sep #$20	
	
	lda #0xFF
	cmp videointerupt
	beq irq_hackednotneeded
		
    lda #$01
    sta isr_flag
    lda $4211  //Acknowledge irq
	pla
	plp
	rti
	
	irq_hackednotneeded:
	pla
	plp	
	jml originalIRQvector
	
	
spc_upload:
	rep #$20
	sep #$10

	lda #$bbaa	// wait for IPL bootup
-;
	cmp $2140
	bne -

	// IPL portmap outside transfer state:
	// $2141   = command (transfer / run)
	// $2142-3 = target address
	// $2140   = trigger
	lda.w spcaddr
	sta $2142
	ldx #$01	// transfer
	stx $2141
	ldx #$cc
	stx $2140
	// wait for echo
-;
	cpx $2140
	bne -

	// IPL portmap inside transfer state:
	// $2140 = sequence number
	// $2141 = payload
	// init counters
	sep #$20
	ldx #$00	// sequence counter
	lda spclen
	tay		// countdown
spc_loop:
	lda.w spccode,x	// fill data byte
	sta $2141	// write data...
	stx $2140	// ...and write sequence counter
-;
	cpx $2140	// wait for echo from IPL
	bne -
	inx		// increment sequence counter...
	dey
	bne spc_loop	// if not, do it again

spc_end:
	rep #$20
	lda spcexec
	sta $2142	// set exec address
	stz $2141	// command: run
	ldx $2140
	inx
	inx
	stx $2140	// send sequence end / execute
-;
	cpx $2140	// wait for last echo
	bne -

	sep #$20
	rep #$10

	rts		// and done!

snes_init:
	sep #$20		//8-bit accumulator
	rep #$10		//16-bit index
	stz $4200		;
	lda #$ff
	sta $4201		;
	stz $4202		;
	stz $4203		;
	stz $4204		;
	stz $4205		;
	stz $4206		;
	stz $4207		;
	stz $4208		;
	stz $4209		;
	stz $420a		;
	stz $420d		;
	lda #$8f
	sta $2100		//INIDISP: force blank
	stz $2101		;
	stz $2102		;
	stz $2103		;
//	stz $2104		// (OAM Data?!)
//	stz $2104		// (OAM Data?!)
	stz $2105		;
	stz $2106		;
	stz $2107		;
	stz $2108		;
	stz $2109		;
	stz $210a		;
	stz $210b		;
	stz $210c		;
	stz $210d		;
	stz $210d		;
	stz $210e		;
	stz $210e		;
	stz $210f		;
	stz $210f		;
	stz $2110		;
	stz $2110		;
	stz $2111		;
	stz $2111		;
	stz $2112		;
	stz $2112		;
	stz $2113		;
	stz $2113		;
	stz $2114		;
	stz $2114		;
	lda #$80		//VRAM addr increment after high byte
	sta $2115		;
	stz $2116		;
	stz $2117		;
//	stz $2118		;(VRAM Data?!)
//	stz $2119		;(VRAM Data?!)
	stz $211a		;
	stz $211b		;
	lda #$01
	sta $211b		;
	stz $211c		;
	stz $211c		;
	stz $211d		;
	stz $211d		;
	stz $211e		;
	sta $211e		;
	stz $211f		;
	stz $211f		;
	stz $2120		;
	stz $2120		;
	stz $2121		;
//	stz $2122		; (CG Data?!)
//	stz $2122		; (CG Data?!)
	stz $2123		;
	stz $2124		;
	stz $2125		;
	stz $2126		;
	stz $2127		;
	stz $2128		;
	stz $2129		;
	stz $212a		;
	stz $212b		;
	stz $212c		;
	stz $212d		;
	stz $212e		;
	stz $212f		;
	stz $2130		;
	stz $2131		;
	lda #$e0		//clear fixed color
	sta $2132		;
	stz $2133		;

	rts
	
dma0:
	rep #$10
	sep #$20
	lda dma_mode
	sta $4300
	lda dma_b_reg
	sta $4301
	lda dma_a_bank
	ldx dma_a_addr
	stx $4302
	sta $4304
	ldx dma_len
	stx $4305
	lda #$01
	sta $420b
	rts
	

	
setup_gfx:
	sep #$20
	rep #$10

//clear VRAM
	ldx #$0000
	stx $2116
	DMA0M(#$09, #$0000, #(zero >> 16), #(zero), #$18)

//copy low tilemap
	ldx #$3F80 // == 8-bit address $7F00
	stx $2116
	DMA0M(#$01, #$0100, #(tilemap >> 16), #(tilemap), #$18)

//copy high tilemap
	ldx #$7F80 // == 8-bit address $FF00
	stx $2116
	DMA0M(#$01, #$0020, #(tilemap2 >> 16), #(tilemap2), #$18)

//clear OAM tables
	ldx #$0000
	stx $2102
	DMA0M(#$08, #$0220, #(zero >> 16), #(zero), #$04)

	rts


msu1init:
	sep #$20
	rep #$10
	ldx #$0000
	stx MSU_SEEK_OFFSET
	stx MSU_SEEK_BANK
-;	
	bit MSU_STATUS
	bmi -

	lda #$ff
	sta MSU_VOLUME

	stx MSU_TRACK
-;
	bit MSU_STATUS
	bvs -
	ldx #$0000
	stx $2116
	
	lda #$04
	sta charptr
	sta $210b

	// prepare DMA
	ldx #$2001
	stx $4302
	stz $4304

	lda #$01
	sta firstframe

	rts  

waitblank:
-;	
	lda $4212
	and #$80
	bne -
-;	
	lda $4212
	and #$80
	beq -
	rts
	
killdma:
//  stz $420b
	stz $420c
	rts
	
screen_init:
	sep #$20
	rep #$10
	lda #$13		//mode 3, 16x16
	sta $2105
	lda #$3C		//Tilemap addr 0x7800, 32x32
	sta $2107		//for BG1
	lda #$00		//chr base addr:
	sta $210b		//BG1=0x0000, BG2=0x0000
	lda #$01		//enable BG1
	sta $212c		//BG Main
	lda #$01		//enable none
	sta $212d		//BG Sub
	lda #$20		//Window 1 for color
	sta $2125		//Color window
//	lda #$02		//Window 1 for BG1
//	sta $2123
	lda #$10		//cut off 16 pixels left
	sta $2126
	lda #$ef		//cut off 16 pixels right
	sta $2127
	lda #$40		//enable clipping outside window
	sta $2130
//	lda #$01		//enable clipping for BG1
//	sta $212e
	stz $2121		//reset CGRAM ptr
//	lda #$0f
//	sta $2100		//screen on, full brightness
	rts

setup_hdma:
	sep #$20
	rep #$10
//	stz $420b
//	stz $420c

	//Around 3F0 in original rom
	lda #$00		//A to B// direct// 1x single reg A900
	sta $4310		//ch. 1 for tilemap switch 8D1043?
	lda #$07		//2107 = BG1 Tilemap Address
	sta $4311
	//In the original this was ROM $0234
	//Disasembly showed lda 0xC0 ldy 0x0261
	lda.b #(hdma_tilemap >> 16)
	ldy.w #(hdma_tilemap)
	sty $4312
	sta $4314
	
	//Starts at 0x03F9
	lda #$03		//A to B// direct// 2x 2x single reg
	sta $4320		//ch. 2 for scroll
	lda #$0d		//210d = BG1HOFS
	sta $4321
	//Hex disasembly A9 C0 A0 33 02; LDA C0 ldy $0233
	//Bank is loaded into accumulator
	//Address loaded into y register
	lda.b #(hdma_scroll >> 16)
	ldy.w #(hdma_scroll)
	sty $4322
	sta $4324

// BLANKING CHANNEL MUST NOT BE A DIRECT NEIGHBOUR OF THE GPDMA CHANNEL.
	lda #$00		//A to B// direct// 1x single reg
	sta $4330		//ch. 3 for blanking
	lda #$00		//2100 = inidisp
	sta $4331
	lda.b #(hdma_blank >> 16)
	ldy.w #(hdma_blank)
	sty $4332
	sta $4334

	jsr waitblank

	ldx #185		//Set IRQ trigger to line 185
	stx $4209		//
	lda #$0e
	sta $420c
	rts

	

msu1loop:
	sep #$20
	rep #$10
	stz dispcnt
	lda $2001
	sta numframes
	lda $2001
	sta numframes2
	lda $2001
	sta curdur
	sta stddur
	lda $2001
	sta altdur
	lda $2001
	sta altcnt
	lda #$01
	sta curcnt
	ldx numframes
	dex
	lda #$21                //V-Count IRQ + Auto Joypad Read
	sta $4200
msu1loop2:
	lda isr_flag
	beq msu1loop2
	stz isr_flag
	lda dispcnt	//load field count
	cmp #$02	//if >= 2 don't draw anymore
	bpl +
	//load half picture
	lda #$18
	sta $4301
	lda #$09
	sta $4300
	ldy #$3f80		//ldy #16256
	sty $4305
	lda #$01
	sta $420b
+;
	inc dispcnt	//inc field count
	lda dispcnt	//and compare with current duration
	cmp curdur	//if not reached...
	bne msu1loop2   //...wait another field

	lda firstframe	//first frame ready for display?
	beq +

	lda #$01	//then start audio
	sta MSU_CONTROL
	stz firstframe

+;
	lda curcnt	//
	cmp altcnt	//compare with alternation frequency
	bne +		//if reached...
	stz curcnt	//...reset current frame count
	lda altdur	//use alternate duration for next frame
	bra skip
+;	
	lda stddur	//else use normal duration
	inc curcnt	//and inc current frame count
skip:
	sta curdur	//store in current duration
	stz dispcnt	//reset field counter
	dex		//countdown total frames
	beq msu1stop	//stop if end of movie

	//load palette
	stz $2121
	lda #$22
	sta $4301
	lda #$08
	sta $4300
	ldy #512
	sty $4305
	lda #$01
	sta $420b
	lda charptr
	bne ptr2
ptr1:
	lda #$04
	sta $210b
	sta charptr
	ldy #$0000
	sty $2116
	jmp msu1loop2
ptr2:
	stz $210b
	stz charptr
	ldy #$4000
	sty $2116
	jmp msu1loop2

msu1stop:
//	lda #$80
//	sta $2100
//	stz $420c
	stz MSU_CONTROL
	rts


seek($A08600);

//Program data
zero:

dw 0x0000

hdma_blank:
db 40
db 0x8f		//byt $8f
db 0x7F		//byt 127
db 0x0F		//byt $0f
db 0x11		//byt 17
db 0x0F		//byt $0f
db 0x01		//byt 1
db 0x8F		//byt $8f
db 0x00		//byt 0



//Snipet from wla code analysis
//.word 152+255
//255+152=407=0x197 but its a word so 0x97 01
//start around address 0x0234

hdma_scroll:
db 56
dw 0		//word 0
dw 0x0197	//word 152+255
db 0x10		//byt 16
dw 0x0100	//word 256
dw 0x0187	//word 136+255
db 0x10		//byt 16
dw 0x0000	//word 0
dw 0x0187	//word 136+255
db 0x10		//byt 16
dw 0x0100	//word 256
dw 0x0177	//word 120+255
db 0x10		//byt 16
dw 0x0000	//word 0
dw 0x0177	//word 120+255
db 0x10		//byt 16
dw 0x0100	//word 256
dw 0x0167	//word 104+255
db 0x10		//byt 16
dw 0x0000	//word 0
dw 0x0167	//word 104+255
db 0x10		//byt 16
dw 0x0100	//word 256
dw 0x0157	//word 88+255
//last row -> new tilemap
db 0x10		//byt 16
dw 0x0000	//word 0
dw 0x0117	//word 24+255
db 0x00

hdma_tilemap:
db 40
db 0xbc
db 127
db 0xbc
db 0x01
db 0xbc
db 0x01
db 0xfc
db 0x00

tilemap:

dw 0x0000, 0x0000, 0x0002, 0x0004, 0x0006, 0x0008, 0x000a, 0x000c
dw 0x000e, 0x0020, 0x0022, 0x0024, 0x0026, 0x0028, 0x002a, 0x0000

dw 0x0000, 0x002c, 0x002e, 0x0040, 0x0042, 0x0044, 0x0046, 0x0048
dw 0x004a, 0x004c, 0x004e, 0x0060, 0x0062, 0x0064, 0x0066, 0x0000

dw 0x0000, 0x0068, 0x006a, 0x006c, 0x006e, 0x0080, 0x0082, 0x0084
dw 0x0086, 0x0088, 0x008a, 0x008c, 0x008e, 0x00a0, 0x00a2, 0x0000

dw 0x0000, 0x00a4, 0x00a6, 0x00a8, 0x00aa, 0x00ac, 0x00ae, 0x00c0
dw 0x00c2, 0x00c4, 0x00c6, 0x00c8, 0x00ca, 0x00cc, 0x00ce, 0x0000


dw 0x0000, 0x00e0, 0x00e2, 0x00e4, 0x00e6, 0x00e8, 0x00ea, 0x00ec
dw 0x00ee, 0x0100, 0x0102, 0x0104, 0x0106, 0x0108, 0x010a, 0x0000

dw 0x0000, 0x010c, 0x010e, 0x0120, 0x0122, 0x0124, 0x0126, 0x0128
dw 0x012a, 0x012c, 0x012e, 0x0140, 0x0142, 0x0144, 0x0146, 0x0000

dw 0x0000, 0x0148, 0x014a, 0x014c, 0x014e, 0x0160, 0x0162, 0x0164
dw 0x0166, 0x0168, 0x016a, 0x016c, 0x016e, 0x0180, 0x0182, 0x0000

dw 0x0000, 0x0184, 0x0186, 0x0188, 0x018a, 0x018c, 0x018e, 0x01a0
dw 0x01a2, 0x01a4, 0x01a6, 0x01a8, 0x01aa, 0x01ac, 0x01ae, 0x0000

tilemap2:
dw 0x0000, 0x01c0, 0x01c2, 0x01c4, 0x01c6, 0x01c8, 0x01ca, 0x01cc
dw 0x01ce, 0x01e0, 0x01e2, 0x01e4, 0x01e6, 0x01e8, 0x01ea, 0x0000

spcaddr:
dw 0x0100
spcexec:
dw 0x0100
spclen:
db 0x29

//I took this out anyway and inserting from a spc binary compiled from an spc source
//Is more efficient.
//Screw it, copy paste from original for completeness
spccode:

db 0xe8, 0x6c
db 0xc4, 0xf2
db 0xe8, 0x20
db 0xc4, 0xf3
db 0x78, 0x20, 0xf3
db 0xd0, 0xf3

db 0xe8, 0x2c
db 0xc4, 0xf2
db 0xe8, 0x00
db 0xc4, 0xf3
db 0x78, 0x00, 0xf3
db 0xd0, 0xf3

db 0xe8, 0x3c
db 0xc4, 0xf2
db 0xe8, 0x00
db 0xc4, 0xf3
db 0x78, 0x00, 0xf3
db 0xd0, 0xf3

db 0x2f, 0xfe






