;************************************************************************
;	BIOSでロードされる最初のセクタ
;	
;	プログラム全体を通して、セグメントの値は0x0000とする。
;	(DS==ES==0)
;	
;************************************************************************

;************************************************************************
;	マクロ
;************************************************************************
%include	"../include/define.s"
%include	"../include/macro.s"

		ORG		BOOT_LOAD						; ロードアドレスをアセンブラに指示

;************************************************************************
;	エントリポイント
;************************************************************************
entry:
		;---------------------------------------
		; BPB(BIOS Parameter Block)
		;---------------------------------------
		jmp		ipl								; 0x00( 3) ブートコードへのジャンプ命令
		times	3 - ($ - $$) db 0x90			; 
		db		'OEM-NAME'						; 0x03( 8) OEM名
												; -------- --------------------------------
		dw		512								; 0x0B( 2) セクタのバイト数
		db		1								; 0x0D( 1) クラスタのセクタ数
		dw		32								; 0x0E( 2) 予約セクタ数
		db		2								; 0x10( 1) FAT数
		dw		512								; 0x11( 2) ルートエントリ数
		dw		0xFFF0							; 0x13( 2) 総セクタ数16
		db		0xF8							; 0x15( 1) メディアタイプ
		dw		256								; 0x16( 2) FATのセクタ数
		dw		0x10							; 0x18( 2) トラックのセクタ数
		dw		2								; 0x1A( 2) ヘッド数
		dd		0								; 0x1C( 4) 隠されたセクタ数
												; -------- --------------------------------
		dd		0								; 0x20( 4) 総セクタ数32
		db		0x80							; 0x24( 1) ドライブ番号
		db		0								; 0x25( 1) （予約）
		db		0x29							; 0x26( 1) ブートフラグ
		dd		0xbeef							; 0x27( 4) シリアルナンバー
		db		'BOOTABLE   '					; 0x2B(11) ボリュームラベル
		db		'FAT16   '						; 0x36( 8) FATタイプ

		;---------------------------------------
		; IPL(Initial Program Loader)
		;---------------------------------------
ipl:
		cli										; // 割り込み禁止

		mov		ax, 0x0000						; AX = 0x0000;
		mov		ds, ax							; DS = 0x0000;
		mov		es, ax							; ES = 0x0000;
		mov		ss, ax							; SS = 0x0000;
		mov		sp, BOOT_LOAD					; SP = 0x7C00;

		sti										; // 割り込み許可

		mov		[BOOT + drive.no], dl			; ブートドライブを保存

		;---------------------------------------
		; 文字列を表示
		;---------------------------------------
		cdecl	puts, .s0						; puts(.s0);

		;---------------------------------------
		; 残りのセクタを全て読み込む
		;---------------------------------------
		mov		bx, BOOT_SECT - 1				; BX = 残りのブートセクタ数;
		mov		cx, BOOT_LOAD + SECT_SIZE		; CX = 次のロードアドレス;

		cdecl	read_chs, BOOT, bx, cx			; AX = read_chs(.chs, bx, cx);

		cmp		ax, bx							; if (AX != 残りのセクタ数)
.10Q:	jz		.10E							; {
.10T:	cdecl	puts, .e0						;   puts(.e0);
		call	reboot							;   reboot(); // 再起動
.10E:											; }

		;---------------------------------------
		; 次のステージへ移行
		;---------------------------------------
		jmp		stage_2							; ブート処理の第2ステージ

		;---------------------------------------
		; データ
		;---------------------------------------
.s0		db	"Booting...", 0x0A, 0x0D, 0
.e0		db	"Error:sector read", 0

;************************************************************************
;	ブートドライブに関する情報
;************************************************************************
ALIGN 2, db 0
BOOT:											; ブートドライブに関する情報
	istruc	drive
		at	drive.no,		dw	0				; ドライブ番号
		at	drive.cyln,		dw	0				; C:シリンダ
		at	drive.head,		dw	0				; H:ヘッド
		at	drive.sect,		dw	2				; S:セクタ
	iend

