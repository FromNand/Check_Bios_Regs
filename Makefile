SRC=ipl.s
LS=ipl.ls
IMG=DEBUG.img

img: $(SRC) $(LS)
	@gcc -nostdlib -T$(LS) $(SRC) -o $(IMG)

run: $(IMG)
	qemu-system-i386 -fda $?				# FDDから起動
	@@qemu-system-i386 -hda $?				# HDDから起動
	@@qemu-system-i386 -cdrom $?				# CDROMから起動

clean:
	@rm -f $(IMG)
