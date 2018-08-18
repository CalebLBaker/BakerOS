PREFIX:=${HOME}/opt/cross
TARGET:=x86_64-elf
PATH:="${PREFIX}/bin:${PATH}"
CROSS_COMP_FLAGS:=--target=${TARGET} --prefix="${PREFIX}" --disable-nls
CC:=${PREFIX}/bin/${TARGET}-gcc
AS:=${PREFIX}/bin/${TARGET}-as

C_SOURCES = $(wildcard src/*.c)
ASM_SOURCES = $(wildcard src/*.S)
HEADERS = $(wildcard src/*.h)

C_OBJ = ${C_SOURCES:.c=.o}
PREPROCESSED = ${ASM_SOURCES:.S=.s}
ASM_OBJ = ${PREPROCESSED:.s=.o}
OBJ = ${C_OBJ} ${ASM_OBJ}
C_FLAGS = -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -c

all: buttaire.iso

cross-compiler/binutils-2.31.tar.gz:
	cd cross-compiler
	wget https://ftp.gnu.org/gnu/binutils/binutils-2.31.tar.gz

cross-compiler/binutils-2.31: cross-compiler/binutils-2.31.tar.gz
	tar xf $<

cross-compiler/build-binutils: cross-compiler/binutils-2.31
	mkdir $@
	cd $@
	../$</configure ${CROSS_COMP_FLAGS} --with-sysroot --disable-werror
	make 
	make install

cross-compiler/gcc-8.2.0: cross-compiler/gcc-8.2.0.tar.gz
	tar xf $<

cross-compiler/build-gcc: cross-compiler/gcc-8.2.0 build-binutils
	mkdir $@
	cd $@
	../$</configure ${CROSS_COMP_FLAGS} --enable-languages=c,c++ --without-headers
	make all-gcc
	make all-target-libgcc
	make install-gcc
	make install-target-libgcc

%.s: %.S ${HEADERS}
	cpp $< > $@

%.o: %.c ${HEADERS}
	${CC} ${C_FLAGS} $< -o $@

%.o: %.s
	${AS} $< -o $@

iso/boot/buttaire.elf: link.ld ${OBJ}
	${CC} -ffreestanding -T $^ -nostdlib -lgcc -o $@ -z max-page-size=0x1000

buttaire.iso: iso/boot/buttaire.elf iso/boot/grub/grub.cfg
	grub-mkrescue -o $@ iso

clean:
	rm -f *.iso src/*.s src/*.o iso/boot/*.elf
	rm -rf cross-compiler/binutils-2.31.1
	rm -rf cross-compiler/gcc-8.2.0
	rm -rf cross-compiler/build-*

