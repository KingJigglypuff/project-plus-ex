
#############################
Cherry Double v1.2 [Kapedani]
#############################
.alias g_GameGlobal                         = 0x805a00E0
.alias g_itManager                          = 0x80B8B7F4
.alias itManager__removeItemAll             = 0x809b2750
.alias itManager__getItemNum                = 0x809b2f64
.alias g_ftManager                          = 0x80B87C28
.alias ftManager__getFighter                = 0x80814f20
.alias ftManager__getSubOwner               = 0x80815a0c
.alias ftManager__getEntryIdFromTaskId      = 0x80815cb0
.alias ftManager__getEntryId                = 0x80815c40
.alias g_ftEntryManager                     = 0x80B87c48
.alias ftEntryManager__isValid              = 0x80823ae4
.alias ftEntryManager__getEntity            = 0x80823b24
.alias grYakumono__isSubFighter             = 0x8096f870
.alias Fighter__start                       = 0x80835f04
.alias Fighter__deactivate                  = 0x80835460
.alias soExternalValueAccesser__getStatusKind = 0x80797608
.alias soExternalValueAccesser__getPos      = 0x807973e8
.alias soExternalValueAccesser__getLr       = 0x807974c8
.alias soExternalValueAccesser__getWorkFlag = 0x80797710
.alias g_ftInstanceManager                  = 0x80b87c74
.alias ftInstanceManager__create            = 0x8082f2d4
.alias ftInstanceManager__remove            = 0x8082f3e4
.alias g_sndSystem                          = 0x805A01D0
.alias sndSystem__playSE                    = 0x800742b0
.alias g_HeapInfos                          = 0x80494958
.alias gfMemoryPool__getMaxFreeBlockSize    = 0x8002606c
.alias _float_1_0								= 0x80AD7DCC

.macro lf(<freg>, <reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lfs     <freg>, temp_Lo(<reg>)
}
.macro swd(<storeReg>, <addrReg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <addrReg>, temp_Hi
    stw     <storeReg>, temp_Lo(<addrReg>)
}
.macro lwd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lwz     <reg>, temp_Lo(<reg>)
}
.macro lbd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lbz     <reg>, temp_Lo(<reg>)
}
.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
}
.macro call(<addr>)
{
  %lwi(r12, <addr>)
  mtctr r12
  bctrl    
}
.macro branch(<addr>)
{
    %lwi(r12, <addr>)
    mtctr r12
    bctr
}

op li r0, 0x4 @ $80823ff0   # fighterCount always 4 in ftEntryManager::getEntryIdFromTaskId  (so that instance index can be retrieved from double)
op li r0, 0x4 @ $8081e224   # \ fighterCount always 4 in ftEntry::exit (so that double deloads)
op li r0, 0x4 @ $8081e280   # /
op li r6, 0x4 @ $8081ebd8   # fighterCount always 4 in ftEntry::isExistFighter (so that Final Smash can be given to primary fighter)

HOOK @ $8083ae24    # Fighter::getOwner
{
    stwu r1, -0x10(r1)
    mflr r0
    stw r0, 0x14(r1)
    stw r3, 0xc(r1)

    lwz r4, 0x10c(r3)   # fighter->entryId
    %lwd(r3, g_ftEntryManager) 
    %call (ftEntryManager__getEntity)
    lwz r12, 0x58(r3)
    cmpwi r12, 6
    blt+ notParasite
    %lwd(r12, g_ftManager)
    lbz r12, 0x91(r12)   # get entryId for parasite 
    li r3, 3
    cmpwi r12, 0xFF    # \ check if -1
    bne- parasite       # / 
notParasite:
    lwz r3, 0xc(r1)
	lwz r4, 0x28(r3)	# fighter->taskId
    %lwd(r3, g_ftManager) 			
	addi r5, r1, 0x8	# outInstanceIndex
	%call(ftManager__getEntryIdFromTaskId)    
    lwz r3, 0x8(r1)
parasite:    
    lwz r0, 0x14(r1)
    lwz r4, 0xc(r1)
    mtlr r0
    addi r1, r1, 0x10
    
    cmpwi r3, 3     # \ check if outInstanceIndex == 3 (i.e it is a double fighter)
    bne+ %end%      # /
    %lwd(r3, g_ftManager)
    lwz r4, 0x10c(r4)   # fighter->entryId
    %branch(ftManager__getSubOwner)
}
## TODO: Patch more instances to call ftManager::getSubOwner if double fighter

