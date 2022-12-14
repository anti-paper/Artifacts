;************************************************************************
;	KBCの出力バッファに書き込む
;========================================================================
;■書式		: WORD KBC_Data_Write(data);
;
;■引数
;	data	: 書き込みデータ
;
;■戻り値	: 成功(0以外)、失敗(0)
;************************************************************************
KBC_Data_Write:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
												; ------|--------
												;    + 4| データ
												;    + 2| IP（戻り番地）
		push	bp								;  BP+ 0| BP（元の値）
		mov		bp, sp							; ------+--------

		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	cx

		;---------------------------------------
		; データ書き込み
		;---------------------------------------
		mov		cx, 0							; CX = 0; // 最大カウント値
.10L:											; do
												; {
		in		al, 0x64						;   AL = inp(0x64); // KBCステータス
		test    al, 0x02						;   ZF = AL & 0x02; // 書き込み可能？
		loopnz	.10L							; } while (--CX && !ZF);
												; 
		cmp		cx, 0							; if (CX) // 未タイムアウト
		jz		.20E							; {
												;   
		mov		al, [bp + 4]					;   AL = データ;
		out    	0x60, al						;   outp(0x60, AL);
.20E:											; }
												; 
		mov		ax, cx							; return CX;

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		cx

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		sp, bp
		pop		bp

		ret

;************************************************************************
;	KBCの出力バッファを読み込む
;========================================================================
;■書式		: WORD KBC_Data_Read(data);
;
;■引数
;	data	: 読み込みデータ格納アドレス
;
;■戻り値	: 成功(0以外)、失敗(0)
;************************************************************************
KBC_Data_Read:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
												;    + 4| 格納アドレス
												;    + 2| IP（戻り番地）
		push	bp								;  BP+ 0| BP（元の値）
		mov		bp, sp							; ------+--------

		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	cx
		push	di

		;---------------------------------------
		; データ読み込み
		;---------------------------------------
		mov		cx, 0							; CX = 0; // 最大カウント値
.10L:											; do
												; {
		in		al, 0x64						;   AL = inp(0x64); // KBCステータス
		test    al, 0x01						;   ZF = AL & 0x01; // 読み込み可能？
		loopz	.10L							; } while (--CX && ZF);
												;   
		cmp		cx, 0							; if (CX) // 未タイムアウト
		jz		.20E							; {
												;   
		mov		ah, 0x00						;   AH = 0x00;
		in     	al, 0x60						;   AL = inp(0x60); // データ取得
												;   
		mov		di, [bp + 4]					;   DI    = adr;
		mov		[di + 0], ax					;   DI[0] = AX;
.20E:											; }
												; 
		mov		ax, cx							; return CX;

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		di
		pop		cx

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		sp, bp
		pop		bp

		ret

;************************************************************************
;	KBCにコマンドを出力
;========================================================================
;■書式		: WORD KBC_Cmd_Write(cmd);
;
;■引数
;	cmd		: コマンド
;
;■戻り値	: 成功(0以外)、失敗(0)
;************************************************************************
KBC_Cmd_Write:
		;---------------------------------------
		; 【スタックフレームの構築】
		;---------------------------------------
												;    + 4| コマンド
												;    + 2| IP（戻り番地）
		push	bp								;  BP+ 0| BP（元の値）
		mov		bp, sp							; ------+--------

		;---------------------------------------
		; 【レジスタの保存】
		;---------------------------------------
		push	cx

		;---------------------------------------
		; コマンド書き込み
		;---------------------------------------
		mov		cx, 0							; CX = 0; // 最大カウント値
.10L:											; do
												; {
		in		al, 0x64						;   AL = inp(0x64); // KBCステータス
		test    al, 0x02						;   ZF = AL & 0x02; // 書き込み可能？
		loopnz	.10L							; } while (--CX && !ZF);
												; 
		cmp		cx, 0							; if (CX) // 未タイムアウト
		jz		.20E							; {
												;   
		mov		al, [bp + 4]					;   AL = コマンド;
		out    	0x64, al						;   outp(0x64, AL);
.20E:											; }

		mov		ax, cx							; return CX;

		;---------------------------------------
		; 【レジスタの復帰】
		;---------------------------------------
		pop		cx

		;---------------------------------------
		; 【スタックフレームの破棄】
		;---------------------------------------
		mov		sp, bp
		pop		bp

		ret

