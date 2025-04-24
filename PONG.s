		; Constants['']
        AREA PONGCONST, DATA, READONLY
        EXPORT PONG_bg_color
        EXPORT PONG_lbat_x
        EXPORT PONG_rbat_x
        EXPORT PONG_ball_hdim
        EXPORT PONG_pad_hheight
        EXPORT PONG_pad_hwidth
PONG_bg_color	EQU 0x6e3f
Width       EQU 480
Height      EQU 320
PONG_lbat_x  	EQU 0x0014
PONG_rbat_x  	EQU 0x01CC
PONG_ball_hdim EQU	0x0A
PONG_pad_hheight EQU 0x32
PONG_pad_hwidth	EQU 0x05
scale_factor EQU 0x0006

    ALIGN
        AREA	PONGVARS, DATA, READWRITE
		EXPORT PONG
		EXPORT PONG_ball_pos
		EXPORT PONG_lbat
		EXPORT PONG_rbat
		EXPORT PONG_score1
		EXPORT PONG_score2
        EXPORT PONG_state
        EXPORT PONG_GAME_MODE
		;EXPORT ball_vel

PONG
		
PONG_ball_pos    DCD 0x00F000A0	;XXXXYYYY

PONG_lbat    	DCW 0x00A0		;YYYY (X is constant 20)
PONG_rbat		DCW 0x00A0		;YYYY (X is constant 460)
PONG_score1		DCB 0x00		; max score is 255 (FF)
PONG_score2		DCB 0x00		; max score is 255 (FF)
ball_vel	DCW 0x0100		;(Vx)(Vx)(Vy)(Vy) (This is pixel per frame, a more accurate simulation would be per second, but this is more complicated.)
PONG_state        DCB 0x00		; 0 = game_starting, 1 = game mode select, 2 =game_on, 3 = right_won, 4 = left_won

PONG_GAME_MODE        DCB 0x00		; 0 = Single player, 1= Multiplayer

        AREA PONGCODE, CODE, READONLY
		EXPORT PONG_RESET
		EXPORT PONG_LOOP
		EXPORT PONG_BAT_UP
        EXPORT PONG_BAT_DOWN

PONG_RESET FUNCTION
		; reset all data here
		; Store into PONG_ball_pos (32-bit)
        LDR     R0, =PONG_ball_pos
        LDR     R1, =0x00F000A0     ; XXXXYYYY
        STR     R1, [R0]

        ; Store into PONG_lbat (16-bit)
        LDR     R0, =PONG_lbat
        LDR     R1, =0x00A0     ; YYYY
        STRH     R1, [R0]

        ; Store into PONG_rbat (16-bit)
        LDR     R0, =PONG_rbat
        LDR     R1, =0x00A0     ; Same as PONG_lbat for now
        STRH     R1, [R0]

        ; Store into score (8-bit)
        LDR     R0, =PONG_score1
        MOV     R1, #0x00           ; Set PONG_score1 to 0
        STRB    R1, [R0]
		
		; Store into score (8-bit)
        LDR     R0, =PONG_score2
        MOV     R1, #0x00           ; Set PONG_score2 to 0
        STRB    R1, [R0]

        LDR    R0, =PONG_state
        MOV    R1, #0x00           ; Set PONG_state to 0 (game_on)
        STRB   R1, [R0]

        ; Store into ball_vel (16-bit)
        LDR     R0, =ball_vel
        MOV     R1, #0xFF00         ; VxVxVyVy
        STRH    R1, [R0]
    ENDFUNC
PONG_LOOP FUNCTION
        PUSH{R0-R11, LR}
        LDR     R0, =PONG_GAME_MODE
        LDRB    R0, [R0]            ; Load game mode (0 = single player, 1 = multiplayer)
        CMP     R0, #0              ; Check if single player mode
        BLEQ     PONG_FOLLOW        ; If yes, branch to PONG_FOLLOW
        BL check_win_condition
		BL apply_vel
		BL check_collision_with_bats
		BL check_wall_collision
        POP{R0-R11, LR}
        BX LR

