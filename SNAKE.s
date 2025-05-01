
        AREA  SNAKECONSTS, DATA, READONLY
dirRight    EQU 0
dirLeft     EQU 1
dirUp       EQU 2
dirDown     EQU 3


        AREA    SNAKEDATA, DATA, READWRITE
        EXPORT SNAKE_prng_state
        EXPORT SNAKE_HEAD
        EXPORT SNAKE_LENGTH
        EXPORT SNAKE_FOOD_POS
        EXPORT SNAKE_SCORE
        EXPORT SNAKE_GAME_OVER

SNAKE
SNAKE_LENGTH    DCB 0x01      ; Initial snake length (just the head)
SNAKE_FOOD_POS        DCW 0x0909      ; XXYY food position
SNAKE_HEAD      DCW 0x1414      ; XXYY initial position
snake_body      SPACE 2*1536  ; Array to store snake body segments (x,y coordinates (2Bytes) for each)
snake_direction DCB dirRight        ; Initial direction: right
SNAKE_SCORE           DCW 0x00            ; Current SNAKE_SCORE
SNAKE_GAME_OVER       DCB 0x00            ; Game over flag (0 = playing, 1 = game over)
SNAKE_prng_state    DCD 0x00  ; Initial seed value

        AREA CODE, CODE, READONLY
        EXPORT SNAKE_LOOP
        EXPORT SNAKE_RESET
        EXPORT SNAKE_GO_DOWN
        EXPORT SNAKE_GO_UP
        EXPORT SNAKE_GO_LEFT
        EXPORT SNAKE_GO_RIGHT
        EXPORT MODULO

SNAKE_LOOP FUNCTION
		PUSH {LR}
        BL      update_snake
        BL      check_collisions
        POP {LR}
		BX LR
		ENDFUNC

SNAKE_RESET FUNCTION
        PUSH    {R0-R1, LR}
        ; Initialize snake head position (middle of screen)
        LDR     R0, =SNAKE_HEAD
        LDR     R1, =0x1414     ; Initial position
        STRH     R1, [R0]

        ; Initialize snake length
        LDR     R0, =SNAKE_LENGTH
        MOV     R1, #1              ; Start with length of 1 (just the head)
        STRB     R1, [R0]

        ; Initialize snake direction
        LDR     R0, =snake_direction
        MOV     R1, #dirUp       ; Start moving right
        STRB    R1, [R0]

        ; Initialize food position
        LDR     R0, =SNAKE_FOOD_POS
        LDR     R1, =0x1409
        STRH     R1, [R0]

        ; Initialize SNAKE_SCORE
        LDR     R0, =SNAKE_SCORE
        MOV     R1, #0              ; Start with SNAKE_SCORE of 0
        STRH    R1, [R0]

        ; Initialize game over flag
        LDR     R0, =SNAKE_GAME_OVER
        MOV     R1, #0              ; Game is running
        STRB    R1, [R0]
        
        POP    {R0-R1, LR}
        BX LR
        ENDFUNC


; ----------------------------------------------------
; update_snake: Move the snake one step in the current direction
update_snake 
        PUSH    {R0-R7, LR}
        BL update_head_func ; Stores new position in R6 (XXYY)

        ; Check if snake head has collided with food
        LDR     R0, =SNAKE_FOOD_POS
        LDRH     R4, [R0]            ; R4 = food position
        
        ; Check if head and food are at the same position
        CMP     R6, R4
        BNE     update_body
        BL      grow_snake
        BL      increase_score
        BL      spawn_new_food
update_body
        ; First, update the snake body (move each segment to position of segment ahead of it)
        LDR     R0, =snake_body
        LDR     R1, =SNAKE_HEAD
        LDR     R3, =SNAKE_LENGTH
        LDRB     R3, [R3]            ; R3 = snake length
        ; Skip body update if length is just 1 (only head)
        CMP     R3, #1
        BEQ     update_head
        
        ; Start from the tail and move each segment to the position of the one ahead of it
        SUB     R4, R3, #1          ; R4 = index of last body segment
        MOV     R5, R4              ; R5 = loop counter
        
