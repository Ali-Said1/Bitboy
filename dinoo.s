    IMPORT sys_time
    AREA DINOCONST, DATA, READONLY
    EXPORT DINO_CAC_W
    EXPORT DINO_CAC_H
    EXPORT DINO_BIRD_W
    EXPORT DINO_BIRD_H
DINO_CAC_W          EQU      40
DINO_CAC_H          EQU      60
DINO_BIRD_W         EQU      40
DINO_BIRD_H         EQU      20
DINO_GROUND_Y       EQU      280
DINO_START_X        EQU      20
DINO_START_Y        EQU      180
DINO_NORMAL_DINO_H  EQU      100
DINO_CROUCH_DINO_H  EQU      50
DINO_OBSTACLE_VELOCITY EQU   100
    AREA DINOVARS, DATA, READWRITE
    
    ;##########################DINO
    EXPORT DINOSTATE
    EXPORT DINO_X
    EXPORT DINO_Y
    EXPORT DINO_W
    EXPORT DINO_H
    EXPORT LAST_SPAWN_TIME
	EXPORT DINO_VELOCITY
    EXPORT OB1_TYPE
    EXPORT OB1_ACTIVE
    EXPORT OB1_X
    EXPORT OB1_Y
    EXPORT OB1_W
    EXPORT OB1_H
    EXPORT OB2_TYPE
    EXPORT OB2_ACTIVE
    EXPORT OB2_X
    EXPORT OB2_Y
    EXPORT OB2_W
    EXPORT OB2_H
    EXPORT OB3_TYPE
    EXPORT OB3_ACTIVE
    EXPORT OB3_X
    EXPORT OB3_Y
    EXPORT OB3_W
    EXPORT OB3_H
	EXPORT JUMP_CONDITION
DINOSTATE  DCB 0 ;0 walking, 1 jumping, ,2 ducking,3 dead
DINO_X  DCW 20
DINO_Y  DCW 180
DINO_W DCW 40
DINO_H DCW 100

LAST_SPAWN_TIME  DCW 0
JUMP_CONDITION DCB 0 ;0 up, 1 down 2 delay

DELAY DCW 20
;##########################Obstacle 1
OB1_TYPE DCB 0
OB1_ACTIVE DCB 0
OB1_X DCW 0
OB1_Y DCW 0
OB1_W DCW 0
OB1_H DCW 0

;##########################Obstacle 2
OB2_TYPE DCB 0
OB2_ACTIVE DCB 0
OB2_X DCW 0
OB2_Y DCW 0
OB2_W DCW 0
OB2_H DCW 0

;##########################Obstacle 3
OB3_TYPE DCB 0
OB3_ACTIVE DCB 0
OB3_X DCW 0
OB3_Y DCW 0
OB3_W DCW 0
OB3_H DCW 0
DINO_PRNG_STATE DCD 0
DINO_VELOCITY DCB 0
ACC          DCB      -2

LAST_SYS_TIME_1 DCD 0
LAST_SYS_TIME_2 DCD 0
LAST_SYS_TIME_MOVE DCD 0

DINO_DELTA_Y DCW 0x0000 ; Δ position in y direction used to accumulate position change, then we take its upper byte to update position
DINO_DELTA_Y_DECIMAL DCW 0x0000 
GAME_OVER_STATE DCB 0x00 
    AREA DINOCODE, CODE, READONLY
	EXPORT DINO_LOOP
    EXPORT DINO_RESET

