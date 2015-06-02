/*
 *  Enigma.c	
 *  	A simple implementation of the Enigma machine.
 *  AUTHOR: Kenneth Callow 
 *	    Written on the lazy Saturday morning of 30-May-2015
 *  Compile with:
 *  	$ gcc Enigma.c -o Enigma
 */

#include <stdio.h>
#include <string.h>
#include <ctype.h>

#define LETTERS 26

typedef struct {
	char shift[LETTERS];
	char rotation;	//In range 0 to LETTERS - 1
} Rotor; 

char letterToCode(char letter) {
	return (char) letter - 'A';
}

char codeToLetter(char code) {
	return (char) code + 'A';
}

char getLetterShift(char letter, Rotor rotor) {
	if(!isupper(letter))
		return letter;	//Do nothing if not an uppercase letter
	char letterCode = letterToCode(letter);
	char index = letterCode + rotor.rotation;
	index %= LETTERS;
	return rotor.shift[index];
}

char getShiftIndex(char shift, Rotor rotor) {
	int i;
	for(i = 0; i < LETTERS; i++)
		if(rotor.shift[i] == shift)
			break;
	return i;
}

char getLetterFromShift(char shift, Rotor rotor) {
	int index = getShiftIndex(shift, rotor);
	if(index == LETTERS)
		return shift;
	char letter = codeToLetter(index) - rotor.rotation;
	if(letter < 'A')
		letter += LETTERS;
	return letter;
}

char encryptLetter(char letter, Rotor reflector, Rotor leftRotor, Rotor middleRotor, Rotor rightRotor, Rotor plugboard) {
	letter = getLetterShift(letter,plugboard);
	letter = getLetterShift(letter,rightRotor);
	letter = getLetterShift(letter,middleRotor);
	letter = getLetterShift(letter,leftRotor);
	letter = getLetterShift(letter,reflector);
	letter = getLetterFromShift(letter,leftRotor);
	letter = getLetterFromShift(letter,middleRotor);
	letter = getLetterFromShift(letter,rightRotor);
	letter = getLetterFromShift(letter,plugboard);
	return letter;
}

void handleRotations(Rotor* leftRotor, Rotor* middleRotor, Rotor* rightRotor) {
	rightRotor->rotation++;
	if(rightRotor->rotation == LETTERS) {
		rightRotor->rotation = 0;
		middleRotor->rotation++;
	}
	if(middleRotor->rotation == LETTERS) {
		middleRotor->rotation = 0;
		leftRotor->rotation++;
	}
	if(leftRotor->rotation == LETTERS) {
		leftRotor->rotation = 0;
	}
}

int main() {
	Rotor reflector, leftRotor, middleRotor, rightRotor, plugboard;
	strcpy(reflector.shift, "ZYXWVUTSRQPONMLKJIHGFEDCBA");
	strcpy(leftRotor.shift, "EKMFLGDQVZNTOWYHXUSPAIBRCJ");
	strcpy(middleRotor.shift, "AJDKSIRUXBLHWTMCQGZNPYFVOE");
	strcpy(rightRotor.shift, "BDFHJLCPRTXVZNYEIWGAKMUSQO");
	strcpy(plugboard.shift, "AJDKSIRUXBLHWTMCQGZNPYFVOE");
	reflector.rotation = 0;
	leftRotor.rotation = 0;
	middleRotor.rotation = 0;
	rightRotor.rotation = 0;
	plugboard.rotation = 0;
	char c;
	char separator = '.';
	while((c = getchar()) != separator) {
		putchar(encryptLetter(c, reflector, leftRotor, middleRotor, rightRotor, plugboard));
		handleRotations(&leftRotor, &middleRotor, &rightRotor);
	}
	return 0;
}
