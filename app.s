	AREA    DATA, DATA, READWRITE
sys_time            DCD     0       ; 32-bit variable for system time (ms)
;####################################################INTERRUPT VARAIBLES#######################################################
btn1_last_handled_time   DCD     0       ; 32-bit variable for last handled time (ms)
btn2_last_handled_time   DCD     0       ; 32-bit variable for last handled time (ms)
btn3_last_handled_time   DCD     0       ; 32-bit variable for last handled time (ms)
btn4_last_handled_time   DCD     0       ; 32-bit variable for last handled time (ms)
;####################################################END INTERRUPT VARAIBLES#######################################################
;####################################################Menu VARAIBLES#######################################################
HOVERED_GAME DCD 0 ; Variable to store the currently hovered game
HOVERED_GAME_X DCD 0 ; X coordinate of the hovered game border
HOVERED_GAME_Y DCD 0 ; Y coordinate of the hovered game border
;###################################################END Menu VARAIBLES#######################################################
;####################################################PONG VARAIBLES#######################################################

;####################################################END PONG VARAIBLES#######################################################
    ALIGN
	;--===============================================================--
	;|--|  STM32F103C8T6  |--|  ARM Cortex-M3  |--|  ARM Assembly   |--|
    ;|--| =================Important Definitions:================== |--|
    ;|--| ============ Delay in ms, use R5 as counter ============= |--|
    ;|--| ================== Active Game => R11 =================== |--|
    ;|--| =============== R11 <== 0 == Main Menu ================== |--|
    ;|--| =============== R11 <== 1 == Game 1... ================== |--|
    ;|--| ================== Game Over => R11 ===================== |--|
    ;--===============================================================--
    INCLUDE hal.s
    IMPORT gamelogo
	; Characters import
    IMPORT char_48  ; 0
    IMPORT char_49  ; 1
    IMPORT char_50  ; 2
    IMPORT char_51  ; 3
    IMPORT char_52  ; 4
    IMPORT char_53  ; 5
    IMPORT char_54  ; 6
    IMPORT char_55  ; 7
    IMPORT char_56  ; 8
    IMPORT char_57  ; 9
    ; Alphabet (A-Z)
    IMPORT char_65  ; A
    IMPORT char_66  ; B
    IMPORT char_67  ; C
    IMPORT char_68  ; D
    IMPORT char_69  ; E
    IMPORT char_70  ; F
    IMPORT char_71  ; G
    IMPORT char_72  ; H
    IMPORT char_73  ; I
    IMPORT char_74  ; J
    IMPORT char_75  ; K
    IMPORT char_76  ; L
    IMPORT char_77  ; M
    IMPORT char_78  ; N
    IMPORT char_79  ; O
    IMPORT char_80  ; P
    IMPORT char_81  ; Q
    IMPORT char_82  ; R
    IMPORT char_83  ; S
    IMPORT char_84  ; T
    IMPORT char_85  ; U
    IMPORT char_86  ; V
    IMPORT char_87  ; W
    IMPORT char_88  ; X
    IMPORT char_89  ; Y
    IMPORT char_90  ; Z
	EXPORT __main
	EXPORT EXTI0_IRQHandler
	EXPORT EXTI1_IRQHandler
	EXPORT EXTI2_IRQHandler
	EXPORT EXTI3_IRQHandler
	EXPORT SysTick_Handler
	AREA MYCODE, CODE, READONLY

	ENTRY

__main FUNCTION

	BL _init
    BL TFT_INIT ; Call TFT_INIT to initialize the TFT LCD
    LDR R0, =0x0000 ; Load the color value
    BL FILL_SCREEN ; Call FILL_SCREEN to fill the screen with the color
	BL RESET_MENU
	BL DRAW_MENU
	MOV R11, #0
MAIN_LOOP
    CMP R11, #0 ; Check if R11 is 0 (Main Menu)
    BEQ END_MAINLOOP

    CMP R11, #1 ; Check if R11 is 1
    BEQ DRAW_GAME1_LBL ; If R11 is 1, branch to DRAW_GAME1
	B END_MAINLOOP
DRAW_GAME1_LBL
    BL DRAW_GAME1
    B END_MAINLOOP
END_MAINLOOP
	B MAIN_LOOP

_init
    push {r0-r12, lr}  ; Save registers
    ;#################################Select system Clock Source#######################################
    ; Enable HSI clock
    ldr r0, =RCC_BASE
    ldr r1 , =RCC_CR_OFFSET
    add r0, r0, r1  ; Read RCC_CR
	ldr R1, [R0]
    orr r1, r1, #0x01  ; Set HSION bit to enable HSI clock
    str r1, [r0]  ; Write back to RCC_CR
WAIT_HSI ldr r1, [r0]    ; Read RCC_CR again
    AND r1, #0x02  ; Check if HSIRDY bit is set
    CMP r1, #0x02  ; Compare with 0x02
    BNE WAIT_HSI  ; Wait until HSI is ready
    ; Select HSI as PLL source Set PLL multiplication factor to 8
    ldr r0, =RCC_BASE
	ldr r1, =RCC_CFGR_OFFSET
    add r0, r0 , r1
    ldr r1, [r0]  ; Read RCC_CFGR
    and r1, r1, #0xFFFEFFFF  ; Select HSI as PLL source (clear PLLSRC bit)
    orr r1, r1, #0x380000  ; Set PLLMUL[3:0] to 0x0F (16x)
    str r1, [r0]  ; Write back to RCC_CFGR
    ; Enable PLL
    ldr r0, =RCC_BASE
    ldr r1 , =RCC_CR_OFFSET
    add r0, r0, r1  ; Read RCC_CR
    ldr r1, [r0]  ; Read RCC_CR again
    orr r1, r1, #0x1000000 ; ; Set PLLON bit to enable PLL
    str r1, [r0]  ; Write back to RCC_CR
