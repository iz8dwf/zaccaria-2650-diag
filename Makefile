compile: diag_galaxia.asm
	asl -a -L -o diag_galaxia.obj -cpu 2650 diag_galaxia.asm

hex:	diag_galaxia.obj
	p2hex -F Intel diag_galaxia.obj

bin:	diag_galaxia.obj
	p2bin diag_galaxia.obj
