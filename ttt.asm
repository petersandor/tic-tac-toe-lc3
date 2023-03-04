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

      LEA R0, PROMPT_MOVE_MESSAGE
      JSR PROMPT

      JSR MAKE_MOVE ; (R0 > 0 = spot marked)

      LD R0,MOVES_LEFT
      ADD R0,R0,#-1
      ST R0,MOVES_LEFT
      BRnzp GAME_LOOP

GAME_WIN
      LD R0,NEW_LINE
      OUT
      LEA R0, WIN_MESSAGE
      PUTS

GAME_OVER
      HALT

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

      TEXT_BOARD_LABELS_TBL_PTR .FILL x3070 ; TEXT_BOARD_LABELS_TBL

      WELCOME_MESSAGE   .STRINGZ "Welcome to LC-3 TTT minigame\n"
      WIN_MESSAGE       .STRINGZ "You won!"  ; TODO: add symbol ref
      DRAW_MESSAGE      .STRINGZ "It's a draw."
      PROMPT_MOVE_MESSAGE .STRINGZ	"Choose position (1-9): "

      TEXT_BOARD_LABELS_TBL .FILL x3073	; BOARD_LABEL_0
                            .FILL x3075 ; BOARD_LABEL_1
                            .FILL x3077 ; BOARD_LABEL_2

      BOARD_LABEL_0     .STRINGZ	" "
      BOARD_LABEL_1     .STRINGZ	"X"
      BOARD_LABEL_2     .STRINGZ	"O"

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
      ; LD R3,POS_ENEMY_PER_COMBINATION_COUNT
      ; ADD R3,R3,#1
      ; ST R3,POS_ENEMY_PER_COMBINATION_COUNT
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
      ; LD R4, POS_ENEMY_PER_COMBINATION_COUNT
      ; AND R4,R4,#2
      ; BR MAKE_MOVE_CONTINUE
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
      ST R4, POS_ENEMY_PER_COMBINATION_COUNT
      ADD R4,R4,#-1
      ST R4, AVAILABLE_POS_1
      ST R4, AVAILABLE_POS_2
      ST R4, AVAILABLE_POS_3

      ADD R2,R2,#4  ; increment loop counter
      BR MAKE_MOVE_LOOP

MARK_POSITION_EXIT
      AND R4,R4,#0
      ST R4, POS_CHECK_COUNTER
      ST R4, POS_ENEMY_PER_COMBINATION_COUNT
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

NEXT_PLAYER                       .FILL x1  ; 1 - X, 2 - O
POS_CHECK_COUNTER                 .FILL x0
POS_ENEMY_PER_COMBINATION_COUNT   .FILL x0
AVAILABLE_POS_1                   .FILL #-1
AVAILABLE_POS_2                   .FILL #-1
AVAILABLE_POS_3                   .FILL #-1

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

;
; Since LC-3 has no source of entropy for random number generation, the only
; source of entropy can be extracted via user input. The below routine implements
; a pseudo random number generator which is using the player's moves as a seed.
;

;
; From Ryan Pendleton's 2048
;

;--------------------------------------------------------------------------
; RAND_MOD
; Generates random number between 0 and r0 - 1 inclusively
; Returns r0 = random number
;--------------------------------------------------------------------------

RAND_MOD
      STR   R0, R6, #-1
      STR   R1, R6, #-2
      STR   R2, R6, #-3
      STR   R7, R6, #-4
      ADD   R6, R6, #-4

      LD    R0, RAND_SEED
      LD    R1, RAND_Q
      JSR   MOD_DIV           ; R0 = x % q

      LD    R1, RAND_A
      JSR   MULT              ; R0 = (x % q) * a
      ST    R0, RAND_SEED

      LDR   R1, R6, #3        ; get original R0
      JSR   MOD_DIV

      LDR   R7, R6, #0
      LDR   R2, R6, #1
      LDR   R1, R6, #2
      ADD   R6, R6, #4
      RET

; data
      RAND_INIT   .FILL x0000
      RAND_SEED   .FILL xC20D
      RAND_A      .FILL x0007
      RAND_M      .FILL x7FFF ; 2^15 - 1
      RAND_Q      .FILL x1249 ; M/A

;--------------------------------------------------------------------------
; GETC_SEED
; Seeds random number generator while getting a character from the keyboard
; Returns r0 = character
;--------------------------------------------------------------------------

GETC_SEED
      STR   R1, R6, #-1       ; save R1
      ADD   R6, R6, #-1

      AND   R1, R1, #0
