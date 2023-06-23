galaxia: diag_galaxia.asm 
	asl -a -L -o diag_galaxia.obj -cpu 2650 diag_galaxia.asm

shell:	diag_shell.asm 
	asl -a -L -o diag_shell.obj -cpu 2650 diag_shell.asm

hex:	diag_galaxia.obj diag_shell.obj
	p2hex -F Intel diag_galaxia.obj
	p2hex -F Intel diag_shell.obj

bin:	diag_galaxia.obj diag_shell.obj
	p2bin diag_galaxia.obj
	p2bin diag_shell.obj

compile:	galaxia shell
