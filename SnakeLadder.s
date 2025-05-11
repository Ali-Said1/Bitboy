    AREA RESET, DATA, READONLY
    EXPORT __Vectors

__Vectors
    DCD 0x20001000         ; Initial Stack Pointer (set appropriately)
    DCD Reset_Handler      ; Reset vector

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    AREA SNAKE_LADDER_CONST, DATA, READONLY
    EXPORT PLAYER_ONE_COLOR
    EXPORT PLAYER_TWO_COLOR
    EXPORT CELL_COLOR
    EXPORT WALL_COLOR
    EXPORT LADDER_ONE_POS
    EXPORT LADDER_TWO_POS
    EXPORT LADDER_THREE_POS
    EXPORT SNAKE_ONE_POS
    EXPORT SNAKE_TWO_POS
    EXPORT SNAKE_THREE_POS

ONGOING_GAME        EQU     0x0000
PLAYER_ONE          EQU     0x0001
PLAYER_TWO          EQU     0x0002
BOARD_DIM           EQU     0x0140
CELL_COLOR          EQU     0x1C16
WALL_COLOR          EQU     0x1C16
PLAYER_ONE_COLOR    EQU     0x5C49
PLAYER_TWO_COLOR    EQU     0x2066
LADDER_COLOR        EQU     0x1C16
SNAKE_COLOR         EQU     0x1C16

LADDER_ONE_POS      EQU     0x1551
LADDER_TWO_POS      EQU     0x0624
LADDER_THREE_POS    EQU     0x1D45
SNAKE_ONE_POS       EQU     0x3911
SNAKE_TWO_POS       EQU     0x5C2A
SNAKE_THREE_POS     EQU     0x2814

    ALIGN

    AREA SNAKE_LADDER_DATA, DATA, READWRITE
    EXPORT CurrentPlayer
    EXPORT PLAYER_ONE_POS
    EXPORT PLAYER_TWO_POS
    EXPORT GAME_STATUS
    EXPORT PLAYER_MOVES

SNAKE_LADDER_prng_state      DCD     0x12       ; Initial seed for the PRNG
CurrentPlayer        DCB   0x0
PLAYER_ONE_POS       DCB   0x0
PLAYER_TWO_POS       DCB   0x0
GAME_STATUS          DCB   0x0
PLAYER_MOVES         DCB   0x0


    ALIGN





    AREA MYCODE,CODE,READONLY
    EXPORT Reset_Handler
    EXPORT MAIN_LOOP
    EXPORT SNAKE_LADDER_INIT_GAME
    EXPORT INCREMENT_POSITION
    EXPORT CHECK_LADDER_START
    EXPORT CHECK_SNAKE_START
    EXPORT CHECK_WINNING
    ENTRY

    
Reset_Handler     FUNCTION

    BL SNAKE_LADDER_INIT_GAME

MAIN_LOOP
    BL GET_PLAYER_MOVES
    BL INCREMENT_POSITION
    BL CHECK_LADDER_START
    BL CHECK_SNAKE_START
    BL TOGGLE_PLAYER

    LDR R0,=GAME_STATUS
    LDRB R0,[R0]
    CMP R0,#0
    BEQ MAIN_LOOP


    B .
    ENDFUNC

SNAKE_LADDER_INIT_GAME     FUNCTION
    PUSH{R0-R12,LR}

    ;Set start player to player 1
    LDR R0,=CurrentPlayer
    LDR R1,=PLAYER_ONE
    STRB R1,[R0]
    ;set ongoing game
    LDR R0,=GAME_STATUS
    LDR R1,=ONGOING_GAME
    STRB R1,[R0]
    ;Set players position to cell 1
    LDR R0, =PLAYER_ONE_POS
    MOV R1, #1
    STRB R1, [R0]
    LDR R0, =PLAYER_TWO_POS
    STRB R1, [R0]
    
    
    POP{R0-R12,PC}
    ENDFUNC
;################################# INCREMENT PLAYER POSITION #############################
INCREMENT_POSITION     FUNCTION
    PUSH{R0-R12,LR}

    LDR R0,=PLAYER_MOVES
    LDRB R0,[R0]

    LDR R1,=CurrentPlayer
    LDRB R1,[R1]
    CMP R1,#1
    BEQ INCREMENT_FOR_0NE
    B INCREMENT_FOR_TWO
