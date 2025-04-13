//.section vectors, "a"
//.word 0x20005000 //SRAM TOP
//.word Reset_Handler
// TODO: write the ISRs for the EXTI0 to EXTI3 interrupts as dummy functions
.include "hal.s"
.include "macros.s"

.section .text
.global main
main:
bl _init
bl _main

_init:
    push {r0-r12, lr}  // Save registers
    // Initialize the stack pointer
    ;ldr sp, =0x20001000  // TODO: Set stack pointer to top of RAM
    ;#################################Select system Clock Source#######################################
    // Enable HSI clock
    ldr r0, =RCC_BASE
    ldr r1 , =RCC_CR_OFFSET
    add r0, r0, r1  // Read RCC_CR
    orr r1, r1, #0x01  // Set HSION bit to enable HSI clock
    str r1, [r0]  // Write back to RCC_CR
    WAIT_HSI: ldr r1, [r0]    // Read RCC_CR again
    AND r1, #0x02  // Check if HSIRDY bit is set
    CMP r1, #0  // Compare with 0x02
    BEQ WAIT_HSI  // Wait until HSI is ready
    // Select HSI as PLL source Set PLL multiplication factor to 8
    ldr r0, =RCC_BASE
	ldr r1, =RCC_CFGR_OFFSET
    add r0, r0 , r1
    ldr r1, [r0]  // Read RCC_CFGR
    and r1, r1, #0xFFFEFFFF  // Select HSI as PLL source (clear PLLSRC bit)
    orr r1, r1, #0x380000  // Set PLLMUL[3:0] to 0x0F (16x)
    str r1, [r0]  // Write back to RCC_CFGR
    // Enable PLL
    ldr r0, =RCC_BASE
    ldr r1 , =RCC_CR_OFFSET
    add r0, r0, r1  // Read RCC_CR
    ldr r1, [r0]  // Read RCC_CR again
    orr r1, r1, #0x1000000 ; // Set PLLON bit to enable PLL
    str r1, [r0]  // Write back to RCC_CR
    WAIT_PLL: ldr r1, [r0]    // Read RCC_CR again
    AND r1, #0x2000000  // Check if PLLRDY bit is set
    CMP r1, #0 
    BEQ WAIT_PLL  // Wait until PLL is ready
    ldr r0, =RCC_BASE
    ldr r1, =RCC_CFGR_OFFSET
    add r0, r0 , r1
    ldr r1, [r0]  // Read RCC_CFGR
    orr r1, r1, #0x02  // Set SW[1:0] to select PLL as system clock
    str r1, [r0]  // Write back to RCC_CFGR
    WAIT_SWS: ldr r1, [r0]    // Read RCC_CFGR again
    AND r1, #0x08  // Check if SWS[1:0] is set to 0x02 (PLL)
    CMP r1, #0  // Compare with 0x0C
    BEQ WAIT_SWS  // Wait until PLL is selected as system clock
    ;##################################End Select System Clock Source#######################################
    ;#################################Enable GPIOA, GPIOB & AFIO Clocks#######################################
    ldr r0, =RCC_BASE
    ldr r1, =RCC_APB2ENR_OFFSET
    add r0, r0, r1
    ldr r1, [r0]  // Read RCC_APB2ENR 
    orr r1, r1, #0x0D  // Enable GPIOA, GPIOB & AFIO clock
    str r1, [r0]  // Write back to RCC_APB2ENR
    ;##################################End Enable GPIOA, GPIOB & AFIO Clocks#######################################
    ;#################################Configure GPIOA and GPIOB#######################################
    // Configure GPIOA (PA0 through PA-8) as output, we need 12 bit (LCD_RST, LCD_CS, LCD_RS, LCS_WR, LCDD0-7)
    // Lower 8 pins are defined here and will be used as Data pins for the LCD
    ldr r0, =GPIOA_BASE
    ldr r1, =GPIOx_CRL_OFFSET
    add r0, r0, r1
    ldr r1, #0x33333333  // Set mode to output 50MHz, push-pull for PA0-PA7
    str r1, [r0]  // Write to GPIOA_CRL
    // Define the LSB of the 4 higher pins for the LCD functios (RST, CS, RS, WR) => Can be expanded later if we read the LCD or use SD card
    ldr r0, =GPIOA_BASE
    ldr r1, =GPIOx_CRH_OFFSET
    add r0, r0, r1
    ldr r1, #0x3333 // Set mode to output 50MHz, push-pull for PA8-PA11
    str r1, [r0]  // Write to GPIOA_CRH
    // Configure GPIOB (PB0 through PB3) as input with pull-up/pull-down resistors => this is for the arcade buttons
    ldr r0, =GPIOB_BASE
    ldr r1, =GPIOx_CRL_OFFSET
    add r0, r0, r1
    ldr r1, #0x8888  // Set mode to input with pull-up/pull-down for PB0-PB3
    str r1, [r0]  // Write to GPIOB_CRL
    // Configure the GPIOB input ports with pull-up resistors
    ldr r0, =GPIOB_BASE
    ldr r1, =GPIOx_BSRR_OFFSET
    add r0, r0, r1
    ldr r1, #0x0F // Pull up the 4 LSB bits of GPIOB
    str r1, [r0]  // Write to GPIOB_BSRR
    ;##################################End Configure GPIOA and GPIOB#######################################
    ;#################################Configure NVIC ########################################
    ldr r0, =NVIC_BASE  // Load NVIC base address
    ldr r1, =NVIC_AIRCR_OFFSET  // Load NVIC_AIRCR offset
    add r0, r0, r1  // Calculate NVIC_AIRCR address
    ldr r1, [r0]  // Read NVIC_AIRCR
    orr r1, r1, #0x0200 // Set the priority group to 2 bits for pre-emption and 2 bits for sub-priority
    str r1, [r0]  // Write back to NVIC_AIRCR
    ;#################################End Configure NVIC ########################################
    ;#################################Enable Interrupts for Arcade Buttons#######################################
    // Map EXTI0 to EXTI3 to GPIOB
    ldr r0, =AFIO_BASE
    ldr r1, =AFIO_EXTICR1_OFFSET
    add r0, r0, r1
    ldr r1, [r0]  // Set EXTI0 to EXTI3 to GPIOB
    MOV r2, #0xFFFF
    LSL r2, r2, #16  // Shift left to clear the lower 16 bits
    and r1, r1, r2  // Clear the lower 16 bits
    MOV r2, #0x1111
    orr r1, r1, r2  // Set EXTI0 to EXTI3 to GPIOB
    str r1, [r0]  // Write to AFIO_EXTICR1
    // Unmask EXTI0 to EXTI3 lines' interrupts
    ldr r0, =EXTI_BASE
    ldr r1, =EXTI_IMR_OFFSET
    add r0, r0, r1
    ldr r1, [r0]  // Read EXTI_IMR
    orr r1, r1, 0x0F // Unmask EXTI0 to EXTI3
    str r1, [r0]  // Write to EXTI_IMR
    // Enable interrupt on falling edge for EXTI0 to EXTI3 lines, since arcade buttons' pins are pulled-up
    ldr r0, =EXTI_BASE
    ldr r1, =EXTI_FTSR_OFFSET
    add r0, r0, r1
    ldr r1, [r0] // Read EXTI_FTSR
    orr r1, r1, 0x0F // Enable falling edge trigger for EXTI0 to EXTI3
    str r1, [r0]  // Write to EXTI_FTSR
    // Enable NVIC interrupts for EXTI0 to EXTI3 lines
    // Enable NVIC interrupts for EXTI0 to EXTI3 lines
    ldr r0, =NVIC_BASE  // Load NVIC base address
    ldr r1, =NVIC_ISER_ONE_OFFSET  // Load NVIC_ISER0 offset
    add r0, r0, r1  // Calculate NVIC_ISER0 address
    ldr r1, [r0]  // Read NVIC_ISER0
    orr r1, r1, #0x03C0  // Enable interrupts for EXTI0 to EXTI3, ISER0 bits 6 - 9
    str r1, [r0]  // Write back to NVIC_ISER0
    // Set the preemption priority and subpriority for EXTI0 to EXTI3 interrupts
    ldr r0, =NVIC_BASE  // Load NVIC base address
    ldr r1, =NVIC_IPR_TWO_OFFSET  // Load NVIC_IPR2 offset
    add r0, r0, r1  // Calculate NVIC_IPR2 address
    ldr r1, [r0]  // Read NVIC_IPR2
    orr r1, r1, #0x10000000 // Set the priority for EXTI1 & EXTI0 (Premrption to 0, sub priority of EXTI1 is 1 and EXTI0 is 0, lower priority number means higher priority)
    str r1, [r0]  // Write back to NVIC_IPR2
    ldr r0, =NVIC_BASE  // Load NVIC base address
    ldr r1, =NVIC_IPR_THREE_OFFSET  // Load NVIC_IPR2 offset
    add r0, r0, r1  // Calculate NVIC_IPR3 address
    ldr r1, [r0]  // Read NVIC_IPR3
    MOV r2, #0x3020
    orr r1, r1, r2 // Set the priority for EXTI3 & EXTI2 (Premrption to 0, sub priority of EXTI3 is 3 and EXTI2 is 2)
    str r1, [r0]  // Write back to NVIC_IPR3
    ;#################################End Enable Interrupts for Arcade Buttons#######################################
    pop {r0-r12, lr}
    bx lr