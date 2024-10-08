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

#####################################################################
Requirement 0 (Thread has ended) returns True if no args passed [Eon]
#####################################################################
#made since people incorrectly assumed requirement 0 was "character exists" and was sortof used as a "if True" requirement.
#this meant anywhere that requirement was used without requirements then its final functionality was based on whatever happened to be next in the file.
#so this is to make sure that command is consistent
HOOK @ $807826DC
{
    mr r3, r27
    lwz r12, 0x0(r3)
    lwz r12, 0x14(r12)
    mtctr r12 
    bctrl #getSize()
    cmpwi r3, 0x2
    bge cont
    #not enough args so dont read invalid data
    li r3, 1
    lis r12, 0x8078
    ori r12, r12, 0x54B4
    mtctr r12 
    bctr
cont:
    mr r3, r27
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

#################################################################
On hit Action change through Trip Rate [MarioDox, Eon (refactor)]
#################################################################
.macro checkTripRate(<TripRateHalf>, <Action>)
{
    lis r6, <TripRateHalf>
    cmpw r5, r6
    bne 0xC
    li r3, <Action>
    b exit
}
HOOK @ $8076BD5C
{
    mr r31, r4
    lwz r5, 0x44(r5)
    lwz r5, 0x40(r5)
    lwz r5, 0x6C(r5)    
    %checkTripRate(0x4040, 0x4B)    //3 = floor cripple
    %checkTripRate(0x4080, 0xBD)    //4 = death
    %checkTripRate(0x40a0, 0xFF)    //5 = freeze in place
    %checkTripRate(0x40c0, 0x46)    //6 = speen knockback
    %checkTripRate(0x40d0, 0x40)    //7 = grab release (horizontal)
    %checkTripRate(0x40f0, 0x41)    //8 = grab release (vertical)
	%checkTripRate(0x4330, 0xB0)    //176 = Aerial Screw Attack Jump
    b %end%
exit:
    lis r12, 0x8076
    ori r12, r12, 0xBDAC
    mtctr r12 
    bctr
}

#######################################################################
!Char Specific Paralyze Effect [MarioDox]
#######################################################################
#Currently disabled, as it breaks specific projectile interactions when reflected.
.macro customParalyze(<ID>, <GFXHi>, <GFXLo>)
{
	cmpwi r3, <ID>
	bne- 0x10
	lis r4, <GFXHi>
	addi r4, r4, <GFXLo>
	b %END%
}
HOOK @ $8085c684 #onParalyzeDamage
{
	lbz r3, 0x123(r5)		#Get attacker fighter id
	%customParalyze(0x18, 0x0019,0x0007)	# ZSS, vanilla
	b default:
default:
	li r4, 0x0
	addi r4, r4, 0x002D		#Common gfx, dizzy spark
}

.include Source/Community/PSA/CreateAndThrowItem.asm

##############################################################
Store hit Task in LA/RA-Basic 6 [MarioDox]
##############################################################
# LA/RA-Basic 6 must contain "741EF1D" (THIEF ID) to get the hit task
.macro storeTaskandCheck(<reg1>,<reg2>)
{
    lwz        r12, 0x60(<reg1>)    # get the address for accessing basics
    lwz        r12, 0xD8(r12)
    lwz        r12, 0x64(r12)
    lwz        r12, 0x20(r12)        # LA
    lwz        r12, 0x0C(r12)        # Basic
     lwz         r11, 0x18(r12)        # 6
    lis        <reg2>, 0x0741        # \ Check if it's
    ori        <reg2>, <reg2>, 0xEF1D    # / 0741EF1D(THIEF-ID)
    cmpw        <reg2>, r11
    beq-        write
    lwz        r12, 0x60(<reg1>)    # get the address for accessing basics
    lwz        r12, 0xD8(r12)
    lwz        r12, 0x64(r12)
    lwz        r12, 0x24(r12)        # RA
    lwz        r12, 0x0C(r12)        # Basic
     lwz         r11, 0x18(r12)        # 6
    cmpw        <reg2>, r11        # Check if it's 0741EF1D(THIEF-ID)
    beq-        write
    b        end
write:
    stw        r3, 0x18(r12)        # Store hit task in XX Basic 6
end:
    mr        <reg2>, r3        # original op
}
HOOK @ $8083fbbc #notifyEventCollisionAttack/[Fighter]
{
    %storeTaskandCheck(r29,r27)
}
HOOK @ $808e53cc #notifyEventCollisionAttack/[Weapon]
{
    %storeTaskandCheck(r26,r29)
}
HOOK @ $80aa991c #notifyEventCollisionAttack/[wnLucarioAuraBall]
{
    %storeTaskandCheck(r27,r30)
}

#############################################################
Raycast Requirement (0x19) Supports Variables for x,y,z [Eon]
#############################################################
.macro getVariable() 
{
    addi r3, r1, 1048
    
    stw r28, 0x10(r3)
    lis r12, 0x8077
    ori r12, r12, 0xE0CC
    mtctr r12
    bctrl 
}
#get soValueAccesser into place
#X
HOOK @ $807838B4 8127ee50
{
orig:
    fdivs f31, f1, f0

    lwz r4, 0x0(r3)
    cmpwi r4, 0x5
    bne %end% 
    li r4, 0
    %getVariable()
    fmr f31, f1
}
#Y
HOOK @ $80783918 
{
orig:
    fdivs f30, f1, f0

    lwz r4, 0x0(r3)
    cmpwi r4, 0x5
    bne %end%
    li r4, 1
    %getVariable()
    fmr f30, f1
}
#Z
HOOK @ $8078397C 
{
orig:
    fdivs f0, f1, f0

    lwz r4, 0x0(r3)
    cmpwi r4, 0x5
    bne %end%
    li r4, 2
    %getVariable()
    fmr f0, f1
}