SRC=check_bios_regs.s			# ソースコード
LS=check_bios_regs.ls			# リンカスクリプト
GENERAL_IMG=check_bios_regs.img		# 普通はこのイメージを各起動ディスクの先頭セクタに書き込めば良い
CD_IMG=check_bios_regs_for_cd.img	# CDブートにおいてfdtoisoやBurnAwareを使う場合などに、イメージファイルが1440KBでないといけないことがあるので仕方なく用意しておいた

.SILENT:

img: $(SRC) $(LS)
	gcc -nostdlib -T$(LS) $(SRC) -o $(GENERAL_IMG)
	dd if=$(GENERAL_IMG) of=$(CD_IMG)
	dd seek=1 bs=512 count=2879 if=/dev/zero of=$(CD_IMG)

run: img
	qemu-system-i386 -fda $(GENERAL_IMG)				# Boot from FDD.
	qemu-system-i386 -hda $(GENERAL_IMG)				# Boot from HDD.
	qemu-system-i386 -fda $(CD_IMG)					# Boot from FDD.
	qemu-system-i386 -hda $(CD_IMG)					# Boot from HDD.

clean:
	rm -f $(GENERAL_IMG) $(CD_IMG)
