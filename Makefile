# $@ = target file
# $< = first dependency
# $^ = all dependencies

# First rule is the one executed when no parameters are fed to the Makefile

buttaire.bin: boot.bin kernel.bin
	cat $^ > $@

kernel.bin: kernelEntry.o kernel.o
	ld -o $@ -Ttext 0x500 $^ --oformat binary

kernel.elf: kernelEntry.o kernel.o
	ld -o $@ -Ttext 0x500 $^

kernelEntry.o: kernelEntry.s
	nasm $< -f elf64 -o $@

kernel.o: kernel.c
	gcc -g -ffreestanding -c $< -o $@

# Rule to disassemble the kernel - may be useful to debug
kernel.dis: kernel.bin
	ndisasm -b 64 $< > $@

boot.bin: boot.s
	nasm $< -f bin -o $@

all: run

run: buttaire.bin
	qemu-system-x86_64 -fda $<

debug: buttaire.bin kernel.elf
	qemu-system-x86_64 -s -fda bakeros.bin &
	gdb -ex "target remote localhost:1234" -ex "symbol-file kernel.elf"

clean:
	rm *.bin *.o *.dis *.elf
