# 16-bit real mode assembly
# avaliable code space is 510 bytes
.code16

.text
  .global _start

_start:
  clc           # clear CF (carry flag)
  xorw %ax, %ax # set ax to zero 

  movb $0x02, %ah # read sector
  movb $0x01, %al # number of sectors

  movb $0x0, %ch # track/cylinder number
  movb $0x2, %cl # sector number (1-17 dec.)
  movb $0x0, %dh # head number (0-15 dec.)

  movb $0x80, %dl   # use first drive
  movw $0x7E00, %bx # start of 480.5K of usable memory (https://wiki.osdev.org/Memory_Map_(x86))
  int $0x13

  jc res # jump if CF (carry flag) = 1 which indicates an error
  cmp $0, %ah 
  jne res # jump if ah != 0 which indicates an error

  movw $0, %cx # set counter to 0
loop:
  movb $0x0E, %ah # print interrupt
  movb (%bx), %al # get symbol from buffer
  int $0x10       # print

  incw %cx
  incw %bx

  cmpw $512, %cx
  jne loop
  
res:
  jmp .

  .org 510 - _start
  .word 0xaa55
.ascii "Hello, World!"
