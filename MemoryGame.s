AREA  MEMGAMECONSTS, DATA, READONLY
; Game constants
MAX_SEQUENCE_LEN  EQU 5         ; Maximum sequence length
DISPLAY_TIME      EQU 500        ; Time to display each number (in ms)
HIDE_TIME         EQU 250        ; Time between numbers (in ms)
MAX_INPUT_TIME    EQU 5000       ; Maximum time for player input (in ms)

; Game states
STATE_INIT        EQU 0          ; Game initialization
STATE_GENERATE    EQU 1          ; Generate new sequence
STATE_DISPLAY     EQU 2          ; Display sequence to player
STATE_INPUT       EQU 3          ; Wait for player input
STATE_CHECK       EQU 4          ; Check player input
STATE_GAME_OVER   EQU 5          ; Game over

        AREA    MEMGAMEDATA, DATA, READWRITE
        EXPORT MEMGAME_prng_state
        EXPORT MEMGAME_SCORE
        EXPORT MEMGAME_GAME_OVER
        EXPORT MEMGAME_SEQ_LENGTH
        EXPORT MEMGAME_CURRENT_SEQ_POS
        EXPORT MEMGAME_DISPLAY_NUM

MEMGAME
MEMGAME_prng_state    DCD 0x12345678  ; Initial seed value
MEMGAME_SCORE         DCW 0x00        ; Current score (sequence length - 1)
MEMGAME_GAME_OVER     DCB 0x00        ; Game over flag (0 = playing, 1 = game over)
MEMGAME_SEQ_LENGTH    DCB 0x01        ; Current sequence length
MEMGAME_CURRENT_SEQ_POS DCB 0x00      ; Current position in sequence (for display/input)
MEMGAME_STATE         DCB 0x00        ; Current game state
MEMGAME_DISPLAY_NUM   DCB 0x00        ; Currently displayed number
MEMGAME_TIMER         DCD 0x00        ; Timer for display/input timing
sequence             SPACE MAX_SEQUENCE_LEN  ; Array to store sequence
player_input         SPACE MAX_SEQUENCE_LEN  ; Array to store player input

        AREA CODE, CODE, READONLY
        EXPORT MEMGAME_LOOP
        EXPORT MEMGAME_RESET
        EXPORT MEMGAME_INPUT_NUM
        EXPORT GET_RANDOM

; Main game loop function
MEMGAME_LOOP FUNCTION
        PUSH {R0-R7, LR}
        
        ; Get current game state
        LDR     R0, =MEMGAME_STATE
        LDRB    R1, [R0]
        
        ; Branch based on game state
        CMP     R1, #STATE_INIT
        BEQ     state_init
        
        CMP     R1, #STATE_GENERATE
        BEQ     state_generate
        
        CMP     R1, #STATE_DISPLAY
        BEQ     state_display
        
        CMP     R1, #STATE_INPUT
        BEQ     state_input
        
        CMP     R1, #STATE_CHECK
        BEQ     state_check
        
        CMP     R1, #STATE_GAME_OVER
        BEQ     state_game_over
        
        ; Default - go to init
        B       state_init
        
state_init
        ; Initialize game
        BL      MEMGAME_RESET
        
        ; Move to generate state
        MOV     R1, #STATE_GENERATE
        STRB    R1, [R0]
        B       end_loop
        
state_generate
        ; Generate next number in sequence
        BL      generate_sequence
        
        ; Reset display position counter
        LDR     R0, =MEMGAME_CURRENT_SEQ_POS
        MOV     R1, #0
        STRB    R1, [R0]
        
        ; Move to display state
        LDR     R0, =MEMGAME_STATE
        MOV     R1, #STATE_DISPLAY
        STRB    R1, [R0]
        
        ; Initialize timer
        LDR     R0, =MEMGAME_TIMER
        MOV     R1, #0
        STR     R1, [R0]
        B       end_loop
        
