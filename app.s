	AREA    DATA, DATA, READWRITE
    EXPORT sys_time
	EXPORT ACTIVE_GAME
	EXPORT JOYSTICK_X_VALUE
	EXPORT JOYSTICK_Y_VALUE
sys_time            DCD     0       ; 32-bit variable for system time (ms)
ACTIVE_GAME       DCB     0       ; 8-bit variable for active game (0 = Main Menu, 1 = Game 1, etc.)
LAST_DRAW_TIME 	  DCW 	0
INPUT_BUFFER	  DCB 0
;####################################################INTERRUPT VARAIBLES#######################################################
btn1_last_handled_time   DCD     0       ; 32-bit variable for last handled time (ms)
btn2_last_handled_time   DCD     0       ; 32-bit variable for last handled time (ms)
btn3_last_handled_time   DCD     0       ; 32-bit variable for last handled time (ms)
btn4_last_handled_time   DCD     0       ; 32-bit variable for last handled time (ms)
btn5_last_handled_time   DCD     0       ; 32-bit variable for last handled time (ms)
;####################################################END INTERRUPT VARAIBLES#######################################################
;####################################################Menu VARAIBLES#######################################################
HOVERED_GAME DCD 0 ; Variable to store the currently hovered game
HOVERED_GAME_X DCD 0 ; X coordinate of the hovered game border
HOVERED_GAME_Y DCD 0 ; Y coordinate of the hovered game border
;###################################################END Menu VARAIBLES#######################################################
;####################################################JOYSTICK VARAIBLES#######################################################
ACTIVE_COORDINATE   DCB     0
JOYSTICK_X_VALUE    DCB     0       ; Raw ADC value for X-axis
JOYSTICK_Y_VALUE    DCB     0       ; Raw ADC value for Y-axis
JOYSTICK_SW_STATE   DCB     0       ; 0 = released, 1 = pressed
JOYSTICK_SW_LAST_HANDLED_TIME DCD 0 ; For debouncing joystick switch
JOYSTICK_NEUTRAL_LOW    DCW 1800    ; Lower threshold for neutral zone (approx 4095/2 - delta)
JOYSTICK_NEUTRAL_HIGH   DCW 2200    ; Upper threshold for neutral zone (approx 4095/2 + delta)
;####################################################END JOYSTICK VARAIBLES#######################################################    ALIGN
	;--===============================================================--
	;|--|  STM32F103C8T6  |--|  ARM Cortex-M3  |--|  ARM Assembly   |--|
    ;|--| =================Important Definitions:================== |--|
    ;|--| ============ Delay in ms, use R5 as counter ============= |--|
    ;|--| ================== Active Game => VAR =================== |--|
    ;|--| ===================== 0 == Main Menu ==================== |--|
    ;|--| ===================== 1 == Game 1... ==================== |--|
    ;|--| ===================== Game Over ========================= |--|
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
    EXPORT EXTI9_5_IRQHandler
    EXPORT ADC1_2_IRQHandler
	EXPORT SysTick_Handler
    ;==============================PONG IMPORTS=================================
    IMPORT PONG_LOGO
    IMPORT PONG
    IMPORT PONG_ball_pos
    IMPORT PONG_lbat
    IMPORT PONG_score1
    IMPORT PONG_score2
    IMPORT PONG_bg_color
    IMPORT PONG_fg_color
    IMPORT PONG_txt_color
    IMPORT PONG_state
    IMPORT PONG_RESET
	IMPORT PONG_LOOP
    IMPORT PONG_lbat_x
    IMPORT PONG_rbat_x
    IMPORT PONG_ball_hdim
    IMPORT PONG_pad_hheight
    IMPORT PONG_pad_hwidth
	IMPORT PONG_GAME_MODE
    IMPORT PONG_BAT_DOWN
    IMPORT PONG_BAT_UP
    IMPORT PONG_rbat
    ;===============================END PONG IMPORTS=================================
    ;===============================Maze Imports=================================
    IMPORT MAZEGEN_WALL
    IMPORT MAZEGEN_PATH
    IMPORT MAZE_HEIGHT
    IMPORT MAZE_WIDTH
    IMPORT MAZE_BLOCK_DIM
    IMPORT MAZE_layout
    IMPORT MAZE_pos
    IMPORT MAZE_prng_state
    IMPORT MAZE_TIMER_MINUTE
    IMPORT MAZE_TIMER_SECOND
    IMPORT MAZE_SECOND_TIMER
    IMPORT MAZE_GAME_STATE
    IMPORT MAZE_RESET
    IMPORT MAZE_GENERATE
    IMPORT MAZE_SOLVER
    IMPORT MAZE_CHECK_WIN_CONDITION
    IMPORT MAZE_LOGO
    IMPORT MAZE_WALL
    IMPORT MAZE_PATH
    IMPORT MAZEGEN_PATH_SOL
    IMPORT MAZE_KNIGHT
    IMPORT MAZE_MOVE_DOWN
    IMPORT MAZE_MOVE_LEFT
    IMPORT MAZE_MOVE_RIGHT
    IMPORT MAZE_MOVE_UP
    ;===============================END Maze Imports=================================
    ;===============================Start Snake Imports==============================
    IMPORT SNAKE_prng_state
    IMPORT SNAKE_HEAD
    IMPORT SNAKE_LENGTH
    IMPORT SNAKE_FOOD_POS
    IMPORT SNAKE_SCORE
    IMPORT SNAKE_GAME_OVER
    IMPORT SNAKE_GO_DOWN
    IMPORT SNAKE_GO_UP
    IMPORT SNAKE_GO_LEFT
    IMPORT SNAKE_GO_RIGHT
    IMPORT SNAKE_LOOP
    IMPORT SNAKE_RESET
    IMPORT SNAKE_LOGO
    ;===============================END Snake Imports================================
    ;===============================Start XO Imports================================
    IMPORT XO_LOGO
    IMPORT GameBoard
    IMPORT GAME_STATUS
    IMPORT ACTIVE_CELL
    IMPORT BOARD_DIM
    IMPORT XO_O_COLOR
    IMPORT XO_X_COLOR
    IMPORT XO_HOVER_COLOR
    IMPORT XO_WALL_COLOR
    IMPORT XO_BCK_COLOR
    IMPORT XO_INIT_GAME
    IMPORT CHECK_DRAW_X
    IMPORT CHECK_DRAW_O
    IMPORT CHECK_WINNING
    IMPORT CurrentPlayer
    ;===============================END XO Imports================================
    ;===============================Start AIM Imports================================
    IMPORT AIM_VEL
    IMPORT AIM_PRNG_STATE
    IMPORT AIM_SCORE
    IMPORT AIM_POS
    IMPORT AIM_OBJ1_POS
    IMPORT AIM_OBJ2_POS
    IMPORT AIM_OBJ3_POS
    IMPORT TARGET_R
    IMPORT AIM_BCK
    IMPORT AIM_CURSOR_COLOR
    IMPORT AIM_OBJ_COLOR
    IMPORT AIM_RESET
    IMPORT AIM_SHOOT
    IMPORT AIM_LOOP
    IMPORT AIM_GAME_STATE
    IMPORT AIM_TIMER
    IMPORT AIM_SECOND_TIMER
    IMPORT AIM_SCORE_TIMER_COLOR
    IMPORT AIM_LOGO
    ;===============================END AIM Imports================================
    ;===============================Start DINO Imports================================
    IMPORT DINO_LOOP
    IMPORT DINO_RESET
    IMPORT DINO_CHARACTER
    IMPORT DINOSTATE
    IMPORT DINOSTATE_INPUT
    IMPORT DINO_HEAD_ERASED
    IMPORT DINO_X
    IMPORT DINO_Y
    IMPORT DINO_W
    IMPORT DINO_H
    IMPORT LAST_SPAWN_TIME
	IMPORT DINO_VELOCITY
    IMPORT OB1_TYPE
    IMPORT OB1_ACTIVE
    IMPORT OB1_X
    IMPORT OB1_Y
    IMPORT OB1_W
    IMPORT OB1_H
    IMPORT OB2_TYPE
    IMPORT OB2_ACTIVE
    IMPORT OB2_X
    IMPORT OB2_Y
    IMPORT OB2_W
    IMPORT OB2_H
    IMPORT OB3_TYPE
    IMPORT OB3_ACTIVE
	IMPORT OB3_X
    IMPORT OB3_Y
    IMPORT OB3_W
    IMPORT OB3_H
    ;===============================END DINO Imports================================
    IMPORT MEMORY_LOGO
    IMPORT DINO_LOGO
	IMPORT MODULO
    AREA MYCODE, CODE, READONLY

	ENTRY

__main FUNCTION

	BL _init
    BL TFT_INIT ; Call TFT_INIT to initialize the TFT LCD
    LDR R0, =0x0 ; Load the color value
    BL FILL_SCREEN ; Call FILL_SCREEN to fill the screen with the color
    BL RESET_MENU
    BL PONG_RESET
    BL SNAKE_RESET
	BL DRAW_MENU
    LDR R0, =ACTIVE_GAME ; Load the address of ACTIVE_GAME
	MOV R11, #0
    STRB R11, [R0]
MAIN_LOOP
    LDR R0, =ACTIVE_GAME ; Load the address of ACTIVE_GAME
    LDRB R11, [R0]
    CMP		 R11, #0 ; Check if R11 is 0 (Main Menu)
    BEQ END_MAINLOOP

    CMP R11, #1 ; Check if R11 is 1
    BEQ DRAW_GAME1_LBL ; If R11 is 1, branch to DRAW_GAME1

    CMP R11, #3
    BEQ DRAW_GAME3_LBL

    CMP R11, #5
    BEQ DRAW_GAME5_LBL ; Aim Game
	
    CMP R11, #6
    BEQ DRAW_GAME6_LBL
    
    B END_MAINLOOP
DRAW_GAME1_LBL
    BL DRAW_GAME1
    B END_MAINLOOP

DRAW_GAME3_LBL
    BL DRAW_GAME3
    B END_MAINLOOP
DRAW_GAME5_LBL
    BL DRAW_GAME5
    B END_MAINLOOP

DRAW_GAME6_LBL
    BL DRAW_GAME6
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
    ;#################################Enable ADC1, GPIOA, GPIOB & AFIO Clocks#######################################
    ldr r0, =RCC_BASE
    ldr r1, =RCC_APB2ENR_OFFSET
    add r0, r0, r1
    ldr r1, [r0]  ; Read RCC_APB2ENR 
    LDR R2, =0x20D
    orr r1, r1, R2  ; Enable ADC1, GPIOA, GPIOB & AFIO clock
    str r1, [r0]  ; Write back to RCC_APB2ENR
    ;##################################End Enable GPIOA, GPIOB & AFIO Clocks#######################################
    ;#################################Configure GPIOA and GPIOB#######################################
    ; Configure GPIOA (PA0 PA1 PA2 PA3 PA5) as input, for
    ldr r0, =GPIOA_BASE
    ldr r1, =GPIOx_CRL_OFFSET
    add r0, r0, r1
    LDR r1, =0x888888  ; Set mode to input mode / pull-up - pull-down for PA0 - PA3, PA5
    str r1, [r0]  ; Write to GPIOA_CRL
    ; Set GPIOB B0, B1 to be floating input
    ldr r0, =GPIOB_BASE
    ldr r1, =GPIOx_CRL_OFFSET
    add r0, r0, r1
    ldr r1, [r0]
    AND r1, r1, #0x00
    str r1, [r0]
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
    ;##################################Start ADC1 config############################################
    ; SMPR2: Configure sample time for channel 0 (Joystick X on PB0) and 1 (Joystick Y on PB1)
    ; Let's use 71.5 cycles: 0b101
    ldr r0, =ADC1_BASE
    ldr r1, =ADC1_SMPR2_OFFSET
    add r1, r0, r1 ; Address of ADC_SMPR2
    ldr r2, [r1]
    ldr r3, =0x36000000
    orr r2, r3
    str r2, [r1]
    ; SQR1 (1 conversion in sequence)
    ldr r1, =ADC1_SQR1_OFFSET
    add r1, r0, r1
    ldr r2, [r1]
    bic r2, r2, #0x00F00000 ; Clear L bits (bits 23-20 for number of conversions)
                            ; We'll do one channel at a time.
    ;orr r2, r2, #0x00100000
    str r2, [r1]
    
    ldr r0, =ADC1_BASE
    ldr   r1, =ADC1_SQR3_OFFSET
    add   r1, r0, r1            ; r1 → &ADC1->SQR3
    ldr   r2, [r1]
    bic   r2, r2, #0x1F         ; clear SQ1 (bits 4:0)
    ;ORR R2, R2, #9
    ;LSL R2, R2, #8
    orr   r2, r2, #8     ; SQ1 = 8 (channel 8 = PB0)
    str   r2, [r1]
    ; Turn ADC On (ADON=1 in CR2) - first time to wake up, second time after config
    ldr r0, =ADC1_BASE
    ldr r1, =ADC1_CR2_OFFSET
    add r1, r0, r1 ; Address of ADC_CR2
    ldr r2, [r1]
    orr r2, r2, #ADC_CR2_ADON
    str r2, [r1]

    ; Wait for ADC to stabilize (a short delay)
    mov r5, #10 ; Small delay
    bl DELAY_MS ; Use your existing delay function

    ; ADC Calibration
    ldr r0, =ADC1_BASE
    ldr r1, =ADC1_CR2_OFFSET
    add r1, r0, r1
    ldr r2, [r1]
    orr r2, r2, #ADC_CR2_CAL  ; Start calibration
    str r2, [r1]

