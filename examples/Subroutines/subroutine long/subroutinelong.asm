arch snes.cpu
output "subroutinelong.sfc", create

macro seek(variable offset) {
  origin ((offset & $7F0000) >> 1) | (offset & $7FFF)
  base offset
}

seek($8000); fill $8000 // Fill Upto $7FFF (Bank 0) With Zero Bytes
include "LIB/SNES.INC"        // Include SNES Definitions
include "LIB/SNES_HEADER.ASM" // Include Header & Vector Table

seek($8000); Start:
  SNES_INIT(SLOWROM) // Run SNES Initialisation Routine

//Make sure I am in 16 bit acumulator mode
rep	#$20;
nop;
nop;


//Push numbers to be added
lda.w	#0x0201;
pha;
lda.w	#0x0302;
pha;


//Zero in acumulator for debuging clarity
lda.w	#0x0000;

//Start of debug step through
db	0x42
nop
nop
nop

//Call subroutine
jsl	Addtwo;
//Return to normal execution

//You need to decrement the stack pointer twice because two values where pushed
//Make sure this is 8 or 16 bit depending on what was passed
pla
pla 
  
//Write a bunch of new values to show stack pointer
//returned to the correct place  
lda.w #0xAAAA
pha
pha
pha
  
Loop:
  jmp Loop
  
//Bank 2
seek($818000)

Addtwo:
  
  //Breakpoint opcode
  nop
  //Stop my add from being messed with by the carry register
  clc    
  //Load the first number
  //4 bytes back because the return address is 3 bytes
  //and another 1 bytes for the proper allignement in LiFO  
  lda $04,s
  nop
  adc $06,s
  nop
  rtl
  
  
  
  
  
  
  
  
  
  
  
  
  