DINO_RESET FUNCTION
    PUSH {R0-R1, LR}
    ; Initialize dino x
    LDR     R0, =DINO_X
    MOV     R1, #DINO_START_X    ; Initial position
    STRH     R1, [R0]

    ; Initialize dino y
    LDR     R0, =DINO_Y
    MOV     R1, #DINO_START_Y              ; Start with length of 1 (just the head)
    STRH     R1, [R0]

    ; Initialize dino state
    LDR     R0, =DINOSTATE
    MOV     R1, #0
    STRB    R1, [R0]

    ; Initialize GAME_OVER_STATE
    LDR     R0, =GAME_OVER_STATE
    MOV     R1, #0      ; Start moving right
    STRB    R1, [R0]



    ;intialize spawntime
    LDR     R0,=LAST_SPAWN_TIME
    MOV     R1,#0
    STRH    R1,[R0]

    ;intialize dino object width
    LDR     R0,=DINO_W
    MOV     R1,#40 
    STRH    R1,[R0]
    ;intialize dino object height
    LDR     R0,=DINO_H
    MOV     R1,#DINO_NORMAL_DINO_H          
    STRH    R1,[R0]
    ;intialize delay
    LDR     R0,=DELAY
    MOV     R1,#20
    STRH    R1,[R0]

    ;intialize jump condition
    LDR     R0,=JUMP_CONDITION
    MOV     R1,#0
    STRB    R1,[R0]
    POP {R0-R1, LR}
    BX LR
    ENDFUNC
DINO_LOOP FUNCTION
    PUSH {R0-R12, LR}
    BL PROCESS_INPUT
    BL check_for_objects ;spawn objects if needed
    BL move_object ;move Obstacle
    BL check_for_despawn

    LDR R1, =OB1_X
    BL check_collision   
    CMP R3, #0
    BNE GAME_OVER
    
    LDR R1, =OB2_X
    BL check_collision   
    CMP R3, #0
    BNE GAME_OVER
    
    LDR R1, =OB3_X
    BL check_collision
    CMP R3, #0
    BNE GAME_OVER
    
    BL apply_vel_y
	BL UPDATE_VELOCITY
    
    POP {R0-R12, LR}
    BX LR
    ENDFUNC

GAME_OVER FUNCTION
    PUSH {R0, R1, LR}
    LDR     R0, =GAME_OVER_STATE
    MOV     R1, #1
    STRB    R1, [R0]
    POP {R0, R1, LR}
    BX LR
    ENDFUNC

PROCESS_INPUT FUNCTION
    PUSH {R0-R12 , LR}
    CMP R12, #0
    BEQ cond1
    CMP R12, #1
    BEQ cond2
    CMP R12, #2
    BEQ cond3


cond1
    LDR R0,=DINOSTATE
    LDRB R2,[R0]
    CMP R2, #2
    BLEQ UNCROUCH
    B return_input
cond2
    LDR R0,=DINOSTATE
    LDRB R2,[R0]
    CMP R2, #1
    BEQ return_input
    BL UNCROUCH
    BL DINO_JUMP
    B return_input
cond3
    LDR R0,=DINOSTATE
    LDRB R2,[R0]
    CMP   R2, #0
    BNE return_input
    BL DINO_CROUCH
    B return_input

return_input
    POP {R0-R12 , LR}
    BX LR
    ENDFUNC







UPDATE_VELOCITY FUNCTION
    PUSH {R0-R12 , LR}
    LDR R0, =LAST_SYS_TIME_2
    LDR R0, [R0]            ; Load the value of sys_time
    LDR R1, =sys_time
    LDR R1, [R1]            ; Load the value of sys_time
    SUB R1, R1, R0          ;R1 = sys_time - LAST_SYS_TIME_1


    LDR R2,=ACC
    LDRB R2, [R2]            ; Load the value of acc
    SXTB R2, R2
    CMP R2, #0
    BEQ end_update_velocity
    TST   R2, #0x80000000
    MVNNE R2,R2
    ADDNE R2, R2, #1
    MOV R3, #1000
    UDIV R3,R3,R2
    CMP R1, R3
    BLT end_update_velocity
    LDR R0, =DINO_VELOCITY
    LDRH R4, [R0]            ; Load the value of dino_y
    LDR R2,=ACC
    LDRB R2, [R2]            ; Load the value of acc
    SXTB R2, R2
    TST   R2, #0x80000000
    BEQ ACCNEG             ;if ACC is negative
    ADD R4, R4, #1
    LDR R0, =DINO_VELOCITY
    STRH R4, [R0]           ; Update dino_y
	B update_last_sys
ACCNEG
    MVN R2,R2
    ADD R2, R2, #1
    SUB R4, #1
    LDR R0, =DINO_VELOCITY
    STRH R4, [R0]           ; Update dino_y