WAIT_PLL ldr r1, [r0]    ; Read RCC_CR again
    AND r1, #0x2000000  ; Check if PLLRDY bit is set
    CMP r1, #0x2000000
    BNE WAIT_PLL  ; Wait until PLL is ready
    ldr r0, =RCC_BASE
    ldr r1, =RCC_CFGR_OFFSET
    add r0, r0 , r1
    ldr r1, [r0]  ; Read RCC_CFGR
    orr r1, r1, #0x02  ; Set SW[1:0] to select PLL as system clock
    str r1, [r0]  ; Write back to RCC_CFGR
WAIT_SWS ldr r1, [r0]    ; Read RCC_CFGR again
    AND r1, #0x08  ; Check if SWS[1:0] is set to 0x02 (PLL)
    CMP r1, #0x08  ; Compare with 0x0C
    BNE WAIT_SWS  ; Wait until PLL is selected as system clock
    ;##################################End Select System Clock Source#######################################
	;##################################Start Systick Enable#######################################
	ldr r0, =SysTick_BASE  ; Load SysTick base address
    ldr r1, =SysTick_CTRL_OFFSET  ; Load SysTick_CTRL offset
    add r0, r0, r1  ; Calculate SysTick_CTRL address
    ldr r1, [r0]  ; Read SysTick_CTRL
    orr r1, r1, #0x07  ; Enable SysTick with HSI/8 clock and enable interrupt
    str r1, [r0]  ; Write back to SysTick_CTRL
    ldr r0, =SysTick_BASE  ; Load SysTick base address
    ldr r1, =SysTick_RELOAD_VALUE_OFFSET  ; Load SysTick_RELOAD_VALUE offset
    add r0, r0, r1 ; Calculate SysTick_RELOAD_VALUE address
    ldr r1, =0x0F9FF ; Set reload value to 63999 (tick everey 1 ms)
    str r1, [r0]  ; Write to SysTick_RELOAD_VALUE
    ldr r0, =SysTick_BASE  ; Load SysTick base address
    ldr r1, =SysTick_CURRENT_VALUE_OFFSET  ; Load SysTick_CURRENT_VALUE offset
    add r0, r0, r1 ; Calculate SysTick_CURRENT_VALUE address
    ldr r1, =0x00 ; Set current value to 0
    str r1, [r0]  ; Write to SysTick_CURRENT_VALUE
	;##################################End Systick Enable#######################################
    ;#################################Enable GPIOA, GPIOB & AFIO Clocks#######################################
    ldr r0, =RCC_BASE
    ldr r1, =RCC_APB2ENR_OFFSET
    add r0, r0, r1
    ldr r1, [r0]  ; Read RCC_APB2ENR 
    orr r1, r1, #0x0D  ; Enable GPIOA, GPIOB & AFIO clock
    str r1, [r0]  ; Write back to RCC_APB2ENR
    ;##################################End Enable GPIOA, GPIOB & AFIO Clocks#######################################
    ;#################################Configure GPIOA and GPIOB#######################################
    ; Configure GPIOA (PA0 PA1 PA2 PA3 PA5) as input, for
    ; Lower 8 pins are defined here and will be used as CTRL pins for the LCD
    ldr r0, =GPIOA_BASE
    ldr r1, =GPIOx_CRL_OFFSET
    add r0, r0, r1
    LDR r1, =0x111111  ; Set mode to input mode / pull-up - pull-down for PA0 - PA3, PA5
    str r1, [r0]  ; Write to GPIOA_CRL
    ; Define (PA8 - PA12) as output for control port
    ldr r0, =GPIOA_BASE
    ldr r1, =GPIOx_CRH_OFFSET
    add r0, r0, r1
    LDR r1, =0x00033333 ; Set mode to output 50MHz, push-pull for PA8 - PA12
    str r1, [r0]  ; Write to GPIOA_CRH
    ; Configure the GPIOA input ports with pull-up resistors
    ldr r0, =GPIOA_BASE
    ldr r1, =GPIOx_BSRR_OFFSET
    add r0, r0, r1
    MOV r1, #0x2F ; Pull up the pins PA0 - PA3, PA5
    str r1, [r0]  ; Write to GPIOA_BSRR
    ; Configure GPIOB high as output for data port
    ldr r0, =GPIOB_BASE
    ldr r1, =GPIOx_CRH_OFFSET
    add r0, r0, r1
    MOV r1, #0x33333333  ; Set mode to output 50MHZ, push-pull for PB8-PB15
    str r1, [r0]  ; Write to GPIOB_CRH
    ;##################################End Configure GPIOA and GPIOB#######################################
    ;#################################Configure NVIC ########################################
    ldr r0, =NVIC_BASE  ; Load NVIC base address
    ldr r1, =NVIC_AIRCR_OFFSET  ; Load NVIC_AIRCR offset
    add r0, r0, r1  ; Calculate NVIC_AIRCR address
    ldr r1, [r0]  ; Read NVIC_AIRCR
    orr r1, r1, #0x0200 ; Set the priority group to 2 bits for pre-emption and 2 bits for sub-priority
    str r1, [r0]  ; Write back to NVIC_AIRCR
    ;#################################End Configure NVIC ########################################
    ;#################################Enable Interrupts for Arcade Buttons#######################################
    ; Map EXTI0 to EXTI3 to GPIOA
    ldr r0, =AFIO_BASE
    ldr r1, =AFIO_EXTICR1_OFFSET
    add r0, r0, r1
    ldr r1, [r0]  ; Set EXTI0 to EXTI3 to GPIOB
	mov r2, #0xFFFF
    bic r1, r1, r2 ; Clear Lower 16 bits
    str r1, [r0]  ; Write to AFIO_EXTICR1
    ; Unmask EXTI0 to EXTI3 lines' interrupts
    ldr r0, =EXTI_BASE
    ldr r1, =EXTI_IMR_OFFSET
    add r0, r0, r1
    ldr r1, [r0]  ; Read EXTI_IMR
    orr r1, r1, #0x0F ; Unmask EXTI0 to EXTI3
    str r1, [r0]  ; Write to EXTI_IMR
    ; Enable interrupt on falling edge for EXTI0 to EXTI3 lines, since arcade buttons' pins are pulled-up
    ldr r0, =EXTI_BASE
    ldr r1, =EXTI_FTSR_OFFSET
    add r0, r0, r1
    ldr r1, [r0] ; Read EXTI_FTSR
    orr r1, r1, #0x0F ; Enable falling edge trigger for EXTI0 to EXTI3
    str r1, [r0]  ; Write to EXTI_FTSR
    ; Enable NVIC interrupts for EXTI0 to EXTI3 lines
    ldr r0, =NVIC_BASE  ; Load NVIC base address
    ldr r1, =NVIC_ISER_ONE_OFFSET  ; Load NVIC_ISER0 offset
    add r0, r0, r1  ; Calculate NVIC_ISER0 address
    ldr r1, [r0]  ; Read NVIC_ISER0
    orr r1, r1, #0x03C0  ; Enable interrupts for EXTI0 to EXTI3, ISER0 bits 6 - 9
    str r1, [r0]  ; Write back to NVIC_ISER0
    ; Set the preemption priority and subpriority for EXTI0 to EXTI3 interrupts
    ldr r0, =NVIC_BASE  ; Load NVIC base address
    ldr r1, =NVIC_IPR_TWO_OFFSET  ;Load NVIC_IPR2 offset
    add r0, r0, r1  ;Calculate NVIC_IPR2 address
    ldr r1, [r0]  ;Read NVIC_IPR2
	mov r2, #0x10000
	LSL r2, r2, #16
    orr r1, r1, r2 ;Set the priority for EXTI1 & EXTI0 (Premrption to 0, sub priority of EXTI1 is 1 and EXTI0 is 0, lower priority number means higher priority)
    str r1, [r0]  ;Write back to NVIC_IPR2
    ldr r0, =NVIC_BASE  ;Load NVIC base address
    ldr r1, =NVIC_IPR_THREE_OFFSET  ;Load NVIC_IPR2 offset
    add r0, r0, r1  ;Calculate NVIC_IPR3 address
    ldr r1, [r0]  ;Read NVIC_IPR3
    MOV r2, #0x3020
    orr r1, r1, r2 ;Set the priority for EXTI3 & EXTI2 (Premrption to 0, sub priority of EXTI3 is 3 and EXTI2 is 2)
    str r1, [r0]  ;Write back to NVIC_IPR3
    ;#################################End Enable Interrupts for Arcade Buttons#######################################
	pop {r0-r12, lr}
	bx lr
	LTORG