;************************************************************************
;	モジュール
;************************************************************************
%include	"../modules/real/puts.s"
%include	"../modules/real/reboot.s"
%include	"../modules/real/read_chs.s"

;************************************************************************
;	ブートフラグ（先頭512バイトの終了）
;************************************************************************
		times	510 - ($ - $$) db 0x00
		db	0x55, 0xAA

;************************************************************************
;	リアルモード時に取得した情報
;************************************************************************
FONT:											; フォント
.seg:	dw	0
.off:	dw	0
ACPI_DATA:										; ACPI data
.adr:	dd	0									; ACPI data address
.len:	dd	0									; ACPI data length

;************************************************************************
;	モジュール（先頭512バイト以降に配置）
;************************************************************************
%include	"../modules/real/itoa.s"
%include	"../modules/real/get_drive_param.s"
%include	"../modules/real/get_font_adr.s"
%include	"../modules/real/get_mem_info.s"
%include	"../modules/real/kbc.s"
%include	"../modules/real/lba_chs.s"
%include	"../modules/real/read_lba.s"
%include	"../modules/real/memcpy.s"
%include	"../modules/real/memcmp.s"

;************************************************************************
;	ブート処理の第2ステージ
;************************************************************************
stage_2:
		;---------------------------------------
		; 文字列を表示
		;---------------------------------------
		cdecl	puts, .s0						; puts(.s0);

		;---------------------------------------
		; ドライブ情報を取得
		;---------------------------------------
		cdecl	get_drive_param, BOOT			; get_drive_param(DX, BOOT.CYLN);
		cmp		ax, 0							; if (0 == AX)
.10Q:	jne		.10E							; {
.10T:	cdecl	puts, .e0						;   puts(.e0);
		call	reboot							;   reboot(); // 再起動
.10E:											; }

		;---------------------------------------
		; ドライブ情報を表示
		;---------------------------------------
		mov		ax, [BOOT + drive.no]			; AX = ブートドライブ;
		cdecl	itoa, ax, .p1, 2, 16, 0b0100	; 
		mov		ax, [BOOT + drive.cyln]			; 
		cdecl	itoa, ax, .p2, 4, 16, 0b0100	; 
		mov		ax, [BOOT + drive.head]			; AX = ヘッド数;
		cdecl	itoa, ax, .p3, 2, 16, 0b0100	; 
		mov		ax, [BOOT + drive.sect]			; AX = トラックあたりのセクタ数;
		cdecl	itoa, ax, .p4, 2, 16, 0b0100	; 
		cdecl	puts, .s1

		;---------------------------------------
		; 次のステージへ移行
		;---------------------------------------
		jmp		stage_3rd						; 次のステージへ移行

		;---------------------------------------
		; データ
		;---------------------------------------
.s0		db	"2nd stage...", 0x0A, 0x0D, 0

.s1		db	" Drive:0x"
.p1		db	"  , C:0x"
.p2		db	"    , H:0x"
.p3		db	"  , S:0x"
.p4		db	"  ", 0x0A, 0x0D, 0

.e0		db	"Can't get drive parameter.", 0

;************************************************************************
;	ブート処理の第3ステージ
;************************************************************************
stage_3rd:
		;---------------------------------------
		; 文字列を表示
		;---------------------------------------
		cdecl	puts, .s0

		;---------------------------------------
		; プロテクトモードで使用するフォントは、
		; BIOSに内蔵されたものを流用する
		;---------------------------------------
		cdecl	get_font_adr, FONT				; // BIOSのフォントアドレスを取得

		;---------------------------------------
		; フォントアドレスの表示
		;---------------------------------------
		cdecl	itoa, word [FONT.seg], .p1, 4, 16, 0b0100
		cdecl	itoa, word [FONT.off], .p2, 4, 16, 0b0100
		cdecl	puts, .s1

		;---------------------------------------
		; メモリ情報の取得と表示
		;---------------------------------------
		cdecl	get_mem_info					; get_mem_info();

		mov		eax, [ACPI_DATA.adr]			; EAX = ACPI_DATA.adr;
		cmp		eax, 0							; if (EAX)
		je		.10E							; {

		cdecl	itoa, ax, .p4, 4, 16, 0b0100	;   itoa(AX); // 下位アドレスを変換
		shr		eax, 16							;   EAX >>= 16;
		cdecl	itoa, ax, .p3, 4, 16, 0b0100	;   itoa(AX); // 上位アドレスを変換

		cdecl	puts, .s2						;   puts(.s2); // アドレスを表示
.10E:											; }

		;---------------------------------------
		; 次のステージへ移行
		;---------------------------------------
		jmp		stage_4							; 次のステージへ移行

		;---------------------------------------
		; データ
		;---------------------------------------
