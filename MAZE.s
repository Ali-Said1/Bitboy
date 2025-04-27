        AREA MAZECONST, DATA, READONLY
        EXPORT  MAZEGEN_WALL
        EXPORT  MAZEGEN_PATH
        EXPORT  MAZE_HEIGHT
        EXPORT  MAZE_WIDTH
        EXPORT  MAZE_BLOCK_DIM

MAZEGEN_WALL      EQU 1       ; Wall cell
MAZEGEN_PATH      EQU 0       ; Path cell
MAZE_HEIGHT      EQU 11       
MAZE_WIDTH      EQU 11
MAZE_BLOCK_DIM      EQU 5       ; Half block size in pixels
    ALIGN
        AREA MAZEVARS, DATA, READWRITE
		EXPORT MAZE_layout
		EXPORT MAZE_pos
		EXPORT MAZE_prng_state

MAZE_layout      SPACE MAZE_WIDTH*MAZE_HEIGHT   ; Maze layout (0=path, 1=wall)
MAZE_pos      DCW 0x0000                        ; XXYY
MAZE_prng_state
    DCB     0x12                          ; Initial seed for the PRNG

        AREA MAZEGENCODE, CODE, READONLY
        EXPORT MAZE_GENERATE



; Function: get_random
; Inputs: R3 = max - 1
; Outputs: R0 = [0, R3 -1]
get_random  FUNCTION
    PUSH    {R1-R5, LR}        ; Save R4, R5, and LR

    ; Save R3 (range bound)
    MOV    R5, R3              ; R5 = R3 (preserve R3)

    ; Generate random number
    ; Load PRNG state
    LDR     R4, =MAZE_prng_state     ; R4 = address of prng_state
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
    MOV    R0, R2              ; R0 = random number

    UDIV R0,R0, R3
    MUL  R5, R3, R0   ; Rtemp = Rm × Ra
    SUB  R0, R2, R5   ; Rd = Rn - Rtemp



    POP     {R1-R5, LR}        ; Restore R4, R5, and return
    BX LR
    ENDFUNC
; Function: MAZE_GENERATE
; Generates a random maze using Depth-First Search with backtracking
; This replaces the current maze layout with a randomly generated one
MAZE_GENERATE FUNCTION
        PUSH    {R0-R12, LR}
        
        ; Initialize maze with all walls
        LDR     R0, =MAZE_layout
        MOV     R1, #MAZE_WIDTH*MAZE_HEIGHT
        MOV     R2, #MAZEGEN_WALL
