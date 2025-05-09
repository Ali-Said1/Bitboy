    AREA XOCONST,DATA,READONLY
    EXPORT BOARD_DIM
    EXPORT XO_O_COLOR
    EXPORT XO_X_COLOR
    EXPORT XO_HOVER_COLOR
    EXPORT XO_WALL_COLOR
    EXPORT XO_BCK_COLOR
EMPTY_CELL    EQU     0x0000
PLAYER_X      EQU     0x0001
PLAYER_O      EQU     0x0002
BOARD_DIM     EQU     0x0140
XO_HOVER_COLOR EQU 0xB59E
XO_WALL_COLOR EQU 0x1C16
XO_BCK_COLOR EQU 0xEF7C

XO_O_COLOR EQU 0x5C49
XO_X_COLOR EQU 0x2066
    ALIGN

    AREA GameData, DATA, READWRITE
    EXPORT GameBoard
    EXPORT CurrentPlayer
    EXPORT GAME_STATUS
    EXPORT ACTIVE_CELL
GameBoard       SPACE   9       ; 3x3 game board (1 byte per cell, each cell 0 = free, 1 = X, 2 = O)
CurrentPlayer   DCB     0x0     ; Current player (X=1, O=2)
COUNTER         DCB   0x0       ; Counter for the number of moves made
GAME_STATUS     DCB   0x0       ; Game status (0 =ongoing, 1 = X wins, 2 =O wins, 3 =draw)
ACTIVE_CELL     DCB   0x0       ; Active cell (0-8)
WINNER          DCB   0x0       ; Winner (1 = X, 2 = O, 0 = none)
    ALIGN




    AREA MYCODE,CODE,READONLY
    EXPORT XO_MAIN
    EXPORT XO_INIT_GAME
    EXPORT CHECK_DRAW_X
    EXPORT CHECK_DRAW_O
    EXPORT CHECK_WINNING
    ENTRY
XO_MAIN     FUNCTION

    ; DRAW BACKGROUND COLOR
    ; DRAW ROWS & COLUMNS

    BL XO_INIT_GAME

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
XO_INIT_GAME FUNCTION
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

    LDR R0, =ACTIVE_CELL
    MOV R1, #0
    STRB R1, [R0]
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

    LDR R0, =CurrentPlayer
    MOV R1, #1
    STRB R1, [R0]

    pop{R0-R12,PC}
    ENDFUNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_WINNING   FUNCTION
    PUSH{R0-R12,LR}
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
    BNE CHECK_FIRST_DIAG

    CMP R2, R3
    BNE CHECK_FIRST_DIAG

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
    LDRB R1, [R0]
    ADD R1, R1, #1
    STRB R1, [R0]
    CMP R1, #9
    BNE DRAW_DONE
    LDR R0,=GAME_STATUS
    MOV R1,#3
    STRB R1,[R0]
DRAW_DONE
    POP{R0-R12,PC}
    ENDFUNC

    END
