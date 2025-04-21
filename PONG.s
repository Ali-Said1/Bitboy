		; Constants
Width       EQU 480
Height      EQU 360
lbat_x  	EQU 0x0014
rbat_x  	EQU 0x01CC
ball_hwidth EQU	0x0A
pad_hheight EQU 0x64
pad_hwidth	EQU 0x05
scale_factor EQU 0x0040
		AREA    VECTORS, CODE, READONLY
        EXPORT  __Vectors
__Vectors
        DCD     0x20005000          ; Initial SP value (top of 400KB simulated SRAM)
        DCD     Reset_Handler   ; Reset handler address

        AREA	DATA, DATA, READWRITE
		EXPORT PONG
		EXPORT bg_color
		EXPORT ball_pos
		EXPORT lbat
		EXPORT rbat
		EXPORT score1
		EXPORT score2
		EXPORT ball_vel

PONG
		
ball_pos    DCD 0x01AF00A0	;XXXXYYYY
bg_color	DCW 0x6e3f
lbat    	DCW 0x00A0		;YYYY (X is constant 20)
rbat		DCW 0x00A0		;YYYY (X is constant 460)
score1		DCB 0x00		; max score is 255 (FF)
score2		DCB 0x00		; max score is 255 (FF)
ball_vel	DCW 0x0100		;(Vx)(Vx)(Vy)(Vy) (This is pixel per frame, a more accurate simulation would be per second, but this is more complicated.)
state        DCB 0x00		; 0 = game_on, 1 = right_won, 2 = left_won
prng_state
    DCD     0x12345678      ; Initial seed for the PRNG

        AREA CODE, CODE, READONLY
		EXPORT Reset_Handler
		EXPORT game_loop
Reset_Handler

        MOV sp, r13
        MOV r8, #0                ; Simulation steps

start
		; reset all data here
		; Store into bg_color (16-bit)
        LDR     R0, =bg_color
        MOV     R1, #0x6E3F         ; RGB565 value
        STRH    R1, [R0]            ; Store halfword

        
		
		; Store into ball_pos (32-bit)
        LDR     R0, =ball_pos
        LDR     R1, =0x00F000A0     ; XXXXYYYY
        STR     R1, [R0]

        ; Store into lbat (16-bit)
        LDR     R0, =lbat
        LDR     R1, =0x00A0     ; WWHHYYYY
        STRH     R1, [R0]

        ; Store into rbat (16-bit)
        LDR     R0, =rbat
        LDR     R1, =0x00A0     ; Same as lbat for now
        STRH     R1, [R0]

        ; Store into score (8-bit)
        LDR     R0, =score1
        MOV     R1, #0x00           ; Set score1 to 0
        STRB    R1, [R0]
		
		; Store into score (8-bit)
        LDR     R0, =score2
        MOV     R1, #0x00           ; Set score2 to 0
        STRB    R1, [R0]

        LDR    R0, =state
        MOV    R1, #0x00           ; Set state to 0 (game_on)
        STRB   R1, [R0]

        ; Store into ball_vel (16-bit)
        LDR     R0, =ball_vel
        MOV     R1, #0xFF00         ; VxVxVyVy
        STRH    R1, [R0]
		LDR r0, =PONG
		LDR r1, =ball_vel
game_loop
        ADD r8, r8, #1

        LDR r0, =score2
        LDRB r1, [r0]
		CMP r1, #0x0A
        BNE play
        LDR r0, =state
        MOV r1, #0x01           ; Set state to 1 (right_won)
        STRB r1, [r0]
        LDR r0, =score1
        LDRB r1, [r0]
		CMP r1, #0x0A
        BNE play
        LDR r0, =state
        MOV r1, #0x02           ; Set state to 1 (left_won)
        STRB r1, [r0]
play
		
		BL apply_vel
		BL check_collision_with_bats
		BL check_wall_collision
		BL follow
		LDR r0, =PONG
		LDR r1, =ball_vel
        B game_loop

hang
        B hang

