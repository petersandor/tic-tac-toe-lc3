; TODO
; 1. MAIN LOOP (who made the prev move in Rn)
;    1. LOOK FOR ANY OF THE WIN. COMBINATIONS
;        1. IF PRESENT: MSG & EXIT
;    1. CHECK WHETHER THERE IS SLOT AVAILABLE
;        1. IF NOT: MSG & EXIT
;    3. MAKE MOVE
;        1. FOR DEMO, MARK FIRST AVAILABLE POS

.ORIG x3000

MAIN
      LD R6,STACK
      LEA R5,BOARD

      LEA R0,WELCOME_MESSAGE
      PUTS

      JSR DRAW_BOARD
      ; JSR MARK_POSITION
      ; JSR DRAW_BOARD
      HALT

;
; TBD
;
; MARK_POSITION
;       STR R7, R6, #-1     ; save registers
;       ADD R6, R6, #-1

;       LD R1,NEXT_MOVE
;       ADD R1,R1,#-1

; MARK_POSITION_EXIT
;       LDR   R7, R6, #0
;       ADD   R6, R6, #1
;       RET

;
; TBD
;
DRAW_BOARD
      STR R7, R6, #-1     ; save registers
      ADD R6, R6, #-1

      LD R0,NEW_LINE
      OUT

      LD R1,TEXT_BOARD_LABELS_TBL_PTR
      AND R2,R2,#0

PRINT_NEXT_NUMBER
      LEA R0,SPACER
      PUTS

      ADD R3,R5,R2
      LDR R3,R3,#0
      ADD R2,R2,#1

      ADD R0,R1,R3
      LDR R0,R0,#0
      PUTS

      LEA R0,SPACER
      PUTS

      ADD R0,R2,#-2
      BRnz PRINT_VERT_DIVIDER

      JSR PRINT_NEXT_NUMBER

PRINT_VERT_DIVIDER
      LEA R0,VERT_DIV
      PUTS
      JSR PRINT_NEXT_NUMBER

      ; LEA R0,GAME_STATE
      ; PUTS
      ; LEA R0,SPACER
      ; PUTS
      ; LEA R0,VERT_DIV
      ; PUTS
      ; LEA R0,SPACER
      ; PUTS
      ; LEA R0,GAME_STATE
      ; ADD R0,R0,#2
      ; PUTS
      ; LEA R0,SPACER
      ; PUTS
      ; LEA R0,VERT_DIV
      ; PUTS
      ; LEA R0,SPACER
      ; PUTS
      ; LEA R0,GAME_STATE
      ; ADD R0,R0,#4
      ; PUTS
      ; LEA R0,SPACER_END
      ; PUTS
      ; LEA R0,HOR_DIV
      ; PUTS
      ; LEA R0,SPACER
      ; PUTS
      ; LEA R0,GAME_STATE
      ; ADD R0,R0,#6
      ; PUTS
      ; LEA R0,SPACER
      ; PUTS
      ; LEA R0,VERT_DIV
      ; PUTS
      ; LEA R0,SPACER
      ; PUTS
      ; LEA R0,GAME_STATE
      ; ADD R0,R0,#8
      ; PUTS
      ; LEA R0,SPACER
      ; PUTS
      ; LEA R0,VERT_DIV
      ; PUTS
      ; LEA R0,SPACER
      ; PUTS
      ; LEA R0,GAME_STATE
      ; ADD R0,R0,#10
      ; PUTS
      ; LEA R0,SPACER_END
      ; PUTS
      ; LEA R0,HOR_DIV
      ; PUTS
      ; LEA R0,SPACER
      ; PUTS
      ; LEA R0,GAME_STATE
      ; ADD R0,R0,#12
      ; PUTS
      ; LEA R0,SPACER
      ; PUTS
      ; LEA R0,VERT_DIV
      ; PUTS
      ; LEA R0,SPACER
      ; PUTS
      ; LEA R0,GAME_STATE
      ; ADD R0,R0,#14
      ; PUTS
      ; LEA R0,SPACER
      ; PUTS
      ; LEA R0,VERT_DIV
      ; PUTS
      ; LEA R0,SPACER
      ; PUTS
      ; LEA R0,GAME_STATE
      ; LEA R1,GAME_STATE_LEN
      ; ADD R1,R1,#-2
      ; ADD R0,R1,#0
      ; PUTS
      ; LEA R0,SPACER_END
      ; PUTS

DRAW_EXIT
      LDR   R7, R6, #0
      ADD   R6, R6, #1
      RET

; data
      NEW_LINE          .FILL x0A
      SPACE             .FILL x20
      SPACER            .STRINGZ " "
      SPACER_END        .STRINGZ " \n"
      HOR_DIV           .STRINGZ "-----------\n"
      VERT_DIV          .STRINGZ "|"

; data
      STACK             .FILL x4000
      BOARD             .FILL #2
                        .FILL #3
                        .FILL #4
                        .FILL #5
                        .FILL #6
                        .FILL #7
                        .FILL #8
                        .FILL #9
                        .FILL #10

      WINNING_COMBINATIONS
                        .FILL #0
                        .FILL #1
                        .FILL #2
                        .FILL #3
                        .FILL #4
                        .FILL #5
                        .FILL #6
                        .FILL #7
                        .FILL #8
                        .FILL #0
                        .FILL #3
                        .FILL #6
                        .FILL #1
                        .FILL #4
                        .FILL #7
                        .FILL #2
                        .FILL #5
                        .FILL #8
                        .FILL #0
                        .FILL #4
                        .FILL #8
                        .FILL #2
                        .FILL #4
                        .FILL #6

      TEXT_BOARD_LABELS_TBL_PTR .FILL x3076 ; TEXT_BOARD_LABELS_TBL

      WELCOME_MESSAGE   .STRINGZ "Welcome to LC-3 TTT minigame\n"

      TEXT_BOARD_LABELS_TBL .FILL x3081 ; BOARD_LABEL_0
                            .FILL x3083 ; BOARD_LABEL_1
                            .FILL x3085 ; BOARD_LABEL_2
                            .FILL x3087 ; BOARD_LABEL_3
                            .FILL x3089 ; BOARD_LABEL_4
                            .FILL x308B ; BOARD_LABEL_5
                            .FILL x308D ; BOARD_LABEL_6
                            .FILL x308F ; BOARD_LABEL_7
                            .FILL x3091 ; BOARD_LABEL_8
                            .FILL x3093 ; BOARD_LABEL_9
                            .FILL x3095 ; BOARD_LABEL_10

      BOARD_LABEL_0     .STRINGZ	"O"
      BOARD_LABEL_1     .STRINGZ	"X"
      BOARD_LABEL_2     .STRINGZ	"1"
      BOARD_LABEL_3     .STRINGZ	"2"
      BOARD_LABEL_4     .STRINGZ	"3"
      BOARD_LABEL_5     .STRINGZ	"4"
      BOARD_LABEL_6     .STRINGZ	"5"
      BOARD_LABEL_7     .STRINGZ	"6"
      BOARD_LABEL_8     .STRINGZ	"7"
      BOARD_LABEL_9     .STRINGZ	"8"
      BOARD_LABEL_10    .STRINGZ	"9"

.END
