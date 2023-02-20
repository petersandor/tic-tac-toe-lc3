;
; Yes I copied the random number generator. Sorry.
;

.ORIG x3000

MAIN
      LEA R0,WELCOME_MESSAGE
      PUTS
      JSR DRAW_BOARD
      JSR ADD_RANDOM_X
      HALT

ADD_RANDOM_X
      STR R7, R6, #-1     ; save registers
      ADD R6, R6, #-1

      ADD R0,R4,#8
      JSR RAND_MOD

ADD_RANDOM_EXIT
      LDR   R7, R6, #0
      ADD   R6, R6, #1
      RET

DRAW_BOARD
      STR R7, R6, #-1     ; save registers
      ADD R6, R6, #-1

      LEA R0,SPACER
      PUTS
      LEA R0,GAME_STATE
      PUTS
      LEA R0,SPACER
      PUTS
      LEA R0,VERT_DIV
      PUTS
      LEA R0,SPACER
      PUTS
      LEA R0,GAME_STATE
      ADD R0,R0,#2
      PUTS
      LEA R0,SPACER
      PUTS
      LEA R0,VERT_DIV
      PUTS
      LEA R0,SPACER
      PUTS
      LEA R0,GAME_STATE
      ADD R0,R0,#4
      PUTS
      LEA R0,SPACER_END
      PUTS
      LEA R0,HOR_DIV
      PUTS
      LEA R0,SPACER
      PUTS
      LEA R0,GAME_STATE
      ADD R0,R0,#6
      PUTS
      LEA R0,SPACER
      PUTS
      LEA R0,VERT_DIV
      PUTS
      LEA R0,SPACER
      PUTS
      LEA R0,GAME_STATE
      ADD R0,R0,#8
      PUTS
      LEA R0,SPACER
      PUTS
      LEA R0,VERT_DIV
      PUTS
      LEA R0,SPACER
      PUTS
      LEA R0,GAME_STATE
      ADD R0,R0,#10
      PUTS
      LEA R0,SPACER_END
      PUTS
      LEA R0,HOR_DIV
      PUTS
      LEA R0,SPACER
      PUTS
      LEA R0,GAME_STATE
      ADD R0,R0,#12
      PUTS
      LEA R0,SPACER
      PUTS
      LEA R0,VERT_DIV
      PUTS
      LEA R0,SPACER
      PUTS
      LEA R0,GAME_STATE
      ADD R0,R0,#14
      PUTS
      LEA R0,SPACER
      PUTS
      LEA R0,VERT_DIV
      PUTS
      LEA R0,SPACER
      PUTS
      LEA R0,GAME_STATE
      LEA R1,GAME_STATE_LEN
      ADD R1,R1,#-2
      ADD R0,R1,#0
      PUTS
      LEA R0,SPACER_END
      PUTS

DRAW_EXIT
      LDR   R7, R6, #0
      ADD   R6, R6, #1
      RET

;--------------------------------------------------------------------------
; RAND_MOD
;
; Generates random number between 0 and r0 - 1 inclusively
; Returns r0 = random number
;
; Project: rpendleton/lc3-2048
; Created by: Ryan Pendleton (Dec 2014)
; License: MIT (see accompanying LICENSE file)
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
; END: RAND_MOD
;--------------------------------------------------------------------------

;--------------------------------------------------------------------------
; MOD_DIV
; Performs r0 % r1 and r0/r1.
; Returns r0 = remainder, r1 = quotient
;
; Project: rpendleton/lc3-2048
; Created by: Ryan Pendleton (Dec 2014)
; License: MIT (see accompanying LICENSE file)
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
;
; Performs multiplication using bit shifting
; Returns r0 = r0 * r1
;
; Project: rpendleton/lc3-2048
; Created by: Ryan Pendleton (Dec 2014)
; License: MIT (see accompanying LICENSE file)
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

;--------------------------------------------------------------------------
; END: MULT
;--------------------------------------------------------------------------

; data

      SPACER            .STRINGZ " "
      SPACER_END        .STRINGZ " \n"
      HOR_DIV           .STRINGZ "-----------\n"
      VERT_DIV          .STRINGZ "|"

      WELCOME_MESSAGE   .STRINGZ "Welcome to LC-3 TTT minigame\n\n"

      ; Array of ASCII X/O chars separated by nulls
      GAME_STATE        .FILL #49
                        .FILL x0
                        .FILL #50
                        .FILL x0
                        .FILL #51
                        .FILL x0
                        .FILL #52
                        .FILL x0
                        .FILL #53
                        .FILL x0
                        .FILL #54
                        .FILL x0
                        .FILL #55
                        .FILL x0
                        .FILL #56
                        .FILL x0
                        .FILL #57
                        .FILL x0
      GAME_STATE_LEN    .FILL #17

      ; use later
      NEW_LINE          .FILL x0A
      SPACE             .FILL x20

.END