; ----------------------------------------------------
; PONG_FOLLOW: Computer controlled lbat
PONG_FOLLOW
    ; Save registers r0 to r3 and LR on the stack
    PUSH {r0-r3, lr}

    ; Load the address of PONG_ball_pos into r3 and then load its lower halfword (ball Y position)
    LDR     r3, =PONG_ball_pos 
    LDRH    r3, [r3]

    ; Load the address of PONG_lbat into r2 and then load its current Y position
    LDR     r2, =PONG_lbat
    LDRH    r2, [r2]

    ; Compare ball Y position (r3) with left bat Y position (r2)
    CMP     r3, r2

    ; If ball is below the left bat, branch to move_down
    BGT     move_down

    ; Compare ball Y position (r3) with left bat Y position (r2) again
    CMP     r3, r2

    ; If ball is above the left bat, branch to move_up
    BLT     move_up

    ; Otherwise, do nothing and jump to end_follow
    B       end_follow

move_down
    ; Move the left bat down
    ; Load the address of PONG_lbat into r0
    LDR     R0, =PONG_lbat
    ; Load current bat Y position into r1
    LDR     R1, [R0]
    ; Increment bat Y position
    ADD     R1, R1, #1
    ; Store the updated Y position back into PONG_lbat
    STRH    R1, [R0]
    ; Jump to end_follow
    B       end_follow

move_up
    ; Move the left bat up
    ; Load the address of PONG_lbat into r0
    LDR     R0, =PONG_lbat
    ; Load current bat Y position into r1
    LDR     R1, [R0]
    ; Decrement bat Y position
    SUB     R1, R1, #1
    ; Store the updated Y position back into PONG_lbat
    STRH    R1, [R0]

end_follow
    ; Restore registers r0 to r3 and LR from the stack
    POP     {r0-r3, lr}
    BX      lr


; ----------------------------------------------------
; Function: check_win_condition
;    ; Inputs: None (accesses PONG_score1 and PONG_score2 via memory)
;    ; Outputs: None (modifies PONG_state if a player wins)
;    ; Clobbers: None (saves/restores R0-R10, LR)
check_win_condition
    PUSH    {R0-R2, LR}        ; Save R0-R10 and LR
    LDR     R0, =PONG_score1       ; R0 = address of PONG_score1
    LDRB    R1, [R0]              ; R1 = PONG_score1
    LDR     R0, =PONG_score2       ; R0 = address of PONG_score2
    LDRB    R2, [R0]              ; R2 = PONG_score2

    CMP     R1, #0x07           ; Check if PONG_score1 >= 7
    BGE     left_player_wins     ; If yes, branch to left_player_wins
    CMP     R2, #0x07           ; Check if PONG_score2 >= 7
    BGE     right_player_wins     ; If yes, branch to right_player_wins
    B       end_check_win_condition  ; No player has won, return

right_player_wins
    LDR     R0, =PONG_state       ; R0 = address of PONG_state
    MOV     R1, #0x03           ; Set PONG_state to 3 (right player wins)
    STRB    R1, [R0]            ; Store PONG_state
    B       end_check_win_condition

left_player_wins
    LDR     R0, =PONG_state       ; R0 = address of PONG_state
    MOV     R1, #0x04           ; Set PONG_state to 4 (left player wins)
    STRB    R1, [R0]            ; Store PONG_state

end_check_win_condition
    POP     {R0-R2, LR}        ; Restore R0-R10 and LR
    BX     LR                  ; Return

; ----------------------------------------------------
; check_collision
    ; Assume R0 = address of PONG_ball_pos
    ; Assume R1 = address of rbat_y
    ; Assume R2 = address of lbat_y
