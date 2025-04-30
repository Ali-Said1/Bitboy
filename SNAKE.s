; Constants
Width       EQU 480        ; Screen width
Height      EQU 320        ; Screen height
color_red   EQU 0xF800     ; RGB565 color constants
color_green EQU 0x07D0
color_blue  EQU 0x001F
snake_size  EQU 0x000A     ; Size of each snake segment
max_length  EQU 20        ; Maximum snake length
dirRight    EQU 0
dirLeft     EQU 1
dirUp       EQU 2
dirDown     EQU 3
food_size   EQU 0x000A     ; Size of food

        AREA    VECTORS, CODE, READONLY
        EXPORT  __Vectors
__Vectors
        DCD     0x20005000          ; Initial SP value (top of 400KB simulated SRAM)
        DCD     Reset_Handler       ; Reset handler address

        AREA    DATA, DATA, READWRITE
        EXPORT SNAKE
        EXPORT snake_head
        EXPORT snake_body
        EXPORT snake_length
        EXPORT snake_direction
        EXPORT food_pos
        EXPORT score
        EXPORT game_over

SNAKE
food_pos        DCW 0x0909      ; XXYY food position
snake_head      DCW 0x1414      ; XXYY initial position
snake_body      SPACE 2*max_length  ; Array to store snake body segments (x,y coordinates (4Bytes) for each)
snake_length    DCD 0x00000001      ; Initial snake length (just the head)
snake_direction DCB dirRight        ; Initial direction: right
score           DCB 0x00            ; Current score
game_over       DCB 0x00            ; Game over flag (0 = playing, 1 = game over)
last_input      DCB 0x00            ; Last keyboard input
SNAKE_prng_state    DCB 0x00  ; Initial seed value

        AREA CODE, CODE, READONLY
        EXPORT Reset_Handler
        EXPORT game_loop
Reset_Handler
        MOV sp, r13
        MOV r8, #0                  ; Simulation steps

start


        ; Initialize snake head position (middle of screen)
        LDR     R0, =snake_head
        LDR     R1, =0x1414     ; Initial position
        STRH     R1, [R0]

        ; Initialize snake length
        LDR     R0, =snake_length
        MOV     R1, #1              ; Start with length of 1 (just the head)
        STR     R1, [R0]

        ; Initialize snake direction
        LDR     R0, =snake_direction
        MOV     R1, #dirRight       ; Start moving right
        STRB    R1, [R0]

        ; Initialize food position
        LDR     R0, =food_pos
        LDR     R1, =0x0909
        STRH     R1, [R0]

        ; Initialize score
        LDR     R0, =score
        MOV     R1, #0              ; Start with score of 0
        STRB    R1, [R0]

        ; Initialize game over flag
        LDR     R0, =game_over
        MOV     R1, #0              ; Game is running
        STRB    R1, [R0]
                
                ; Initialize random_seed
        LDR     R0, =SNAKE_prng_state
        MOV     R1, #0x12
        STRB    R1, [R0]

        LDR     r0, =SNAKE
        B       game_loop

game_loop
        ADD     r8, r8, #1          ; Increment simulation step counter


        BL spawn_new_food
        MOV R3, #0
 ;       ; Process input (when connection not now)
 ;       BL      process_input
 ;
 ;       ; Update snake position
 ;       BL      update_snake
 ;
 ;       ; Check collisions (with walls, food, and self)
 ;       BL      check_collisions

        ; Next frame
        B       game_loop

hang
        B       hang                ; End game loop if game is over
                
                
                
        

GO_UP FUNCTION

    LDR     R2, =snake_direction	;R2 points to snake_direction
    LDRB    R3, [R2]
    CMP     R3, #dirDown
    BEQ     save_direction
    MOV     R3, #dirUp
    B       save_direction
save_direction
        STRB    R3, [R2]            ; Save the new direction
        MOV     R1, #0
        STRB    R1, [R0]            

    ENDFUNC

; ----------------------------------------------------
; process_input: Handle input to change snake direction
process_input
        PUSH    {R0-R3, LR}
        
        ; For simulation, input is stored in last_input

        LDR     R0, =last_input 		;R0 points to last_input
        LDRB    R1, [R0]
        LDR     R2, =snake_direction	;R2 points to snake_direction
        LDRB    R3, [R2]

        ; Check input and update direction
                ; hna el inputs temporary 'w a d s' (httbdl sa3t el simulation)
        ; 'w' = up, 'a' = left, 's' = down, 'd' = right
        
        CMP     R1, #'w'
        BNE     not_up
        ; Can't go down if already going up
        CMP     R3, #dirDown
        BEQ     input_done
        MOV     R3, #dirUp
        B       save_direction
