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

#######################################################
PSA Command 1F080200 (spawn item variant) [Sammi Husky]
#######################################################
* 047C8674 83A3000C

#######################################################################
On hit Action change through Trip Rate v1.27 [MarioDox, Eon (refactor)]
#################################################################
v1.2: Automatized, trip rate is decimal action ID change
v1.25: Added anti-lock behavior, can't change action if it's already in it
v1.26: Anti-lock behavior works properly
v1.27: Fixes various issues related to unexpected behaviors
#######################################################################
HOOK @ $8076BD50
{
    stw r0, 0x14(r1) #\save registers so that success condition doesnt break them
    stw r31, 0xC(r1) #/
    stwu r1, -0x10(r1)
    mflr r0
    stw r0, 0x14(r1)
    mr r31, r4
    lwz r5, 0x44(r3)
    lwz r5, 0x40(r5)

    lwz r3, 0xD8(r3) #original instruction now that we're done with it

    lfs f1, 0x6C(r5)
    fctiw f1,f1
    stfd f1,0x08(r1)
    lwz r5,0x0C(r1)
    cmpwi r5, 0x15     # \ No need forcing these actions,
    ble+ end         # / saves some room for extra effects.
    cmpwi r5, 0x112     # \ And Don't access Specials!
    bge+ end        # /
    lwz r12, -0x4(r3)     # \ return from moduleAccesser
    lwz r12, 0x60(r12)  # | 
    lwz r12, 0x7C(r12)  # | 
    lwz r12, 0x38(r12)     # / Access action
    cmpw r5, r12
    beq- end
    mr r3, r5
exit:
    lwz r0, 0x14(r1)
    mtlr r0
    addi r1, r1, 0x10
    lis r12, 0x8076
    ori r12, r12, 0xBDAC
    mtctr r12 
    bctr
end:
    lwz r0, 0x14(r1)
    mtlr r0
    addi r1, r1, 0x10
}
op nop @ $8076BD54 #\remove register saves in original function so they dont double save 
op nop @ $8076BD58 #/not necessary but feels messy without, and means r0/r31 would be usable in above code

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

########################################################################################
Graphic Effect (Detached) Commands Can Specify an ID Offset in Arg 0x10 v1.0 [QuickLava]
# Mimics the functionality found in the Graphic Effect (Attached) commands where you
# can specify an offset value to add to the originally specified Graphic ID.
########################################################################################
.alias getValueIntHi = 0x8079
.alias getValueIntLo = 0x7104
.alias argListStackOff = 0x818
HOOK @ $807A568C
{
    lwz r27, 0x04(r3)             # Restore Original Instruction (Load EfID Argument)
	lwz r12, 0x08(r21)            # \  
    lbz r12, 0x02(r12)            # / Grab the number of arguments on this event.
	cmplwi r12, 0x10              # \
	ble+ %END%                    # / If its 16 or fewer, we don't have our extra argument, exit!
getIDOffset:                      # 
	addi r3, r1, argListStackOff  # Grab the active soAnimCmdArgList for this set of events, in preparation for grabbing our argument.
	li r4, 0x10                   # Set r4 to 0x10, the index of the argument we care about.
	lwz r12, 0x00(r3)             # \
	lwz r12, 0x10(r12)            # | Grab the pointer for the at() function via the arg list's vTable...
	mtctr r12                     # | ... then put it into CTR and call it! Afterwards, r3 will be pointer to our argument.
	bctrl                         # / 
	lwz r12, 0x00(r3)             # Load the type of the returned argument...
	lwz r3, 0x04(r3)              # ... as well as its value.
	cmplwi r12, 0x05              # Check if the argument was a variable...
    bne finalizeValue             # ... and if it wasn't, skip the below for resolving it.
handleVariable:                   # If it was a variable though, we need to get its actual value.
	mr r4, r3                     # First, move our variable ID into r4, since that's where we'll need it.
	mr r3, r31                    # Then grab our soModuleAccesser from its place in r31.
	lis r12, getValueIntHi        # \
	ori r12, r12, getValueIntLo   # | Set up and call soValueAccesser::getValueInt()!
	mtctr r12                     # | Afterwards, r3 is our variable value.
	bctrl                         # /
finalizeValue:                    #
	add r27, r27, r3              # Finally, add our retrieved value to the original Effect ID stored in r27!
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
