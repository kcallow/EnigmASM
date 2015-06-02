%include "Enigma.mac"
%include "System.mac"
%include "Itoa.mac"
%include "Roman.mac"
%define temp_size 5
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
	putstring reflectorMsg
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
	loadUntilNewline temp2, 64
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

section .text

global _start
_start:
	putstring introMsg
	;If three or more args, then load extra rotors from third arg
	cmp argcount, 3
	jl .skip
	fopen argument(3), o_readonly
	mov r8, rax
	loadRotors 
	fclose argument(3)
.skip:
	putstring reflectUsingMsg
	putstring reflector
	;If two or more args, then load rotor sequence, rotations and plugboard from second arg
	cmp argcount, 2
	jl .error
	fopen argument(2), o_readonly
	mov r8, rax
	loadRotorSequence r12, r13, r14
	loadRotations r12, r13, r14
	loadPlugboard plugboard
	fclose argument(2)
	mov [leftRotPtr], r12
	mov [middRotPtr], r13
	mov [rightRotPtr], r14
	putstring beginMsg
.loop:
	getchar  c
	cmp rax, 0
	je .end
	mov r11, reflector
	mov r12, [leftRotPtr]
	mov r13, [middRotPtr]
	mov r14, [rightRotPtr]
	mov r15, rotor4
	encryptLetter c, r11, r12, r13, r14, r15
	putchar c
	handleRotations r12, r13, r14
	jmp .loop
.end:
	return 0
.error:
	putstring usageMsg
	return -1

section .data
introMsg	db "Welcome to EnigmASM. Ctrl-C to quit.",10,0
usageMsg	db "  Usage: $ ./EngimASM config [extra-rotors]",10,0
rotorMsg	db 10,"Read rotor: ",0
reflectorMsg	db 10,"Read reflector: ",0
reflectUsingMsg	db 10,"Using reflector ",0
usingMsg	db 10,"Using rotor ",0
rotationMsg	db 10,"Using rotation: ",0
plugboardMsg	db 10,"Using plugboard: ",0
colon		db ": ",0
beginMsg	db 10,"Begin typing your message in CAPS:",10,0

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
temp2		resb 64
c		resb	1
leftRotPtr	resq	1
middRotPtr	resq	1
rightRotPtr	resq	1
