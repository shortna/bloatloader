.code16
.section .text
  clc           # clear CF (carry flag)
  xorw %ax, %ax # set ax to zero 
  movw %SS:0xFFFF, %sp # reset stack to start position
  call print_status_A20

########################
#     ENABLING A20     #
########################
# check if A20 is enabled
# GS - general purpose segment
check_A20:
  pushw %bp
  movw %sp, %bp

  movw $0xFFFF, %ax
  # 0x500 start of 29.75K of usable memory (https://wiki.osdev.org/Memory_Map_(x86))
  movw %ax, %GS
  # %GS + 0x10 is a start of high memory area
  # %GS + 0x500 in case A20 not enabled we looping back to address 0x500
  movb $0xFE, %GS:0x510

  movw $0x500, %ax
  movw %ax, %ES
  movw %ES:0x0, %bx

  cmpb $0xFE, (%bx)
  jne A20_enabled

  movb $0x0, %al
  jmp A20_end
    
  A20_enabled:
  movb $0x1, %al

  A20_end:
  pop %bp
  ret

print_status_A20:
  call check_A20
  movb %al, %cl
  addb $0x30, %cl

  movw $A20_enabled_msg, %si

  print_status_msg:
    movb $0x0E, %ah
    movb (%si), %al
    int $0x10
    incw %si
    cmpb $0x0, (%si)
  jne print_status_msg

  movb $0x0E, %ah
  movb %cl, %al
  int $0x10

  jmp .

########################
#      LOAD GDT        #
########################

########################
# ENTER PROTECTED MODE #
########################

A20_enabled_msg:
  .ascii "A20 status = \0"