state_display
        ; Display current sequence
        BL      display_sequence
        B       end_loop
        
state_input
        ; Wait for and process player input
        BL      process_input
        B       end_loop
        
state_check
        ; Check if player input matches sequence
        BL      check_sequence
        B       end_loop
        
state_game_over
        ; Game over state - wait for reset
        B       end_loop
        
end_loop
        POP     {R0-R7, LR}
        BX      LR
        ENDFUNC

; Reset the game to initial state
MEMGAME_RESET FUNCTION
        PUSH    {R0-R4, LR}
        
        ; Reset score
        LDR     R0, =MEMGAME_SCORE
        MOV     R1, #0
        STRH    R1, [R0]
        
        ; Reset game over flag
        LDR     R0, =MEMGAME_GAME_OVER
        MOV     R1, #0
        STRB    R1, [R0]
        
        ; Reset sequence length
        LDR     R0, =MEMGAME_SEQ_LENGTH
        MOV     R1, #1          ; Start with length of 1
        STRB    R1, [R0]
        
        ; Reset current position
        LDR     R0, =MEMGAME_CURRENT_SEQ_POS
        MOV     R1, #0
        STRB    R1, [R0]
        
        ; Reset game state
        LDR     R0, =MEMGAME_STATE
        MOV     R1, #STATE_GENERATE
        STRB    R1, [R0]
        
        ; Reset display number
        LDR     R0, =MEMGAME_DISPLAY_NUM
        MOV     R1, #0
        STRB    R1, [R0]
        
        ; Reset timer
        LDR     R0, =MEMGAME_TIMER
        MOV     R1, #0
        STR     R1, [R0]
        
        POP     {R0-R4, LR}
        BX      LR
        ENDFUNC

; Generate a random sequence
generate_sequence FUNCTION
        PUSH    {R0-R5, LR}
        
        ; Get current sequence length
        LDR     R0, =MEMGAME_SEQ_LENGTH
        LDRB    R1, [R0]        ; R1 = current length
        
        ; Calculate position in sequence array
        LDR     R4, =sequence
        SUB     R5, R1, #1      ; Adjust for 0-indexing
        ADD     R4, R4, R5      ; R4 = address where new number will be stored
        
        ; Generate random number between 1-9
        MOV     R3, #9
        BL      GET_RANDOM
        ADD     R0, R0, #1      ; Add 1 to get range 1-9
        
        ; Store the new number in sequence
        STRB    R0, [R4]
        
        POP     {R0-R5, LR}
        BX      LR
        ENDFUNC

; Display the current sequence to the player
display_sequence FUNCTION
        PUSH    {R0-R7, LR}
        
        ; Get current position and sequence length
        LDR     R0, =MEMGAME_CURRENT_SEQ_POS
        LDRB    R1, [R0]        ; R1 = current position
        
        LDR     R0, =MEMGAME_SEQ_LENGTH
        LDRB    R2, [R0]        ; R2 = sequence length
        
        ; Check if we're done displaying
        CMP     R1, R2
        BGE     display_done
        
        ; Get timer value
        LDR     R0, =MEMGAME_TIMER
        LDR     R3, [R0]
        ADD     R3, R3, #1      ; Increment timer
        STR     R3, [R0]
        
        ; Check if it's time to show or hide a number
        MOV     R4, #(DISPLAY_TIME + HIDE_TIME)
        MUL     R4, R1, R4      ; R4 = current_pos * (display_time + hide_time)
        
        ; Show number phase
        CMP     R3, R4
        BLT     skip_display
        
        ADD     R4, R4, #DISPLAY_TIME
        CMP     R3, R4
        BGE     hide_number
        
        ; Display the current number
        LDR     R0, =sequence
        ADD     R0, R0, R1      ; Point to current position
        LDRB    R5, [R0]        ; R5 = current number
        
        ; Update display number
        LDR     R0, =MEMGAME_DISPLAY_NUM
        STRB    R5, [R0]
        
        B       skip_display
        