;####################################################PONG Start#######################################################
pong
    push {r0-r12, lr}
    
    pop {r0-r12, lr}
    bx lr

;#####################################################PONG End#######################################################

	ENDFUNC
	
; #######################################################START MISC FUNCTIONS#######################################################
DELAY_MS PROC
	PUSH {R0-R3, LR}          ; Save registers and link register
	LDR R1, =sys_time         ; Load address of sys_time
	LDR R2, [R1]              ; R2 = current sys_time
	ADD R3, R2, R5            ; R3 = sys_time + delay_ms (target time)
DELAY_MS_LOOP
	LDR R2, [R1]              ; R2 = current sys_time
	CMP R2, R3                ; Compare current sys_time with target time
	BLT DELAY_MS_LOOP         ; Branch if less than (not enough time has passed)
	POP {R0-R3, LR}           ; Restore registers and return
	BX LR
	ENDP
    LTORG
;#######################################################END MISC FUNCTIONS#######################################################
;#######################################################START Drawing Functions#####################################################
; DRAW_PIXEL FUNCTION
;     PUSH {R0-R4, LR}

;     POP {R0-R4, LR}
    ; BX LR
;     ENDFUNC
;@@@@@@@@@@@@@@@DRAW RECT
; All landscape
; R0 Has Start X
; R1 Has Start Y
; R3 Has Width
; R4 Has Height
; R5 Has Color
DRAW_RECT FUNCTION
    PUSH {LR}
    MOV R2, #0x2A ; Set Column Address command
    BL TFT_COMMAND_WRITE
    LSR R2, R0, #8 ; Get high byte of Start X coordinate
    BL TFT_DATA_WRITE ; Send high byte of Start X coordinate
    AND R2, R0, #0xFF ; Get low byte of Start X coordinate
    BL TFT_DATA_WRITE ; Send low byte of Start X coordinate
    ADD R0, R0, R3 ; Add Width to X coordinate for end X
    SUBS R0, R0, #1 ; Subtract 1 to get the correct end X coordinate
    LSR R2, R0, #8 ; Get high byte of End X coordinate
    BL TFT_DATA_WRITE ; Send high byte of End X coordinate
    AND R2, R0, #0xFF ; Get low byte of End X coordinate
    BL TFT_DATA_WRITE ; Send low byte of End X coordinate

    MOV R2, #0x2B ; Set Page Address command
    BL TFT_COMMAND_WRITE
    LSR R2, R1, #8 ; Get high byte of Start Y coordinate
    BL TFT_DATA_WRITE ; Send high byte of Start Y coordinate
    AND R2, R1, #0xFF ; Get low byte of Start Y coordinate
    BL TFT_DATA_WRITE ; Send low byte of Start Y coordinate
    ADD R1, R1, R4 ; Add Height to Y coordinate for end Y
    SUBS R0, R0, #1 ; Subtract 1 to get the correct end X coordinate
    LSR R2, R1, #8 ; Get high byte of End Y coordinate
    BL TFT_DATA_WRITE ; Send high byte of End Y coordinate
    AND R2, R1, #0xFF ; Get low byte of End Y coordinate
    BL TFT_DATA_WRITE ; Send low byte of End Y coordinate
    MOV R2, #0x2C ; Memory Write command
    BL TFT_COMMAND_WRITE
    MUL R3, R3, R4 ; Calculate total pixels (Width * Height)
