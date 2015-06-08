##This is EnigmASM...
... an implementation of the classic Enigma machine in x86-64 NASM assembly, for Linux.  By Kenneth Callow.

#Features:
 - Can encrypt text line by line, or character by character.
 - Reads custom rotors and configuration from file.
 - Shows the encryption sequence and current state of rotors, plugboard and reflector, and thus can be useful in teaching the workings of this machine.
 - Code consists mainly of macro modules, which can be easily reused.

#Limitations:
 - Can only encrypt text up to 4096 chars (though this can be easily redefined in Main.asm).
 - For the purposes of "pretty printing", screen is cleared and printed each time a character is encrypted.  This breaks somewhat the Unix philosophy of having program output to standard output in a useful manner for other programs reading from standard input.
 - Cannot delete chars once they are encrypted.
 - Encrypts only uppercase ASCII characters.
 - Not a very good encryption algorithm in current computing.

#Getting started:
  1. Download the source and decompress.
  2. Type 'make' in the source's directory.
     NOTE: Makefile uses YASM as assembler.  To use NASM, open 'Makefile' and change the 'ASSEMBLER' variable's value from 'yasm' to 'nasm'.
  3. You should now have an executable called 'Main'.  To run it, type './Main config.txt rotors.txt'.  This uses the example config and extra rotors file.  Do './Main' to see full usage.
  4. Start typing capital letters.  You will see how the rotors rotate each time, and see the sequence of letters passed to encrypt your letter.  Whitespace, punctuation, numbers, and lowercase letters are not encrypted.  Type Ctrl-C when done.