body_update_loop
        ; Calculate address of current segment: snake_body + (R5 * 2)
        MOV     R6, R5
        LSL     R6, R6, #1          ; R6 = R5 * 2
        ADD     R6, R1, R6          ; R6 = address of current segment
        
        ; Calculate address of segment ahead: snake_body + ((R5-1) * 2)
        SUB     R7, R5, #1
        LSL     R7, R7, #1          ; R7 = (R5-1) * 2
        ADD     R7, R1, R7          ; R7 = address of segment ahead
        
        ; Copy from segment ahead
        LDR     R7, [R7]            ; Load position of segment ahead
        STR     R7, [R6]            ; Store at current segment position
        
next_segment
        SUBS    R5, R5, #1          ; Decrement loop counter
        BNE     body_update_loop    ; Continue loop if not zero
update_head
        BL update_head_func ; Stores new position in R6 (XXYY)
        STRH     R6, [R0]            ; Store updated head position

        POP     {R0-R7, LR}
        BX      LR

update_head_func
    PUSH {LR}
        ; updating the head position based on current direction
        LDR     R0, =SNAKE_HEAD
        LDRH     R1, [R0]            ; R1 = current head position
        LDR     R2, =snake_direction
        LDRB    R3, [R2]            ; R3 = current direction
        
        ; Extract X and Y coordinates from head position
        LSR     R4, R1, #8         ; R4 = X position
        UXTB    R5, R1              ; R5 = Y position
        
        ; Update position based on direction
        CMP     R3, #dirRight
        BNE     not_right
        ADD     R4, R4, #1 ; Move right
        B       ret_update_head
not_right
        CMP     R3, #dirLeft
        BNE     not_left_dir
        SUB     R4, R4, #1 ; Move left
        B       ret_update_head
not_left_dir
        CMP     R3, #dirUp
        BNE     not_up_dir
        SUB     R5, R5, #1 ; Move up
        B       ret_update_head
not_up_dir
        ADD     R5, R5, #1 ; Move down (if none of the above)

ret_update_head
        ; Combine X and Y back into position
        LSL     R6, R4, #8
        ORR     R6, R6, R5
    POP {LR}
    BX LR

; ----------------------------------------------------
; check_collisions: Check if snake has collided with walls, food, or itself
check_collisions
        PUSH    {R0-R7, LR}
        
        ; Get head position
        LDR     R0, =SNAKE_HEAD
        LDRH     R1, [R0]            ; R1 = head position
        
        ; Extract X and Y from head position
        LSR     R2, R1, #8          ; R2 = head X
        UXTB    R3, R1              ; R3 = head Y
        
        ; Check wall collisions
        CMP     R2, #0
        BLT     collision_detected  ; X < 0
        CMP     R2, #47
        BGT     collision_detected
        CMP     R3, #0
        BLT     collision_detected  ; Y < 0
        CMP     R3, #31
        BGT     collision_detected  ; Y >= Height
        
        ; Check self-collision (snake length > 1)
        LDR     R0, =SNAKE_LENGTH
        LDRB     R4, [R0]            ; R4 = snake length
        CMP     R4, #1
        BEQ     collision_done          ; Skip self-collision check if length is 1
        
        LDR     R0, =snake_body
        MOV     R5, #0              ; R5 = loop counter
        
self_collision_loop
        ; Calculate address of current segment: snake_body + (R5 * 1)
        LSL     R6, R5, #1          ; R6 = R5 * 1
        ADD     R6, R0, R6          ; R6 = address of current segment
        LDRH     R7, [R6]            ; R7 = segment position
        
        ; Compare with head position
        CMP     R1, R7
        BEQ     collision_detected  ; Head collided with body segment
        
        ADD     R5, R5, #1          ; Increment loop counter
        SUB     R6, R4, #1
        CMP     R5, R6              ; Compare with snake length
        BLT     self_collision_loop ; Continue if not done
        

        
        B       collision_done
        
collision_detected
        ; Set game over flag
        LDR     R0, =SNAKE_GAME_OVER
        MOV     R1, #1
        STRB    R1, [R0]
        
collision_done
        POP     {R0-R7, LR}
        BX      LR

