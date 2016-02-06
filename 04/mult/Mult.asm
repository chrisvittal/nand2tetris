// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

// Put your code here.

// Initialize:
  @1
  D=M
  @3
  M=D
  @2
  M=0
  @3
  D=M
(LOOP)
  @END
  D;JEQ
  @0
  D=M
  @2
  M=D+M
  @3
  MD=M-1
  @LOOP
  0;JMP
(END)
  @END
  0;JMP
  