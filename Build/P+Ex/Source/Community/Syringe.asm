#######################################################
Reduce InfoInstance in SSE v2 [Sammi Husky, Kapedani]
######################################################
word 0x12B440 @ $80421f9c
word 0x12B440 @ $8042204C # Great Maze save room

#################################################
Don't clear memory on game launch [Sammi Husky]
#################################################
op nop @ $801d5f64
op nop @ $801d5f68

#######################################################
run codehandler after initializing memory [Sammi Husky]
#######################################################
HOOK @ $80016c30 
{
    # __memfill
    lis r12, 0x8000
    ori r12, r12, 0x443c
    mtctr r12
    bctrl
    
    # codehandler
    lis r12, 0x8000
    ori r12, r12, 0x18a8
    mtctr r12
    bctrl
    
}

##################################################
run codehandler after loading rels [Sammi Husky]
##################################################
HOOK @ $800272b8
{
    stwu r1, -0x80(r1)
    mflr r0
    stw r0, 0x84(r1)
    stmw r3, 8(r1)
    
    # codehandler
    lis r12, 0x8000
    ori r12, r12, 0x18a8
    mtctr r12
    bctrl
    
    lmw r3, 8(r1)
    lwz r0, 0x84(r1)
    mtlr r0
    addi r1, r1, 0x80
    
    lwz r4, 0x0(r30)
}



########################################
Syringe Core Loader [Sammi Husky]
########################################
HOOK @ $800180a0
{
    # simple stack frame
    stwu r1, -0xa0(r1)
    mflr r0
    stw r0, 0xa4(r1)
    stmw r3, 0x20(r1)   # store all our registers on the stack
    bl _main            # branch to our main code, this puts data section addr in LR

    #############################
    # pseudo data section
    #############################
    word 0x817ba5a0 # Syringe heap start addr
    word 0x79b00    # \ 					    # Normally 99B00 in vBrawl
    word 0x4Cb900   # | Menu Instance sizes	    # Normally 4EB90 in vBrawl
    word 0x393400   # /						    # Normally 3B3400 in vBrawl
    
    word 0x53797269 # "Syringe"
    word 0x6E676500
    
    word 0x6476643A # "dvd:/module/sy_core.rel"
    word 0x2F6D6F64
    word 0x756C652F
    word 0x73795F63
    word 0x6F72652E
    word 0x72656C00
    #############################

_main:
    mflr r31
    
    lswi r3, r31, 16 # loads our data into r3-r6

    # Uncommented the below, as we're using BrawlEx
    lis r0, 1       # \
    sub r3, r3, r0  # | If brawlex is present, our heap start will
    sub r4, r4, r0  # | need to be 0x10000 earlier and menu instance
    sub r5, r5, r0  # | needs to be reduced by the same amount.
    sub r6, r6, r0  # /

_storeSize:
    lis r7, 0x8042
    stw r4, 0x1D84(r7) # \
    stw r5, 0x2254(r7) # | Write our menuInstance size patches
    stw r6, 0x2394(r7) # /

_createHeap:
    lis r4, 1
    addi r5, r31, 0x10 # "Syringe"
    lis r6, 0x8049
    ori r6, r6, 0x4D18
    stw r5, 0(r6)
    stw r3, 4(r6)
    stw r4, 8(r6)
    lis r12, 0x8002
    ori r12, r12, 0x59A4
    mtctr r12
    bctrl # create/[gfMemoryPool]
    
_loadModule:
    li r6, 0            # \ Zero out space on the stack for 
    stw r6, 0x8(r1)     # / gfFileIOHandle object

    # ---------------------- #
    # gfFileIOHandle::read
    # ---------------------- #
    addi r3, r1, 0x8    # our gfFileIOHandle pointer
    addi r4, r31, 0x18  # "dvd:/module/sy_core.rel"
    li r5, 0x3c         # Syringe heap id
    lis r12, 0x8002
    ori r12, r12, 0x19e0
    mtctr r12
    bctrl

    # ----------------------- #
    # gfHeapManager::getHeap
    # ----------------------- #
    li r3, 0x3c         # Syringe heap id
    lis r12, 0x8002
    ori r12, r12, 0x49cc
    mtctr r12
    bctrl
    mr r28, r3

    # ------------------------ #
    # gfFilIOHandle::getBuffer
    # ------------------------ #
    addi r3, r1, 0x8    # our gfFileIOHandle pointer
    lis r12, 0x8002
    ori r12, r12, 0x1f94
    mtctr r12
    bctrl
    mr r27, r3

    # ---------------------- #
    # gfFilIOHandle::getSize
    # ---------------------- #
    addi r3, r1, 0x8    # our gfFileIOHandle pointer
    lis r12, 0x8002
    ori r12, r12, 0x1f88
    mtctr r12
    bctrl
    mr r26, r3

    # ------------------ #
    # gfModule::create
    # ------------------ #
    mr r3, r28          # syringe heap addr we got earlier
    mr r4, r27          # rel file data buffer
    mr r5, r26          # rel filesize
    lis r12, 0x8002
    ori r12, r12, 0x64d8
    mtctr r12
    bctrl

    # ----------------- #
    # module->_prolog
    # ----------------- #
    lwz r3, 0(r3)
    lwz r12, 0x34(r3)
    mtctr r12
    bctrl

    # ------------------------ #
    # gfFileIOHandle::release
    # ------------------------ #
    addi r3, r1, 0x8    # our gfFileIOHandle pointer
    lis r12, 0x8002
    ori r12, r12, 0x1fac
    mtctr r12
    bctrl

    # clean up our stack frame
    lmw r3, 0x20(r1)
    lwz r0, 0xa4(r1)
    mtlr r0
    addi r1, r1, 0xa0

    li r5, 0x32 # original instruction
}