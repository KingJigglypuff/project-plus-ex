############################################################
BrawlEx Clone Engine v2.0.0.0 Subspace Fix (RSBE.Ver) [JOJI]
############################################################
* C2026074 00000003
* 3CA08000 7C042840
* 41810008 48000008
* 80A40008 00000000
* C2026078 00000006
* 3C808001 7C042840
* 41800020 3C808041
* 60846B70 90840000
* 38800000 6084F060
* 3CA08000 48000008
* 80850004 00000000
* 20416B70 80416B70
* 04416B70 00000000
* 077BA5A0 000000A0
* 80B84500 817BA5A0
* 817DA5A0 00020000
* 004C00CC 00010001
* 00010F20 00010F20
* 817BA600 00CCCCCC
* 00000000 00000000
* 00000000 00000000
* CCCCCCCC CCCCCCCC
* CCCCCCCC CCCCCCCC
* CCCCCCCC CCCCCCCC
* CCCCCCCC CCCCCCCC
* CCCCCCCC CCCCCCCC
* 817BA5A0 00000000
* 817BA620 00000000
* 00000000 CCCCCCCC
* CCCCCCCC CCCCCCCC
* 817BA5A0 0000F060
* 817BA600 00000000
* 00000000 CCCCCCCC
* CCCCCCCC CCCCCCCC
* E0000000 80008000

#############################################################################
SSEEx Levels [Kapedani]
#############################################################################

.alias levelIdForVsFighter = 0x5A
.alias levelIdForVsBoss = 0x50
.alias levelIdForVsZako = 0x46
.alias levelIdForSavePoint = 0x45

.alias levelIdForVsZakoMinusOne = levelIdForVsZako - 1

###########################################################
# Subspace Level Ids between Ranges are Non-Normal Levels #
###########################################################

# 0xXX5A0000 (XX900000) to 0xXX63631A (XX9999z) -> Vs. Fighter
# 0xXX500000 (XX800000) to 0xXX59631A (XX8999z) -> Vs. Boss
# 0xXX460000 (XX700000) to 0xXX4F631A (XX7999z) -> Vs. Zako (enemies)
# 0xXX450000 (XX690000) to 0xXX45631A (XX6999z) -> Savepoint

HOOK @ $806e8b34    # During sqAdventure state 0x1b
{   
    lwz r3, 0x26C(r1)                   # Original operation
    rlwinm r5, r4, 16, 24, 31           # (advSaveData->jumpLevelId >> 16) & 0x000000ff 
    cmplwi r5, levelIdForVsFighter      # Check if level id is in the desired range
    blt+ checkIfVsBoss
    li r0, 0x2b         # \ 
    stw r0, 0x8(r28)    # | 
    li r0, 0x4          # | Set sqAdventure state for VS Fighter
    stb r0, 0x21(r28)   # |
    li r0, 0xf          # /
    b applySqAdventureState
checkIfVsBoss:
    cmplwi r5, levelIdForVsBoss      # Check if level id is in the desired range
    blt+ checkIfVsZako
    li r0, 0x14         # Set sqAdventure state for VS Boss
    b applySqAdventureState
checkIfVsZako:
    cmplwi r5, levelIdForVsZako      # Check if level id is in the desired range
    blt+ checkIfSavePoint
    li r0, 0x17         # Set sqAdventure state for VS Zako
    b applySqAdventureState
checkIfSavePoint:
    cmplwi r5, levelIdForSavePoint   # Check if level id is in the desired range
    blt+ %END%
    li r0, 0x7          # \  
    stb r0, 0x21(r28)   # /
    li r0, 0x1A         # Set sqAdventure state for Savepoint
applySqAdventureState:
    stw r0, 0xc(r28)    # Apply sqAdventure state
}

#############################################################################################
#     End of Vs. Stages in Range Set Door Id Based on Current Level and Last Door Index    #
#############################################################################################

# If level id sends in 26 (z) continue SSE flow as normal (i.e. don't go to another custom level and continue sequence as normal)

HOOK @ $8095c1ac  # Hook During State 4 of stOperatorRuleAdventure::processBegin after game mode is finished and deciding on next state 
{
    lwz r4, 0x620(r30)                  # Original operation (advSaveData->currentLevelId)
    rlwinm r3, r4, 0, 0, 15             # Original next operation (so that can be overridden by branch condition)
    rlwinm r5, r4, 16, 24, 31           # (currentLevelId >> 16) & 0x000000ff 
    cmplwi r5, levelIdForVsZakoMinusOne # Check if level id is in the desired range
}
op bgt- 0x24 @ $8095c1b0 # Branch to condition setting stOperatorRuleAdventure state to 10 if level id is in the desired range

