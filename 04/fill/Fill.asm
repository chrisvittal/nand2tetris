// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input. 
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel. When no key is pressed, the
// program clears the screen, i.e. writes "white" in every pixel.

// Put your code here.

// Initialize:

(RESET)
  @16384
  D=A
  @scrn
  M=D
  @24576
  D=M
  @WHITE
  D;JEQ
  @BLACK
  D;JGT
(WHITE)
  @scrn
  A=M
  M=0
  A=A+1
  D=A
  @scrn
  M=D
  @24575
  D=D-A
  @RESET
  D;JGT
  @24576
  D=M
  @WHITE
  D;JEQ
  @BLACK
  D;JGT
(BLACK)
  @scrn
  A=M
  M=-1
  A=A+1
  D=A
  @scrn
  M=D
  @24575
  D=D-A
  @RESET
  D;JGT
  @24576
  D=M
  @WHITE
  D;JEQ
  @BLACK
  D;JGT