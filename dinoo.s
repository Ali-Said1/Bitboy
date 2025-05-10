CAC_W          EQU      40
CAC_H          EQU      80
BIRD_W         EQU      40
BIRD_H         EQU      20
GROUND_Y       EQU      280
DINO_START_X   EQU      20
DINO_START_Y   EQU      180
NORMAL_DINO_H  EQU      100
DISTANCE_MOVED EQU      20

    AREA    VECTORS, CODE, READONLY
    EXPORT  __Vectors
__Vectors
    DCD     0x20005000          ; Initial SP value (top of 400KB simulated SRAM)
    DCD     Reset_Handler       ; Reset handler address
    AREA DINOVARS, DATA, READWRITE
    
    ;##########################DINO
    EXPORT DINOSTATE
    EXPORT DINO_X
    EXPORT DINO_Y
    EXPORT DINO_W
    EXPORT DINO_H
    EXPORT LAST_SPAWN_TIME
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
    EXPORT sys_time
	EXPORT JUMP_CONDITION
DINOSTATE  DCB 0 ;0 walking, 1 jumping, ,2 ducking,3 dead
    ALIGN 2
DINO_X  DCW 20
DINO_Y  DCW 180
DINO_W DCW 40
DINO_H DCW 100

LAST_SYS_TIME_1 DCW 0
LAST_SYS_TIME_2 DCW 0
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
sys_time DCW 100

    ALIGN

    AREA CODE, CODE, READONLY
	EXPORT Reset_Handler

Reset_Handler
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
    MOV     R1, #0      ; Start moving right
    STRB    R1, [R0]

    ; intialize sys time
    LDR     R0,=sys_time
    MOV     R1,#100
    STRH    R1,[R0]

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
    MOV     R1,#NORMAL_DINO_H          
    STRH    R1,[R0]
    ;intialize delay
    LDR     R0,=DELAY
    MOV     R1,#20
    STRH    R1,[R0]

    ;intialize jump condition
    LDR     R0,=JUMP_CONDITION
    MOV     R1,#0
    STRB    R1,[R0]

    LTORG
    
game_loop
    BL USER_CROUCH
    BL check_for_objects ;spawn objects if needed
    BL move_object ;move Obstacle
    LDR R0, =DINO_X
    LDR R1, =OB1_X
    BL check_collision   

    LDR R4,=DINOSTATE
    LDRB R4,[R4]
    CMP R4, #1
    BLEQ JUMP_DINO
    CMP R4, #2
    BLEQ START_CROUCH
    
    BL USER_WALK
    CMP R3, #0
    BNE game_over
    
    LDR R1, =OB2_X
    BL check_collision   
    CMP R3, #0
    BNE game_over
    
    LDR R1, =OB3_X
    BL check_collision
    CMP R3, #0
    BNE game_over

    BL check_for_despawn

    LDR R0, =sys_time
    LDRH R1, [R0]
    ADD R1, R1, #1
    STRH R1, [R0] ;increment sys_time by 20
    
    
    ;BL check_for_despawn
    B game_loop
    LTORG
game_over

    ; Reset game state
    BL Reset_Handler
    B game_loop

USER_Jump
    PUSH {R0-R12 , LR}
    LDR R0,=DINOSTATE
    MOV R2, #1
    STRB R2,[R0]
    POP {R0-R12 , LR}
    BX LR

JUMP_DINO
    PUSH {R0-R12 , LR}
    LDR R0, =JUMP_CONDITION
    LDRB R1, [R0]
    CMP R1, #0
    BEQ jump_dino_up
    CMP R1, #1
    BEQ jump_dino_down
    CMP R1, #2
    BEQ DELAY_JUMP
    B end_jump_dino

    LTORG

condition_delay
    LDR R2, =JUMP_CONDITION
    mov R3, #2
    STRB R3, [R2]
    BX LR

condition_down
    LDR R2, =JUMP_CONDITION
    mov R3, #1
    STRB R3, [R2]
    BX LR

jump_dino_up
    LDR R0,=DINO_Y
    LDRH R1, [R0]
    SUB R1, R1, #4
    STRH R1, [R0]
    CMP R1, #50
    BEQ condition_delay
     BX LR