HOOK @ $80838378    # Fighter::endFinal
{
    lwz r4, 0x28(r27)	# fighter->taskId
    %lwd(r3, g_ftManager) 			
	addi r5, r1, 0x8	# outInstanceIndex
	%call(ftManager__getEntryIdFromTaskId) 
    lwz r3, 0x8(r1) # \
    cmpwi r3, 3     # | check if outInstanceIndex == 3 (i.e. it is a double fighter)
    bne+ end        # /
    %branch(0x80838690) # skip ending final
end:
    lwz	r12, 0x3C(r27)  # Original operation
}

op stwu r1, -0x20(r1) @ $8083cc8c
op stw r0, 0x24(r1) @ $8083cc98
HOOK @ $8083cca0    # Fighter::setNameCursor
{
    mr r31, r3      # Original operation
    stw r4, 0x10(r1) # Temp store r4
    lwz r4, 0x28(r31)	# fighter->taskId
    %lwd(r3, g_ftManager) 			
	addi r5, r1, 0x8	# outInstanceIndex
	%call(ftManager__getEntryIdFromTaskId) 
    lwz r3, 0x8(r1) # \
    cmpwi r3, 3     # | check if outInstanceIndex == 3 (i.e. it is a double fighter)
    bne+ end        # /
    %branch(0x8083cd1c) # skip ending final
end:
    mr r3, r31
    lwz r4, 0x10(r1)
    cmplwi r4, 1
}
op lwz r0, 0x24(r1) @ $8083cd1c
op addi	r1, r1, 0x20 @ $8083cd28

op stwu r1, -0x20(r1) @ $8083cbe8
op stw r0, 0x24(r1) @ $8083cbf4
HOOK @ $8083cbfc    # Fighter::setCursor
{
    mr r31, r3      # Original operation
    stw r4, 0x10(r1) # Temp store r4
    lwz r4, 0x28(r31)	# fighter->taskId
    %lwd(r3, g_ftManager) 			
	addi r5, r1, 0x8	# outInstanceIndex
	%call(ftManager__getEntryIdFromTaskId) 
    lwz r3, 0x8(r1) # \
    cmpwi r3, 3     # | check if outInstanceIndex == 3 (i.e. it is a double fighter)
    bne+ end        # /
    %branch(0x8083cc78) # skip ending final
end:
    mr r3, r31
    lwz r4, 0x10(r1)
    cmplwi r4, 1
}
op lwz r0, 0x24(r1) @ $8083cc78
op addi	r1, r1, 0x20 @ $8083cc84

HOOK @ $8087dce8    # ftStatusUniqProcessDead::decCoin
{
    lis	r31, 0x80B8  # Original operation
    lwz	r3, 0x7C28(r31) # g_ftManager			
    lwz r4, 0x8(r28)    # \ moduleAccesser->stageObject->taskId
    lwz r4, 0x28(r4)	# / 
	addi r5, r1, 0x8	# outInstanceIndex
	%call(ftManager__getEntryIdFromTaskId) 
}
HOOK @ $8087dcf8    # ftStatusUniqProcessDead::decCoin
{
    li r6, 1    # Original operation
    lwz r12, 0x8(r1) # \
    cmpwi r12, 3     # | check if outInstanceIndex == 3 (i.e it is a double fighter)
    bne+ %end%       # /
    li r6, 0    # don't subtract coins
}

