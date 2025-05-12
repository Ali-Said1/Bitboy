
        EXPORT  MAZEGEN_WALL
        EXPORT  MAZEGEN_PATH
        EXPORT  MAZE_HEIGHT
        EXPORT  MAZE_WIDTH
        EXPORT  MAZEGEN_PATH_SOL

MAZEGEN_WALL      EQU 1       ; Wall cell
MAZEGEN_PATH      EQU 0       ; Path cell
MAZEGEN_PATH_VISITED      EQU 0x11       ; Visited
MAZE_HEIGHT      EQU 31       
MAZE_WIDTH      EQU 37      
MAZEGEN_PATH_SOL      EQU 2       ; SOLUTION PATH cell
        AREA    VECTORS, CODE, READONLY
        EXPORT  __Vectors
__Vectors
        DCD     0x20005000          ; Initial SP value (top of 400KB simulated SRAM)
        DCD     Reset_Handler   ; Reset handler address

    
        AREA MAZEVARS, DATA, READWRITE
		EXPORT MAZE_layout
		EXPORT MAZE_pos
		EXPORT MAZE_prng_state
                EXPORT MAZE_TIMER_MINUTE
                EXPORT MAZE_TIMER_SECOND
                EXPORT MAZE_SECOND_TIMER
                EXPORT MAZE_GAME_STATE
MAZE_layout      SPACE MAZE_WIDTH*MAZE_HEIGHT   ; Maze layout (0=path, 1=wall)
MAZE_pos      DCW 0x0000                        ; XXYY
MAZE_prng_state
    DCD     0x12                          ; Initial seed for the PRNG
MAZE_stack SPACE 2*MAZE_WIDTH*MAZE_HEIGHT
MAZE_stack_ptr  DCW	0x0

MAZE_TIMER_SECOND DCB 0
MAZE_TIMER_MINUTE DCB 5
MAZE_SECOND_TIMER DCW 0x3E8
MAZE_GAME_STATE DCB 0x0 ; 0 = playing, 1 = win, 2 = lose
        AREA MAZEGENCODE, CODE, READONLY
		EXPORT Reset_Handler
                EXPORT MAZE_GENERATE
Reset_Handler
        LDR     SP, =0x20005000          ; Initialize stack pointer
        BL      MAZE_RESET
        BL      MAZE_GENERATE
        BL      MAZE_SOLVER
        B       Reset_Handler


; check_win_condition
; I don't need to explain
; Outputs: Changes memory byte to indicate won state. (01)
check_win_condition FUNCTION ; Idk if this might cause naming problems with PONG.s
        PUSH {R0, R1, R4, R5, LR}
        LDR     R0, =MAZE_GAME_STATE
        MOV     R1, #0
        LDR     R4, =MAZE_pos
        LDRH    R4, [R4]
        MOV     R5, R4
        AND     R5, #0xFF ; R5 = current Y
        LSR     R4, R4, #8 ; R4 = current X
        CMP     R4, #MAZE_WIDTH - 2
        CMPEQ   R5, #MAZE_HEIGHT - 2
        MOVEQ   R1, #1
        STRBEQ  R1, [R0]
        POP {R0, R1, R4, R5, LR}
        BX LR
        ENDFUNC

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
    LTORG

MAZE_RESET FUNCTION
        PUSH    {R0-R1, LR}
        LDR     R0, =MAZE_pos
        MOV     R1, #0x0101
        STRH    R1, [R0]
        LDR R0, =MAZE_stack_ptr
        MOV R1, #0
        STRH R1, [R0]
        LDR R0, =MAZE_TIMER_MINUTE
        MOV R1, #5
        STRB R1, [R0]
        LDR R0, =MAZE_TIMER_SECOND
        MOV R1, #00
        STRB R1, [R0]
        LDR R0, =MAZE_GAME_STATE
        MOV R1, #0
        STRB R1, [R0]
        LDR R0, =MAZE_SECOND_TIMER
        MOV R1, #0x3E7
        STRH R1, [R0]
        POP    {R0-R1, LR}
        BX LR
        ENDFUNC
        LTORG
; Function: MAZE_GENERATE
; Generates a random maze using Depth-First Search with backtracking
; This replaces the current maze layout with a randomly generated one
MAZE_GENERATE FUNCTION
        PUSH    {R0-R12, LR}
        ;; Initialize the maze player position to (1,1)
        
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
        ; Pack XXYY in R4
        MOV     R4, #1          ; Starting X
        LSL     R4, R4, #8
        ADD     R4, R5          ; Starting Y
        ; R4 XXYY
        MOV     R11, #0         ; Path Found?
        BL     dfs_loop
        B       generation_complete
        

