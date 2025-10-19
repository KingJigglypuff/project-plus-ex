###############################################
Code Menu can swap characters in SSE v2 [MarioDox]
# instead of spawning you through the normal fighterChange, force rebirth to respawn you properly in SSE
###############################################
HOOK @ $806cf93c            #start/[scMelee]
{
    li r3,0x64
    li r4,0x2
    lis r12,0x8000            # \
    ori r12,r12,0xC8B8        # | __nw/[srHeapType]
    mtctr r12                # |
    bctrl                    # /
    cmpwi r3,0x0
    beq- end
    lis r12,0x8095            # \
    ori r12,r12,0x0D14        # | __ct/[stOperatorFighterChange]
    mtctr r12                # |
    bctrl                    # /
    stw r3,0x88(r24)
end:
    mr r22,r24
}

# fighterChange in SSE causes rebirth
HOOK @ $80950e90            #processBegin/[stOperatorFighterChange]
{
    lbz r0,0x6B(r3)            # original op
    lis r12,0x805B            # \
    lwz r12,0x50AC(r12)        # |
    lwz r12,0x10(r12)        # |
    lwz r12,0x0(r12)        # |
    lwz r4,0x0(r12)            # / get Scene name
    lis r3,0x7371            # sq
    ori r3,r3,0x4164        # Ad(venture)
    cmpw r3,r4
    beq- forceRebirth
    lwz r4,0xC(r12)            # get Scene name, but offset to get further parts of the string
    ori r3,r3,0x5369        # Single(Si)mple
    bne- %END%
forceRebirth:
    lis r12,0x8002            # \ getInstance/[gfSceneManager]
    ori r12,r12,0xd018        # |
    mtctr r12            # |
    bctrl                # /
    lwz r12,0x4(r3)            # gfSceneManager->currentScene
    mulli r3,r28,0x4        # \ (fighterChange's currently affected idx)
    addi r7,r3,0x6c            # | scMelee->stOperatorFighterRebirths[index]
    lwzx r12,r12,r7            # /
    cmpwi r12,0x0            # invalid
    beq- %END%
    lbz r3,0x40(r12)        # stOperatorFighterRebirth->stOperator->state
    cmpwi r3,0x0            # 0 = no rebirth process is occurring
    bne- skip
    li r3,0x5            # 5 = rebirth is happening
    stb r3,0x40(r12)
skip:
    li r0,-1
}