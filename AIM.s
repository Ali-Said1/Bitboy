		; Constants
Width       EQU 480
Height      EQU 320
TARGET_R		EQU 10
		AREA    VECTORS, CODE, READONLY
        EXPORT  __Vectors
__Vectors
        DCD     0x20005000          ; Initial SP value (top of 400KB simulated SRAM)
        DCD     Reset_Handler   ; Reset handler address

        AREA	DATA, DATA, READWRITE
        ; IMPORT systime
        EXPORT AIM_POS
        EXPORT AIM_SCORE
        EXPORT OBJ1_POS
        EXPORT OBJ2_POS
        EXPORT OBJ3_POS
        EXPORT AIM_VEL
        EXPORT AIM_PRNG_STATE
AIM_POS  DCD 0           ; Aim absolute position XXXXYYYY
OBJ1_POS DCW 0           ; OBJ1 grid position XXYY ([0, 47], [0, 31])
OBJ2_POS DCW 0           ; OBJ2 grid position XXYY ([0, 47], [0, 31])
OBJ3_POS DCW 0           ; OBJ3 grid position XXYY ([0, 47], [0, 31])
AIM_VEL  DCW 0           ; Aim velocity XXYY px/ SECOND
AIM_POS_DELTA_X DCW 0x0000 
AIM_POS_DELTA_X_DECIMAL DCW 0x0000 

AIM_POS_DELTA_Y DCW 0x0000 ; Δ position in y direction used to accumulate position change, then we take its upper byte to update position
AIM_POS_DELTA_Y_DECIMAL DCW 0x0000 
AIM_PRNG_STATE
    DCD     0x12815678    ; INITIAL SEED FOR THE PRNG
AIM_SYSTIME
    DCD     0    ; SYSTIME (THIS IS VIRTUAL)
AIM_LAST_SYSTIME
    DCD     0    ; SYSTIME OF LAST FRAME

AIM_SCORE DCB 0

        AREA CODE, CODE, READONLY
        EXPORT Reset_Handler
        
Reset_Handler FUNCTION
		BL Reset
        MOV     R0, #0
        BL SPAWN_OBJ
        MOV     R0, #1
        BL SPAWN_OBJ
        MOV     R0, #2
        BL SPAWN_OBJ
        LDR   r0, =AIM_VEL
        MOV   r1, #0x00F0
        STRH  r1, [r0]
game_loop
		
        LDR   r0, =AIM_SYSTIME
        LDR   r1, [r0]
        ADD   r1, #17
        STR  r1, [r0]
		LDR   r0, =AIM_VEL
        STRH  r10, [r0]

        BL apply_vel_x
        BL apply_vel_y
		CMP R12, #1
        BLEQ SHOOT
		
		B game_loop
	ENDFUNC

SHOOT FUNCTION
    PUSH {R0-R12, LR}          ; Save registers

    LDR   R0, =AIM_POS        ; Load AIM_POS
    LDR   R7, [R0]            ; R7 = AIM_POS (XXXXYYYY)

    MOV   R0, #0              ; Start with object index 0
    MOV   R2, #3              ; Total number of objects (3 in this case)

