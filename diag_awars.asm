; Diagnostic 1Kbytes ROM for Zaccaria Astrowars arcade PCB
; display circuitry.
; IZ8DWF 2022 - 2025
; rev. 0.1
	
; This code needs to go in position 8H (mapped at 0000H)
; the other ROMs are mapped as follows:
; 10H @ 0400H
; 11H @ 0800H
; 13H @ 0C00H
; 8I  @ 1000H
; 10I @ 2000H
; 11I @ 2400H
; 13I @ 2800H
; 11L @ 2C00H
; 13L @ 3000H

; Memory mapped stuff other than ROMs:
;
; Program (user) RAM   	1400H - 14FFH  (low nibble 13F, high 13G)
; 2636 PVI 8F	      	1500H - 15FFH
; BG color RAM	      	1800H - 1BFFH with PSU FLAG = 0 (low nibble only 3C)
; BG (character) RAM  	1800H - 1BFFH with PSU FLAG = 1 (low nibble 2C, high 1C)
; Shell (bombs) RAM 	1C00H - 1CFFH (low nibble 3F, high 2F)

; I/O read map:
;
; redd - clears collision detection 
; redc - reads collision detection @ 7L
; etxended: (bits 0 to 5 valid only)
; 0H = inputs 0 
; 2H = inputs 1 
; 6H = DIP switches @ 3N
; 7H = DIP switches @ 2N

; I/O write map:
;
; wrtd - sounds (3L latch, bits 0 to 5)
; wrtc - latch at 2L 
;	 bit 5 = STON (starfield enable)
;        bit 4 = sound 8
;        bit 3 = sound 7
;        bit 2,1,0 = transitor bases (coin counters)
; extended -> DO NOT USE: extended I/O is not qualified with R/W signal.

; The first 32 bytes on the BG ram aren't displayed, so we can use them as general purpose
; RAM: 1800H to 181FH 
; It also seems that only 29 chars of each row are actually displayed
; "first" row of text begins at 1BE0H, second at 1BE1H etc..
	relaxed on
	page 	0
	cpu	2650
	org 	0

reset:
	lodi,r0 H'20'	; mask to disable interrupts
	lpsu		; disables interrupts 
	eorz r0		; r0 XOR r0 = clears the register  
	lpsl		; clears status low
	ppsl H'02'	; set to unsigned logic compare
	strz r1		; clears r1




; let's first zero all shell RAM now
; so we can see the "background" characters only

	bsta,un zersh

	ppsu H'40'		; to access the char ram, flag must be 1
	lodi,r0 H'A0'
	bsta,un fill
; outputs a pattern on the PVIs

pvi:	stra,r0 H'1500',r0
	birr,r0 pvi
	bsta,un wfinp		; wait for player 1 pressed to continue

clrpvi:	stra,r0 H'1500',r1
	birr,r1 clrpvi

; now fill all the char ram and color ram with an
; incrementing pattern from 00 to FF (each with 00 to 11 colors)

wlp:	stra,r0 H'1800',r1,+
	stra,r0 H'1900',r1	
	stra,r0 H'1A00',r1	
	stra,r0 H'1B00',r1
	brnr,r1 wlp
	addi,r0 H'01'
	bstr,un colcyc
	brnr,r0 wlp
chrs:	stra,r0 H'1A00',r0,+	; test all charset
	stra,r0 H'1830',r0
	brnr,r0 chrs
	bsta,un wfinp		; wait for player 1 pressed to continue
	bctr,un tstram

colcyc:
	cpsu H'40'		; to access color ram
	strz r3			; save r0
	eorz r0
ccyc:	bsta,un fill
	addi,r0 H'01'
	bsta,un inpck		; check if fire is pressed, to pause the cycling
	comi,r0 H'07'
	bcfr,eq ccyc
	lodz,r3			; restore old r0
	ppsu H'40'		; to access the char ram, flag must be 1
	retc,un

tstram:

; now let's make a better char ram test
; copy a ROM image into it and then compare
; it back. Errors will be output to
; shifter latches (toggling = bit having errors)

; test the BG ram first
	ppsu H'40'
	bsta,un tstbg
	lodi,r0 H'F0'
	bsta,un fill
	lodi,r2 (welc>>8)&H'00FF'	; print the diag banner
	lodi,r3 (welc&H'00FF')-1	; start address needs to be one byte before the actual string
	bsta,un stspos
	lodi,r2 H'1B'
	lodi,r3 H'E0'
	bsta,un stvpos
	bsta,un print
	lodi,r2 (bg>>8)&H'00FF'	; print BG ram
	lodi,r3 (bg&H'00FF')-1		; start address needs to be one byte before the actual string
	bsta,un stspos
	lodi,r2 H'1B'
	lodi,r3 H'E1'			; on second row
	bsta,un stvpos
	bsta,un print
	bsta,un prram
	bsta,un prok