RECT_DRAW_LOOP
    LSR R2, R5, #8 ; Extract high byte of pixel color
    BL TFT_DATA_WRITE ; Send high byte of pixel color
    AND R2, R5, #0xFF ; Extract low byte of pixel color
    BL TFT_DATA_WRITE ; Send low byte of pixel color
    SUBS R3, R3, #1 ; Decrement pixel count
    BNE RECT_DRAW_LOOP ; Loop until all pixels are drawn
	POP {LR}
	BX LR
    ENDFUNC
;@@@@@@@@@@@@@@@DRAW IMAGE
; All landscape
; R0 Has Start X
; R1 Has Start Y
; R3 Has image address, first 8 bytes of an image contain width and height
DRAW_IMAGE FUNCTION
    PUSH {R0-R7, LR}
    LDR R4, [R3], #4 ; Load width from image address
    LDR R5, [R3], #4 ; Load height from image address

    MOV R2, #0x2A ; Set Column Address command
    BL TFT_COMMAND_WRITE
    LSR R2, R0, #8 ; Get high byte of Start X coordinate
    BL TFT_DATA_WRITE ; Send high byte of Start X coordinate
    AND R2, R0, #0xFF ; Get low byte of Start X coordinate
    BL TFT_DATA_WRITE ; Send low byte of Start X coordinate
    ADD R6, R4, R0
    SUB R6, R6, #1 ; Calculate End X coordinate (Start X + Width - 1)
    LSR R2, R6, #8 ; Get high byte of End X coordinate
    BL TFT_DATA_WRITE ; Send high byte of End X coordinate
    AND R2, R6, #0xFF ; Get low byte of End X coordinate
    BL TFT_DATA_WRITE ; Send low byte of End X coordinate

    MOV R2, #0x2B ; Set Page Address command
    BL TFT_COMMAND_WRITE
    LSR R2, R1, #8 ; Get high byte of Start Y coordinate
    BL TFT_DATA_WRITE ; Send high byte of Start Y coordinate
    AND R2, R1, #0xFF ; Get low byte of Start Y coordinate
    BL TFT_DATA_WRITE ; Send low byte of Start Y coordinate
    ADD R6, R5, R1
    SUB R6, R6, #1 ; Calculate End Y coordinate (Start Y + Height - 1)
    LSR R2, R6, #8 ; Get high byte of End Y coordinate
    BL TFT_DATA_WRITE ; Send high byte of End Y coordinate
    AND R2, R6, #0xFF ; Get low byte of End Y coordinate
    BL TFT_DATA_WRITE ; Send low byte of End Y coordinate

    MOV R2, #0x2C ; Memory Write command
    BL TFT_COMMAND_WRITE

    MUL R6, R4, R5 ; Calculate total pixels (Width * Height)

IMAGE_DRAW_LOOP
    LDRH R0, [R3], #2 ; Load pixel color from image address
    MOV R2, R0, LSR #8 ; Extract high byte
    BL TFT_DATA_WRITE ; Send high byte of pixel color
    AND R2, R0, #0xFF ; Extract low byte
    BL TFT_DATA_WRITE ; Send low byte of pixel color
    SUBS R6, R6, #1 ; Decrement pixel count
    BNE IMAGE_DRAW_LOOP ; Loop until all pixels are drawn

    POP {R0-R7, LR}
    BX LR
    ENDFUNC
