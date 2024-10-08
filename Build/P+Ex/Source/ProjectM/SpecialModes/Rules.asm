##########################################################
Special modes rules menu change cosmetics REDUX [Kapedani]
##########################################################
HOOK @ $806a66b0  # muProcRule1::init
{  
  lis r26, 0x806a 
  lis r29, 0x800b       # \ store function pointer for MuObject::changeTexPatAnimN
  ori r29, r29, 0x4c14  # /
  lwz r28, 0x64c(r27)   # this->muObjects
  lis r25, 0x805A       # \
  lwz	r25, 0x00E0(r25)  # | g_GameGlobal->setRule->spMeleeOption1
  lwz r25, 0x1C(r25)    # |
  lbz r12, 0x18(r25)    # /
  cmpwi r12, 0x2        # \ Check if stamina mode
  bne+ checkForZTD      # /
  lwz r3, 0x10(r28)     # \
  ori r4, r26, 0xD610   # | muObjects[0x4]->changeTexPatAnimN("126_TopN")
  mtctr r29             # |
  bctrl                 # /
checkForZTD:
  lbz r12, 0x1A(r25)    # \
  cmpwi r12, 0x2        # | Check if ZTD/regen mode
  bne+ end              # /
  lwz r3, 0x8(r28)      # \
  ori r4, r26, 0xD5E0   # | muObjects[0x2]->changeTexPatAnimN("124_TopN")
  mtctr r29             # |
  bctrl                 # /
end:
  li r3, 0x1   # Original operation
}

HOOK @ $806a8290 # muProcRule1::setMessage
{
  addi r4, r4, 10       # Original operation
  lis r12, 0x805A       # \
  lwz	r12, 0x00E0(r12)  # | g_GameGlobal->setRule->spMeleeOption1
  lwz r12, 0x1C(r12)    # |
  lbz r12, 0x18(r12)    # /
  cmpwi r12, 0x2        # \ Check if stamina mode
  bne+ %end%            # /
  addi r4, r4, 17       # Add to get to stamina description msg indices
}
HOOK @ $806a827c # muProcRule1::setMessage
{
  addi r4, r4, 6        # Original operation
  lis r12, 0x805A       # \
  lwz	r12, 0x00E0(r12)  # | g_GameGlobal->setRule->spMeleeOption3
  lwz r12, 0x1C(r12)    # |
  lbz r12, 0x1A(r12)    # /
  cmpwi r12, 0x2        # \ Check if ztd/regen mode
  bne+ %end%            # /
  addi r4, r4, 26       # Add to get to frame control for ztd/regen description msg indices
}

##############################################################################################################
Coin and Time Games Have a Target Amount and Stock Time Limit Handles Time Limit for All Rules v1.3 [Kapedani]
##############################################################################################################
.alias g_GameGlobal                 = 0x805a00E0

.macro lwd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lwz     <reg>, temp_Lo(<reg>)
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

HOOK @ $806a6080  # muProcRule1::init
{
  addi r5, r29, 0x858   # \
  lbz r12, 0x66c(r27)   # | 
  cmpwi r12, 0x0        # | If time rule then use num5N instead of num4N
  bne- %end%            # |
  addi r5, r29, 0x860   # /
}
HOOK @ $806a609c  # muProcRule1::init
{
  addi r5, r29, 0x860   # \
  lbz r12, 0x66c(r27)   # |
  cmpwi r12, 0x0        # | If time rule then use num4N instead of num2N
  bne- %end%            # |
  addi r5, r29, 0x868   # /
}
HOOK @ $806a60d0  # muProcRule1::init
{
  lwz	r3, 0x064C(r27)     # \
  addi r5, r29, 0x868     # |
  lbz r12, 0x66c(r27)     # | If time rule then skip extra digits
  cmpwi r12, 0x0          # |
}                         # |
op beq+ 0x34 @ $806a60d4  # /
op nop @ $806a60cc  # Skip num3N colon
HOOK @ $806a75e0  # muProcRule1::selectProc
{
  addi r5, r30, 0x858     # \
  lbz r12, 0x66c(r23)     # |
  cmpwi r12, 0x0          # | If time rule then use num5N instead of num4N
  bne- %end%              # |
  addi r5, r30, 0x860     # /
}
HOOK @ $806a75fc  # muProcRule1::selectProc
{
  addi r5, r30, 0x860     # \
  lbz r12, 0x66c(r23)     # |
  cmpwi r12, 0x0          # | If time rule then use num4N instead of num2N
  bne- %end%              # |
  addi r5, r30, 0x868     # /
}
HOOK @ $806a7630  # muProcRule1::selectProc
{
  lwz	r3, 0x064C(r23)     # \
  addi r5, r30, 0x868     # |
  lbz r12, 0x66c(r23)     # | If time rule then skip extra digits
  cmpwi r12, 0x0          # |
}                         # |
op beq+ 0x34 @ $806a7634  # /
op nop @ $806a762c  # Skip num3N colon 
HOOK @ $806a73a4 # muProcRule1::selectProc
{
  li r11, 8                 # \
  %lwd (r12, g_GameGlobal)  # | g_GameGlobal->SetRule->stockTimeMinutes = 8
  lwz r12, 0x1c(r12)        # |
  stb r11, 0x8(r12)         # /
  lwz	r3, 0x654(r23)  # Original operation
}