# Make original and double metal cuz both get the model effect cuz they share the same model
HOOK @ $80843130    # Fighter::setMetal
{
    andi. r12, r4, 0x1
    cmplwi r12, 1    # Original operation
}
HOOK @ $80843210    # Fighter::setMetal
{
    lwz r4, 0x10c(r29)   # fighter->entryId
    %lwd(r3, g_ftEntryManager) 
    %call (ftEntryManager__getEntity)
    lwz r12, 0x58(r3)
    cmpwi r12, 6
    blt+ notParasite
    %lwd(r12, g_ftManager)
    lbz r12, 0x91(r12)   # get playerNo for parasited player
    cmpwi r12, 0xFF     # \ check if -1
    bne- parasite       # / 
notParasite:
    lwz r4, 0x28(r29)	# fighter->taskId
    %lwd(r3, g_ftManager) 			
	addi r5, r1, 0x8	# outInstanceIndex
	%call(ftManager__getEntryIdFromTaskId) 
    lwz r3, 0x8(r1) # \
    cmpwi r3, 3     # | check if outInstanceIndex == 3 (i.e it is a double fighter)
    bne+ end        # /
parasite:
    %branch(0x8084322c) # skip switching model envMap if not main fighter
end:
    lwz	r3, 0xD8(r27)   # Original operation
}
HOOK @ $80843294    # Fighter::setMetal
{
    lwz r4, 0x10c(r29)   # fighter->entryId
    %lwd(r3, g_ftEntryManager) 
    %call (ftEntryManager__getEntity)
    lwz r12, 0x58(r3)
    cmpwi r12, 6
    blt+ end
    %lwd(r12, g_ftManager)
    lbz r12, 0x91(r12)   # get playerNo for parasited player
    cmpwi r12, 0xFF     # \ check if -1
    bne- parasite       # / 
    lwz r4, 0x28(r29)	# fighter->taskId
    %lwd(r3, g_ftManager) 			
	addi r5, r1, 0x8	# outInstanceIndex
	%call(ftManager__getEntryIdFromTaskId) 
    lwz r3, 0x8(r1) # \
    cmpwi r3, 3     # | check if outInstanceIndex == 3 (i.e it is a double fighter)
    bne+ end        # /
parasite:
    %branch(0x808432b0) # skip switching model envMap if not main fighter
end:
    lwz	r3, 0xD8(r27)   # Original operation
}
HOOK @ $808432ec    # Fighter:setMetal
{
    cmpwi r30, 0x2  # \ end 
    bge+ end        # /   
    lwz r4, 0x10C(r29)  # fighter->entryId
    %lwd(r3, g_ftEntryManager)
    %call(ftEntryManager__getEntity)
    addi r27, r3, 0x34  # &ftEntry->instances.fighter

    lwz r4, 0x28(r29)	# fighter->taskId
    %lwd(r3, g_ftManager) 			
	addi r5, r1, 0x8	# outInstanceIndex
	%call(ftManager__getEntryIdFromTaskId) 
    lwz r3, 0x8(r1) # \
    cmpwi r3, 3     # | check if outInstanceIndex == 3 (i.e it is a double fighter)
    beq+ double     # /
    %lwd(r3, g_ftManager)
    lbz r4, 0x91(r3)   # get playerNo for parasited fighter
    cmpwi r4, -1       # \ check if parasite is active
    beq+ notParasite    # /
    lwz r12, 0x24(r27)  # \
    cmpw r4, r12       # | check player is parasited
    beq+ parasited     # /  
    cmpwi r12, 6        # \ check if parasite
    blt+ notParasite   # /
    b getFighter       # get parasited fighter
parasited:
    li r4, 0x6                      # \
getFighter:
    %call(ftManager__getEntryId)    # | get parasite fighter 
    cmpwi r3, -1                    # |
    beq- end                        # |
    mr r4, r3                       # /
    %lwd(r3, g_ftManager)         
    li r5, -1
    %call(ftManager__getFighter)
    b setMetal
notParasite:
    lwz r3, 0x18(r27)   # \
    cmpwi r3, 0x0       # | check if instances[3].fighter == NULL
    beq+ end            # /
    b setMetal    
double: 
    lbz r12, -0x2a(r27) # \
    mulli r12, r12, 0x8 # | instance[ftEntry->activeInstanceIndex].fighter
    lwzx r3, r27, r12   # /
setMetal:  
    addi r4, r30, 0x2   # \
    mr r5, r31          # |
    fmr f1, f31         # |
    lwz r12, 0x3c(r3)   # | fighter->setMetal(setStatus, param_3, health)
    lwz	r12, 0x2CC(r12) # |
    mtctr r12           # |
    bctrl               # /
end:
    li r3, 1    # Original operation
}
HOOK @ $8083b2d4    # Fighter::toDead
{
    mr r31, r3  # Original operation
    lwz r4, 0x28(r26)  # fighter->taskId
    %lwd(r3, g_ftManager) 			
	addi r5, r1, 0x8	# outInstanceIndex
	%call(ftManager__getEntryIdFromTaskId) 
    lwz r3, 0x8(r1) # \
    cmpwi r3, 3     # | check if outInstanceIndex == 3 (i.e it is a double fighter)
    bne+ end        # /
    %branch(0x8083b310) # skip switching setting metal if not main fighter
end:
    lwz	r12, 0x3C(r26)  # Original operation
}
HOOK @ $80835490    # Fighter::deactivate
{
    lwz r4, 0x28(r31)	# fighter->taskId
    %lwd(r3, g_ftManager) 			
	addi r5, r1, 0x8	# outInstanceIndex
	%call(ftManager__getEntryIdFromTaskId) 
    lwz r3, 0x8(r1) # \
    cmpwi r3, 3     # | check if outInstanceIndex == 3 (i.e it is a double fighter)
    bne+ end        # /
    %branch(0x808354b4) # skip switching setting metal if not main fighter
end:
    lwz	r12, 0x3C(r31)  # Original operation
}
HOOK @ $80835628    # Fighter::deactivate
{
    lwz r4, 0x28(r31)	# fighter->taskId
    %lwd(r3, g_ftManager) 			
	addi r5, r1, 0x8	# outInstanceIndex
	%call(ftManager__getEntryIdFromTaskId) 
    lwz r3, 0x8(r1) # \
    cmpwi r3, 3     # | check if outInstanceIndex == 3 (i.e it is a double fighter)
    bne+ end        # /
    %branch(0x8083564c) # skip switching setting metal if not main fighter
end:
    lwz	r12, 0x3C(r31)  # Original operation
}