update_last_sys
	LDR R0,=LAST_SYS_TIME_2
    LDR R2,=sys_time
    LDRH R2,[R2]
    STRH R2,[R0]            ; Update LAST_SYS_TIME_1

end_update_velocity

    
    POP {R0-R12 , LR}
    BX LR
    ENDFUNC


DINO_JUMP FUNCTION
    PUSH {R0-R12 , LR}

    LDR R0,=DINOSTATE
    MOV R2, #1
    STRB R2,[R0]
    LDR R0,=DINO_Y
    MOV R2, #180
    STRH R2,[R0]
    LDR R0,=DINO_H
    MOV R2, #DINO_NORMAL_DINO_H
    STRH R2,[R0]
    ; Set initial velocity and upward acceleration
    LDR R0, =DINO_VELOCITY
    MOV R1, #-50
    STRB R1, [R0]
    LDR R2, =ACC
    MOV R1, #-15
    STRH R1, [R2]

return_to_JUMP_DINO
    POP {R0-R12 , LR}
    BX LR
    ENDFUNC



    
DINO_CROUCH FUNCTION
    PUSH {R0-R2 , LR}
    LDR R0,=DINO_Y
    MOV R2, #230
    STRH R2,[R0]
    LDR R0,=DINO_H
    MOV R2, #DINO_CROUCH_DINO_H
    STRH R2,[R0]
    LDR R0,=DINOSTATE
    MOV R2, #2
    STRB R2,[R0]
return_from_crouch
    POP {R0-R2 , LR}
    BX LR
    ENDFUNC
UNCROUCH FUNCTION
    PUSH {R0-R2 , LR}
    LDR R0,=DINO_Y
    MOV R2, #180
    STRH R2,[R0]
    LDR R0,=DINO_H
    MOV R2, #DINO_NORMAL_DINO_H
    STRH R2,[R0]
    LDR R0,=DINOSTATE
    MOV R2, #0
    STRB R2,[R0]
return_uncrouch
    POP {R0-R2 , LR}
    BX LR
    ENDFUNC
check_for_despawn   FUNCTION
    PUSH {R0-R12, LR}
    LDR R0, =OB1_ACTIVE
    LDRB R1, [R0]           ; Load OB1_ACTIVE
    CMP R1, #1              ; Is OB1 active?
    BNE check_ob2_despawn   ; If not, skip to OB2
    LDR R2, =OB1_X
    LDRH R3, [R2]           ; Load OB1_X
    CMP R3, #0              ; Is OB1_X < 0?
    BGT check_ob2_despawn   ; If not, skip to OB2
    MOV R1, #0
    STRB R1, [R0]           ; Deactivate OB1 (OB1_ACTIVE = 0)

check_ob2_despawn

    LDR R0, =OB2_ACTIVE
    LDRB R1, [R0]           ; Load OB1_ACTIVE
    CMP R1, #1              ; Is OB1 active?
    BNE check_ob3_despawn   ; If not, skip to OB2
    LDR R2, =OB2_X
    LDRH R3, [R2]           ; Load OB1_X
    CMP R3, #0              ; Is OB1_X < 0?
    BGT check_ob3_despawn   ; If not, skip to OB2
    MOV R1, #0
    STRB R1, [R0]           ; Deactivate OB1 (OB1_ACTIVE = 0)

check_ob3_despawn
    LDR R0, =OB3_ACTIVE
    LDRB R1, [R0]           ; Load OB1_ACTIVE
    CMP R1, #1              ; Is OB1 active?
    BNE end_despawn   ; If not, skip to OB2
    LDR R2, =OB3_X
    LDRH R3, [R2]           ; Load OB1_X
    CMP R3, #0              ; Is OB1_X < 0?
    BGT end_despawn   ; If not, skip to OB2
    MOV R1, #0
    STRB R1, [R0]           ; Deactivate OB1 (OB1_ACTIVE = 0)

end_despawn
    POP {R0-R12, LR}
    BX LR
    ENDFUNC