DELAY_JUMP
    LDR R0, =DELAY
    LDRH R1, [R0]
    SUB R1, R1, #1
    STRH R1, [R0]
    CMP R1, #0
    BEQ condition_down
    BX LR


jump_dino_down
    LDR R0,=DINO_Y
    LDRH R1, [R0]
    ADD R1, R1, #4
    STRH R1, [R0]
    CMP R1, #180
    BEQ end_jump_dino
     BX LR


end_jump_dino

    LDR R0, =DINOSTATE
    MOV R2, #0
    STRB R2,[R0]
    LDR R0, =JUMP_CONDITION
    MOV R2, #0
    STRB R2,[R0]
    LDR R0, =DELAY
    MOV R1, #20
    STRH R1, [R0]


    POP {R0-R12 , LR}
    BX LR

USER_WALK

    PUSH {R0-R2 , LR}
    LDR R0,=DINOSTATE
    LDRB R1, [R0]
    CMP R1, #2
    BLEQ end_CROUCH
    MOV R2, #0
    STRB R2,[R0]
    POP {R0-R2 , LR}
    BX LR

    
USER_CROUCH

    PUSH {R0-R2 , LR}
    LDR R0,=DINOSTATE
    MOV R2, #2
    STRB R2,[R0]
    POP {R0-R2 , LR}
    BX LR
   

START_CROUCH
    PUSH {R0-R12 , LR}

    LDR R0,=DINO_Y
    MOV R2, #220
    STRH R2, [R0]
    BX LR

end_CROUCH
    PUSH {R0-R12 , LR}
    LDR R0,=DINO_Y
    MOV R2, #180
    STRH R2, [R0]
    POP {R0-R12 , LR}

    BX LR


check_for_despawn
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


check_for_objects
    PUSH {R0-R12 , LR}


margian_time_check   ;check if 60 seconds passed since last spawn    
    MOV R0, #0 
    LDR R10, =sys_time  
    LDRH R10, [R10]                  ;R10 = sys_time
    LDR R11, =LAST_SPAWN_TIME
    LDRH R11, [R11]                  ;R11 = LAST_SPAWN_TIME
    SUB R11, R10 ,R11                ;R11 = sys_time - LAST_SPAWN_TIME
    MOV R9, #60                      ;R9 =60
    CMP R11, R9                      ;if sys_time-LAST_SPAWN_TIME <60  dont spawn anything
    BLT end_check_for_objects

    
    LDR R1, =OB1_ACTIVE
    LDRB R1, [R1]
    CMP R1, #1
    BLNE spawn_object1  ;if ob1 isnt active spawn one 
    LDR R2, =OB2_ACTIVE
    LDRB R2, [R2]
    CMP R2, #1
    BLNE spawn_object2

    LDR R3, =OB3_ACTIVE
    LDRB R3, [R3]
    CMP R3, #1
    BLNE spawn_object3



end_check_for_objects
    POP {R0-R12 , LR}
    BX LR



spawn_object1
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
    
end_spawn_object1        ;no need for it since spawn_cactus/bird ends with BX check_for_objects
    POP {R0-R12 , LR}
    B margian_time_check ;end_spawn_object1


spawn_object2
    PUSH {R0-R12 , LR}
    MOV R0, #1              ;to indicate the object number
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
    B margian_time_check ;end_spawn_object1


spawn_object3
    PUSH {R0-R12 , LR}
    MOV R0, #1              ;to indicate the object number
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
    B margian_time_check ;end_spawn_object1





DINO_DEFINE_OB_TYPE  ;R4 has obj type address
    PUSH {R0-R12 ,LR}
    LDR R0, =sys_time       ; Get the address of sys_time
    LDRH R0, [R0]            ; Load the value of sys_time
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






