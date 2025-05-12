        AREA  AIMCONSTS, DATA, READONLY

        EXPORT MEM_GAME_STATE
        EXPORT MEM_SEQUENCE
        EXPORT MEM_USER_SEQUENCE
        EXPORT MEM_SEQUENCE_LENGTH
        EXPORT MEM_HIGHLIGHT_INDEX
        EXPORT MEM_USER_INDEX
        EXPORT MEM_SCORE
		EXPORT MEM_PRNG_STATE

MEM_GAME_STATE DCB    0 ; 0: Playing 1: Win 2: Lose
PADD	SPACE 3
MEM_SEQUENCE DCD    0 
MEM_USER_SEQUENCE DCD    0 
MEM_SEQUENCE_LENGTH DCB 0
MEM_SCORE DCB 0
MEM_HIGHLIGHT_INDEX DCB 0 ; -1 means don't highlight anything
MEM_USER_INDEX DCB 0
MEM_PRNG_STATE DCB 0

        AREA MEMCODE, CODE, READONLY
        EXPORT  MEMORY_LOOP
    
MEMORY_LOOP FUNCTION
    PUSH {R0-R12, LR}
    LDR R0, =MEM_SEQUENCE
    LDR R1, [R0]
    AND R1, #0xF
    CMP R1, #0
    BEQ stop_highlight
    LDR R0, =MEM_HIGHLIGHT_INDEX
    MOV R2, R1
    STRB R2, [R0]
    LDR R0, =MEM_SEQUENCE
    LDR R1, [R0]
    LSR R1, #4
    STR R1, [R0]
    B MEM_LOOP_END

stop_highlight
    LDR R0, =MEM_HIGHLIGHT_INDEX
    MOV R2, #-1
    STRB R2, [R0]
    B MEM_LOOP_END
MEM_LOOP_END
    POP {R0-R12, LR}
    BX LR
	ENDFUNC






MEM_USER_SELECT FUNCTION
    PUSH {R0-R2, LR}
    LDR R0, =MEM_USER_INDEX
    LDRB R1, [R0]
    LDR R0, =MEM_USER_SEQUENCE
    LDR R2, [R0]

    AND R2, #0xF
    CMP R1, R2
    BEQ correct_choice
    B incorrect_choice

correct_choice
    BL INC_SCORE
    LDR R0, =MEM_USER_SEQUENCE
    LDR R2, [R0]
    LSR R2, #4
    STR R2, [R0]
    AND R2, #0xF
    CMP R2, #0
    BLEQ NEXT_LEVEL
    B return_user_select
incorrect_choice
    LDR     R0, =MEM_GAME_STATE  ; Load address of MEM_GAME_STATE
    MOV     R1, #2
    STRB     R1, [R0]

return_user_select
    POP {R0-R2, LR}
    BX LR
    ENDFUNC


NEXT_LEVEL FUNCTION
    PUSH {R0-R2, LR}
    LDR     R0, =MEM_SEQUENCE_LENGTH ; Load address of MEM_SEQUENCE_LENGTH
    LDRB     R1, [R0]
    ADD     R1, #2
    STRB    R1, [R0]
    CMP     R1, #8
    BGT     MAX_LEVEL
    BL GENERATE_SEQUENCE
    LDR R0, =MEM_SEQUENCE
    LDR R1, [R0]
    AND R1, #0xF
    LDR R0, =MEM_HIGHLIGHT_INDEX
    MOV R2, R1
    STRB R2, [R0]
    LDR R0, =MEM_SEQUENCE
    LDR R1, [R0]
    LSR R1, #4
    STR R1, [R0]
    B return_next_level

MAX_LEVEL
    LDR     R0, =MEM_GAME_STATE  ; Load address of MEM_GAME_STATE
    MOV     R1, #1
    STRB     R1, [R0]

return_next_level
    POP {R0-R2, LR}
    BX LR
    ENDFUNC




MEM_INC_INDEX FUNCTION
    PUSH {R0, R1, LR}
    LDR R0, =MEM_USER_INDEX
    LDRB R1, [R0]
    CMP R1, #9
    BEQ return_inc
    ADD R1, #1
    STRB R1, [R0]
return_inc
    POP {R0, R1, LR}
    BX LR
    ENDFUNC

MEM_DEC_INDEX FUNCTION
    PUSH {R0, R1, LR}
    LDR R0, =MEM_USER_INDEX
    LDRB R1, [R0]
    CMP R1, #1
    BEQ return_dec
    SUB R1, #1
    STRB R1, [R0]

return_dec
    POP {R0, R1, LR}
    BX LR
    ENDFUNC