; ----------------------------------------------------
; check_collision
    ; Assume R0 = address of ball_pos
    ; Assume R1 = address of rbat_y
    ; Assume R2 = address of lbat_y
check_collision_with_bats
	PUSH    {R0-R10, LR}
	LDR 	R0, =ball_pos
	LDR 	R1, =rbat
	LDR 	R2, =lbat
    ; Load ball_pos (32 bits) into R3
    LDR     R3, [R0]              ; R3 = ball_pos

    ; Extract ball_x from high halfword
    LSR    	R4, R3, #16           ; R4 = ball_x

    ; Extract ball_y from low halfword
    UXTH    R5, R3                ; R5 = ball_y

    ; --- Check against Right Paddle ---
    MOV	    R6, #rbat_x

    SUB     R7, R6, #ball_hwidth    ; R5 = R6 - ball_width/2
	SUB     R7, R7, #pad_hwidth    ; R5 = R6 - ball_width/2
    CMP     R4, R7                  ; Compare ball X (R4) with (R6 - ball_width/2)
    BLT     check_left_paddle       ; If R4 < R6 - ball_width/2, jump to check_left_paddle (out of range)
    CMP     R4, R6                  ; Compare ball X (R4) with R6
    BGT     score_lp		       	; If R4 > R6, jump to check_left_paddle (out of range)


    ; Ball is at right paddle X, check Y
    LDRH    R7, [R1]              ; R7 = rbat_y

    ; R5 = ball_y, R7 = paddle_y
    ; Subtract R7 from R5 and take abs diff
    SUBS R8, R5, R7     ; R8 = R5 - R7, set flags (C = 1 if no borrow, C = 0 if borrow)
    BCS no_negate_rbat       ; Branch to no_negate if C = 1 (no borrow, R8 is positive)
    RSBS R8, R8, #0     ; R8 = 0 - R0 (negate R0 to get |R5 - R7|)
no_negate_rbat
	CMP     R8, #pad_hheight
    BLS     collision_detected


check_left_paddle
    MOVS    R6, #lbat_x

    ADD     R7, R6, #ball_hwidth    ; R7 = R6 + ball_width/2
	ADD     R7, R7, #pad_hwidth    	; R7 = R7 + pad_width/2
    CMP     R4, R7                  ; Compare ball X (R4) with (R6 + ball_width/2)
    BGE     no_collision       		; If R4 > R6 + ball_width/2, jump to no_collision
    CMP     R4, R6                  ; Compare ball X (R4) with R6
    BLT     score_rp       			; If R4 < R6

    ; Ball is at left paddle X, check Y
    LDRH    R7, [R2]              	; R7 = rbat_y

    ; R5 = ball_y, R7 = paddle_y
    ; Subtract R7 from R5 and take abs diff
    SUBS 	R8, R5, R7     			; R8 = R5 - R7, set flags (C = 1 if no borrow, C = 0 if borrow)
    BCS 	no_negate_lbat       	; Branch to no_negate if C = 1 (no borrow, R8 is positive)
    RSBS 	R8, R8, #0     			; R8 = 0 - R8 (negate R0 to get |R1 - R2|)
no_negate_lbat
	CMP     R8, #pad_hheight
    BLS     collision_detected
no_collision
    ; No collision
    B       continue_game