HOOK @ $806a5bbc # muProcRule1::__ct
{
  stb	r4, 0x6A6(r29) # Original operation         
  stb r4, 0x6AA(r29) # initialize bool to keep track of whether to silence sfx (when sending fake inputs)
}
HOOK @ $806a73ec  # muProcRule1::selectProc
{
  li r11, 2                 # \
  %lwd (r12, g_GameGlobal)  # | g_GameGlobal->SetRule->stockTimeMinutes = 2
  lwz r12, 0x1c(r12)        # |
  stb r11, 0x8(r12)         # /
  li r12, 1             # \ Set score to win (formerly Time Limit) as 1 
  stb r12, 0x66D(r23)   # / 
  li r12, 1             # \
  sth r12, 0x42(r23)    # / Set current entry index to 1 (i.e. Time Limit)
  li r12, 0             # \
  stb r12, 0x6AA(r23)   # / set to silence sfx
  mr r3, r23            # \
  li r4, 4              # |
  lwz r12, 0x668(r23)   # |
  lwz r12, 0x20(r12)    # |
  mtctr r12             # | 
  bctrl                 # |
  mr r3, r23            # | Send fake left and then down input to set Score to infinite and reset digit placement
  li r4, 1              # |
  lwz r12, 0x668(r23)   # |
  lwz r12, 0x20(r12)    # |
  mtctr r12             # |
  bctrl                 # /
  li r12, 1             # \ set to unsilence sfx
  stb r12, 0x6AA(r23)   # /
  lwz	r3, 0x654(r23)  # Original operation
}
HOOK @ $806a8130  # muProcRule1::selectProc
{
  li r4, 0  # Original operation
  lbz r12, 0x6AA(r23) # \
  cmpwi r12, 0x0      # | disable sfx if set to silent
  bne+ %end%          # |
  li r4, -1           # /
}
HOOK @ $806a8188  # muProcRule1::selectProc
{
  li r4, 37  # Original operation
  lbz r12, 0x6AA(r23) # \
  cmpwi r12, 0x0      # | disable sfx if set to silent
  bne+ %end%          # |
  li r4, -1           # /
}

HOOK @ $806a84d4  # muProcRule2::__ct
{
  stb	r0, 0x699(r29)  # Original operation
  stb r0, 0x671(r29)  # initialize bool to keep track of whether to silence sfx (when sending fake inputs)
}
HOOK @ $806a8ca8  # muProcRule2::init
{
  lbz r29, 0x66c(r28)   # get desired time limit
  li r12, 0x0           # \ set time limit as infinite
  stb r12, 0x66c(r28)   # /
  stb r12, 0x671(r28)   # set to silence sfx
  mr r3, r28            # \
  li r4, 8              # |
  lwz r12, 0x668(r28)   # | Send fake right input to reset digit placement
  lwz r12, 0x20(r12)    # | 
  mtctr r12             # | 
  bctrl                 # /
  addi r12, r29, 1      # \ set time limit as desired time limit + 1
  stb r12, 0x66c(r28)   # /
  mr r3, r28            # \
  li r4, 4              # |
  lwz r12, 0x668(r28)   # | Send fake left input to set to desired time limit
  lwz r12, 0x20(r12)    # | 
  mtctr r12             # | 
  bctrl                 # /
  li r12, 0x1           # \ set to unsilence sfx
  stb r12, 0x671(r28)   # /
  stb r29, 0x66c(r28)   # set desired time limit 
  addi r11, r1, 64  # Original operation
}
HOOK @ $806aa2fc  # muProcRule2::selectProc
{
  li r4, 37  # Original operation
  lbz r12, 0x671(r25) # \
  cmpwi r12, 0x0      # | disable sfx if set to silent
  bne+ %end%          # |
  li r4, -1           # /
}

