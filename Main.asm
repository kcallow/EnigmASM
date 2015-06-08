%include "IO.asm"
%include "System.mac"
%include "Enigma.mac"
%include "Itoa.mac"
%include "Roman.mac"
%define temp_size 5
%define temp2_size 64
%define result_size 4096
%define Rotors 8

%macro loadCsv 2
	clearString %1, %2
	fgetcsv r8, %1
	mov [rsi], byte 0 ;Delete comma
%endmacro

%macro loadUntilNewline 2
	clearString %1, %2
	fgetline r8, %1
	mov [rsi], byte 0 ;Delete newline
%endmacro

%macro loadRotors 0
	putstring rotorMsg
	loadRotor rotor6
	putstring rotorMsg
	loadRotor rotor7
	putstring rotorMsg
	loadRotor rotor8
	putstring readReflectrMsg
	loadRotor reflector
%endmacro

%macro loadRotor 1
	fgetline r8, %1
	mov rotation(%1),0
	putstring %1
%endmacro

%macro loadRotorSequence 3
	loadCsv temp, temp_size
	loadRotorNumber %1
	loadCsv temp, temp_size
	loadRotorNumber %2
	loadUntilNewline temp, temp_size
	loadRotorNumber %3
%endmacro

%macro loadRotorNumber 1
	romanToInt temp, temp_size, Rotors
	mov rbx, Rotor_size
	mul rbx
	add rax, rotor1
	mov %1, rax
	push %1
	putstring usingMsg
	putstring temp
	putstring colon
	pop %1
	putstring %1
%endmacro

%macro loadRotations 3
	loadCsv temp, temp_size
	loadRotation %1
	loadCsv temp, temp_size
	loadRotation %2
	loadUntilNewline temp, temp_size
	loadRotation %3
%endmacro

%macro loadRotation 1
	mov rax, 2 ;Scan 2 digit number
	push r8
	atoi temp, rax
	pop r8
	mov rotation(%1), al
	putstring rotationMsg
	putstring temp
%endmacro

%macro loadPlugboard 1
	loadUntilNewline temp2, temp2_size
	xor rax,rax
	xor rbx,rax
	mov rsi, temp2
%%loop
	mov al, [rsi]
	cmp al, 0
	je %%end
	mov bl, [rsi + 1]
	loadPlugboardPair %1
	add rsi, 3
	jmp %%loop
%%end
	putstring plugboardMsg
	putstring %1
%endmacro

%macro loadPlugboardPair 1
	letterToCode rax
	mov shift(%1, rax), bl
	codeToLetter rax
	letterToCode rbx
	mov shift(%1, rbx), al
%endmacro

%macro readRotorFile 0
	fopen argument(3), o_readonly
	mov r8, rax
	loadRotors 
	fclose argument(3)
%endmacro

%macro readConfigFile 0
	fopen argument(2), o_readonly
	mov r8, rax
	loadRotorSequence r12, r13, r14
	loadRotations r12, r13, r14
	loadPlugboard plugboard
	fclose argument(2)
	mov [leftRotPtr], r12
	mov [middRotPtr], r13
	mov [rightRotPtr], r14
%endmacro

%macro printRotors 0
	mov r12, [leftRotPtr]
	mov r13, [middRotPtr]
	mov r14, [rightRotPtr]
	putstring reflectorMsg
	putstring reflector
	putstring leftRotorMsg
	printRotor r12
	putstring middleRotorMsg
	printRotor r13
	putstring rightRotorMsg
	printRotor r14
	putstring plugboardMsg
	putstring plugboard
%endmacro

%macro processChar 1
	mov r11, reflector
	mov r12, [leftRotPtr]
	mov r13, [middRotPtr]
	mov r14, [rightRotPtr]
	mov r15, plugboard
	isupper byte [%1]
	jne %%skip
	push rax
	push rcx
	push r11
	putchar c
	pop r11
	pop rcx
	pop rax
	encryptLetter %1, r11, r12, r13, r14, r15
%%skip:
	handleRotations r12, r13, r14
%endmacro

section .text

global _start
_start:
	;Enter raw mode to read char by char.
	call canonical_off
	call echo_off

	putstring clearScreen
	putstring introMsg

	;If arg 4 exists, read line by line.
	cmp argcount, 4
	jl .skip0
	call canonical_on
	call echo_on
.skip0:
	;If three or more args, then load extra rotors from third arg
	cmp argcount, 3
	jl .skip1
	readRotorFile
.skip1:
	;If two or more args, then load rotor sequence, rotations and plugboard from second arg
	cmp argcount, 2
	jl .error
	putstring reflectorMsg
	putstring reflector
	readConfigFile
	putstring beginMsg
	xor rbx,rbx
.loop:
	push rbx
	getchar  c
	cmp rax, 0
	je .end
	putstring clearScreen
	printRotors
	putchar newline
	processChar c
	putchar newline
	pop rbx
	mov al, [c]
	mov [result + rbx], al
	inc rbx
	putstring result
	jmp .loop
.end:
	call canonical_on
	call echo_on
	return 0
.error:
	call canonical_on
	call echo_on
	putstring usageMsg
	return -1

section .data
introMsg	db "Welcome to EnigmASM. Ctrl-C to quit.",10,0
usageMsg	db "  Usage: $ ./EngimASM config [extra-rotors] [line-mode]",10,0
rotorMsg	db 10,"Read rotor:	",0
readReflectrMsg	db 10,"Read reflector:	",0
reflectorMsg	db 10,"Use reflector:	",0
usingMsg	db 10,"Use rotor ",0
rotationMsg	db 10,"Use rotation:	",0
plugboardMsg	db 10,"Use plugboard:	",0
leftRotorMsg	db 10,"Left rotor:	",0
middleRotorMsg	db 10,"Middle rotor:	",0
rightRotorMsg	db 10,"Right rotor:	",0

colon		db ":	",0
beginMsg	db 10,"Begin typing your message in CAPS:",10,0
newline		db 10
clearScreen	db 0x1b,'[2J',0x1b,'[H',0

reflector	newRotor "ZYXWVUTSRQPONMLKJIHGFEDCBA",0
rotor1		newRotor "EKMFLGDQVZNTOWYHXUSPAIBRCJ",0
rotor2		newRotor "AJDKSIRUXBLHWTMCQGZNPYFVOE",0
rotor3		newRotor "BDFHJLCPRTXVZNYEIWGAKMUSQO",0
rotor4		newRotor "ESOVPZJAYQUIRHXLNFTGKDCMWB",0
rotor5		newRotor "VZBRGITYUPSDNHLXAWMJQOFECK",0
rotor6		times Rotor_size db 0
rotor7		times Rotor_size db 0
rotor8		times Rotor_size db 0
plugboard	newRotor "ABCDEFGHIJKLMNOPQRSTUVWXYZ",0

section .bss
temp		resb temp_size
temp2		resb temp2_size
result		resb result_size
c		resb	1
leftRotPtr	resq	1
middRotPtr	resq	1
rightRotPtr	resq	1