check_for_objects   FUNCTION
    PUSH {R0-R12 , LR}

    
    MOV R0, #0 
    LDR R10, =sys_time  
    LDR R10, [R10]                  ;R10 = sys_time
    LDR R11, =LAST_SPAWN_TIME
    LDRH R11, [R11]                  ;R11 = LAST_SPAWN_TIME
    SUB R11, R10 ,R11                ;R11 = sys_time - LAST_SPAWN_TIME
    MOV R3, #3000
    BL get_random
    MOV R9, #5000
    ADD R9, R0
    CMP R11, R9                      ;if sys_time-LAST_SPAWN_TIME
    BLT end_check_for_objects

    
    LDR R1, =OB1_ACTIVE
    LDRB R1, [R1]
    CMP R1, #0
    BNE check_two  ;if ob1 isnt active spawn one 
    BL spawn_object1  ;if ob1 isnt active spawn one 
    B end_check_for_objects
check_two
    LDR R1, =OB2_ACTIVE
    LDRB R1, [R1]
    CMP R1, #0
    BNE check_three  ;if ob1 isnt active spawn one 
    BL spawn_object2  ;if ob1 isnt active spawn one 
    B end_check_for_objects
check_three
    LDR R1, =OB3_ACTIVE
    LDRB R1, [R1]
    CMP R1, #0
    BLEQ spawn_object3  ;if ob1 isnt active spawn one 

end_check_for_objects
    POP {R0-R12 , LR}
    BX LR
    ENDFUNC
    LTORG

spawn_object1 FUNCTION
    PUSH {R0-R12 , LR}
    MOV R0, #1              ;to indicate the object number
    MOV R7, #1              ;object became active
    LDR R1, =OB1_ACTIVE
    STRB R7, [R1]            ;OB1_active =1

    LDR R4, =OB1_TYPE
    BL DINO_DEFINE_OB_TYPE     ;get random object type
    LDRB R4, [R4]
    CMP R4, #1 ;if its a cactus
    BNE spawn_bird1 ;if false spawn a bird
    BLEQ.W spawn_cactus  ;if true spawn a cactus
    B end_spawn_object1

spawn_bird1    ;if false spawn a bird
    
    BL spawn_bird    ;if false spawn a bird
    
end_spawn_object1
    POP {R0-R12 , LR}
    BX LR ; Simply return to check_for_objects after spawning one
    ENDFUNC
    LTORG
spawn_object2   FUNCTION
    PUSH {R0-R12 , LR}
    MOV R0, #2              ;to indicate the object number
    MOV R7, #1              ;object became active
    LDR R1, =OB2_ACTIVE
    STRB R7, [R1]            ;OB1_active =1

    LDR R4, =OB2_TYPE
    BL DINO_DEFINE_OB_TYPE     ;get random object type
    LDRB R4, [R4]
    CMP R4, #1 ;if its a cactus
    BNE spawn_bird2 ;if false spawn a bird
    BLEQ.W spawn_cactus  ;if true spawn a cactus
    B end_spawn_object1

spawn_bird2    ;if false spawn a bird
    
    BL spawn_bird    ;if false spawn a bird
    
end_spawn_object2        ;no need for it since spawn_cactus/bird ends with BX check_for_objects
    POP {R0-R12 , LR}
    BX LR ; Simply return to check_for_objects after spawning one1
    ENDFUNC

spawn_object3   FUNCTION
    PUSH {R0-R12 , LR}
    MOV R0, #3              ;to indicate the object number
    MOV R7, #1              ;object became active
    LDR R1, =OB3_ACTIVE
    STRB R7, [R1]            ;OB1_active =1

    LDR R4, =OB3_TYPE
    BL DINO_DEFINE_OB_TYPE     ;get random object type
    LDRB R4, [R4]
    CMP R4, #1 ;if its a cactus
    BNE spawn_bird3 ;if false spawn a bird
    BLEQ.W spawn_cactus  ;if true spawn a cactus
    B end_spawn_object3

spawn_bird3    ;if false spawn a bird
    
    BL spawn_bird    ;if false spawn a bird
    
