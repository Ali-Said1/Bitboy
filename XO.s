    AREA GameConstants, DATA, READONLY
    EXPORT BOARDSTARTX
    EXPORT BOARDSTARTY
    EXPORT BOARDENDX
    EXPORT BOARDENDY
    EXPORT ROW_Y_START
    EXPORT ROW_ONE
    EXPORT ROW_TWO
    EXPORT COL_X_START
    EXPORT COL_ONE
    EXPORT COL_TWO
    EXPORT ROW_OR_COL_WIDTH
    EXPORT ROW_OR_COL_HEIGHT
    EXPORT BOARD_DIM

;;;;;;;;;; BOARD WITH 1 PIXEL FRAME IN CASE COLOR INSIDE FRAME AND OUTSIDE ;;;;;;;;;;;;;;
BOARDSTARTX      EQU     #0x0050
BOARDSTARTY      EQU     #0x0000
BOARDENDX        EQU     #0x0190
BOARDENDY        EQU     #0x0140





;;;;;;;;;;; ROW START AT 81 ,EACH AT DISTANCE 106 ;;;;;;;;;;
ROW_Y_START      EQU        #0x0001
ROW_ONE          EQU        #0x00B8
ROW_TWO          EQU        #0x0122


;;;;;;;;;;; COL START AT 81 ,EACH AT DISTANCE 106 ;;;;;;;;;;
COL_X_START     EQU         #0x0051         
COL_ONE         EQU         #0x0068
COL_TWO         EQU         #0x00D2

;;;;;;;;;;; ROW AND COL DIMENSIONS (NUMERICAL) ;;;;;;;;;;;;;;
ROW_OR_COL_HEIGHT     EQU     #0x013E
ROW_OR_COL_WIDTH      EQU     #0x0006

EMPTY_CELL    EQU     #0x0000
PLAYER_X          EQU     #0x0001
PLAYER_O          EQU     #0x0002
BOARD_DIM       EQU     #0x0140
    ALIGN


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
    ALIGN



    EXPORT XO_MAIN
    EXPORT INIT_GAME
    AREA MYCODE,CODE,READONLY
    ENTRY


XO_MAIN     FUNCTION

;DRAW BACKGROUND COLOR
;DRAW ROWS & COLUMNS

    BL INIT_GAME

MAIN_LOOP

    BL HANDLE_INPUT


;;;;;;;;;;;;;;; CHECK FOR NO ONE HAS WON ;;;;;;;;;;;;;;;;;;
;; TODO: this will be implemented in app.s
    LDR R0, =GAME_STATUS
    MOV R1, #0x0000
    CMP R1,[R0]
    BEQ MAIN_LOOP

    LDR R0, =GAME_STATUS
    MOV R1, #0x0001
    CMP R1,[R0]        
    BEQ X_WINS          ;FUNC X_WINS TO DISPLAY X WINS"NOT IMPLEMENTED"

    LDR R0, =GAME_STATUS
    MOV R1, #0x0002
    CMP R1,[R0]
    BEQ O_WINS          ;FUNC O_WINS TO DISPLAY X WINS"NOT IMPLEMENTED"

    LDR R0, =GAME_STATUS
    MOV R1, #0x0003
    CMP R1,[R0]
    BEQ D_DRAW              ;FUNC D_DRAW TO DISPLAY X WINS"NOT IMPLEMENTED"

;;;;;;;;;;;;;;;;;;;;;;;;; HERE TO RESET ;;;;;;;;;;;;;;;;;;;;;;;

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
    LDR     R1, =GAME_ONGOING
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
; HANDLE_INPUT
;     ;R2 >>> X-Coordinates
;     ;R3 >>> Y-Coordinates
;     ;R4 >>> Player_Num
;     PUSH {R0-R12,LR}

;     LDR R0, =CurrentPlayer
;     LDR R1, =PLAYER_X
;     CMP [R0],R1
;     BEQ CHECK_DRAW_X

;     LDR R0, =CurrentPlayer
;     LDR R1, =PLAYER_X
;     CMP [R0],R1
;     BEQ CHECK_DRAW_O