check_collision_with_bats
	PUSH    {R0-R10, LR}
	LDR 	R0, =PONG_ball_pos
	LDR 	R1, =PONG_rbat
	LDR 	R2, =PONG_lbat
    ; Load PONG_ball_pos (32 bits) into R3
    LDR     R3, [R0]              ; R3 = PONG_ball_pos

    ; Extract ball_x from high halfword
    LSR    	R4, R3, #16           ; R4 = ball_x

    ; Extract ball_y from low halfword
    UXTH    R5, R3                ; R5 = ball_y

    ; --- Check against Right Paddle ---
    MOV	    R6, #PONG_rbat_x

    SUB     R7, R6, #PONG_ball_hdim    ; R7 = R6 - ball_width/2
	SUB     R7, R7, #PONG_pad_hwidth    ; R7 = R7 - pad_width/2
    CMP     R4, R7                  ; Compare ball X (R4) with (R6 - ball_width/2)
    BLT     check_left_paddle       ; If R4 < R6 - (ball_width/2 + pad_width/2), jump to check_left_paddle (out of range)
    CMP     R4, R6                  ; Compare ball X (R4) with R6
    BGT     score_lp		       	; If R4 > R6, jump to add point to score to left player


    ; Ball is at right paddle X, check Y
    LDRH    R7, [R1]              ; R7 = rbat_y

    ; R5 = ball_y, R7 = paddle_y
    ; Subtract R7 from R5 and take abs diff
    SUBS R8, R5, R7     ; R8 = R5 - R7, set flags (C = 1 if no borrow, C = 0 if borrow)
    BCS no_negate_rbat       ; Branch to no_negate if C = 1 (no borrow, R8 is positive)
    RSBS R8, R8, #0     ; R8 = 0 - R0 (negate R0 to get |R5 - R7|)
no_negate_rbat
    SUB R8, R8, #PONG_ball_hdim
	CMP     R8, #PONG_pad_hheight
    BLT     collision_detected


check_left_paddle
    MOVS    R6, #PONG_lbat_x

    ADD     R7, R6, #PONG_ball_hdim    ; R7 = R6 + ball_width/2
	ADD     R7, R7, #PONG_pad_hwidth    	; R7 = R7 + pad_width/2
    CMP     R4, R7                  ; Compare ball X (R4) with (R6 + ball_width/2)
    BGT     no_collision       		; If R4 > R6 + ball_width/2, jump to no_collision
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
    SUB     R8, R8, #PONG_ball_hdim
	CMP     R8, #PONG_pad_hheight
    BLT     collision_detected
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
	LDR     R4, =scale_factor        ; scale factor = 0.25 * 256 = 64
	; Multiply difference by scale factor
	MUL     R3, R3, R4         ; R3 = (ball_y - paddle_y) * 0.25 in Q8.8
	; Shift down to get integer result (Q8.8 to int)
	MOV     R3, R3, ASR #8     ; R3 = final vy
	; Store result in *vy (at address in R2)
	STRB     R3, [R0]
	B 		continue_game
score_rp
    ; Right paddle scored
	LDR		R0, =PONG_score2
	LDRB	R1, [R0]
	ADD		R1, R1, #0x1
	STRB	R1, [R0]
	; Reset PONG_ball_pos
	LDR     R0, =PONG_ball_pos
	LDR     R1, =0x00F000A0     ; XXXXYYYY
	STR     R1, [R0]
    ; Reset PONG_ball_vel
    LDR R0, =ball_vel
    LDR R1, =0xFF00         ; VxVxVyVy
    STRH R1, [R0]
	B 		continue_game
score_lp
    ; Left paddle scored
	LDR		R0, =PONG_score1
	LDRB	R1, [R0]
	ADD		R1, R1, #0x1
	STRB	R1, [R0]
	; Reset PONG_ball_pos
	LDR     R0, =PONG_ball_pos
	LDR     R1, =0x00F000A0     ; XXXXYYYY
	STR     R1, [R0]
    ; Reset PONG_ball_vel
    LDR R0, =ball_vel
    LDR R1, =0x0100         ; VxVxVyVy
    STRH R1, [R0]
	B 		continue_game
