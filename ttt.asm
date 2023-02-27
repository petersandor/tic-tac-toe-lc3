.ORIG x3000

MAIN
      LD R6,STACK
      LEA R5,BOARD

      LEA R0,WELCOME_MESSAGE
      PUTS

GAME_LOOP
      JSR DRAW_BOARD

      JSR CHECK_WINNING_COMBINATION ; check for winning combinations (R0 1 = win)
      ADD R0,R0,#0
      BRz GAME_WIN

      ; check whether there are available moves
      LD R0,MOVES_LEFT
      ADD R0,R0,#0
      BRz GAME_OVER

      JSR MAKE_MOVE ; (R0 > 0 = spot marked)

      LD R0,MOVES_LEFT
      ADD R0,R0,#-1
      ST R0,MOVES_LEFT
      BRnzp GAME_LOOP

GAME_WIN
      LD R0,NEW_LINE
      OUT
      OUT
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
      BRn CHECK_WINNING_COMBINATION_COUNTER_RESET
      ADD R3,R0,#-10
      BRz CHECK_WINNING_COMBINATION_EXIT  ; nothing left to check

      ADD R0,R5,R0
      LDR R0,R0,#0  ; value from game state in R0-th spot
      LD R3,PREVIOUS_SYMBOL
      ST R0,PREVIOUS_SYMBOL

      AND R0,R0,R3  ; compare current (R0) with previous (R3)
      BRp CHECK_WINNING_COMBINATION_INCREMENT
      AND R4,R4,#0
      BR CHECK_WINNING_COMBINATION_CONTINUE

CHECK_WINNING_COMBINATION_INCREMENT
      ADD R4,R4,#1
      BR CHECK_WINNING_COMBINATION_CONTINUE

CHECK_WINNING_COMBINATION_COUNTER_RESET
      AND R4,R4,#0
      ST R4,PREVIOUS_SYMBOL

CHECK_WINNING_COMBINATION_CONTINUE
      ADD R0,R4,#-2
      BRz CHECK_WINNING_COMBINATION_EXIT

      ADD R2,R2,#1  ; increment loop counter
      BR CHECK_WINNING_COMBINATION_LOOP

CHECK_WINNING_COMBINATION_EXIT
      LDR   R7, R6, #0
      ADD   R6, R6, #1
      RET

PREVIOUS_SYMBOL .FILL x0


;
; Marks free spots, alternating between players
;
MAKE_MOVE
      STR R7, R6, #-1     ; save registers
      ADD R6, R6, #-1

      LEA R1,WIN_COMBINATIONS

      AND R2,R2,#0  ; loop counter

MAKE_MOVE_LOOP
      ADD R0,R1,R2
      LDR R0,R0,#0  ; board offset from R2-th index in winning combinations array
      ADD R3,R0,#-10
      BRz MARK_POSITION_EXIT  ; nothing left to check

      ADD R0,R5,R0

CHECK_POS_LOOP
      LD R3,POS_CHECK_COUNTER
      ADD R3,R3,#0
      BRz LOAD_POS_1

      LD R3,POS_CHECK_COUNTER
      ADD R3,R3,#-1
      BRz LOAD_POS_2

      LD R3,POS_CHECK_COUNTER
      ADD R3,R3,#-2
      BRz LOAD_POS_3

LOAD_POS_1
      ADD R4,R0,#0
      LDR R3,R0,#0
      BRp CHECK_POS
      ST R4,AVAILABLE_POS_1 ;  save available empty position
      BR CHECK_POS_NEXT

LOAD_POS_2
      ADD R4,R0,#1
      LDR R3,R0,#1
      BRp CHECK_POS
      ST R4,AVAILABLE_POS_2 ;  save available empty position
      BR CHECK_POS_NEXT

LOAD_POS_3
      ADD R4,R0,#2
      LDR R3,R0,#2
      BRp CHECK_POS
      ST R4,AVAILABLE_POS_3 ;  save available empty position
      BR CHECK_POS_NEXT

CHECK_POS
      LD R4,NEXT_PLAYER
      AND R4,R4,R3
      BRp CHECK_POS_NEXT ; position already owned
      BRz MAKE_MOVE_CONTINUE ; combination not viable (already blocked by other player), skip it