;     pop{R0-R12,PC}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_DRAW_X
    PUSH {R0-R12,LR}

    MOV R5,R2
    MOV R6,R3

    MOV R1,#0x0050
    CMP R1,R2
    BGE X_OUT_OF_RANGE
    
    MOV R1,#0x0051
    SUB R2,R2,R1
    MOV R1,#0x006A
    UDIV R2,R2,R1       ;;;; R2 HORIZONTAL INDEX

    CMP R3,#0x0001
    BEQ THIRD_ROW

    CMP R3,#0x006B
    BEQ SECOND_ROW

    CMP R3,#0x00D5
    BEQ FIRST_ROW

    B X_OUT_OF_RANGE

 ;;;; THIRD  0   1   2
 ;;;; SECOND 3   4   5
 ;;;; FIRST  6   7   8

THIRD_ROW      

    MOV R0 ,#0x0000      ;;;;; 1 FOR X
    LDR R1, =GameBoard    
    CMP R0,[R1,R2]
    BNE X_OUT_OF_RANGE
    MOV R0 ,#0x0001           
    STR R0,[R1,R2]                 
    B X_DONE

SECOND_ROW

    MOV R0 ,#0x0000 
    LDR R1, =GameBoard
    MOV R3,#0x0003
    ADD R2 ,R2 ,R3
    CMP R0,[R1,R2]
    BNE X_OUT_OF_RANGE 
    MOV R0 ,#0x0001
    STR R0,[R1,R2]
    B X_DONE

FIRST_ROW

    MOV R0 ,#0x0000
    LDR R1, =GameBoard
    MOV R3,#0x0006
    ADD R2 ,R2 ,R3
    CMP R0,[R1,R2]
    BNE X_OUT_OF_RANGE 
    MOV R0 ,#0x0001
    STR R0,[R1,R2]
    B X_DONE

X_DONE
    BL DRAW_X   ;;;;;;;;;;;;;;;;;HERE TO CALL REAL DRAW
    LDR R0, =CurrentPlayer
    LDR R1, =PLAYER_O
    STRB R1, [R0]
X_OUT_OF_RANGE
    pop{R0-R12,PC}



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_DRAW_O
    PUSH {R0-R12,LR}

    MOV R5,R2
    MOV R6,R3

    MOV R1,#0x0050
    CMP R1,R2
    BGE O_OUT_OF_RANGE
    
    MOV R1,#0x0051
    SUB R2,R2,R1
    MOV R1,#0x006A
    UDIV R2,R2,R1       ;;;; R2 HORIZONTAL INDEX

    CMP R3,#0x0001
    BEQ THIRD_ROW

    CMP R3,#0x006B
    BEQ SECOND_ROW

    CMP R3,#0x00D5
    BEQ FIRST_ROW

    B O_OUT_OF_RANGE

 ;;;; THIRD  0   1   2
 ;;;; SECOND 3   4   5
 ;;;; FIRST  6   7   8

THIRD_ROW                           
    MOV R0 ,#0x0000     ;;;;; 2 FOR O
    LDR R1, =GameBoard
    CMP R0,[R1,R2]
    BNE O_OUT_OF_RANGE  
    MOV R0 ,#0x0002
    STR R0,[R1,R2]                  
    B O_DONE

SECOND_ROW

    MOV R0 ,#0x0000
    LDR R1, =GameBoard
    MOV R3,#0x0003
    ADD R2 ,R2 ,R3
    CMP R0,[R1,R2]
    BNE O_OUT_OF_RANGE 
    MOV R0 ,#0x0002
    STR R0,[R1,R2]
    B O_DONE

FIRST_ROW

    MOV R0 ,#0x0000
    LDR R1, =GameBoard
    MOV R3,#0x0006
    ADD R2 ,R2 ,R3
    CMP R0,[R1,R2]
    BNE O_OUT_OF_RANGE 
    MOV R0 ,#0x0002
    STR R0,[R1,R2]
    B O_DONE

O_DONE
    BL DRAW_O        ;;;;;;;;;;;;;;;;;HERE TO CALL REAL DRAW
    LDR R0, =CurrentPlayer
    LDR R1, =PLAYER_X
    STRB R1, [R0]
O_OUT_OF_RANGE
    pop{R0-R12,PC}


DRAW_X

    PUSH{R0-R12,LR}
    ;(1) - DRAW

    ;R5 >>> X-Coordinates
    ;R6 >>> Y-Coordinates
    
    ;(2) - CHECK FOR WINNING 
    BL CHECK_WINNING

    POP{R0-R12,PC}


