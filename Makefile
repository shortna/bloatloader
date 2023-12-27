# in case shell inherited from environment
SHELL = /bin/sh

# clears out the suffix list 
.SUFFIXES:

# introduces all suffixes which may be subject to implicit rules in this Makefile.
.SUFFIXES: .o .asm 

SRC_DIR = src
TARGET_DIR = build
TARGET = boot.bin

all: $(TARGET_DIR) boot.o $(TARGET)

$(TARGET_DIR):
	mkdir $@

boot.o: $(SRC_DIR)/*.asm
	$(AS) $< -o $(TARGET_DIR)/$@ -g

$(TARGET): $(TARGET_DIR)/boot.o
	$(LD) $< --oformat=binary -Ttext=0x7C00 -o $(TARGET_DIR)/$@ -g

qemu-img: 
	qemu-img create -f raw image 64k; \
	cat $(TARGET_DIR)/$(TARGET) > image

qemu:
	qemu-system-i386 -nographic -drive file=image,format=raw

clean:
	rm -r $(TARGET_DIR) image