HOOK @ $80835610    # Fighter::deactivate
{
    lwz	r29, 0x60(r31)  # Original operation
    cmpwi r3, 0xBD  # \ 
    beq- %end%      # | check if dead
	cmpwi r3, 0x10B	# |
	beq- %end% 		# / 
    lwz r28, 0x10(r1)   # Temp free stack to make room for pos
    addi r3, r1, 0x8
    mr r4, r31
    %call(soExternalValueAccesser__getPos)
    li r4, 0x36                 # \
    addi r5, r1, 0x8            # |
    li r6, 0                    # |
    li r7, 0                    # |
    %lf(f1, r12, _float_1_0)    # |
    lwz r3, 0xd8(r29)           # | moduleAccesser->moduleEnumeration->soEffectModule->req(0x36, &pos, NULL, 0, -1, 1.0)
    lwz r3, 0x88(r3)            # |
    lwz r12, 0x0(r3)            # |
    lwz r12, 0x20(r12)          # |
    mtctr r12                   # |
    bctrl                       # /
    stw r28, 0x10(r1)   # Restore on stack
}

HOOK @ $8082374c    # ftEntry::process
{   
    lwz r3, 0x4c(r29)  # \
    cmpwi r3, 0x0      # | check if ftEntry->instances[3].fighter == NULL
    beq+ end           # /
    %call(soExternalValueAccesser__getStatusKind)
    cmpwi r3, 0xBD  # \ check if double is dead
    bne+ end        # /
    lwz r3, 0x4c(r29)
    %call(Fighter__deactivate)
    %lwi(r3, g_ftInstanceManager)
    lwz r4, 0x4c(r29)
    %call(ftInstanceManager__remove)
    li r12, 0           # \ ftEntry->instances[3].fighter = NULL
    stw r12, 0x4c(r29)  # /
end:
    lbz	r0, 0x11(r29)   # Original operation
}
HOOK @ $808206f0    # ftEntry::startChange
{
    lwz r3, 0x4c(r29)  # \
    cmpwi r3, 0x0      # | check if ftEntry->instances[3].fighter == NULL
    beq+ %end%         # /
    %call(Fighter__deactivate)
    %lwi(r3, g_ftInstanceManager)
    lwz r4, 0x4c(r29)
    %call(ftInstanceManager__remove)
    li r12, 0           # \ ftEntry->instances[3].fighter = NULL
    stw r12, 0x4c(r29)  # /
    stw	r26, 0x10(r1)   # Original operation
}
HOOK @ $8081f7c0    # ftEntry::restart
{
    lwz r3, 0x4c(r30)  # \
    cmpwi r3, 0x0      # | check if ftEntry->instances[3].fighter == NULL
    beq+ end           # /
    %call(Fighter__deactivate)
    %lwi(r3, g_ftInstanceManager)
    lwz r4, 0x4c(r30)
    %call(ftInstanceManager__remove)
    li r12, 0           # \ ftEntry->instances[3].fighter = NULL
    stw r12, 0x4c(r30)  # /
end:
    lwz	r3, 0x28(r30)   # Original operation
}