ADC_CAL_WAIT
    ldr r2, [r1]
    tst r2, #ADC_CR2_CAL      ; Check if CAL bit is still set
    bne ADC_CAL_WAIT          ; Loop if still calibrating
    
    ldr r0, =ADC1_BASE
    ldr r1, =ADC1_CR2_OFFSET
    add r1, r0, r1 ; Address of ADC_CR2
    ldr r2, [r1]
    orr r2, r2, #ADC_CR2_ADON
    str r2, [r1]
    ; ADC Configuration:
    ; CR1: SCAN mode off, interrupts off for now
    ldr r0, =ADC1_BASE
    ldr r1, =ADC1_CR1_OFFSET
    add r1, r0, r1 ; Address of ADC_CR1
    mov r2, #(0 << 8)   ; Default: SCAN=0, AWDSGL=0etc.
	;orr r2, r2, #(1 << 5)
    str r2, [r1]

    ; CR2: ADON=1 (already on), CONT=1 (continuous conversion), ALIGN=0 (right)
    ldr r0, =ADC1_BASE
    ldr r1, =ADC1_CR2_OFFSET
    add r1, r0, r1 ; Address of ADC_CR2
    MOV R2, #3 ; CONT AND ADON
    str r2, [r1]

    ;##################################END ADC1 config############################################
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
    ldr r1, [r0]  ; Set EXTI0 to EXTI3 to GPIOA
	mov r2, #0xFFFF
    bic r1, r1, r2 ; Clear Lower 16 bits
    str r1, [r0]  ; Write to AFIO_EXTICR1
    ldr r0, =AFIO_BASE
    ldr r1, =AFIO_EXTICR2_OFFSET
    add r0, r0, r1
    ldr r1, [r0]  ; Set EXTI0 to EXTI3 to GPIOA
	mov r2, #0xFFFF
    bic r1, r1, r2 ; Clear Lower 16 bits
    str r1, [r0]  ; Write to AFIO_EXTICR2
    ; Unmask EXTI0 to EXTI3 lines' interrupts
    ldr r0, =EXTI_BASE
    ldr r1, =EXTI_IMR_OFFSET
    add r0, r0, r1
    ldr r1, [r0]  ; Read EXTI_IMR
    orr r1, r1, #0x2F ; Unmask EXTI0 to EXTI3
    str r1, [r0]  ; Write to EXTI_IMR
    ; Enable interrupt on falling edge for EXTI0 to EXTI3 lines, since arcade buttons' pins are pulled-up
    ldr r0, =EXTI_BASE
    ldr r1, =EXTI_FTSR_OFFSET
    add r0, r0, r1
    ldr r1, [r0] ; Read EXTI_FTSR
    orr r1, r1, #0x2F ; Enable falling edge trigger for EXTI0 to EXTI3
    str r1, [r0]  ; Write to EXTI_FTSR
    ; Enable NVIC interrupts for EXTI0 to EXTI3 lines
    ldr r0, =NVIC_BASE  ; Load NVIC base address
    ldr r1, =NVIC_ISER_ONE_OFFSET  ; Load NVIC_ISER0 offset
    add r0, r0, r1  ; Calculate NVIC_ISER0 address
    ldr r1, [r0]  ; Read NVIC_ISER0
    ldr r2, =0x8003C0 ; 0x8403C0 for ADC INT
    orr r1, r1, r2  ; Enable interrupts for EXTI0 to EXTI3, ISER0 bits 6 - 9
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
    ldr r0, =NVIC_BASE
    ldr r1, =NVIC_IPR_SIX_OFFSET
    add r0, r0, r1
    ldr r1, [r0]
    MOV r2, #0x00
    ROR r2, r2, #8
    ORR r1, r1, r2
    str r1, [r0]
    ;#################################End Enable Interrupts for Arcade Buttons#######################################
	pop {r0-r12, lr}
	bx lr
	LTORG
	ENDFUNC
	

;###########################################ADC Functions################################################
START_ADC1_CH8_CONVERSION FUNCTION
    PUSH {R0-R3,LR}

    LDR R0, =ADC1_BASE
    LDR R1, =ADC1_SQR3_OFFSET
    ADD R0, R0, R1          ; Address of ADC_SQR3
    MOV R1, #8              ; R3 = channel number
    STR R1, [R0]            ; Set first sequence conversion to channel R0

    LDR R0, =ADC1_BASE
    LDR R1, =ADC1_SR_OFFSET
    ADD R0, R0, R1
    LDR R1, [R0]
    MVN R2, #2
    AND R1, R1, R2
    STR R1, [R0] ; Clear EOC
    ; 2. Start ADC conversion (Set SWSTART bit in ADC_CR2)
WAIT_CH8_EOC_LOOP
    LDR R0, =ADC1_BASE
    LDR R1, =ADC1_SR_OFFSET
    ADD R0, R0, R1
    LDR R1, [R0]
    TST R1, #2 ; Check EOC
    BEQ WAIT_CH8_EOC_LOOP

    LDR R0, =ADC1_BASE
    LDR R1, =ADC1_SR_OFFSET
    ADD R0, R0, R1
    LDR R1, [R0]
    MVN R2, #2
    AND R1, R1, R2
    STR R1, [R0] ; Clear EOC

    LDR R0, =ADC1_BASE
    LDR R1, =ADC1_DR_OFFSET
    ADD R0, R0, R1
    LDR R1, [R0]
    LSR R1, R1, #2
    MOV R2, #10
    UDIV R1, R2
    CMP R1, #100
    BLE JS_SKIP_CAP_X_AT_100
    MOV R1, #100
JS_SKIP_CAP_X_AT_100
    CMP R1, #45
    BGE JS_X_COMPARE_55
    SUB R1, R1, #50
    B JS_X_UPDATE_VAL
JS_X_COMPARE_55
    CMP R1, #55
    MOVLE R1, #0
    SUBGT R1, R1, #50
JS_X_UPDATE_VAL
    LDR R0, =JOYSTICK_X_VALUE
    STRB R1, [R0]
    
    POP {R0-R3,LR}
    BX LR
    ENDFUNC
START_ADC1_CH9_CONVERSION FUNCTION
    PUSH {R0-R3,LR}

    LDR R0, =ADC1_BASE
    LDR R1, =ADC1_SQR3_OFFSET
    ADD R0, R0, R1          ; Address of ADC_SQR3
    MOV R1, #9              ; R3 = channel number
    STR R1, [R0]            ; Set first sequence conversion to channel R0

    LDR R0, =ADC1_BASE
    LDR R1, =ADC1_SR_OFFSET
    ADD R0, R0, R1
    LDR R1, [R0]
    MVN R2, #2
    AND R1, R1, R2
    STR R1, [R0] ; Clear EOC
    ; 2. Start ADC conversion (Set SWSTART bit in ADC_CR2)
WAIT_CH9_EOC_LOOP
    LDR R0, =ADC1_BASE
    LDR R1, =ADC1_SR_OFFSET
    ADD R0, R0, R1
    LDR R1, [R0]
    TST R1, #2 ; Check EOC
    BEQ WAIT_CH9_EOC_LOOP

    LDR R0, =ADC1_BASE
    LDR R1, =ADC1_SR_OFFSET
    ADD R0, R0, R1
    LDR R1, [R0]
    MVN R2, #2
    AND R1, R1, R2
    STR R1, [R0] ; Clear EOC

    LDR R0, =ADC1_BASE
    LDR R1, =ADC1_DR_OFFSET
    ADD R0, R0, R1
    LDR R1, [R0]
    LSR R1, R1, #2
    MOV R2, #10
    UDIV R1, R2
    CMP R1, #100
    BLE JS_SKIP_CAP_Y_AT_100
    MOV R1, #100
JS_SKIP_CAP_Y_AT_100
    CMP R1, #45
    BGE JS_Y_COMPARE_55
    SUB R1, R1, #50
    B JS_Y_UPDATE_VAL
JS_Y_COMPARE_55
    CMP R1, #55
    MOVLE R1, #0
    SUBGT R1, R1, #50
JS_Y_UPDATE_VAL
    MOV R2, #-1
    MUL R1, R1, R2 ; To Make it start at top left
    LDR R0, =JOYSTICK_Y_VALUE
    STRB R1, [R0]
    
    POP {R0-R3,LR}
    BX LR
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
;========================================================================
        ; DRAW_CHAR (ARM Assembly)
        ; Draws a monochrome 16×16 glyph by expanding a 1-bit bitmap into
        ; full-color pixels.  Call with:
        ;   R0 = start X coordinate
        ;   R1 = start Y coordinate
        ;   R3 = address of glyph data (width, height, then row masks)
        ;   R4 = foreground color (16-bit RGB565)
        ;   R5 = background color (16-bit RGB565)
        ;========================================================================

DRAW_CHAR FUNCTION
    PUSH    {R6,R7,R8,R9,R10,R11,LR}
	PUSH {R4, R5}
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
	POP {R4, R5}
    MOV R2, #0x2C ; Memory Write command
    BL TFT_COMMAND_WRITE
    MOV R6, #8
CHAR_ROW_LOOP
    LDR R7, [R3], #4
    ROR R7, #16
    MOV R8, #32
CHAR_COLUMN_LOOP
    LSLS R7, #1
    BCS CHAR_DRAW_TXT
    MOV R2, R5, LSR #8 ; Extract high byte
    BL TFT_DATA_WRITE ; Send high byte of pixel color
    AND R2, R5, #0xFF ; Extract low byte
    BL TFT_DATA_WRITE ; Send low byte of pixel color
    B CHAR_COLUMN_CHECK
CHAR_DRAW_TXT
    MOV R2, R4, LSR #8 ; Extract high byte
    BL TFT_DATA_WRITE ; Send high byte of pixel color
    AND R2, R4, #0xFF ; Extract low byte
    BL TFT_DATA_WRITE ; Send low byte of pixel color
CHAR_COLUMN_CHECK
    SUB R8, R8, #1
    CMP R8, #0
    BNE CHAR_COLUMN_LOOP
    SUB R6, R6, #1
    CMP R6, #0
    BNE CHAR_ROW_LOOP
    POP     {R6,R7,R8,R9,R10,R11,LR}
    BX      LR
    ENDFUNC
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
; R3 Has image address, first 16 bytes of an image contain width and height
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

; Draw run length encoded image
; All landscape
; R0 Has Start X
; R1 Has Start Y
; R3 Has image address
DRAW_RLE_IMAGE FUNCTION
    PUSH {R0-R12, LR}
    LDRH R7, [R3], #2 ; Read the count of repitions

    LDRH R4, [R3], #2 ; Load width from image address
    LDRH R5, [R3], #2 ; Load height from image address
    
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

OUTER_RLE_LOOP
    LDRH R4, [R3], #2 ; Repition of the color
    LDRH R0, [R3], #2
INNER_RLE_LOOP
    MOV R2, R0, LSR #8 ; Extract high byte
    BL TFT_DATA_WRITE ; Send high byte of pixel color
    AND R2, R0, #0xFF ; Extract low byte
    BL TFT_DATA_WRITE ; Send low byte of pixel color
    SUB R4, R4, #1
	CMP R4, #0
    BNE INNER_RLE_LOOP
    SUB R7, R7, #1
	CMP R7, #0
    BNE OUTER_RLE_LOOP

    POP {R0-R12, LR}
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
; Function to draw an X shape
; Parameters:
; R0 = Start X coordinate
; R1 = Start Y coordinate
; R4 = Thickness
; R5 = Color
DRAW_X FUNCTION
    PUSH {R0-R12, LR}
    
    ; Save initial parameters
    MOV R6, R0  ; Save start X
    MOV R7, R1  ; Save start Y
    MOV R8, R4  ; Save thickness
    MOV R9, R5  ; Save color
    
    ; Draw first diagonal (top-left to bottom-right)
    MOV R10, #0      ; Counter for position
DIAGONAL1_LOOP
    MOV R0, R6       ; Load original X
    ADD R0, R0, R10  ; Add counter to X
    
    MOV R1, R7       ; Load original Y
    ADD R1, R1, R10  ; Add counter to Y
    
    ; Draw a square at current position
    MOV R3, R8       ; Width = thickness
    MOV R4, R8       ; Height = thickness
    MOV R5, R9       ; Color
    PUSH {R10}
    BL DRAW_RECT
    POP {R10}
    
    ADD R10, R10, #2  ; Move to next position
    CMP R10, #90     ; Check if we've reached the end
    BLT DIAGONAL1_LOOP
    
    ; Draw second diagonal (top-right to bottom-left)
    MOV R10, #0      ; Reset counter
DIAGONAL2_LOOP
    MOV R0, R6       ; Load original X
    ADD R0, R0, #90  ; Start from right side
    SUB R0, R0, R10  ; Move left as we go down
    
    MOV R1, R7       ; Load original Y
    ADD R1, R1, R10  ; Move down
    
    ; Draw a square at current position
    MOV R3, R8       ; Width = thickness
    MOV R4, R8       ; Height = thickness
    MOV R5, R9       ; Color
    PUSH {R10}
    BL DRAW_RECT
    POP {R10}
    
    ADD R10, R10, #2  ; Move to next position
    CMP R10, #90     ; Check if we've reached the end
    BLT DIAGONAL2_LOOP
    
    POP {R0-R12, LR}
    BX LR
    ENDFUNC
; DRAW_HOLLOW_CIRCLE Function
; R6 = center X coordinate
; R7 = center Y coordinate
; R8 = radius
; R9 = color (16-bit RGB565 format)
DRAW_HOLLOW_CIRCLE FUNCTION
    PUSH {R0-R12, LR}
    
    ; Save parameters
    MOV R0, R6    ; xc = center X
    MOV R1, R7    ; yc = center Y
    MOV R2, R8    ; r = radius
    MOV R3, R9    ; color
    
    ; Initialize variables
    MOV R4, #0    ; x = 0
    MOV R5, R2    ; y = r
    MOV R6, #0    ; d = 0
    
    ; Calculate initial decision parameter
    MOV R7, #3
    SUB R7, R7, R2, LSL #1  ; d = 3 - 2*r
    
HOLLOW_CIRCLE_LOOP
    ; Draw 8 octants
    BL DRAW_HOLLOW_CIRCLE_POINTS
    
    ; Update decision parameter
    CMP R7, #0
    BLT HOLLOW_CIRCLE_D_NEG
    
    ; d >= 0
    SUB R7, R7, R5, LSL #2  ; d = d - 4*y
    ADD R7, R7, #4          ; d = d + 4
    SUB R5, R5, #1          ; y = y - 1
    
HOLLOW_CIRCLE_D_NEG
    ADD R7, R7, R4, LSL #2  ; d = d + 4*x
    ADD R7, R7, #6          ; d = d + 6
    ADD R4, R4, #1          ; x = x + 1
    
    ; Check if we're done
    CMP R4, R5
    BLE HOLLOW_CIRCLE_LOOP
    
    POP {R0-R12, LR}
    BX LR
    ENDFUNC

; Helper function to draw points in all 8 octants
DRAW_HOLLOW_CIRCLE_POINTS FUNCTION
    PUSH {R0-R12, LR}
    
    ; Save center coordinates and color
    MOV R10, R0    ; xc
    MOV R11, R1    ; yc
    MOV R12, R3    ; color
    
    ; Draw point in all 8 octants
    ; (x,y)
    ADD R0, R10, R4
    ADD R1, R11, R5
    BL DRAW_PIXEL
    
    ; (y,x)
    ADD R0, R10, R5
    ADD R1, R11, R4
    BL DRAW_PIXEL
    
    ; (-x,y)
    SUB R0, R10, R4
    ADD R1, R11, R5
    BL DRAW_PIXEL
    
    ; (-y,x)
    SUB R0, R10, R5
    ADD R1, R11, R4
    BL DRAW_PIXEL
    
    ; (x,-y)
    ADD R0, R10, R4
    SUB R1, R11, R5
    BL DRAW_PIXEL
    
    ; (y,-x)
    ADD R0, R10, R5
    SUB R1, R11, R4
    BL DRAW_PIXEL
    
    ; (-x,-y)
    SUB R0, R10, R4
    SUB R1, R11, R5
    BL DRAW_PIXEL
    
    ; (-y,-x)
    SUB R0, R10, R5
    SUB R1, R11, R4
    BL DRAW_PIXEL
    
    POP {R0-R12, LR}
    BX LR
    ENDFUNC
; ----------------------------------------------------------------------------
; DRAW_CIRCLE (filled)
;  R6 = center X
;  R7 = center Y
;  R8 = radius
;  R9 = color (RGB565)
; ----------------------------------------------------------------------------
DRAW_CIRCLE
    PUSH    {R0-R12, LR}

    ;— load parameters into R0–R3
    MOV     R0, R6      ; xc
    MOV     R1, R7      ; yc
    MOV     R2, R8      ; r
    MOV     R3, R9      ; color

    ;— save center and color for use in loop
    MOV     R8, R0      ; save xc in R8
    MOV     R9, R1      ; save yc in R9

    ;— init midpoint vars
    MOV     R4, #0      ; x = 0
    MOV     R5, R2      ; y = r
    ; d = 3 - 2*r
    MOV     R7, #3
    SUB     R7, R7, R2, LSL #1