; ----------------------------------------------------
; grow_snake: Increase snake length by 1
grow_snake
        PUSH    {R0-R4, LR}
        
        LDR     R0, =SNAKE_LENGTH
        LDRB     R1, [R0]            ; R1 = current length
        
        
        ; Increase length
        ADD     R1, R1, #1
        STR     R1, [R0]            ; Store new length
        
        ; Initialize the new segment (copy from tail position)
        LDR     R0, =SNAKE_HEAD
        SUB     R2, R1, #1          ; R2 = index of new segment
        SUB     R3, R1, #2          ; R3 = index of previous last segment
        
        ; Calculate addresses
        LSL     R2, R2, #1          ; R2 = R2 * 2
        ADD     R2, R0, R2          ; R2 = address of new segment
        
        LSL     R3, R3, #1          ; R3 = R3 * 2
        ADD     R3, R0, R3          ; R3 = address of previous last segment
        
        ; Copy position
        LDRH     R4, [R3]
        STRH     R4, [R2]
        
grow_done
        POP     {R0-R4, LR}
        BX      LR

; ----------------------------------------------------
; increase_score: Add 1 to the current SNAKE_SCORE
increase_score
        PUSH    {R0-R1, LR}
        
        LDR     R0, =SNAKE_SCORE
        LDRH    R1, [R0]
        ADD     R1, R1, #1          ; Increment SNAKE_SCORE
        STRH    R1, [R0]            ; Store updated SNAKE_SCORE
        
        POP     {R0-R1, LR}
        BX      LR


; Working
; ----------------------------------------------------
; spawn_new_food: Generate a new random position for food
spawn_new_food
        PUSH    {R0-R6, LR}

        MOV R3, #48
        BL get_random ; [0, 47]
        MOV R6, R0 ; R4 = X

        MOV R3, #32
        BL get_random ; [0, 31]
        MOV R5, R0 ; R5 = Y
        LSL R6, #8
        ORR R6, R5

        MOV R3, #0
food_collision_loop
        ; Calculate address of current segment
        LDR 	R8, =SNAKE_HEAD
        
        ADD     R8, R3,LSL #1          ; R8 = R3 * 2       
        LDRH     R8, [R8]
        ; Compare with current body part position
        CMP     R8, R6
        BEQ     food_collision_detected  ; Head collided with body segment
        
        ADD     R3, #1          ; Increment loop counter
        LDR 	R0, =SNAKE_LENGTH
        LDRB 	R5, [R0]

        CMP     R3, R5              ; Compare with snake length
        BLT     food_collision_loop ; Continue if not done
        B     no_collision


food_collision_detected
        B spawn_new_food

no_collision
        ; Store into SNAKE_FOOD_POS
        LDR     R0, =SNAKE_FOOD_POS
        STRH     R6, [R0]

        POP     {R0-R6, LR}
        BX      LR
                

SNAKE_GO_UP FUNCTION
    PUSH {R2, R3, LR}
    LDR     R2, =snake_direction	;R2 points to snake_direction
    LDRB    R3, [R2]
    CMP     R3, #dirDown
    BEQ     save_up
    MOV     R3, #dirUp
    B       save_up
save_up
    STRB    R3, [R2]            ; Save the new direction
    POP {R2, R3, LR}
    BX LR
    ENDFUNC
SNAKE_GO_RIGHT FUNCTION
    PUSH {R2, R3, LR}
    LDR     R2, =snake_direction	;R2 points to snake_direction
    LDRB    R3, [R2]
    CMP     R3, #dirLeft
    BEQ     save_right
    MOV     R3, #dirRight
    B       save_right
save_right
    STRB    R3, [R2]            ; Save the new direction
    POP {R2, R3, LR}
    BX LR
    ENDFUNC

SNAKE_GO_LEFT FUNCTION
    PUSH {R2, R3, LR}
    LDR     R2, =snake_direction	;R2 points to snake_direction
    LDRB    R3, [R2]
    CMP     R3, #dirRight
    BEQ     save_left
    MOV     R3, #dirLeft
    B       save_left
save_left
    STRB    R3, [R2]            ; Save the new direction
    POP {R2, R3, LR}
    BX LR
    ENDFUNC

SNAKE_GO_DOWN FUNCTION
    PUSH {R2, R3, LR}
    LDR     R2, =snake_direction	;R2 points to snake_direction
    LDRB    R3, [R2]
    CMP     R3, #dirUp
    BEQ     save_down
    MOV     R3, #dirDown
    B       save_down
save_down
    STRB    R3, [R2]            ; Save the new direction
    POP {R2, R3, LR}
    BX LR
    ENDFUNC


; ==============================Utility Functions==================================

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