.s0:	db	"3rd stage...", 0x0A, 0x0D, 0

.s1:	db	" Font Address="
.p1:	db	"ZZZZ:"
.p2:	db	"ZZZZ", 0x0A, 0x0D, 0
		db	0x0A, 0x0D, 0

.s2:	db	" ACPI data="
.p3:	db	"ZZZZ"
.p4:	db	"ZZZZ", 0x0A, 0x0D, 0

;************************************************************************
;	ブート処理の第4ステージ
;************************************************************************
stage_4:
		;---------------------------------------
		; 文字列を表示
		;---------------------------------------
		cdecl	puts, .s0

		;---------------------------------------
		; A20ゲートの有効化
		;---------------------------------------
		cli										;   // 割り込み禁止
												;   
		cdecl	KBC_Cmd_Write, 0xAD				;   // キーボード無効化
												;   
		cdecl	KBC_Cmd_Write, 0xD0				;   // 出力ポート読み出しコマンド
		cdecl	KBC_Data_Read, .key				;   // 出力ポートデータ
												;   
		mov		bl, [.key]						;   BL  = key;
		or		bl, 0x02						;   BL |= 0x02; // A20ゲート有効化
												;   
		cdecl	KBC_Cmd_Write, 0xD1				;   // 出力ポート書き込みコマンド
		cdecl	KBC_Data_Write, bx				;   // 出力ポートデータ
												;   
		cdecl	KBC_Cmd_Write, 0xAE				;   // キーボード有効化
												;   
		sti										;   // 割り込み許可

		;---------------------------------------
		; キーボードLEDのテスト
		;---------------------------------------
		mov		bx, 0							; CX = LEDの初期値;
.10L:											; do
												; {
		mov		ah, 0x00						;   // キー入力待ち
		int		0x16							;   AL = BIOS(0x16, 0x00);
												;   
		cmp		al, '1'							;   if (AL < '1')
		jb		.10E							;     break;
												;   
		cmp		al, '3'							;   if ('3' < AL)
		ja		.10E							;     break;
												;   
		mov		cl, al							;   CL   = キー入力;
		dec		cl								;   CL  -= 1;       // 1減算
		and		cl, 0x03						;   CL  &= 0x03;    // 0〜2に制限
		mov		ax, 0x0001						;   AX   = 0x0001;  // ビット変換用
		shl		ax, cl							;   AX <<= CL;      // 0〜2ビット左シフト
		xor		bx, ax							;   BX  ^= AX;      // ビット反転

		;---------------------------------------
		; LEDコマンドの送信
		;---------------------------------------
		cli										;   // 割り込み禁止
												;   
		cdecl	KBC_Cmd_Write, 0xAD				;   // キーボード無効化
												;   
		cdecl	KBC_Data_Write, 0xED			;   // LEDコマンド
		cdecl	KBC_Data_Read, .key				;   // 受信応答
												;   
		cmp		[.key], byte 0xFA				;   if (0xFA == key)
		jne		.11F							;   {
												;     
		cdecl	KBC_Data_Write, bx				;     // LEDデータ出力
												;   }
		jmp		.11E							;   else
.11F:											;   {
		cdecl	itoa, word [.key], .e1, 2, 16, 0b0100
		cdecl	puts, .e0						;     // 受信コードを表示
.11E:											;   }
												;   
		cdecl	KBC_Cmd_Write, 0xAE				;   // キーボード有効化
												;   
		sti										;   // 割り込み許可
												;   
		jmp		.10L							; } while (1);