loop_objects
    CMP   R0, R2              ; Check if all objects are processed
    BGE   done_objects        ; If yes, exit loop

    ; Compute address of object position: OBJ_POS_BASE + R0 * 2
    LSL   R3, R0, #1          ; R3 = R0 * 2 (each object takes 2 bytes)
    LDR   R4, =OBJ1_POS       ; R4 = base address
    ADD   R4, R4, R3          ; R4 = address of this object's position

    LDRH  R6, [R4]            ; R6 = Object position (XXYY)

    ; Extract X and Y components
    UXTH  R4, R6              ; R4 = XXYY (clear upper 16 bits)
    LSR   R5, R4, #8          ; R5 = X (upper byte of XXYY)
    AND   R4, R4, #0xFF       ; R4 = Y (lower byte of XXYY)

    ; Multiply X by 10
    MOV   R6, #10
    MUL   R5, R5, R6          ; R5 = X * 10

    ; Multiply Y by 10
    MUL   R4, R4, R6          ; R4 = Y * 10

    ; Combine X and Y back into R6
    LSL   R5, R5, #16         ; Shift X * 10 to upper word
    ORR   R6, R5, R4          ; Combine X * 10 (upper) and Y * 10 (lower)

    
    ; R6 = OBJ Position, R7 = AIM Position
    ; Call CALC_DISTANCE
    BL    CALC_DISTANCE       ; R5 = distance

    ; Check if distance is less than constant value
    LDR   R6, =(TARGET_R*TARGET_R)
    CMP   R5, R6              ; Compare distance with constant
    BGE   next_object         ; If distance >= constant, skip to next object

    ; If distance < TARGET_R
    MOV R8, #1                  ; Object HIT
    BL    INC_SCORE
    BL    DESPAWN_OBJ         ; Despawn the object
	BL    SPAWN_OBJ         ; Despawn the object
next_object
    ADD   R0, R0, #1          ; Increment object index
    B     loop_objects        ; Repeat for next object

done_objects
    CMP R8, #1
    BEQ return_shoot
    BL DEC_SCORE
return_shoot
    POP   {R0-R12, LR}          ; Restore registers
    BX    LR                  ; Return
	ENDFUNC

	LTORG

; Function: increment_score
; Increments AIM_SCORE by 1
INC_SCORE FUNCTION
    PUSH {R0-R1, LR}           ; Save registers
    LDR   R0, =AIM_SCORE    ; Load address of AIM_SCORE
    LDRB  R1, [R0]          ; Load current score
    ADD   R1, R1, #1        ; Increment score by 1
    STRB  R1, [R0]          ; Store updated score
    POP {R0-R1, LR}            ; Restore registers
    BX LR                   ; Return
    ENDFUNC

; Function: decrement_score
; Decrements AIM_SCORE by 1 (if greater than 0)
DEC_SCORE FUNCTION
    PUSH {R0-R1, LR}           ; Save registers
    LDR   R0, =AIM_SCORE    ; Load address of AIM_SCORE
    LDRB  R1, [R0]          ; Load current score
    CMP   R1, #0            ; Check if score is greater than 0
    BEQ   done              ; If score is 0, skip decrement
    SUB   R1, R1, #1        ; Decrement score by 1
    STRB  R1, [R0]          ; Store updated score
done
    POP {R0-R1, LR}            ; Restore registers
    BX LR                   ; Return
    ENDFUNC



; Inputs
; R6 = POINT1 (XXXXYYYY)
; R7 = POINT2 (XXXXYYYY)
; Output
; R5 = Distance**2
CALC_DISTANCE FUNCTION
    PUSH {R0-R4, LR}          ; Save registers

    ; Extract X1 and Y1 from POINT1 (R6)
    MOV   R0, R6              ; R0 = POINT1
    LSR   R1, R0, #16         ; R1 = X1 (upper 16 bits of POINT1)
    UXTH  R2, R0              ; R2 = Y1 (lower 16 bits of POINT1)

    ; Extract X2 and Y2 from POINT2 (R7)
    MOV   R0, R7              ; R0 = POINT2
    LSR   R3, R0, #16         ; R3 = X2 (upper 16 bits of POINT2)
    UXTH  R4, R0              ; R4 = Y2 (lower 16 bits of POINT2)

    ; Calculate ΔX = X2 - X1
    SUB   R1, R3, R1          ; R1 = ΔX
    SXTH  R1, R1              ; Sign-extend ΔX

    ; Calculate ΔY = Y2 - Y1
    SUB   R2, R4, R2          ; R2 = ΔY
    SXTH  R2, R2              ; Sign-extend ΔY

    ; Calculate ΔX^2
    MUL   R3, R1, R1          ; R3 = ΔX^2

    ; Calculate ΔY^2
    MUL   R4, R2, R2          ; R4 = ΔY^2

    ; Calculate ΔX^2 + ΔY^2
    ADD   R5, R3, R4          ; R5 = ΔX^2 + ΔY^2

    POP {R0-R4, LR}           ; Restore registers
    BX LR                     ; Return
    ENDFUNC