; now the program (user) ram will be tested
; exactly in the same way
	lodi,r2 (cpu>>8)&H'00FF'	; print CPU ram
	lodi,r3 (cpu&H'00FF')-1		; start address needs to be one byte before the actual string
	bsta,un stspos
	lodi,r2 H'1B'
	lodi,r3 H'E2'			; on third row
	bsta,un stvpos
	bsta,un print
	bsta,un prram


pram:	loda,r0 H'0800',r1,+
	stra,r0 H'1400',r1
	brnr,r1 pram
cpram:	loda,r0 H'0800',r1,+
	strz,r2
	loda,r0 H'1400',r1
	comz,r2
	bsfa,eq ramerr
	brnr,r1 cpram
	bsta,un wfinp		; wait for player 1 pressed
	bsta,un prok

; now we test the four bits of color char ram
	lodi,r2 (col>>8)&H'00FF'	; print CPU ram
	lodi,r3 (col&H'00FF')-1		; start address needs to be one byte before the actual string
	bsta,un stspos
	lodi,r2 H'1B'
	lodi,r3 H'E3'			; on 4th row
	bsta,un stvpos
	bsta,un print
	bsta,un prram

	cpsu H'40'		; to access color ram
	bsta,un tstbg
	lodi,r0 H'03'		; restore a single color
	bsta,un fill
	ppsu H'40'		; to access char ram
	bsta,un prok

; test the "shell" RAM, 256 bytes total
; 
	lodi,r2 (shel>>8)&H'00FF'	
	lodi,r3 (shel&H'00FF')-1	; start address needs to be one byte before the actual string
	bsta,un stspos
	lodi,r2 H'1B'
	lodi,r3 H'E4'			; on 5th row
	bsta,un stvpos
	bsta,un print
	bsta,un prram

shwlp:	loda,r0 H'0400',r1,+ 	; let's copy part of a ROM
	stra,r0 H'1C00',r1 	; to shell ram range 
	brnr,r1 shwlp
shcmp:	loda,r0 H'0400',r1,+	; read again the ROM
	strz,r2
	loda,r0 H'1C00',r1	; and compare to the shell RAM
	comz,r2
	bsfa,eq	ramerr		
	brnr,r1 shcmp
	bsta,un prok
	bsta,un zersh
; print the collision latch content after zeroing it
; it must read 04H
;	redd,r0			; resets the collision registers
;	eorz,r0
;	stra,r0 H'1806'
;	lodi,r2 (cll>>8)&H'00FF'	
;	lodi,r3 (cll&H'00FF')-1	; start address needs to be one byte before the actual string
;	bsta,un stspos
;	bsta,un print
;	redc,r0			; reads the collision registers
;	stra,r0 H'1804'
;	bsta,un hexadj
;	stra,r0 H'1805'
;	loda,r0 H'1804'
;	bsta,un rot0
;	stra,r0 H'1804'
;	lodi,r2 H'18'			; prints the bit error hex
;	lodi,r3 H'03'
;	bsta,un stspos
;	bsta,un print
	

; calculate chksum of all ROMs
roms:	
	lodi,r2 (tenh>>8)&H'00FF'
	lodi,r3 (tenh&H'00FF')-1		; start address needs to be one byte before the actual string
	bsta,un stspos
	lodi,r2 H'1B'
	lodi,r3 H'E6'			; on 5th row
	bsta,un stvpos
	bsta,un print
	lodi,r2 H'04'
	stra,r2 H'181E'			; use 181E-F as ROM pointer
	eorz,r0
	stra,r0 H'181F'
	bsta,un romck
	lodi,r2 (eleh>>8)&H'00FF'
	lodi,r3 (eleh&H'00FF')-1		; start address needs to be one byte before the actual string
	bsta,un stspos
	bsta,un print
	bsta,un romck
	lodi,r2 (thih>>8)&H'00FF'
	lodi,r3 (thih&H'00FF')-1		; start address needs to be one byte before the actual string
	bsta,un stspos
	bsta,un print
	bsta,un romck
	lodi,r2 (eigi>>8)&H'00FF'
	lodi,r3 (eigi&H'00FF')-1		; start address needs to be one byte before the actual string
	bsta,un stspos
	lodi,r2 H'1B'
	lodi,r3 H'E7'			; on 6th row
	bsta,un stvpos
	bsta,un print
	bsta,un romck
	lodi,r2 (teni>>8)&H'00FF'
	lodi,r3 (teni&H'00FF')-1		; start address needs to be one byte before the actual string
	bsta,un stspos
	bsta,un print
	lodi,r2 H'20'
	stra,r2 H'181E'			; use 181E-F as ROM pointer
	eorz,r0
	stra,r0 H'181F'
	bsta,un romck
	lodi,r2 (elei>>8)&H'00FF'
	lodi,r3 (elei&H'00FF')-1		; start address needs to be one byte before the actual string
	bstr,un stspos
	bsta,un print
	bsta,un romck
	lodi,r2 (thii>>8)&H'00FF'
	lodi,r3 (thii&H'00FF')-1		; start address needs to be one byte before the actual string
	bstr,un stspos
	lodi,r2 H'1B'
	lodi,r3 H'E8'			; on 7th row
	bstr,un stvpos
	bsta,un print
	bsta,un romck
	lodi,r2 (elel>>8)&H'00FF'
	lodi,r3 (elel&H'00FF')-1		; start address needs to be one byte before the actual string
	bstr,un stspos
	bsta,un print
	bsta,un romck
	lodi,r2 (thil>>8)&H'00FF'
	lodi,r3 (thil&H'00FF')-1		; start address needs to be one byte before the actual string
	bstr,un stspos
	bsta,un print
	bsta,un romck
	bcta,un roms			; loop on rom cksum
