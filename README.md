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

【このプログラムについて】
BIOSから起動した直後のレジスタの内容を表示するプログラム。
上から順番に「EAX, ECX, EDX, EBX, ESI, EDI, EBP, ES」を表示します。
残念ながら、CS, DS, SS, ESPの値は表示することができないです。(これらのレジスタは自らの値を表示するために変更されてしまうからです)
起動ディスクは選ばないはずです。(ハードディスクやフロッピーディスク、USB、CDROMなど、あらゆるディスクから起動可能だと思います)
プログラムの内容について知りたい方はipl.sを読んでもらうといいと思います。

【使い方】
まず、Check_Bios_Regsディレクトリに移動した後、「make」を行い、DEBUG.imgを作成します。
次に何らかの方法で起動ディスクの先頭セクタにDEBUG.imgを書き込みます。(ddコマンドなど)
最後にBiosで起動ディスクのプライオリティーを設定した後、PCを起動します。