CHECK_POS_NEXT
      LD R3, POS_CHECK_COUNTER
      ADD R3,R3,#1
      ST R3, POS_CHECK_COUNTER
      ADD R3,R3,#-3
      BRn CHECK_POS_LOOP

;
; Loads address of the first available position in R0 which is then used
;
PICK_POSITION
      LD R4, AVAILABLE_POS_1
      BRp MARK_POSITION
      LD R4, AVAILABLE_POS_2
      BRp MARK_POSITION
      LD R4, AVAILABLE_POS_3
      BRp MARK_POSITION
      BR MAKE_MOVE_CONTINUE

;
; Marks position R0 (address in BOARD) by player R3 (1 - X, 2 - O)
;
MARK_POSITION
      LD R3,NEXT_PLAYER
      STR R3,R4,#0
      BR MARK_POSITION_EXIT

MAKE_MOVE_CONTINUE
      AND R4,R4,#0
      ST R4, POS_CHECK_COUNTER
      ADD R4,R4,#-1
      ST R4, AVAILABLE_POS_1
      ST R4, AVAILABLE_POS_2
      ST R4, AVAILABLE_POS_3

      ADD R2,R2,#4  ; increment loop counter
      BR MAKE_MOVE_LOOP

MARK_POSITION_EXIT
      AND R4,R4,#0
      ST R4, POS_CHECK_COUNTER
      ADD R4,R4,#-1
      ST R4, AVAILABLE_POS_1
      ST R4, AVAILABLE_POS_2
      ST R4, AVAILABLE_POS_3

      LD R0,NEXT_PLAYER
      ADD R0,R0,#-1
      BRp SET_NEXT_PLAYER_X

SET_NEXT_PLAYER_O
      ADD R0,R0,#2
      ST R0,NEXT_PLAYER
      BR MAKE_MOVE_END

SET_NEXT_PLAYER_X
      ST R0, NEXT_PLAYER

MAKE_MOVE_END
      LDR   R7, R6, #0
      ADD   R6, R6, #1
      RET

NEXT_PLAYER         .FILL x1  ; 1 - X, 2 - O
POS_CHECK_COUNTER   .FILL x0
AVAILABLE_POS_1     .FILL #-1
AVAILABLE_POS_2     .FILL #-1
AVAILABLE_POS_3     .FILL #-1

;
; Outputs the board representing the game state
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
      HOR_DIV           .STRINGZ "\n-----------\n"
      VERT_DIV          .STRINGZ "|"

; data
      STACK             .FILL x4000
      BOARD             .FILL x0
                        .FILL x0
                        .FILL x0
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
                        .FILL #-1
                        .FILL #3
                        .FILL #4
                        .FILL #5
                        .FILL #-1
                        .FILL #6
                        .FILL #7
                        .FILL #8
                        .FILL #-1
                        .FILL #0
                        .FILL #3
                        .FILL #6
                        .FILL #-1
                        .FILL #1
                        .FILL #4
                        .FILL #7
                        .FILL #-1
                        .FILL #2
                        .FILL #5
                        .FILL #8
                        .FILL #-1
                        .FILL #0
                        .FILL #4
                        .FILL #8
                        .FILL #-1
                        .FILL #2
                        .FILL #4
                        .FILL #6
                        .FILL #10
                        .FILL #10

      TEXT_BOARD_LABELS_TBL_PTR .FILL x3120 ; TEXT_BOARD_LABELS_TBL

      WELCOME_MESSAGE   .STRINGZ "Welcome to LC-3 TTT minigame\n"
      WIN_MESSAGE       .STRINGZ "You won!"  ; TODO: add symbol ref
      DRAW_MESSAGE      .STRINGZ "It's a draw."

      TEXT_BOARD_LABELS_TBL .FILL x3123	; BOARD_LABEL_0
                            .FILL x3125 ; BOARD_LABEL_1
                            .FILL x3127 ; BOARD_LABEL_2

      BOARD_LABEL_0     .STRINGZ	" "
      BOARD_LABEL_1     .STRINGZ	"X"
      BOARD_LABEL_2     .STRINGZ	"O"

.END