HOOK @ $8082040c    # ftEntry::setFinal
{
    lwz	r3, 0(r3)   # Original operation
    stw r3, 0x8(r1)
    lwz r3, 0x4c(r3)    # \
    cmpwi r3, 0x0       # | check if ftEntry->instances[3].fighter == NULL
    beq+ end            # /
    %call(Fighter__deactivate)
    lwz r3, 0x8(r1)
    lwz r4, 0x4c(r3)
    %lwi(r3, g_ftInstanceManager)
    %call(ftInstanceManager__remove)
end:
    lwz r3, 0x8(r1)
    li r12, 0           # \
    stw r12, 0x4C(r3)   # / ftEntry->instances[3].fighter = NULL
}
HOOK @ $80820440    # ftEntry::setFinal
{
    %lwd(r3, g_itManager)
    li r4, 0x55
    li r5, 0
    li r6, -1
    %call(itManager__removeItemAll)
    
    %lwi(r11, g_HeapInfos)  # \
    lwz r3, 0x1F4(r11)      # / g_HeapInfo[FighterTechqniq].memoryPool
    %call(gfMemoryPool__getMaxFreeBlockSize)
    %lwi(r11, g_HeapInfos)  # \
    lwz r4, 0x1F8(r11)      # / g_HeapInfo[FighterTechqniq].size
    sub r12, r4, r3     # \ check if there's free space for final smash
    cmpwi r12, 0x100    # /
    lwz r3, 0x28(r30)   # \ ftOwner->data
    lwz r11, 0x0(r3)    # /
    lbz r12, 0x1F(r11)  # 
    blt+ isFree
    andi. r12, r12, 0xEF    # \ set unused flag to signify waiting for Final Smash
    stb r12, 0x1F(r11)      # /
    %branch(0x808204c0)
isFree:
    ori r12, r12, 0x10  # \ set flag back to signify no longer waiting for Final Smash
    stb r12, 0x1F(r11)  # /
    mr r3, r27  # Original operation
}
HOOK @ $8081c934    # ftOwner::getFinalContinue
{
    lbz	r0, 0x1F(r3)    # Original operation
    rlwinm. r12,r0,28,31,31 # \
    li r3, 0x1              # | return true if waiting for final smash
    beqlr+                  # /
}