CIRCLE_LOOP
    ;— fill spans at y-offset = ±y
    ;  row = yc + y
    ADD     R1, R9, R5
    ;  xstart = xc - x
    SUB     R0, R8, R4
    ;  xend   = xc + x
    ADD     R2, R8, R4
    BL      DRAW_HLINE
    ;  row = yc - y
    SUB     R1, R9, R5
    BL      DRAW_HLINE

    ;— if x != y, also fill spans at ±x
    CMP     R4, R5
    BEQ     SKIP_SWAP
    ;  row = yc + x
    ADD     R1, R9, R4
    ;  xstart = xc - y
    SUB     R0, R8, R5
    ;  xend   = xc + y
    ADD     R2, R8, R5
    BL      DRAW_HLINE
    ;  row = yc - x
    SUB     R1, R9, R4
    BL      DRAW_HLINE
SKIP_SWAP

    ;— update decision parameter
    CMP     R7, #0
    BLT     D_NEG
    SUB     R7, R7, R5, LSL #2
    ADD     R7, R7, #4
    SUB     R5, R5, #1        ; y--
D_NEG
    ADD     R7, R7, R4, LSL #2
    ADD     R7, R7, #6
    ADD     R4, R4, #1        ; x++

    CMP     R4, R5
    BLE     CIRCLE_LOOP

    POP     {R0-R12, LR}
    BX      LR

; ----------------------------------------------------------------------------
; DRAW_HLINE: draw a horizontal line from Xstart (R0) to Xend (R2) at row Y (R1)
;  R3 = color (RGB565)
; ----------------------------------------------------------------------------
DRAW_HLINE
    PUSH    {R0-R12, LR}
    MOV     R4, R0      ; curX = Xstart
    ; color in R3, row in R1, Xend in R2

HLINE_LOOP
    MOV     R0, R4
    MOV     R1, R1      ; row
    MOV     R12, R3     ; color
    BL      DRAW_PIXEL

    ADD     R4, R4, #1
    CMP     R4, R2
    BLE     HLINE_LOOP

    POP     {R0-R12, LR}
    BX      LR

; ----------------------------------------------------------------------------
; DRAW_PIXEL
;  R0 = X, R1 = Y, R12 = color
; ----------------------------------------------------------------------------
DRAW_PIXEL
    PUSH    {R0-R12, LR}

    ;— set column address (0x2A)
    MOV     R2, #0x2A
    BL      TFT_COMMAND_WRITE
    LSR     R2, R0, #8
    BL      TFT_DATA_WRITE
    AND     R2, R0, #0xFF
    BL      TFT_DATA_WRITE
    LSR     R2, R0, #8
    BL      TFT_DATA_WRITE
    AND     R2, R0, #0xFF
    BL      TFT_DATA_WRITE

    ;— set page address (0x2B)
    MOV     R2, #0x2B
    BL      TFT_COMMAND_WRITE
    LSR     R2, R1, #8
    BL      TFT_DATA_WRITE
    AND     R2, R1, #0xFF
    BL      TFT_DATA_WRITE
    LSR     R2, R1, #8
    BL      TFT_DATA_WRITE
    AND     R2, R1, #0xFF
    BL      TFT_DATA_WRITE

    ;— memory write (0x2C)
    MOV     R2, #0x2C
    BL      TFT_COMMAND_WRITE

    ;— pixel color
    LSR     R2, R12, #8
    BL      TFT_DATA_WRITE
    AND     R2, R12, #0xFF
    BL      TFT_DATA_WRITE

    POP     {R0-R12, LR}
    BX      LR
    ENDFUNC
    LTORG
;#######################################################END Drawing Functions#######################################################
;#######################################################START Menu Functions#######################################################
;#### Function to reset the menu =>> to be called before switching the current game variable
RESET_MENU FUNCTION
    PUSH {R0-R1, LR}
    LDR R0, =HOVERED_GAME
    MOV R1, #1
    STR R1, [R0] ; Reset hovered game to 0
    LDR R0, =HOVERED_GAME_X
    MOV R1, #2
    STR R1, [R0] ; Reset X coordinate of hovered game
    LDR R0, =HOVERED_GAME_Y
    MOV R1, #52
    STR R1, [R0] ; Reset Y coordinate of hovered game

    POP {R0-R1, LR}
    BX LR
    ENDFUNC
DRAW_MENU FUNCTION
    PUSH {R0-R4, LR}
    MOV R0, #192
    MOV R1, #14
    LDR R3, =char_66
    MOV R4, #0xFFFF
    MOV R5, #0
    BL DRAW_CHAR
    MOV R0, #208
    MOV R1, #14
    LDR R3, =char_73
    MOV R4, #0xFFFF
    MOV R5, #0
    BL DRAW_CHAR
    MOV R0, #224
    MOV R1, #14
    LDR R3, =char_84
    MOV R4, #0xFFFF
    MOV R5, #0
    BL DRAW_CHAR
    MOV R0, #240
    MOV R1, #14
    LDR R3, =char_66
    MOV R4, #0xFFFF
    MOV R5, #0
    BL DRAW_CHAR
    MOV R0, #256
    MOV R1, #14
    LDR R3, =char_79
    MOV R4, #0xFFFF
    MOV R5, #0
    BL DRAW_CHAR
    MOV R0, #272
    MOV R1, #14
    LDR R3, =char_89
    MOV R4, #0xFFFF
    MOV R5, #0
    BL DRAW_CHAR
    ; Draw the hover rectangle around the hovered game
    LDR R0, =HOVERED_GAME_X ; Load X coordinate of hovered game
    LDR R0, [R0]
    LDR R1, =HOVERED_GAME_Y
    LDR R1, [R1]
    MOV R3, #116
    MOV R4, #116
    MOV R5, #0xF8F0
    BL DRAW_RECT
    ;Draw the game logo
    LDR R3, =PONG_LOGO
    MOV R0, #10
    MOV R1, #60
    BL DRAW_RLE_IMAGE ; Call DRAW_RLE_IMAGE to draw the image
    LDR R3, =MAZE_LOGO
    MOV R0, #130
    MOV R1, #60
    BL DRAW_RLE_IMAGE ; Call DRAW_IMAGE to draw the image
    LDR R3, =SNAKE_LOGO
    MOV R0, #250
    MOV R1, #60
    BL DRAW_RLE_IMAGE ; Call DRAW_RLE_IMAGE to draw the image
    LDR R3, =XO_LOGO
    MOV R0, #370
    MOV R1, #60
    BL DRAW_RLE_IMAGE ; Call DRAW_IMAGE to draw the image
    LDR R3, =AIM_LOGO
    MOV R0, #10
    MOV R1, #200
    BL DRAW_RLE_IMAGE ; Call DRAW_IMAGE to draw the image
    LDR R3, =DINO_LOGO
    MOV R0, #130
    MOV R1, #200
    BL DRAW_RLE_IMAGE ; Call DRAW_IMAGE to draw the image
    LDR R3, =DINO_LOGO
    MOV R0, #250
    MOV R1, #200
    BL DRAW_RLE_IMAGE ; Call DRAW_IMAGE to draw the image
    LDR R3, =DINO_LOGO
    MOV R0, #370
    MOV R1, #200
    BL DRAW_RLE_IMAGE ; Call DRAW_IMAGE to draw the image
    POP {R0-R4, LR}
    BX LR
    ENDFUNC
	LTORG
;#######################################################END Menu Functions#######################################################
;#######################################################Start Game Functions#######################################################
DRAW_GAME1 FUNCTION
	PUSH {R0-R11, LR}

    LDR.W R0, =PONG_state
    LDRB R1, [R0]
    CMP R1, #0
    BEQ.W GAME1_START_MENU
    CMP R1, #1
    BEQ.W GAME1_FUNCTION_END
    CMP R1, #3
    BEQ PONG_P1WIN
    CMP R1, #4
    BEQ.W PONG_P2WIN
    B GAME1_RUNNING
PONG_P1WIN
    MOV R0, #0x07E0 
    BL FILL_SCREEN
    LDR R0, =PONG_GAME_MODE
    LDRB R0, [R0]
    CMP R0, #0 ; Check if game mode is single player
    BEQ PONG_P1WIN_SINGLE_PLAYER ; If single player, branch to single player win
    LDR R3, =char_80 ;P
    MOV R0, #136
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_76 ;L
    MOV R0, #152
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_65 ;A
    MOV R0, #168
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_89 ;Y
    MOV R0, #184
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_69 ;E
    MOV R0, #200
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_82 ;R
    MOV R0, #216
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_49 ;1
    MOV R0, #248
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_87 ;W
    MOV R0, #280
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_73 ;I
    MOV R0, #296
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_78 ;N
    MOV R0, #312
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_83 ;S
    MOV R0, #328
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    B.W GAME1_FUNCTION_END
PONG_P1WIN_SINGLE_PLAYER
    LDR R3, =char_80 ;P
    MOV R0, #152
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_76 ;L
    MOV R0, #168
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_65 ;A
    MOV R0, #184
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_89 ;Y
    MOV R0, #200
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_69 ;E
    MOV R0, #216
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_82 ;R
    MOV R0, #232
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_87 ;W
    MOV R0, #264
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_73 ;I
    MOV R0, #280
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_78 ;N
    MOV R0, #296
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_83 ;S
    MOV R0, #312
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    B.W GAME1_FUNCTION_END
PONG_P2WIN
    LDR R0, =PONG_GAME_MODE
    LDRB R0, [R0]
    CMP R0, #0 ; Check if game mode is single player
    BEQ PONG_P2WIN_SINGLE_PLAYER ; If single player, branch to single player win
    MOV R0, #0x07E0
    BL FILL_SCREEN
    LDR R3, =char_80 ;P
    MOV R0, #136
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_76 ;L
    MOV R0, #152
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_65 ;A
    MOV R0, #168
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_89 ;Y
    MOV R0, #184
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_69 ;E
    MOV R0, #200
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_82 ;R
    MOV R0, #216
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_50 ;2
    MOV R0, #248
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_87 ;W
    MOV R0, #280
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_73 ;I
    MOV R0, #296
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_78 ;N
    MOV R0, #312
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_83 ;S
    MOV R0, #328
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    B.W GAME1_FUNCTION_END
PONG_P2WIN_SINGLE_PLAYER
    MOV R0, #0xF800 ; Red color
    BL FILL_SCREEN ; Fill screen with red color
    LDR R3, =char_80 ;P
    MOV R0, #136
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0xF800
    BL DRAW_CHAR
    LDR R3, =char_76 ;L
    MOV R0, #152
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0xF800
    BL DRAW_CHAR
    LDR R3, =char_65 ;A
    MOV R0, #168
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0xF800
    BL DRAW_CHAR
    LDR R3, =char_89 ;Y
    MOV R0, #184
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0xF800
    BL DRAW_CHAR
    LDR R3, =char_69 ;E
    MOV R0, #200
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0xF800
    BL DRAW_CHAR
    LDR R3, =char_82 ;R
    MOV R0, #216
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0xF800
    BL DRAW_CHAR
    LDR R3, =char_76 ;L
    MOV R0, #248
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0xF800
    BL DRAW_CHAR
    LDR R3, =char_79 ;O
    MOV R0, #264
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0xF800
    BL DRAW_CHAR
    LDR R3, =char_83 ;S
    MOV R0, #280
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0xF800
    BL DRAW_CHAR
    LDR R3, =char_69 ;E
    MOV R0, #296
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0xF800
    BL DRAW_CHAR
    LDR R3, =char_83 ;S
    MOV R0, #312
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0xF800
    BL DRAW_CHAR
    B.W GAME1_FUNCTION_END
    LTORG
GAME1_START_MENU
    PUSH {R0}
    LDR R0, =PONG_bg_color
    BL FILL_SCREEN ; Fill screen with background color
    POP {R0}
    MOV R1, #1
    STRB R1, [R0]
    MOV R0, #190
    MOV R1, #40
    LDR R3, =PONG_LOGO
    BL DRAW_RLE_IMAGE ; Call DRAW_RLE_IMAGE to draw the image
    LDR R3, =char_80
    MOV R0, #200
    MOV R1, #144
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR ; Call DRAW_CHAR to draw the image
    MOV R5, #500
    BL DELAY_MS
    ADD R0, R0, #20
    MOV R1, #144
	LDR R3, =char_79
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR ; Call DRAW_CHAR to draw the image
    MOV R5, #500
    BL DELAY_MS
    ADD R0, R0, #21
	MOV R1, #144
    LDR R3, =char_78
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR ; Call DRAW_CHAR to draw the image
    MOV R5, #500
    BL DELAY_MS
    ADD R0, R0, #20
	MOV R1, #144
    LDR R3, =char_71
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR ; Call DRAW_CHAR to draw the image
    MOV R5, #500
    BL DELAY_MS
    MOV R5, #1000
    BL DELAY_MS
    ; Show game mode select
    ; Single Player
    MOV R0, #34 ;S
    MOV R1, #160
    LDR R3,=char_83
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    MOV R0, #50 ;I
    MOV R1, #160
    LDR R3,=char_73
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    MOV R0, #66 ;N
    MOV R1, #160
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    LDR R3,=char_78
    BL DRAW_CHAR
    MOV R0, #82 ;G
    MOV R1, #160
    LDR R3,=char_71
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    MOV R0, #98 ;L
    MOV R1, #160
    LDR R3,=char_76
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    MOV R0, #114 ;E
    MOV R1, #160
    LDR R3,=char_69
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    MOV R0, #130 ;P
    MOV R1, #160
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    LDR R3,=char_80
    BL DRAW_CHAR
    MOV R0, #146 ;L
    MOV R1, #160
    LDR R3,=char_76
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    MOV R0, #162 ;A
    MOV R1, #160
    LDR R3,=char_65
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    MOV R0, #178 ;Y
    MOV R1, #160
    LDR R3,=char_89
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    MOV R0, #194 ;E
    MOV R1, #160
    LDR R3,=char_69
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    MOV R0, #208 ;R
    MOV R1, #160
    LDR R3,=char_82
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
 ; MULTIPLAYER
    MOV R0, #256 ;M
    MOV R1, #160
    LDR R3,=char_77
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    MOV R0, #272 ;U
    MOV R1, #160
    LDR R3,=char_85
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    MOV R0, #288 ;L
    MOV R1, #160
    LDR R3,=char_76
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    MOV R0, #304 ;T
    MOV R1, #160
    LDR R3,=char_84
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    MOV R0, #320 ;I
    MOV R1, #160
    LDR R3,=char_73
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    MOV R0, #336 ;P
    MOV R1, #160
    LDR R3,=char_80
    BL DRAW_CHAR
    MOV R0, #352 ;L
    MOV R1, #160
    LDR R3,=char_76
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    MOV R0, #368 ;A
    MOV R1, #160
    LDR R3,=char_65
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    MOV R0, #384 ;Y
    MOV R1, #160
    LDR R3,=char_89
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    MOV R0, #400 ;E
    MOV R1, #160
    LDR R3,=char_69
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    MOV R0, #416 ;R
    MOV R1, #160
    LDR R3,=char_82
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    B GAME1_FUNCTION_END
	LTORG
GAME1_RUNNING
    MOV R5, #1
    BL DELAY_MS