collision_detected
	LDR     R0, =ball_vel     	; R0 points to ball_vel
	LDRSB   R8, [R0, #1]      	; Load ball_vel (VxVx)
	RSBS	R8, R8, #0			; Change X direction
	STRB   	R8, [R0, #1]      	; Store ball_vel (VxVx)
	
	SUB     R3, R5, R7         ; R3 = ball_y - paddle_y
	; Load scale factor (0.25 in Q8.8)
	LDR     R4, =0x0040        ; scale factor = 0.25 * 256 = 64
	; Multiply difference by scale factor
	MUL     R3, R3, R4         ; R3 = (ball_y - paddle_y) * 0.25 in Q8.8
	; Shift down to get integer result (Q8.8 to int)
	MOV     R3, R3, ASR #8     ; R3 = final vy
	; Store result in *vy (at address in R2)
	STRB     R3, [R0]
	B 		continue_game
score_rp
    ; Right paddle scored
	LDR		R0, =score2
	LDRB	R1, [R0]
	ADD		R1, R1, #0x1
	STRB	R1, [R0]
	; Reset ball_pos
	LDR     R0, =ball_pos
	LDR     R1, =0x00F000A0     ; XXXXYYYY
	STR     R1, [R0]
	B 		continue_game
score_lp
    ; Left paddle scored
	LDR		R0, =score1
	LDRB	R1, [R0]
	ADD		R1, R1, #0x1
	STRB	R1, [R0]
	; Reset ball_pos
	LDR     R0, =ball_pos
	LDR     R1, =0x00F000A0     ; XXXXYYYY
	STR     R1, [R0]
	B 		continue_game
continue_game
	POP    {R0-R10, LR}
	BX LR


; Function: check_wall_collision
    ; Inputs: None (accesses ball_pos and ball_vel via memory)
    ; Outputs: None (modifies ball_vel[0] if collision detected)
    ; Clobbers: None (saves/restores R0-R10, LR)
check_wall_collision
    PUSH    {R0-R10, LR}        ; Save R0-R10 and LR

    ; Load ball_pos (16 bits) into R5
    LDR     R0, =ball_pos       ; R0 = address of ball_pos
    LDRH     R5, [R0]            ; R5 = ball_pos

    ; Check for top wall collision (y < ball_hwidth)
    CMP     R5, #ball_hwidth              ; Compare y with ball_hwidth
    BLT     wall_collision_detected     ; Branch if y < ball_hwidth (signed, though y is unsigned, so this won't trigger)

    ; Check for bottom wall collision (y >= HEIGHT - ball_hwidth)
    MOV    R1, #Height         ; R1 = HEIGHT
	SUB		R1, R1, #ball_hwidth ; R1 = HEIGHT - ball_hwidth
    CMP     R5, R1              ; Check collision with bottom wall
    BGE     wall_collision_detected  ; Branch if (y >= HEIGHT - ball_hwidth)

    ; No collision
    B       check_wall_collision_ret       ; Jump to end

wall_collision_detected
    ; Load and reverse y-velocity (Vy)
    LDR     R0, =ball_vel       ; R0 = address of ball_vel
    LDRSB   R8, [R0]        	; R8 = Vy (signed 8-bit)
    RSBS    R8, R8, #0          ; R8 = -Vy (negate y-velocity)
	
    ; Store reversed y-velocity
    STRB    R8, [R0]        	; Update Vy in memory

check_wall_collision_ret
    POP     {R0-R10, LR}        ; Restore R0-R10 and LR
    BX      LR                  ; Return




; ----------------------------------------------------
; apply_vel: applies the velocity vector on the ball_pos
apply_vel
        PUSH    {R0-R4, LR}        	; Save callee-saved register and return address
        LDR     R0, =ball_vel     	; R0 points to ball_vel
        LDR     R1, =ball_pos     	; R1 points to ball_pos

        LDRSB     R2, [R0, #1]      ; Load ball_vel (VxVx)
		TST   R2, #0x80000000   	; Test if bit 31 is set
		BNE   subtract_x   
		
        LDRH    R4, [R1, #2]       	; Load X position (XXXX)
        ADD     R4, R4, R2        	; Add Vx to X
        STRH    R4, [R1, #2]       	; Store updated X back
		B end_x
subtract_x
		LDRH    R4, [R1, #2]       	; Load X position (XXXX)
		MVN  	R2, R2  			; Complement
		ADD  	R2, R2, #1 			; Two's Complement
        SUB     R4, R4, R2        	; Subtract The complemented value
        STRH     R4, [R1, #2]       ; Store updated X back


end_x
		LDRSB     R2, [R0]          ; Load ball_vel (VyVy)
		TST   R2, #0x80000000   	; Test if bit 31 is set
		BNE   subtract_y       

        LDRH     R4, [R1]          	; Load position (YYYY)
        ADD     R4, R4, R2        	; Add Vy to Y
        STRH     R4, [R1]          	; Store updated Y back
		B end_y

subtract_y
		LDRH    R4, [R1]       	; Load Y position (YYYY)
		MVN  	R2, R2    			; Complement
		ADD  	R2, R2, #1 			; Two's Complement
        SUB     R4, R4, R2        	; Subtract The complemented value
        STRH     R4, [R1]       ; Store updated Y back

end_y
        POP     {R0-R4, LR}        ; Restore registers
        BX      LR                	; Return


; Not needed but may be useful later.
;; Function: get_random_bounded
;    ; Inputs: R3 = range bound (positive integer, output will be in [-R3, R3])
;    ; Outputs: R0 = 32-bit pseudo-random number in [-R3, R3]
;    ; Clobbers: R1, R2, R3
;get_random_bounded
;    PUSH    {R0-R5, LR}        ; Save R4, R5, and LR
;
;    ; Save R3 (range bound)
;    MOV    R5, R3              ; R5 = R3 (preserve R3)
;
;    ; Generate random number
;    ; Load PRNG state
;    LDR     R4, =prng_state     ; R4 = address of prng_state
;    LDR     R0, [R4]            ; R0 = current state
;
;    ; Compute: state = state * 1664525
;    MOV    R1, #0x60D          ; Lower 16 bits of multiplier
;    MOVT    R1, #0x196          ; Upper 16 bits of multiplier
;    MUL    R2, R0, R1          ; R2 = state * 1664525 (low 32 bits)
;
;    ; Add increment: 1013904223 = 0x3C6EF35F
;    MOV    R1, #0xF35F         ; Lower 16 bits of increment
;    MOVT    R1, #0x3C6E         ; Upper 16 bits of increment
;    ADD    R2, R2, R1          ; R2 = R2 + 1013904223 (mod 2^32 via overflow)
;
;    ; Store new state
;    STR     R2, [R4]            ; prng_state = new state
;
;    ; Move result to R0
;    MOV    R0, R2              ; R0 = random number
;
;    ; Bound the random number to [-R3, R3]
;    ; Compute range size: 2 * R3 + 1
;    LSL    R1, R5, #1          ; R1 = 2 * R3
;    ADDS    R1, R1, #1          ; R1 = 2 * R3 + 1 (range size)
;
;    ; Simple scaling: mask R0 to range size
;    ; Assume R1 is small (e.g., < 2^16) for simplicity
;    AND    R0, R0, R1          ; R0 = R0 % (2 * R3 + 1) approximation
;
;    ; Shift to [-R3, R3]: subtract R3
;    SUB    R10, R0, R5          ; R0 = R0 - R3
;
;    POP     {R0-R5, LR}        ; Restore R4, R5, and return
;	BX LR
;

; ----------------------------------------------------
; follow: For Simulation purposes
follow
        PUSH {r3-r12, lr}
        LDR 	r10, =ball_pos
        LDRH 	r6, [r10]
		ADD		r6, r6, #20
        LDR 	r10, =rbat
        STRH 	r6, [r10]
		SUB		r6, r6, #40
		;LDR 	r10, =lbat
        ;STRH 	r6, [r10]
        POP {r3-r12, lr}
        BX lr




; ----------------------------------------------------
; rbat_down: Move right bat down
rbat_down
        PUSH {r3-r12, lr}
        LDR r10, =rbat
        LDRH r6, [r10]
        ADDS r6, r6, #3
		MOV r7, #Height
		SUB r7, r7, #pad_hheight
        CMP r6, r7
        BGE rbat_down_return
        STRH r6, [r10]
rbat_down_return
        POP {r3-r12, lr}
        BX lr

; ----------------------------------------------------
; rbat_up: Move right bat up
rbat_up
        PUSH {r3-r12, lr}
        LDR r10, =rbat
        LDRH r6, [r10]
        SUB r6, r6, #3
        CMP r6, #pad_hheight
        BLE rbat_up_return
        STRH r6, [r10]
rbat_up_return
        POP {r3-r12, lr}
        BX lr


