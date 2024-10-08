#############################################################################################################
[CM_Addons] Raycast Debugger (Toggle Ver.) v1.0.1 [Eon, QuickLava]
# Raycast Debugger created by Eon
# Disabled by default. If enabled, any raycasting checks will always display.
# draws the ray you are trying to check for in red, and draws anything the ray comes in contact with in green
# stRay basic raycast command used for anything that isnt explictly collisions
#############################################################################################################
.include "Source/CM_Addons/AddonAliases.asm"

.macro lwd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lwz     <reg>, temp_Lo(<reg>)
}

HOOK @ $801380EC                            # in "raycheckSub/[grCollisionRaycheck]/gr_collision_raycheck.o" @ 0x801380BC
{
    %lwd(r12, RAYDEBUG_ONOFF_LOC)           # Grab the address of the Toggle line...
    lwz r12, 0x08(r12)                      # ... then grab the current state of the toggle!
    cmplwi r12, 0x00                        # If it's set to off...
    beq+ exit                               # ... then skip displaying, jump to exit! 
    
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

exit:
    lbz r0, 0x12(r24)                       # Restore Original Instruction 
}
HOOK @ $80138218                            # in "raycheckSub/[grCollisionRaycheck]/gr_collision_raycheck.o" @ 0x801380BC
{
    %lwd(r12, RAYDEBUG_ONOFF_LOC)           # Grab the address of the Toggle line...
    lwz r12, 0x08(r12)                      # ... then grab the current state of the toggle!
    cmplwi r12, 0x00                        # If it's set to off...
    beq+ exit                               # ... then skip displaying, jump to exit! 
    
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

exit:
    lfs f1, 0x8(r1)                         # Restore Original Instruction
}

#havok materials #draws same stuff for havok collision checks
HOOK @ $800869cc                            # in "checkCollisionHit/[ph2ndaryWorld]/ph_2ndary_world.o" @ 0x800867E8
{
    stw r0, 0x6C(r1)                        # Restore Original Instruction
    %lwd(r12, RAYDEBUG_ONOFF_LOC)           # Grab the address of the Toggle line...
    lwz r12, 0x08(r12)                      # ... then grab the current state of the toggle!
    cmplwi r12, 0x00                        # If it's set to off...
    beq+ %END%                              # ... then skip displaying, jump to exit! 
    
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
HOOK @ $80086a24                            # in "checkCollisionHit/[ph2ndaryWorld]/ph_2ndary_world.o" @ 0x800867E8
{
    %lwd(r12, RAYDEBUG_ONOFF_LOC)           # Grab the address of the Toggle line...
    lwz r12, 0x08(r12)                      # ... then grab the current state of the toggle!
    cmplwi r12, 0x00                        # If it's set to off...
    beq+ exit                               # ... then skip displaying, jump to exit! 
    
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

exit:
    cmpwi r29, 0                            # Restore Original Instruction
}