INCREMENT_FOR_0NE
    LDR R1,=PLAYER_ONE_POS
    LDRB R3,[R1]
    ADD R2,R3,R0
    CMP R2,#100
    BGE ONE_EQ_MAX
    STRB R2,[R1]
    B DONE
ONE_EQ_MAX
    MOV R2,#100
    STRB R2,[R1]

    LDR R0,=GAME_STATUS
    LDR R1,=PLAYER_ONE
    STRB R1,[R0]
    B DONE
;#########################################
INCREMENT_FOR_TWO
    LDR R1,=PLAYER_TWO_POS
    LDRB R3,[R1]
    ADD R2,R3,R0
    CMP R2,#100
    BGE TWO_EQ_MAX
    STRB R2,[R1]
    B DONE
TWO_EQ_MAX
    MOV R2,#100
    STRB R2,[R1]
    LDR R0,=GAME_STATUS
    LDR R1,=PLAYER_TWO
    STRB R1,[R0]
    B DONE
DONE 
    POP{R0-R12,LR}
    BX LR
    ENDFUNC



;################################# TOGGLE PLAYER ####################################
TOGGLE_PLAYER     FUNCTION
    PUSH{R0-R12,LR}
    MOV R0,#0x3
    LDR R1,=CurrentPlayer
    LDR R2,[R1]
    EOR R2 ,R2 ,R0
    STRB R2,[R1]
    POP {R0-R12,LR}
    BX LR
    ENDFUNC

;################################# CHECK LADDER START ####################################
CHECK_LADDER_START     FUNCTION
    PUSH{R0-R12,LR}

    LDR R0,=CurrentPlayer
    LDRB R0,[R0]
    CMP R0,#1
    BEQ CHECK_P_ONE_LADDER
    CMP R0,#2
    BEQ CHECK_P_TWO_LADDER
    B TO_END_LADDER

CHECK_P_ONE_LADDER
    LDR R0,=PLAYER_ONE_POS
    LDRB R3, [R0]
    LDR R1,=LADDER_ONE_POS
    LSR R2, R1, #8
    CMP R3, R2 
    BEQ UPDATE_POS_LADDER

    LDR R1,=LADDER_TWO_POS
    LSR R2, R1, #8
    CMP R3, R2 
    BEQ UPDATE_POS_LADDER

    LDR R1,=LADDER_THREE_POS
    LSR R2, R1, #8
    CMP R3, R2 
    BEQ UPDATE_POS_LADDER

    B TO_END_LADDER

CHECK_P_TWO_LADDER
    LDR R0,=PLAYER_TWO_POS
    LDRB R3, [R0]
    LDR R1,=LADDER_ONE_POS
    LSR R2, R1, #8
    CMP R3, R2 
    BEQ UPDATE_POS_LADDER

    LDR R1,=LADDER_TWO_POS
    LSR R2, R1, #8
    CMP R3, R2 
    BEQ UPDATE_POS_LADDER

    LDR R1,=LADDER_THREE_POS
    LSR R2, R1, #8
    CMP R3, R2 
    BEQ UPDATE_POS_LADDER

    B TO_END_LADDER

UPDATE_POS_LADDER
    AND R1 ,R1 ,#0x00FF
    STRB R1 ,[R0]
TO_END_LADDER
    POP{R0-R12,PC}
    ENDFUNC
;################################### CHECK SNAKE START ###################################
CHECK_SNAKE_START      FUNCTION
    PUSH{R0-R12,LR}

    LDR R0,=CurrentPlayer
    LDRB R0,[R0]
    CMP R0,#1
    BEQ CHECK_P_ONE_SNAKE
    CMP R0,#2
    BEQ CHECK_P_TWO_SNAKE
    B TO_END_SNAKE

CHECK_P_ONE_SNAKE
    LDR R0,=PLAYER_ONE_POS
    LDRB R3, [R0]
    LDR R1,=SNAKE_ONE_POS
    LSR R2, R1, #8
    CMP R3, R2 
    BEQ UPDATE_POS_SNAKE

    LDR R1,=SNAKE_TWO_POS
    LSR R2, R1, #8
    CMP R3, R2 
    BEQ UPDATE_POS_SNAKE

    LDR R1,=SNAKE_THREE_POS
    LSR R2, R1, #8
    CMP R3, R2 
    BEQ UPDATE_POS_SNAKE

    B TO_END_SNAKE
    
