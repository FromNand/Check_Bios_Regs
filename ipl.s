# 自分用のメモ
# 上からeax, ecx, edx, ebx, esi, edi, ebp, esの順番で表示するが、cs, ds, ss, espについては表示することが(おそらく論理的に)できない。
# なぜなら、cs, ds, ss, espはプログラムの実行に最低限初期化が必要なものなので、プログラム開始時に初期化する必要があるからである。
# このプログラムでは"cs=ds=ss=0, esp=&storage+30"とはじめに初期化しているが、VMAはリンカスクリプトの方で調節している。
# ss=0, esp=&storage+30と初期化するのは、ssが変なところ(例えば、0x7c0とか)を指していると、場合によってはプログラムやデータを壊してしまう恐れがあるためである。
# cs, ds, ss, espを初期化せずにプログラムを書こうとした場合、どこかでレジスタの値を決めつける必要が出てくる。(これでは移植性に欠ける)
# 大抵のIPLではこれらのレジスタを始めに初期化するはずであるので知る必要がないと思われるが、一応複数の実機で調べたところ、dlとesp以外のレジスタのビットは大抵すべて0になっているようだ。



# Generate machine language for real mode.
.code16

# Place the program in the text area.
.text



start:					# Main function.
	sti				# In case Bios forgets to do sti.
	ljmpw	$0x0, $debug		# Set 0x7c0 to cs. (if you change init_regs part to debug, then you can debug this program.)

debug:					# You can debug this program by uncommenting this part.
	movl	$0x12345678, %eax
	movl	$0x87654321, %ecx
	movl	$0x12121212, %edx
	movl	$0x21212121, %ebx
	movl	$0x23456789, %esi
	movl	$0x98765432, %edi
	movl	$0x18273645, %ebp
	movw	%ax, %es

init_regs:
	xorw	%sp, %sp		# We can't use "movw $0x0, %ds" and "movw %cs, %ds" etc..., so we have to go through a general register when initializing the segment register.
	movw	%sp, %ds
	movw	%sp, %ss
	movw	$storage, %sp		# Storage variable is defined at the bottom of this source code.
	addw	$30, %sp		# Size of storage variable is 4*7+2*1=30. (The number of general registers is 7, and the number of segment registers is 1.)

save_regs:				# Since we saved the register in a storage variable, we are free to use the register from here.
	pushw	%es
	pushl	%ebp
	pushl	%edi
	pushl	%esi
	pushl	%ebx
	pushl	%edx
	pushl	%ecx
	pushl	%eax

init_stack:				# We are free to use the register from here.
	movw	$0x7c00, %sp		# The program is located from 0x7c00. We have to use a region with an address lower than 0x7c00 for the stack. ss:esp=0x0*0x10+0x7c00=0x7c00.

print_general_regs:			# Display in order of eax, ecx, edx, ebx, esi, edi, ebp. (seven registers)
	xorl	%ecx, %ecx		# ecx counts 7 of eax~ebp. (I use xorl because ecx is used in "movl (%ebx, %ecx, 4), %eax" part.)
	movl	$storage, %ebx		# ebx points to the start address of the storage variable. (I use movl because ebx is also used in "movl (%ebx, %ecx, 4), %eax" part.)
print_general_regs_loop:
	cmpw	$7, %cx			# Display 7 general-purpose registers: eax, ecx, edx, ebx, esi, edi, ebp.
	je	print_segment_regs	# If we are trying to display the 8th register, jump to the next step.
	movl	(%ebx, %ecx, 4), %eax	# When compared in C language, it means the same as "eax=storage[ecx];". (Because ebx points to the start address of the storage variable.)
	call	print_4byte_regs	# Since the general-purpose register is 4 bytes, call the function for displaying 4 bytes.
	incw	%cx			# ecx++
	jmp	print_general_regs_loop	# Return to the beginning of the loop.