; subroutines

stspos:
	stra,r2 H'1800'
	stra,r3 H'1801'
	retc,un
stvpos:
	stra,r2 H'1802'
	stra,r3 H'1803'
	retc,un

fill:	stra,r0 H'1800',r1,+
	stra,r0 H'1900',r1
	stra,r0 H'1A00',r1
	stra,r0 H'1B00',r1
	brnr,r1 fill
	retc,un

tstbg:
	loda,r0 H'0400',r1,+
	stra,r0 H'1800',r1
	loda,r0 H'0500',r1
	stra,r0 H'1900',r1
	loda,r0 H'0600',r1
	stra,r0 H'1A00',r1
	loda,r0 H'0700',r1
	stra,r0 H'1B00',r1
	brnr,r1 tstbg
cpbg:	loda,r0 H'0400',r1,+
	strz,r2
	loda,r0 H'1800',r1
	comz,r2
	bsfr,eq ramerr
	loda,r0 H'0500',r1
	strz,r2
	loda,r0 H'1900',r1
	comz,r2
	bsfr,eq ramerr
	loda,r0 H'0600',r1
	strz,r2
	loda,r0 H'1A00',r1
	comz,r2
	bsfr,eq ramerr
	loda,r0 H'0700',r1
	strz,r2
	loda,r0 H'1B00',r1
	comz,r2
	bsfr,eq ramerr
	brnr,r1 cpbg
	bsta,un wfinp		; wait for player 1 pressed
	retc,un
	

ramerr:
	eorz,r2
	tpsu H'40'		; if we are testing color ram
	bctr,eq cnt		; no we aren't so it's a real error
	andi,r0 H'0F'		; color RAM is only wired to D3..D0
	bctr,eq noerr		; so we exit if there's no error on those two bits
cnt:	bsta,un prerr		; print error bits and error offset
	bsta,un wfinp		; wait for player 1 pressed
noerr:	retc,un

romck:  tpsu H'80'		; attempt to start in the vertical retrace
	bcfr,eq romck
	lodi,r0 H'F0'
	stra,r0 H'1809'
	stra,r0 H'1804'
	eorz,r0
	stra,r0 H'180A'
	strz,r1			
	strz,r3			; r3 will have the MS byte of the sum
	ppsl H'08'		; with carry = 1
	cpsl H'01'		; clear carry
	loda,r2 H'181E'		; initial high byte of rom address
	addi,r2 H'04'
	stra,r2 H'183E'		; we need the end MSB, 1K rom = 4 x 256
sum:	adda,r0 *H'181E',r1,+	
	addi,r3 H'00'		; just the carry added
	cpsl H'01'		; clear carry
	brnr,r1 sum
	loda,r2 H'181E'
	addi,r2 H'01'
	stra,r2 H'181E'
	coma,r2 H'183E'
	bcfr,eq sum
	cpsl H'08'
	stra,r0 H'1807'
	bstr,un hexadj
	stra,r0 H'1808'
	loda,r0 H'1807'
	bstr,un rot0
	stra,r0 H'1807'
	lodz,r3
	bstr,un hexadj
	stra,r0 H'1806'
	lodz,r3
	bstr,un rot0
	stra,r0 H'1805'
	lodi,r2 H'18'			
	lodi,r3 H'03'
	bsta,un stspos
	bsta,un print
	retc,un


hexadj:
	andi,r0 H'0F'
	addi,r0 H'30'
	comi,r0 H'3A'
	bctr,lt stlow
	addi,r0 H'07'
