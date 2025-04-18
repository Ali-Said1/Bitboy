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
	EXPORT __main
	EXPORT EXTI0_IRQHandler
	EXPORT SysTick_Handler
	AREA MYCODE, CODE, READONLY
		; HAL LAYER
INTERVAL EQU 0x30D400
	; This file contains the HAL layer for the STM32F103C8T6 microcontroller.
	;GPIO
GPIOA_BASE EQU 0x40010800
GPIOB_BASE EQU 0x40010C00
GPIOC_BASE EQU 0x40011000
GPIOx_CRL_OFFSET EQU 0x00
GPIOx_CRH_OFFSET EQU 0x04
GPIOx_IDR_OFFSET EQU 0x08
GPIOx_ODR_OFFSET EQU 0x0C
GPIOx_BSRR_OFFSET EQU 0x10
GPIOx_BRR_OFFSET EQU 0x14
GPIOx_LCKR_OFFSET EQU 0x18
;AFIO
AFIO_BASE EQU 0x40010000
AFIO_EVCR_OFFSET EQU 0x00
AFIO_MAPR_OFFSET EQU 0x04
AFIO_EXTICR1_OFFSET EQU 0x08
AFIO_EXTICR2_OFFSET EQU 0x0C
AFIO_EXTICR3_OFFSET EQU 0x10
AFIO_EXTICR4_OFFSET EQU 0x14
AFIO_MAPR2_OFFSET EQU 0x1C
;EXTI
EXTI_BASE EQU 0x40010400
EXTI_IMR_OFFSET EQU 0x00
EXTI_EMR_OFFSET EQU 0x04
EXTI_RTSR_OFFSET EQU 0x08
EXTI_FTSR_OFFSET EQU 0x0C
EXTI_SWIER_OFFSET EQU 0x10
EXTI_PR_OFFSET EQU 0x14
;RCC
RCC_BASE EQU 0x40021000
RCC_CR_OFFSET EQU 0x00
RCC_CFGR_OFFSET EQU 0x04
RCC_CIR_OFFSET EQU 0x08
RCC_APB2RSTR_OFFSET EQU 0x0C
RCC_APB1RSTR_OFFSET EQU 0x10
RCC_AHBENR_OFFSET EQU 0x14
RCC_APB2ENR_OFFSET EQU 0x18
RCC_APB1ENR_OFFSET EQU 0x1C
RCC_BDCR_OFFSET EQU 0x20
RCC_CSR_OFFSET EQU 0x24
;.equ RCC_AHBSTR_OFFSET, 0x28
;.equ RCC_CFGR2_OFFSET, 0x2C
;ADC
ADC1_BASE EQU 0x40012400
ADC1_SR_OFFSET EQU 0x00
ADC1_CR1_OFFSET EQU 0x04
ADC1_CR2_OFFSET EQU 0x08
ADC1_SMPR1_OFFSET EQU 0x0C
ADC1_SMPR2_OFFSET EQU 0x10
ADC1_JOFR1_OFFSET EQU 0x14
ADC1_JOFR2_OFFSET EQU 0x18
ADC1_JOFR3_OFFSET EQU 0x1C
ADC1_JOFR4_OFFSET EQU 0x20
ADC1_HTR_OFFSET EQU 0x24
ADC1_LTR_OFFSET EQU 0x28
ADC1_SQR1_OFFSET EQU 0x2C
ADC1_SQR2_OFFSET EQU 0x30
ADC1_SQR3_OFFSET EQU 0x34
ADC1_JSQR_OFFSET EQU 0x38
ADC1_JDR1_OFFSET EQU 0x3C
ADC1_JDR2_OFFSET EQU 0x40
ADC1_JDR3_OFFSET EQU 0x44
ADC1_JDR4_OFFSET EQU 0x48
ADC1_DR_OFFSET EQU 0x4C
;RTC
RTC_BASE EQU 0x40002800
RTC_CRH_OFFSET EQU 0x00
RTC_CRL_OFFSET EQU 0x04
RTC_PRLH_OFFSET EQU 0x08
RTC_PRLL_OFFSET EQU 0x0C
RTC_DIVH_OFFSET EQU 0x10
RTC_DIVL_OFFSET EQU 0x14
RTC_CNTH_OFFSET EQU 0x18
RTC_CNTL_OFFSET EQU 0x1C
RTC_ALRH_OFFSET EQU 0x20
RTC_ALRL_OFFSET EQU 0x24
;PWR
PWR_BASE EQU 0x40007000
PWR_CR_OFFSET EQU 0x00
PWR_CSR_OFFSET EQU 0x04
;System Control Space (SCS)
SCS_BASE EQU 0xE000E000
;SysTick
SysTick_BASE EQU 0xE000E010
SysTick_CTRL_OFFSET EQU 0x00
SysTick_RELOAD_VALUE_OFFSET EQU 0x04
SysTick_CURRENT_VALUE_OFFSET EQU 0x08
SysTick_CALIB_OFFSET EQU 0x0C
;NVIC
NVIC_BASE EQU 0xE000E100
;Set Enable register , each register controls 32 interrupts
NVIC_ISER_ONE_OFFSET EQU 0x00
NVIC_ISER_TWO_OFFSET EQU 0x04
NVIC_ISER_THREE_OFFSET EQU 0x08
NVIC_ISER_FOUR_OFFSET EQU 0x0C
NVIC_ISER_FIVE_OFFSET EQU 0x10
NVIC_ISER_SIX_OFFSET EQU 0x14
NVIC_ISER_SEVEN_OFFSET EQU 0x18
NVIC_ISER_EIGHT_OFFSET EQU 0x1C
;Set Clear register
NVIC_ICER_OFFSET EQU 0x80
NVIC_ICER_ONE_OFFSET EQU 0x00
NVIC_ICER_TWO_OFFSET EQU 0x04
NVIC_ICER_THREE_OFFSET EQU 0x08
NVIC_ICER_FOUR_OFFSET EQU 0x0C
NVIC_ICER_FIVE_OFFSET EQU 0x10
NVIC_ICER_SIX_OFFSET EQU 0x14
NVIC_ICER_SEVEN_OFFSET EQU 0x18
NVIC_ICER_EIGHT_OFFSET EQU 0x1C
;Set pending register
NVIC_ISPR_OFFSET EQU 0x100
NVIC_ISPR_ONE_OFFSET EQU 0x00
NVIC_ISPR_TWO_OFFSET EQU 0x04
NVIC_ISPR_THREE_OFFSET EQU 0x08
NVIC_ISPR_FOUR_OFFSET EQU 0x0C
NVIC_ISPR_FIVE_OFFSET EQU 0x10
NVIC_ISPR_SIX_OFFSET EQU 0x14
NVIC_ISPR_SEVEN_OFFSET EQU 0x18
NVIC_ISPR_EIGHT_OFFSET EQU 0x1C
;Clear pending register
NVIC_ICPR_OFFSET EQU 0x180
NVIC_ICPR_ONE_OFFSET EQU 0x00
NVIC_ICPR_TWO_OFFSET EQU 0x04
NVIC_ICPR_THREE_OFFSET EQU 0x08
NVIC_ICPR_FOUR_OFFSET EQU 0x0C
NVIC_ICPR_FIVE_OFFSET EQU 0x10
NVIC_ICPR_SIX_OFFSET EQU 0x14
NVIC_ICPR_SEVEN_OFFSET EQU 0x18
NVIC_ICPR_EIGHT_OFFSET EQU 0x1C
;Active bit register
NVIC_IABR_OFFSET EQU 0x200
NVIC_IABR_ONE_OFFSET EQU 0x00
NVIC_IABR_TWO_OFFSET EQU 0x04
NVIC_IABR_THREE_OFFSET EQU 0x08
NVIC_IABR_FOUR_OFFSET EQU 0x0C
NVIC_IABR_FIVE_OFFSET EQU 0x10
NVIC_IABR_SIX_OFFSET EQU 0x14
NVIC_IABR_SEVEN_OFFSET EQU 0x18
NVIC_IABR_EIGHT_OFFSET EQU 0x1C
;Priority register
NVIC_IPR_OFFSET EQU 0x300 ;Check interrupt number => File: RM0008, page 204/1134
NVIC_IPR_ONE_OFFSET EQU 0x00
NVIC_IPR_TWO_OFFSET EQU 0x04
NVIC_IPR_THREE_OFFSET EQU 0x08
NVIC_IPR_FOUR_OFFSET EQU 0x0C
NVIC_IPR_FIVE_OFFSET EQU 0x10
NVIC_IPR_SIX_OFFSET EQU 0x14
NVIC_IPR_SEVEN_OFFSET EQU 0x18
NVIC_IPR_EIGHT_OFFSET EQU 0x1C
;Interrupt Control and State Register (ICSR)
NVIC_ICSR_OFFSET EQU 0xC04
;Vector table OFFSET, register (VTOR)
NVIC_VTOR_OFFSET EQU 0xC08
;Application Interrupt and Reset Control Register (AIRCR)
NVIC_AIRCR_OFFSET EQU 0xC0C
		; END HAL LAYER