.10E:

		;---------------------------------------
		; 文字列を表示
		;---------------------------------------
		cdecl	puts, .s1

		;---------------------------------------
		; 次のステージへ移行
		;---------------------------------------
		jmp		stage_5							; 次のステージへ移行

.s0:	db	"4th stage...", 0x0A, 0x0D, 0
.s1:	db	" A20 Gate Enabled.", 0x0A, 0x0D, 0
.e0:	db	"["
.e1:	db	"ZZ]", 0

.key:	dw	0

;************************************************************************
;	ブート処理の第5ステージ
;************************************************************************
stage_5:
		;---------------------------------------
		; 文字列を表示
		;---------------------------------------
		cdecl	puts, .s0

		;---------------------------------------
		; カーネルを読み込む
		;---------------------------------------
		cdecl	read_lba, BOOT, BOOT_SECT, KERNEL_SECT, BOOT_END
												; AX = read_lba(.lba, ...);
		cmp		ax, KERNEL_SECT					; if (AX != CX)
.10Q:	jz		.10E							; {
.10T:	cdecl	puts, .e0						;   puts(.e0);
		call	reboot							;   reboot(); // 再起動
.10E:											; }
												; 

		;---------------------------------------
		; 次のステージへ移行
		;---------------------------------------
		jmp		stage_6							; 次のステージへ移行

.s0		db	"5th stage...", 0x0A, 0x0D, 0
.e0		db	" Failure load kernel...", 0x0A, 0x0D, 0

;************************************************************************
;	ブート処理の第6ステージ
;************************************************************************
stage_6:
		;---------------------------------------
		; 文字列を表示
		;---------------------------------------
		cdecl	puts, .s0

		;---------------------------------------
		; ユーザーからの入力待ち
		;---------------------------------------
.10L:											; do
												; {
		mov		ah, 0x00						;   // キー入力待ち
		int		0x16							;   AL = BIOS(0x16, 0x00);
		cmp		al, ' '							;   ZF = AL == ' ';
		jne		.10L							; } while (!ZF);
												; 

		;---------------------------------------
		; ビデオモードの設定
		;---------------------------------------
		mov		ax, 0x0012						; VGA 640x480
		int		0x10							; BIOS(0x10, 0x12); // ビデオモードの設定

		;---------------------------------------
		; 次のステージへ移行
		;---------------------------------------
		jmp		stage_7							; 次のステージへ移行

.s0		db	"6th stage...", 0x0A, 0x0D, 0x0A, 0x0D
		db	" [Push SPACE key to protect mode...]", 0x0A, 0x0D, 0

;************************************************************************
;	ファイル読み込み
;************************************************************************
read_file:
		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	ax
		push	bx
		push	cx

		;---------------------------------------
		; デフォルトの文字列を設定
		;---------------------------------------
		cdecl	memcpy, 0x7800, .s0, .s1 - .s0

		;---------------------------------------
		; 
		; 
		;          |____________| 
		; 0000_7600|            | FAT用バッファ
		;          =            = 
		;          |____________| 
		; 0000_7800|            | データ用バッファ
		;          =            = 
		;          |____________| 
		; 0000_7A00|            | スタック
		;          =            = 
		;          |____________| 
		; 0000_7C00|            | ブート
		;          =            = 
		;          |____________| 
		;          |////////////| 
		;          |            | 
		;---------------------------------------

		;---------------------------------------
		; ルートディレクトリのセクタを読み込む
		;---------------------------------------
		mov		bx, 32 + 256 + 256				; BX = ディレクトリエントリの先頭セクタ
		mov		cx, (512 * 32) / 512			; CX = 512エントリ分のセクタ数
.10L:											; do
												; {
		;---------------------------------------
		; 1セクタ（16エントリ）分を読み込む
		;---------------------------------------
		cdecl	read_lba, BOOT, bx, 1, 0x7600	;   AX = read_lba();
		cmp		ax, 0							;   if (0 == AX)
		je		.10E							;     break;

		;---------------------------------------
		; ディレクトリエントリからファイル名を検索
		;---------------------------------------
		cdecl	fat_find_file					;     AX = ファイルの検索
		cmp		ax, 0							;     if (AX)
		je		.12E							;     {
												;       
		add		ax, 32 + 256 + 256 + 32 - 2		;       // セクタ位置にオフセットを加算
		cdecl	read_lba, BOOT, ax, 1, 0x7800	;       read_lba() // ファイルの読み込み
												;       
		jmp		.10E							;       break;
.12E:											;     }
		inc		bx								;     BX++; //次のセクタ（16エントリ）
		loop	.10L							;   
.10E:											; } while (--CX);

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		cx
		pop		bx
		pop		ax

		ret