; Update Score
    ; MOV R0, #214
    ; MOV R1, #10
    ; MOV R3, #56
    ; MOV R4, #26
    ; MOV R5, #0x0000
    ; BL DRAW_RECT ; Clear the score area
    MOV R0, #238
    MOV R1, #22
    MOV R3, #6
    MOV R4, #2
    MOV R5, #0x07AF
    BL DRAW_RECT
    MOV R0, #220
    MOV R1, #15
    LDR R3, =PONG_score1
    LDRB R4, [R3]
    CMP R4, #0
    BLEQ SCORE_ZERO
    CMP R4, #1
    BLEQ SCORE_ONE
    CMP R4, #2
    BLEQ SCORE_TWO
    CMP R4, #3
    BLEQ SCORE_THREE
    CMP R4, #4
    BLEQ SCORE_FOUR
    CMP R4, #5
    BLEQ SCORE_FIVE
    CMP R4, #6
    BLEQ SCORE_SIX
    CMP R4, #7
    BLEQ SCORE_SEVEN
    CMP R4, #8
    BLEQ SCORE_EIGHT
    CMP R4, #9
    BLEQ SCORE_NINE
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR ; Draw the score image
    MOV R0, #250
    MOV R1, #15
    LDR R3, =PONG_score2
    LDRB R4, [R3]
    CMP R4, #0
    BLEQ SCORE_ZERO
    CMP R4, #1
    BLEQ SCORE_ONE
    CMP R4, #2
    BLEQ SCORE_TWO
    CMP R4, #3
    BLEQ SCORE_THREE
    CMP R4, #4
    BLEQ SCORE_FOUR
    CMP R4, #5
    BLEQ SCORE_FIVE
    CMP R4, #6
    BLEQ SCORE_SIX
    CMP R4, #7
    BLEQ SCORE_SEVEN
    CMP R4, #8
    BLEQ SCORE_EIGHT
    CMP R4, #9
    BLEQ SCORE_NINE
    LDR R4, =PONG_txt_color
    LDR R5, =PONG_bg_color
    BL DRAW_CHAR
    B END_UPDATE_SCORE
SCORE_ZERO
    PUSH {LR}
    LDR R3, =char_48 ; 0
    POP {LR}
    BX LR
SCORE_ONE
    PUSH {LR}
    LDR R3, =char_49 ; 1
    POP {LR}
    BX LR
SCORE_TWO
    PUSH {LR}
    LDR R3, =char_50 ; 2
    POP {LR}
    BX LR
SCORE_THREE
    PUSH {LR}
    LDR R3, =char_51 ; 3
    POP {LR}
    BX LR
SCORE_FOUR
    PUSH {LR}
    LDR R3, =char_52 ; 4
    POP {LR}
    BX LR
SCORE_FIVE
    PUSH {LR}
    LDR R3, =char_53 ; 5
    POP {LR}
    BX LR
SCORE_SIX
    PUSH {LR}
    LDR R3, =char_54 ; 6
    POP {LR}
    BX LR
SCORE_SEVEN
    PUSH {LR}
    LDR R3, =char_55 ; 7
    POP {LR}
    BX LR
SCORE_EIGHT
    PUSH {LR}
    LDR R3, =char_56 ; 8
    POP {LR}
    BX LR
SCORE_NINE
    PUSH {LR}
    LDR R3, =char_57 ; 9
    POP {LR}
    BX LR

END_UPDATE_SCORE
; =================Clear Ball
    LDR R2, =PONG_ball_pos
    LDR R2, [R2]
    LSR R0, R2, #16
    MOV R3, #0xFFFF
    AND R1, R2, R3
    LDR R2, =PONG_ball_hdim
    SUB R0, R0, R2
    SUB R1, R1, R2
    MOV R3, R2, LSL #1
    MOV R4, R3
    LDR R5, =PONG_bg_color
    BL DRAW_RECT

; =================Remove pixel line from each bat
    LDR R0, =PONG_rbat
    LDR r1, =PONG_rbat_x
    BL BAT_REMOVE_PIXEL_LINE
    LDR R0, =PONG_lbat
    LDR r1, =PONG_lbat_x
    BL BAT_REMOVE_PIXEL_LINE

; Poll button stats
    LDR R0, =GPIOA_BASE
    LDR R1, =GPIOx_IDR_OFFSET
    ADD R0, R0, R1
    LDR R2, [R0]
    MOV R7, R2
    MVN R3, #(1 << 0) ; right arrow
    MVN R4, #(1 << 3) ; down arrow
    AND R7, R7, R3
    CMP R2, R7
    BEQ RIGHT_BAT_UP
    MOV R7, R2
    AND R7, R7, R4
    CMP R2, R7
    BEQ RIGHT_BAT_DOWN
    B LEFT_BAT_CHECKS
RIGHT_BAT_UP
    LDR R0, =PONG_rbat
    BL PONG_BAT_UP
    MOV R7, R2
    AND R2, R2, R4
    CMP R2, R7
    BNE LEFT_BAT_CHECKS

RIGHT_BAT_DOWN
    LDR R0, =PONG_rbat
    BL PONG_BAT_DOWN
LEFT_BAT_CHECKS
    LDR R0, =PONG_GAME_MODE
    LDRB R0, [R0]
    TST R0, #0x01 ; Check if in multiplayer mode
    BEQ LOOP_FUNCTION
    MVN R3, #(1 << 2) ; up arrow
    MVN R4, #(1 << 1) ; left arrow
    MOV R7, R2
    AND R7, R7, R3
    CMP R2, R7
    BEQ LEFT_BAT_UP
    MOV R7, R2
    AND R7, R7, R4
    CMP R2, R7
    BEQ LEFT_BAT_DOWN
    B LOOP_FUNCTION
LEFT_BAT_UP
    LDR R0, =PONG_lbat
    BL PONG_BAT_UP
    MOV R7, R2
    AND R7, R7, R4
    CMP R2, R7
    BNE LOOP_FUNCTION
LEFT_BAT_DOWN
    LDR R0, =PONG_lbat
    BL PONG_BAT_DOWN
LOOP_FUNCTION
    BL PONG_LOOP
; =================Draw Ball
    LDR R2, =PONG_ball_pos
    LDR R2, [R2]
    LSR R0, R2, #16
    MOV R3, #0xFFFF
    AND R1, R2, R3
    LDR R2, =PONG_ball_hdim
    SUB R0, R0, R2
    SUB R1, R1, R2
    MOV R3, R2, LSL #1
    MOV R4, R3
    LDR R5, =PONG_fg_color
    BL DRAW_RECT
; ================Update Bats
    LDR R0, =PONG_rbat
    LDR r1, =PONG_rbat_x
    BL BAT_ADD_PIXEL_LINE
    LDR R0, =PONG_lbat
    LDR r1, =PONG_lbat_x
    BL BAT_ADD_PIXEL_LINE
GAME1_FUNCTION_END
    POP {R0-R11, LR}
	BX LR
	ENDFUNC
; ######### BAT_REMOVE_PIXEL_LINE FUNCTION
; General function for both bats
; R0 has the handled bat (right or left)
; R1 has the handled bat x
BAT_REMOVE_PIXEL_LINE FUNCTION
    PUSH {R1-R5, LR}
    ; Remove one pixel line from the start of the bat
    LDRH R2, [R0]
    PUSH {R0, R1}
    LDR R3, =PONG_pad_hwidth
    SUB R0, R1, R3 ; Start X
    LDR R3, =PONG_pad_hheight
    SUB R1, R2, R3 ; Start Y
    LDR R3, =PONG_pad_hwidth
    LSL R3, #1
    MOV R4, #1
    LDR R5, =PONG_bg_color
    BL DRAW_RECT
    POP {R0, R1}
    LDRH R2, [R0]
    LDR R3, =PONG_pad_hwidth
    SUB R0, R1, R3 ; Start X
    LDR R3, =PONG_pad_hheight
    ADD R1, R2, R3
    SUB R1, R1, #1 ; Start Y
    LDR R3, =PONG_pad_hwidth
    LSL R3, #1
    MOV R4, #1
    LDR R5, =PONG_bg_color
    BL DRAW_RECT
    POP {R1-R5, LR}
    BX LR
    ENDFUNC
; ######### BAT_ADD_PIXEL_LINE FUNCTION
; General function for both bats
; R0 has the handled bat (right or left)
; R1 has the handled bat x
BAT_ADD_PIXEL_LINE FUNCTION
    PUSH {R1-R5, LR}
    ; Remove one pixel line from the start of the bat
    LDRH R2, [R0]
    PUSH {R0, R1}
    LDR R3, =PONG_pad_hwidth
    SUB R0, R1, R3 ; Start X
    LDR R3, =PONG_pad_hheight
    SUB R1, R2, R3 ; Start Y
    LDR R3, =PONG_pad_hwidth
    LSL R3, #1
    MOV R4, #2
    LDR R5, =PONG_fg_color
    BL DRAW_RECT
    POP {R0, R1}
    LDRH R2, [R0]
    LDR R3, =PONG_pad_hwidth
    SUB R0, R1, R3 ; Start X
    LDR R3, =PONG_pad_hheight
    ADD R1, R2, R3
    SUB R1, R1, #2 ; Start Y
    LDR R3, =PONG_pad_hwidth
    LSL R3, #1
    MOV R4, #2
    LDR R5, =PONG_fg_color
    BL DRAW_RECT
    POP {R1-R5, LR}
    BX LR
    ENDFUNC
    LTORG
DRAW_FULL_BATS FUNCTION
    PUSH {R0-R5, LR}
    MOVW R0, #:lower16:PONG_rbat_x  ; Load the lower 16 bits of the address
    MOVT R0, #:upper16:PONG_rbat_x  ; Load the upper 16 bits of the address
    LDR R1, =PONG_pad_hwidth
    SUB R0, R0, R1
    LDR R1, =PONG_rbat
    LDRH R1, [R1]
    LDR R2, =PONG_pad_hheight
    SUB R1, R1, R2
    LDR R3, =PONG_pad_hwidth
    LSL R3, #1
    LDR R4, =PONG_pad_hheight
    LSL R4, #1
    LDR R5, =PONG_fg_color
    BL DRAW_RECT ; Draw right bat
    LDR R0, =PONG_lbat_x
    LDR R1, =PONG_pad_hwidth
    SUB R0, R0, R1
    LDR R1, =PONG_lbat
    LDRH R1, [R1]
    LDR R2, =PONG_pad_hheight
    SUB R1, R1, R2
    LDR R3, =PONG_pad_hwidth
    LSL R3, #1
    LDR R4, =PONG_pad_hheight
    LSL R4, #1
    LDR R5, =PONG_fg_color
    BL DRAW_RECT ; Draw left bat
    POP {R0-R5, LR}
    BX LR
    ENDFUNC

DRAW_GAME2 FUNCTION
    PUSH {R0-R11, LR}
    MOV R0, #0x00
    MOV R1, #5
    LDR R3, =MAZE_LOGO
    BL DRAW_RLE_IMAGE ; Draw the logo
    LDR R0, =SysTick_BASE
    LDR R1, =SysTick_CURRENT_VALUE_OFFSET
    ADD R0, R0, R1
    LDR R1, [R0]
    LDR R0, =MAZE_prng_state
    STR R1, [R0] ; Store the current SysTick value in the PRNG state variable
    BL MAZE_GENERATE ; Generate the maze
    LDR R6, =MAZE_layout
    LDR R7, =MAZE_WIDTH
	SUB R7, R7, #1
    LDR R8, =MAZE_HEIGHT
	SUB R8, R8, #1
    LDR R12, =MAZEGEN_WALL
    MOV R10, #-1 ; Initialize the row index
MAZE_ROW_LOOP
	ADD R10, #1
    MOV R9, #-1 ; Reset the column index for each column
MAZE_COLUMN_LOOP
	ADD R9, #1
	ADD R7, R7, #1
    MUL R2, R10, R7
    SUB R7, R7, #1
	ADD R2, R2, R9 ; Calculate the index in the maze layout
    LDRB R11, [R6, R2] ; Load the maze value at the current index
    CMP R11, R12
    BEQ MAZE_WALL_DRAW ; If not a path, draw wall
    ; Calculate the coordinates for drawing the path
    LDR R3, =MAZE_BLOCK_DIM ; Set the block dimension
    LSL R3, R3, #1 ; Multiply by 2 for width and height
    MOV R0, #100
    MUL R2, R9, R3 ; Column index multiplied by dimesion
    ADD R0, R0, R2 ; X coordinate
    MOV R1, #5
    MUL R2, R10, R3 ; Row index multiplied by dimesion
    ADD R1, R1, R2 ; Y coordinate
    ;MOV R4, R3 ; Set the width and height for the rectangle
    ; MOV R5, #0x88A2 ; Set the foreground color to reddish brown
    LDR R3, =MAZE_PATH
    BL DRAW_IMAGE ; Draw the path block
    B MAZE_COLUMN_CHECK ; Check if we need to continue drawing the maze
MAZE_WALL_DRAW
    CMP R10, #0
    CMPEQ R9, #1
    BEQ MAZE_COLUMN_CHECK ; Skip drawing if it's the second column and first row
	CMP R10, #30
	CMPEQ R9, #35
	BEQ MAZE_COLUMN_CHECK
    LDR R3, =MAZE_BLOCK_DIM ; Set the block dimension
    LSL R3, R3, #1 ; Multiply by 2 for width and height
    MOV R0, #100
    MUL R2, R9, R3 ; Column index multiplied by dimesion
    ADD R0, R0, R2 ; X coordinate
    MOV R1, #5
    MUL R2, R10, R3 ; Row index multiplied by dimesion
    ADD R1, R1, R2 ; Y coordinate
    LDR R3,=MAZE_WALL
    BL DRAW_IMAGE ; Draw the wall block
MAZE_COLUMN_CHECK
    CMP R9, R7
    BNE MAZE_COLUMN_LOOP ; Loop through the rows
    CMP R10, R8
    BNE MAZE_ROW_LOOP

    ; Draw the player
    BL DRAW_MAZE_PLAYER ; Draw the player block
    POP {R0-R11, LR}
    BX LR
    ENDFUNC
    LTORG

DRAW_MAZE_PLAYER FUNCTION
    PUSH {R0-R3, LR}
    LDR R2, =MAZE_pos
    LDR R2, [R2] ; Load the player position
    LSR R0, R2, #8 ; Extract the X coordinate
    AND R1, R2, #0x00FF
    LDR R3, =MAZE_BLOCK_DIM ; Set the block dimension
    LSL R3, R3, #1 ; Multiply by 2 for width and height
    MUL R2, R0, R3 ; Column index multiplied by dimesion
    MOV R0, #100
    ADD R0, R0, R2 ; X coordinate
    MUL R2, R1, R3 ; Row index multiplied by dimesion
    MOV R1, #5
    ADD R1, R1, R2 ; Y coordinate
    LDR R3 , =MAZE_KNIGHT
    BL DRAW_IMAGE ; Draw the player block
    POP {R0-R3, LR}
    BX LR
    ENDFUNC