FILL_SCREEN FUNCTION
    PUSH {R1-R12, LR}
    ; Extract high and low bytes from R0 (COLOR)
    MOV R1, R0
    AND R1, R0, #0xFF ; Get the low byte (lower 8 bits)
    LSR R0, R0, #8   ; Get the high byte (upper 8 bits)

    ; Set Column Address
    MOV R2, #0x2A
    BL TFT_COMMAND_WRITE
    MOV R2, #0x00
    BL TFT_DATA_WRITE
    MOV R2, #0x00
    BL TFT_DATA_WRITE
    MOV R2, #0x01
    BL TFT_DATA_WRITE
    MOV R2, #0xDF  ; Max column (319)
    BL TFT_DATA_WRITE

    ; Set Page Address
    MOV R2, #0x2B
    BL TFT_COMMAND_WRITE
    MOV R2, #0x00
    BL TFT_DATA_WRITE
    MOV R2, #0x00
    BL TFT_DATA_WRITE
    MOV R2, #0x01
    BL TFT_DATA_WRITE
    MOV R2, #0x3F  ; Max row (479)
    BL TFT_DATA_WRITE

    ; Memory Write
    MOV R2, #0x2C
    BL TFT_COMMAND_WRITE

    ; Fill screen with color
    MOV R3, #153600  ; Total pixels (320x240 since 16-bit per pixel)
TFT_Loop
    MOV R2, R0      ; Send high byte
    BL TFT_DATA_WRITE
    MOV R2, R1      ; Send low byte
    BL TFT_DATA_WRITE

    SUBS R3, R3, #1
    BNE TFT_Loop

    POP {R1-R12, LR}
    BX LR
    ENDFUNC
;#######################################################END Drawing Functions#######################################################
;#######################################################START Menu Functions#######################################################
;#### Function to reset the menu =>> to be called before switching the current game variable
RESET_MENU FUNCTION
    PUSH {R0-R1, LR}
    LDR R0, =HOVERED_GAME
    MOV R1, #1
    STR R1, [R0] ; Reset hovered game to 0
    LDR R0, =HOVERED_GAME_X
    MOV R1, #37
    STR R1, [R0] ; Reset X coordinate of hovered game
    LDR R0, =HOVERED_GAME_Y
    MOV R1, #52
    STR R1, [R0] ; Reset Y coordinate of hovered game

    POP {R0-R1, LR}
    BX LR
    ENDFUNC
DRAW_MENU FUNCTION
    PUSH {R0-R4, LR}
    ; Draw the hover rectangle around the hovered game
    LDR R0, =HOVERED_GAME_X ; Load X coordinate of hovered game
    LDR R0, [R0]
    LDR R1, =HOVERED_GAME_Y
    LDR R1, [R1]
    MOV R3, #116
    MOV R4, #116
    MOV R5, #0x265B
    BL DRAW_RECT
    ;Draw the game logo
    LDR R3, =gamelogo
    MOV R0, #45
    MOV R1, #60
    BL DRAW_IMAGE ; Call DRAW_IMAGE to draw the image
    LDR R3, =gamelogo
    MOV R0, #190
    MOV R1, #60
    BL DRAW_IMAGE ; Call DRAW_IMAGE to draw the image
    LDR R3, =gamelogo
    MOV R0, #335
    MOV R1, #60
    BL DRAW_IMAGE ; Call DRAW_IMAGE to draw the image
    LDR R3, =gamelogo
    MOV R0, #45
    MOV R1, #200
    BL DRAW_IMAGE ; Call DRAW_IMAGE to draw the image
    LDR R3, =gamelogo
    MOV R0, #190
    MOV R1, #200
    BL DRAW_IMAGE ; Call DRAW_IMAGE to draw the image
    LDR R3, =gamelogo
    MOV R0, #335
    MOV R1, #200
    BL DRAW_IMAGE ; Call DRAW_IMAGE to draw the image
    POP {R0-R4, LR}
    BX LR
    ENDFUNC
;#######################################################END Menu Functions#######################################################
;#######################################################Start Game Functions#######################################################
DRAW_GAME1 FUNCTION
	PUSH {R0-R3, LR}
    LDR R3, =char_80
    MOV R0, #200
    MOV R1, #152
    BL DRAW_IMAGE ; Call DRAW_IMAGE to draw the image
    ADD R0, R0, #20
    MOV R1, #152
	LDR R3, =char_79
    BL DRAW_IMAGE ; Call DRAW_IMAGE to draw the image
    ADD R0, R0, #21
	MOV R1, #152
    LDR R3, =char_78
    BL DRAW_IMAGE ; Call DRAW_IMAGE to draw the image
    ADD R0, R0, #20
	MOV R1, #152
    LDR R3, =char_71
    BL DRAW_IMAGE ; Call DRAW_IMAGE to draw the image
    POP {R0-R3, LR}
	BX LR
	ENDFUNC
	LTORG