## Below Code in C++ for updating level id 
# // e.g. currentLevelId = 0x1C5A0101, lastDoorId = 0x28000204
# // output = 28900114
# unsigned int calculateOutputId(unsigned int currentLevelId, unsigned int lastDoorId) {
#     unsigned int outputId = 0;

#     // Turn first 3 bytes into base 10
#     for (unsigned char i = 8; i <= 24; i += 8) {
#         unsigned char shiftId = (currentLevelId >> i) & 0xff;
        
#         unsigned char shiftIdQuotient = (shiftId / 10); 
#         unsigned char shiftIdRemainder = shiftId % 10;
        
#         outputId += ((shiftIdQuotient*16) + shiftIdRemainder) << i;
        
#     }
#     if ((currentLevelId & 0xff) << 4 < 0x100) {
#       outputId += (currentLevelId & 0xf) << 4; // Move sub level id to digit before
#     }
#     outputId += (lastDoorId & 0xf); // Have last door index be door index so that there is some flexibility (jump can be determined based on what door was entered previously)
     
#     return outputId;
# }

HOOK @ $8095c8c4    # Hook During State 10 of stOperatorRuleAdventure::processBegin to set door id
{   
    lwz r4, 0x620(r30)                  # Original operation (advSaveData->currentLevelId)
    rlwinm r5, r4, 16, 24, 31           # (currentLevelId >> 16) & 0x000000ff 
    cmplwi r5, levelIdForVsZako         # Check if level id is in the desired range
    lis r3, 0xCCCD                      # Original next operation (so that can be overridden by branch condition)
    blt+ %END%
    mr r0, r4
    lwz r4, 0x628(r30)  # advSaveData->lastDoorid
    li r10,8                # \
    li r6,0                 # |
    li r12,10               # |
loc_forEachByte:            # |
    srw r7,r0,r10           # |
    andi. r7, r7, 0xFF      # |
    divwu r9,r7,r12         # |
    slwi r8,r9,4            # |
    mulli r9,r9,10          # | Turn first 3 bytes into base 10
    subf r9,r9,r7           # |
    andi. r9,r9, 0xFF       # | 
    add r9,r8,r9            # |
    slw r9,r9,r10           # | 
    addi r10,r10,8          # |
    cmplwi r10,32           # |
    add r6,r6,r9            # |
    bne+ loc_forEachByte    # /
    rlwinm r4,r4,0,28,31    # Get last door index
    rlwinm r0,r0,4,20,27    # Move sub level id to digit 
    cmpwi r0, 0x100             # \ If sub level id 16 or greater don't use it to calculate new door id
    bge+ loc_dontAddSubLevelId  # /                
    add r6,r6,r0            # \ 
loc_dontAddSubLevelId:      # | Calculate new final door id
    add r0,r6,r4            # /
    cmplwi r5, levelIdForVsZako
}
op bge- 0x6C @ $8095c8c8 # Branch to setting stOperatorRuleAdventure state and levelId

    
###########################################################################
# Force Movie to Play if stepJumpState is not 8 and jumpLevelId is not 0  #
###########################################################################

HOOK @ $806e7544 # in sqSequence::setNext (case 8)   
{   
    lwzux r0, r4, r0      # Original operation

    lbz r5, 0x603(r29)  # Get stepJumpState
    cmpwi r5, 0x8
    blt+ %END%
    lwz r12, 0x62C(r29)  # Get jumpLevelId
    cmpwi r12, 0x0
    beq+ %END%
    li r0, 0x6          # Set case so that video will play
}

#################################################################################
#  Handle Going to Custom Levels After Movie Is Played If JumpLevelID is not 0  #
#################################################################################

HOOK @ $806e8920 # in sqSequence::setNext (case 10)   
{   
    stw	r19, 0x24(r28)          # Original operation
    lbz r5, 0x603(r29)          # \
    cmpwi r5, 0xE               # |
    bne+ noResetJumpLevelId     # | If advSaveData->stepJumpState is 0xE, reset advSaveData->jumpLevelId to siginify that can continue on normal SSE path
    li r5, 0x0                  # |
    stw r5, 0x62C(r29)          # |
    b revertSequenceIndex       # /
noResetJumpLevelId:
    lwz r5, 0x62C(r29)  # \
    cmpwi r5, 0x0       # | If advSaveData->jumpLevelId is 0, skip and continue normal SSE path
    beq+ %END%          # /
    li r0, 0x1B         # Set sqAdventure->state to 27 to setup next stage
    li r5, 0x2          # \
    stb r5, 0x603(r29)  # / Set advSaveData->stepJumpState to 2
revertSequenceIndex:
    stw r3, 0x10(r28)   # Revert Sequence index (don't increment since was on custom path)

}