DRAW_MAZE_PATH_BLOCK FUNCTION
    PUSH {R0-R3, LR}
    LDR R2, =MAZE_pos
    LDR R2, [R2] ; Load the player position
    LSR R0, R2, #8 ; Extract the X coordinate
    AND R1, R2, #0x00FF
    LDR R3, =MAZE_BLOCK_DIM ; Set the block dimension
    LSL R3, R3, #1 ; Multiply by 2 for width and height
    MUL R2, R0, R3 ; Column index multiplied by dimesion
    MOV R0, #100
    ADD R0, R0, R2 ; X coordinate
    MUL R2, R1, R3 ; Row index multiplied by dimesion
    MOV R1, #5
    ADD R1, R1, R2 ; Y coordinate
    LDR R3 , =MAZE_PATH
    BL DRAW_IMAGE ; Draw the player block
    POP {R0-R3, LR}
    BX LR
    ENDFUNC
    LTORG

GAME2_UPDATE_TIME FUNCTION
    PUSH {R0-R6, LR}
    MOV R0, #16
    MOV R1, #200
    LDR R3, =char_48 ; 0
    MOV R4, #0xFFE0 ; Set the foreground color to yellow
    MOV R5, #0x0
    BL DRAW_CHAR
    MOV R0, #32
    LDR R6, =MAZE_TIMER_MINUTE
    LDRB R2, [R6]
    MOV R7, #40
    MUL R2, R2, R7
    LDR R3, =char_48
    ADD R3, R3, R2 ; Add the minute value to the ASCII code for '0'
    BL DRAW_CHAR ; Draw the minute value
    MOV R0, #52
    LDR R6, =MAZE_TIMER_SECOND
    LDRB R2, [R6]
    MOV R7, #10
    UDIV R2, R2, R7 ; Divide the second value by 10
    LDR R3, =char_48
    MOV R7, #40
    MUL R2, R2, R7
    ADD R3, R3, R2 ; Add the second value to the ASCII code for '0'
    BL DRAW_CHAR ; Draw the tens digit of the second value
    MOV R0, #68
    LDR R6, =MAZE_TIMER_SECOND
    LDRB R2, [R6]
    MOV R7, #10
    UDIV R6, R2, R7 ; Divide the second value by 10
    MUL R6, R6, R7 ; Multiply the quotient by 10
    SUB R2, R2, R6 ; Subtract the tens digit from the second value
    LDR R3, =char_48
    MOV R7, #40
    MUL R2, R2, R7
    ADD R3, R3, R2 ; Add the second value to the ASCII code for '0'
    BL DRAW_CHAR ; Draw the units digit of the second value
    MOV R0, #46
    MOV R1, #202
    MOV R3, #4
    MOV R4, #4
    MOV R5, #0xFFE0 ; Set the foreground color to yellow
    BL DRAW_RECT ; Draw the rectangle for the timer
    MOV R0, #46
    MOV R1, #210
    MOV R3, #4
    MOV R4, #4
    MOV R5, #0xFFE0 ; Set the foreground color to yellow
    BL DRAW_RECT ; Draw the rectangle for the timer
    POP {R0-R6, LR}
    BX LR
    ENDFUNC
GAME2_LOST FUNCTION
    PUSH {R0-R12, LR}
    MOV R0, #16
    MOV R1, #200
    LDR R3, =char_48 ; 0
    MOV R4, #0xF800 ; Set the foreground color to red
    MOV R5, #0x0
    BL DRAW_CHAR
    MOV R0, #32
    MOV R1, #200
    LDR R3, =char_48 ; 0
    MOV R4, #0xF800 ; Set the foreground color to red
    MOV R5, #0x0
    BL DRAW_CHAR
    MOV R0, #52
    MOV R1, #200
    LDR R3, =char_48 ; 0
    MOV R4, #0xF800 ; Set the foreground color to red
    MOV R5, #0x0
    BL DRAW_CHAR
    MOV R0, #68
    MOV R1, #200
    LDR R3, =char_48 ; 0
    MOV R4, #0xF800 ; Set the foreground color to red
    MOV R5, #0x0
    BL DRAW_CHAR
    MOV R0, #46
    MOV R1, #202
    MOV R3, #4
    MOV R4, #4
    MOV R5, #0xF800 ; Set the foreground color to red
    BL DRAW_RECT ; Draw the rectangle for the timer
    MOV R0, #46
    MOV R1, #210
    MOV R3, #4
    MOV R4, #4
    MOV R5, #0xF800 ; Set the foreground color to red
    BL DRAW_RECT ; Draw the rectangle for the timer
    ; Type "TOO SLOW" on the screen
    MOV R0, #26
    MOV R1, #134
    LDR R3, =char_84 ; T
    MOV R4, #0xF800 ; Set the foreground color to red
    MOV R5, #0x0
    BL DRAW_CHAR
    MOV R0, #42
    MOV R1, #134
    LDR R3, =char_79 ; O
    MOV R4, #0xF800 ; Set the foreground color to red
    MOV R5, #0x0
    BL DRAW_CHAR
    MOV R0, #58
    MOV R1, #134
    LDR R3, =char_79 ; O
    MOV R4, #0xF800 ; Set the foreground color to red
    MOV R5, #0x0
    BL DRAW_CHAR
    MOV R0, #18
    MOV R1, #150
    LDR R3, =char_83 ; S
    MOV R4, #0xF800 ; Set the foreground color to red
    MOV R5, #0x0
    BL DRAW_CHAR
    MOV R0, #34
    MOV R1, #150
    LDR R3, =char_76 ; L
    MOV R4, #0xF800 ; Set the foreground color to red
    MOV R5, #0x0
    BL DRAW_CHAR
    MOV R0, #50
    MOV R1, #150
    LDR R3, =char_79 ; O
    MOV R4, #0xF800 ; Set the foreground color to red
    MOV R5, #0x0
    BL DRAW_CHAR
    MOV R0, #66
    MOV R1, #150
    LDR R3, =char_87 ; W
    MOV R4, #0xF800 ; Set the foreground color to red
    MOV R5, #0x0
    BL DRAW_CHAR
    BL MAZE_SOLVER
    LDR R6, =MAZE_layout
    LDR R7, =MAZE_WIDTH
	SUB R7, R7, #1
    LDR R8, =MAZE_HEIGHT
	SUB R8, R8, #1
    LDR R12, =MAZEGEN_PATH_SOL
    MOV R10, #-1 ; Initialize the row index
MAZE_SOL_ROW_LOOP
	ADD R10, #1
    MOV R9, #-1 ; Reset the column index for each column
MAZE_SOL_COLUMN_LOOP
	ADD R9, #1
	ADD R7, R7, #1
    MUL R2, R10, R7
    SUB R7, R7, #1
	ADD R2, R2, R9 ; Calculate the index in the maze layout
    LDRB R11, [R6, R2] ; Load the maze value at the current index
    CMP R11, R12
    BNE MAZE_SOL_COLUMN_CHECK ; If not a path, skip drawing
    ; Calculate the coordinates for drawing the path
	CMP R10, #0
	CMPEQ R9, #0
	BEQ MAZE_SOL_COLUMN_CHECK
    LDR R3, =MAZE_BLOCK_DIM ; Set the block dimension
    LSL R3, R3, #1 ; Multiply by 2 for width and height
    MOV R0, #100
    MUL R2, R9, R3 ; Column index multiplied by dimesion
    ADD R0, R0, R2 ; X coordinate
    MOV R1, #5
    MUL R2, R10, R3 ; Row index multiplied by dimesion
    ADD R1, R1, R2 ; Y coordinate
    MOV R4, R3 ; Set the width and height for the rectangle
    MOV R5, #0xF81F ; Set the foreground color to magenta for sol
    BL DRAW_RECT ; Draw the solution block
MAZE_SOL_COLUMN_CHECK
    CMP R9, R7
    BNE MAZE_SOL_COLUMN_LOOP ; Loop through the rows
    CMP R10, R8
    BNE MAZE_SOL_ROW_LOOP

; Draw the player last position as yellow

    LDR R2, =MAZE_pos
    LDR R2, [R2] ; Load the player position
    LSR R0, R2, #8 ; Extract the X coordinate
    AND R1, R2, #0x00FF
    LDR R3, =MAZE_BLOCK_DIM ; Set the block dimension
    LSL R3, R3, #1 ; Multiply by 2 for width and height
    MUL R2, R0, R3 ; Column index multiplied by dimesion
    MOV R0, #100
    ADD R0, R0, R2 ; X coordinate
    MUL R2, R1, R3 ; Row index multiplied by dimesion
    MOV R1, #5
    ADD R1, R1, R2 ; Y coordinate
   MOV R4, R3 ; Set the width and height for the rectangle
    MOV R5, #0xFFE0 ; Set the foreground color to yellow
    BL DRAW_RECT ; Draw the player block
    POP {R0-R12, LR}
    BX LR
    ENDFUNC
    LTORG
GAME2_WIN FUNCTION
    PUSH {R0-R12, LR}
	MOV R0, #0
	MOV R1, #100
	MOV R3, #100
	MOV R4, #220
	MOV R5, #0x0
	BL DRAW_RECT
    ; Type "You Win" on the screen
    MOV R0, #26
    MOV R1, #188
    LDR R3, =char_89 ; Y
    MOV R4, #0x07E0 ; Set the foreground color to green
    MOV R5, #0x0
    BL DRAW_CHAR
    MOV R0, #42
    MOV R1, #188
    LDR R3, =char_79 ; O
    MOV R4, #0x07E0 ; Set the foreground color to green
    MOV R5, #0x0
    BL DRAW_CHAR
    MOV R0, #58
    MOV R1, #188
    LDR R3, =char_85 ; U
    MOV R4, #0x07E0 ; Set the foreground color to green
    MOV R5, #0x0
    BL DRAW_CHAR
    MOV R0, #26
    MOV R1, #204
    LDR R3, =char_87 ; W
    MOV R4, #0x07E0 ; Set the foreground color to green
    MOV R5, #0x0
    BL DRAW_CHAR
    MOV R0, #42
    MOV R1, #204
    LDR R3, =char_73 ; I
    MOV R4, #0x07E0 ; Set the foreground color to green
    MOV R5, #0x0
    BL DRAW_CHAR
    MOV R0, #58
    MOV R1, #204
    LDR R3, =char_78 ; N
    MOV R4, #0x07E0 ; Set the foreground color to green
    MOV R5, #0x0
    BL DRAW_CHAR

    BL MAZE_SOLVER
    LDR R6, =MAZE_layout
    LDR R7, =MAZE_WIDTH
	SUB R7, R7, #1
    LDR R8, =MAZE_HEIGHT
	SUB R8, R8, #1
    LDR R12, =MAZEGEN_PATH_SOL
    MOV R10, #-1 ; Initialize the row index
MAZE_WIN_SOL_ROW_LOOP
	ADD R10, #1
    MOV R9, #-1 ; Reset the column index for each column
MAZE_WIN_SOL_COLUMN_LOOP
	ADD R9, #1
	ADD R7, R7, #1
    MUL R2, R10, R7
    SUB R7, R7, #1
	ADD R2, R2, R9 ; Calculate the index in the maze layout
    CMP R2, #0
	BEQ MAZE_WIN_DRAW
	LDRB R11, [R6, R2] ; Load the maze value at the current index
    CMP R11, R12
    BEQ MAZE_WIN_SOL_COLUMN_CHECK ; If is a path sol, skip drawing
	CMP R10, #0
    CMPEQ R9, #1
    BEQ MAZE_WIN_SOL_COLUMN_CHECK ; Skip drawing if it's the second column and first row
	CMP R10, #30
	CMPEQ R9, #35
	BEQ MAZE_WIN_SOL_COLUMN_CHECK
MAZE_WIN_DRAW
    LDR R3, =MAZE_BLOCK_DIM ; Set the block dimension
    LSL R3, R3, #1 ; Multiply by 2 for width and height
    MOV R0, #100
    MUL R2, R9, R3 ; Column index multiplied by dimesion
    ADD R0, R0, R2 ; X coordinate
    MOV R1, #5
    MUL R2, R10, R3 ; Row index multiplied by dimesion
    ADD R1, R1, R2 ; Y coordinate
    MOV R4, R3 ; Set the width and height for the rectangle
    MOV R5, #0x07E0 ; Set the foreground color to green to border solution
    BL DRAW_RECT ; Draw the solution block
MAZE_WIN_SOL_COLUMN_CHECK
    CMP R9, R7
    BNE MAZE_WIN_SOL_COLUMN_LOOP ; Loop through the rows
    CMP R10, R8
    BNE MAZE_WIN_SOL_ROW_LOOP

    POP {R0-R12, LR}
    BX LR
    ENDFUNC
	LTORG
DRAW_GAME3 FUNCTION
    PUSH {R0-R12, LR}
  	LDR R0, =SNAKE_GAME_OVER
	LDRB R0, [R0]
	CMP R0, #1
	BEQ.W SNAKE_GAME_END
	LDR R0, =LAST_DRAW_TIME
	LDRH R1, [R0]
	CMP R1, #200
	BLT.W SNAKE_GAME_END
	MOV R1, #0
	STRH R1, [R0]
	; Remove Head
	LDR R7, =SNAKE_HEAD
    LDRH R2, [R7]
    LSR R0, R2, #8
    AND R1, R2, #0xFF
	MOV R2, #10
	MUL R0, R0, R2
	MUL R1, R1, R2
    MOV R3, #10
    MOV R4, #10
	MOV R5, #0xFFFF
	MOV R5, #0x07E0
	BL DRAW_RECT
	; Remove Tail
	LDR R7, =SNAKE_HEAD
    LDR R6, =SNAKE_LENGTH
    LDRB R6, [R6]
    SUB R6, R6, #1
	LSL R8, R6, #1
    LDRH R2, [R7, R8]
    LSR R0, R2, #8
    AND R1, R2, #0xFF
	MOV R2, #10
	MUL R0, R0, R2
	MUL R1, R1, R2
    MOV R3, #10
    MOV R4, #10
	MOV R5, #0xFFE0
	BL DRAW_RECT
	BL SNAKE_LOOP
	LDR R0, =SNAKE_GAME_OVER
	LDRB R0, [R0]
	CMP R0, #1
	BEQ.W SNAKE_GAME_OVER_DRAW
	LDR R0, =INPUT_BUFFER
	MOV R1, #0
	STRB R1, [R0]
	; Draw Tail
	LDR R7, =SNAKE_HEAD
    LDR R6, =SNAKE_LENGTH
    LDRB R6, [R6]
    SUB R6, R6, #1
	LSL R8, R6, #1
    LDRH R2, [R7, R8]
    LSR R0, R2, #8
    AND R1, R2, #0xFF
	MOV R2, #10
	MUL R0, R0, R2
	MUL R1, R1, R2
    MOV R3, #10
    MOV R4, #10
	MOV R5, #0x07E0
	BL DRAW_RECT
	; Draw Head
	LDR R7, =SNAKE_HEAD
    LDRH R2, [R7]
    LSR R0, R2, #8
    AND R1, R2, #0xFF
	MOV R2, #10
	MUL R0, R0, R2
	MUL R1, R1, R2
    MOV R3, #10
    MOV R4, #10
	MOV R5, #0x001F
	BL DRAW_RECT

    LDR R0, =SNAKE_FOOD_POS
    LDRH R2, [R0]
    LSR R0, R2, #8
    AND R1, R2, #0xFF
	MOV R2, #10
	MUL R0, R0, R2
	MUL R1, R1, R2
    MOV R3, #10
    MOV R4, #10
    MOV R5, #0xF800
    BL DRAW_RECT