;#######################################################END Game Functions#######################################################
;#######################################################START TFT FUNCTIONS#######################################################
TFT_COMMAND_WRITE PROC
    PUSH {R0-R4, LR}

    ; Set CS low
    LDR R0, =GPIOA_BASE
    LDR R1, =GPIOx_ODR_OFFSET
    ADD R0, R0, R1
    LDR R1, [R0]
    ORR R1, R1, #0x1F00
    BIC R1, R1, #TFT_CS
    STR R1, [R0]

    ; Set DC (RS) low for command
    BIC R1, R1, #TFT_RS
    STR R1, [R0]

    ; Set RD high (not used in write operation)
    ORR R1, R1, #TFT_RD
    STR R1, [R0]

    ; Send command (R2 contains command)
    LDR R3, =GPIOB_BASE
    LDR R4, =GPIOx_ODR_OFFSET
    ADD R3, R3, R4
    AND R2, R2, #0xFF
    LSL R2, R2, #8   ; Shift command to the upper byte
    STR R2, [R3]

    ; Generate WR pulse (low > high)
    BIC R1, R1, #TFT_WR
    STR R1, [R0]
    ORR R1, R1, #TFT_WR
    STR R1, [R0]

    ; Set CS high
    ORR R1, R1, #TFT_CS
    STR R1, [R0]

    POP {R0-R4, LR}
    BX LR
    ENDP

TFT_DATA_WRITE PROC
    PUSH {R0-R4, LR}

    ; Set CS low
    LDR R0, =GPIOA_BASE
    LDR R1, =GPIOx_ODR_OFFSET
    ADD R0, R0, R1
    LDR R1, [R0]
    ORR R1, R1, #0x1F00
    BIC R1, R1, #TFT_CS
    STR R1, [R0]

    ; Set DC (RS) high for data
    ORR R1, R1, #TFT_RS
    STR R1, [R0]

    ; Set RD high (not used in write operation)
    ORR R1, R1, #TFT_RD
    STR R1, [R0]

    ; Send data (R2 contains data)
    LDR R3, =GPIOB_BASE
    LDR R4, =GPIOx_ODR_OFFSET
    ADD R3, R3, R4
    AND R2, R2, #0xFF
    LSL R2, R2, #8   ; Shift data to the upper byte
    STR R2, [R3]

    ; Generate WR pulse (low > high)
    BIC R1, R1, #TFT_WR
    STR R1, [R0]
    ORR R1, R1, #TFT_WR
    STR R1, [R0]

    ; Set CS high
    ORR R1, R1, #TFT_CS
    STR R1, [R0]

    POP {R0-R4, LR}
    BX LR
    ENDP

TFT_INIT FUNCTION
    PUSH {R0-R1, R5, lr}
    LDR R0, =GPIOA_BASE
    LDR R1, =GPIOx_ODR_OFFSET
    ADD R0, R0, R1
    LDR R1, [R0]
    ORR R1, R1, #0x1F00
    ; Reset sequence (high -> low -> high)
    ORR R1, R1, #TFT_RST
    STR R1, [R0]
    MOV R5, #100
    BL DELAY_MS
    BIC R1, R1, #TFT_RST
    STR R1, [R0]
    MOV R5, #100
    BL DELAY_MS
    ORR R1, R1, #TFT_RST
    STR R1, [R0]
    MOV R5, #100
    BL DELAY_MS
    ; Prepare for Write Cycle Sequence
    ; CS high -> Set RD & WR then reset CS
    ORR R1, R1, #TFT_CS
    STR R1, [R0]
    ; SET WR high
    ORR R1, R1, #TFT_WR
    STR R1, [R0]
    ; SET RD high
    ORR R1, R1, #TFT_RD
    STR R1, [R0]
    ; Set CS low
    BIC R1, R1, #TFT_CS
    STR R1, [R0]
    ; ###############################Software INIT commands#######################################
    MOV R2, #0x3A ; Set R2 to 0x3A (TFT LCD pixel format command)
    BL TFT_COMMAND_WRITE ; Call TFT_COMMAND_WRITE to send the command
    MOV R2, #0x55 ; Set R2 to 0x55 (16-bit pixel format)
    BL TFT_DATA_WRITE ; Call TFT_DATA_WRITE to send the data
    MOV R2, #0x11 ; Set R2 to 0x11 (TFT LCD sleep out command)
    BL TFT_COMMAND_WRITE ; Call TFT_COMMAND_WRITE to send the command
    MOV R0, #120 ; Set delay to 120 ms
    BL DELAY_MS ; Call DELAY_MS to wait
    MOV R2, #0x36 ; Set R2 to 0x36 (TFT LCD memory access control command)
    BL TFT_COMMAND_WRITE ; Call TFT_COMMAND_WRITE to send the command
    MOV R2, #0x28 ; Set R2 to 0x28 (RGB color order, Landscape display)
    BL TFT_DATA_WRITE ; Call TFT_DATA_WRITE to send the data

	MOV R2, #0xB1 ;FPS Control
	BL TFT_COMMAND_WRITE
	MOV R2, #0xA0
	BL TFT_DATA_WRITE
	MOV R2, #0x11
	BL TFT_DATA_WRITE
	
    MOV R2, #0x29 ; LCD display on command
    BL TFT_COMMAND_WRITE ; Call TFT_COMMAND_WRITE to send the command
    BL DELAY_MS ; Call DELAY_MS to wait

    POP {R0-R1, R5, lr}
    bx lr
    ENDFUNC
