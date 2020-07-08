# 「eax, ecx, edx, ebx, esi, edi, ebp, es」の順番で表示するが、cs, ds, ss, espについてはうまく表示できない。
# このプログラムでは、'cs=0' 'ds=0' 'ss=0' 'esp=&storage+30'と仮定する。
# cs=0, ds=0と仮定するのは、IPLに使用するリンカスクリプトのVMAを定義するため。
# ss=0, esp=&storage+30と仮定するのは、スタック領域が変なところを指しているとがプログラムやデータを壊してしまう恐れがあるためである。
# これらを仮定せずにプログラムを実行しようとした場合、必ずbios依存の動作が発生するか、bios直後のレジスタの値を決めつけておく必要が出てくる。
# 大抵のIPLではこれらのレジスタを始めに初期化するはずであるが、複数機種で調べたところ、dlとesp以外のレジスタのビットは大抵すべて0になっているようだ。

# リアルモード用の機械語を生成する。
.code16

# テキスト領域にプログラムを配置する。
.text

# スタックがプログラムを書き換えてしまわないように、cs=0, ds=0, ss=0に初期化する。
	sti
	ljmpw	$0x0, $init_regs
init_regs:
#	movl	$0x12345678, %eax
#	movl	$0x87654321, %ecx
#	movl	$0x12121212, %edx
#	movl	$0x21212121, %ebx
#	movl	$0x23456789, %esi
#	movl	$0x98765432, %edi
#	movl	$0x18273645, %ebp
#	movw	%ax, %es

	xorw	%sp, %sp
	movw	%sp, %ds
	movw	%sp, %ss
	movw	$storage, %sp
	addw	$30, %sp

push_regs:
	pushw	%es
	pushl	%ebp
	pushl	%edi
	pushl	%esi
	pushl	%ebx
	pushl	%edx
	pushl	%ecx
	pushl	%eax

# ここからは、cs, ds, ss, esp以外のレジスタも自由に使って良い。
reinit_stack:
	movw	$0x7c00, %sp

# eax, ecx, edx, ebx, esi, edi, ebpの順番に表示する。
print_general_regs:
	xorl	%ecx, %ecx		# 7つのレジスタ分カウントする(movl (%ebx, %ecx, 4), %eax の部分でecxを使用するので、4byte命令にしている)
	movl	$storage, %ebx		# ebxはレジスタの値が保存されているメモリの先頭アドレスを指す(movl (%ebx, %ecx, 4), %eax の部分でecxを使用するので、4byte命令にしている)
print_general_regs_loop:
	cmpw	$7, %cx			# 汎用レジスタはeax, ecx, edx, ebx, esi, edi, ebpの7つを表示する
	je	print_segment_regs	# もし、8つ目のレジスタを表示しようとしていたら、次の処理にジャンプする
	movl	(%ebx, %ecx, 4), %eax	# C言語でいう「eax=storage[ecx];」と同じ意味(storageは符号なしintの配列ね)
	call	print_regs4		# 汎用レジスタは4byteなので、4バイト表示用の関数を呼び出す
	incw	%cx			# 次のレジスタを指すようにカウンタを進める
	jmp	print_general_regs_loop	# ループの始めに戻る

print_segment_regs:
	movl	(%ebx, %ecx, 4), %eax	# 汎用レジスタと同様にストレージからesの値を取得する
	call	print_regs2		# esは2byteなので、2バイト表示用の関数を呼び出す

fin:
	hlt
	jmp	fin

print_regs2:
	pushal
	andl	$0x0000ffff, %eax
	movb	$12, %cl
print_regs2_loop:
	cmpb	$-4, %cl
	je	print_regs2_end
	pushl	%eax
	shrl	%cl, %eax
	andl	$0x0000000f, %eax
	cmpb	$10, %al
	jae	hex2
	addb	$0x30, %al
	jmp	show2
hex2:
	addb	$0x37, %al
show2:
	movb	$0x0e, %ah
	movw	$0, %bx
	int	$0x10
	subb	$4, %cl
	popl	%eax
	jmp	print_regs2_loop
print_regs2_end:
	call	show_CRLF
	popal
	ret

print_regs4:
	pushal
	movb	$28, %cl
print_regs4_loop:
	cmpb	$-4, %cl
	je	print_regs4_end
	pushl	%eax
	shrl	%cl, %eax
	andl	$0x0000000f, %eax
	cmpb	$10, %al
	jae	hex4
	addb	$0x30, %al
	jmp	show4
hex4:
	addb	$0x37, %al
show4:
	movb	$0x0e, %ah
	movw	$0, %bx
	int	$0x10
	subb	$4, %cl
	popl	%eax
	jmp	print_regs4_loop
print_regs4_end:
	call	show_CRLF
	popal
	ret

# 一文字表示のBIOSサービスを使って、復帰と改行を行っている。
# ah=0x0e, al=文字コード, bh=0, bl=カラーコード。
# この関数はshow_register系関数から呼ばれることを前提としているので、pushal・popalは行っていない。
show_CRLF:
	movw	$0x0e0d, %ax
	movw	$0x0, %bx
	int	$0x10
	movw	$0x0e0a, %ax
	movw	$0x0, %bx
	int	$0x10
	ret

# レジスタの値の保管に使用される(4*7+2*1=30byte)
storage:
	.skip	30, 0x00
