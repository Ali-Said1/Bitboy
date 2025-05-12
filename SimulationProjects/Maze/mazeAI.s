; ------------------------------------------------------------------
; Maze generation on Cortex-M3 (ARMASM syntax)
; Bit-packed 30x40 grid, explicit DFS stack, minimal RAM footprint
; ------------------------------------------------------------------
		AREA    VECTORS, CODE, READONLY
        EXPORT  __Vectors
__Vectors
        DCD     0x20005000          ; Initial SP value (top of 400KB simulated SRAM)
        DCD     Reset_Handler   ; Reset handler address



                AREA    Maze_Data, DATA, READWRITE
; configuration constants
ROWS            EQU     30
COLS            EQU     40
CELLS           EQU     (ROWS/2)*(COLS/2)        ; ~=300
GRID_BYTES      EQU     (ROWS*COLS+7)/8         ; =150 bytes
STACK_ENTRIES   EQU     CELLS
; memory
grid            SPACE   GRID_BYTES              ; bit-array: 1=wall,0=path
stack           SPACE   STACK_ENTRIES*4         ; each entry r<<8|c (32-bit)
stack_ptr       DCD     stack                  ; pointer to next free
rng_seed        DCD     1                       ; simple LCG seed

; direction tables
                AREA    Maze_Tables, READONLY, DATA
dr_table        DCB     2, -2, 0, 0
dc_table        DCB     0, 0, 2, -2
lcg_mul         DCD     1103515245
lcg_add         DCD     12345

                AREA    Maze_Code, CODE, READONLY
                THUMB
                EXPORT  Reset_Handler

;-----------------------------------------------
; void MazeGenerate(void)
; fills 'grid' with maze (0=path,1=wall)
;-----------------------------------------------
Reset_Handler
; init grid to 0xFF
                LDR     R0, =grid
                MOVS    R1, #GRID_BYTES
InitLoop        MOVS    R2, #0xFF
                STRB    R2, [R0], #1
                SUBS    R1, R1, #1
                BNE     InitLoop
; clear start cell (1,1)
                MOVS    R0, #1
                MOVS    R1, #1
                BL      MazeClearCell
; push (1,1)
                MOVS    R0, #1
                MOVS    R1, #1
                BL      MazePush
MainLoop        BL      MazeStackEmpty       ; Z=1 if empty
                BEQ     DoneGenerate
                BL      MazePop               ; R0=r, R1=c
                BL      MazeCarveCell         ; carve neighbors
                B       MainLoop
DoneGenerate    POP     {LR}
                BX      LR
                ENDP

;-----------------------------------------------
; Helper routines: Stack, RNG, Bit ops, Carving
;-----------------------------------------------

MazeStackEmpty  PROC            ; returns Z=1 if empty
                PUSH    {LR}
                LDR     R0, =stack_ptr
                LDR     R1, [R0]
                LDR     R2, =stack
                CMP     R1, R2
                POP     {PC}
                ENDP

MazePush        PROC
                ; R0=r, R1=c
                PUSH    {R2-R4,LR}
                LSLS    R2, R0, #8         ; r<<8
                ORRS    R2, R2, R1         ; |c
                LDR     R3, =stack_ptr
                LDR     R4, [R3]
                STR     R2, [R4]           ; store entry
                ADD     R4, R4, #4
                STR     R4, [R3]
                POP     {R2-R4,PC}
                ENDP

MazePop         PROC               ; R0=r, R1=c
                PUSH    {R2-R4,LR}
                LDR     R3, =stack_ptr
                LDR     R4, [R3]
                SUB     R4, R4, #4
                STR     R4, [R3]
                LDR     R2, [R4]
                MOV     R0, R2, LSR #8     ; r
                UXTB    R1, R2             ; c
                POP     {R2-R4,PC}
                ENDP

MazeRand4       PROC               ; R0 = (seed>>16)&3
                PUSH    {R1-R3,LR}
                LDR     R1, =rng_seed
                LDR     R2, [R1]
                LDR     R3, =lcg_mul
                MUL     R2, R2, R3
                LDR     R3, =lcg_add
                ADDS    R2, R2, R3
                STR     R2, [R1]
                MOV     R0, R2, LSR #16
                ANDS    R0, R0, #3
                POP     {R1-R3,PC}
                ENDP

MazeTestCell    PROC               ; test bit, Z=1 if wall/unvisited
                PUSH    {R2-R6,LR}
                ; compute idx = r*COLS + c
                MOV     R2, R0
                LSL     R3, R2, #5         ; r*32
                LSL     R2, R2, #3         ; r*8
                ADDS    R2, R3, R2         ; r*40
                ADDS    R2, R2, R1         ; +c
                MOV     R3, R2, LSR #3     ; byte index
                AND     R4, R2, #7         ; bit pos
                LDR     R5, =grid
                LDRB    R6, [R5, R3]
                LSR     R6, R6, R4
                AND     R6, R6, #1
                CMP     R6, #1             ; Z=1 if bit==1
                POP     {R2-R6,PC}
                ENDP

MazeClearCell   PROC               ; clear bit → 0
                PUSH    {R2-R7,LR}
                ; idx = r*40 + c (as above)
                MOV     R2, R0
                LSL     R3, R2, #5
                LSL     R2, R2, #3
                ADDS    R2, R3, R2
                ADDS    R2, R2, R1
                MOV     R3, R2, LSR #3
                AND     R4, R2, #7
                LDR     R5, =grid
                LDRB    R6, [R5, R3]
                MOV     R7, #1
                LSL     R7, R7, R4
                BIC     R6, R6, R7         ; clear bit
                STRB    R6, [R5, R3]
                POP     {R2-R7,PC}
                ENDP

MazeCarveCell  PROC               ; carve from R0=r, R1=c
                PUSH    {R4-R11,LR}
                MOV     R6, R0             ; r_cur
                MOV     R7, R1             ; c_cur
                MOVS    R2, #0             ; tried mask
CarveLoop       BL      MazeRand4
                MOV     R3, R0             ; dir
                MOV     R4, #1
                LSL     R4, R4, R3         ; mask = 1<<dir
                TST     R2, R4
                BNE     NextDir
                ; compute nr, nc
                LDR     R5, =dr_table
                LDRSB   R8, [R5, R3]
                LDR     R5, =dc_table
                LDRSB   R9, [R5, R3]
                ADDS    R8, R6, R8
                ADDS    R9, R7, R9
                CMP     R8, #ROWS
                BHS     NextDir
                CMP     R9, #COLS
                BHS     NextDir
                ; test neighbor
                MOV     R0, R8
                MOV     R1, R9
                BL      MazeTestCell
                BEQ     NextDir
                ; clear wall between
                ADDS    R10, R6, R8
                LSRS    R10, R10, #1
                ADDS    R11, R7, R9
                LSRS    R11, R11, #1
                MOV     R0, R10
                MOV     R1, R11
                BL      MazeClearCell
                ; clear neighbor
                MOV     R0, R8
                MOV     R1, R9
                BL      MazeClearCell
                ; push current & neighbor
                MOV     R0, R6
                MOV     R1, R7
                BL      MazePush
                MOV     R0, R8
                MOV     R1, R9
                BL      MazePush
                B       CarveDone
NextDir         ORR     R2, R2, R4         ; mark tried
                CMP     R2, #15            ; all 4 tried?
                BNE     CarveLoop
CarveDone       POP     {R4-R11,PC}
                END

            
