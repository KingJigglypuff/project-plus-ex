###########################################################################
Coin Games Have a Target Amount Decided By Stock Time Limit v1.1 [Kapedani]
###########################################################################

HOOK @ $80954bf8 # stOperatorRuleMelee::checkExtraRule
{
    stwu r1, -0x40(r1)
    mflr r0
    stw r0, 0x44(r1)
    stw r31, 0x3c(r1)
    stw r30, 0x38(r1)
    stw r29, 0x34(r1)
    stw r28, 0x30(r1)
    li r0, 0x0
    stw r0, 0x10(r1)
    stw r0, 0x14(r1)
    stw r0, 0x18(r1)
    stw r0, 0x1c(r1)
    stw r0, 0x20(r1)
    stw r0, 0x24(r1)
    stw r0, 0x28(r1)
    
    lwz r10, 0xcc(r3)     # \ this->resultInfo->gameRule
    lbz r9, 0x1(r10)      # / 
    cmpwi r9, 0x2         # \ skip if not Coin Mode
    bne+ coinRuleNotMet   # /
    lbz r9, 0xF(r10)      # \
    cmpwi r9, 1           # | skip if there is not currently one winner
    bne+ coinRuleNotMet   # /
    lwz r10, 0x54(r3)     # \
    cmpwi r10, 0x0        # | skip if this->eventRule is not NULL (i.e. not currently in Event mode)
    bne+ coinRuleNotMet   # /
    lis r10, 0x805a       # \
    lwz r10, 0x00e0(r10)  # | g_GameGlobal->SetRule->stockTimeMinutes
    lwz r10, 0x1c(r10)    # |
    lbz r30, 0x8(r10)     # /
    cmpwi r30, 0x0        # \ skip if 0 (i.e. infinite)
    beq- coinRuleNotMet   # /
    mulli r30, r30, 100   # Target coins is 100 * stockTimeMinutes (which matches UI)
    lis r31, 0x80b8         # \ g_ftManager
    lwz r3, 0x7C28(r31)     # /
    lis r12, 0x8081         # \
    ori r12, r12, 0x5be4    # |
    mtctr r12				        # | g_ftManager->getEntryCount()
	  bctrl	                  # /
    mr r29, r3
    b startLoop
loopThroughPlayers: 
    lwz r3, 0x7C28(r31)     # \
    subi r4, r29, 0x1       # | 
    lis r12, 0x8081         # |
    ori r12, r12, 0x5bf8    # | g_ftManager->getEntryIdFromIndex(index)
    mtctr r12               # |
    bctrl                   # /
    mr r28, r3              
    mr r4, r28              # \
    lwz r3, 0x7C28(r31)     # |
    li r5, 0x0              # |
    li r6, 0x0              # |
    lis r12, 0x8081         # | g_ftManager->getTeam(entryId, false, false)
    ori r12, r12, 0x4a40    # |
    mtctr r12               # |
    bctrl                   # /
    mr r4, r28
    mr r28, r3              
    lwz r3, 0x7C28(r31)     # \
    lis r12, 0x8081         # |
    ori r12, r12, 0x6900    # | g_ftManager->getCoin(entryId)
    mtctr r12               # |
    bctrl                   # /
    addi r10, r1, 0x10      # \
    mulli r9, r28, 0x4      # |
    lwzx r4, r10, r9        # | Add coins to team total
    add r3, r3, r4          # |
    stwx r3, r10, r9        # /
    cmpw r3, r30            # \ 
    li r3, 1                # | Return true if coin target is met
    bge- coinRuleMet        # /    
    subi r29, r29, 0x1 
startLoop:
    cmpwi r29, 0x0
    bgt- loopThroughPlayers
coinRuleNotMet:    
    li r3, 0                # Return false since coin target has not been met     
coinRuleMet:

    lwz r0, 0x44(r1)
    lwz r28, 0x30(r1)
    lwz r29, 0x34(r1)
    lwz r30, 0x38(r1)
    lwz r31, 0x3c(r1)
    mtlr r0
    addi r1, r1, 0x40
}

HOOK @ $80954c00 # stOperatorRuleMelee::decisionExtraRule
{
    li r0, 0x1          # \ Set GameDecision to GameSet
    stw r0, 0x254(r3)   # /
    li r0, 0x1          # \
    lwz r4, 0xcc(r3)    # | Set ResultInfo to having a winner
    stb r0, 0x1378(r4)  # /
    blr
}