spawn_bird    ;R0 has the object number
    PUSH {R0-R12 , LR}

    CMP R0 , #1
    BNE not1  ;not obj1
    LDR R1 , =OB1_X
    MOV R2 , #480
    STRH R2 , [R1]  ;obj1_x =480  (the right of the screen)

    LDR R3 , =OB1_Y
    MOV R4 , #GROUND_Y
    SUB R4 , R4 , #NORMAL_DINO_H  
    ADD R4 , R4,#10
    STRH R4 , [R3]      ;obj1_y = GROUND_Y-DINO_H (flying at height of the dino)
    

    LDR R5 , =OB1_W   ;R5 = address of obj width
    LDR R6 , =OB1_H   ;R6 = address of obj height
    LDR R7 , =BIRD_W
    LDRH R7 , [R7]     ;R7 = bird width
    STRH R7 , [R5]     ;OBj1 width = bird width

    LDR R7 , =BIRD_H
    LDRH R7 , [R7]
    STRH R7 , [R6]    ;obj1 height = bird height


    B end_spawn_bird





not1

    CMP R0 , #2
    BNE not2 ;not obj2
    LDR R1 , =OB2_X
    MOV R2 , #480
    STRH R2 , [R1]  ;obj2_x =480  (the right of the screen)

    LDR R3 , =OB2_Y
    MOV R4 , #GROUND_Y
    SUB R4 , R4 , #NORMAL_DINO_H  
    STRH R4 , [R3]      ;obj2_y = GROUND_Y-DINO_H (flying at height of the dino)




    LDR R5 , =OB2_W   ;R5 = address of obj width
    LDR R6 , =OB2_H   ;R6 = address of obj height
    LDR R7 , =BIRD_W
    LDRH R7 , [R7]     ;R7 = bird width
    STRH R7 , [R5]     ;OBj2 width = bird width

    LDR R7 , =BIRD_H
    LDRH R7 , [R7]
    STRH R7 , [R6]    ;obj2 height = bird height



    B end_spawn_bird



not2

    LDR R1, =OB3_X
    MOV R2, #480
    STRH R2, [R1]  ;obj3_x =480  (the right of the screen)

    LDR R3, =OB3_Y
    MOV R4, #GROUND_Y
    SUB R4, R4, #NORMAL_DINO_H  
    STRH R4, [R3]      ;obj3_y = GROUND_Y-DINO_H (flying at height of the dino)



    LDR R5, =OB3_W   ;R5 = address of obj width
    LDR R6, =OB3_H   ;R6 = address of obj height
    LDR R7, =BIRD_W
    LDRH R7, [R7]     ;R7 = bird width
    STRH R7, [R5]     ;OBj3 width = bird width

    LDR R7, =BIRD_H
    LDRH R7, [R7]
    STRH R7, [R6]    ;obj3 height = bird height


    B end_spawn_bird


end_spawn_bird

    LDR R1 , =sys_time
    LDRH R1 , [R1]
    LDR R2, =LAST_SPAWN_TIME
    STRH R1, [R2]   ;update LAST_SPAWN_TIME



    POP {R0-R12 , LR}
    BX LR    ;to check again for the other objects



spawn_cactus    ;R0 has the object number
    PUSH {R0-R12 , LR}

    CMP R0, #1
    BNE not1_cactus  ;not obj1
    LDR R1, =OB1_X
    MOV R2, #480
    STRH R2, [R1]  ;obj1_x =480  (the right of the screen)

    LDR R3, =OB1_Y
    MOV R4, #GROUND_Y
    SUB R4, R4, #CAC_H
    STRH R4, [R3]      ;obj1_y = GROUND_Y-CAC_H (normal cactus position)
    LDR R5, =OB1_W   ;R5 = address of obj width
    LDR R6, =OB1_H   ;R6 = address of obj height
    LDR R7, =CAC_W
    LDRH R7, [R7]     ;R7 = cactus width
    STRH R7, [R5]     ;OBj1 width = cactus width

    LDR R7, =CAC_H
    LDRH R7, [R7]
    STRH R7, [R6]    ;obj1 height = cactus height
    B end_spawn_cactus





not1_cactus
    CMP R0 , #2
    BNE not2_cactus ;not obj2
    LDR R1, =OB2_X
    MOV R2, #480
    STRH R2, [R1]  ;obj2_x =480  (the right of the screen)

    LDR R3, =OB2_Y
    MOV R4, #GROUND_Y
    SUB R4, R4, #CAC_H  
    STRH R4, [R3]      ;obj2_y = GROUND_Y-CAC_H (normal cactus position)
    

    LDR R5, =OB2_W   ;R5 = address of obj width
    LDR R6, =OB2_H   ;R6 = address of obj height
    LDR R7, =CAC_W
    LDRH R7, [R7]     ;R7 = cactus width
    STRH R7, [R5]     ;OBj2 width = cactus width

    LDR R7, =CAC_H
    LDRH R7, [R7]
    STRH R7, [R6]    ;obj2 height = cactus height

    B end_spawn_cactus



