; Diagnostic 1Kbytes ROM for Zaccaria Astro War arcade PCB
; this code only tests the "shell" (alien's bombs) RAM and
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
; Shell (bombs) RAM 	1C00H - 1CFFH (low nibble 3F, high 2F)
; BG color RAM	      	1800H - 1BFFH with PSU FLAG = 0 (low nibble only 3C)
; BG (character) RAM  	1800H - 1BFFH with PSU FLAG = 1 (low nibble 2C, high 1C)
; Program RAM        	1400H - 14FFH  (low nibble 13F, high 13G)
; 2636 PVI 8F	      	1500H - 15FFH

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
;

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


; clears the sprites of PVIs

clrpvi:	stra,r0 H'1500',r1
	birr,r1 clrpvi


; initial diag outputs are the screen shifter latches	
;	lodi,r2 H'FF'		; set all latch bits to 1
;	wrte,r2 H'00'

; clears "background" RAM

	ppsu H'40'		; to access the char ram, flag must be 1
	lodi,r0 H'F0'
	bsta,un fill

; makes a static diagonal "shell" pattern

	eorz,r0
	lodz,r1
fixsh:	stra,r0 H'1C00',r0
	birr,r0 fixsh
	bsta,un wfinp		; wait for player 1 pressed

; the following makes a shifting pattern
	eorz,r0
	lodz,r1
vsy:	tpsu H'80'		; attempt to start in the vertical retrace
	bcfr,eq vsy
shpt:	stra,r0 H'1C00',r1,+
	birr,r0 shpt
	addi,r1 H'01'
	bctr,un vsy		; and loops forever

; subroutines

fill:	stra,r0 H'1800',r1,+
	stra,r0 H'1900',r1
	stra,r0 H'1A00',r1
	stra,r0 H'1B00',r1
	brnr,r1 fill
	retc,un


hexadj:
	andi,r0 H'0F'
	addi,r0 H'60'
	comi,r0 H'6A'
	bctr,lt stlow
	subi,r0 H'29'
stlow:	retc,un

rot0:	rrr,r0
	rrr,r0
	rrr,r0
	rrr,r0
	bstr,un hexadj
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



; not all letters are available! 
; space is 3Fh
; numbers start at 60h

welc:	db "GALA",H'3F',"DIAG",H'3F',H'68',"DWF\0"
ram:	db "RAM\0"
rom:	db "ROM\0"
cpu:	db "CP",H'3F',H'00'
cll:	db H'3F',"CL",H'3F',H'00'
bg:	db "BG",H'3F',H'00'
col:	db "CO",H'3F',H'00'
shel:	db "SH",H'3F',H'00'
ok:	db H'3F',"GD",H'00'
bits:	db H'3F',"B",H'3F',H'00'
offs:	db H'3F',"O",H'3F',H'00'
tenh:	db H'61',H'60',"H\0"
eleh:	db H'61',H'61',"H\0"
thih:	db H'61',H'63',"H\0"
eigi:	db H'68',"I\0"
teni:	db H'61',H'60',"I\0"
elei:	db H'61',H'61',"I\0"
thii:	db H'61',H'63',"I\0"
elel:	db H'61',H'61',"L\0"
thil:	db H'61',H'63',"L\0"