; TFT PIN DEFINITIONS
TFT_RST         EQU     (1 << 8)
TFT_RS          EQU     (1 << 9)
TFT_CS          EQU     (1 << 10)
TFT_WR          EQU     (1 << 11)
TFT_RD          EQU     (1 << 12)
	ENTRY

__main FUNCTION

	BL _init
    LDR R0, =0xF800 ; Load the color value
    BL TFT_FillScreen ; Call TFT_FillScreen to fill the screen with the color
MAIN_LOOP
	;LDR R0, =GPIOA_BASE
	;LDR R1, =GPIOx_ODR_OFFSET
	;ADD R0, R0, R1
	;LDR R1, [R0]
	;eor R1, #0x01
	;str R1, [R0]
	;push {R0}
	;MOV R0, #5000
	;BL DELAY_MS
	;pop {R0}
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
    ; Configure GPIOA (PA0 through PA-8) as output, we need 12 bit (LCD_RST, LCD_CS, LCD_RS, LCS_WR, LCD_RD, LCDD0-7)
    ; Lower 8 pins are defined here and will be used as Data pins for the LCD
    ldr r0, =GPIOA_BASE
    ldr r1, =GPIOx_CRL_OFFSET
    add r0, r0, r1
    MOV r1, #0x33333333  ; Set mode to output 50MHz, push-pull for PA0-PA7
    str r1, [r0]  ; Write to GPIOA_CRL
    ; Define the LSB of the 4 higher pins for the LCD functios (RST, CS, RS, WR) => Can be expanded later if we read the LCD or use SD card
    ldr r0, =GPIOA_BASE
    ldr r1, =GPIOx_CRH_OFFSET
    add r0, r0, r1
    LDR r1, =0x33333 ; Set mode to output 50MHz, push-pull for PA8-PA12
    str r1, [r0]  ; Write to GPIOA_CRH
    ; Configure GPIOB (PB0 through PB3) as input with pull-up/pull-down resistors => this is for the arcade buttons
    ldr r0, =GPIOB_BASE
    ldr r1, =GPIOx_CRL_OFFSET
    add r0, r0, r1
    MOV r1, #0x8888  ; Set mode to input with pull-up/pull-down for PB0-PB3
    str r1, [r0]  ; Write to GPIOB_CRL
    ; Configure the GPIOB input ports with pull-up resistors
    ldr r0, =GPIOB_BASE
    ldr r1, =GPIOx_BSRR_OFFSET
    add r0, r0, r1
    MOV r1, #0x0F ; Pull up the 4 LSB bits of GPIOB
    str r1, [r0]  ; Write to GPIOB_BSRR
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
    ; Map EXTI0 to EXTI3 to GPIOB
    ldr r0, =AFIO_BASE
    ldr r1, =AFIO_EXTICR1_OFFSET
    add r0, r0, r1
    ldr r1, [r0]  ; Set EXTI0 to EXTI3 to GPIOB
	mov r2, #0xFFFF
    bic r1, r1, r2 ; Clear Lower 16 bits
	mov r2, #0x1111
    orr r1, r1, r2  ; Set EXTI0 to EXTI3 to GPIOB
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
    ;#################################TFT LCD Init#######################################
    LDR R2, =GPIOA_BASE ; Load GPIOA base address
    LDR R1, =GPIOx_ODR_OFFSET ; Load GPIOx_ODR offset
    ADD R2, R2, R1 ; Calculate GPIOA_ODR address
    LDR R1, [R2] ; Read GPIOA_ODR
    ; Reset low
    BIC R1, R1, #TFT_RST
    STR R1, [R2]
    MOV R0, #120
    BL DELAY_MS
    ; Reset high
    ORR R1, R1, #TFT_RST
    STR R1, [R2]
    BL DELAY_MS
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
    MOV R2, #0x02A ; Set R2 to 0x02A (TFT LCD column address set command)
    BL TFT_COMMAND_WRITE ; Call TFT_COMMAND_WRITE to send the command
    MOV R2, #0x00 ; Set R2 to 0x00 (start column address)
    BL TFT_DATA_WRITE ; Call TFT_DATA_WRITE to send the data
    MOV R2, #0x00 ; Set R2 to 0x00 (start column address)
    BL TFT_DATA_WRITE ; Call TFT_DATA_WRITE to send the data
    MOV R2, #0x01 ; Set R2 to 0x01 (end column address)
    BL TFT_DATA_WRITE ; Call TFT_DATA_WRITE to send the data
    MOV R2, #0xDF ; Set R2 to 0x3F (end column address)
    BL TFT_DATA_WRITE ; Call TFT_DATA_WRITE to send the data
    MOV R2, #0x02B ; Set R2 to 0x02B (TFT LCD page address set command)
    BL TFT_COMMAND_WRITE ; Call TFT_COMMAND_WRITE to send the command
    MOV R2, #0x00 ; Set R2 to 0x00 (start page address)
    BL TFT_DATA_WRITE ; Call TFT_DATA_WRITE to send the data
    MOV R2, #0x00 ; Set R2 to 0x00 (start page address)
    BL TFT_DATA_WRITE ; Call TFT_DATA_WRITE to send the data
    MOV R2, #0x01 ; Set R2 to 0x01 (end page address)
    BL TFT_DATA_WRITE ; Call TFT_DATA_WRITE to send the data
    MOV R2, #0x3F ; Set R2 to 0x3F (end page address)
    BL TFT_DATA_WRITE ; Call TFT_DATA_WRITE to send the data
    MOV R2, #0x2C ; Set R2 to 0x2C (TFT LCD memory write command)
    BL TFT_COMMAND_WRITE ; Call TFT_COMMAND_WRITE to send the command
    MOV R2, #0x29 ; LCD display on command
    BL TFT_COMMAND_WRITE ; Call TFT_COMMAND_WRITE to send the command
    BL DELAY_MS ; Call DELAY_MS to wait
    pop {r0-r12, lr}
    bx lr
	
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
	ADD R3, R2, R0            ; R3 = sys_time + delay_ms (target time)
