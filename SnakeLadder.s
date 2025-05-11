AREA SNAKE_LADDER_CONST,DATA,READONLY
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

ONGOING_GAME    EQU     0x0000
PLAYER_ONE      EQU     0x0001
PLAYER_TWO      EQU     0x0002
BOARD_DIM       EQU     0x0140
CELL_COLOR      EQU     0x1C16
WALL_COLOR      EQU     0x1C16
PLAYER_ONE_COLOR EQU    0x5C49
PLAYER_TWO_COLOR EQU    0x2066
LADDER_COLOR      EQU   0x1C16
SNAKE_COLOR      EQU    0x1C16
LADDER_ONE_POS         EQU   0x1551    ; Start cell and End cell of first Ladder position
LADDER_TWO_POS         EQU   0x0624    ; Start cell and End cell of second Ladder position
LADDER_THREE_POS       EQU   0x1D45    ; Start cell and End cell of third Ladder position
SNAKE_ONE_POS          EQU   0x3911    ; Start cell and End cell of first snake position
SNAKE_TWO_POS          EQU   0x5C2A    ; Start cell and End cell of second snake position
SNAKE_THREE_POS        EQU   0x2814    ; Start cell and End cell of third snake position

    ALIGN

    AREA SNAKE_LADDER_CONST, DATA, READWRITE
    EXPORT CurrentPlayer
    EXPORT PLAYER_ONE_POS
    EXPORT PLAYER_TWO_POS
    EXPORT GAME_STATUS
    EXPORT PLAYER_MOVES
CurrentPlayer          DCB   0x0       ; Current player (X=1, O=2)
PLAYER_ONE_POS         DCB   0x0       ; Position of player 1
PLAYER_TWO_POS         DCB   0x0       ; Position of player 2
GAME_STATUS            DCB   0x0       ; Game status (0 =ongoing, 1 = X wins, 2 =O wins, 3 =draw)
PLAYER_MOVES           DCB   0x06       ; Number of Random moves of the player
    ALIGN




    AREA MYCODE,CODE,READONLY
    EXPORT SNAKE_LADDER_MAIN
    EXPORT SNAKE_LADDER_INIT_GAME
    EXPORT INCREMENT_POSITION
    EXPORT CHECK_LADDER_START
    EXPORT CHECK_SNAKE_START
    EXPORT INCREMENT_POSITION
    EXPORT CHECK_WINNING
    ENTRY
SNAKE_LADDER_MAIN     FUNCTION

    BL SNAKE_LADDER_INIT_GAME

MAIN_LOOP
    BL INCREMENT_POSITION
    BL CHECK_LADDER_START
    BL CHECK_SNAKE_START

    LDR R0,=GAME_STATUS
    LDR R0,[R0]
    CMP R0,#0
    BEQ MAIN_LOOP


    B .
    ENDFUNC

SNAKE_LADDER_INIT_GAME     FUNCTION
    PUSH{R0-R12,LR}

    ;Set start player to player 1
    LDR R0,=CurrentPlayer
    LDR R1,=PLAYER_ONE
    STR R1,[R0]
    ;set ongoing game
    LDR R0,=GAME_STATUS
    LDR R1,=ONGOING_GAME
    STR R1,[R0]
    ;Set players position to cell 1
    LDR R0, =PLAYER_ONE_POS
    LDR R1, #1
    STR R1, [R0]
    LDR R0, =PLAYER_TWO_POS
    STR R1, [R0]
    
    POP{R0-R12,PC}
    ENDFUNC
################################# INCREMENT PLAYER POSITION #############################
INCREMENT_POSITION     FUNCTION
    PUSH{R0-R12,LR}

    LDR R0,=PLAYER_MOVES
    LDR R0,[R0]
    LDR R1,=CurrentPlayer
    LDR R1,[R1]
    CMP R1,#1
    BEQ INCREMENT_FOR_0NE
    B INCREMENT_FOR_TWO
INCREMENT_FOR_0NE
    LDR R1,=PLAYER_ONE_POS
    LDR R1,[R1]
    ADD R2,R1,R0
    CMP R2,#100
    BGE EQ_MAX
    STRB R2,[R1]
    B DONE
ONE_EQ_MAX
    MOV R2,#100
    STRB R2,[R1]

    LDR R0,=GAME_STATUS
    LDR R1,=PLAYER_ONE
    STRB R1,[R0]
    B DONE