Reset FUNCTION
    PUSH {LR}
    
    ; Initialize variables in memory
    LDR   r0, =AIM_POS
    LDR   r1, =0x00E000A0              ; Initial Aim position (XXXXYYYY = 0)
    STR   r1, [r0]

    LDR   r0, =AIM_VEL
    MOV   r1, #0x0000              ; Initial Aim velocity (XXYY = 0)
    STRH  r1, [r0]

    LDR   r0, =OBJ1_POS
    MOV   r1, #0x9090              ; Initial OBJ1 grid position (XXYY = 0)
    STRH  r1, [r0]

    LDR   r0, =OBJ2_POS
    MOV   r1, #0x1390              ; Initial OBJ2 grid position (XXYY = 0)
    STRH  r1, [r0]

    LDR   r0, =OBJ3_POS
    MOV   r1, #0x0000              ; Initial OBJ3 grid position (XXYY = 0)
    STRH  r1, [r0]

    ; Optionally re-initialize the PRNG state 
    LDR   r0, =AIM_PRNG_STATE
    LDR   r1, =0x12345678     ; Re-set initial seed
    STR   r1, [r0]

    POP {LR}
    BX LR
	ENDFUNC


; Inputs R0 = Object Index
SPAWN_OBJ FUNCTION
    PUSH {R1-R4, LR}

    ; Compute address of object position: OBJ_POS_BASE + R0 * 2
    LSL     R1, R0, #1          ; R1 = R0 * 2 (each object takes 2 bytes)
    LDR     R2, =OBJ1_POS       ; R2 = base address
    ADD     R2, R2, R1          ; R2 = address of this object's position

    ; Get random x (0 to 45)
    MOV     R3, #46             ; max x is 45, so pass 46
    BL      get_random
    ADD     R0, #1
    MOV     R4, R0              ; R4 = x

    ; Store x in high byte (<< 8)
    LSL     R4, R4, #8          ; shift x to upper byte

    ; Get random y (0 to 29)
    MOV     R3, #30             ; max y is 29, so pass 30
    BL      get_random
    ADD     R0, #1
    ORR     R4, R4, R0          ; combine y (low byte) with x (already in upper byte)
                                
    ; Store 2-byte XXYY at object position
    STRH    R4, [R2]            ; Store halfword (16-bit) to memory

    POP {R1-R4, LR}
    BX LR
	ENDFUNC


; Inputs
; R0 = OBJ Index
DESPAWN_OBJ FUNCTION
    PUSH {R1-R4, LR}

    ; Compute address of object position: OBJ_POS_BASE + R0 * 2
    LSL     R1, R0, #1          ; R1 = R0 * 2 (each object takes 2 bytes)
    LDR     R2, =OBJ1_POS       ; R2 = base address
    ADD     R2, R2, R1          ; R2 = address of this object's position

    MOV     R4, #0

    ; Store 2-byte XXYY at object position
    STRH    R4, [R2]            ; Store halfword (16-bit) to memory

    POP {R1-R4, LR}
    BX LR
	ENDFUNC


apply_vel_x FUNCTION
    PUSH {R0-R4, LR}          ; Save registers

    ; Load current systime and last systime
    LDR   R0, =AIM_SYSTIME
    LDR   R1, [R0]            ; R1 = AIM_SYSTIME
    LDR   R0, =AIM_LAST_SYSTIME
    LDR   R2, [R0]            ; R2 = AIM_LAST_SYSTIME

    ; Calculate dt = AIM_SYSTIME - AIM_LAST_SYSTIME
    SUB   R3, R1, R2          ; R3 = dt

    ; Load AIM velocity and AIM_POS_DELTA_X
    LDR   R0, =AIM_VEL
    LDRH  R1, [R0]            ; R1 = AIM_VEL (XXYY)
    LDR   R0, =AIM_POS_DELTA_X
    LDRH  R2, [R0]            ; R2 = AIM_POS_DELTA_X

    ; Extract x velocity (upper byte of AIM_VEL)
    LSR   R1, R1, #8          ; R1 = x velocity (XX)
	SXTB	R1,R1

    CMP R1, #0               ; Check if velocity is positive or negative
    BGE positive_velocity    ; If positive, branch to positive_velocity