hide_number
        ; Hide the number
        LDR     R0, =MEMGAME_DISPLAY_NUM
        MOV     R5, #0          ; 0 = no display
        STRB    R5, [R0]
        
        ; Check if it's time for next number
        ADD     R4, R4, #HIDE_TIME
        CMP     R3, R4
        BLT     skip_display
        
        ; Move to next position
        LDR     R0, =MEMGAME_CURRENT_SEQ_POS
        ADD     R1, R1, #1
        STRB    R1, [R0]
        
skip_display
        B       display_exit
        
display_done
        ; Switch to input state
        LDR     R0, =MEMGAME_STATE
        MOV     R1, #STATE_INPUT
        STRB    R1, [R0]
        
        ; Reset position counter for input
        LDR     R0, =MEMGAME_CURRENT_SEQ_POS
        MOV     R1, #0
        STRB    R1, [R0]
        
        ; Reset timer for input
        LDR     R0, =MEMGAME_TIMER
        MOV     R1, #0
        STR     R1, [R0]
        
display_exit
        POP     {R0-R7, LR}
        BX      LR
        ENDFUNC

; Process player input
process_input FUNCTION
        PUSH    {R0-R7, LR}
        
        ; Get current position and sequence length
        LDR     R0, =MEMGAME_CURRENT_SEQ_POS
        LDRB    R1, [R0]        ; R1 = current position
        
        LDR     R0, =MEMGAME_SEQ_LENGTH
        LDRB    R2, [R0]        ; R2 = sequence length
        
        ; Check if we've received all inputs
        CMP     R1, R2
        BGE     input_done
        
        ; Update timer
        LDR     R0, =MEMGAME_TIMER
        LDR     R3, [R0]
        ADD     R3, R3, #1
        STR     R3, [R0]
        
        ; Check for timeout
        LDR     R4, =MAX_INPUT_TIME
        CMP     R3, R4
        BGE     input_timeout
        
        B       input_exit
        
input_done
        ; Move to check state
        LDR     R0, =MEMGAME_STATE
        MOV     R1, #STATE_CHECK
        STRB    R1, [R0]
        B       input_exit
        
input_timeout
        ; Game over due to timeout
        LDR     R0, =MEMGAME_GAME_OVER
        MOV     R1, #1
        STRB    R1, [R0]
        
        ; Move to game over state
        LDR     R0, =MEMGAME_STATE
        MOV     R1, #STATE_GAME_OVER
        STRB    R1, [R0]
        
input_exit
        POP     {R0-R7, LR}
        BX      LR
        ENDFUNC

; Handle player input for a number
MEMGAME_INPUT_NUM FUNCTION
        PUSH    {R0-R4, LR}
        
        ; R0 contains the input number (1-9)
        
        ; Check if game is in input state
        LDR     R1, =MEMGAME_STATE
        LDRB    R2, [R1]
        CMP     R2, #STATE_INPUT
        BNE     input_num_exit
        
        ; Get current position
        LDR     R1, =MEMGAME_CURRENT_SEQ_POS
        LDRB    R2, [R1]
        
        ; Store player input
        LDR     R3, =player_input
        ADD     R3, R3, R2      ; Point to current input position
        STRB    R0, [R3]
        
        ; Update display number to show input
        LDR     R3, =MEMGAME_DISPLAY_NUM
        STRB    R0, [R3]
        
        ; Increment position
        ADD     R2, R2, #1
        STRB    R2, [R1]
        
        ; Reset timer
        LDR     R1, =MEMGAME_TIMER
        MOV     R2, #0
        STR     R2, [R1]
        
input_num_exit
        POP     {R0-R4, LR}
        BX      LR
        ENDFUNC

