ASSEMBLER = yasm
LINKER = ld
FORMAT = elf64
CODE = Main.asm
OBJECT = Main.o
EXECUTABLE = Main

all: $(CODE)
	$(ASSEMBLER) $(CODE) -f $(FORMAT) -o $(OBJECT)
	$(LINKER) $(OBJECT) -o $(EXECUTABLE)
	@echo "Assembled and linked to $(EXECUTABLE).\nDo ./$(EXECUTABLE) to run it."