;#######################################################END TFT FUNCTIONS#######################################################
;#######################################################START INTERRUPT HANDLER#######################################################
EXTI0_IRQHandler PROC ; Right Button Handler

	push {r0-r5, lr}         ; Save registers to the stack
    ldr r0, =EXTI_BASE      ; EXTI base address
    ldr r1, =EXTI_PR_OFFSET        ; EXTI_PR offset
    add r0, r0, r1            ; Calculate EXTI_PR address
    mov r1, #0x01             ; Bit mask for EXTI0
    str r1, [r0]              ; Clear the pending bit for EXTI0
	; Debouncing logic
    ldr r2, =sys_time            ; Address of sys_time
    ldr r2, [r2]                 ; r2 = current sys_time
    ldr r3, =btn1_last_handled_time   ; Address of last_handled_time
    ldr r3, [r3]                 ; r3 = last_handled_time
    subs r0, r2, r3              ; r0 = sys_time - last_handled_time
    cmp r0, #250                  ; Compare difference with 50 ms
    bls skip_toggle              ; If <= 50 ms, skip the toggle
	ldr r4, =btn1_last_handled_time
	str r2, [r4]
	; ISR logic starts here:
    CMP R11, #0
    BEQ MENU_INT0_HANDLER
	B skip_toggle

; ##########Start Main Menu Handler##########
MENU_INT0_HANDLER
    ; Clear old hover
    PUSH {R0-R5}
    LDR R0, =HOVERED_GAME_X ; Load X coordinate of hovered game
    LDR R0, [R0]
    LDR R1, =HOVERED_GAME_Y ; Load Y coordinate of hovered game
    LDR R1, [R1]
    MOV R3, #116 ; Width of the hover rectangle
    MOV R4, #116 ; Height of the hover rectangle
    MOV R5, #0x0000 ; Color to clear (black)
    BL DRAW_RECT ; Call DRAW_RECT to clear the old hover
    POP {R0-R5}
    LDR R1, =HOVERED_GAME
    LDR R2, [R1] ; Get hovered game index
    ADD R2, R2, #1 ; Move to the next game
    STR R2, [R1] ; Update hovered game index
    CMP R2, #4 ; Check if it was the last game in the first row (3)
    BEQ GO_SECOND_ROW
    CMP R2, #7 ; Check if it was the last game in the second row (6)
    BEQ GO_FIRST_ROW
    ; If both weren't the case stay in the same row
    LDR R1, =HOVERED_GAME_X ; Load X coordinate of hovered game
    LDR R2, [R1] ; Get X coordinate
    ADD R2, R2, #145 ; Add 145 to X coordinate for next game
    STR R2, [R1]
    BL DRAW_MENU ; Call DRAW_MENU to update the screen
    B skip_toggle

GO_SECOND_ROW
    LDR R1, =HOVERED_GAME_X
    MOV R2, #37 ; Reset X coordinate to first game
    STR R2, [R1]
    LDR R1, =HOVERED_GAME_Y ; Load Y coordinate of hovered game
    MOV R2, #192 ; Go to the second row
    STR R2, [R1]
    BL DRAW_MENU
    B skip_toggle
GO_FIRST_ROW
    BL RESET_MENU
    BL DRAW_MENU ; Call DRAW_MENU to update the screen
    B skip_toggle
; ##########END Main Menu Handler##########
skip_toggle
    pop {r0-r5, lr}          ; Restore registers
    bx lr                     ; Return from interrupt
	ENDP

EXTI1_IRQHandler PROC ; Left Button Handler

	push {r0-r5, lr}         ; Save registers to the stack
    ldr r0, =EXTI_BASE      ; EXTI base address
    ldr r1, =EXTI_PR_OFFSET        ; EXTI_PR offset
    add r0, r0, r1            ; Calculate EXTI_PR address
    mov r1, #0x02             ; Bit mask for EXTI1
    str r1, [r0]              ; Clear the pending bit for EXTI0
	; Debouncing logic
    ldr r2, =sys_time            ; Address of sys_time
    ldr r2, [r2]                 ; r2 = current sys_time
    ldr r3, =btn2_last_handled_time   ; Address of last_handled_time
    ldr r3, [r3]                 ; r3 = last_handled_time
    subs r0, r2, r3              ; r0 = sys_time - last_handled_time
    cmp r0, #250                  ; Compare difference with 50 ms
    bls skip_toggle1              ; If <= 50 ms, skip the toggle
	ldr r4, =btn2_last_handled_time
	str r2, [r4]
	; ISR logic starts here:
    CMP R11, #0x0
    BEQ MENU_INT1_HANDLER
	B skip_toggle1
    ; ##########Start Main Menu Handler##########