not_up
        CMP     R1, #'a'
        BNE     not_left
        ; Can't go right if already going left
        CMP     R3, #dirRight
        BEQ     input_done
        MOV     R3, #dirLeft
        B       save_direction
not_left
        CMP     R1, #'s'
        BNE     not_down
        ; Can't go up if already going down
        CMP     R3, #dirUp
        BEQ     input_done
        MOV     R3, #dirDown
        B       save_direction
not_down
        CMP     R1, #'d'
        BNE     input_done
        ; Can't go left if already going right
        CMP     R3, #dirLeft
        BEQ     input_done
        MOV     R3, #dirRight



input_done
        POP     {R0-R3, LR}
        BX      LR

; ----------------------------------------------------
; update_snake: Move the snake one step in the current direction
update_snake
        PUSH    {R0-R7, LR}
        
        ; First, update the snake body (move each segment to position of segment ahead of it)
        LDR     R0, =snake_body
        LDR     R1, =snake_head
        LDR     R2, =snake_length
        LDR     R3, [R2]            ; R3 = snake length
        
        ; Skip body update if length is just 1 (only head)
        CMP     R3, #1
        BEQ     update_head
        
        ; Start from the tail and move each segment to the position of the one ahead of it
        SUB     R4, R3, #1          ; R4 = index of last body segment
        MOV     R5, R4              ; R5 = loop counter
        
body_update_loop
        ; Calculate address of current segment: snake_body + (R5 * 4)
        MOV     R6, R5
        LSL     R6, R6, #2          ; R6 = R5 * 4
        ADD     R6, R0, R6          ; R6 = address of current segment
        
        ; Calculate address of segment ahead: snake_body + ((R5-1) * 4)
        SUB     R7, R5, #1
        LSL     R7, R7, #2          ; R7 = (R5-1) * 4
        ADD     R7, R0, R7          ; R7 = address of segment ahead
        
        ; If this is segment 0, copy from head instead
        CMP     R5, #1
        BNE     not_first_segment
        
        ; Copy head position to first body segment
        LDR     R7, [R1]            ; Load head position
        STR     R7, [R6]            ; Store at segment position
        B       next_segment
        
not_first_segment
        ; Copy from segment ahead
        LDR     R7, [R7]            ; Load position of segment ahead
        STR     R7, [R6]            ; Store at current segment position
        
next_segment
        SUBS    R5, R5, #1          ; Decrement loop counter
        BNE     body_update_loop    ; Continue loop if not zero

update_head
        ; updating the head position based on current direction
        LDR     R0, =snake_head
        LDR     R1, [R0]            ; R1 = current head position
        LDR     R2, =snake_direction
        LDRB    R3, [R2]            ; R3 = current direction
        
        ; Extract X and Y coordinates from head position
        LSR     R4, R1, #16         ; R4 = X position
        UXTH    R5, R1              ; R5 = Y position
        
        ; Update position based on direction
        CMP     R3, #dirRight
        BNE     not_right
        ADD     R4, R4, #snake_size ; Move right
        B       update_pos
not_right
        CMP     R3, #dirLeft
        BNE     not_left_dir
        SUB     R4, R4, #snake_size ; Move left
        B       update_pos
not_left_dir
        CMP     R3, #dirUp
        BNE     not_up_dir
        SUB     R5, R5, #snake_size ; Move up
        B       update_pos
not_up_dir
        ADD     R5, R5, #snake_size ; Move down (if none of the above)
        
update_pos
        ; Combine X and Y back into position
        LSL     R6, R4, #16
        ORR     R6, R6, R5
        STR     R6, [R0]            ; Store updated head position
        
        POP     {R0-R7, LR}
        BX      LR

; ----------------------------------------------------
; check_collisions: Check if snake has collided with walls, food, or itself
check_collisions
        PUSH    {R0-R7, LR}
        
        ; Get head position
        LDR     R0, =snake_head
        LDR     R1, [R0]            ; R1 = head position
        
        ; Extract X and Y from head position
        LSR     R2, R1, #16         ; R2 = head X
        UXTH    R3, R1              ; R3 = head Y
        
        ; Check wall collisions
        CMP     R2, #0
        BLT     collision_detected  ; X < 0
        CMP     R2, #Width
        BGE     collision_detected  ; X >= Width
        CMP     R3, #0
        BLT     collision_detected  ; Y < 0
        CMP     R3, #Height
        BGE     collision_detected  ; Y >= Height
        
        ; Check self-collision (snake length > 1)
        LDR     R0, =snake_length
        LDR     R4, [R0]            ; R4 = snake length
        CMP     R4, #1
        BEQ     check_food          ; Skip self-collision check if length is 1
        
        LDR     R0, =snake_body
        MOV     R5, #0              ; R5 = loop counter
        
