;************************************************************************
;	割り込みコントローラの初期化
;========================================================================
;■書式		: void init_pic(void);
;
;■引数		: 無し
;
;■戻り値	: 無し
;************************************************************************
init_pic:
		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	eax

		;---------------------------------------
		; マスタPICの設定
		;---------------------------------------
		outp	0x20, 0x11						; // MASTER.ICW1 = 0x11;
		outp	0x21, 0x20						; // MASTER.ICW2 = 0x20;
		outp	0x21, 0x04						; // MASTER.ICW3 = 0x04;
		outp	0x21, 0x01						; // MASTER.ICW4 = 0x01;
		outp	0x21, 0xFF						; // マスタ割り込みマスク

		;---------------------------------------
		; スレーブPICの設定
		;---------------------------------------
		outp	0xA0, 0x11						; // SLAVE.ICW1  = 0x11;
		outp	0xA1, 0x28						; // SLAVE.ICW2  = 0x28;
		outp	0xA1, 0x02						; // SLAVE.ICW3  = 0x02;
		outp	0xA1, 0x01						; // SLAVE.ICW4  = 0x01;
		outp	0xA1, 0xFF						; // スレーブ割り込みマスク

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		eax

		ret

