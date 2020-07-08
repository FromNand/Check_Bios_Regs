SRC=ipl.s
LS=ipl.ls
IMG=DEBUG.img

.SILENT:

img: $(SRC) $(LS)
	gcc -nostdlib -T$(LS) $(SRC) -o $(IMG)

run: img
	qemu-system-i386 -fda $(IMG)						# Boot from FDD.
	qemu-system-i386 -drive file=$(IMG),format=raw,index=0,media=disk	# Boot from HDD.

clean:
	rm -f $(IMG)
