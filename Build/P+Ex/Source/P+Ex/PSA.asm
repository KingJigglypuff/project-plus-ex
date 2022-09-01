######################################################
Clear Specific Transition Term Group PSA Command [Eon]
######################################################
#020E0100 = Clear Specific transition term, with argument
#020E0000 = Original command, left in tact, clears all transition terms
HOOK @ $80781F04
{
#is arg list empty   
    addi r3, r1, 0x138
    lwz r12, 0x0(r3)
    lwz r12, 0x18(r12)
    mtctr r12
    bctrl
    cmpwi r3, 1
    li r4, -1
    beq end #if empty, pass arg as -1
#else get value of arg 0 as pass as r4
    addi r3, r1, 0x138
    li r4, 0
    stw r28, 0x10(r3)
    lis r12, 0x8077
    ori r12, r12, 0xDFDC
    mtctr r12
    bctrl
    mr r4, r3
end:
    mr r3, r26
    lwz r12, 0x0(r26)
}

#########################################################
Null GroundModule makes rayCheckTarget return false [Eon]
#########################################################
HOOK @ $80734254
{
    mr r28, r3
    #target.groundModule.isNull()
    lwz r12, 0x8(r3)
    lwz r12, 0x10(r12)
    mtctr r12
    bctrl 
    cmpwi r3, 1 
    beq isNull #if isNull, return false
    #this.groundModule.isNull()
    mr r3, r29
    lis r12, 0x8079
    ori r12, r12, 0x77D8
    mtctr r12
    bctrl
    lwz r12, 0x8(r3)
    lwz r12, 0x10(r12)
    mtctr r12
    bctrl 
    cmpwi r3, 1
    bne notNull 
isNull:
    li r3, 0 #return false
    lis r12, 0x8073
    ori r12, r12, 0x4300
    mtctr r12
    bctr
notNull:
    mr r3, r28 #do normal function with raycast
}

###################################################################################
Concurrent Infinite Loop accepts int types so you can point to arbitrary code [Eon]
###################################################################################
HOOK @ $8077d120
{
  cmpwi r0, 0 #if type value just accept it anyways
  beq %end%
  cmpwi r0, 2 #pointer default functionality
}

#######################
!Raycast debugger [Eon]
#######################
#Disabled by default. If enabled, any raycasting checks will always display.
#draws the ray you are trying to check for in red, and draws anything the ray comes in contact with in green
#stRay basic raycast command used for anything that isnt explictly collisions
HOOK @ $801380EC
{
    addi r3, r1, 0xC
    addi r4, r24, 0x2C
    lfs f1, 0x0(r4)
    lfs f2, 0x8(r4)
    fadds f2, f1, f2
    stfs f1, 0x0(r3)
    stfs f2, 0x8(r3)
    lfs f1, 0x4(r4)
    lfs f2, 0xC(r4)
    fadds f2, f1, f2
    stfs f1, 0x4(r3)
    stfs f2, 0xC(r3)
    addi r4, r1, 0x8
    lis r0, 0xFF00
    ori r0, r0, 0x00FF
    stw r0, 0x0(r4)
    li r5, 0
    lfs f1, -0x68CC(r2)
    lis r12, 0x8004
    ori r12, r12, 0x1104
    mtctr r12
    bctrl


    lbz r0, 0x12(r24) #orig 
}
HOOK @ $80138218
{
    addi r3, r1, 0x50
    stwu r1, -0x10(r1)
    addi r4, r1, 0x8
    lis r0, 0x00FF
    ori r0, r0, 0x00FF
    stw r0, 0x0(r4)
    li r5, 0
    lfs f1, -0x68CC(r2)
    lis r12, 0x8004
    ori r12, r12, 0x1104
    mtctr r12
    bctrl
    addi r1, r1, 0x10


    lfs f1, 0x8(r1) #orig 
}

#havok materials #draws same stuff for havok collision checks
HOOK @ $800869cc
{
    stw r0, 0x6C(r1)
    addi r3, r1, 0x5C
    stwu r1, -0x10(r1)
    addi r4, r1, 0x8
    lis r0, 0xFF00
    ori r0, r0, 0x00FF
    stw r0, 0x0(r4)
    li r5, 0
    lfs f1, -0x68CC(r2)
    lis r12, 0x8004
    ori r12, r12, 0x1104
    mtctr r12
    bctrl
    addi r1, r1, 0x10

}
HOOK @ $80086a24
{
    addi r3, r1, 0x48
    stwu r1, -0x10(r1)
    addi r4, r1, 0x8
    lis r0, 0x00FF
    ori r0, r0, 0x00FF
    stw r0, 0x0(r4)
    li r5, 0
    lfs f1, -0x68CC(r2)
    lis r12, 0x8004
    ori r12, r12, 0x1104
    mtctr r12
    bctrl
    addi r1, r1, 0x10

    cmpwi r29, 0
}

#######################################################
PSA Command 1F080200 (spawn item variant) [Sammi Husky]
#######################################################
* 047C8674 83A3000C