negative_velocity
    ; Handle negative velocity
    MVN R1, R1               ; Take two's complement of velocity
    ADD R1, R1, #1
    MUL R1, R3               ; R1 = (-x velocity) * dt
    PUSH {R0-R2, LR}
    MOV R0, R1
    MOV R1, #1000
    BL DIVIDE                ; R3 = Integer Part, R4 = Remainder [0, 1000]
    POP {R0-R2, LR}

    SUB R2, R2, R3           ; Subtract Integer part
	MVN R4, R4
    ADD R4, R4, #1
    BL ADD_DECIMAL_TO_WHOLE_X
    B done_velocity

positive_velocity
    ; Handle positive velocity
    MUL R1, R3               ; R1 = x velocity * dt
    PUSH {R0-R2, LR}
    MOV R0, R1
    MOV R1, #1000
    BL DIVIDE                ; R3 = Integer Part, R4 = Remainder [0, 1000]
    POP {R0-R2, LR}

    ADD R2, R2, R3           ; Add Integer part
    BL ADD_DECIMAL_TO_WHOLE_X

done_velocity

    ; Load AIM_POS and AIM_POS_DELTA_X
    LDR   R0, =AIM_POS
    LDR   R1, [R0]            ; R1 = AIM_POS (XXXXYYYY)
    LDR   R0, =AIM_POS_DELTA_X
    LDRH  R2, [R0]            ; R2 = AIM_POS_DELTA_X

    ; Add AIM_POS_DELTA_X to AIM_POS (x component only)
    LSR   R1, R1, #16         ; Extract x component of AIM_POS
	SXTH	R2, R2
    CMP   R2, #0              ; Check if AIM_POS_DELTA_X is negative
    BGE   add_delta           ; If positive or zero, branch to add_delta

    ; Handle negative AIM_POS_DELTA_X
    MVN   R2, R2              ; Take two's complement of AIM_POS_DELTA_X
    ADD   R2, R2, #1
    SUB   R1, R1, R2          ; Subtract AIM_POS_DELTA_X
    B     done_delta          ; Skip adding delta

add_delta
    ADD   R1, R1, R2          ; Add AIM_POS_DELTA_X

done_delta
    LSL   R1, R1, #16         ; Shift back to upper 16 bits

    ; Combine updated x component with original y component
    LDR   R0, =AIM_POS
    LDR   R2, [R0]
    UXTH  R2, R2             ; Clear upper 16 bits
    ORR   R1, R1, R2         ; Combine updated x (R1) with original y

    ; Clamp x to 0 - Width
    LSR   R3, R1, #16        ; Extract x component
    SXTH  R3, R3
    CMP   R3, #0
    BGT   check_upper_bound
    MOV   R3, #0             ; Clamp to 0 if x < 0
    B     clamp_done

check_upper_bound
    LDR   R4, =Width
    CMP   R3, R4
    BLE   clamp_done
    MOV   R3, R4             ; Clamp to Width if x > Width

clamp_done
    LSL   R3, R3, #16        ; Shift clamped x back to upper 16 bits
    UXTH  R2, R1             ; Extract y component
    ORR   R1, R3, R2         ; Combine clamped x with original y
    STR   R1, [R0]           ; Store updated AIM_POS

    ; Clear AIM_POS_DELTA_X
    LDR   R0, =AIM_POS_DELTA_X
    MOV   R2, #0
    STRH  R2, [R0]


apply_vel_x_done
    POP {R0-R4, LR}           ; Restore registers
    BX LR
    ENDFUNC