self_collision_loop
        ; Calculate address of current segment: snake_body + (R5 * 4)
        LSL     R6, R5, #2          ; R6 = R5 * 4
        ADD     R6, R0, R6          ; R6 = address of current segment
        LDR     R7, [R6]            ; R7 = segment position
        
        ; Compare with head position
        CMP     R1, R7
        BEQ     collision_detected  ; Head collided with body segment
        
        ADD     R5, R5, #1          ; Increment loop counter
        CMP     R5, R4              ; Compare with snake length
        BLT     self_collision_loop ; Continue if not done
        
check_food
        ; Check if snake head has collided with food
        LDR     R0, =food_pos
        LDR     R4, [R0]            ; R4 = food position
        
        ; Extract X and Y from food position
        LSR     R5, R4, #16         ; R5 = food X
        UXTH    R6, R4              ; R6 = food Y
        
        ; Check if head and food are at the same position
        CMP     R1, R4
        BNE     collision_done
        
        ; Snake ate the food
        BL      grow_snake
        BL      increase_score
        BL      spawn_new_food
        
        B       collision_done
        
collision_detected
        ; Set game over flag
        LDR     R0, =game_over
        MOV     R1, #1
        STRB    R1, [R0]
        
collision_done
        POP     {R0-R7, LR}
        BX      LR

; ----------------------------------------------------
; grow_snake: Increase snake length by 1
grow_snake
        PUSH    {R0-R4, LR}
        
        LDR     R0, =snake_length
        LDR     R1, [R0]            ; R1 = current length
        
        ; Check if max length reached
        CMP     R1, #max_length
        BGE     grow_done
        
        ; Increase length
        ADD     R1, R1, #1
        STR     R1, [R0]            ; Store new length
        
        ; Initialize the new segment (copy from tail position)
        LDR     R0, =snake_body
        SUB     R2, R1, #1          ; R2 = index of last segment
        SUB     R3, R2, #1          ; R3 = index of previous last segment
        
        ; Calculate addresses
        LSL     R2, R2, #2          ; R2 = R2 * 4
        ADD     R2, R0, R2          ; R2 = address of new segment
        
        LSL     R3, R3, #2          ; R3 = R3 * 4
        ADD     R3, R0, R3          ; R3 = address of previous last segment
        
        ; Copy position
        LDR     R4, [R3]
        STR     R4, [R2]
        
grow_done
        POP     {R0-R4, LR}
        BX      LR

; ----------------------------------------------------
; increase_score: Add 1 to the current score
increase_score
        PUSH    {R0-R1, LR}
        
        LDR     R0, =score
        LDRB    R1, [R0]
        ADD     R1, R1, #1          ; Increment score
        STRB    R1, [R0]            ; Store updated score
        
        POP     {R0-R1, LR}
        BX      LR

; ----------------------------------------------------
; spawn_new_food: Generate a new random position for food
; ----------------------------------------------------
; spawn_new_food: Generate a new random food position
; X in range 0 - 450 (i.e., 0 45 * 10)
; Y in range 0 - 340 (i.e., 0 34 * 10)
spawn_new_food
        PUSH    {R0-R6, LR}

        MOV R3, #42
        BL get_random ; [0, 41]
        ADD R0, #3
        MOV R6, R0 ; R4 = X

        MOV R3, #26
        BL get_random ; [0, 25]
        ADD R0, #3
        MOV R5, R0 ; R5 = Y
        LSL R6, #8
        ORR R6, R5

        MOV R3, #0
food_collision_loop
        ; Calculate address of current segment
        LDR 	R8, =snake_head
        
        ADD     R8, R3,LSL #1          ; R8 = R3 * 2       
        LDRH     R8, [R8]
        ; Compare with current body part position
        CMP     R8, R6
        BEQ     food_collision_detected  ; Head collided with body segment
        
        ADD     R3, #1          ; Increment loop counter
        LDR 	R0, =snake_length
        LDR 	R5, [R0]

        CMP     R3, R5              ; Compare with snake length
        BLT     food_collision_loop ; Continue if not done
        B     no_collision


food_collision_detected
        B spawn_new_food

no_collision
        ; Store into food_pos
        LDR     R0, =food_pos
        STRH     R6, [R0]

        POP     {R0-R6, LR}
        BX      LR
                
; ----------------------------------------------------


; Function: get_random
; Inputs: R3 = max - 1
; Outputs: R0 = [0, R3 -1]
get_random  FUNCTION
    PUSH    {R1-R5, LR}        ; Save R4, R5, and LR

    ; Save R3 (range bound)
    MOV    R5, R3              ; R5 = R3 (preserve R3)

    ; Generate random number
    ; Load PRNG state
    LDR     R4, =SNAKE_prng_state     ; R4 = address of prng_state
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
