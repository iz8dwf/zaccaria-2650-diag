galaxia: diag_galaxia.asm 
	asl -a -L -o diag_galaxia.obj -cpu 2650 diag_galaxia.asm
	p2hex -F Intel diag_galaxia.obj
	p2bin diag_galaxia.obj

astrowars: diag_awars.asm 
	asl -a -L -o diag_awars.obj -cpu 2650 diag_awars.asm
	p2hex -F Intel diag_awars.obj
	p2bin diag_awars.obj

shell:	diag_shell.asm 
	asl -a -L -o diag_shell.obj -cpu 2650 diag_shell.asm
	p2hex -F Intel diag_shell.obj
	p2bin diag_shell.obj

awshell:	diag_awshell.asm 
	asl -a -L -o diag_awshell.obj -cpu 2650 diag_awshell.asm
	p2hex -F Intel diag_awshell.obj
	p2bin diag_awshell.obj

all:	galaxia astrowars shell awshell