CHECK_P_TWO_SNAKE
    LDR R0,=PLAYER_TWO_POS
    LDRB R3, [R0]
    LDR R1,=SNAKE_ONE_POS
    LSR R2, R1, #8
    CMP R3, R2 
    BEQ UPDATE_POS_SNAKE

    LDR R1,=SNAKE_TWO_POS
    LSR R2, R1, #8
    CMP R3, R2 
    BEQ UPDATE_POS_SNAKE

    LDR R1,=SNAKE_THREE_POS
    LSR R2, R1, #8
    CMP R3, R2 
    BEQ UPDATE_POS_SNAKE

    B TO_END_SNAKE

UPDATE_POS_SNAKE
    AND R1 ,R1 ,#0x00FF
    STRB R1 ,[R0]
TO_END_SNAKE
    POP{R0-R12,PC}
    ENDFUNC
CHECK_WINNING      FUNCTION
    PUSH{R0-R12,LR}

    LDR R0,=CurrentPlayer
    LDRB R0,[R0]
    CMP R0,#1
    BEQ CHECK_FOR_PLAYER_ONE
    B CHECK_FOR_PLAYER_TWO

CHECK_FOR_PLAYER_ONE
    LDR R0,=PLAYER_ONE_POS
    LDRB R0,[R0]
    CMP R0,#100
    BEQ PLAYER_ONE_WINS
    B NO_WINNING
PLAYER_ONE_WINS
    LDR R0,=GAME_STATUS
    LDR R1,=PLAYER_ONE
    STRB R1,[R0]
    B NO_WINNING

CHECK_FOR_PLAYER_TWO
    LDR R0,=PLAYER_TWO_POS
    LDRB R0,[R0]
    CMP R0,#100
    BEQ PLAYER_TWO_WINS
    B NO_WINNING
PLAYER_TWO_WINS
    LDR R0,=GAME_STATUS
    LDR R1,=PLAYER_TWO
    STRB R1,[R0]
    B NO_WINNING

NO_WINNING
    POP{R0-R12,PC}
    ENDFUNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Function: get_random
; Inputs: R3 = max + 1
; Outputs: R0 = [0, R3 - 1]
get_random  FUNCTION
    PUSH    {R1-R5, LR}        ; Save R4, R5, and LR

    ; Save R3 (range bound)
    MOV    R5, R3              ; R5 = R3 (preserve R3)

    ; Generate random number
    ; Load PRNG state
    LDR     R4, =SNAKE_LADDER_prng_state     ; R4 = address of prng_state
    LDR     R0, [R4]            ; R0 = current state

    ; Compute: state = state * 1664525
    MOV    R1, #0x60D          ; Lower 16 bits of multiplier
    MOVT    R1, #0x196          ; Upper 16 bits of multiplier
    MUL    R2, R0, R1          ; R2 = state * 1664525 (low 32 bits)

    ; Add increment: 1013904223 = 0x3C6EF35F
    MOV    R1, #0xF35F         ; Lower 16 bits of increment
    MOVT    R1, #0x3C6E         ; Upper 16 bits of increment
    ADD    R2, R2, R1          ; R2 = R2 + 1013904223 (mod 2^32 via overflow)

    ; Store new state
    STR     R2, [R4]            ; prng_state = new state

    ; Move result to R0
    MOV    R0, R2               ; R0 = random number

    UDIV R0,R0, R3
    MUL  R5, R3, R0   ; Rtemp = Rm × Ra
    SUB  R0, R2, R5   ; Rd = Rn - Rtemp



    POP     {R1-R5, LR}        ; Restore R4, R5, and return
    BX LR
    ENDFUNC

GET_PLAYER_MOVES FUNCTION
    PUSH{R0-R12,LR}
    MOV  R3, #6
    BL get_random
    ADD R0, R0, #1
    LDR R5,=PLAYER_MOVES
    STRB R0, [R5]
    POP{R0-R12,LR}
    BX LR
    ENDFUNC
	END