end_spawn_object3        ;no need for it since spawn_cactus/bird ends with BX check_for_objects
    POP {R0-R12 , LR}
    BX LR ; Simply return to check_for_objects after spawning one
    ENDFUNC



DINO_DEFINE_OB_TYPE  FUNCTION;R4 has obj type address
    PUSH {R0-R12 ,LR}
    LDR R0, =sys_time       ; Get the address of sys_time
    LDR R0, [R0]            ; Load the value of sys_time
    AND R3, R0, #0x1
    CMP R3, #0
    BEQ CHOOSE_BIRD
    MOV R2, #1              ; 1 is a cactus
    STRB R2, [R4]
    B RETURN_FROM_OB_TYPE

CHOOSE_BIRD
    MOV R2, #0              ; 0 is bird
    STRB R2, [R4]

RETURN_FROM_OB_TYPE
    POP {R0-R12 ,LR}
    BX LR
    ENDFUNC





spawn_bird   FUNCTION ;R0 has the object number
    PUSH {R0-R12 , LR}

    CMP R0 , #1
    BNE not1  ;not obj1
    LDR R1 , =OB1_X
    MOV R2 , #480
    STRH R2 , [R1]  ;obj1_x =480  (the right of the screen)
RD_W
    LDR R3 , =OB1_Y
    MOV R4 , #DINO_GROUND_Y
    SUB R4 , R4 , #DINO_NORMAL_DINO_H
    ADD R4 , R4,#10
    STRH R4 , [R3]      ;obj1_y = DINO_GROUND_Y-DINO_H (flying at height of the dino)
    

    LDR R5 , =OB1_W   ;R5 = address of obj width
    LDR R6 , =OB1_H   ;R6 = address of obj height
    LDR R7 , =DINO_BIRD_W
    STRH R7 , [R5]     ;OBj1 width = bird width

    LDR R7 , =DINO_BIRD_H
    STRH R7 , [R6]    ;obj1 height = bird height


    B end_spawn_bird





not1

    CMP R0 , #2
    BNE not2 ;not obj2
    LDR R1 , =OB2_X
    MOV R2 , #480
    STRH R2 , [R1]  ;obj2_x =480  (the right of the screen)

    LDR R3 , =OB2_Y
    MOV R4 , #DINO_GROUND_Y
    SUB R4 , R4 , #DINO_NORMAL_DINO_H  
    STRH R4 , [R3]      ;obj2_y = DINO_GROUND_Y-DINO_H (flying at height of the dino)




    LDR R5 , =OB2_W   ;R5 = address of obj width
    LDR R6 , =OB2_H   ;R6 = address of obj height
    LDR R7 , =DINO_BIRD_W
    STRH R7 , [R5]     ;OBj2 width = bird width

    LDR R7 , =DINO_BIRD_H
    STRH R7 , [R6]    ;obj2 height = bird height



    B end_spawn_bird



not2

    LDR R1, =OB3_X
    MOV R2, #480
    STRH R2, [R1]  ;obj3_x =480  (the right of the screen)

    LDR R3, =OB3_Y
    MOV R4, #DINO_GROUND_Y
    SUB R4, R4, #DINO_NORMAL_DINO_H  
    STRH R4, [R3]      ;obj3_y = DINO_GROUND_Y-DINO_H (flying at height of the dino)



    LDR R5, =OB3_W   ;R5 = address of obj width
    LDR R6, =OB3_H   ;R6 = address of obj height
    LDR R7, =DINO_BIRD_W
    STRH R7, [R5]     ;OBj3 width = bird width

    LDR R7, =DINO_BIRD_H
    STRH R7, [R6]    ;obj3 height = bird height


    B end_spawn_bird


end_spawn_bird

    LDR R1 , =sys_time
    LDR R1 , [R1]
    LDR R2, =LAST_SPAWN_TIME
    STRH R1, [R2]   ;update LAST_SPAWN_TIME



    POP {R0-R12 , LR}
    BX LR    ;to check again for the other objects
    ENDFUNC