##################################################################
#  Create movie and param filename based on current jumpLevelID  #
##################################################################

# jumpLevelID = 0 signifies that it's a normal SSE movie

HOOK @ $806da2b8
{   
    lis r5, 0x805a          # \
    lwz r5, 0x00E0(r5)      # |
    lwz r5, 0x30(r5)        # | Get GameGlobal->advSaveData->jumpLevelId
    lwz r5, 0x62C(r5)       # | (if it's 0 then skip)
    cmpwi r5, 0x0           # /
    beq+ end
    addi r3, r1, 0x10       # \
    lis r4, 0x8059          # |
    ori r4, r4, 0xEB3B      # |
    lis r12, 0x803f         # | sprintf(fileName, %08x, jumpLevelId)
    ori r12, r12, 0x89fc    # | (get movie name based on jumpLevelId)
    mtctr r12               # |
    bctrl                   # /
end:
    lis r3, 0x805A      # Original operation
}

HOOK @ $806da740
{   
    lis r6, 0x805a          # \
    lwz r6, 0x00E0(r6)      # |
    lwz r6, 0x30(r6)        # | Get GameGlobal->advSaveData->jumpLevelId
    lwz r6, 0x62C(r6)       # | (if it's 0 then skip)
    cmpwi r6, 0x0           # /
    beq+ end

    lis r4, 0x8042          # \
    ori r4, r4, 0xC090      # |
    lis r12, 0x3038         # | 
    ori r12, r12, 0x782E    # | Temporarily make string format as %s/%08x.%s
    stw r12, 0x4(r4)        # |
    lis r25, 0x2573         # | 
    stw r25, 0x8(r4)        # /
SDTHP_NotFound:
    addi r3, r1, 0x40       # \
    lwz	r5, -0x79A0(r13)    # |
    lwz	r7, -0x7998(r13)    # | sprintf(fileName, %s/%08x.%s, folderPath, jumpLevelId, "thp")
    lis r12, 0x803f         # | (get movie filepath based on jumpLevelId)
    ori r12, r12, 0x89fc    # | 
    mtctr r12               # | 
    bctrl                   # /
    addi r3, r1, 0x40       # \
    lis r12, 0x8001			# |
	ori r12, r12, 0xF0D0	# | Check if the THP video exists on the SD card
	mtctr r12				# |
	bctrl					# |
    cmpwi r3, 0             # /
    li r6, 0x0              # \
    lis r4, 0x8042          # | if non-zero, it gives an error code, set video id so that 00000000.thp (blank thp) is obtained instead
    ori r4, r4, 0xC090      # |
    bne+ SDTHP_NotFound	    # / 
    lis r12, 0x8043         # \
    li r4, 0x732E           # |
    sth r4, -0x3F6C(r12)    # | Change string format back to %s/%s.%s
    stw r25, -0x3F6A(r12)   # /
end:
    li r3, 108     # Original operation
}

############################################################
#  Use new stepJumpStates to End Non-Normal Level Battles  #
############################################################

# advSaveData->stepJumpState=0xD -> used for when adsj flag0 is 4 which is to signify playing a custom movie after a non-normal level
# advSaveData->stepJumpState=0xE -> used for when adsj flag0 is 5 which is to signify playing a custom movie after a non-normal level and continuing regular SSE flow after
# advSaveData->stepJumpState=0xF -> used for when adsj flag0 is 5 which is to signify returning to regular SSE flow after a non-normal level

HOOK @ $8095c9b0 # in stOperatorRuleAdventure::isEnd
{
    cmplwi r0, 2    # Original operation (check if stepJumpState is 2) 
    beq+ %END%
    cmplwi r0, 0xD  # \ 
    beq+ %END%      # | 
    cmplwi r0, 0xE  # | Also end if stepJumpState is 0xD, 0xE, 0xF (new states for custom non normal levels of whether to play movie after it)
    beq+ %END%      # |
    cmplwi r0, 0xF  # / 
}

HOOK @ $806e8d4c # in sqSequence::setNext (case 43)   
{   
    lwz r12, 0x62C(r29)     # Get current jumpLevelId
    cmpwi r12, 0x0          # \ If jumpLevelId was not 0, don't increment sequenceIndex
    bne- %END%              # /
    stw	r0, 0x0010 (r28)    # Original operation (store new incremented sequenceIndex)
}