DELAY_MS_LOOP
	LDR R2, [R1]              ; R2 = current sys_time
	CMP R2, R3                ; Compare current sys_time with target time
	BLT DELAY_MS_LOOP         ; Branch if less than (not enough time has passed)
	POP {R0-R3, PC}           ; Restore registers and return
	ENDP
TFT_COMMAND_WRITE PROC
	PUSH {R0-R1, lr}          ; Save registers and link register
	ldr R0, =GPIOA_BASE
    ldr R1, =GPIOx_ODR_OFFSET
    add R0, R0, R1
    ldr R1, [R0]
    ; CLEAR CS
    BIC R1, R1, #TFT_CS ; Set CS to 0 for chip select
    STR R1, [R0]
    ; CLEAR RS
    BIC R1, R1, #TFT_RS ; Set RS to 0 for command
    STR R1, [R0]
    ; Set RD high
    ORR R1, R1, #TFT_RD ; Set RD to 1 (not a read operation)
    STR R1, [R0]
    ; Send command (R2 contains command)
    BIC R1, R1, #0xFF   ; Clear data bits PE0-PE7
    and R2, R2, #0xFF   ; Ensure only 8 bits
    orr R1, R1, R2      ; Combine with control bits
	STR R1, [R0]
    BIC R1, R1, #TFT_WR ; Clear WR bit
    STR R1, [R0]        ; Write command to data register
    ; Generate WR pulse (low > high)
    NOP
    ORR R1, R1, #TFT_WR ; Set WR to 1
    STR R1, [R0]        ; Write command to data register
    ; Set CS high
    ORR R1, R1, #TFT_CS ; Set CS to 1 (chip deselect)
    STR R1, [R0]        ; Write command to data register

	POP {R0-R1, LR}           ; Restore registers and return
    bx lr
	ENDP