HOOK @ $80844378    # Fighter::touchItem 
{
    bctrl   # Original operation
    cmpwi r3, 0x55      # \
    bne- %end%          # |
    lwz r12, 0x8c4(r29) # | check if Double Cherry
    cmpwi r12, 0x0      # |
    bne- %end%          # /
    # TODO: Move this in a function like setCurry so other things can create a double

    li r28, 0x1
    li r27, 0x1

    lwz r4, 0x10c(r25)  # \ ftCreate.entry = fighter->entryId
    stw r4, 0x20(r1)    # /
    lwz r12, 0x110(r25) # \ ftCreate.kind = fighter->kind
    stw r12, 0x24(r1)   # / 
    %lwd(r23, g_ftManager)
    lwz r3, 0x154(r23)      # ftManager->entryManager
    %call(ftEntryManager__getEntity)
    lwz r12, 0x4c(r3)   # \ 
    cmpwi r12, 0x0      # | check if ftEntry->instances[3].fighter == NULL (i.e. double already exists)
    bne- %end%          # /
    mr r24, r3

    lwz r3, 0x60(r25)   # \
    lwz r3, 0xd8(r3)    # | 
    lwz r3, 0x4(r3)     # |
    lwz r12, 0x8(r3)    # | fighter->moduleAccesser->moduleEnumeration->modelModule->isEnvMap(false)
    lwz r12, 0x130(r12) # |
    mtctr r12           # |
    bctrl               # /
    stw r3, 0x1c(r1)

    lwz r11, 0x158(r23)     # \
    lwz r11, 0x0(r11)       # |
    lwz r12, 0x18(r24)      # | 
    mulli r12, r12, 0x4d4   # | ftManager->slotManager->slots[ftEntry->slotIndex].instanceHeapType
    add r12, r11, r12       # |
    lwz r12, 0x164(r12)     # /
    stw r12, 0x28(r1)   # ftCreate.instanceHeapType = instanceHeapType
    %lwi(r11, g_HeapInfos)  # \
    mulli r12, r12, 0x10    # | g_HeapInfo[instanceHeapType]
    add r23, r11, r12       # /
    lwz r3, 0x4(r23)    # heapInfo.memoryPool
    %call(gfMemoryPool__getMaxFreeBlockSize)
    li r12, 31
    stw r12, 0x2c(r1)   # ftCreate.nwModelInstanceHeapType = Heaps::FighterTechqniq   
    lwz r11, 0x8(r23)    # \ 
    sub r10, r11, r3     # | 
    mulli r10, r10, 0x3  # | check if (heapInfo.size - maxFreeBlockSize)*(3/2) < maxFreeBlockSize
    li r9, 0x2           # |
    divw r10, r10, r9    # |
    stw r10, 0x78(r1)    # /
    b compareSpace
useFighterTechqniq:
    %lwi(r11, g_HeapInfos)  # \
    mulli r12, r12, 0x10    # | g_HeapInfo[instanceHeapType]
    add r11, r11, r12       # /
    lwz r3, 0x4(r11)    # heapInfo.memoryPool
    %call(gfMemoryPool__getMaxFreeBlockSize)
    lwz r10, 0x78(r1)   # \
compareSpace:
    cmpw r10, r3        # | check if < maxFreeBlockSize
    bgt+ notEnoughSpace # /     
enoughSpace:
    lwz r12, 0x28(r1)   # \ ftCreate.nwMotionInstanceHeapType = ftCreate.instanceHeapType
    stw r12, 0x30(r1)   # /

    li r4, 0x0          # \
    lwz r3, 0x60(r25)   # |
    lwz r3, 0xd8(r3)    # | 
    lwz r3, 0x4(r3)     # |
    lwz r12, 0x8(r3)    # | fighter->moduleAccesser->moduleEnumeration->modelModule->switchEnvMap(false)
    lwz r12, 0x134(r12) # |
    mtctr r12           # |
    bctrl               # /
    %lwi(r3, g_ftInstanceManager)
    addi r4, r1, 0x20
    %call(ftInstanceManager__create)
    cmpwi r3, 0x0
    bne+ fighterCreated
notEnoughSpace:
    lwz r12, 0x28(r1)   # \ check if ftCreate.instanceHeapType is already FighterTechqniq
    cmpwi r12, 31       # /
    li r12, 31          # \ ftCreate.instanceHeapType = FighterTechqniq
    stw r12, 0x28(r1)   # /
    bne+ useFighterTechqniq
    b fighterNotCreated
fighterCreated:
    stw r3, 0x4c(r24)   # ftEntry->instances[3].fighter = newFighter
    lwz r12, 0x110(r3)  # \
    stw r12, 0x48(r24)  # / ftEntry->instances[3].kind = newFighter->kind
    lwz r12, 0x3c(r3)   # \
    lwz r12, 0x290(r12) # | newFighter->activate()
    mtctr r12           # |
    bctrl               # /
    addi r3, r1, 0x68
    mr r4, r25
    %call(soExternalValueAccesser__getPos)
    li r4, 0x0          # \
    lwz r3, 0x60(r25)   # |
    lwz r3, 0xd8(r3)    # |
    lwz r3, 0x38(r3)    # | fighter->moduleAccesser->moduleEnumeration->damageModule->getDamage(0)
    lwz r12, 0x8(r3)    # |
    lwz r12, 0x50(r12)  # |
    mtctr r12           # |
    bctrl               # /
    stfs f1, 0x74(r1)
    mr r3, r25
    %call(soExternalValueAccesser__getLr)
    lis r12, 0x40a0     # \
    stw r12, 0x78(r1)   # | Make 5.0 on stack
    lfs f3, 0x78(r1)    # /
    lfs f4, 0x6C(r1)    # \
    fmuls f3, f1, f3    # | pos.y -= lr*5
    fsubs f4, f4, f3    # |
    stfs f4, 0x6C(r1)   # /

    lwz r3, 0x4c(r24)       # \
    lfs f2, 0x74(r1)        # |
    addi r4, r1, 0x68       # | newFighter->start(&pos, lr, damage, 1, 0)
    li r5, 1                # |
    li r6, 0                # |
    %call(Fighter__start)   # /

    li r4, 0x1F5E
	%lwd (r3, g_sndSystem)      # \
    li r5, -0x1                 # |
    li r6, 0x0                  # | g_sndSystem->playSE(0x1F5E, -0x1, 0x0, 0x0, -0x1);
    li r7, 0x0                  # |
    li r8, -0x1                 # |
    %call (sndSystem__playSE)   # /

    mr r3, r25 
    %lwi(r4, 0x12000012)
    %call(soExternalValueAccesser__getWorkFlag)
    cmpwi r3, 0
    beq+ fighterNotCreated
    lis r12, 0xbf80     # \
    stw r12, 0x78(r1)   # | make -1.0 on stack
    lfs f1, 0x78(r1)    # /
    li r4, 1            # \
    li r5, -1           # |
    lwz r3, 0x4c(r24)   # |
    lwz r12, 0x3c(r3)   # | fighter->setMetal(-1.0, 1, -1)
    lwz r12, 0x2cc(r12) # | 
    mtctr r12           # |
    bctrl               # /

fighterNotCreated:

    lwz r4, 0x1c(r1)    # \
    lwz r3, 0x60(r25)   # |
    lwz r3, 0xd8(r3)    # | 
    lwz r3, 0x4(r3)     # |
    lwz r12, 0x8(r3)    # | fighter->moduleAccesser->moduleEnumeration->modelModule->switchEnvMap(envMap)
    lwz r12, 0x134(r12) # |
    mtctr r12           # |
    bctrl               # /
}

