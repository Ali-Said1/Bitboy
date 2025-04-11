    .macro delay_cycle count
    mov     r1, #\count
1:
    subs    r1, r1, #1
    bne     1b
    .endm