MENU_INT1_HANDLER
    ; Clear old hover
    PUSH {R0-R5}
    LDR R0, =HOVERED_GAME_X ; Load X coordinate of hovered game
    LDR R0, [R0]
    LDR R1, =HOVERED_GAME_Y ; Load Y coordinate of hovered game
    LDR R1, [R1]
    MOV R3, #116 ; Width of the hover rectangle
    MOV R4, #116 ; Height of the hover rectangle
    MOV R5, #0x0000 ; Color to clear (black)
    BL DRAW_RECT ; Call DRAW_RECT to clear the old hover
    POP {R0-R5}
    LDR R1, =HOVERED_GAME
    LDR R2, [R1] ; Get hovered game index
    SUBS R2, R2, #1 ; Move to the previous game
    STR R2, [R1] ; Update hovered game index
    CMP R2, #0 ; Check if it was the first game in the first row (1)
    BEQ GO_END_SECOND_ROW
    CMP R2, #3 ; Check if it was the first game in the second row (index 4)
    BEQ GO_END_FIRST_ROW
    ; If both weren't the case stay in the same row
    LDR R1, =HOVERED_GAME_X ; Load X coordinate of hovered game
    LDR R2, [R1] ; Get X coordinate
    SUBS R2, R2, #145 ; Subtract 145 to X coordinate for next game
    STR R2, [R1]
    BL DRAW_MENU ; Call DRAW_MENU to update the screen
    B skip_toggle1

GO_END_SECOND_ROW
    LDR R1, =HOVERED_GAME
    MOV R0, #6
    STR R0, [R1] ; Set hovered game to the last game in the second row
    LDR R1, =HOVERED_GAME_X
    MOV R2, #327 ; X Coordinate to last game
    STR R2, [R1]
    LDR R1, =HOVERED_GAME_Y ; Load Y coordinate of hovered game
    MOV R2, #192 ; Go to the second row
    STR R2, [R1]
    BL DRAW_MENU
    B skip_toggle1
GO_END_FIRST_ROW
    LDR R1, = HOVERED_GAME_X
    MOV R2, #327 ; X Coordinate to last game
    STR R2, [R1]
    LDR R1, =HOVERED_GAME_Y ; Load Y coordinate of hovered game
    MOV R2, #52 ; Go to the second row
    STR R2, [R1]
    BL DRAW_MENU
    B skip_toggle1
; ##########END Main Menu Handler##########
skip_toggle1
    pop {r0-r5, lr}          ; Restore registers
    bx lr                     ; Return from interrupt
	ENDP
		
EXTI2_IRQHandler PROC ; Up Button Handler

	push {r0-r5, lr}         ; Save registers to the stack
    ldr r0, =EXTI_BASE      ; EXTI base address
    ldr r1, =EXTI_PR_OFFSET        ; EXTI_PR offset
    add r0, r0, r1            ; Calculate EXTI_PR address
    mov r1, #0x04             ; Bit mask for EXTI2
    str r1, [r0]              ; Clear the pending bit for EXTI0
	; Debouncing logic
    ldr r2, =sys_time            ; Address of sys_time
    ldr r2, [r2]                 ; r2 = current sys_time
    ldr r3, =btn3_last_handled_time   ; Address of last_handled_time
    ldr r3, [r3]                 ; r3 = last_handled_time
    subs r0, r2, r3              ; r0 = sys_time - last_handled_time
    cmp r0, #250                  ; Compare difference with 50 ms
    bls skip_toggle2             ; If <= 50 ms, skip the toggle
	ldr r4, =btn3_last_handled_time
	str r2, [r4]
	; ISR logic starts here:
    CMP R11, #0
    BEQ MENU_INT2_HANDLER
	B skip_toggle2
    ; ##########Start Main Menu Handler##########
MENU_INT2_HANDLER
    LDR R1, =HOVERED_GAME ; Load Hovered Game Number
    LDR R11, [R1] ; Store game number in R11 for context switching
    BL RESET_MENU ; Reset the menu before switching games
	MOV R0, #0x0000
	BL FILL_SCREEN
	BL DRAW_GAME1
    B skip_toggle2
    ;###########End Main Menu Handler###########
skip_toggle2
    pop {r0-r5, lr}          ; Restore registers
    bx lr                     ; Return from interrupt
	ENDP

EXTI3_IRQHandler PROC

	push {r0-r5, lr}         ; Save registers to the stack
    ldr r0, =EXTI_BASE      ; EXTI base address
    ldr r1, =EXTI_PR_OFFSET        ; EXTI_PR offset
    add r0, r0, r1            ; Calculate EXTI_PR address
    mov r1, #0x08             ; Bit mask for EXTI3
    str r1, [r0]              ; Clear the pending bit for EXTI0
	; Debouncing logic
    ldr r2, =sys_time            ; Address of sys_time
    ldr r2, [r2]                 ; r2 = current sys_time
    ldr r3, =btn4_last_handled_time   ; Address of last_handled_time
    ldr r3, [r3]                 ; r3 = last_handled_time
    subs r0, r2, r3              ; r0 = sys_time - last_handled_time
    cmp r0, #250                  ; Compare difference with 50 ms
    bls skip_toggle3              ; If <= 50 ms, skip the toggle
	ldr r4, =btn4_last_handled_time
	str r2, [r4]
	; ISR logic starts here:
skip_toggle3
    pop {r0-r5, lr}          ; Restore registers
    bx lr                     ; Return from interrupt
	ENDP
SysTick_Handler PROC
    PUSH    {R0, R1, LR}            ; Save registers
	LDR     R0, =sys_time    ; Load address of my_variable
	LDR     R1, [R0]            ; Load current value of my_variable
	ADD     R1, R1, #1          ; Increment value by 1
	STR     R1, [R0]            ; Store updated value back to my_variable
	POP     {R0, R1,LR}            ; Restore registers
	bx lr
	ENDP
    LTORG
;================================================END INTERRUPT HANDLER=================================================
	END
;========================================================END========================================================