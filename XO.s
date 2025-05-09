
;;;;;;;;;; BOARD WITH 1 PIXEL FRAME IN CASE COLOR INSIDE FRAME AND OUTSIDE ;;;;;;;;;;;;;;
BOARDSTARTX      EQU     0x0050
BOARDSTARTY      EQU     0x0000
BOARDENDX        EQU     0x0190
BOARDENDY        EQU     0x0140





;;;;;;;;;;; ROW START AT 81 ,EACH AT DISTANCE 106 ;;;;;;;;;;
ROW_Y_START      EQU        0x0001
ROW_ONE          EQU        0x00B8
ROW_TWO          EQU        0x0122


;;;;;;;;;;; COL START AT 81 ,EACH AT DISTANCE 106 ;;;;;;;;;;
COL_X_START     EQU         0x0051         
COL_ONE         EQU         0x0068
COL_TWO         EQU         0x00D2

;;;;;;;;;;; ROW AND COL DIMENSIONS (NUMERICAL) ;;;;;;;;;;;;;;
ROW_OR_COL_HEIGHT     EQU     0x013E
ROW_OR_COL_WIDTH      EQU     0x0006

EMPTY_CELL    EQU     0x0000
PLAYER_X      EQU     0x0001
PLAYER_O      EQU     0x0002
BOARD_DIM     EQU     0x0140
    

        AREA VECTORS, CODE, READONLY
        EXPORT  __Vectors
__Vectors
        DCD     0x20005000          ; Initial SP value (top of 400KB simulated SRAM)
        DCD     Reset_Handler       ; Reset handler address


    AREA GameData, DATA, READWRITE
    EXPORT GameBoard
    EXPORT CurrentPlayer   
    EXPORT WINNER
    EXPORT COUNTER
    EXPORT GAME_STATUS
    EXPORT ACTIVE_CELL
GameBoard       SPACE   9       ; 3x3 game board (1 byte per cell, each cell 0 = free, 1 = X, 2 = O)
CurrentPlayer   DCB     0x0     ; Current player (X=1, O=2)
COUNTER         DCB   0x0       ; Counter for the number of moves made
GAME_STATUS     DCB   0x0       ; Game status (0 =ongoing, 1 = X wins, 2 =O wins, 3 =draw)
ACTIVE_CELL     DCB   0x0       ; Active cell (1-9)
WINNER          DCB   0x0       ; Winner (1 = X, 2 = O, 0 = none)
    ALIGN




    AREA MYCODE,CODE,READONLY
    EXPORT XO_MAIN
    EXPORT INIT_GAME
    EXPORT Reset_Handler
    ENTRY
Reset_Handler
    BL XO_MAIN


XO_MAIN     FUNCTION

    ; DRAW BACKGROUND COLOR
    ; DRAW ROWS & COLUMNS

    BL INIT_GAME

MAIN_LOOP
    BL HANDLE_INPUT

    ;;;;;;;;;;;;;;; CHECK FOR NO ONE HAS WON ;;;;;;;;;;;;;;;;;;
    LDR R0, =GAME_STATUS
    LDRB R1, [R0]
    CMP R1, #0
    BEQ MAIN_LOOP

    CMP R1, #1
    ; BEQ X_WINS          ; TODO: implement this (Display X Wins)

    CMP R1, #2
    ; BEQ O_WINS          ; TODO: implement this (Display O Wins)

    CMP R1, #3
    ; BEQ D_DRAW          ; TODO: implement this (Dsplay Draw)

    ;;;;;;;;;;;;;;;;;;;;;;;;; RESET OR HALT ;;;;;;;;;;;;;;;;;;;;;;
    B .                   ; halt here
    ENDFUNC

;;;;;;;;;;;; Clear Data , Set start up Player to X , Set Ongoing Game ;;;;;;;;;;;;
INIT_GAME FUNCTION
    push{R0-R12,LR}

    LDR     R0, =GameBoard
    MOV     R1, #0
    
INTI_BOARD_LOOP
    CMP     R1, #9
    BEQ     INIT_DONE
    LDR     R2, =EMPTY_CELL
    STRB    R2, [R0, R1]
    ADD     R1, R1, #1
    B       INTI_BOARD_LOOP

