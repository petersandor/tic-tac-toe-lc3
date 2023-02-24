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

GAME_LOOP
      JSR DRAW_BOARD
      ; JSR MARK_POSITION
      ; JSR DRAW_BOARD

      JSR CHECK_WINNING_COMBINATION ; check for winning combinations (R0 1 = win)
      ADD R0,R0,#0
      BRp GAME_WIN

      ; check whether there are available moves
      LD R0,MOVES_LEFT
      ADD R0,R0,#0
      BRz GAME_OVER
      ADD R0,R0,#-1
      ST R0,MOVES_LEFT
      BRnzp GAME_LOOP

GAME_WIN
      LEA R0, WIN_MESSAGE
      PUTS

GAME_OVER
      HALT


CHECK_WINNING_COMBINATION
      STR R7, R6, #-1     ; save registers
      ADD R6, R6, #-1

      LEA R1,WIN_COMBINATIONS

      AND R2,R2,#0  ; loop counter
      ADD R2,R2,#0

      AND R4,R4,#0  ; succession counter (3 = victory)

CHECK_WINNING_COMBINATION_LOOP
      ADD R0,R1,R2
      LDR R0,R0,#0  ; board offset from R2-th index in winning combinations array
      BRn CHECK_WINNING_COMBINATION_EXIT  ; nothing left to check

      ADD R0,R5,R0
      LDR R0,R0,#0  ; value from game state in R0-th spot
      LD R3,PREVIOUS_SYMBOL
      ST R0,PREVIOUS_SYMBOL

      AND R0,R0,R0
      BRp CHECK_WINNING_COMBINATION_INCREMENT
      BR CHECK_WINNING_COMBINATION_COUNTER_RESET

CHECK_WINNING_COMBINATION_INCREMENT
      ADD R4,R4,#1
      BR CHECK_WINNING_COMBINATION_CONTINUE

CHECK_WINNING_COMBINATION_COUNTER_RESET
      AND R4,R4,#0

CHECK_WINNING_COMBINATION_CONTINUE
      ADD R0,R4,#-2
      BRp CHECK_WINNING_COMBINATION_EXIT

      ADD R2,R2,#1  ; increment loop counter
      BRp CHECK_WINNING_COMBINATION_LOOP

CHECK_WINNING_COMBINATION_EXIT
      LDR   R7, R6, #0
      ADD   R6, R6, #1
      RET

PREVIOUS_SYMBOL .FILL x0

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
      LD R0,SPACE
      OUT

      ADD R3,R5,R2
      LDR R3,R3,#0
      ADD R2,R2,#1

      ADD R0,R1,R3
      LDR R0,R0,#0
      PUTS

      LD R0,SPACE
      OUT

      ADD R0,R2,#-2
      BRnz PRINT_VERT_DIVIDER

      ADD R0,R2,#-3
      BRz PRINT_HOR_DIVIDER

      ADD R0,R2,#-6
      BRz PRINT_HOR_DIVIDER

      ADD R0,R2,#-5
      BRnz PRINT_VERT_DIVIDER

      ADD R0,R2,#-8
      BRnz PRINT_VERT_DIVIDER

      LD R0,NEW_LINE
      OUT

      JSR DRAW_EXIT

PRINT_VERT_DIVIDER
      LEA R0,VERT_DIV
      PUTS
      JSR PRINT_NEXT_NUMBER

PRINT_HOR_DIVIDER
      LEA R0,HOR_DIV
      PUTS
      JSR PRINT_NEXT_NUMBER

DRAW_EXIT
      LDR   R7, R6, #0
      ADD   R6, R6, #1
      RET

; data
      NEW_LINE          .FILL x0A
      SPACE             .FILL x20
      SPACER            .STRINGZ " "
      SPACER_END        .STRINGZ " \n"
      HOR_DIV           .STRINGZ "\n-----------\n"
      VERT_DIV          .STRINGZ "|"

; data
      STACK             .FILL x4000
      BOARD             .FILL x1
                        .FILL x1
                        .FILL x1
                        .FILL x0
                        .FILL x0
                        .FILL x0
                        .FILL x0
                        .FILL x0
                        .FILL x0
      MOVES_LEFT        .FILL #9
      WINNER            .FILL x0

      WIN_COMBINATIONS  .FILL #0
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
                        .FILL #-1

      TEXT_BOARD_LABELS_TBL_PTR .FILL x30B4 ; TEXT_BOARD_LABELS_TBL

      WELCOME_MESSAGE   .STRINGZ "Welcome to LC-3 TTT minigame\n"
      WIN_MESSAGE       .STRINGZ "You won!"  ; TODO: add symbol ref

      TEXT_BOARD_LABELS_TBL .FILL x30B7 ; BOARD_LABEL_0
                            .FILL x30B9 ; BOARD_LABEL_1
                            .FILL x30BB ; BOARD_LABEL_2

      BOARD_LABEL_0     .STRINGZ	" "
      BOARD_LABEL_1     .STRINGZ	"X"
      BOARD_LABEL_2     .STRINGZ	"O"

.END