stlow:	retc,un

rot0:	rrr,r0
	rrr,r0
	rrr,r0
	rrr,r0
	bstr,un hexadj
	retc,un


prerr:	stra,r0 H'1FF0'		; saves register 0 in program RAM
	spsu			; stores cpu status upper in r0
	stra,r0 H'1FF1'		; and writes it in program RAM too	
	ppsu H'40'		; to access the char ram, flag must be 1
	loda,r0 H'1FF0'
				; error bits (0 = bad) are in r0, offset in r1
	eori,r0 H'FF'		; lets invert the bits again
	stra,r0 H'1804'		; save the value
	bstr,un hexadj
	stra,r0 H'1805'
	loda,r0 H'1804'
	bstr,un rot0
	stra,r0 H'1804'
	eorz,r0
	stra,r0 H'1806'
	stra,r0 H'1809'
	lodz,r1
	bstr,un hexadj
	stra,r0 H'1808'
	lodz,r1
	bstr,un rot0
	stra,r0 H'1807'
	lodi,r2 (bits>>8)&H'00FF'	
	lodi,r3 (bits&H'00FF')-1	; start address needs to be one byte before the actual string
	bsta,un stspos
	bsta,un print

	lodi,r2 H'18'			; prints the bit error hex
	lodi,r3 H'03'
	bsta,un stspos
	bsta,un print

	lodi,r2 (offs>>8)&H'00FF'	
	lodi,r3 (offs&H'00FF')-1	; start address needs to be one byte before the actual string
	bsta,un stspos
	bsta,un print
	lodi,r2 H'18'			
	lodi,r3 H'06'
	bsta,un stspos
	bsta,un print
	loda,r0 H'1FF1'		; get the saved cpu status upper byte
	lpsu			; and rewrite in the actual status byte
	retc,un


inpck:
	rede,r2 H'00'		; read input col. 0
	andi,r2 H'20'		; mask bit 5 (fire)
	bctr,eq inpck		; if is pressed, we wait
	retc,un
wfinp:
	rede,r2 H'00'		; read input col. 0
	andi,r2 H'01'		; mask bit 0 (player 1)
	bcfr,eq wfinp		; if is NOT pressed, we wait
wfrl:	rede,r2 H'00'
	andi,r2 H'01'		
	bctr,eq wfrl		; wait for release
	retc,un

prram:
	lodi,r2 (ram>>8)&H'00FF'	; print ram
	lodi,r3 (ram&H'00FF')-1		; start address needs to be one byte before the actual string
strp:	stra,r2 H'1800'
	stra,r3 H'1801'
	bstr,un print
	retc,un
prok:
	lodi,r2 (ok>>8)&H'00FF'	; print ok
	lodi,r3 (ok&H'00FF')-1		; start address needs to be one byte before the actual string
	bctr,un strp
print:
	ppsl H'10'		; use alternate registers
	lodi,r1 H'00'
	loda,r2 H'1802'
	loda,r3 H'1803'
rdnext:	loda,r0 *H'1800',r1,+
	bctr,eq expr		; we reached the null termination
	iori,r0 H'80'		; set bit 7 
	stra,r0 *H'1802'	; store in video ram
	comi,r3 H'40'
	bcfr,lt t20
	comi,r2 H'18'		; attempt at wrapping around to the next line
	bctr,gt t20
	lodi,r2 H'1B'
	andi,r3 H'1F'
	addi,r3 H'01'
	bctr,un st2
t20:	comi,r3 H'20'
	bcfr,lt npos
	subi,r2 H'01'
st2:	stra,r2 H'1802'
npos:	subi,r3 H'20'
	stra,r3 H'1803'
	bctr,un rdnext
expr:	cpsl H'10'		; "old" registers again
	retc,un
	

zersh:	eorz,r0
	strz,r1
wz:	stra,r0 H'1C00',r1,+
	brnr,r1 wz
	retc,un

; not all letters are available! 
; use ascii uppercase and set bit 7 before printing

welc:   db "AWAR DIAG 8DWF\0"
ram:	db "RAM\0"
rom:	db "ROM\0"
cpu:	db "CP \0"
cll:	db " CL \0"
bg:	db "BG ",H'00'
col:	db "CO ",H'00'
shel:	db "SH ",H'00'
ok:	db " GD",H'00'
bits:	db " B ",H'00'
offs:	db " O ",H'00'
tenh:	db "10H\0"
eleh:	db "11H\0"
thih:	db "13H\0"
eigi:	db "8I\0"
teni:	db "10I\0"
elei:	db "11I\0"
thii:	db "13I\0"
elel:	db "11L\0"
thil:	db "13L\0"