op sth r31, 0x7C(r27) @ $80812da8  # Initialize field 0x7D for ftManager::__ct (use for keeping track number of doubles)

HOOK @ $8082f384    # ftInstanceManager::create
{
    lwz	r11, 0x1C(r1)   # \
    cmpwi r11, 0x0      # | Don't add to instanceInfoArray if fighter is null (i.e. failed to create)
    beq- %end%          # /
    bctrl   # Original operation
    lwz r12, 0x14(r1)    # \
    cmpwi r12, 31       # | check if ftCreate.nwModelInstanceHeapType == Heaps::FighterTechqniq 
    bne+ %end%          # /
    %lwd(r12, g_ftManager)  # \
    lbz r11, 0x7D(r12)      # | ftManager->numDoubles++
    addi r11, r11, 0x1      # |
    stb r11, 0x7D(r12)      # /
}
HOOK @ $8082f464    # ftInstanceManager::remove
{
    lwz r30, 0x10C(r3)  # fighter->entryId
    lwz r12, 0x28(r3)   # fighter->taskId
    stw r12, 0x8(r1)
    bctrl   # Original operation
    mr r4, r30      # entryId
    %lwd(r3, g_ftEntryManager)
    %call(ftEntryManager__getEntity)
    addi r30, r3, 0x34  # &ftEntry->instances.fighter

    lwz r4, 0x8(r1)          # taskId
    %lwd(r3, g_ftManager) 			
	addi r5, r1, 0x8	# outInstanceIndex
	%call(ftManager__getEntryIdFromTaskId) 
    lwz r3, 0x8(r1) # \
    cmpwi r3, 3     # | check if outInstanceIndex == 3 (i.e it is a double fighter)
    beq+ double     # /
    %lwd(r3, g_ftManager)
    lbz r4, 0x91(r3)   # get playerNo for parasited fighter
    cmpwi r4, -1       # \ check if parasite is active
    beq+ end    # /
    lwz r12, 0x24(r30)  # \
    cmpw r4, r12       # | check player is parasited
    beq+ parasited     # /  
    cmpwi r12, 6        # \ check if parasite
    blt+ end            # /
    b getFighter       # get parasited fighter
parasited:
    li r4, 0x6                      # \
getFighter:
    %call(ftManager__getEntryId)    # | get parasite fighter 
    cmpwi r3, -1                    # |
    beq- end                        # |
    mr r4, r3                       # /
    %lwd(r3, g_ftManager)         
    li r5, -1
    %call(ftManager__getFighter)
    b rebindAnim
double: 
    %lwd(r12, g_ftManager)  # \
    lbz r11, 0x7D(r12)      # | ftManager->numDoubles--
    subi r11, r11, 0x1      # |
    stb r11, 0x7D(r12)      # /
    lbz r12, -0x2a(r30) # \
    mulli r12, r12, 0x8 # | instance[ftEntry->activeInstanceIndex].fighter
    lwzx r3, r30, r12   # /
rebindAnim:  
    cmpwi r3, 0x0   # \ check if fighter is null
    beq+ end        # /
    li r4, 0x0          # \
    lwz r5, 0x60(r3)    # | 
    lwz r3, 0xd8(r5)    # |
    lwz r3, 0x8(r3)     # | fighter->moduleAccesser->moduleEnumeration->motionModuleImpl->notifyEventConstructInstance(0, fighter->moduleAccesser)
    lwz r12, 0x0(r3)    # |
    lwz r12, 0x208(r12) # |
    mtctr r12           # |
    bctrl               # /
end:
}

