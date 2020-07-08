★ I'm Japanese, so I'm sorry if I wrote difficult English ★

【About】
This program displays value of registers right after bios program. (but only for x86 architecture)
From top to bottom are "EAX, ECX, EDX, EBX, ESI, EDI, EBP, ES".
The values of CS, DS, SS and ESP cannot be displayed. (These registers are modified by displaying their own value, unfortunately.)
I thought this program can be used on various boot disk. (e.g. HDD, Floppy, USB, CDROM...)

【How to use】
First, if you execute "make" in "Check_Bios_Regs" directory, an image file called DEBUG.img will be created.
Then somehow write DEBUG.img to the first sector of the boot disk. (e.g. dd command)
Finally, after setting the startup disk priority with Bios, start the PC.
If you are trying to boot from a CD and you get an error with the CD burning tool, try using check_bios_regs_for_cd.img.

【このプログラムについて】
BIOSから起動した直後のレジスタの内容を表示するプログラム。
上から順番に「EAX, ECX, EDX, EBX, ESI, EDI, EBP, ES」を表示します。
残念ながら、CS, DS, SS, ESPの値は表示することができないです。(これらのレジスタは自らの値を表示するために変更されてしまうからです)
起動ディスクは選ばないはずです。USBとCD-RWからの起動については実機2つで確認済みです。おそらく、ハードディスクやフロッピーディスク、USB、CDROMなど、あらゆるディスクから起動可能だと思います。
プログラムの内容について知りたい方はipl.sを読んでもらうといいと思います。

【使い方】
まず、Check_Bios_Regsディレクトリに移動した後、「make」を行い、check_bios_regs.imgを作成します。
次に何らかの方法で起動ディスクの先頭セクタにcheck_bios_regs.imgを書き込みます。(ddコマンドなど)
最後にBiosで起動ディスクのプライオリティーを設定した後、PCを起動します。
もしあなたがCDを用いたブートを行おうとしていて、CDに焼くためのツールにエラーが発生する場合はcheck_bios_regs_for_cd.imgを使用してみてください。

【作者メモ】
・USBについてはRufusで単純に書き込めば良い
・CDについては少し勝手が違っていて、fdtoisoを経由してBurnAwareなどで焼かないといけない
　fdtoisoは1440KBのOSイメージしか受け付けないので、DEBUG.img(512byte)では容量が足りない(たとえ、そのOSイメージがqemuでの起動に成功していたとしても)
　なので1440KBになるまでなんらかのデータでかさ増しする必要がある
　この場合は、例えば「dd if=DEBUG.img of=DEBUG2.img」→「dd seek=1 bs=512 count=2879 if=/dev/zero of=DEBUG2.img」などとして1440KBにかさ増しすることができる
　自作ツールなどを用いて直接CDの先頭セクタにOSイメージを書き込めるのなら512byteでも起動できるのだとは思うが、他人のツールに頼っている以上仕方ない
　この点、USBに焼くためのツールであるRufusは非常に優秀でありがたい