TFT_DATA_WRITE PROC
	PUSH {R0-R1, lr}          ; Save registers and link register
	ldr R0, =GPIOA_BASE
    ldr R1, =GPIOx_ODR_OFFSET
    add R0, R0, R1
    ldr R1, [R0]
    ; CLEAR CS
    BIC R1, R1, #TFT_CS ; Set CS to 0 for chip select
    STR R1, [R0]
    ; CLEAR RS
    ORR R1, R1, #TFT_RS ; Set RS to 1 for data
    STR R1, [R0]
    ; Set RD high
    ORR R1, R1, #TFT_RD ; Set RD to 1 (not a read operation)
    STR R1, [R0]
    ; Send command (R2 contains data)
    BIC R1, R1, #0xFF   ; Clear data bits PE0-PE7
    and R2, R2, #0xFF   ; Ensure only 8 bits
    orr R1, R1, R2
	STR R1, [R0]
    BIC R1, R1, #TFT_WR ; Clear WR bit
    STR R1, [R0]        ; Write command to data register
    ; Generate WR pulse (low > high)
    ;STR R1, [R0]        ; Write command to data register
    NOP
    ORR R1, R1, #TFT_WR ; Set WR to 1
    STR R1, [R0]        ; Write command to data register
    ; Set CS high
    ORR R1, R1, #TFT_CS ; Set CS to 1 (chip deselect)
    STR R1, [R0]        ; Write command to data register

	POP {R0-R1, LR}           ; Restore registers and return
    bx lr
	ENDP