DRAW_O

    PUSH{R0-R12,LR}
    ;(1) - DRAW

    ;R5 >>> X-Coordinates
    ;R6 >>> Y-Coordinates
    
    ;(2) - CHECK FOR WINNING 
    BL CHECK_WINNING

    POP{R0-R12,PC}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_WINNING
    PUSH{R0-R12,LR}

    LDR R0,=COUNTER
    LDR R1, [R0]
    CMP R1,#9
    BNE CHECK_THIRD_ROW
    LDR R0,=GAME_STATUS
    MOV R1,#0x0003
    STRB R1,[R0]
    B DRAW_DONE

CHECK_THIRD_ROW
    LDR R0, =GameBoard
    MOV R1,#0
    MOV R2,#1
    MOV R3,#2

    CMP [R0,R1],[R0,R2]
    BNE CHECK_SECOND_ROW

    CMP [R0,R2],[R0,R3]
    BNE CHECK_SECOND_ROW

    MOV R3,#0x0001
    CMP [R0,R2],R3
    BEQ X_IS_WINNING
    B O_IS_WINNING

CHECK_SECOND_ROW
    MOV R1,#3
    MOV R2,#4
    MOV R3,#5

    CMP [R0,R1],[R0,R2]
    BNE CHECK_FIRST_ROW

    CMP [R0,R2],[R0,R3]
    BNE CHECK_FIRST_ROW

    MOV R3,#0x0001
    CMP [R0,R2],R3
    BEQ X_IS_WINNING
    B O_IS_WINNING

CHECK_FIRST_ROW
    MOV R1,#6
    MOV R2,#7
    MOV R3,#8

    CMP [R0,R1],[R0,R2]
    BNE CHECK_FIRST_COL

    CMP [R0,R2],[R0,R3]
    BNE CHECK_FIRST_COL

    MOV R3,#0x0001
    CMP [R0,R2],R3
    BEQ X_IS_WINNING
    B O_IS_WINNING

    
CHECK_FIRST_COL
    MOV R1,#0
    MOV R2,#3
    MOV R3,#6

    CMP [R0,R1],[R0,R2]
    BNE CHECK_SECOND_COL

    CMP [R0,R2],[R0,R3]
    BNE CHECK_SECOND_COL

    MOV R3,#0x0001
    CMP [R0,R2],R3
    BEQ X_IS_WINNING
    B O_IS_WINNING

CHECK_SECOND_COL
    MOV R1,#1
    MOV R2,#4
    MOV R3,#7

    CMP [R0,R1],[R0,R2]
    BNE CHECK_THIRD_COL

    CMP [R0,R2],[R0,R3]
    BNE CHECK_THIRD_COL

    MOV R3,#0x0001
    CMP [R0,R2],R3
    BEQ X_IS_WINNING
    B O_IS_WINNING

CHECK_THIRD_COL
    MOV R1,#0
    MOV R2,#3
    MOV R3,#6

    CMP [R0,R1],[R0,R2]
    BNE TO_END

    CMP [R0,R2],[R0,R3]
    BNE TO_END

    MOV R3,#0x0001
    CMP [R0,R2],R3
    BEQ X_IS_WINNING
    B O_IS_WINNING

CHECK_FIRST_DIAG
    MOV R1,#0
    MOV R2,#4
    MOV R3,#8

    CMP [R0,R1],[R0,R2]
    BNE CHECK_SECOND_DIAG

    CMP [R0,R2],[R0,R3]
    BNE CHECK_SECOND_DIAG

    MOV R3,#0x0001
    CMP [R0,R2],R3
    BEQ X_IS_WINNING
    B O_IS_WINNING

CHECK_SECOND_DIAG
    MOV R1,#2
    MOV R2,#4
    MOV R3,#6

    CMP [R0,R1],[R0,R2]
    BNE TO_END

    CMP [R0,R2],[R0,R3]
    BNE TO_END

    MOV R3,#0x0001
    CMP [R0,R2],R3
    BEQ X_IS_WINNING
    B O_IS_WINNING

X_IS_WINNING
    LDR R0, =WINNER
    MOV R1,#0x0001
    STRB R1,[R0]
    LDR R0,=GAME_STATUS
    MOV R1,#0x0001
    STRB R1,[R0]
    B TO_END

O_IS_WINNING
    LDR R0, =WINNER
    MOV R1,#0x0002
    LDR R0,=GAME_STATUS
    MOV R1,#0x0002
    STRB R1,[R0]
    B TO_END

TO_END
    LDR R0, =COUNTER
    LDR R1, [R0]
    ADD R1, R1, #1
    STR R1, [R0]
DRAW_DONE
    POP{R0-R12,PC}

END