.s0:	db		'File not found.', 0
.s1:

;************************************************************************
;	1セクタ分のディレクトリエントリからファイル名を検索
;************************************************************************
fat_find_file:
		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	bx
		push	cx
		push	si

		;---------------------------------------
		; ファイル名検索
		;---------------------------------------
		cld										; // DFクリア（+方向）
		mov		bx, 0							; BX = ファイルの先頭セクタ; // 初期値
		mov		cx, 512 / 32					; CX = エントリ数;           // 1セクタ/32バイト
		mov		si, 0x7600						; SI = 読み込んだセクタのアドレス; 
												; do
.10L:											; {
		and		[si + 11], byte 0x18			;   // ファイル属性のチェック
		jnz		.12E							;   if (ディレクトリ/ボリュームラベル以外)
												;   {
		cdecl	memcmp, si, .s0, 8 + 3			;     AX = memcmp(ファイル名を比較);
		cmp		ax, 0							;     if (同一ファイル名)
		jne		.12E							;     {
												;       
		mov		bx, word [si + 0x1A]			;       BX = ファイルの先頭セクタ;
		jmp		.10E							;       break;
												;     }
.12E:											;   }
		add		si, 32							;   SI += 32; // 次のエントリ
		loop	.10L							;   
.10E:											; } while (--CX);
		mov		ax, bx							; ret = 見つかったファイルの先頭セクタ;

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		si
		pop		cx
		pop		bx

		ret

.s0:	db		'SPECIAL TXT', 0

;************************************************************************
;	GLOBAL DESCRIPTOR TABLE
;	(セグメントディスクリプタの配列)
;************************************************************************
;
;   セグメントディスクリプタ
;
;        +--------+-----------------: Base (0xBBbbbbbb)
;        |   +----|--------+--------: Limit(0x000Lllll)
;        |   |    |        |
;       +--+--+--+--+--+--+--+--+
;       |B |FL|f |b       |l    |
;       +--+--+--+--+--+--+--+--+
;           |  |                         76543210
;           |  +--------------------: f:PDDSTTTA
;           |                          P:Exist
;           |                          D:DPL(特権)
;           |                          S:(DT)0=システムorゲート, 1=データセグメント
;           |                          T:Type
;           |                            000(0)=R/- DATA
;           |                            001(1)=R/W DATA
;           |                            010(2)=R/- STACK
;           |                            011(3)=R/W STACK
;           |                            100(4)=R/- CODE
;           |                            101(5)=R/W CODE
;           |                            110(6)=R/- CONFORM
;           |                            111(7)=R/W CONFORM
;           |                          A:Accessed
;           |                       
;           +-----------------------: F:GD0ALLLL
;                                      G:Limit Scale(0=1, 1=4K)
;                                      D:Data/BandDown(0=16, 1=32Bit セグメント)
;                                      A:any
;                                      L:Limit[19:16]
ALIGN 4, db 0
;					  B_ F L f T b_____ l___
GDT:			dq	0x00_0_0_0_0_000000_0000	; NULL
.cs:			dq	0x00_C_F_9_A_000000_FFFF	; CODE 4G
.ds:			dq	0x00_C_F_9_2_000000_FFFF	; DATA 4G
.gdt_end:

;===============================================
;	セレクタ
;===============================================
SEL_CODE	equ	.cs - GDT						; コード用セレクタ
SEL_DATA	equ	.ds - GDT						; データ用セレクタ

;===============================================
;	GDT
;===============================================
GDTR:	dw 		GDT.gdt_end - GDT - 1			; ディスクリプタテーブルのリミット
		dd 		GDT								; ディスクリプタテーブルのアドレス