HOOK @ $80684680  # muSelCharTask::getDefaultRuleFromGlobal
{
  lbz	r0, 0x3(r30)  # \
  cmpwi r0, 0x0     # | Set stock time minutes as default if score to win (formally time minutes) is infinite
  bne+ %end%        # |
  lbz	r0, 0x8(r30)  # /
}
HOOK @ $806850f0  # muSelCharTask::setRuleNumToGlobal
{
  lbz r12, 0x3(r4)  # \
  cmpwi r12, 0x0    # | Check if score to win (formally timeMinutes) is infinite
  beq+ saveTime     # /
  stb r0, 0x3(r4)   # Store as score to win
  b %end%
saveTime:
  stb r0, 0x8(r4)   # Store as stock time minutes
}
HOOK @ $80684c6c # muSelCharTask::setToGlobal
{
  lbz r12, 0x3(r3)  # \
  cmpwi r12, 0x0    # | Check if score to win (formally timeMinutes) is infinite
  beq+ saveTime     # / 
  stb r0, 0x3(r3)   # Store as score to win
  b %end%
saveTime:
  stb r0, 0x8(r3)   # Store as stock time minutes
}
HOOK @ $80687530  # muSelCharTask::setState
{
  lbz r12, 0x3(r3)  # \
  cmpwi r12, 0x0    # | Check if score to win (formally timeMinutes) is infinite
  beq+ saveTime     # / 
  stb r0, 0x3(r3)   # Store as score to win
  b %end%
saveTime:
  stb r0, 0x8(r3)   # Store as stock time minutes
}
HOOK @ $8068f408  # muSelCharTask::dispRule
{
  lwzx r31, r3, r0  # Original operation (get msg index)
  lwz r12, 0x5d4(r29) # \ Skip if stock battle
  cmpwi r12, 1        # |
  beq+ %end%          # /
  lis r12, 0x805A     # \
  lwz r12, 0xe0(r12)  # | g_GameGlobal->SetRule->timeMinutes (i.e scoreToWin)
  lwz r12, 0x1c(r12)  # |
  lbz r12, 0x3(r12)   # /
  cmpwi r12, 0        # \ Check if score to win is infinite
  beq+ %end%          # /
  addi r31, r31, 29   # Add 29 to get new index (should be 33 and 35)
}


HOOK @ $8005048c # gmGlobalModeMelee::gmSetRuleToGlobalModeMelee
{   
    lbz r0, 0x3(r31)    # Get Time option from gmSetRule as Time instead
    stb r0, 0x11(r29)   # Store in unused byte of gmMeleeInitData so it can be used for target amount
    lbz r0,0x8(r31)     # Use stockTimeMinutes as Time
}
HOOK @ $800504c4 # gmGlobalModeMelee::gmSetRuleToGlobalModeMelee
{   
    lbz r0, 0x3(r31)    # Get Time option from gmSetRule
    stb r0, 0x11(r29)   # Store in unused byte of gmMeleeInitData so it can be used for target amount
    lbz r0,0x8(r31)     # Use stockTimeMinutes as Time instead
}
HOOK @ $800505ec # gmGlobalModeMelee::gmSetRuleToGlobalModeMelee
{
  li r4, 0x0          # \
  lbz r12, 0x11(r29)  # | 
  cmpwi r12, 0x0      # | Toggle score display if score to win is set
  beq- %end%          # |
  li r4, 0x1          # /
}
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
    lbz r8, 0x1(r10)      # / 
    lbz r9, 0xF(r10)      # \
    cmpwi r9, 1           # | skip if there is not currently one winner
    bne+ scoreRuleNotMet  # /
    lwz r10, 0x44(r3)     # \ Get unused byte of gmMeleeInitData from this->condition so that it can be used as target amount
    lbz r30, 0x11(r10)    # /
    cmpwi r30, 0x0        # \ skip if 0 (i.e. infinite)
    beq- scoreRuleNotMet  # /
    cmpwi r8, 0x2         # \ Check if coin mode
    bne- notCoinMode      # /
    mulli r30, r30, 100   # Target coins is 100 * stockTimeMinutes (which matches UI)
  notCoinMode:
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
    lis r11, 0x8081         # | g_ftManager->getRankPoint(entryId)
    ori r12, r11, 0x5b88    # |
    mtctr r12               # |
    bctrl                   # /
    addi r10, r1, 0x10      # \
    mulli r9, r28, 0x4      # |
    lwzx r4, r10, r9        # | Add score to team total
    add r3, r3, r4          # |
    stwx r3, r10, r9        # /
    cmpw r3, r30            # \ 
    li r3, 1                # | Return true if score target is met
    bge- scoreRuleMet       # /    
    subi r29, r29, 0x1 
startLoop:
    cmpwi r29, 0x0
    bgt- loopThroughPlayers
scoreRuleNotMet:    
    li r3, 0                # Return false since coin target has not been met     
scoreRuleMet:

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


## TODO: Display score objective on SSS and Results screen? as well as in match at top right