INIT_DONE

    ;Set player X as starting player
    LDR     R0, =CurrentPlayer
    LDR     R1, =PLAYER_X
    STRB    R1, [R0]
    
    ;Set game status to ongoing
    LDR     R0, =GAME_STATUS
    MOV     R1, #0
    STRB    R1, [R0]

    LDR     R0, =WINNER
    MOV     R1, #0x0000
    STRB    R1, [R0]

    ;INTIALIZE COUNTER
    LDR     R0, =COUNTER
    MOV     R1, #0x0000
    STRB    R1, [R0]

    pop {R0-R12,LR}
    BX LR
    ENDFUNC

; TODO: Update this implementation
HANDLE_INPUT FUNCTION
    
    PUSH {R0-R12,LR}

    LDR R0, =CurrentPlayer
    LDRB R1, [R0]
    CMP R1, #1
    BEQ CHECK_DRAW_X

    LDR R0, =CurrentPlayer
    LDRB R1, [R0]
    CMP R1, #2
    BEQ CHECK_DRAW_O

    pop{R0-R12,PC}
    ENDFUNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_DRAW_X    FUNCTION
    PUSH {R0-R12,LR}

    LDR R1, =GameBoard
    LDR R2, =ACTIVE_CELL
    LDRB R3, [R2]            ; R3 = index
    MOV R4, #0
    ADD R4, R1, R3
    LDR R0, =PLAYER_X
    STRB R0,[R4] 

    BL DRAW_X        ;;;;;;;;;;;;;;;;;HERE TO CALL REAL DRAW
    LDR R0, =CurrentPlayer
    MOV R1, #2
    STRB R1, [R0]

    pop{R0-R12,PC}
    ENDFUNC


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_DRAW_O    FUNCTION
    PUSH {R0-R12,LR}

    LDR R1, =GameBoard
    LDR R2, =ACTIVE_CELL
    LDRB R3, [R2]            ; R3 = index
    MOV R4, #0
    ADD R4, R1, R3
    LDR R0, =PLAYER_O
    STRB R0,[R4] 

    BL DRAW_O        ;;;;;;;;;;;;;;;;;HERE TO CALL REAL DRAW
    LDR R0, =CurrentPlayer
    MOV R1, #1
    STRB R1, [R0]

    pop{R0-R12,PC}
    ENDFUNC

DRAW_X  FUNCTION

    PUSH{R0-R12,LR}
    ;(1) - DRAW
    
    ;(2) - CHECK FOR WINNING 
    BL CHECK_WINNING

    POP{R0-R12,PC}
    ENDFUNC

DRAW_O  FUNCTION

    PUSH{R0-R12,LR}
    ;(1) - DRAW

    ;R5 >>> X-Coordinates
    ;R6 >>> Y-Coordinates
    
    ;(2) - CHECK FOR WINNING 
    BL CHECK_WINNING

    POP{R0-R12,PC}
    ENDFUNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_WINNING   FUNCTION
    PUSH{R0-R12,LR}

    LDR R0,=COUNTER
    LDR R1, [R0]
    CMP R1, #9
    BNE CHECK_THIRD_ROW
    LDR R0,=GAME_STATUS
    MOV R1,#0x0003
    STRB R1,[R0]
    B DRAW_DONE

