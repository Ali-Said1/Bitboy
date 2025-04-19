	AREA    DATA, DATA, READWRITE
sys_time            DCD     0       ; 32-bit variable for system time (ms)
;####################################################INTERRUPT VARAIBLES#######################################################
btn1_last_handled_time   DCD     0       ; 32-bit variable for last handled time (ms)
btn2_last_handled_time   DCD     0       ; 32-bit variable for last handled time (ms)
btn3_last_handled_time   DCD     0       ; 32-bit variable for last handled time (ms)
btn4_last_handled_time   DCD     0       ; 32-bit variable for last handled time (ms)
;####################################################END INTERRUPT VARAIBLES#######################################################
;####################################################PONG VARAIBLES#######################################################

;####################################################END PONG VARAIBLES#######################################################
    ALIGN
    ; R5 is used as delay counter in ms
    INCLUDE hal.s
	EXPORT __main
	EXPORT EXTI0_IRQHandler
	EXPORT SysTick_Handler
	AREA MYCODE, CODE, READONLY
		; HAL LAYER

	ENTRY

__main FUNCTION

	BL _init
    BL TFT_INIT ; Call TFT_INIT to initialize the TFT LCD
    LDR R0, =0xF800 ; Load the color value
    BL TFT_FillScreen ; Call TFT_FillScreen to fill the screen with the color
MAIN_LOOP

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
	
; Number of delay ms is in R0
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
; *************************************************************
; TFT Write Data (R0 = data)
; *************************************************************
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

TFT_FillScreen FUNCTION
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
EXTI0_IRQHandler PROC

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
    LDR R0, =GPIOA_BASE
	LDR R1, =GPIOx_ODR_OFFSET
	ADD R0, R0, R1
	LDR R1, [R0]
	eor R1, #0x01
	str R1, [R0]
skip_toggle
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

	END
		