; Check if player input matches sequence
check_sequence FUNCTION
        PUSH    {R0-R7, LR}
        
        ; Get sequence length
        LDR     R0, =MEMGAME_SEQ_LENGTH
        LDRB    R1, [R0]        ; R1 = sequence length
        
        ; Compare each position
        MOV     R2, #0          ; R2 = current position
        
check_loop
        CMP     R2, R1
        BGE     check_success   ; All positions matched
        
        LDR     R3, =sequence
        ADD     R3, R3, R2      ; Point to sequence position
        LDRB    R4, [R3]        ; R4 = expected number
        
        LDR     R3, =player_input
        ADD     R3, R3, R2      ; Point to input position
        LDRB    R5, [R3]        ; R5 = player input
        
        CMP     R4, R5
        BNE     check_fail
        
        ADD     R2, R2, #1      ; Move to next position
        B       check_loop
        
check_success
        ; Increase score
        LDR     R0, =MEMGAME_SCORE
        LDRH    R2, [R0]
        ADD     R2, R2, #1
        STRH    R2, [R0]
        
        ; Increase sequence length
        LDR     R0, =MEMGAME_SEQ_LENGTH
        LDRB    R2, [R0]
        ADD     R2, R2, #1
        
        ; Check if maximum length reached
        CMP     R2, #MAX_SEQUENCE_LEN
        BGE     max_length_reached
        
        ; Store new length
        STRB    R2, [R0]
        
        ; Move to generate state for next round
        LDR     R0, =MEMGAME_STATE
        MOV     R1, #STATE_GENERATE
        STRB    R1, [R0]
        B       check_exit
        
max_length_reached
        ; Player won the game
        LDR     R0, =MEMGAME_GAME_OVER
        MOV     R1, #1
        STRB    R1, [R0]
        
        ; Move to game over state
        LDR     R0, =MEMGAME_STATE
        MOV     R1, #STATE_GAME_OVER
        STRB    R1, [R0]
        B       check_exit
        
check_fail
        ; Game over
        LDR     R0, =MEMGAME_GAME_OVER
        MOV     R1, #1
        STRB    R1, [R0]
        
        ; Move to game over state
        LDR     R0, =MEMGAME_STATE
        MOV     R1, #STATE_GAME_OVER
        STRB    R1, [R0]
        
check_exit
        POP     {R0-R7, LR}
        BX      LR
        ENDFUNC

; Function: GET_RANDOM
; Inputs: R3 = max
; Outputs: R0 = [0, R3-1]
GET_RANDOM  FUNCTION
    PUSH    {R1-R5, LR}        ; Save registers

    ; Save R3 (range bound)
    MOV     R5, R3              ; R5 = R3 (preserve R3)

    ; Generate random number
    ; Load PRNG state
    LDR     R4, =MEMGAME_prng_state  ; R4 = address of prng_state
    LDR     R0, [R4]            ; R0 = current state

    ; Compute: state = state * 1664525
    MOV     R1, #0x60D          ; Lower 16 bits of multiplier
    MOVT    R1, #0x196          ; Upper 16 bits of multiplier
    MUL     R2, R0, R1          ; R2 = state * 1664525 (low 32 bits)

    ; Add increment: 1013904223 = 0x3C6EF35F
    MOV     R1, #0xF35F         ; Lower 16 bits of increment
    MOVT    R1, #0x3C6E         ; Upper 16 bits of increment
    ADD     R2, R2, R1          ; R2 = R2 + 1013904223 (mod 2^32 via overflow)

    ; Store new state
    STR     R2, [R4]            ; prng_state = new state

    ; Move result to R0
    MOV     R0, R2              ; R0 = random number

    ; Get value in range [0, R3-1]
    UDIV    R1, R0, R3          ; R1 = R0 / R3
    MUL     R1, R1, R3          ; R1 = R1 * R3
    SUB     R0, R0, R1          ; R0 = R0 - R1 (remainder)

    POP     {R1-R5, LR}        ; Restore registers
    BX      LR
    ENDFUNC
    LTORG
    END