spawn_cactus   FUNCTION;R0 has the object number
    PUSH {R0-R12 , LR}

    CMP R0, #1
    BNE not1_cactus  ;not obj1
    LDR R1, =OB1_X
    MOV R2, #480
    STRH R2, [R1]  ;obj1_x =480  (the right of the screen)

    LDR R3, =OB1_Y
    MOV R4, #DINO_GROUND_Y
    SUB R4, R4, #DINO_CAC_H
    STRH R4, [R3]      ;obj1_y = DINO_GROUND_Y-DINO_CAC_H (normal cactus position)
    LDR R5, =OB1_W   ;R5 = address of obj width
    LDR R6, =OB1_H   ;R6 = address of obj height
    LDR R7, =DINO_CAC_W
    STRH R7, [R5]     ;OBj1 width = cactus width

    LDR R7, =DINO_CAC_H
    STRH R7, [R6]    ;obj1 height = cactus height
    B end_spawn_cactus





not1_cactus
    CMP R0 , #2
    BNE not2_cactus ;not obj2
    LDR R1, =OB2_X
    MOV R2, #480
    STRH R2, [R1]  ;obj2_x =480  (the right of the screen)

    LDR R3, =OB2_Y
    MOV R4, #DINO_GROUND_Y
    SUB R4, R4, #DINO_CAC_H  
    STRH R4, [R3]      ;obj2_y = DINO_GROUND_Y-DINO_CAC_H (normal cactus position)
    

    LDR R5, =OB2_W   ;R5 = address of obj width
    LDR R6, =OB2_H   ;R6 = address of obj height
    LDR R7, =DINO_CAC_W
    STRH R7, [R5]     ;OBj2 width = cactus width

    LDR R7, =DINO_CAC_H
    STRH R7, [R6]    ;obj2 height = cactus height

    B end_spawn_cactus



not2_cactus
    LDR R1, =OB3_X
    MOV R2, #480
    STRH R2, [R1]  ;obj3_x =480  (the right of the screen)

    LDR R3, =OB3_Y
    MOV R4, #DINO_GROUND_Y
    SUB R4, R4, #DINO_CAC_H
    STRH R4, [R3]      ;obj3_y = DINO_GROUND_Y-DINO_CAC_H (normal cactus position)



    LDR R5, =OB3_W   ;R5 = address of obj width
    LDR R6, =OB3_H   ;R6 = address of obj height
    LDR R7, =DINO_CAC_W
    STRH R7, [R5]     ;OBj3 width = cactus width

    LDR R7, =DINO_CAC_H
    STRH R7, [R6]    ;obj3 height = cactus height



    B end_spawn_cactus


end_spawn_cactus


    LDR R1 , =sys_time
    LDR R1 , [R1]
    LDR R2, =LAST_SPAWN_TIME
    STRH R1, [R2]   ;update LAST_SPAWN_TIME


    POP {R0-R12 , LR}
    BX LR          ;to check again for the other objects
    ENDFUNC


move_object FUNCTION

    PUSH {R0-R12 , LR}
    LDR R0, =LAST_SYS_TIME_MOVE
    LDR R1, [R0]
    LDR R0, =sys_time
    LDR R2, [R0]
    SUB R4, R2, R1                ; R4 = sys_time - LAST_SPAWN_TIME

    LDR R2,=DINO_OBSTACLE_VELOCITY
    MOV R3, #1000
    UDIV R3,R3,R2
    CMP R4, R3
    BGT update_objects
    B   end_move_object



update_objects
    LDR R0, =LAST_SYS_TIME_MOVE
    LDR R1, =sys_time
    LDR R2, [R1]            ; Load the current systime
    STR R2, [R0]            ; Update LAST_SYS_TIME_MOVE with current systime
    LDR R8, =OB1_ACTIVE
    LDRB R8, [R8]
    CMP R8, #1   ;check if obj1 is active
    BNE notobj1
    LDR R1, =OB1_X    ;R1 has obj_x address
    LDRH R2, [R1]
    SUB R2, R2, #1                   ;R2 = old x - DISTANCE_MOVED
    STRH R2, [R1]                   ;put new x in obj_x
    
   