;===============================================
;	IDT（疑似：割り込み禁止にする為）
;===============================================
IDTR:	dw 		0								; idt_limit
		dd 		0								; idt location

;************************************************************************
;	ブート処理の第7ステージ
;************************************************************************
stage_7:
		cli										; // 割り込み禁止

		;---------------------------------------
		; GDTロード
		;---------------------------------------
		lgdt	[GDTR]							; // グローバルディスクリプタテーブルをロード
		lidt	[IDTR]							; // 割り込みディスクリプタテーブルをロード

		;---------------------------------------
		; プロテクトモードへ移行
		;---------------------------------------
		mov		eax,cr0							; // PEビットをセット
		or		ax, 1							; CR0 |= 1;
		mov		cr0,eax							; 

		jmp		$ + 2							; 先読みをクリア

		;---------------------------------------
		; セグメント間ジャンプ
		;---------------------------------------
[BITS 32]
		DB		0x66							; オペランドサイズオーバーライドプレフィックス
		jmp		SEL_CODE:CODE_32

;************************************************************************
;	32ビットコード開始
;************************************************************************
CODE_32:

		;---------------------------------------
		; セレクタを初期化
		;---------------------------------------
		mov		ax, SEL_DATA					;
		mov		ds, ax							;
		mov		es, ax							;
		mov		fs, ax							;
		mov		gs, ax							;
 		mov		ss, ax							;

		;---------------------------------------
		; カーネル部をコピー
		;---------------------------------------
		mov		ecx, (KERNEL_SIZE) / 4			; ECX = 4バイト単位でコピー;
		mov		esi, BOOT_END					; ESI = 0x0000_9C00; // カーネル部
		mov		edi, KERNEL_LOAD				; EDI = 0x0010_1000; // 上位メモリ
		cld										; // DFクリア（+方向）
		rep movsd								; while (--ECX) *EDI++ = *ESI++;

		;---------------------------------------
		; カーネル処理に移行
		;---------------------------------------
		jmp		KERNEL_LOAD						; カーネルの先頭にジャンプ

;************************************************************************
;	リアルモードへの移行プログラム
;************************************************************************
TO_REAL_MODE:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
												; ------|--------
												; EBP+ 8| col（列）
												; EBP+12| row（行）
												; EBP+16| color（色）
												; EBP+20| *p（文字列へのアドレス）
												; ---------------
		push	ebp								; EBP+ 4| EIP（戻り番地）
		mov		ebp, esp						; EBP+ 0| EBP（元の値）
												; ---------------

		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		pusha

		cli										; // 割り込み禁止

		;---------------------------------------
		; 現在の設定値を保存
		;---------------------------------------
		mov		eax, cr0						; 
		mov		[.cr0_saved], eax				; // CR0レジスタを保存
		mov		[.esp_saved], esp				; // ESPレジスタを保存
		sidt	[.idtr_save]					; // IDTRを保存
		lidt	[.idtr_real]					; // リアルモードの割り込み設定

		;---------------------------------------
		; 16ビットのプロテクトモードに移行
		;---------------------------------------
		jmp		0x0018:.bit16					; CS = 0x18（コードセグメントセレクタ）
[BITS 16]
.bit16:	mov		ax, 0x0020						; DS = 0x20（データセグメントセレクタ）
		mov		ds, ax							; 
		mov		es, ax							; 
		mov		ss, ax							; 

		;---------------------------------------
		; リアルモードへ移行（ページング無効化）
		;---------------------------------------
		mov		eax, cr0						; // PG/PEビットをクリア
		and		eax,  0x7FFF_FFFE				; CR0 &= ~(PG | PE);
		mov		cr0, eax						; 
		jmp		$ + 2							; 

		;---------------------------------------
		; セグメント設定（リアルモード）
		;---------------------------------------
		jmp		0:.real							; CS = 0x0000;
