;************************************************************************
;	TASK-1
;************************************************************************
task_1:
		;---------------------------------------
		; 文字列の表示
		;---------------------------------------
		cdecl	draw_str, 63, 0, 0x07, .s0		; draw_str();

.10L:											; while (;;)
												; {
		;---------------------------------------
		; 時刻の表示
		;---------------------------------------
		mov		eax, [RTC_TIME]					;   // 時刻の取得
		cdecl	draw_time, 72, 0, 0x0700, eax	;   // 時刻の表示

		;---------------------------------------
		; タスクの呼び出し
		;---------------------------------------
		jmp		SS_TASK_0:0						;   // タスク0へのジャンプ

		jmp		.10L							; }

		;---------------------------------------
		; データ
		;---------------------------------------
.s0		db	"Task-1", 0