######################################################################################################
# Check External Loaded ADSJ if it exists and corresponding ADSJ entry not found in adventure_common #
######################################################################################################
HOOK @ $80945b34  # in stLoaderStageAdventureCommon::updateStepId 
{
    li r4, -0x1
    lis r12, 0x8054         # \
    lhz r0, -0x1000(r12)    # | Check if external ADSJ is loaded
    cmpwi r0, 0x4144        # |
    bne+ %END%              # /
    lwz r11, -0xFFC(r12)    # Get number of entries 
    mulli r10, r11, 0x4     # \ Add offset based on number of entries
    add r12, r12, r10       # /
    mtctr r11
loopThroughADSJ1:
    lwz r0, -0xFE8(r12)     # \
    lwz r10, 0xD0(r30)      # |
    lwz r10, 0x620(r10)     # | Check if advStepJumpEntry->jumpLevelId == advSaveData->currentLevelId 
    cmpw r0, r10            # |
    bne+ notMatchingEntry1  # /
    lbz r0, -0xFEC(r12)     # \
    cmpwi r0, 0x1           # | Check if advStepJumpEntry->flag0 is 0x1
    bne+ notMatchingEntry1  # /
    lwz r4, -0xFF0(r12)     # Get door id from ADSJ
notMatchingEntry1:
    addi r12, r12, 0x2C
    bdnz loopThroughADSJ1
}

HOOK @ $80945bb0 # in stLoaderStageAdventureCommon::updateStepId 
{
    li r0, 0x0
    lis r31, 0x8053         # \ 
    ori r31, r31, 0xF010    # | Set pointer to external ADSJ entry
    lhz r12, -0x10(r31)     # | Check if external ADSJ is loaded
    cmpwi r12, 0x4144       # |
    bne+ %END%              # /
    lwz r11, -0xC(r31)      # Get number of entries 
    mulli r10, r11, 0x4     # \ Add offset based on number of entries
    add r31, r31, r10       # /
    mtctr r11
loopThroughADSJ2:
    lwz r12, 0x0(r31)       # \
    lwz r10, 0xD0(r30)      # |
    lwz r10, 0x628(r10)     # | Check if advStepJumpEntry->levelId == advSaveData->lastDoorId 
    cmpw r12, r10           # |
    bne+ notMatchingEntry2  # /
    li r0, 0x1
    b %END%
notMatchingEntry2:
    addi r31, r31, 0x2C
    bdnz loopThroughADSJ2
}

HOOK @ $80945cc0 # in stLoaderStageAdventureCommon::updateStepId 
{
    li r0, 0x0
    lis r31, 0x8053         # \ 
    ori r31, r31, 0xF010    # | Set pointer to external ADSJ entry
    lhz r12, -0x10(r31)     # | Check if external ADSJ is loaded
    cmpwi r12, 0x4144       # |
    bne+ %END%              # /
    lwz r11, -0xC(r31)      # Get number of entries 
    mulli r10, r11, 0x4     # \ Add offset based on number of entries
    add r31, r31, r10       # /
    mtctr r11
loopThroughADSJ3:
    lwz r12, 0x0(r31)       # \
    lwz r10, 0xD0(r30)      # |
    lwz r10, 0x628(r10)     # | Check if advStepJumpEntry->levelId == advSaveData->lastDoorId 
    cmpw r12, r10           # |
    bne+ notMatchingEntry3  # /
    li r0, 0x1
    b %END%
notMatchingEntry3:
    addi r31, r31, 0x2C
    bdnz loopThroughADSJ3
}

###########################################################################################################
#  Put P1 and P2 Initial Slot IDs at the back of advSaveData->selectedSlotIds in sqAdventure::setSelChar  #
###########################################################################################################

HOOK @ $806ec368 
{
    lbz	r0, 0x5FA(r9)   # Original operation
    lwz r12, 0x62C(r29) # \
    cmpwi r12, 0x0      # | Check if advSaveData->jumpLevelId is 0x0
    beq+ %END%          # /
    lwz r12, 0x24(r22)  # \
    lwz r12, 0x50(r12)  # | Make current index seqAdv->advSelchrResult->numSelectedFighters - 1 
    subi r0, r12, 0x1   # /
    add r4, r8, r0      # \ advSaveData->selectedSlotIds[numSelectedFighters - 1] = slotId
    stb r3, 0x5(r4)     # / 
    li r12, -1          # \ advSaveData->numReserveStocks = -1 (start at -1 so then it can be added to)
    stb r12, 0x5FA(r9)  # /
}

