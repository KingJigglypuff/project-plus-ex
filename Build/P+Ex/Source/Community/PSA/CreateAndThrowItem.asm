###############################################################
Custom GenerateAndThrowItem PSA command [Sammi Husky, MarioDox]
###############################################################
.macro getFloat()
{
    lis     r12,0x80AE
    ori     r12,r12,0x0E28
    stw     r12,0x158(r1)
    stw     r5,0x15C(r1)
    stw     r3,0x160(r1)
    stw     r0,0x164(r1)
    stw     r7,0x168(r1)
    li      r0,0x0
    stb     r0,0x16C(r1)
    addi    r3,r1,0x158
    li      r4,0x0
    lis     r12,0x8077      # \ getFloat/[soAnimCmdArgList]
    ori     r12,r12,0xE0CC  # | 
    mtctr   r12             # |
    bctrl                   # /
    li      r0,0x0
}

HOOK @ $807c6fb8
{
    cmplwi   r0, 0x12
    bne      _end
    mr       r7,r5	# save this for later
    
    # get arg list
    lwz      r12, 0x0(r26)
    mr       r4, r26
    addi     r3, r1, 0x298
    lwz      r12, 0x1C(r12)
    mtctr    r12
    bctrl
    
    # get args[0]
    lwz      r12,0x298(r1) # arg list
    addi     r3,r1,0x298
    li       r4,0x0
    lwz      r12,0x10(r12)
    mtctr    r12
    bctrl
    
    lwz r27, 0x4(r3) #itKind
    
    # get args[1]
    lwz      r12,0x298(r1) # arg list
    addi     r3,r1,0x298
    li       r4,0x1
    lwz      r12,0x10(r12)
    mtctr    r12
    bctrl
    
    lwz r28, 0x4(r3)
    
    # get args[2]
    lwz      r12,0x298(r1) # arg list
    addi     r3,r1,0x298
    li       r4,0x2
    lwz      r12,0x10(r12)
    mtctr    r12
    bctrl
    
    lwz r29, 0x4(r3)
    
    # get args[3]
    lwz      r12,0x298(r1) # arg list
    addi     r3,r1,0x298
    li       r4,0x3
    lwz      r12,0x10(r12)
    mtctr    r12
    bctrl

    %getFloat()
    fmr      f29,f1
    
    # get args[4]
    lwz      r12,0x298(r1) # arg list
    addi     r3,r1,0x298
    li       r4,0x4
    lwz      r12,0x10(r12)
    mtctr    r12
    bctrl
    
    %getFloat()
    fmr      f30,f1

    # get args[5]
    lwz      r12,0x298(r1) # arg list
    addi     r3,r1,0x298
    li       r4,0x5
    lwz      r12,0x10(r12)
    mtctr    r12
    bctrl
    
    %getFloat()
    fmr      f31,f1
    
    _throw:
        lwz        r12,0x0(r25)
        mr         r3, r25 # itemManageModule
        mr         r4, r27 # itKind
        mr         r5, r28 # itVariant
        mr         r6, r29 # boneIdx
        fmr        f1, f29
        fmr        f2, f30
        fmr        f3, f31
        lwz        r12,0x24(r12)
        mtctr      r12
        bctrl
        li         r3,0x1
        
        # branch to end of original func
        lis r12, 0x807C
        ori r12, r12, 0x8EA0
        mtctr r12
        bctr
        
    _end:
        # original instruction
        cmplwi r0, 0x11
}

##########################################################################
CreateThrowItem -1 For Direction Just Creates and Doesn't Throw [Kapedani]
##########################################################################
HOOK @ $807c33ec    # soItemManageModuleImp::createThrowItem
{
    lis	r3, 0x80AD      # \ Original operations
    lis	r30, 0x80AD     # /
    lis r12, 0xbf80     # \
    stw r12, 0x8(r1)    # | Check if direction is -1
    lfs f0, 0x8(r1)     # |
    fcmpu 0,f0,f28      # /        
}
op beq- 0x70 @ $807c33f0

##############################################################
CreateThrowItem passes creator centerPos as safePos [MarioDox]
##############################################################
HOOK @ $807c33ac    # soItemManageModuleImpl::createThrowItem
{
    li r4,0x0
    lwz r3,0x68(r31)    # \
    lwz r3,0xD8(r3)        # |
    lwz r3,0x10(r3)        # | soGroundModuleImpl
    lwz r12,0x0(r3)        # |
    lwz r12,0x158(r12)    # | getCenterPos
    mtctr r12        # |
    bctrl            # /
    stw r3,-0x20(r1)    # \ store Vec2f temporarily in the stack (they get replaced later anyway)
    stw r4,-0x1C(r1)    # /
    addi r4,r1,-0x20
    mr r3,r29        # get the BaseItem
    lis r12,0x8099        # \ BaseItem::setSafePos
    ori r12,r12,0xA980    # |
    mtctr r12        # |
    bctrl            # /
end:
    lwz r3,0x68(r31)    # original op
}

###############################################################
CreateThrowItem follows attack staling [MarioDox]
###############################################################
HOOK @ $807c3460    # soItemManageModuleImpl::createThrowItem
{
    mr r3,r29
    lwz r12,0x3C(r29)
    lwz r12,0x254(r12)
    mtctr r12
    bctrl
    li r3,0x1    # original op
}