print_segment_regs:			# Display es register.
	movl	(%ebx, %ecx, 4), %eax	# Get the value of es from storage variable as well as general-purpose register.
	call	print_2byte_regs	# Since es is 2 bytes, call the function for displaying 2 bytes.

fin:					# End of the program.
	hlt				# Stop CPU until interrupted.
	jmp	fin



print_2byte_regs:			# Receive the register value via eax.
	pushal				# Save all general-purpose registers.
	movb	$12, %cl		# How many bits to shift the register value right.
print_2byte_regs_loop:
	cmpb	$-4, %cl		# Equal if all digits are displayed.
	je	print_2byte_regs_end	# Jump to the process that ends the function.
	pushl	%eax			# Save eax.
	shrl	%cl, %eax		# Set the number of the specific digit to the lowest digit.
	andl	$0x0000000f, %eax	# Only set the number of the bottom digit to eax.
	cmpb	$10, %al		# If the number is greater than or equal to 10, then use A~F, if less than 10, use 0~9.
	jae	hex2			# Set A~F
	addb	$0x30, %al		# Add 0x30 to a number to get that number of ASCII codes.
	jmp	display2		# display 2byte-register
hex2:
	addb	$0x37, %al		# Add 0x37 to any number greater than or equal to 10 to get that number's hexadecimal ASCII code.
display2:
	movb	$0x0e, %ah
	movw	$0, %bx
	int	$0x10			# If you want to know the processing of these parts, see the "print_line_break" part below.
	subb	$4, %cl			# Decrement one digit to shift.
	popl	%eax			# Restore eax.
	jmp	print_2byte_regs_loop	# Jump to the beginning of the loop.
print_2byte_regs_end:
	call	print_line_break	# Display line feed and return.
	popal				# Restore all general-purpose registers.
	ret

print_4byte_regs:			# Receive the register value via eax.
	pushal				# Save all general-purpose registers.
	movb	$28, %cl		# How many bits to shift the register value right.
print_4byte_regs_loop:
	cmpb	$-4, %cl		# Equal if all digits are displayed.
	je	print_4byte_regs_end	# Jump to the process that ends the function.
	pushl	%eax			# Save eax.
	shrl	%cl, %eax		# Set the number of the specific digit to the lowest digit.
	andl	$0x0000000f, %eax	# Only set the number of the bottom digit to eax.
	cmpb	$10, %al		# If the number is greater than or equal to 10, then use A~F, if less than 10, use 0~9.
	jae	hex4			# Set A~F
	addb	$0x30, %al		# Add 0x30 to a number to get that number of ASCII codes.
	jmp	display4		# display 4byte-register
hex4:
	addb	$0x37, %al		# Add 0x37 to any number greater than or equal to 10 to get that number's hexadecimal ASCII code.
display4:
	movb	$0x0e, %ah
	movw	$0, %bx
	int	$0x10			# If you want to know the processing of these parts, see the "print_line_break" part below.
	subb	$4, %cl			# Decrement one digit to shift.
	popl	%eax			# Restore eax.
	jmp	print_4byte_regs_loop	# Jump to the beginning of the loop.
print_4byte_regs_end:
	call	print_line_break	# Display line feed and return.
	popal				# Restore all general-purpose registers.
	ret

# Using the one-character display BIOS service, line feed/return is performed.
# You can display one character by setting ah = 0x0e, al = character-code, bh = 0, bl = color-code and then calling int 0x10.
# Since this function is supposed to be called from the print_regs system function, pushal and popal are not performed.
print_line_break:
	movw	$0x0e0d, %ax		# Line feed is 0x0d.
	movw	$0x0, %bx
	int	$0x10
	movw	$0x0e0a, %ax		# Return is 0x0a.
	movw	$0x0, %bx
	int	$0x10			# Call the one-character display BIOS service.
	ret



# Used to store the value of a register.
# Size of storage variable is 4*7+2*1=30. (The number of general registers is 7, and the number of segment registers is 1.)
storage:
	.skip	30, 0x00