HOOK @ $806ec4d4
{
    lbz	r0, 0x5FA(r8)   # Original operation
    lwz r12, 0x62C(r29) # \ 
    cmpwi r12, 0x0      # | Check if advSaveData->jumpLevelId is 0x0
    beq+ %END%          # /
    lwz r12, 0x24(r22)  # \
    lwz r0, 0x50(r12)   # / Make current index seqAdv->advSelchrResult->numSelectedFighters
    add r4, r7, r0      # \ advSaveData->selectedSlotIds[numSelectedFighters] = p2SlotId
    stb r3, 0x5(r4)     # / 
    li r12, -1          # \ advSaveData->numReserveStocks = -1 (start at -1 so then it can be added to)
    stb r12, 0x5FA(r8)  # /
}

op lbz r6,0x5FA(r4) @ $806ec610   # Use advSaveData->numReserveStocks instead of advSelchrResult->numSelectedFighters 

#########################################
# Default Subspace Sound Group is 0x0F2 #
#########################################
op li r3, 0xF2 @ $8094c1e0
op li r3, 0xF2 @ $8094c25c

###############################################
# Use Passed in MsBin Pointer for Enemy Names #
###############################################
op nop @ $80107874  # IfAdvMngr::dispBoss   # \ 
op nop @ $800dced4  # IfMngr::dispBoss      # | pass original struct instead of copied struct
op nop @ $80107804  # IfAdvMngr::dispZako   # /

HOOK @ $80109454    # IfAdvBoss::dispBoss
{
    mr r5, r30  # Original operation
    lwz r12, 0x14(r26)  # \
    cmpwi r12, 0x0      # | check if msBinPtr is null
    beq+ %end%          # /
    mr r6, r12
    li r5, 0
}
HOOK @ $801086ac    # IfAdvZako::dispZako
{
    mr r5, r30  # Original operation
    lwz r12, 0x14(r26)  # \
    cmpwi r12, 0x0      # | check if msBinPtr is null
    beq+ %end%          # /
    mr r6, r12
    li r5, 0
}

##########################
# AdvEx Autosave Support # 
##########################
HOOK @ $806d772c    # scAdvSave::start
{
    li r3, 0                # set first parameter to 0
    lis r12, 0x806D         # \
    ori r12, r12, 0x76ec    # | jump to creating muAdvSaveTask in sora_adv_stage module
    mtctr r12               # |
    bctr                    # /
}   
HOOK @ $806d76f8
{
    lwz	r0, 0x35C(r30)  # Original operation
    cmpwi r3, -1            # \ check if returned -1, and skip back to end
    bne+ %end%              # /
    lis r12, 0x806D
    ori r12, r12, 0x773c
    mtctr r12
    bctr 
}

##########################################################
Fix Behaviour After Vs Melee Fights in Subspace [Kapedani]
##########################################################
.alias g_GameGlobal                         = 0x805a00E0
.alias __memfill                            = 0x8000443c
.alias STEX_PARAM                           = 0x8053F010

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

HOOK @ $806eba40    # sqAdventure::setAdventureCondition
{
    %lwi (r3, STEX_PARAM)   # \
    li r4, 0x0              # | zero out part of stage param
    li r5, 0x10             # /
    %call (__memfill)
    %lwi (r12, 0xFFE7FFFF)  # \
    stw r12, 0x30(r23)      # | Edit default itSwitch 
    li r12, -1              # |
    stw r12, 0x34(r23)      # /
    lbz	r3, 0x606(r22)   # Original operation
}

##############################################
!All Players Can Interact With Warps [Kapedani]
##############################################
## TODO: Maybe check if not in adventure mode? Also make one for doors
op b 0x48 @ $8085f47c

#############################################################################
!Change filename of figdisp.pac to figdisx.pac Except During SSE [Kapedani]
#############################################################################
HOOK @ $80103978
{
    stb	r0, 0x70(r1)        # Original operation 
    lis r23, 0x8046         # \
    li r12, 0x78            # | Temporarily change filename of figdisp.pac to figdisx.pac
    stb r12, -0x4131(r23)   # /
}
HOOK @ $80103980
{
    lwz	r0, 0x32C(r31)      # Original operation 
    li r12, 0x70            # \ Change filename back to figdisp.pac
    stb r12, -0x4131(r23)   # /
}

## TODO: Change to module edit
HOOK @ $81169f84
{
    lis r31, 0x8046         # \ Change filename path location to use the same one as in main.dol
    subi r4, r31, 0x4144    # /
    li r12, 0x78            # \ Temporarily change filename of figdisp.pac to figdisx.pac
    stb r12, -0x4131(r31)   # /
}
HOOK @ $81169fa0
{
    lwz	r3, 0x14B8(r3)      # Original operation 
    li r12, 0x70            # \ Change filename back to figdisp.pac
    stb r12, -0x4131(r31)   # /
}