init_maze_loop
        STRB    R2, [R0], #1
        SUBS    R1, R1, #1
        BNE     init_maze_loop
        
        
        MOV     R5, #1         ; Starting Y
        ; Start at position (1,1) (to ensure there's a wall border)
        MOV     R4, #1          ; Starting X
        LSL     R4, R4, #8
        ADD     R4, R5          ; Starting Y
        ; R4 XXYY

        BL     dfs_loop
        B       generation_complete
        

dfs_loop
        PUSH {R4, LR}
        ; R4 = X, R5 = Y of current cell
        MOV     R5, R4
        AND     R5, #0xFF ; Y = current Y
        LSR     R4, R4, #8 ; X = current X
dfs_rloop
        ; Mark start position as path

        LDR     R0, =MAZE_layout
        MOV     R1, #MAZE_WIDTH
        MUL     R1, R5, R1
        ADD     R1, R1, R4
        ADD     R0, R0, R1
        MOV     R2, #MAZEGEN_PATH
        STRB    R2, [R0]


        ; Check for unvisited neighbors
        BL      MAZEGEN_GET_UNVISITED_NEIGHBOR
        ; R0 = has neighbor?, R1 = direction (0=N, 1=E, 2=S, 3=W)
        CMP     R0, #0
        BEQ     backtrack
        CMP     R4, #MAZE_WIDTH - 2
        CMPEQ   R5, #MAZE_HEIGHT - 2
        BEQ     backtrack
        ; Calculate wall position between current and neighbor
        CMP     R1, #0          ; North?
        BEQ     process_north
        CMP     R1, #1          ; East?
        BEQ     process_east
        CMP     R1, #2          ; South?
        BEQ     process_south
        B       process_west    ; West
        
process_north
        
        MOV     R0, R4          ; Wall X = current X
        SUB     R1, R5, #1      ; Wall Y = current Y - 1
        MOV     R3, #MAZE_WIDTH
        MUL     R3, R1, R3      ; y*width
        ADD     R3, R3, R0      ; y*width + x
        LDR     R1, =MAZE_layout
        ADD     R1, R1, R3
        MOV     R3, #MAZEGEN_PATH
        STRB    R3, [R1]        ; Set path at wall
        

        
        SUB R5, #2
        B      next
process_east
        ; Wall at (x+1, y)
        ADD     R0, R4, #1      ; Wall X = current X + 1
        MOV     R1, R5          ; Wall Y = current Y
        MOV     R3, #MAZE_WIDTH
        MUL     R3, R1, R3      ; y*width
        ADD     R3, R3, R0      ; y*width + x
        LDR     R1, =MAZE_layout
        ADD     R1, R1, R3
        MOV     R3, #MAZEGEN_PATH
        STRB    R3, [R1]        ; Set path at wall
        

        ADD R4, #2
        B      next
process_south
        ; Wall at (x, y+1)
        MOV     R0, R4          ; Wall X = current X
        ADD     R1, R5, #1      ; Wall Y = current Y + 1
        MOV     R3, #MAZE_WIDTH
        MUL     R3, R1, R3      ; y*width
        ADD     R3, R3, R0      ; y*width + x
        LDR     R1, =MAZE_layout
        ADD     R1, R1, R3
        MOV     R3, #MAZEGEN_PATH
        STRB    R3, [R1]        ; Set path at wall

        ADD R5, R5, #2
        B       next
process_west
        ; Wall at (x-1, y)
        SUB     R0, R4, #1      ; Wall X = current X - 1
        MOV     R1, R5          ; Wall Y = current Y
        MOV     R3, #MAZE_WIDTH
        MUL     R3, R1, R3      ; y*width
        ADD     R3, R3, R0      ; y*width + x
        LDR     R1, =MAZE_layout
        ADD     R1, R1, R3
        MOV     R3, #MAZEGEN_PATH
        STRB    R3, [R1]        ; Set path at wall
        
        SUB R4, R4, #2
        B next



        
backtrack
        LSL     R4, R4, #8
        ADD     R4, R5          ; Starting Y
        POP {R4, LR}
        BX      LR
next
        LSL     R4, R4, #8
        ADD     R4, R5          ; Starting Y
        BL       dfs_loop
        MOV     R5, R4
        AND     R5, #0xFF ; Y = current Y
        LSR     R4, R4, #8 ; X = current X
        B       dfs_rloop
generation_complete
        POP    {R0-R12, LR}
		MOV R0, #0
        BX LR





;Working
;; Function: MAZEGEN_GET_UNVISITED_NEIGHBOR
;; Finds a random unvisited neighbor of current cell
;; Input: R4=X, R5=Y
;; Output: R0=1 if neighbor found, 0 if none found
;;         R1=direction (0=N, 1=E, 2=S, 3=W)
MAZEGEN_GET_UNVISITED_NEIGHBOR FUNCTION
        PUSH    {LR}
        MOV     R11, #0             ; Array of valid neighbors
        MOV     R10, #0             ; Number of valid neighbors
        ; Check North neighbor (x, y-2)
        CMP     R5, #2             ; Must be at least at y=2 to have north wall
        BLT     check_east
        
        ; Check if cell is visited
        SUB     R7, R5, #2         ; Y = current Y - 2
        MOV     R6, R4             ; X = current X
        
        MOV     R1, #MAZE_WIDTH
        MUL     R1, R7, R1         ; Y * width
        ADD     R1, R1, R6         ; Y * width + X
        LDR     R2, =MAZE_layout
        ADD     R2, R2, R1
        LDRB    R1, [R2]           ; R1 = visited state
        CMP     R1, #MAZEGEN_WALL
        BNE     check_east
        
        ; North is valid, add to array
        MOV     R1, #0             ; North direction
        MOV     R0, #1
        ADD     R10, R10, #1             ; Increment valid neighbors count
        LSL    R11, #4             ; Shift left to make space for new neighbor
        ORR    R11, R11, R0
        LSL    R11, #4             ; Shift left to make space for new neighbor
        ORR    R11, R11, R1             ; Add North direction to valid neighbors array
check_east
        ; Check East neighbor (x+2, y)
        ADD     R6, R4, #2         ; X = current X + 2
        MOV     R7, R5             ; Y = current Y
        
        CMP     R6, #MAZE_WIDTH-1  ; Must be within bounds
        BGE     check_south
        
        ; Check if cell is visited
        MOV     R1, #MAZE_WIDTH
        MUL     R1, R7, R1         ; Y * width
        ADD     R1, R1, R6         ; Y * width + X
        LDR     R2, =MAZE_layout
        ADD     R2, R2, R1
        LDRB    R1, [R2]           ; R1 = visited state
        CMP     R1, #MAZEGEN_WALL
        BNE     check_south
        
        ; East is valid, add to array
        MOV     R1, #1             ; East direction
        MOV     R0, #1
        ADD     R10, R10, #1             ; Increment valid neighbors count
        LSL    R11, #4             ; Shift left to make space for new neighbor
        ORR    R11, R11, R0
        LSL    R11, #4             ; Shift left to make space for new neighbor
        ORR    R11, R11, R1             ; Add North direction to valid neighbors array
check_south
        ; Check South neighbor (x, y+2)
        MOV     R6, R4             ; X = current X
        ADD     R7, R5, #2         ; Y = current Y + 2
        
        CMP     R7, #MAZE_HEIGHT-1 ; Must be within bounds
        BGE     check_west
        
        ; Check if cell is visited
        MOV     R1, #MAZE_WIDTH
        MUL     R1, R7, R1         ; Y * width
        ADD     R1, R1, R6         ; Y * width + X
        LDR     R2, =MAZE_layout
        ADD     R2, R2, R1
        LDRB    R1, [R2]           ; R1 = visited state
        CMP     R1, #MAZEGEN_WALL
        BNE     check_west
        
        ; South is valid, add to array
        MOV     R1, #2             ; South direction
        MOV     R0, #1
        ADD     R10, R10, #1             ; Increment valid neighbors count
        LSL    R11, #4             ; Shift left to make space for new neighbor
        ORR    R11, R11, R0
        LSL    R11, #4             ; Shift left to make space for new neighbor
        ORR    R11, R11, R1             ; Add North direction to valid neighbors array
check_west
        ; Check West neighbor (x-2, y)
        SUB     R6, R4, #2         ; X = current X - 2
        MOV     R7, R5             ; Y = current Y
        
        CMP     R6, #1             ; Must be at least at x=1
        BLT     process_neighbors
        
        ; Check if cell is visited
        MOV     R1, #MAZE_WIDTH
        MUL     R1, R7, R1         ; Y * width
        ADD     R1, R1, R6         ; Y * width + X
        LDR     R2, =MAZE_layout
        ADD     R2, R2, R1
        LDRB    R1, [R2]           ; R1 = visited state
        CMP     R1, #MAZEGEN_WALL
        BNE     process_neighbors
        
        ; West is valid, add to array
        MOV     R1, #3             ; West direction
        MOV     R0, #1
        ADD     R10, R10, #1             ; Increment valid neighbors count
        LSL    R11, #4             ; Shift left to make space for new neighbor
        ORR    R11, R11, R0
        LSL    R11, #4             ; Shift left to make space for new neighbor
        ORR    R11, R11, R1             ; Add North direction to valid neighbors array
process_neighbors
        ; Check if any valid neighbors were found
        CMP     R10, #0
        BEQ     no_neighbors
        
        ; Choose a random direction
        
        
        MOV     R3, R10             ; Max value = 4 (number of directions)
        BL      get_random 
        MOV     R9, R0
        MOV     R0, #1
        
        MOV    R8, #8
        MUL    R9, R9, R8
        LSR    R11, R9
        MOV    R1, R11
        AND    R1,#0xF

neighbor_found
        MOV     R0, #1             ; Found a neighbor
        POP     {LR}
        BX      LR
        
no_neighbors
        MOV     R0, #0             ; No neighbors found
        POP     {LR}
        BX      LR

    ENDFUNC

    END