dfs_loop
        PUSH {LR}
		ADD     R9, #1
        CMP     R9, #10
        BGE     backtrack
        ; Manual Stack Push
        LDR R1, =MAZE_stack
        LDR R3, =MAZE_stack_ptr
        LDRH R2, [R3]
        ADD R1, R2
        STRH R4, [R1]
        ADD R2, #2
        STRH R2, [R3]
        
        ; Un-Pack XXYY from R4
        ; R4 = X, R5 = Y of current cell
        MOV     R5, R4
        AND     R5, #0xFF ; Y = current Y
        LSR     R4, R4, #8 ; X = current X
        MOV R8, #0
dfs_rloop
        ; This makes the end a point rather than part of a bigger passage.
        CMP     R4, #MAZE_WIDTH - 2
        CMPEQ   R5, #MAZE_HEIGHT - 2
        CMPEQ   R11, #0         ; Path Found?
        MOVEQ   R11, #1
        BEQ     backtrack
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

        CMP     R8, #1
        BNE     no_backtrack
        MOV     R6, R4
        LSL     R6, #8
        ORR     R6, R5 ; XXYY
        LDR R7, =MAZE_stack
        LDR R3, =MAZE_stack_ptr
        LDRH R2, [R3]
        ADD R7, R2
        STRH R6, [R7]
        ADD R2, #2
        STRH R2, [R3]
no_backtrack
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
        MOV R9, #0      ; Clear the nodes since last backtrack
        ; Pack XXYY in R4
        LSL     R4, R4, #8
        ADD     R4, R5          ; Starting Y
        
        
        ; Manual Stack Pop
        LDR R1, =MAZE_stack
        LDR R3, =MAZE_stack_ptr
        LDRH R2, [R3]
        SUB R2, #2
        STRH R2, [R3]
        ADD R1, R2
        LDRH R4, [R1]
        POP {LR}
        BX      LR
next
        ; Pack XXYY in R4
        LSL     R4, R4, #8
        ADD     R4, R5
        BL       dfs_loop
        ; Un-Pack XXYY from R4
        MOV     R5, R4
        AND     R5, #0xFF ; R5 = current Y
        LSR     R4, R4, #8 ; R4 = current X
        MOV R8, #1      ; Don't modify R8
        B       dfs_rloop
generation_complete
        POP    {R0-R12, LR}
        MOV R0, #0
        BX LR
    ENDFUNC
        LTORG