; R2 = Integer Part of AIM_POS_DELTA
; R4 = Decimal part from v * dt
ADD_DECIMAL_TO_WHOLE_X FUNCTION
    PUSH {R0-R5, LR}
    LDR   R0, =AIM_POS_DELTA_X_DECIMAL
    LDRH  R5, [R0]           ; R5 = AIM_POS_DELTA_X_DECIMAL
    ADD R5, R5, R4
    SXTH R5, R5
    CMP R5, #0               ; Check if AIM_POS_DELTA_X_DECIMAL is negative
    BGE decimal_positive     ; If positive or zero, branch to decimal_positive

    ; Handle negative AIM_POS_DELTA_X_DECIMAL
    MVN R5, R5               ; Take two's complement of AIM_POS_DELTA_X_DECIMAL
    ADD R5, R5, #1
    PUSH {R0-R3, LR}
    MOV R0, R5
    MOV R1, #1000
    BL DIVIDE
    SUB R2, R2, R3           ; Subtract from integer part
    LDR   R0, =AIM_POS_DELTA_X
    STRH R2, [R0]
    LDR R0, =AIM_POS_DELTA_X_DECIMAL
	MVN R4, R4
    ADD R4, R4, #1
    STRH R4, [R0]
    POP {R0-R3, LR}
    B done_decimal
decimal_positive 
    PUSH {R0-R3, LR}
    MOV R0, R5
    MOV R1, #1000
    BL DIVIDE
    ADD R2, R2, R3           ; Subtract from integer part
    LDR   R0, =AIM_POS_DELTA_X
    STRH R2, [R0]
    LDR R0, =AIM_POS_DELTA_X_DECIMAL
    STRH R4, [R0]
    POP {R0-R3, LR}
done_decimal
    POP {R0- R5, LR} 
    BX LR
    ENDFUNC

apply_vel_y FUNCTION
    PUSH {R0-R4, LR}          ; Save registers

    ; Load current systime and last systime
    LDR   R0, =AIM_SYSTIME
    LDR   R1, [R0]            ; R1 = AIM_SYSTIME
    LDR   R0, =AIM_LAST_SYSTIME
    LDR   R2, [R0]            ; R2 = AIM_LAST_SYSTIME

    ; Calculate dt = AIM_SYSTIME - AIM_LAST_SYSTIME
    SUB   R3, R1, R2          ; R3 = dt

    ; Update AIM_LAST_SYSTIME
    STR   R1, [R0]

    ; Load AIM velocity and AIM_POS_DELTA_Y
    LDR   R0, =AIM_VEL
    LDRH  R1, [R0]            ; R1 = AIM_VEL (XXYY)
    LDR   R0, =AIM_POS_DELTA_Y
    LDRH  R2, [R0]            ; R2 = AIM_POS_DELTA_Y

    ; Extract y velocity (lower byte of AIM_VEL)
    SXTB  R1, R1

    CMP R1, #0               ; Check if velocity is positive or negative
    BGE positive_velocity_y  ; If positive, branch to positive_velocity_y

negative_velocity_y
    ; Handle negative velocity
    MVN R1, R1               ; Take two's complement of velocity
    ADD R1, R1, #1
    MUL R1, R3               ; R1 = (-y velocity) * dt
    PUSH {R0-R2, LR}
    MOV R0, R1
    MOV R1, #1000
    BL DIVIDE                ; R3 = Integer Part, R4 = Remainder [0, 1000]
    POP {R0-R2, LR}

    SUB R2, R2, R3           ; Subtract Integer part
    MVN R4, R4
    ADD R4, R4, #1
    BL ADD_DECIMAL_TO_WHOLE_Y
    B done_velocity_y

positive_velocity_y
    ; Handle positive velocity
    MUL R1, R3               ; R1 = y velocity * dt
    PUSH {R0-R2, LR}
    MOV R0, R1
    MOV R1, #1000
    BL DIVIDE                ; R3 = Integer Part, R4 = Remainder [0, 1000]
    POP {R0-R2, LR}

    ADD R2, R2, R3           ; Add Integer part
    BL ADD_DECIMAL_TO_WHOLE_Y

