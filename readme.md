Diagnostic 1Kbytes ROM for Zaccaria Galaxia arcade PCB
 IZ8DWF 2022
 rev. 0.6

This code is compiled with the Macro Assembler AS:
http://john.ccac.rwth-aachen.de:8000/as/

1) `diag_galaxia` 

It can be programmed into a 2708 (or any other PROM memory if you use a socket
adapter). It goes in the `8H` socket on the Galaxia logic PCB.
Hint: use the binary with the `galaxiac` MAME driver as the 8h file so you can
see what it does on a working machine. 
First displays a pattern on the three 2636 PVIs, then cycles on all the chargen
characters, then tests all the different RAM segments and if all is ok it
displays all other ROM's checksums in a loop.
Use "player 1" input to advance between the tests.

2) `diag_shell`

Also this goes in the `8H` socket. It exercises the shell RAM and shell video
generator (shell are the galaxian's bombs, these are generated as separate
objects and are neither characters nor PVI's sprites). Press `Player 1` to
change from a static pattern to a moving one.

3) `diag_awshell`

Same test as `diag_shell` but for the Astro War PCB that has different memory
mapping. Moving pattern can be freezed by holding down the fire button. Can
switch between different patterns by pressing `Player 1`.

4) `diag_awars` 

Goes in socket `8H` of the Astrowars PCB, tests RAM spaces and prints ROM's
checksums. It advances between tests by pressing "player 1" input.

For further information,
read the .asm files ;-)