notobj1
    LDR R8, =OB2_ACTIVE
    LDRB R8, [R8]
    CMP R8, #1       ;check if obj2 is active
    BNE notobj2

    LDR R1, =OB2_X    ;R1 has obj_x address
    LDRH R2, [R1]
    SUB R2, R2, #1                   ;R2 = old x - DISTANCE_MOVED
    STRH R2, [R1]                   ;put new x in obj_x

      

notobj2
    LDR R8, =OB3_ACTIVE
    LDRB R8, [R8]
    CMP R8, #1               ;check if obj3 is active
    BNE end_move_object
    LDR R1, =OB3_X    ;R1 has obj_x address
    LDRH R2, [R1]
    SUB R2, R2, #1                    ;R2 = old x - DISTANCE_MOVED
    STRH R2 , [R1]                   ;put new x in obj_x
     

end_move_object
    POP {R0-R12, LR}
    BX LR
    ENDFUNC
   
; R0 = pointer to Dino (x, y, w, h)
; R1 = pointer to Object (x, y, w, h)
; returns Z = 1 if collision detected, Z = 0 if not (can use BEQ/BNE)

check_collision   FUNCTION  ;output in R3
    PUSH {R4-R7, LR}
    LDR R0, =DINO_X
    ; Load Dino values
    LDRH R2, [R0]         ; Dino X
    LDRH R3, [R0, #2]     ; Dino Y
    LDRH R4, [R0, #4]     ; Dino Width
    LDRH R5, [R0, #6]    ; Dino Height

    ; Load Object values
    LDRH R6, [R1]         ; Object X
    LDRH R7, [R1, #2]     ; Object Y
    LDRH R8, [R1, #4]     ; Object Width
    LDRH R9, [R1, #6]    ; Object Height
    ; Check if object is active
    LDRB R11, [R1, #-1]   ; Load the active status of the object (assumes active flag is stored just before object data)
    CMP R11, #1
    BNE no_collision       ; If not active, no collision

    ; Check X overlap
    ADD R10, R2, R4      ; Dino right edge
    ADD R11, R6, R8      ; Object right edge
    CMP R10, R6
    BLE no_collision     ; Dino completely left

    CMP R11, R2  
    BLE no_collision     ; Object completely left

    ; Check Y overlap
    ADD R10, R3, R5      ; Dino bottom edge
    ADD R11, R7, R9      ; Object bottom edge
    CMP R10, R7
    BLE no_collision     ; Dino completely above

    CMP R11, R3
    BLE no_collision     ; Object completely above

    ; If all overlaps happen, collision detected
    MOV R3, #1           ; Return 1 = collision
    POP {R4-R7, LR}
    BX LR

no_collision
    MOV R3, #0           ; Return 0 = no collision
    POP {R4-R7, LR}
    BX LR
    ENDFUNC

; A / B = C
; A % B = D
; Inputs: R0 = A, R1 = B
; Output: R3 = Quotient, R2 = Remainder
DIVIDE  FUNCTION
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
MODULO  FUNCTION
    PUSH {R0, R1, LR}
    MOV  R2, R0             ; R2 = R0
    UDIV R0, R0, R1         ; R0 = R0 // R1
    MLS R2, R1, R0, R2      ; R2 = R2 - R1 * R0
    POP {R0, R1, LR}
    BX LR
    ENDFUNC


apply_vel_y FUNCTION
    PUSH {R0-R4, LR}          ; Save registers

    ; Load current systime and last systime
    LDR   R0, =sys_time
    LDR   R1, [R0]            ; R1 = AIM_SYSTIME
    LDR   R0, =LAST_SYS_TIME_1
    LDR   R2, [R0]            ; R2 = AIM_LAST_SYSTIME

    ; Calculate dt = AIM_SYSTIME - AIM_LAST_SYSTIME
    SUB   R3, R1, R2          ; R3 = dt

    ; Update AIM_LAST_SYSTIME
    STR   R1, [R0]

    ; Load AIM velocity and DINO_DELTA_Y
    LDR   R0, =DINO_VELOCITY
    LDRB  R1, [R0]
    CMP    R1, #0
    BEQ     apply_vel_y_done
    LDR   R0, =DINO_DELTA_Y
    LDRH  R2, [R0]            ; R2 = DINO_DELTA_Y

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
    BL DIVIDE                ; R3 = Integer Part, R2 = Remainder [0, 1000]
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
    BL DIVIDE                ; R3 = Integer Part, R2 = Remainder [0, 1000]
    POP {R0-R2, LR}

    ADD R2, R2, R3           ; Add Integer part
    BL ADD_DECIMAL_TO_WHOLE_Y

done_velocity_y

    ; Load DINO_Y and DINO_DELTA_Y
    LDR   R0, =DINO_Y
    LDRH   R1, [R0]            
    LDR   R0, =DINO_DELTA_Y
    LDRH  R2, [R0]            ; R2 = DINO_DELTA_Y

    ; Add DINO_DELTA_Y to DINO_Y (y component only)
    UXTH  R1, R1              ; Extract y component of AIM_POS
    SXTH  R2, R2
    CMP   R2, #0              ; Check if DINO_DELTA_Y is negative
    BGE   add_delta_y         ; If positive or zero, branch to add_delta_y

    ; Handle negative DINO_DELTA_Y
    MVN   R2, R2              ; Take two's complement of DINO_DELTA_Y
    ADD   R2, R2, #1
    SUB   R1, R1, R2          ; Subtract DINO_DELTA_Y
    B     done_delta_y        ; Skip adding delta

add_delta_y
    ADD   R1, R1, R2          ; Add DINO_DELTA_Y

done_delta_y
    ; Clamp y to 0 - Height
    CMP   R1, #0
    BGE   check_upper_bound_y
    MOV   R1, #0             ; Clamp to 0 if y < 0
    B     clamp_done_y

check_upper_bound_y
    LDR   R4, =DINO_GROUND_Y
    SUB R4, #DINO_NORMAL_DINO_H
    CMP   R1, R4
    BLE   clamp_done_y
    MOV   R1, R4             ; Clamp to Width if x > Width
    LDR R0,=ACC
    MOV R3, #0
    STRB R3, [R0]            ; Load the value of acc
    LDR R0,=DINO_VELOCITY
    MOV R3, #0
    STRH R3, [R0]            ; Load the value of acc
    LDR R0,=DINOSTATE
    MOV R3, #0
    STRB R3, [R0]
clamp_done_y
    LDR   R0, =DINO_Y
    STRH   R1, [R0]           ; Store updated DINO_Y

    ; Clear DINO_DELTA_Y
    LDR   R0, =DINO_DELTA_Y
    MOV   R2, #0
    STRH  R2, [R0]

apply_vel_y_done
    POP {R0-R4, LR}           ; Restore registers
    BX LR
    ENDFUNC

; R2 = Integer Part of accumulation
; R4 = Decimal part from v * dt
ADD_DECIMAL_TO_WHOLE_Y  FUNCTION
    PUSH {R0-R5, LR}
    LDR   R0, =DINO_DELTA_Y_DECIMAL
    LDRH  R5, [R0]           ; R5 = DINO_DELTA_Y_DECIMAL
    ADD R5, R5, R4
    SXTH R5, R5
    CMP R5, #0               ; Check if DINO_DELTA_Y_DECIMAL is negative
    BGE decimal_positive_y   ; If positive or zero, branch to decimal_positive_y

    ; Handle negative DINO_DELTA_Y_DECIMAL
    MVN R5, R5               ; Take two's complement of DINO_DELTA_Y_DECIMAL
    ADD R5, R5, #1
    PUSH {R0-R3, LR}
    MOV R0, R5
    MOV R1, #1000
    BL DIVIDE
    SUB R2, R2, R3           ; Subtract from integer part
    LDR   R0, =DINO_DELTA_Y
    STRH R2, [R0]
    LDR R0, =DINO_DELTA_Y_DECIMAL
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
    LDR   R0, =DINO_DELTA_Y
    STRH R2, [R0]
    LDR R0, =DINO_DELTA_Y_DECIMAL
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
    LDR     R4, =DINO_PRNG_STATE     ; R4 = address of prng_state
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

    END