TFT_FillScreen PROC
    PUSH {R1-R5, LR}

    ; Save color
    MOV R5, R0

    ; Set Column Address (0-479)
    MOV R2, #0x2A
    BL TFT_COMMAND_WRITE
    MOV R2, #0x00
    BL TFT_DATA_WRITE
    MOV R2, #0x00
    BL TFT_DATA_WRITE
    MOV R2, #0x01
    BL TFT_DATA_WRITE
    MOV R2, #0xDF      ; 479
    BL TFT_DATA_WRITE

    ; Set Page Address (0-319)
    MOV R2, #0x2B
    BL TFT_COMMAND_WRITE
    MOV R2, #0x00
    BL TFT_DATA_WRITE
    MOV R2, #0x00
    BL TFT_DATA_WRITE
    MOV R2, #0x01      ; High byte of 0x013F (319)
    BL TFT_DATA_WRITE
    MOV R2, #0x3F      ; Low byte of 0x013F (319)
    BL TFT_DATA_WRITE

    ; Memory Write
    MOV R2, #0x2C
    BL TFT_COMMAND_WRITE

    ; Prepare color bytes
    MOV R0, R5, LSR #8     ; High byte
    AND R1, R5, #0xFF      ; Low byte

    ; Fill screen with color (320x480)
    LDR R3, =153600
FillLoop
    ; Write high byte
    MOV R2, R0
    BL TFT_DATA_WRITE
    
    ; Write low byte
    MOV R2, R1
    BL TFT_DATA_WRITE
    
    SUBS R3, R3, #1
    BNE FillLoop

    POP {R1-R5, LR}
    BX LR
    ENDP
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
		
