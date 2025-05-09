    AREA DINOVARS, DATA, READWRITE
    ;##########################DINO
    DINOSTATE  DCB 0
    DINO_X  DCW 0
    DINO_Y  DCW 0
    DINO_W DCW 0
    DINO_H DCW 0
    DINO_JUMPING_STATE DCB 0
    DINO_LAST_JUMP_CHANGE DCW 0
    ;##########################Obstacle 1
    OB1_TYPE DCB 0
    OB1_ACTIVE DCB 0
    OB1_X DCW 0
    OB1_Y DCW 0
    ;##########################Obstacle 1
    OB2_TYPE DCB 0
    OB2_ACTIVE DCB 0
    OB2_X DCW 0
    OB2_Y DCW 0
    ;##########################Obstacle 3
    OB3_TYPE DCB 0
    OB3_ACTIVE DCB 0
    OB3_X DCW 0
    OB3_Y DCW 0
    ALIGN
 ; TODO: update constant values
    AREA DINOCONST, DATA, READONLY
    CAC_W DCW 0
    CAC_H DCW 0
    BIRD_W DCW 0
    BIRD_H DCW 0
    ALIGN

    IMPORT sys_time
    EXPORT DINO_DEFINE_OB_TYPE
    AREA DINOCODE, CODE, READONLY
; R4 has the object address
DINO_DEFINE_OB_TYPE FUNCTION
    PUSH {R0-R3, LR}
    LDR R0, =sys_time ; Get the address of sys_time
    LDR R0, [R0] ; Load the value of sys_time
    UDIV R3, R0, #2
    MUL R4, R3, #2
    SUB R3, R0, R4 ; R3 => contains Modulus
    CMP R3, #0
    BEQ CHOOSE_BIRD
    MOV R2, #1 ; 1 is a cactus
    STR R2, [R4]
    B END_DINO_DEFINE_OB
CHOOSE_BIRD
    MOV R2, #0 ; 0 is bird
    STR R2, [R4]
END_DINO_DEFINE_OB

    POP {R0-R3, LR}
    BX LR
    ENDFUNC
    END