MEM_RESET FUNCTION
    PUSH {R0, R1, LR}
    LDR     R0, =MEM_SCORE      ; Load address of MEM_SCORE
    MOV     R1, #0             ; Set R1 to 0
    STRB    R1, [R0]           ; Reset MEM_SCORE to 0

    LDR     R0, =MEM_SEQUENCE  ; Load address of MEM_SEQUENCE
    MOV     R1, #0             ; Set R1 to 0
    STR     R1, [R0]           ; Reset MEM_SEQUENCE to 0

    LDR     R0, =MEM_SEQUENCE_LENGTH ; Load address of MEM_SEQUENCE_LENGTH
    MOV     R1, #2             ; Set R1 to 0
    STRB    R1, [R0]           ; Reset MEM_SEQUENCE_LENGTH to 0

    LDR     R0, =MEM_PRNG_STATE  ; Load address of MEM_PRNG_STATE
    LDR     R1, =0x12345678      ; Initialize PRNG state with a seed value
    STRB    R1, [R0]             ; Store the seed value in MEM_PRNG_STATE

    LDR     R0, =MEM_GAME_STATE  ; Load address of MEM_GAME_STATE
    MOV     R1, #0               ; Set R1 to 0 (Playing state)
    STRB     R1, [R0]             ; Reset MEM_GAME_STATE to 0 (Playing)

    LDR     R0, =MEM_USER_INDEX  ; Load address of MEM_USER_INDEX
    MOV     R1, #1               ; Set R1 to 1
    STRB    R1, [R0]             ; Initialize MEM_USER_INDEX to 1

    LDR     R0, =MEM_HIGHLIGHT_INDEX ; Load address of MEM_HIGHLIGHT_INDEX
    MOV     R1, #-1               ; Set R1 to 0
    STRB    R1, [R0]             ; Initialize MEM_HIGHLIGHT_INDEX to 0

    BL GENERATE_SEQUENCE
    POP {R0, R1, LR}
    BX LR
    ENDFUNC


GENERATE_SEQUENCE FUNCTION
    PUSH {R0-R4, LR}
    LDR     R0, =MEM_SEQUENCE_LENGTH ; Load address of MEM_SEQUENCE_LENGTH
    LDRB     R1, [R0]
    MOV R4, #0
    MOV R2, #0
loop_generate_sequence
    CMP R2, R1              ; Compare R2 (current count) with R1 (total count)
    BGE end_generate_loop   ; If R2 >= R1, exit loop
    LSL R4, #4
    MOV R3, #9
    BL get_random           ; R0 = [0, 8]
    ADD R0, #1
    ADD R4, R0

    ADD R2, R2, #1          ; Increment loop counter
    B loop_generate_sequence ; Repeat loop

    
end_generate_loop
	LDR R0, =MEM_SEQUENCE
    LDR R1, =MEM_USER_SEQUENCE
    STR R4, [R0]
    STR R4, [R1]

    POP {R0-R4, LR}
    BX LR
    ENDFUNC

; Function: increment_score
; Increments MEM_SCORE by 1
INC_SCORE FUNCTION
    PUSH {R0-R1, LR}           ; Save registers
    LDR   R0, =MEM_SCORE    ; Load address of MEM_SCORE
    LDRB  R1, [R0]          ; Load current score
    ADD   R1, R1, #1        ; Increment score by 1
    STRB  R1, [R0]          ; Store updated score
    POP {R0-R1, LR}            ; Restore registers
    BX LR                   ; Return
    ENDFUNC


; Function: decrement_score
; Decrements MEM_SCORE by 1 (if greater than 0)
;DEC_SCORE FUNCTION
;    PUSH {R0-R1, LR}           ; Save registers
;    LDR   R0, =MEM_SCORE    ; Load address of MEM_SCORE
;    LDRB  R1, [R0]          ; Load current score
;    CMP   R1, #0            ; Check if score is greater than 0
;    BEQ   done              ; If score is 0, skip decrement
;    SUB   R1, R1, #1        ; Decrement score by 1
;    STRB  R1, [R0]          ; Store updated score
;done
;    POP {R0-R1, LR}            ; Restore registers
;    BX LR                   ; Return
;    ENDFUNC




; Function: get_random
; Inputs: R3 = max - 1
; Outputs: R0 = [0, R3 -1]
get_random  FUNCTION
    PUSH    {R1-R5, LR}        ; Save R4, R5, and LR

    ; Save R3 (range bound)
    MOV    R5, R3              ; R5 = R3 (preserve R3)

    ; Generate random number
    ; Load PRNG state
    LDR     R4, =MEM_PRNG_STATE     ; R4 = address of MEM_PRNG_STATE
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

; A / B = C
; A % B = D
; Inputs: R0 = A, R1 = B
; Output: R3 = Quotient, R2 = Remainder
DIVIDE FUNCTION
    PUSH {R0, R1, R2, LR}
    MOV  R2, R0             ; R2 = R0
    UDIV R0, R0, R1         ; R0 = R0 // R1
    MLS R4, R1, R0, R2      ; R2 = R2 - R1 * R0
    MOV R3, R0

    POP {R0, R1, R2, LR}
    BX LR
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

	END


