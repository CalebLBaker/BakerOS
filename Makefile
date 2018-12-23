PREFIX:=${HOME}/opt/cross
TARGET:=x86_64-elf
PATH:="${PREFIX}/bin:${PATH}"
CROSS_COMP_FLAGS:=--target=${TARGET} --prefix="${PREFIX}" --disable-nls
CC:=${PREFIX}/bin/${TARGET}-gcc
AS:=${PREFIX}/bin/${TARGET}-as

C_SOURCES = $(wildcard src/*.c)
ASM_SOURCES = $(wildcard src/*.s)
HEADERS = $(wildcard src/*.h)

C_OBJ = ${C_SOURCES:.c=.o}
ASM_OBJ = ${ASM_SOURCES:.s=.o}
OBJ = ${C_OBJ} ${ASM_OBJ}
CFLAGS = -g -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -c
ASMFLAGS = -g

all: .attach

run: .attach
	VBoxManage startvm Buttaire

debug: buttaire.iso
	qemu-system-x86_64 -s -S -cdrom $< &
	sleep 1
	gdb -ex "target remote localhost:1234" -ex "symbol-file root/boot/buttaire.elf"

.attach: buttaire.vdi .vm
	VBoxManage storageattach Buttaire --storagectl SATA --port 0 --device 0 --type hdd --medium $<
	touch $@

buttaire.vdi: buttaire.iso .deleteDisk.sh .vm
	chmod +x .deleteDisk.sh
	./.deleteDisk.sh
	VBoxManage convertfromraw $< $@ --format VDI

.vm:
	VBoxManage createvm --name Buttaire --ostype Other_64 --register
	VBoxManage storagectl Buttaire --name SATA --add sata --controller IntelAHCI
	touch $@

cross-compiler/binutils-2.31.tar.gz:
	wget https://ftp.gnu.org/gnu/binutils/binutils-2.31.tar.gz
	mv binutils-2.31.tar.gz $@

cross-compiler/binutils-2.31: cross-compiler/binutils-2.31.tar.gz
	tar xf $<

cross-compiler/build-binutils: cross-compiler/binutils-2.31
	mkdir $@
	cd $@ && ../binutils-2.31/configure ${CROSS_COMP_FLAGS} --with-sysroot --disable-werror && make && make install

cross-compiler/gcc-8.2.0.tar.gz:
	wget https://ftp.gnu.org/gnu/gcc/gcc-8.2.0/gcc-8.2.0.tar.gz
	mv gcc-8.2.0.tar.gz $@

cross-compiler/gcc-8.2.0: cross-compiler/gcc-8.2.0.tar.gz cross-compiler/t-x86_64-elf cross-compiler/config.gcc
	tar xf $<
	cp cross-compiler/t-x86_64-elf $@/gcc/config/i386/
	cp cross-compiler/config.gcc $@/gcc/

cross-compiler/build-gcc: cross-compiler/gcc-8.2.0 build-binutils
	mkdir $@
	cd $@ && ../gcc-8.2.0/configure ${CROSS_COMP_FLAGS} --enable-languages=c,c++ --without-headers && make all-gcc && make all-target-libgcc && make install-gcc && make install-target-libgcc
	touch .tools

%.o: %.c ${HEADERS}
	${CC} ${CFLAGS} $< -o $@

%.o: %.s
	${AS} ${ASMFLAGS} $< -o $@

root/boot/buttaire.elf: link.ld ${OBJ}
	${CC} -ffreestanding -T $^ -nostdlib -lgcc -o $@ -z max-page-size=0x1000

buttaire.iso: root/boot/buttaire.elf root/boot/grub/grub.cfg
	grub-mkrescue -o $@ root

clean:
	./.deleteDisk.sh
	rm -f *.iso src/*.o root/boot/*.elf cross-compiler/*.tar.gz
	rm -rf cross-compiler/binutils-2.31.1
	rm -rf cross-compiler/gcc-8.2.0
	rm -rf cross-compiler/build-*