; SOLVER
; Traverses the map using dfs and finds the solution.
; Allow us to use some more time complexity so we can solve.
MAZE_SOLVER FUNCTION
        PUSH {R0-R12, LR}
        LDR R0, =MAZE_stack_ptr
        MOV R1, #0
        STRH R1, [R0]
        MOV R11, #0 ; Found Goal State: 0 = Not Found, 1 = Found

        MOV     R5, #1         ; Starting Y
        ; Start at position (1,1) (to ensure there's a wall border)
        MOV     R4, #1          ; Starting X
        LSL     R4, R4, #8
        ADD     R4, R5          ; Starting Y
        ; R4 XXYY
        BL dfs_sol_loop
        B found_goal
dfs_sol_loop
        PUSH {LR}


        LDR R1, =MAZE_stack
        LDR R3, =MAZE_stack_ptr
        LDRH R2, [R3]
        ADD R1, R2
        STRH R4, [R1]
        ADD R2, #2
        STRH R2, [R3]
        
        ; R4 = X, R5 = Y of current cell
        MOV     R5, R4
        AND     R5, #0xFF ; Y = current Y
        LSR     R4, R4, #8 ; X = current X
        MOV R8, #0
dfs_sol_rloop

        CMP R11, #1
        BEQ sol_backtrack
        ; Mark start position as path

	LDR     R0, =MAZE_layout
        MOV     R1, #MAZE_WIDTH
        MUL     R1, R5, R1
        ADD     R1, R1, R4
        ADD     R0, R0, R1
        MOV     R2, #MAZEGEN_PATH_SOL
        STRB    R2, [R0]


        ; Check for unvisited neighbors
        BL      MAZEGEN_GET_OPEN_NEIGHBOR
        ; R0 = has neighbor?, R1 = direction (0=N, 1=E, 2=S, 3=W)
        CMP     R4, #MAZE_WIDTH - 2
        CMPEQ   R5, #MAZE_HEIGHT - 2
        MOVEQ R11, #1
        BEQ.W     sol_backtrack
        CMP     R0, #0
        BEQ     sol_backtrack
        

        
        CMP     R8, #1
        BNE     no_sol_backtrack
        MOV     R6, R4
        LSL     R6, #8
        ORR     R6, R5 ; XXYY
        LDR R7, =MAZE_stack
        LDR R3, =MAZE_stack_ptr
        LDRH R2, [R3]
        ADD R7, R2
        STRH R6, [R7]
        ADD R2, #2
        STRH R2, [R3]
no_sol_backtrack
        ; Calculate wall position between current and neighbor
        CMP     R1, #0          ; North?
        BEQ     sol_process_north
        CMP     R1, #1          ; East?
        BEQ     sol_process_east
        CMP     R1, #2          ; South?
        BEQ     sol_process_south
        B       sol_process_west    ; West
        
sol_process_north
        
        MOV     R0, R4          ; Wall X = current X
        SUB     R1, R5, #1      ; Wall Y = current Y - 1
        MOV     R3, #MAZE_WIDTH
        MUL     R3, R1, R3      ; y*width
        ADD     R3, R3, R0      ; y*width + x
        LDR     R1, =MAZE_layout
        ADD     R1, R1, R3
        MOV     R3, #MAZEGEN_PATH_SOL
        STRB    R3, [R1]        ; Set path at wall
        

        
        SUB R5, #1
        B      sol_next
sol_process_east
        ; Wall at (x+1, y)
        ADD     R0, R4, #1      ; Wall X = current X + 1
        MOV     R1, R5          ; Wall Y = current Y
        MOV     R3, #MAZE_WIDTH
        MUL     R3, R1, R3      ; y*width
        ADD     R3, R3, R0      ; y*width + x
        LDR     R1, =MAZE_layout
        ADD     R1, R1, R3
        MOV     R3, #MAZEGEN_PATH_SOL
        STRB    R3, [R1]        ; Set path at wall
        

        ADD R4, #1
        B      sol_next
sol_process_south
        ; Wall at (x, y+1)
        MOV     R0, R4          ; Wall X = current X
        ADD     R1, R5, #1      ; Wall Y = current Y + 1
        MOV     R3, #MAZE_WIDTH
        MUL     R3, R1, R3      ; y*width
        ADD     R3, R3, R0      ; y*width + x
        LDR     R1, =MAZE_layout
        ADD     R1, R1, R3
        MOV     R3, #MAZEGEN_PATH_SOL
        STRB    R3, [R1]        ; Set path at wall

        ADD R5, R5, #1
        B       sol_next
sol_process_west
        ; Wall at (x-1, y)
        SUB     R0, R4, #1      ; Wall X = current X - 1
        MOV     R1, R5          ; Wall Y = current Y
        MOV     R3, #MAZE_WIDTH
        MUL     R3, R1, R3      ; y*width
        ADD     R3, R3, R0      ; y*width + x
        LDR     R1, =MAZE_layout
        ADD     R1, R1, R3
        MOV     R3, #MAZEGEN_PATH_SOL
        STRB    R3, [R1]        ; Set path at wall
        
        SUB R4, R4, #1
        B sol_next



        
sol_backtrack
        CMP R11, #1
        BEQ found_backtrack
        LDR     R0, =MAZE_layout
        MOV     R1, #MAZE_WIDTH
        MUL     R1, R5, R1
        ADD     R1, R1, R4
        ADD     R0, R0, R1
        CMP     R11, #0
        MOVEQ     R2, #MAZEGEN_PATH_VISITED
        STRBEQ    R2, [R0]
found_backtrack
        LSL     R4, R4, #8
        ADD     R4, R5          ; Starting Y
        POP {LR}
        LDR R1, =MAZE_stack
        LDR R3, =MAZE_stack_ptr
        LDRH R2, [R3]
        SUB R2, #2
        STRH R2, [R3]
        ADD R1, R2
        LDRH R4, [R1]
        
        BX      LR
sol_next
        LSL     R4, R4, #8
        ADD     R4, R5          ; Starting Y
        BL      dfs_sol_loop
        MOV     R5, R4
        AND     R5, #0xFF ; Y = current Y
        LSR     R4, R4, #8 ; X = current X
        MOV R8, #1
        B       dfs_sol_rloop
found_goal
        POP    {R0-R12, LR}
        MOV R0, #0
        BX LR
        ENDFUNC

        
;; Function: MAZEGEN_GET_OPEN_NEIGHBOR
;; Finds the first unvisited neighbor of current cell
;; Input: R4=X, R5=Y
;; Output: R0=1 if neighbor found, 0 if none found
;;         R1=direction (0=N, 1=E, 2=S, 3=W)
MAZEGEN_GET_OPEN_NEIGHBOR FUNCTION
        PUSH    {R11, LR}
        MOV     R11, #0             ; Array of valid neighbors
        MOV     R10, #0             ; Number of valid neighbors
        ; Check North neighbor (x, y-1)
        CMP     R5, #1             ; Must be at least at y=1 to have north wall
        BLT     sol_check_east
        
        ; Check if cell is visited
        SUB     R7, R5, #1         ; Y = current Y - 1
        MOV     R6, R4             ; X = current X
        
        MOV     R1, #MAZE_WIDTH
        MUL     R1, R7, R1         ; Y * width
        ADD     R1, R1, R6         ; Y * width + X
        LDR     R2, =MAZE_layout
        ADD     R2, R2, R1
        LDRB    R1, [R2]           ; R1 = visited state
        CMP     R1, #MAZEGEN_PATH
        BNE     sol_check_east
        
        ; North is valid, add to array
        MOV     R1, #0                  ; North direction
        MOV     R0, #1
        ADD     R10, R10, #1            ; Increment valid neighbors count
        LSL    R11, #4                  ; Shift left to make space for new neighbor
        ORR    R11, R11, R0
        LSL    R11, #4                  ; Shift left to make space for new neighbor
        ORR    R11, R11, R1             ; Add North direction to valid neighbors array
sol_check_east
        ; Check East neighbor (x+1, y)
        ADD     R6, R4, #1         ; X = current X + 1
        MOV     R7, R5             ; Y = current Y
        
        CMP     R6, #MAZE_WIDTH-1  ; Must be within bounds
        BGE     sol_check_south
        
        ; Check if cell is visited
        MOV     R1, #MAZE_WIDTH
        MUL     R1, R7, R1         ; Y * width
        ADD     R1, R1, R6         ; Y * width + X
        LDR     R2, =MAZE_layout
        ADD     R2, R2, R1
        LDRB    R1, [R2]           ; R1 = visited state
        CMP     R1, #MAZEGEN_PATH
        BNE     sol_check_south
        
        ; East is valid, add to array
        MOV     R1, #1             ; East direction
        MOV     R0, #1
        ADD     R10, R10, #1             ; Increment valid neighbors count
        LSL    R11, #4             ; Shift left to make space for new neighbor
        ORR    R11, R11, R0
        LSL    R11, #4             ; Shift left to make space for new neighbor
        ORR    R11, R11, R1             ; Add North direction to valid neighbors array
sol_check_south
        ; Check South neighbor (x, y+1)
        MOV     R6, R4             ; X = current X
        ADD     R7, R5, #1         ; Y = current Y + 1
        
        CMP     R7, #MAZE_HEIGHT-1 ; Must be within bounds
        BGE     sol_check_west
        
        ; Check if cell is visited
        MOV     R1, #MAZE_WIDTH
        MUL     R1, R7, R1         ; Y * width
        ADD     R1, R1, R6         ; Y * width + X
        LDR     R2, =MAZE_layout
        ADD     R2, R2, R1
        LDRB    R1, [R2]           ; R1 = visited state
        CMP     R1, #MAZEGEN_PATH
        BNE     sol_check_west
        
        ; South is valid, add to array
        MOV     R1, #2             ; South direction
        MOV     R0, #1
        ADD     R10, R10, #1             ; Increment valid neighbors count
        LSL    R11, #4             ; Shift left to make space for new neighbor
        ORR    R11, R11, R0
        LSL    R11, #4             ; Shift left to make space for new neighbor
        ORR    R11, R11, R1             ; Add North direction to valid neighbors array
sol_check_west
        ; Check West neighbor (x-1, y)
        SUB     R6, R4, #1         ; X = current X - 1
        MOV     R7, R5             ; Y = current Y
        
        CMP     R6, #0             ; Must be at least at x=0
        BLT     sol_process_neighbors
        
        ; Check if cell is visited
        MOV     R1, #MAZE_WIDTH
        MUL     R1, R7, R1         ; Y * width
        ADD     R1, R1, R6         ; Y * width + X
        LDR     R2, =MAZE_layout
        ADD     R2, R2, R1
        LDRB    R1, [R2]           ; R1 = visited state
        CMP     R1, #MAZEGEN_PATH
        BNE     sol_process_neighbors
        
        ; West is valid, add to array
        MOV     R1, #3             ; West direction
        MOV     R0, #1
        ADD     R10, R10, #1             ; Increment valid neighbors count
        LSL    R11, #4             ; Shift left to make space for new neighbor
        ORR    R11, R11, R0
        LSL    R11, #4             ; Shift left to make space for new neighbor
        ORR    R11, R11, R1             ; Add North direction to valid neighbors array
sol_process_neighbors
        ; Check if any valid neighbors were found
        CMP     R10, #0
        BEQ     sol_no_neighbors
        
        UXTB    R1, R11
        AND    R1,#0xF

sol_neighbor_found
        MOV     R0, #1             ; Found a neighbor
        POP     {R11,LR}
        BX      LR
        
sol_no_neighbors
        MOV     R0, #0             ; No neighbors found
        POP     {R11,LR}
        BX      LR

    ENDFUNC
        LTORG



;Working
;; Function: MAZEGEN_GET_UNVISITED_NEIGHBOR
;; Finds a random unvisited neighbor of current cell
;; Input: R4=X, R5=Y
;; Output: R0=1 if neighbor found, 0 if none found
;;         R1=direction (0=N, 1=E, 2=S, 3=W)
MAZEGEN_GET_UNVISITED_NEIGHBOR FUNCTION
        PUSH    {R9, LR}                ; I need to preserve R9
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
        
        ; Roll dice to finalise North if valid
        ;MOV     R3, #100             
        ;BL      get_random          ; R0 = Random Number [0, R3)
        ;MOV     R2, R0
        ;CMP     R2, #50
        ;MOVLT   R1, #0
        ;MOVLT   R0, #1
        ;BLT     neighbor_found


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
        
        
        BLT     neighbor_found

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
        
        ; Roll dice to finalise south if valid
        ;MOV     R3, #100             
        ;BL      get_random          ; R0 = Random Number [0, R3)
        ;MOV     R2, R0
        ;CMP     R2, #5
        ;MOVLT   R1, #2
        ;MOVLT   R0, #1 
        ;BLT     neighbor_found


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
        BL      get_random          ; R0 = Random Number [0, R3)
        MOV     R9, R0
        MOV     R0, #1
        
        MOV    R8, #8
        MUL    R9, R9, R8
        LSR    R11, R9
        MOV    R1, R11
        AND    R1,#0xF

neighbor_found
        MOV     R0, #1             ; Found a neighbor
        POP     {R9, LR}
        BX      LR
        
no_neighbors
        MOV     R0, #0             ; No neighbors found
        POP     {R9, LR}
        BX      LR

    ENDFUNC

; Function: MAZE_MOVE_LEFT
; Moves the current position left in the maze (decreases X by 1)
MAZE_MOVE_LEFT FUNCTION
        PUSH    {R0-R5, LR}
        LDR     R0, =MAZE_pos
        LDRH     R4, [R0]            ; current pos: high= X, low = Y
        MOV     R5, R4
        AND     R5, #0xFF           ; R5 = current Y
        LSR     R4, R4, #8          ; R4 = current X
        SUB     R4, R4, #1          ; new X = X - 1
        MOV     R1, #MAZE_WIDTH
        MUL     R1, R5, R1          ; R1 = Y * width
        ADD     R1, R1, R4          ; index = (Y * width + new X)
        LDR     R2, =MAZE_layout
        ADD     R2, R2, R1
        LDRB    R3, [R2]            ; Get cell state
        CMP     R3, #MAZEGEN_WALL
        BEQ     ret_move_left       ; If wall, do not update
        ; Update MAZE_pos: pack new X and current Y back together
        LSL     R4, R4, #8          ; newX << 8
        ORR     R4, R4, R5          ; new pos = (newX << 8) | Y
        STRH     R4, [R0]
        BL check_win_condition
ret_move_left
        POP     {R0-R5, LR}
        BX      LR
        ENDFUNC

; Function: MAZE_MOVE_RIGHT
; Moves the current position right in the maze (increases X by 1)
MAZE_MOVE_RIGHT FUNCTION
        PUSH    {R0-R5, LR}
        LDR     R0, =MAZE_pos
        LDRH     R4, [R0]            ; current pos: high= X, low = Y
        MOV     R5, R4
        AND     R5, #0xFF           ; R5 = current Y
        LSR     R4, R4, #8          ; R4 = current X
        ADD     R4, R4, #1          ; new X = X + 1
        MOV     R1, #MAZE_WIDTH
        MUL     R1, R5, R1          ; R1 = Y * width
        ADD     R1, R1, R4          ; index = (Y * width + new X)
        LDR     R2, =MAZE_layout
        ADD     R2, R2, R1
        LDRB    R3, [R2]            ; Get cell state
        CMP     R3, #MAZEGEN_WALL
        BEQ     ret_move_right      ; If wall, do not update
        ; Update MAZE_pos
        LSL     R4, R4, #8          ; newX << 8
        ORR     R4, R4, R5          ; new pos = (newX << 8) | Y
        STRH     R4, [R0]
        BL check_win_condition
ret_move_right
        POP     {R0-R5, LR}
        BX      LR
        ENDFUNC

; Function: MAZE_MOVE_UP
; Moves the current position up in the maze (decreases Y by 1)
MAZE_MOVE_UP FUNCTION
        PUSH    {R0-R5, LR}
        LDR     R0, =MAZE_pos
        LDRH     R4, [R0]            ; current pos: high= X, low = Y
        MOV     R5, R4
        LSR     R4, R4, #8          ; R4 = current X
        AND     R5, #0xFF           ; R5 = current Y
        SUB     R5, R5, #1          ; new Y = Y - 1
        MOV     R1, #MAZE_WIDTH
        MUL     R1, R5, R1          ; R1 = new Y * width
        ADD     R1, R1, R4          ; index = (new Y * width + X)
        LDR     R2, =MAZE_layout
        ADD     R2, R2, R1
        LDRB    R3, [R2]            ; Get cell state
        CMP     R3, #MAZEGEN_WALL
        BEQ     ret_move_up         ; If wall, do not update
        ; Update MAZE_pos: pack current X and new Y together
        LSL     R4, R4, #8          ; X in high byte
        ORR     R4, R4, R5          ; new pos = (X << 8) | new Y
        STRH     R4, [R0]
        BL check_win_condition
ret_move_up
        POP     {R0-R5, LR}
        BX      LR
        ENDFUNC

; Function: MAZE_MOVE_DOWN
; Moves the current position down in the maze (increases Y by 1)
MAZE_MOVE_DOWN FUNCTION
        PUSH    {R0-R5, LR}
        LDR     R0, =MAZE_pos
        LDRH     R4, [R0]            ; current pos: high= X, low = Y
        MOV     R5, R4
        LSR     R4, R4, #8          ; R4 = current X
        AND     R5, #0xFF           ; R5 = current Y
        ADD     R5, R5, #1          ; new Y = Y + 1
        MOV     R1, #MAZE_WIDTH
        MUL     R1, R5, R1          ; R1 = new Y * width
        ADD     R1, R1, R4          ; index = (new Y * width + X)
        LDR     R2, =MAZE_layout
        ADD     R2, R2, R1
        LDRB    R3, [R2]            ; Get cell state
        CMP     R3, #MAZEGEN_WALL
        BEQ     ret_move_down       ; If wall, do not update
        ; Update MAZE_pos: pack current X and new Y together
        LSL     R4, R4, #8          ; X << 8
        ORR     R4, R4, R5          ; new pos = (X << 8) | new Y
        STRH     R4, [R0]
        BL check_win_condition
ret_move_down
        POP     {R0-R5, LR}
        BX      LR
        ENDFUNC





; A % B = C
; Inputs: R0 = A, R1 = B
; Output: R2 = C
MODULO FUNCTION
        PUSH {R0, R1, LR}
        MOV  R2, R0             ; R2 = R0
        UDIV R0, R0, R1         ; R0 = R0 // R1
        MLS R2, R1, R0, R2      ; R2 = R2 - R1 * R0
        POP {R0, R1, LR}
        BX LR
        ENDFUNC

