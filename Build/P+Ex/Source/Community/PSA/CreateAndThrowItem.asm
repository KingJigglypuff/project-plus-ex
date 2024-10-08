######################################################
Custom GenerateAndThrowItem PSA command [Sammi Husky]
######################################################
HOOK @ $807c6fb8
{
    cmplwi   r0, 0x12
    bne      _end
    
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
    
    # get args[1]
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
    
    # scalar to float conversion
    lfd        f2,0x18(r31) # 4330000080000000h
    lwz        r0,0x4(r3)
    lfs        f0,0x10(r31) # 60000
    xoris      r0,r0,0x8000
    stw        r0,0x2bc(r1)
    lfd        f1,0x2b8(r1)
    fsubs      f1,f1,f2
    fdivs      f29,f1,f0
    
    # get args[4]
    lwz      r12,0x298(r1) # arg list
    addi     r3,r1,0x298
    li       r4,0x4
    lwz      r12,0x10(r12)
    mtctr    r12
    bctrl
    
    # scalar to float conversion
    lfd        f2,0x18(r31) # 4330000080000000h
    lwz        r0,0x4(r3)
    lfs        f0,0x10(r31) # 60000
    xoris      r0,r0,0x8000
    stw        r0,0x2bc(r1)
    lfd        f1,0x2b8(r1)
    fsubs      f1,f1,f2
    fdivs      f30,f1,f0

    # get args[5]
    lwz      r12,0x298(r1) # arg list
    addi     r3,r1,0x298
    li       r4,0x5
    lwz      r12,0x10(r12)
    mtctr    r12
    bctrl
    
    # scalar to float conversion
    lfd        f2,0x18(r31) # 4330000080000000h
    lwz        r0,0x4(r3)
    lfs        f0,0x10(r31) # 60000
    xoris      r0,r0,0x8000
    stw        r0,0x2bc(r1)
    lfd        f1,0x2b8(r1)
    fsubs      f1,f1,f2
    fdivs      f31,f1,f0
    
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
