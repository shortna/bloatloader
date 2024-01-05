# in case shell inherited from environment
SHELL = /bin/sh

# clears out the suffix list .SUFFIXES:
# introduces all suffixes which may be subject to implicit rules in this Makefile.
.SUFFIXES: .o .asm 

SRC_DIR = src
OBJ_DIR = objects
TARGET_DIR = build

OBJECTS = first_stage.o second_stage.o
TARGET = bootloader

QEMU_IMAGE = image

all: $(TARGET_DIR) $(OBJ_DIR) $(OBJECTS) $(TARGET)

$(TARGET_DIR):
	mkdir $@

$(OBJ_DIR):
	mkdir $@

$(OBJECTS): %.o: $(SRC_DIR)/%.asm
	$(AS) -o $(OBJ_DIR)/$@ $< 

$(TARGET): $(patsubst %,$(OBJ_DIR)/%,$(OBJECTS))
	$(LD) -o $(TARGET_DIR)/$@ $^ --Ttext=0x7C00 --oformat=binary

$(QEMU_IMAGE):
	qemu-img create -f raw $@ 64k; \
		cat $(TARGET_DIR)/* > $@
 
.PHONY: clean test qemu
qemu: $(QEMU_IMAGE)
	qemu-system-i386 -nographic -drive file=$<,format=raw

test: clean all $(QEMU_IMAGE) qemu

clean:
	$(RM) -r $(TARGET_DIR) $(OBJ_DIR) $(QEMU_IMAGE)