continue_game
	POP    {R0-R10, LR}
	BX LR


; Function: check_wall_collision
    ; Inputs: None (accesses PONG_ball_pos and ball_vel via memory)
    ; Outputs: None (modifies ball_vel[0] if collision detected)
    ; Clobbers: None (saves/restores R0-R10, LR)
check_wall_collision
    PUSH    {R0-R10, LR}        ; Save R0-R10 and LR

    ; Load PONG_ball_pos (16 bits) into R5
    LDR     R0, =PONG_ball_pos       ; R0 = address of PONG_ball_pos
    LDRH     R5, [R0]            ; R5 = PONG_ball_pos

    ; Check for top wall collision (y < PONG_ball_hdim)
    CMP     R5, #PONG_ball_hdim              ; Compare y with PONG_ball_hdim
    BLT     wall_collision_detected     ; Branch if y < PONG_ball_hdim (signed, though y is unsigned, so this won't trigger)

    ; Check for bottom wall collision (y >= HEIGHT - PONG_ball_hdim)
    MOV    R1, #Height         ; R1 = HEIGHT
	SUB		R1, R1, #PONG_ball_hdim ; R1 = HEIGHT - PONG_ball_hdim
    CMP     R5, R1              ; Check collision with bottom wall
    BGE     wall_collision_detected  ; Branch if (y >= HEIGHT - PONG_ball_hdim)

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
; apply_vel: applies the velocity vector on the PONG_ball_pos
apply_vel
        PUSH    {R0-R4, LR}        	; Save callee-saved register and return address
        LDR     R0, =ball_vel     	; R0 points to ball_vel
        LDR     R1, =PONG_ball_pos     	; R1 points to PONG_ball_pos

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
	ENDFUNC
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
;    ; Load PRNG PONG_state
;    LDR     R4, =prng_state     ; R4 = address of prng_state
;    LDR     R0, [R4]            ; R0 = current PONG_state
;
;    ; Compute: PONG_state = PONG_state * 1664525
;    MOV    R1, #0x60D          ; Lower 16 bits of multiplier
;    MOVT    R1, #0x196          ; Upper 16 bits of multiplier
;    MUL    R2, R0, R1          ; R2 = PONG_state * 1664525 (low 32 bits)
;
;    ; Add increment: 1013904223 = 0x3C6EF35F
;    MOV    R1, #0xF35F         ; Lower 16 bits of increment
;    MOVT    R1, #0x3C6E         ; Upper 16 bits of increment
;    ADD    R2, R2, R1          ; R2 = R2 + 1013904223 (mod 2^32 via overflow)
;
;    ; Store new PONG_state
;    STR     R2, [R4]            ; prng_state = new PONG_state
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

    END
; ----------------------------------------------------
; PONG_BAT_DOWN: Move bat down
; Input: R0 = address of bat_y (16-bit)
; Output: Updates bat_y if within bounds
PONG_BAT_DOWN FUNCTION
    PUSH {r0,r6,r7,r10, lr}
    MOV r10, r0
    LDRH r6, [r10]
    ADD r6, r6, #1
    MOV r7, #Height
    SUB r7, r7, #PONG_pad_hheight
    CMP r6, r7
    BGE bat_down_return
    STRH r6, [r10]
bat_down_return
    POP {r0,r6,r7,r10, lr}
    BX lr
    ENDFUNC


; ----------------------------------------------------
; PONG_BAT_UP: Move bat up
; Input: R0 = address of bat_y (16-bit)
; Output: Updates bat_y if within bounds
PONG_BAT_UP FUNCTION
    PUSH {r0,r6,r10, lr}
    MOV r10, r0
    LDRH r6, [r10]
    SUB r6, r6, #1
    CMP r6, #PONG_pad_hheight
    BLE bat_up_return
    STRH r6, [r10]
bat_up_return
    POP {r0,r6,r7,r10, lr}
    BX lr
    ENDFUNC