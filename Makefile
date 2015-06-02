ENSAMBLADOR = yasm
LINKER = ld
FORMATO = elf64
CODIGO = Main.asm
OBJETO = Main.o
EJECUTABLE = Main

all: $(CODIGO)
	$(ENSAMBLADOR) $(CODIGO) -f $(FORMATO) -o $(OBJETO)
	$(LINKER) $(OBJETO) -o $(EJECUTABLE)
	@echo "Se ensamblo y vinculo al ejecutable $(EJECUTABLE).\nHaga ./$(EJECUTABLE) para correr."