not2_cactus
    LDR R1, =OB3_X
    MOV R2, #480
    STRH R2, [R1]  ;obj3_x =480  (the right of the screen)

    LDR R3, =OB3_Y
    MOV R4, #GROUND_Y
    SUB R4, R4, #CAC_H
    STRH R4, [R3]      ;obj3_y = GROUND_Y-CAC_H (normal cactus position)



    LDR R5, =OB3_W   ;R5 = address of obj width
    LDR R6, =OB3_H   ;R6 = address of obj height
    LDR R7, =CAC_W
    LDRH R7, [R7]     ;R7 = cactus width
    STRH R7, [R5]     ;OBj3 width = cactus width

    LDR R7, =CAC_H
    LDRH R7, [R7]
    STRH R7, [R6]    ;obj3 height = cactus height



    B end_spawn_cactus


end_spawn_cactus


    LDR R1 , =sys_time
    LDRH R1 , [R1]
    LDR R2, =LAST_SPAWN_TIME
    STRH R1, [R2]   ;update LAST_SPAWN_TIME


    POP {R0-R12 , LR}
    BX LR          ;to check again for the other objects



move_object
   
   PUSH {R0-R12 , LR}
   LDR R8, =OB1_ACTIVE
   LDRB R8, [R8]
   CMP R8, #1   ;check if obj1 is active
   BNE notobj1
   LDR R1, =OB1_X    ;R1 has obj_x address
   LDRH R2, [R1]
   SUB R2, R2, #DISTANCE_MOVED    ;R2 = old x - DISTANCE_MOVED
   STRH R2, [R1]                   ;put new x in obj_x
   
   



notobj1
    LDR R8, =OB2_ACTIVE
    LDRB R8, [R8]
    CMP R8, #1       ;check if obj2 is active
    BNE notobj2

    LDR R1, =OB2_X    ;R1 has obj_x address
    LDRH R2, [R1]
    SUB R2, R2, #DISTANCE_MOVED    ;R2 = old x - DISTANCE_MOVED
    STRH R2, [R1]                   ;put new x in obj_x

      

notobj2
    LDR R8, =OB3_ACTIVE
    LDRB R8, [R8]
    CMP R8, #1               ;check if obj3 is active
    BNE end_move_object
    LDR R1, =OB3_X    ;R1 has obj_x address
    LDRH R2, [R1]
    SUB R2, R2, #DISTANCE_MOVED    ;R2 = old x - DISTANCE_MOVED
    STRH R2 , [R1]                   ;put new x in obj_x
     

end_move_object
    POP {R0-R12, LR}
    BX LR
   
   
; R0 = pointer to Dino (x, y, w, h)
; R1 = pointer to Object (x, y, w, h)
; returns Z = 1 if collision detected, Z = 0 if not (can use BEQ/BNE)

check_collision   ;output in R3
    PUSH {R4-R7, LR}

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


; A / B = C
; A % B = D
; Inputs: R0 = A, R1 = B
; Output: R3 = Quotient, R2 = Remainder
DIVIDE
        PUSH {R0, R1, LR}
        MOV  R2, R0             ; R2 = R0
        UDIV R0, R0, R1         ; R0 = R0 // R1
        MLS R2, R1, R0, R2      ; R2 = R2 - R1 * R0
        MOV R3, R0
        POP {R0, R1, LR}
        BX LR


; A % B = C
; Inputs: R0 = A, R1 = B
; Output: R2 = C
MODULO 
        PUSH {R0, R1, LR}
        MOV  R2, R0             ; R2 = R0
        UDIV R0, R0, R1         ; R0 = R0 // R1
        MLS R2, R1, R0, R2      ; R2 = R2 - R1 * R0
        POP {R0, R1, LR}
        BX LR