done_velocity_y

    ; Load AIM_POS and AIM_POS_DELTA_Y
    LDR   R0, =AIM_POS
    LDR   R1, [R0]            ; R1 = AIM_POS (XXXXYYYY)
    LDR   R0, =AIM_POS_DELTA_Y
    LDRH  R2, [R0]            ; R2 = AIM_POS_DELTA_Y

    ; Add AIM_POS_DELTA_Y to AIM_POS (y component only)
    UXTH  R1, R1              ; Extract y component of AIM_POS
    SXTH  R2, R2
    CMP   R2, #0              ; Check if AIM_POS_DELTA_Y is negative
    BGE   add_delta_y         ; If positive or zero, branch to add_delta_y

    ; Handle negative AIM_POS_DELTA_Y
    MVN   R2, R2              ; Take two's complement of AIM_POS_DELTA_Y
    ADD   R2, R2, #1
    SUB   R1, R1, R2          ; Subtract AIM_POS_DELTA_Y
    B     done_delta_y        ; Skip adding delta

add_delta_y
    ADD   R1, R1, R2          ; Add AIM_POS_DELTA_Y

done_delta_y
    ; Combine updated y component with original x component
    LDR   R0, =AIM_POS
    LDR   R2, [R0]

    ; Clamp y to 0 - Height
    CMP   R1, #0
    BGE   check_upper_bound_y
    MOV   R1, #0             ; Clamp to 0 if y < 0
    B     clamp_done_y

check_upper_bound_y
    LDR   R3, =Height
    CMP   R1, R3
    BLE   clamp_done_y
    MOV   R1, R3             ; Clamp to Height if y > Height

clamp_done_y
    
    LSR  R2, R2, #16             ; Extract x component
    LSL  R2, R2, #16             ; Extract x component
    ORR   R1, R1, R2         ; Combine clamped y with original x
    STR   R1, [R0]           ; Store updated AIM_POS

    ; Clear AIM_POS_DELTA_Y
    LDR   R0, =AIM_POS_DELTA_Y
    MOV   R2, #0
    STRH  R2, [R0]

apply_vel_y_done
    POP {R0-R4, LR}           ; Restore registers
    BX LR
    ENDFUNC

; R2 = Integer Part of accumulation
; R4 = Decimal part from v * dt
ADD_DECIMAL_TO_WHOLE_Y FUNCTION
    PUSH {R0-R5, LR}
    LDR   R0, =AIM_POS_DELTA_Y_DECIMAL
    LDRH  R5, [R0]           ; R5 = AIM_POS_DELTA_Y_DECIMAL
    ADD R5, R5, R4
    SXTH R5, R5
    CMP R5, #0               ; Check if AIM_POS_DELTA_Y_DECIMAL is negative
    BGE decimal_positive_y   ; If positive or zero, branch to decimal_positive_y

    ; Handle negative AIM_POS_DELTA_Y_DECIMAL
    MVN R5, R5               ; Take two's complement of AIM_POS_DELTA_Y_DECIMAL
    ADD R5, R5, #1
    PUSH {R0-R3, LR}
    MOV R0, R5
    MOV R1, #1000
    BL DIVIDE
    SUB R2, R2, R3           ; Subtract from integer part
    LDR   R0, =AIM_POS_DELTA_Y
    STRH R2, [R0]
    LDR R0, =AIM_POS_DELTA_Y_DECIMAL
    MVN R4, R4
    ADD R4, R4, #1
    STRH R4, [R0]
    POP {R0-R3, LR}
    B done_decimal_y
decimal_positive_y 
    PUSH {R0-R3, LR}
    MOV R0, R5
    MOV R1, #1000
    BL DIVIDE
    ADD R2, R2, R3           ; Add to integer part
    LDR   R0, =AIM_POS_DELTA_Y
    STRH R2, [R0]
    LDR R0, =AIM_POS_DELTA_Y_DECIMAL
    STRH R4, [R0]
    POP {R0-R3, LR}
done_decimal_y
    POP {R0-R5, LR} 
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
    LDR     R4, =AIM_PRNG_STATE     ; R4 = address of prng_state
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


