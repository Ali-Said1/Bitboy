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
    orr r1, r1, #0x1C0000  // Set PLLMUL[3:0] to 0x04 (8x)
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
    pop {r0-r12, lr}
    bx lr