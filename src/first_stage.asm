# 16-bit real mode assembly
# avaliable code space is 510 bytes
.code16

.text
  .global _start

_start:
  clc           # clear CF (carry flag)
  xorw %ax, %ax # set ax to zero 

###################################
#  ESTABLISHING BOOT LOADER STACK #
###################################
# start adderrors of stack is 0x0007FFFF
# 0x7FFFF = (x * 0x10) + 0xFFFF
# 0x7FFFF - 0xFFFF = x * 0x10
# 0x70000 = x * 0x10
# x = 0x70000 / 0x10
# x = 0x7000

  movw $0x7000, %ax
  movw %ax, %SS
  movw %SS:0xFFFF, %sp

###################################

###################################
#  ESTABLISHING BUFFER FOR data   #
###################################

  movw $0x7E00, %ax
  movw %ax, %ES

###################################

  movb $0x02, %ah # read sector
  movb $0x04, %al # number of sectors

  movb $0x0, %ch # track/cylinder number
  movb $0x2, %cl # sector number (1-17 dec.)
  movb $0x0, %dh # head number (0-15 dec.)

  movb $0x80, %dl    # use first drive
  movw %ES:0x0, %bx  # start of 480.5K of usable memory (https://wiki.osdev.org/Memory_Map_(x86))
  int $0x13

  cmp $0, %ah 
  jne error # jump if ah != 0 which indicates an error

  cmp $0, %al
  je error  # jump if nothing was read

  jmp *%bx # jump to second stage

error:
  movb %ah, %bl  # saves error code
  movw $err, %si # move message addres to si

  # print message till \0
  message:
    movb $0x0E, %ah
    movb (%si), %al
    int $0x10

    incw %si
    cmpb $0x0, (%si)
  jne message

  # prints error_code
  pushw %bx
  call print_byte_in_hex
  
  # infinite loop
  jmp .

# byte to print must be located in lower half
print_byte_in_hex:
  pushw %bp
  movw %sp, %bp

  movb 4(%bp), %al
  shrb $0x4, %al # shift higher 4 bits to lower 4

  pushw %ax
  call half_bit_value_to_ascii

  movb $0x0E, %ah # print hex digit
  int $0x10

  movb 4(%bp), %al
  andb $0xF, %al # remove higher 4 bits


  pushw %ax
  call half_bit_value_to_ascii

  movb $0x0E, %ah # print hex digit
  int $0x10
 
  addw $0x4, %sp # move stack pointer 2 values back
  popw %bp
  ret

# argument is lower 4 bits of lower byte of register
# return is in %al
half_bit_value_to_ascii:
  pushw %bp
  movw %sp, %bp

  movb 4(%bp), %al
  cmpb $0x9, %al # check if value is digit or char
  jle number

  char:
  addb $0x37, %al # add 0x37 to make value to ascii char
  jmp end

  number:
  addb $'0', %al # add '0' to char to make it ascii digit
  jmp end

  end:
  popw %bp
  ret

err:
  .ascii "Something went wrong, error code: \0"
  
  .org 510 - _start # pad rest wiht zeros
  .word 0xaa55      # magic number