SNAKE_GAME_END
	POP {R0-R12, LR}
    BX LR
    ENDFUNC
; R5 has color
; R9 has head color
SNAKE_DRAW FUNCTION
	PUSH {R0-R12, LR}
	LDR R7, =SNAKE_HEAD
    LDR R6, =SNAKE_LENGTH
    LDRB R6, [R6]
    SUB R6, R6, #1
SNAKE_DRAW_LOOP
	LSL R8, R6, #1
    LDRH R2, [R7, R8]
    LSR R0, R2, #8
    AND R1, R2, #0xFF
	MOV R2, #10
	MUL R0, R0, R2
	MUL R1, R1, R2
    MOV R3, #10
    MOV R4, #10
    CMP R6, #0
    MOVEQ R5, R9
    BL DRAW_RECT

    SUBS R6, R6, #1
    CMP R6, #-1
    BNE SNAKE_DRAW_LOOP
	POP {R0-R12, LR}
	BX LR
	ENDFUNC
    LTORG
SNAKE_GAME_OVER_DRAW FUNCTION
	PUSH {R0-R12}
	MOV R0, #0xFFE0
 	BL FILL_SCREEN
    MOV R0, #200
    MOV R1, #144
    LDR R3, =char_83 ; S
    MOV R4, #0x001F ; Set the foreground color to Blue
    MOV R5, #0xFFE0
    BL DRAW_CHAR
    ADD R0, R0, #16
    LDR R3, =char_67 ; C
    MOV R4, #0x001F ; Set the foreground color to Blue
    MOV R5, #0xFFE0
    BL DRAW_CHAR
    ADD R0, R0, #16
    LDR R3, =char_79 ; O
    MOV R4, #0x001F ; Set the foreground color to Blue
    MOV R5, #0xFFE0
    BL DRAW_CHAR
    ADD R0, R0, #16
    LDR R3, =char_82 ; R
    MOV R4, #0x001F ; Set the foreground color to Blue
    MOV R5, #0xFFE0
    BL DRAW_CHAR
    ADD R0, R0, #16
    LDR R3, =char_69 ; E
    MOV R4, #0x001F ; Set the foreground color to Blue
    MOV R5, #0xFFE0
    BL DRAW_CHAR
    ; Draw the score itself
    LDR R3, =SNAKE_SCORE
    LDRH R9, [R3]
    MOV R0, R9
    MOV R1, #10
    BL MODULO
    MOV R7, #40
    MUL R2, R2, R7
    LDR R3, =char_48
    ADD R3, R3, R2
    MOV R0, #256
    MOV R1, #160
    MOV R4, #0x001F ; Set the foreground color to Blue
    MOV R5, #0xFFE0
    BL DRAW_CHAR
    MOV R1, #10
    UDIV R9, R1
    MOV R0, R9
    BL MODULO
    MOV R7, #40
    MUL R2, R2, R7
    LDR R3, =char_48
    ADD R3, R3, R2
    MOV R0, #240
    MOV R1, #160
    MOV R4, #0x001F ; Set the foreground color to Blue
    MOV R5, #0xFFE0
    BL DRAW_CHAR
    MOV R1, #10
    UDIV R9, R1
    MOV R0, R9
    BL MODULO
    MOV R7, #40
    MUL R2, R2, R7
    LDR R3, =char_48
    ADD R3, R3, R2
    MOV R0, #224
    MOV R1, #160
    MOV R4, #0x001F ; Set the foreground color to Blue
    MOV R5, #0xFFE0
    BL DRAW_CHAR
    MOV R1, #10
    UDIV R9, R1
    MOV R0, R9
    BL MODULO
    MOV R7, #40
    MUL R2, R2, R7
    LDR R3, =char_48
    ADD R3, R3, R2
    MOV R0, #208
    MOV R1, #160
    MOV R4, #0x001F ; Set the foreground color to Blue
    MOV R5, #0xFFE0
	BL DRAW_CHAR
	POP {R0-R12}
	B MAIN_LOOP
	ENDFUNC

DRAW_GAME4 FUNCTION
    PUSH {R0-R12, LR}
    MOV R0, #0
    MOV R1, #0
    MOV R3, #0x80
    MOV R4, #0x140
    MOV R5, #0
    BL DRAW_RECT
    MOV R0, #0x190
    MOV R1, #0
    MOV R3, #0x80
    MOV R4, #0x140
    MOV R5, #0
    BL DRAW_RECT
    MOV R0, #80
    MOV R1, #0
    MOV R3, #0x140
    MOV R4, #0x140
    LDR R5, =XO_BCK_COLOR
    BL DRAW_RECT
    MOV R0, #180
    MOV R1, #0
    MOV R3, #10
    MOV R4, #0x140
    LDR R5, =XO_WALL_COLOR
    BL DRAW_RECT
    MOV R0, #0x122 ; 290
    MOV R1, #0
    MOV R3, #10
    MOV R4, #0x140
    LDR R5, =XO_WALL_COLOR
    BL DRAW_RECT
    MOV R0, #80
    MOV R1, #100
    MOV R3, #0x140
    MOV R4, #10
    LDR R5, =XO_WALL_COLOR
    BL DRAW_RECT
    MOV R0, #80
    MOV R1, #210
    MOV R3, #0x140
    MOV R4, #10
    LDR R5, =XO_WALL_COLOR
    BL DRAW_RECT
    MOV R0, #80
    MOV R1, #0
    MOV R3, #100
    MOV R4, #100
    LDR R5, =XO_HOVER_COLOR
    BL DRAW_RECT
    POP {R0-R12, LR}
    BX LR
    ENDFUNC
    LTORG
; R3 Has current active cell
XO_INC_HOVER
    PUSH {R0-R12, LR}
    LDR R0, =ACTIVE_CELL
    LDRB R0, [R0]
    LDR R1, =GameBoard
XO_INC_LOOP
    CMP R0, #8
    MOVEQ R0, #-1
    ADD R0, R0, #1
    LDRB R2, [R1, R0]
    CMP R0, R3
    BEQ XO_INC_END
    CMP R2, #0
    BNE XO_INC_LOOP
XO_INC_END
    LDR R1, =ACTIVE_CELL
    STRB R0, [R1]
    POP {R0-R12, LR}
    BX LR
    ENDFUNC
XO_DEC_HOVER
    PUSH {R0-R12, LR}
    LDR R0, =ACTIVE_CELL
    LDRB R0, [R0]
    LDR R1, =GameBoard
XO_DEC_LOOP
    CMP R0, #0
    MOVEQ R0, #9
    SUB R0, R0, #1
    LDRB R2, [R1, R0]
    CMP R0, R3
    BEQ XO_DEC_END
    CMP R2, #0
    BNE XO_DEC_LOOP
XO_DEC_END
    LDR R1, =ACTIVE_CELL
    STRB R0, [R1]
    POP {R0-R12, LR}
    BX LR
    ENDFUNC
; R7 has the color
XO_DRAW_CELL FUNCTION
    PUSH {R0-R12, LR}
    LDR R0, =ACTIVE_CELL
    LDRB R0, [R0]
    ; Calculate Start X
    MOV R1, #3
    BL MODULO
    MOV R1, #110
    MUL R0, R1, R2
    ADD R0, R0, #80
    ; Calculate Start Y
    LDR R1, =ACTIVE_CELL
    LDRB R1, [R1]
    MOV R8, #3
    UDIV R4, R1, R8
    MOV R2, #110
    MUL R1, R2, R4
    MOV R3, #100
    MOV R4, #100
    MOV R5, R7
    BL DRAW_RECT
    POP {R0-R12, LR}
    BX LR
    ENDFUNC
DRAW_PLAYER_X_WIN FUNCTION
    PUSH {R0-R12, LR}
    LDR R3, =char_80 ;P
    MOV R0, #136
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_76 ;L
    MOV R0, #152
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_65 ;A
    MOV R0, #168
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_89 ;Y
    MOV R0, #184
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_69 ;E
    MOV R0, #200
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_82 ;R
    MOV R0, #216
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_88 ;X
    MOV R0, #248
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_87 ;W
    MOV R0, #280
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_73 ;I
    MOV R0, #296
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_78 ;N
    MOV R0, #312
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_83 ;S
    MOV R0, #328
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    POP {R0-R12, LR}
    BX LR
    ENDFUNC
DRAW_PLAYER_O_WIN FUNCTION
    PUSH {R0-R12, LR}
    LDR R3, =char_80 ;P
    MOV R0, #136
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_76 ;L
    MOV R0, #152
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_65 ;A
    MOV R0, #168
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_89 ;Y
    MOV R0, #184
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_69 ;E
    MOV R0, #200
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_82 ;R
    MOV R0, #216
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_79 ;O
    MOV R0, #248
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_87 ;W
    MOV R0, #280
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_73 ;I
    MOV R0, #296
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_78 ;N
    MOV R0, #312
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    LDR R3, =char_83 ;S
    MOV R0, #328
    MOV R1, #152
    MOV R4, #0x0000
    MOV R5, #0x07E0
    BL DRAW_CHAR
    POP {R0-R12, LR}
    BX LR
    ENDFUNC
XO_GAME_DRAW FUNCTION
    PUSH {R0-R12, LR}
    LDR R3, =char_68 ;D
    MOV R0, #8
    MOV R1, #152
    MOV R4, #0x001E
    MOV R5, #0x0000
    BL DRAW_CHAR
    LDR R3, =char_82 ;R
    MOV R0, #24
    MOV R1, #152
    MOV R4, #0x001E
    MOV R5, #0x0000
    BL DRAW_CHAR
    LDR R3, =char_65 ;A
    MOV R0, #40
    MOV R1, #152
    MOV R4, #0x001E
    MOV R5, #0x0000
    BL DRAW_CHAR
    LDR R3, =char_87 ;W
    MOV R0, #56
    MOV R1, #152
    MOV R4, #0x001E
    MOV R5, #0x0000
    BL DRAW_CHAR
    LDR R3, =char_68 ;D
    MOV R0, #0x198
    MOV R1, #152
    MOV R4, #0x001E
    MOV R5, #0x0000
    BL DRAW_CHAR
    LDR R3, =char_82 ;R
    MOV R0, #0x1A8
    MOV R1, #152
    MOV R4, #0x001E
    MOV R5, #0x0000
    BL DRAW_CHAR
    LDR R3, =char_65 ;A
    MOV R0, #0x1B8
    MOV R1, #152
    MOV R4, #0x001E
    MOV R5, #0x0000
    BL DRAW_CHAR
    LDR R3, =char_87 ;W
    MOV R0, #0x1C8
    MOV R1, #152
    MOV R4, #0x001E
    MOV R5, #0x0000
    BL DRAW_CHAR
    POP {R0-R12, LR}
    BX LR
    ENDFUNC
DRAW_GAME5 FUNCTION
    PUSH {R0-R12, LR}
    LDR R0, =AIM_GAME_STATE
    LDRB R0, [R0]
    CMP R0, #0
    BNE DRAW_GAME5_END
	MOV  R5, #50
	BL DELAY_MS
    BL START_ADC1_CH8_CONVERSION
    BL START_ADC1_CH9_CONVERSION
    LDR R0, =JOYSTICK_X_VALUE
    LDR R1, =JOYSTICK_Y_VALUE
    LDRB R0, [R0]
    LSL R0, R0, #8
    LDRB R1, [R1]
    ORR R0, R0, R1
    LDR R1, =AIM_VEL
    STRH R0, [R1]
    LDR R5, =AIM_BCK
    BL DRAW_AIM_CURSOR
    BL AIM_LOOP
    LDR R5, =AIM_OBJ_COLOR
    BL DRAW_AIM_OBJS
    LDR R5, =AIM_CURSOR_COLOR
    BL DRAW_AIM_CURSOR
    BL AIM_DRAW_SCORE
    BL DRAW_GAME5_TIM
DRAW_GAME5_END
    POP {R0-R12, LR}
    BX LR
    ENDFUNC
; R5 Has color
DRAW_AIM_CURSOR FUNCTION
    PUSH {R0-R12, LR}
    LDR R6, =AIM_POS
    LDR R6, [R6]
    LDR R8, =0xFFFF
    AND R7, R6, R8
    LSR R6, R6, #16
    LDR R8, =TARGET_R
    MOV R9, R5
    BL DRAW_HOLLOW_CIRCLE
    SUB R0, R6, R8
    MOV R1, R7
    MOV R3, R8, LSL #1
    MOV R4, #1
    BL DRAW_RECT
    MOV R0, R6
    LDR R8, =TARGET_R
    SUB R1, R7, R8
    MOV R3, #1
    MOV R4, R8, LSL #1
    BL DRAW_RECT
    POP {R0-R12, LR}
    BX LR
    ENDFUNC
    LTORG
; R5 has color
DRAW_AIM_OBJS FUNCTION
    PUSH {R0-R12, LR}
    LDR R6, =AIM_OBJ1_POS
    LDRH R6, [R6]
    MOV R0, #10
    AND R7, R6, #0xFF
    LSR R6, R6, #8
    MUL R6, R0
    MUL R7, R0
    LDR R8, =TARGET_R
    MOV R9, R5
    BL DRAW_CIRCLE
    
    LDR R6, =AIM_OBJ2_POS
    LDRH R6, [R6]
    MOV R0, #10
    AND R7, R6, #0xFF
    LSR R6, R6, #8
    MUL R6, R0
    MUL R7, R0
    LDR R8, =TARGET_R
    MOV R9, R5
    BL DRAW_CIRCLE
    
    LDR R6, =AIM_OBJ3_POS
    LDRH R6, [R6]
    MOV R0, #10
    AND R7, R6, #0xFF
    LSR R6, R6, #8
    MUL R6, R0
    MUL R7, R0
    LDR R8, =TARGET_R
    MOV R9, R5
    BL DRAW_CIRCLE
    POP {R0-R12, LR}
    BX LR
    ENDFUNC
AIM_DRAW_SCORE FUNCTION
    PUSH {R0-R12, LR}
    LDR R3, =AIM_SCORE
    LDRB R9, [R3]
    MOV R0, R9
    MOV R1, #10
    BL MODULO
    MOV R7, #40
    MUL R2, R2, R7
    LDR R3, =char_48
    ADD R3, R3, R2
    LDR R0, =454
    LDR R1, =294
    LDR R4, =AIM_SCORE_TIMER_COLOR
    LDRH R4, [R4]
    MOV R5, #0
    BL DRAW_CHAR
    MOV R1, #10
    UDIV R9, R1
    MOV R0, R9
    BL MODULO
    MOV R7, #40
    MUL R2, R2, R7
    LDR R3, =char_48
    ADD R3, R3, R2
    LDR R0, =438
    LDR R1, =294
    LDR R4, =AIM_SCORE_TIMER_COLOR
    LDRH R4, [R4]
    MOV R5, #0
    BL DRAW_CHAR
    MOV R1, #10
    UDIV R9, R1
    MOV R0, R9
    BL MODULO
    MOV R7, #40
    MUL R2, R2, R7
    LDR R3, =char_48
    ADD R3, R3, R2
    LDR R0, =422
    LDR R1, =294
    LDR R4, =AIM_SCORE_TIMER_COLOR
    LDRH R4, [R4]
    MOV R5, #0
    BL DRAW_CHAR
    POP {R0-R12, LR}
    BX LR
    ENDFUNC