#########################################
INCREMENT_FOR_TWO
    LDR R1,=PLAYER_TWO_POS
    LDR R1,[R1]
    ADD R2,R1,R0
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
DONE ############## TOGGLE PLAYER #####################
    MOV R0,0x11
    LDR R1,=CurrentPlayer
    LDR R2,[R1]
    XOR R2 ,R2 ,R0
    STRB R2,[R1]

    POP{R0-R12,PC}
    ENDFUNC

################################# CHECK LADDER START ####################################
CHECK_LADDER_START     FUNCTION
    PUSH{R0-R12,LR}

    LDR R0,=CurrentPlayer
    LDR R0,[R0]
    CMP R0,#1
    BEQ CHECK_P_ONE
    CMP R0,#2
    BEQ CHECK_P_TWO
    B TO_END

CHECK_P_ONE
    LDR R0,=PLAYER_ONE_POS
    LDR R0, [R0]
    LDR R1,=LADDER_ONE_POS
    LSR R2, R1, #8
    CMP R0, R2 
    BEQ UPDATE_POS_LADDER

    LDR R1,=LADDER_TWO_POS
    LSR R2, R1, #8
    CMP R0, R2 
    BEQ UPDATE_POS_LADDER

    LDR R1,=LADDER_THREE_POS
    LSR R2, R1, #8
    CMP R0, R2 
    BEQ UPDATE_POS_LADDER

    B TO_END

CHECK_P_TWO
    LDR R0,=PLAYER_TWO_POS
    LDR R0, [R0]
    LDR R1,=LADDER_ONE_POS
    LSR R2, R1, #8
    CMP R0, R2 
    BEQ UPDATE_POS_LADDER

    LDR R1,=LADDER_TWO_POS
    LSR R2, R1, #8
    CMP R0, R2 
    BEQ UPDATE_POS_LADDER

    LDR R1,=LADDER_THREE_POS
    LSR R2, R1, #8
    CMP R0, R2 
    BEQ UPDATE_POS_LADDER

    B TO_END

UPDATE_POS_LADDER
    AND R1 ,R1 ,0x00FF
    STRB R1 ,[R0]
TO_END
    POP{R0-R12,PC}
    ENDFUNC
################################### CHECK SNAKE START ###################################
CHECK_SNAKE_START      FUNCTION
    PUSH{R0-R12,LR}

    LDR R0,=CurrentPlayer
    LDR R0,[R0]
    CMP R0,#1
    BEQ CHECK_P_ONE
    CMP R0,#2
    BEQ CHECK_P_TWO
    B TO_END

CHECK_P_ONE
    LDR R0,=PLAYER_ONE_POS
    LDR R0, [R0]
    LDR R1,=SNAKE_ONE_POS
    LSR R2, R1, #8
    CMP R0, R2 
    BEQ UPDATE_POS_SNAKE

    LDR R1,=SNAKE_TWO_POS
    LSR R2, R1, #8
    CMP R0, R2 
    BEQ UPDATE_POS_SNAKE

    LDR R1,=SNAKE_THREE_POS
    LSR R2, R1, #8
    CMP R0, R2 
    BEQ UPDATE_POS_SNAKE

    B TO_END
    
CHECK_P_TWO
    LDR R0,=PLAYER_TWO_POS
    LDR R0, [R0]
    LDR R1,=SNAKE_ONE_POS
    LSR R2, R1, #8
    CMP R0, R2 
    BEQ UPDATE_POS_SNAKE

    LDR R1,=SNAKE_TWO_POS
    LSR R2, R1, #8
    CMP R0, R2 
    BEQ UPDATE_POS_SNAKE

    LDR R1,=SNAKE_THREE_POS
    LSR R2, R1, #8
    CMP R0, R2 
    BEQ UPDATE_POS_SNAKE

    B TO_END

UPDATE_POS_SNAKE
    AND R1 ,R1 ,0x00FF
    STRB R1 ,[R0]
TO_END
    POP{R0-R12,PC}
    ENDFUNC
CHECK_WINNING      FUNCTION
    PUSH{R0-R12,LR}

    LDR R0,=CurrentPlayer
    LDR R0,[R0]
    CMP R0,#1
    BEQ CHECK_FOR_PLAYER_ONE
    B CHECK_FOR_PLAYER_TWO

CHECK_FOR_PLAYER_ONE
    LDR R0,=PLAYER_ONE_POS
    LDR R0,[R0]
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
    LDR R0,[R0]
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
