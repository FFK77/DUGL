%macro	ARG	2-*
	%assign i	8

	%rep	%0 / 2
		%assign %1  i
		%assign i	i+%2
		%rotate 	2
	%endrep

    PUSH	EBP
	MOV		EBP,ESP
%endmacro

%macro RETURN	0
	POP		EBP
	RET
%endmacro

%macro	FARG 	2-*
	%assign i	4

	%rep	%0 / 2
		%assign %1  i
		%assign i	i+%2
		%rotate 	2
	%endrep

%endmacro

%macro FRETURN  0
	RET
%endmacro