GETC_SEED_LOOP                ; R1++ until character pressed
      ADD   R1, R1, #1
      LDI   R0, OS_KBSR
      BRzp  GETC_SEED_LOOP

      LD    R0, SEED_MASK
      AND   R1, R1, R0

      LDI   R0, OS_KBDR       ; get character
      ST    R1, RAND_SEED     ; save R1 to seed
      ST    R1, RAND_INIT     ; save initial for debugging

      LDR   R1, R6, #0        ; restore R1
      ADD   R6, R6, #1
      RET

; data
      OS_KBSR     .FILL xFE00
      OS_KBDR     .FILL xFE02
      SEED_MASK   .FILL x7FFF

;--------------------------------------------------------------------------
; PROMPT
; Prompts the user to choose position (0-9)
; Returns r0 = 0-8
;--------------------------------------------------------------------------

PROMPT
      STR   R0, R6, #-1       ; save registers
      STR   R1, R6, #-2
      STR   R7, R6, #-3
      ADD   R6, R6, #-3

PROMPT_LOOP                   ; prompt until valid value is provided
      LDR   R0, R6, #2
      PUTS

      JSR   GETC_SEED
      OUT

      ADD   R1, R0, #0
      LD    R0, NEW_LINE
      OUT

      ADD   R0, R1, #0
      BRnz  PROMPT_INVALID            ; TODO check free spots
      LD    R0, PROMPT_RESPONSE_max
      ADD   R0, R0, R1
      BRp   PROMPT_INVALID
      ADD   R0, R0, #8
      ADD   R2, R5, #0
      ADD   R2, R2, R0
      LDR   R2, R2, #0
      BRp   PROMPT_INVALID
      BR    PROMPT_EXIT

PROMPT_INVALID
      ADD   R0, R1, #0
      OUT
      LEA   R0, PROMPT_INVALID_MESSAGE
      PUTS
      BRnzp PROMPT_LOOP

PROMPT_EXIT
      LDR   R7, R6, #0        ; restore registers
      LDR   R1, R6, #1
      ADD   R6, R6, #3
      AND   R2, R2, #0
      RET

; data
      PROMPT_INVALID_MESSAGE  .STRINGZ    " is not a valid input.\n\n"
      PROMPT_RESPONSE_max     .FILL #-57


;--------------------------------------------------------------------------
; MOD_DIV
; Performs r0 % r1 and r0/r1.
; Returns r0 = remainder, r1 = quotient
;--------------------------------------------------------------------------

MOD_DIV
      STR   R1, R6, #-1       ; save registers
      STR   R2, R6, #-2
      STR   R3, R6, #-3
      ADD   R6, R6, #-3

      NOT   R2, R1
      ADD   R2, R2, #1
      BRz   MOD_DIV_EX        ; halt if dividing by zero

      AND   R1, R1, #0        ; clear R1 (quotient)

MOD_DIV_LOOP
      ADD   R1, R1, #1
      ADD   R0, R0, R2        ; R0 -= R1
      BRp MOD_DIV_LOOP        ; R0 - R1 > 0, so keep looping
      BRz MOD_DIV_END         ; R0 = 0, so we finished exactly

                              ; R0 < 0, so we subtracted an extra one
      LDR   R2, R6, #2        ; add it back in
      ADD   R1, R1, #-1
      ADD   R0, R0, R2

MOD_DIV_END
      LDR   R3, R6, #0
      LDR   R2, R6, #1
      ADD   R6, R6, #3
      RET

MOD_DIV_EX
      HALT

;--------------------------------------------------------------------------
; MULT
; Performs multiplication using bit shifting
; Returns r0 = r0 * r1
;--------------------------------------------------------------------------

MULT
      ADD   R0, R0, #0
      BRz   MULT_ZERO   ; return 0 if R0 = 0
      ADD   R1, R1, #0
      BRz   MULT_ZERO   ; return 0 if R1 = 0

      STR   R1, R6, #-1 ; save registers
      STR   R2, R6, #-2 ; save registers
      STR   R3, R6, #-3
      STR   R4, R6, #-4
      ADD   R6, R6, #-4

      AND   R2, R2, #0  ; clear R2 (product)
      ADD   R3, R2, #1  ; set R3 = 1 (bit tester)

MULT_LOOP               ; for each bit in R0
      AND   R4, R0, R3        ; R4 = bit test(R0, R3)
      BRnz  #1                ; only execute next line if bit is set
      ADD   R2, R2, R1              ; product = product + R1
      ADD   R1, R1, R1        ; R1 << 1
      ADD   R3, R3, R3        ; R3 << 1
      BRp   MULT_LOOP

      ADD   R0, R2, #0  ; move product to R0

MULT_END
      LDR   R4, R6, #0  ; restore registers
      LDR   R3, R6, #1
      LDR   R2, R6, #2
      LDR   R1, R6, #3
      ADD   R6, R6, #4
      RET

MULT_ZERO
      AND   R0, R0, #0
      RET

.END