DRAW_GAME5_TIM FUNCTION
    PUSH {R0-R12, LR}
    LDR R0, =AIM_TIMER
    LDRB R0, [R0]
    MOV R1, #10
    BL MODULO
    MOV R7, #40
    MUL R2, R2, R7
    LDR R3, =char_48
    ADD R3, R3, R2 ; Units
    MOV R0, #26
    LDR R1, =294
    LDR R4, =AIM_SCORE_TIMER_COLOR
    LDRH R4, [R4]
    MOV R5, #0
    BL DRAW_CHAR
    LDR R0, =AIM_TIMER
    LDRB R0, [R0]
    MOV R1, #10
    UDIV R0, R1
    MOV R7, #40
    MUL R0, R0, R7
    LDR R4, =AIM_SCORE_TIMER_COLOR
    LDRH R4, [R4]
    MOV R5, #0
    LDR R3, =char_48
    ADD R3, R3, R0 ; Tens
    MOV R0, #10
    LDR R1, =294
    BL DRAW_CHAR
    POP {R0-R12, LR}
    BX LR
    ENDFUNC

DRAW_GAME6 FUNCTION
    PUSH {R0-R12, LR}
DELETE_OBS
    MOV R0, #0
    MOV R1, #100
    MOV R3, #40
    MOV R4, #180
    MOV R5, #0x0
    BL DRAW_RECT
    LDR R6, =DINOSTATE
    LDRB R6, [R6]
    CMP R6, #1
    BNE DINO_OB1_REMOVE
    LDR R0, =DINO_X
    LDRH R0, [R0]
    LDR R1, =DINO_Y
    LDRH R1, [R1]
    LDR R3, =DINO_W
    LDRH R3, [R3]
    ; LDR R4, =DINO_H
    ; LDRH R4, [R4]
    MOV R4, #102
    MOV R5, #0x0
    BL DRAW_RECT
DINO_OB1_REMOVE
    LDR R6, =OB1_ACTIVE
    LDRB R6, [R6]
    CMP R6, #1
    BNE DINO_OB2_REMOVE
    LDR R0, =OB1_X
    LDRH R0, [R0]
    LDR R1, =OB1_Y
    LDRH R1, [R1]
    LDR R3, =OB1_W
    LDRH R3, [R3]
    ADD R0, R0, R3
    SUB R0, R0, #1
    MOV R3, #1
    LDR R4, =OB1_H
    LDRH R4, [R4]
    MOV R5, #0x0
    BL DRAW_RECT
DINO_OB2_REMOVE
    LDR R0, =OB2_X
    LDRH R0, [R0]
    LDR R1, =OB2_Y
    LDRH R1, [R1]
    LDR R3, =OB2_W
    LDRH R3, [R3]
    ADD R0, R0, R3
    SUB R0, R0, #1
    MOV R3, #1
    LDR R4, =OB2_H
    LDRH R4, [R4]
    MOV R5, #0x0
    LDR R6, =OB2_ACTIVE
    LDRB R6, [R6]
    CMP R6, #1
    BNE DINO_GO_LOOP
    BL DRAW_RECT

DINO_GO_LOOP
    BL DINO_LOOP
    LDR R0, =DINOSTATE_INPUT
    MOV R1, #0
    STRB R1, [R0]
    LDR R0, =DINO_X
    LDRH R0, [R0]
    LDR R1, =DINO_Y
    LDRH R1, [R1]
    LDR R3, =DINO_CHARACTER
    BL DRAW_RLE_IMAGE

    LDR R0, =OB1_X
    LDRH R0, [R0]
    LDR R1, =OB1_Y
    LDRH R1, [R1]
    MOV R3, #1
    LDR R4, =OB1_H
    LDRH R4, [R4]
    MOV R5, #0x0E70
    LDR R6, =OB1_ACTIVE
    LDRB R6,[R6]
    CMP R6, #1
    BNE DINO_CHECK_OB2
    BL DRAW_RECT

DINO_CHECK_OB2
    LDR R0, =OB2_X
    LDRH R0, [R0]
    LDR R1, =OB2_Y
    LDRH R1, [R1]
    MOV R3, #1
    LDR R4, =OB2_H
    LDRH R4, [R4]
    MOV R5, #0x0E70
    LDR R6, =OB2_ACTIVE
    LDRB R6,[R6]
    CMP R6, #1
    BNE END_GAME5_FUN
    BL DRAW_RECT
END_GAME5_FUN
    POP {R0-R12, LR}
    BX LR
    ENDFUNC
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
    LTORG
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
    LTORG
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
    ldr r1, =250
    cmp r0, r1                  ; Compare difference with 250 ms
    BLS.W skip_toggle              ; If <= 250 ms, skip the toggle
	ldr r4, =btn1_last_handled_time
	str r2, [r4]
	; ISR logic starts here:
    LDR R0, =ACTIVE_GAME ; Load the active game variable address
    LDRB R11, [R0] ; Load the active game variable value
    CMP R11, #0
    BEQ MENU_INT0_HANDLER
    CMP R11, #1
    BEQ GAME1_INT0_HANDLER
    CMP R11, #2
    BEQ GAME2_INT0_HANDLER
    CMP R11, #3
    BEQ GAME3_INT0_HANDLER
    CMP R11, #4
    BEQ GAME4_INT0_HANDLER
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
    CMP R2, #5 ; Check if it was the last game in the first row (4)
    BEQ GO_SECOND_ROW
    CMP R2, #9 ; Check if it was the last game in the second row (8)
    BEQ GO_FIRST_ROW
    ; If both weren't the case stay in the same row
    LDR R1, =HOVERED_GAME_X ; Load X coordinate of hovered game
    LDR R2, [R1] ; Get X coordinate
    ADD R2, R2, #120 ; Add 120 to X coordinate for next game
    STR R2, [R1]
    BL DRAW_MENU ; Call DRAW_MENU to update the screen
    B skip_toggle

GO_SECOND_ROW
    LDR R1, =HOVERED_GAME_X
    MOV R2, #2 ; Reset X coordinate to first game
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
; ##########Start Game1 Handler##########
GAME1_INT0_HANDLER
    LDR R0, =PONG_state
    LDRB R1, [R0]
    CMP R1, #1
    BNE skip_toggle
    LDR R2, =PONG_GAME_MODE
    MOV R3, #1 ; Multiplayer mode
    STRB R3, [R2]
    MOV R1, #2
    STRB R1, [R0] ; Game on
    LDR R0, =PONG_bg_color
    BL FILL_SCREEN
    BL DRAW_FULL_BATS
    B skip_toggle
; ##########END Game1 Handler##########
; ##########Start Game2 Handler##########
GAME2_INT0_HANDLER
    LDR R0, =MAZE_GAME_STATE
    LDRB R1, [R0]
    CMP R1, #0
    BNE skip_toggle
    BL DRAW_MAZE_PATH_BLOCK ; Draw the path block
    BL MAZE_MOVE_RIGHT
    BL DRAW_MAZE_PLAYER ; Draw the player block
    BL MAZE_CHECK_WIN_CONDITION
    LDR R0, =MAZE_GAME_STATE
    LDRB R1, [R0]
    CMP R1, #1
    BLEQ GAME2_WIN
    B skip_toggle
; ##########END Game2 Handler##########
;###########Start Game3 Handler##########
GAME3_INT0_HANDLER
	LDR R0, =INPUT_BUFFER
	LDRB R0, [R0]
	CMP R0, #1
	BEQ skip_toggle
	LDR R0, =SNAKE_GAME_OVER
	LDRB R0, [R0]
	CMP R0, #1
	BEQ skip_toggle
	BL SNAKE_GO_RIGHT
	LDR R0, =INPUT_BUFFER
	MOV R1, #1
	STRB R1, [R0]
    B skip_toggle
;##########END Game3 Handler############
;##########Start Game4 Handler############
GAME4_INT0_HANDLER
    LDR R3, =GAME_STATUS
    LDRB R3, [R3]
    CMP R3, #0
    BNE skip_toggle
    LDR R3, =ACTIVE_CELL
    LDRB R3, [R3]
    LDR R7, =XO_BCK_COLOR
    BL XO_DRAW_CELL
    BL XO_INC_HOVER
    LDR R3, =ACTIVE_CELL
    LDRB R3, [R3]
    LDR R7, =XO_HOVER_COLOR
    BL XO_DRAW_CELL
    B skip_toggle
;##########END Game4 Handler############
skip_toggle
    pop {r0-r5, lr}          ; Restore registers
    bx lr                     ; Return from interrupt
	ENDP
    LTORG

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
    ldr r1, =250
    cmp r0, r1                  ; Compare difference with 250 ms
    BLS.W skip_toggle1              ; If <= 250 ms, skip the toggle
	ldr r4, =btn2_last_handled_time
	str r2, [r4]
	; ISR logic starts here:
    LDR R0, =ACTIVE_GAME ; Load the active game variable address
    LDRB R11, [R0] ; Load the active game variable value
    CMP R11, #0x0
    BEQ MENU_INT1_HANDLER
    CMP R11, #1
    BEQ GAME1_INT1_HANDLER
    CMP R11, #2
    BEQ GAME2_INT1_HANDLER
    CMP R11, #3
    BEQ GAME3_INT1_HANDLER
    CMP R11, #4
    BEQ.W GAME4_INT1_HANDLER
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
    CMP R2, #4 ; Check if it was the first game in the second row (index 5)
    BEQ GO_END_FIRST_ROW
    ; If both weren't the case stay in the same row
    LDR R1, =HOVERED_GAME_X ; Load X coordinate of hovered game
    LDR R2, [R1] ; Get X coordinate
    SUBS R2, R2, #120 ; Subtract 120 to X coordinate for next game
    STR R2, [R1]
    BL DRAW_MENU ; Call DRAW_MENU to update the screen
    B skip_toggle1

GO_END_SECOND_ROW
    LDR R1, =HOVERED_GAME
    MOV R0, #8
    STR R0, [R1] ; Set hovered game to the last game in the second row
    LDR R1, =HOVERED_GAME_X
    MOV R2, #362 ; X Coordinate to last game
    STR R2, [R1]
    LDR R1, =HOVERED_GAME_Y ; Load Y coordinate of hovered game
    MOV R2, #192 ; Go to the second row
    STR R2, [R1]
    BL DRAW_MENU
    B skip_toggle1
GO_END_FIRST_ROW
    LDR R1, = HOVERED_GAME_X
    MOV R2, #362 ; X Coordinate to last game
    STR R2, [R1]
    LDR R1, =HOVERED_GAME_Y ; Load Y coordinate of hovered game
    MOV R2, #52 ; Go to the second row
    STR R2, [R1]
    BL DRAW_MENU
    B skip_toggle1
; ##########END Main Menu Handler##########
GAME1_INT1_HANDLER
    LDR R0, =PONG_state
    LDRB R1, [R0]
    CMP R1, #1
    BNE skip_toggle
    LDR R2, =PONG_GAME_MODE
    MOV R3, #0 ; Singleplayer mode
    STRB R3, [R2]
    MOV R1, #2
    STRB R1, [R0] ; Game on
    LDR R0, =PONG_bg_color
    BL FILL_SCREEN
    BL DRAW_FULL_BATS
    B skip_toggle1
; ##########END Game1 Handler##########
; ##########Start Game2 Handler##########
GAME2_INT1_HANDLER
    LDR R0, =MAZE_GAME_STATE
    LDRB R1, [R0]
    CMP R1, #0
    BNE skip_toggle1
    BL DRAW_MAZE_PATH_BLOCK ; Draw the path block
    BL MAZE_MOVE_LEFT
    BL DRAW_MAZE_PLAYER ; Draw the player block
    B skip_toggle1
; ##########END Game2 Handler##########
;###########Start Game3 Handler##########
GAME3_INT1_HANDLER
	LDR R0, =INPUT_BUFFER
	LDRB R0, [R0]
	CMP R0, #1
	BEQ skip_toggle1
	LDR R0, =SNAKE_GAME_OVER
	LDRB R0, [R0]
	CMP R0, #1
	BEQ skip_toggle1
	BL SNAKE_GO_LEFT
	LDR R0, =INPUT_BUFFER
	MOV R1, #1
	STRB R1, [R0]
    B skip_toggle1
;##########END Game3 Handler############
;##########Start Game4 Handler############
GAME4_INT1_HANDLER
    LDR R3, =GAME_STATUS
    LDRB R3, [R3]
    CMP R3, #0
    BNE skip_toggle1
    LDR R3, =ACTIVE_CELL
    LDRB R3, [R3]
    LDR R7, =XO_BCK_COLOR
    BL XO_DRAW_CELL
    BL XO_DEC_HOVER
    LDR R3, =ACTIVE_CELL
    LDRB R3, [R3]
    LDR R7, =XO_HOVER_COLOR
    BL XO_DRAW_CELL
    B skip_toggle1
;##########END Game4 Handler############
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
    ldr r1, =250
    cmp r0, r1                  ; Compare difference with 250 ms
    BLS.W skip_toggle2             ; If <= 50 ms, skip the toggle
	ldr r4, =btn3_last_handled_time
	str r2, [r4]
	; ISR logic starts here:
    LDR R0, =ACTIVE_GAME ; Load the active game variable address
    LDRB R11, [R0] ; Load the active game variable value
    CMP R11, #0
    BEQ MENU_INT2_HANDLER
    CMP R11, #1
    BEQ GAME1_INT2_HANDLER
    CMP R11, #2
    BEQ GAME2_INT2_HANDLER
    CMP R11, #3
    BEQ GAME3_INT2_HANDLER
    CMP R11, #4
    BEQ.W GAME4_INT2_HANDLER
    CMP R11, #5
    BEQ.W GAME5_INT2_HANDLER
    CMP R11, #6
    BEQ.W GAME6_INT2_HANDLER
	B skip_toggle2
    ; ##########Start Main Menu Handler##########
MENU_INT2_HANDLER
    LDR R1, =HOVERED_GAME ; Load Hovered Game Number
    LDR R11, [R1] ; Store game number in R11 for context switching
    LDR R0, =ACTIVE_GAME ; Load the active game variable address
    STRB R11, [R0] ; Set the active game variable to the hovered game
    BL RESET_MENU ; Reset the menu before switching games
	MOV R0, #0x0000
	BL FILL_SCREEN
    CMP R11, #1
    BEQ RESET_PONG_LBL
    CMP R11, #2
    BEQ RESET_MAZE_LBL
    CMP R11, #3
    BEQ RESET_SNAKE_LBL
    CMP R11, #4
    BEQ RESET_XO_LBL
    CMP R11, #5
    BEQ RESET_AIM_LBL
    CMP R11, #6
    BEQ RESET_DINO_LBL
RESET_PONG_LBL
    BL PONG_RESET ; Reset the game
    B skip_toggle2
RESET_MAZE_LBL
    BL MAZE_RESET ; Reset the game
    BL DRAW_GAME2 ; Draw the maze
    B skip_toggle2
RESET_SNAKE_LBL
    LDR R0, =SysTick_BASE
    LDR R1, =SysTick_CURRENT_VALUE_OFFSET
    ADD R0, R0, R1
    LDR R1, [R0]
    LDR R0, =SNAKE_prng_state
    STR R1, [R0] ; Store the current SysTick value in the PRNG state variable
    
    BL SNAKE_RESET
    
	LDR R0, =LAST_DRAW_TIME
	MOV R1, #0
	STRH R1, [R0]
	
    MOV R0, #0xFFE0
    BL FILL_SCREEN
    B skip_toggle2
