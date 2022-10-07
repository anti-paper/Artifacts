;************************************************************************
;	割り込みベクタの初期化
;************************************************************************
ALIGN 4
IDTR:	dw 		8 * 256 - 1					; idt_limit
		dd 		VECT_BASE					; idt location

;************************************************************************
;	割り込みテーブルを初期化
;------------------------------------------------------------------------
;	
;	まず、全ての割り込みアドレスにデフォルト処理を設定すし、その後、
;	必要な割り込みだけ設定しなおす。
;	
;	割り込みアドレスは、VECT_BASEで指定され、256の割り込みがあるので
;	0x0800バイト占有することになる。
;	
;	           |____________| _V___
;	  VECT_BASE| IntDefault |  |   
;	           | IntDefault |  | 8 * 256
;	           |      :     |  |   
;	           |____________| _|___
;	      +0800|////////////|
;	           |            |
;	
;	一つの割り込み設定は8バイトで構成される。
;	
;	           |____________|____________| 
;	        [0]| Address Lo[15: 0]       | 
;	        [2]| Selector                | 
;	        [4]| Flags                   | 
;	        [6]|_Address Lo[32:16]_______| 
;	           |/////////////////////////| 
;	           |            |            | 
;	
;========================================================================
;■書式		: void init_int(void);
;
;■引数		: 無し
;
;■戻り値	: 無し
;************************************************************************
init_int:
		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	eax
		push	ebx
		push	ecx
		push	edi

		;---------------------------------------
		; 全ての割り込みにデフォルト処理を設定
		;---------------------------------------
		lea		eax, [int_default]				; EAX   = 割り込み処理アドレス;
		mov		ebx, 0x0008_8E00				; EBX   = セグメントセレクタ;
		xchg	ax, bx							; // 下位ワードを交換

		mov		ecx, 256						; ECX   = 割り込みベクタ数
		mov		edi, VECT_BASE					; EDI   = 割り込みベクタテーブル

.10L:											; do
												; {
		mov		[edi + 0], ebx					;   [EDI + 0] = 割り込みディスクリプタ（下位）
		mov		[edi + 4], eax					;   [EDI + 4] = 割り込みディスクリプタ（上位）
		add		edi, 8							;   EDI += 8;
		loop	.10L							; } while (ECX--);

		;---------------------------------------
		; 割り込みディスクリプタの設定
		;---------------------------------------
		lidt	[IDTR]							; // 割り込みディスクリプタテーブルをロード

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		edi
		pop		ecx
		pop		ebx
		pop		eax

		ret

;************************************************************************
;	スタックの内容を表示して無限ループを実行
;************************************************************************
int_stop:
		sti										; // 割り込み許可

		;---------------------------------------
		; EAXで示される文字列を表示
		;---------------------------------------
		cdecl	draw_str, 25, 15, 0x060F, eax	; draw_str(EAX);

		;---------------------------------------
		; スタックのデータを文字列に変換
		;---------------------------------------
		mov		eax, [esp + 0]					; EAX = ESP[ 0];
		cdecl	itoa, eax, .p1, 8, 16, 0b0100	; itoa(EAX, 8, 16, 0b0100);

		mov		eax, [esp + 4]					; EAX = ESP[ 4];
		cdecl	itoa, eax, .p2, 8, 16, 0b0100	; itoa(EAX, 8, 16, 0b0100);

		mov		eax, [esp + 8]					; EAX = ESP[ 8];
		cdecl	itoa, eax, .p3, 8, 16, 0b0100	; itoa(EAX, 8, 16, 0b0100);

		mov		eax, [esp +12]					; EAX = ESP[12];
		cdecl	itoa, eax, .p4, 8, 16, 0b0100	; itoa(EAX, 8, 16, 0b0100);

		;---------------------------------------
		; 文字列の表示
		;---------------------------------------
		cdecl	draw_str, 25, 16, 0x0F04, .s1	; draw_str("ESP+ 0:-------- ");
		cdecl	draw_str, 25, 17, 0x0F04, .s2	; draw_str("   + 4:-------- ");
		cdecl	draw_str, 25, 18, 0x0F04, .s3	; draw_str("   + 8:-------- ");
		cdecl	draw_str, 25, 19, 0x0F04, .s4	; draw_str("   +12:-------- ");

		;---------------------------------------
		; 無限ループ
		;---------------------------------------
		jmp		$								; while (1) ; // 無限ループ

.s1		db	"ESP+ 0:"
.p1		db	"________ ", 0
.s2		db	"   + 4:"
.p2		db	"________ ", 0
.s3		db	"   + 8:"
.p3		db	"________ ", 0
.s4		db	"   +12:"
.p4		db	"________ ", 0

;************************************************************************
;	割り込み処理：デフォルトの処理
;************************************************************************
int_default:
		pushf									; // EFLAGS(IF==0)
		push	cs								; // CS
		push	int_stop						; // スタック表示処理

		mov		eax, .s0						; // 割り込み種別
		iret

.s0		db	" <    STOP    > ", 0

;************************************************************************
;	割り込み処理：ゼロ除算
;************************************************************************
int_zero_div:
		pushf									; // EFLAGS
		push	cs								; // CS
		push	int_stop						; // スタック表示処理

		mov		eax, .s0						; // 割り込み種別
		iret

.s0		db	" <  ZERO DIV  > ", 0