.real:	mov		ax, 0x0000						; 
		mov		ds, ax							; DS = 0x0000;
		mov		es, ax							; ES = 0x0000;
		mov		ss, ax							; SS = 0x0000;
		mov		sp, 0x7C00						; SP = 0x7C00;

		;---------------------------------------
		; 割り込みマスクの設定（リアルモード用）
		;---------------------------------------
		outp	0x20, 0x11						; out(0x20, 0x11); // MASTER.ICW1 = 0x11;
		outp	0x21, 0x08						; out(0x21, 0x20); // MASTER.ICW2 = 0x08;
		outp	0x21, 0x04						; out(0x21, 0x04); // MASTER.ICW3 = 0x04;
		outp	0x21, 0x01						; out(0x21, 0x01); // MASTER.ICW4 = 0x01;

		outp	0xA0, 0x11						; out(0xA0, 0x11); // SLAVE.ICW1  = 0x11;
		outp	0xA1, 0x10						; out(0xA1, 0x28); // SLAVE.ICW2  = 0x10;
		outp	0xA1, 0x02						; out(0xA1, 0x02); // SLAVE.ICW3  = 0x02;
		outp	0xA1, 0x01						; out(0xA1, 0x01); // SLAVE.ICW4  = 0x01;

		outp	0x21, 0b_1011_1000				; // 割り込み有効：FDD/スレーブPIC/KBC/タイマー
		outp	0xA1, 0b_1011_1110				; // 割り込み有効：HDD/RTC

		sti										; // 割り込み許可

		;---------------------------------------
		; ファイル読み込み
		;---------------------------------------
		cdecl	read_file						; read_file();

		;---------------------------------------
		; 割り込みマスクの設定（プロテクトモード用）
		;---------------------------------------
		cli										; // 割り込み禁止

		outp	0x20, 0x11						; // MASTER.ICW1 = 0x11;
		outp	0x21, 0x20						; // MASTER.ICW2 = 0x20;
		outp	0x21, 0x04						; // MASTER.ICW3 = 0x04;
		outp	0x21, 0x01						; // MASTER.ICW4 = 0x01;

		outp	0xA0, 0x11						; // SLAVE.ICW1  = 0x11;
		outp	0xA1, 0x28						; // SLAVE.ICW2  = 0x28;
		outp	0xA1, 0x02						; // SLAVE.ICW3  = 0x02;
		outp	0xA1, 0x01						; // SLAVE.ICW4  = 0x01;

		outp	0x21, 0b_1111_1000				; // 割り込み有効：スレーブPIC/KBC/タイマー
		outp	0xA1, 0b_1111_1110				; // 割り込み有効：RTC

		;---------------------------------------
		; 16ビットプロテクトモードに移行
		;---------------------------------------
		mov		eax, cr0						; // PEビットをセット
		or		eax, 1							; CR0 |= PE;
		mov		cr0, eax						; 

		jmp		$ + 2							; 先読みをクリア

		;---------------------------------------
		; 32ビットプロテクトモードに移行
		;---------------------------------------
		DB		0x66							; 32bit オーバーライド
[BITS 32]
		jmp		0x0008:.bit32					; CS = 32ビットCS;
.bit32:	mov		ax, 0x0010						; DS = 32ビットDS;
		mov		ds, ax							;
		mov		es, ax							;
		mov		ss, ax							;

		;---------------------------------------
		; レジスタ設定の復帰
		;---------------------------------------
		mov		esp, [.esp_saved]				; // ESPレジスタを復帰
		mov		eax, [.cr0_saved]				; // CR0レジスタを復帰
		mov		cr0, eax						; 
		lidt	[.idtr_save]					; // IDTRを復帰

		sti 									; // 割り込み許可

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		popa

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		esp, ebp
		pop		ebp

		ret

.idtr_real:
		dw 		0x3FF							; idt_limit
		dd 		0								; idt location

.idtr_save:
		dw 		0								; リミット
		dd 		0								; ベース

.cr0_saved:
		dd		0

.esp_saved:
		dd		0

;************************************************************************
;	パディング
;************************************************************************
		times BOOT_SIZE - ($ - $$) - 16	db	0	; パディング

		dd 		TO_REAL_MODE					; リアルモード移行プログラム

;************************************************************************
;	パディング
;************************************************************************
		times BOOT_SIZE - ($ - $$)		db	0	; パディング