HOOK @ $809b0a38    # itManager::checkCreatableItem
{
    cmpwi r27, 0x55 # \
    bne+ end        # | check if Double Cherry
    cmpwi r28, 0    # |
    bne+ end        # /
    %lwd(r12, g_ftManager)  # \
    lwz r12, 0x74(r12)      # | check if there is a player with a Final Smash
    cmpwi r12, -1           # |
    bne+ notCreatable       # /
    %lwd(r3, g_itManager)
    li r4, 0x55
    li r5, 0
    li r6, -1
    li r7, -1
    %call(itManager__getItemNum)
    li r10, 0x2     # default max num of cherries
    %lwd(r12, g_GameGlobal)
    lwz r12, 0x8(r12)
    lwz r12, 0x8(r12)         # \
    rlwinm r12,r12,14,29,31   # | check if globalModeMelee->meleeInitData.numPlayers < 4
    cmpwi r12,4               # |
    blt- lessThanFourPlayers  # /
    li r10, 0x1     # reduce number of cherries to prevent lag
lessThanFourPlayers:
    %lwd(r12, g_ftManager)
    lbz r11, 0x7D(r12)  # \
    add r3, r3, r11     # | check if the current number of doubles and number of cherries do not exceed max num of cherries
    cmpw r3, r10        # |
    bge+ notCreatable   # /
    %branch(0x809b0ed0)
notCreatable:
    %branch(0x809b1088)
end: 
    cmpwi r27, 34   # Original operation
}

HOOK @ $80812db8    # ftManager::__ct
{   
    stb	r31, 0x90(r27)  # Original operation
    stb r30, 0x91(r27)  # Initialize ftSlotId for parasite copy
}

## TODO: Get center position so that clone doesn't fall through stage?
## TODO: Investigate magnifier making both fighters invisible to re-enable magnifier?
## TODO: All Star VS - prevent fighter switching if first fighter dies
## TODO: Check behaviour with Manaphy
## TODO: Check if Pokemon Trainer conflicts anywhere