CHECK_THIRD_ROW
    LDR R0, =GameBoard     ; Load base address
    LDRB R1, [R0, #0]       ; Load byte at offset 0
    LDRB R2, [R0, #1]       ; Load byte at offset 1
    LDRB R3, [R0, #2]       ; Load byte at offset 2


    CMP R1, R2
    BNE CHECK_SECOND_ROW

    CMP R2, R3
    BNE CHECK_SECOND_ROW

    CMP R2, #1
    BEQ X_IS_WINNING
    CMP R2, #2
    BEQ O_IS_WINNING

CHECK_SECOND_ROW
    LDR R0, =GameBoard     ; Load base address
    LDRB R1, [R0, #3]       ; Load byte at offset 3
    LDRB R2, [R0, #4]       ; Load byte at offset 4
    LDRB R3, [R0, #5]       ; Load byte at offset 5

    CMP R1, R2
    BNE CHECK_FIRST_ROW

    CMP R2, R3
    BNE CHECK_FIRST_ROW

    CMP R2, #1
    BEQ X_IS_WINNING
    CMP R2, #2
    BEQ O_IS_WINNING

CHECK_FIRST_ROW
    LDR R0, =GameBoard     ; Load base address
    LDRB R1, [R0, #6]       ; Load byte at offset 6
    LDRB R2, [R0, #7]       ; Load byte at offset 7
    LDRB R3, [R0, #8]       ; Load byte at offset 8

    CMP R1, R2
    BNE CHECK_FIRST_COL

    CMP R2, R3
    BNE CHECK_FIRST_COL

    CMP R2, #1
    BEQ X_IS_WINNING
    CMP R2, #2
    BEQ O_IS_WINNING

    
CHECK_FIRST_COL
    LDR R0, =GameBoard     ; Load base address
    LDRB R1, [R0, #0]       ; Load byte at offset 0
    LDRB R2, [R0, #3]       ; Load byte at offset 3
    LDRB R3, [R0, #6]       ; Load byte at offset 6

    CMP R1, R2
    BNE CHECK_SECOND_COL

    CMP R2, R3
    BNE CHECK_SECOND_COL

    CMP R2, #1
    BEQ X_IS_WINNING
    CMP R2, #2
    BEQ O_IS_WINNING

CHECK_SECOND_COL
    LDR R0, =GameBoard     ; Load base address
    LDRB R1, [R0, #1]       ; Load byte at offset 1
    LDRB R2, [R0, #4]       ; Load byte at offset 4
    LDRB R3, [R0, #7]       ; Load byte at offset 7

    CMP R1, R2
    BNE CHECK_THIRD_COL

    CMP R2, R3
    BNE CHECK_THIRD_COL

    CMP R2, #1
    BEQ X_IS_WINNING
    CMP R2, #2
    BEQ O_IS_WINNING

CHECK_THIRD_COL
    LDR R0, =GameBoard     ; Load base address
    LDRB R1, [R0, #2]       ; Load byte at offset 2
    LDRB R2, [R0, #5]       ; Load byte at offset 5
    LDRB R3, [R0, #8]       ; Load byte at offset 8

    CMP R1, R2
    BNE TO_END

    CMP R2, R3
    BNE TO_END

    CMP R2, #1
    BEQ X_IS_WINNING
    CMP R2, #2
    BEQ O_IS_WINNING

CHECK_FIRST_DIAG
    LDR R0, =GameBoard     ; Load base address
    LDRB R1, [R0, #0]       ; Load byte at offset 0
    LDRB R2, [R0, #4]       ; Load byte at offset 4
    LDRB R3, [R0, #8]       ; Load byte at offset 8

    CMP R1, R2
    BNE CHECK_SECOND_DIAG

    CMP R3, R2
    BNE CHECK_SECOND_DIAG

    CMP R2, #1
    BEQ X_IS_WINNING
    CMP R2, #2
    BEQ O_IS_WINNING

CHECK_SECOND_DIAG
    LDR R0, =GameBoard     ; Load base address
    LDRB R1, [R0, #2]       ; Load byte at offset 2
    LDRB R2, [R0, #4]       ; Load byte at offset 4
    LDRB R3, [R0, #6]       ; Load byte at offset 6

    CMP R1, R2
    BNE TO_END

    CMP R2, R3
    BNE TO_END

    CMP R2, #1
    BEQ X_IS_WINNING
    CMP R2, #2
    BEQ O_IS_WINNING
    
    B TO_END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
X_IS_WINNING
    LDR R0, =WINNER
    MOV R1,#1
    STRB R1,[R0]
    LDR R0,=GAME_STATUS
    MOV R1, #1
    STRB R1,[R0]
    B TO_END

O_IS_WINNING
    LDR R0, =WINNER
    MOV R1,#2
    LDR R0,=GAME_STATUS
    MOV R1, #2
    STRB R1,[R0]
    B TO_END

TO_END
    LDR R0, =COUNTER
    LDR R1, [R0]
    ADD R1, R1, #1
    STR R1, [R0]
DRAW_DONE
    POP{R0-R12,PC}
    ENDFUNC

    END
