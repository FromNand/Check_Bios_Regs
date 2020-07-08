SRC=ipl.s
LS=ipl.ls
IMG=DEBUG.img

.SILENT:

$(IMG): $(SRC) $(LS)
	gcc -nostdlib -T$(LS) $(SRC) -o $(IMG)

run: $(IMG)
	qemu-system-i386 -fda $(IMG)				# FDD
	qemu-system-i386 -hda $(IMG)				# HDD
	qemu-system-i386 -cdrom $(IMG)				# CDROM

clean: $(IMG)
	rm -f $(IMG)