RESET_XO_LBL
    BL XO_INIT_GAME
    BL DRAW_GAME4
    B skip_toggle2

RESET_AIM_LBL
    LDR R0, =AIM_PRNG_STATE
    LDR R1, =sys_time
    LDR R1, [R1]
    STR R1, [R0]
    BL AIM_RESET
    B skip_toggle2
RESET_DINO_LBL
    BL DINO_RESET
    B skip_toggle2
    ;###########End Main Menu Handler###########
GAME1_INT2_HANDLER

    B skip_toggle2
; ##########Start Game2 Handler##########
GAME2_INT2_HANDLER
    LDR R0, =MAZE_GAME_STATE
    LDRB R1, [R0]
    CMP R1, #0
    BNE.W skip_toggle2
    BL DRAW_MAZE_PATH_BLOCK ; Draw the path block
    BL MAZE_MOVE_UP
    BL DRAW_MAZE_PLAYER ; Draw the player block
    B skip_toggle2
; ##########END Game2 Handler##########
; ##########Start Game3 Handler##########
GAME3_INT2_HANDLER
	LDR R0, =INPUT_BUFFER
	LDRB R0, [R0]
	CMP R0, #1
	BEQ.W skip_toggle2
	LDR R0, =SNAKE_GAME_OVER
	LDRB R0, [R0]
	CMP R0, #1
	BEQ.W skip_toggle2
    BL SNAKE_GO_UP
	LDR R0, =INPUT_BUFFER
	MOV R1, #1
	STRB R1, [R0]
	B skip_toggle2
; ##########END Game3 Handler##########
; ##########Start Game4 Handler##########
GAME4_INT2_HANDLER
    LDR R0, =GAME_STATUS
    LDRB R0, [R0]
    CMP R0, #3
    BEQ.W XO_DRAW_RESET
    CMP R0, #0
    BNE.W skip_toggle2
    LDR R2, =CurrentPlayer
    LDRB R2, [R2]
    CMP R2, #1
    BEQ DRAW_X_PLAYER
    BL CHECK_DRAW_O
	LDR R7, =XO_BCK_COLOR
	BL XO_DRAW_CELL
    LDR R0, =ACTIVE_CELL
    LDRB R0, [R0]
    ; Calculate Start X
    MOV R1, #3
    BL MODULO
    MOV R1, #110
    MUL R0, R1, R2
    ADD R0, R0, #80
    ADD R6, R0, #50
    ; Calculate Start Y
    LDR R1, =ACTIVE_CELL
    LDRB R1, [R1]
    MOV R8, #3
    UDIV R4, R1, R8
    MOV R2, #110
    MUL R1, R2, R4
    ADD R7, R1, #50
    MOV R8, #45
    LDR R9, =XO_O_COLOR
    BL DRAW_CIRCLE
    MOV R8, #42
    LDR R9, =XO_BCK_COLOR
    BL DRAW_CIRCLE
    BL CHECK_WINNING
    LDR R0, =GAME_STATUS
    LDRB R0, [R0]
    CMP R0, #2
    BEQ PLAYER_O_WIN
    CMP R0, #3
    BEQ XO_GAME_DRAW_LBL
    BL XO_INC_HOVER
    LDR R7, =XO_HOVER_COLOR
    BL XO_DRAW_CELL
    B skip_toggle2
DRAW_X_PLAYER
    BL CHECK_DRAW_X
    LDR R0, =ACTIVE_CELL
    LDRB R0, [R0]
    ; Calculate Start X
    MOV R1, #3
    BL MODULO
    MOV R1, #110
    MUL R0, R1, R2
    ADD R0, R0, #80
    ADD R0, R0, #5
	LDR R7, =XO_BCK_COLOR
	BL XO_DRAW_CELL
    ; Calculate Start Y
    LDR R1, =ACTIVE_CELL
    LDRB R1, [R1]
    MOV R8, #3
    UDIV R4, R1, R8
    MOV R2, #110
    MUL R1, R2, R4
    ADD R1, R1, #5
    MOV R4, #4
    LDR R9, =XO_X_COLOR
    BL DRAW_X
    BL CHECK_WINNING
    LDR R0, =GAME_STATUS
    LDRB R0, [R0]
    CMP R0, #1
    BEQ PLAYER_X_WIN
    CMP R0, #3
    BEQ XO_GAME_DRAW_LBL
    BL XO_INC_HOVER
    LDR R7, =XO_HOVER_COLOR
    BL XO_DRAW_CELL
    B skip_toggle2
PLAYER_O_WIN
    MOV R0, #0x07E0
    BL FILL_SCREEN
    BL DRAW_PLAYER_O_WIN
    B skip_toggle2
PLAYER_X_WIN
    MOV R0, #0x07E0
    BL FILL_SCREEN
    BL DRAW_PLAYER_X_WIN
    B skip_toggle2
XO_GAME_DRAW_LBL
    BL XO_GAME_DRAW
    B skip_toggle2
XO_DRAW_RESET
    BL XO_INIT_GAME
    BL DRAW_GAME4
    B skip_toggle2
; ##########END Game4 Handler##########
; ##########Start Game5 Handler##########
GAME5_INT2_HANDLER
    LDR R0, =AIM_GAME_STATE
    LDRB R0, [R0]
    CMP R0, #0
    BNE skip_toggle2
    LDR R5, =AIM_BCK
    BL DRAW_AIM_OBJS
    BL DRAW_AIM_CURSOR
    LDR R0, =AIM_PRNG_STATE
    LDR R1, =sys_time
    LDR R1, [R1]
    STR R1, [R0]
    BL AIM_SHOOT
    LDR R5, =AIM_OBJ_COLOR
    BL DRAW_AIM_OBJS
    LDR R5, =AIM_CURSOR_COLOR
    BL DRAW_AIM_CURSOR
    B skip_toggle2
; ##########END Game5 Handler##########
; ##########Start Game6 Handler##########
GAME6_INT2_HANDLER
    LDR R0, =DINOSTATE_INPUT
    MOV R1, #1
    STRB R1, [R0]
    B skip_toggle2
; ##########END Game6 Handler##########


skip_toggle2
    pop {r0-r5, lr}          ; Restore registers
    bx lr                     ; Return from interrupt
	ENDP
    LTORG
EXTI3_IRQHandler PROC ; Down button handler

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
    ldr r1, =250
    cmp r0, r1                  ; Compare difference with 250 ms
    bls skip_toggle3              ; If <= 50 ms, skip the toggle
	ldr r4, =btn4_last_handled_time
	str r2, [r4]
	; ISR logic starts here:
    LDR R11, =ACTIVE_GAME ; Load the active game variable address
	LDRB R11, [R11]
    CMP R11, #2
    BEQ GAME2_INT3_HANDLER
    CMP R11, #3
    BEQ GAME3_INT3_HANDLER
    B skip_toggle3
; ##########Start Game2 Handler##########
GAME2_INT3_HANDLER
    LDR R0, =MAZE_GAME_STATE
    LDRB R1, [R0]
    CMP R1, #0
    BNE skip_toggle3
    BL DRAW_MAZE_PATH_BLOCK ; Draw the path block
    BL MAZE_MOVE_DOWN
    BL DRAW_MAZE_PLAYER ; Draw the player block
    BL MAZE_CHECK_WIN_CONDITION
    LDR R0, =MAZE_GAME_STATE
    LDRB R1, [R0]
    CMP R1, #1
    BLEQ GAME2_WIN
    B skip_toggle3
; ##########END Game2 Handler##########
; ##########Start Game3 Handler##########
GAME3_INT3_HANDLER
	LDR R0, =INPUT_BUFFER
	LDRB R0, [R0]
	CMP R0, #1
	BEQ skip_toggle3
	LDR R0, =SNAKE_GAME_OVER
	LDRB R0, [R0]
	CMP R0, #1
	BEQ skip_toggle3
	BL SNAKE_GO_DOWN
	LDR R0, =INPUT_BUFFER
	MOV R1, #1
	STRB R1, [R0]
    B skip_toggle3
; ##########END Game3 Handler##########
skip_toggle3
    pop {r0-r5, lr}          ; Restore registers
    bx lr                     ; Return from interrupt
	ENDP

EXTI9_5_IRQHandler PROC ; Escape button handler
    ldr r0, =EXTI_BASE      ; EXTI base address
    ldr r1, =EXTI_PR_OFFSET        ; EXTI_PR offset
    add r0, r0, r1            ; Calculate EXTI_PR address
    mov r1, #0x20             ; Bit mask for EXTI3
    str r1, [r0]              ; Clear the pending bit for EXTI0
	; Debouncing logic
    ldr r2, =sys_time            ; Address of sys_time
    ldr r2, [r2]                 ; r2 = current sys_time
    ldr r3, =btn5_last_handled_time   ; Address of last_handled_time
    ldr r3, [r3]                 ; r3 = last_handled_time
    subs r0, r2, r3              ; r0 = sys_time - last_handled_time
    ldr r1, =250
    cmp r0, r1                  ; Compare difference with 250 ms
    bls skip_toggle95              ; If <= 250 ms, skip the toggle
	ldr r4, =btn5_last_handled_time
	str r2, [r4]
	; ISR logic starts here:
    ; LDR R11, =ACTIVE_GAME ; Load the active game variable address
	; LDRB R11, [R11]
    LDR R11, =ACTIVE_GAME
    MOV R1, #0
    STRB R1, [R11]
    BL RESET_MENU
    MOV R0, #0
    BL FILL_SCREEN
    BL DRAW_MENU
	B skip_toggle95
skip_toggle95
    LDR   R0, =MAIN_LOOP + 1
    STR   R0, [SP, #24] ; Store the address of MAIN_LOOP in the to-be-popped pc value
    LDR   LR, =0xFFFFFFF9
    BX LR
    ENDP
SysTick_Handler PROC
    PUSH    {R0, R1, LR}            ; Save registers
	LDR     R0, =sys_time    ; Load address of my_variable
	LDR     R1, [R0]            ; Load current value of my_variable
	ADD     R1, R1, #1          ; Increment value by 1
	STR     R1, [R0]            ; Store updated value back to my_variable
	LDR R0, =LAST_DRAW_TIME
	LDRH R1, [R0]
	ADD R1, R1, #1
	STRH R1, [R0]
    LDR     R0, =ACTIVE_GAME ; Load the active game variable address
    LDRB    R11, [R0] ; Load the active game variable value
    CMP     R11, #2
    BEQ     GAME2_SYSTICK_HANDLER
    CMP R11, #5
    BEQ     GAME5_SYSTICK_HANDLER
    B SYSTICK_END
GAME2_SYSTICK_HANDLER
    LDR R0, =MAZE_GAME_STATE
    LDRB R1, [R0] ; Load the game state
    CMP R1, #0 ; Check if the game is running
    BNE SYSTICK_END ; If lost, skip the timer decrement
    LDR R0, =MAZE_SECOND_TIMER
    LDRH R1, [R0] ; Load the second timer value
    CMP R1, #0
    BEQ GAME2_DECREMENT_TIMER
    SUB R1, R1, #1 ; Decrement the second timer value
    STRH R1, [R0] ; Store the updated value back to the second timer
    B SYSTICK_END
GAME2_DECREMENT_TIMER
    BL GAME2_UPDATE_TIME
    MOV R1, #0x3E7
    STRH R1, [R0] ; Reset the second timer to 999 (0x3E7)
    LDR R0, =MAZE_TIMER_SECOND
    LDRB R1, [R0] ; Load the timer value
    CMP R1, #0
    BEQ GAME2_DECREMENT_MINUTE
    SUB R1, R1, #1 ; Decrement the timer value
    STRB R1, [R0] ; Store the updated value back to the timer
    B SYSTICK_END
GAME2_DECREMENT_MINUTE
    BL GAME2_UPDATE_TIME
    MOV R1, #59
    STRB R1, [R0] ; Reset the timer to 60 (1 minute)
    LDR R0, =MAZE_TIMER_MINUTE
    LDRB R1, [R0] ; Load the minute value
    CMP R1, #0
    BEQ GAME2_LOSE
    SUB R1, R1, #1 ; Decrement the minute value
    STRB R1, [R0] ; Store the updated value back to the minute
    B SYSTICK_END
GAME2_LOSE
    LDR R0, =MAZE_GAME_STATE
    MOV R1, #2 ; Set the game state to lost
    STRB R1, [R0] ; Store the updated value back to the game state
    BL GAME2_LOST ; Call the game lost function
    B SYSTICK_END

GAME5_SYSTICK_HANDLER
    LDR R0, =AIM_GAME_STATE
    LDRB R1, [R0] ; Load the game state
    CMP R1, #0 ; Check if the game is running
    BNE SYSTICK_END ; If lost, skip the timer decrement
    LDR R0, =AIM_SECOND_TIMER
    LDRH R1, [R0]
    CMP R1, #0
    BEQ GAME5_DEC_TIM
    SUB R1, R1, #1
    STRH R1, [R0]
    B SYSTICK_END
GAME5_DEC_TIM
	LDR R0, =AIM_SECOND_TIMER
	LDR R1, =999
	STRH R1, [R0]
    LDR R0, =AIM_TIMER
    LDRB R1, [R0] ; Load the second timer value
    CMP R1, #0
    BEQ GAME5_OVER
    SUB R1, R1, #1 ; Decrement the second timer value
    STRB R1, [R0] ; Store the updated value back to the second timer
    B SYSTICK_END
GAME5_OVER
    LDR R0, =AIM_GAME_STATE
    MOV R1, #1
    STRB R1, [R0] ; Update the game state
    LDR R0, =AIM_SCORE_TIMER_COLOR
    LDR R1, =0xF800
    STRH R1, [R0]
    BL AIM_DRAW_SCORE
    BL DRAW_GAME5_TIM
    B SYSTICK_END
SYSTICK_END
	POP     {R0, R1,LR}            ; Restore registers
	bx lr
	ENDP
    LTORG

; ADC INTERUPT (PLEASE WORK PLEASSSEEE)
ADC1_2_IRQHandler PROC
    PUSH {R0-R12, LR}
    LDR R0, =ADC1_BASE
    LDR R1, =ADC1_SR_OFFSET
    ADD R0, R0, R1
    MOV R1, #2
    STR R1, [R0] ; Clear EOC
    
    LDR R0, =ADC1_BASE
    LDR R1, =ADC1_DR_OFFSET
    ADD R0, R0, R1
    LDR R1, [R0]
    LDR R0, =JOYSTICK_X_VALUE
    STRH R1, [R0]
EOC_WAIT_LOOP
    LDR R0, =ADC1_BASE
    LDR R1, =ADC1_SR_OFFSET
    ADD R0, R0, R1
    LDR R1, [R0]
    TST R1, #2
    BEQ EOC_WAIT_LOOP

    LDR R0, =ADC1_BASE
    LDR R1, =ADC1_SR_OFFSET
    ADD R0, R0, R1
    MOV R1, #2
    STR R1, [R0] ; Clear EOC
    LDR R0, =JOYSTICK_Y_VALUE
    STRH R1, [R0]

ADC1_2END
    POP {R0-R12, LR}
    BX LR
    ENDP
;================================================END INTERRUPT HANDLER=================================================
	END
;========================================================END========================================================