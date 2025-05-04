
#################################################
ItemEx Clone Engine v2.52 [Sammi Husky, Kapedani]
#################################################
# Stages can override items
# Character specific items
# Variants setup for Pokemon/Assist Trophies
# Allows Pokemon/Assist probabilities to be adjusted in ItmGen in stage file

# Requires: BrawlEX, SSEEX

.alias g_GameGlobal                         = 0x805a00E0
.alias g_stLoaderManager                    = 0x80B8A6D0
.alias g_sndSystem                          = 0x805A01D0
.alias sndSystem__freeGroup                 = 0x80073c98
.alias sndSystem__loadSoundGroup            = 0x80073b68
.alias sndSystem__playSE                    = 0x800742b0
.alias g_Stage                              = 0x80B8A428
.alias g_utArchiveManager3                  = 0x80B84ee8
.alias utArchiveManager__addNoManageArchive = 0x800455e0
.alias g_itmParam                           = 0x80B8B800
.alias g_itManager                          = 0x80B8B7F4
.alias itManager__preloadItemKindArchive    = 0x809ae960
.alias itManager__removeItemAll             = 0x809b2750
.alias itManager__removeItemAllTempArchive  = 0x809b69d8
.alias itManager__removeItemArchive         = 0x809b6718
.alias itManager__getRandBasicItemSheet     = 0x809b3a60
.alias itManager__getLotOneItemKind         = 0x809b4864
.alias itManager__checkCreatableItem        = 0x809b08f4
.alias g_itKindGroups                       = 0x80B50A90
.alias g_itKindVariationNums                = 0x80ADB548
.alias g_itKindRemovableItKind              = 0x80ADBE58
.alias g_itKindEmissions                    = 0x80adc120
.alias g_itNullCustomizer                   = 0x80b8b1f0
.alias BaseItem__resetDamage                = 0x8099a068
.alias soExternalValueAccesser__getStatusKind 	= 0x80797608
.alias soExternalValueAccesser__getPos      = 0x807973e8
.alias soExternalValueAccesser__getWorkInt  = 0x807976d8
.alias muProcItemSwitch__init               = 0x806aa5e8
.alias muProcMenu__setAnimFrame             = 0x806a52d4
.alias MuMsg__setMsgData                    = 0x800b8c7c
.alias g_ftManager                          = 0x80B87C28
.alias ftManager__getFighter                = 0x80814f20
.alias ftInfo__getNamePtr                   = 0x808588d8
.alias g_ftEntryManager                     = 0x80B87c48
.alias ftEntryManager__getEntryIdFromTaskId = 0x80823f90
.alias ftEntryManager__getEntity            = 0x80823b24
.alias gfArchiveDatabase__get               = 0x80016664
.alias gfFileArchive__getData               = 0x80015ddc
.alias gfFileIO__checkFile                  = 0x8001F0D0
.alias gfHeapManager__getMaxFreeSize        = 0x80024a34
.alias g_gfPadStatus                        = 0x805A0040
.alias snprintf                             = 0x803f8924
.alias strcpy                               = 0x803fa280
.alias strcmp                               = 0x803fa3fc
.alias randi                                = 0x8003fc7c
.alias __memfill                            = 0x8000443c
.alias memcpy                               = 0x80004338
.alias __shl2i                              = 0x803f1798
.alias _float_1_0							= 0x80AD7DCC

.alias ITM_OVERRIDE_STR_ADDR        = 0x80B518F8 
.alias PKM_OVERRIDE_STR_ADDR        = 0x80B51908
.alias SND_OVERRIDE_STR_ADDR        = 0x80B524E8
.alias 076_SOUND_HEAP_LEVEL_ADDR    = 0x80B51918
.alias ITM_FT_PARAM_ARCHIVES        = 0x80B5191C
.alias FIGHTER_STR                  = 0x80B08850
.alias ITM_OVERRIDE_SETTINGS        = 0x80B51939
.alias PKM_OVERRIDE_SETTINGS        = 0x80B518D8
.alias DEFAULT_PKM_VARIETY_AMOUNT   = 5
.alias DEFAULT_PKM_VARIETY_SPAWN    = 3
.alias PKM_OVERLOAD_AMOUNT_ADDR     = 0x80B51938
.alias NUM_SUB_ITSWITCHES           = 0x806AD300
.alias SUB_ITSWITCH_ALL_START_END   = 0x806AD338
.alias ITSWITCH_CHECK_INDICES       = 0x8042C0D0
.alias EXTRA_ITSWITCH_SAVE          = 0x8042C234
.alias EXTRA_ITSWITCH               = 0x8042C24C
.alias EXTRA_ITSWITCH_POKEMON       = 0x8042C254
.alias EXTRA_ITSWITCH_ASSIST        = 0x8042C258


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

###################################################################
# Skip retrieving and assigning common item pacs from common3.pac #
###################################################################

CODE @ $806bfc2c        # stDecentralizationNandLoader::loadFiles2
{   
    li r4, 0
    lis r12, 0x80B5
    stw r4, 0x18F8(r12)    # Empty ITM_OVERRIDE_STR
    stw r4, 0x1908(r12)    # Empty PKM_OVERRIDE_STR
    stw r4, 0x24E8(r12)    # Empty SND_OVERRIDE_STR_ADDR
    addi r3, r12, 0x191C    # \ Set ITM_FT_ARCHIVES to NULL
    li r5, 122              # | Reset item override settings
    %call (__memfill)       # /
    li r4, -1               # \                               
    lis r12, 0x8043         # |
    stw r4, -0x3DCC(r12)    # |
    stw r4, -0x3DC8(r12)    # | 
    stw r4, -0x3DC4(r12)    # | Fill extra itSwitch settings
    stw r4, -0x3DBC(r12)    # |   
    subis r4, r4, 0x8000    # |
    stw r4, -0x3DC0(r12)    # |
    stw r4, -0x3DB8(r12)    # /
    b 0xA8 # Skip fetching itmParam, itmCommonParam and itmCommonBrres from common3.pac
}

op li r6, 17 @ $809acc7c  # Preload as a temp itarchive

op li r5, 17 @ $809adc04  # \ Preload as a temp itarchive
op li r5, 17 @ $809add24  # /

op li r5, 0x0 @ $806bfd3c   # \ 
CODE @ $806bfd48            # |
{                           # | Skip assigning global itmParam, itmCommonParam and itmCommonBrres
    stw	r5, 0xC(r1)         # |
    stw r5, 0x10(r1)        # |
}                           # /

HOOK @ $809bca84    # itArchive::__ct
{   
    lwz r12, 0xc(r25)   # itArchive->variant
    cmplwi r12, 0xFFFF  # \ Check if fighter item
    ble+ notFighterItem # /
    srawi r10, r12, 20  # ftSlotId = variant / 0x100000
    %lwi (r11, ITM_FT_PARAM_ARCHIVES)   # \
    mulli r10, r10, 0x4                 # |
    lwzx r10, r11, r10                  # | Get itmParam for ftSlot so that it doesn't have to be copied for subsequent items
    stw r10, 0x20(r1)                   # /
    b end
notFighterItem:
    cmpwi r31, 8                # \ Check if stage item group
    beq+ dontUseGlobalItmParam  # /
    cmpwi r31, 0                # \ Check if Subspace item group
    beq+ dontUseGlobalItmParam  # /
    cmpwi r31, 5                # \ Check if Enemy item group
    beq+ dontUseGlobalItmParam  # /
    cmpwi r12, 0x0      # \ Check if itVariation == 0
    beq+ end            # /
    cmpwi r31, 2                # \ Check if Assist
    beq- dontUseGlobalItmParam  # /
    cmpwi r31, 3        # \ Check if Pokemon
    bne- end            # /
dontUseGlobalItmParam:
    li r12, 0x0         # \ Set itmParam to NULL
    stw r12, 0x20(r1)   # /
    lwz r11, 0x8(r25)   # itArchive->itKind
    %lwi (r12, g_itKindRemovableItKind) # \
    lwzx r12, r12, r11                  # | 
    cmpwi r12, -1                       # | Check if the itArchive is the main archive for the Pokemon/Assist (i.e. not just the shot)
    beq+ end                            # |
    cmpw r12, r11                       # | 
    beq+ end                            # /       
    lwz r4, 0x68(r1)                # \
    %lwd (r12, g_utArchiveManager3) # |
    lwz r3, 0x4(r12)                # | Get gfArchive from archive id of main Pokemon/Assist archive
    %call (gfArchiveDatabase__get)  # |
    stw r3, 0x20(r1)                # /
end:
    cmpwi r31, 8    # Original opeartion
}

HOOK @ $809acc84    # itManager::create
{
    %call (itManager__preloadItemKindArchive)
    lwz r4, 0x10(r3)                # \
    %lwd (r12, g_utArchiveManager3) # |
    lwz r3, 0x4(r12)                # | Get gfArchive from itmParam archive id and set to g_itmParam (this is so that it can fetch the archive quicker, was causing lag before)
    %call (gfArchiveDatabase__get)  # |
    %swd (r3, r12, g_itmParam)      # /
}

####################################################################
# Unload common item pacs and sawnds, and reload on stage creation #                                           
####################################################################

HOOK @ $8094a5c8    # stLoaderStage::entryEntity
{
    stw	r0, 0x1A4(r3)   # Original operation
    lwz r12, 0x44(r3)   # \
    stw r12, 0xc(r1)    # | Check if stage kind is results
    cmpwi r12, 0x28     # |
    beq- %end%          # /

    li r10, 0           # \
    stw r10, 0x10(r1)   # | set temp string to empty
    stw r10, 0x1c(r1)   # /

    %lwi (r3, PKM_OVERLOAD_AMOUNT_ADDR)
    li r4, 0x0
    li r5, 94
    %call (__memfill)

    lwz	r3, 0xC4(r31)
    lwz r3, 0x1A0(r3)           # stage filedata
    li r4, 1                    # Data_Type_Misc
    li r5, 20000                # fileIndex
    addi r6, r4, -3             # \ endian
    rlwinm r6, r6, 0, 16, 31    # / 
    %call (gfFileArchive__getData)  # \
    stw r3, 0x8(r1)                 # | Check stage pac for itov in file index 20000
    cmpwi r3, 0x0                   # |
    beq+ noItov                     # /
    %lwd (r12, g_GameGlobal)    # \
    lwz r12, 0x8(r12)           # |
    lbz r12, 0x31(r12)          # | Check if g_GameGlobal->m_modeMelee->m_meleeInitData.m_itSwitch.m_stageItem bit is on
    andi. r12, r12, 0x2         # |
    beq+ noOverrides            # /
    addi r4, r3, 0x10   # \
    addi r3, r1, 0x1c   # |
    %call (strcpy)      # | Copy item and pokemon override strings from Itov to temp strings if Itov exists
    lwz r4, 0x8(r1)     # |
    addi r4, r4, 0x4    # |
    addi r3, r1, 0x10   # |
    %call (strcpy)      # /
noOverrides:
    lwz r4, 0x8(r1)                     # \
    addi r4, r4, 0x1c                   # | Copy Item Override settings
    %lwi (r3, PKM_OVERLOAD_AMOUNT_ADDR) # |
    li r5, 94                           # |
    %call (memcpy)                      # /
noItov:
    addi r4, r1, 0x1c                   # \
    %lwi (r3, PKM_OVERRIDE_STR_ADDR)    # |
    %call (strcmp)                      # | Check if Pokemon folder has changed
    cmpwi r3, 0x0                       # |
    beq+ dontReloadPkmnSawnd            # /
    %lwd (r12, g_stLoaderManager)       
    li r10, 5   
    lwz r11, 0x28(r12)              # Get g_stLoaderManager->stLoaderPokemonSe
    lwz r9, 0xc(r1)
    cmpwi r9, 0x3d
    bne+ notSubspace
    lwz r11, 0x24(r12)              # Get g_stLoaderManager->stLoaderCommonSeAdventure
notSubspace:
    stb r10, 0x44(r11)              # stLoader->state to 5 to tell it to reload sawnd
dontReloadPkmnSawnd:
    addi r4, r1, 0x1c                   # \
    %lwi (r3, PKM_OVERRIDE_STR_ADDR)    # | Copy new Pokemon folder name
    %call (strcpy)                      # /
    addi r4, r1, 0x10                   # \
    %lwi (r3, ITM_OVERRIDE_STR_ADDR)    # |
    %call (strcmp)                      # | Check if item folder has changed
    cmpwi r3, 0x0                       # |
    beq+ %end%                          # /
    addi r4, r1, 0x10                       # \
    %lwi (r3, ITM_OVERRIDE_STR_ADDR)        # |
    %call (strcpy)                          # | Copy new item folder name
    %lwd (r3, g_sndSystem)                  # |
    %lwd (r4, 076_SOUND_HEAP_LEVEL_ADDR)    # /
    li r5, 0                        # \ Unload item sawnd
    %call (sndSystem__freeGroup)    # /
    %lwd (r3, g_sndSystem)              # \
    li r4, 0x76 # sawnd id              # |
    li r5, 2                            # | Reload item sawnd
    li r6, 1                            # |
    %call (sndSystem__loadSoundGroup)   # /
    %swd (r3, r12, 076_SOUND_HEAP_LEVEL_ADDR)    # Store heap level for 076.sawnd
    %lwd (r3, g_itManager)
    li r4, 17          # added parameter: itArchiveType
    %call (itManager__removeItemAllTempArchive)
    li r11, 0x0                     # \ Set g_itmParam to null
    %swd (r11, r12, g_itmParam)     # /
    %lwd (r3, g_itManager)
    li r4, 0x3e # itKind
    li r5, 0x0  # variation
    li r6, 17   # itArchiveType - Temp
    li r7, 0x1
    %call (itManager__preloadItemKindArchive)
    lwz r4, 0x10(r3)                # \
    %lwd (r12, g_utArchiveManager3) # |
    lwz r3, 0x4(r12)                # | Get gfArchive from itmParam archive id and set to g_itmParam (this is so that it can fetch the archive quicker, was causing lag before)
    %call (gfArchiveDatabase__get)  # |
    %swd (r3, r12, g_itmParam)      # /
}
HOOK @ $806bf8e8    # Store 076.sawnd heap level when loaded in stDecentralizationNandLoader::loadFiles2 to be able to unload later
{
    %swd (r3, r12, 076_SOUND_HEAP_LEVEL_ADDR)    # Store heap level for 076.sawnd%
    lwz	r3, 0x1D0(r27)  # original operation
}

########################################################################################################################
# Allow stage to set custom ItmParam as well as custom itCustomizer                                                    #
# Passes in extra parameters to stage->getItemPac() of pointer to gfArchive* for itmParam and pointer to itCustomizer* #
#                                                                                                                      #
# Allow fighter to set custom itCustomizer                                                                             #
# Passes in exta parameters to fighter->onStartFinal() of item variant pointer to itCustomizer*                       #           
########################################################################################################################

HOOK @ $809bcaec # itArchive::__ct
{
    li r29, 17          # Use StageResource to load if not found on stage pac
    stw	r0, 0xC(r1)     # \ *itmParam = NULL
    addi r8, r1, 0xc    # /
    li r9, 0x0          # itCustomizer = NULL
    bctrl	        # original operation
    lwz r4, 0xC(r1) # \ Skip if itmParam was not retrieved from stage
    cmpwi r4, 0x0   # /
    beq+ %end%
    %lwd (r3, g_utArchiveManager3)
    %call (utArchiveManager__addNoManageArchive)
    stw r3, 0x10(r25)   # store id for commonParams
}

HOOK @ $809bcc30 # itArchive::__ct
{
    lwz r24, 0x20(r1)   # \ Original operations
    li r3, 2            # /
    lwz r10, 0x10(r25)  # \ Check if commonParamsID has been assigned
    cmplwi r10, 0xffff   # /
}
CODE @ $809bcc34
{
    bne+ 0x58           # Skip if commonParamsID has been assigned already
    cmpwi r24, 0        # \ Original operations
    beq- 0x18           # /
}

HOOK @ $8098b3c4    # BaseItem::__ct
{
    mr r4, r14          # Original operation
    lwz r5, 0x8c4(r29)  # Pass itVariation to itManager::getCustomizer as extra parameter
}
HOOK @ $8098d574    # BaseItem::activate
{
    lwz r4, 0x8C0(r29)  # Original operation
    lwz r5, 0x8C4(r29)  # Pass itVariation to itManager::getCustomizer as extra parameter
}
HOOK @ $809abc28    # itManager::getCustomizer
{
    li r29, 0
    stw r29, 0x8(r1)
    stw r29, 0xc(r1)
    mr r30, r4  
    mr r31, r5
grabItCustomizerFromModule:
    cmplwi r31, 0xFFFF                  # \ Check if variant is in character specific range
    bgt+ grabItCustomizerFromFighter    # /
    %lwd (r3, g_Stage)
    cmpwi r3, 0
    beq- skipGettingItCustomizerFromModule
    addi r4, r1, 0x8    # \
    addi r5, r1, 0x8    # |
    mr r6, r30          # |
    mr r7, r31          # |
    addi r8, r1, 0x8    # |
    addi r9, r1, 0xc    # | stage->getItemPac(gfArchive** brres, gfArchive** param, itKind itemID, int variantID, gfArchive** commonParam, itCustomizerInterface** customizer)
    lwz r12, 0x3c(r3)   # |
    lwz r12, 0x80(r12)  # |
    mtctr r12           # |
    bctrl               # /
    b fetchItCustomizer
grabItCustomizerFromFighter:
    %lwd (r28, g_ftEntryManager)    # \
    addi r3, r28, 0x8               # |
    lwz r12, 0x8(r28)               # | ftEntryManager->ftEntryArrayVector.size();
    lwz r12, 0x14(r12)              # |
    mtctr r12                       # |
    bctrl                           # /
    mr r27, r3
    li r26, 0x0
    b startCheckEntriesLoop
checkEntriesLoop:
    mr r4, r26                      # \
    addi r3, r28, 0x8               # |
    lwz r12, 0x8(r28)               # | ftEntryManager->ftEntryArrayVector.at(i);
    lwz r12, 0x10(r12)              # |
    mtctr r12                       # |
    bctrl                           # /
    lwz r3, 0x0(r3)
    lwz r4, 0x18(r3)    # ftEntry->slotId
    srawi r5, r31, 20   # variant / 0x100000 to get ftSlotId
    cmpw r4, r5         # check if slotId matches
    bne+ notSlot
    lwz r4, 0x4(r3)     # ftEntry->entryId
    b foundSlot
notSlot:
    addi r26, r26, 0x1
startCheckEntriesLoop:
    cmpw r26, r27
    blt+ checkEntriesLoop 
    li r4, -0x1         # entryId = -1
foundSlot:
    %lwd (r3, g_ftManager)
    li r5, -1
    %call (ftManager__getFighter)
    cmpwi r3, 0x0
    beq- skipGettingItCustomizerFromModule
    rlwinm r4,r31,0,12,31   # variant id & 0xFFFFF (i.e. remove the ftslotid)
    addi r5, r1, 0xc    # \
    lwz r12, 0x3c(r3)   # |
    lwz r12, 0x278(r12) # | fighter->onStartFinal(int variantId, itCustomizerInterface** customizer)
    mtctr r12           # |
    bctrl               # /
fetchItCustomizer:
    lwz r29, 0xc(r1)    # fetch obtained itCustomizer from stage
skipGettingItCustomizerFromModule:
    stw r31, 0x8(r1)    # Store variant to be used later
    mr r4, r30          # Restore itKind in r4
    mr r3, r29          
    cmpwi r3, 0x0       # check if itCustomizer is null 
    lis	r7, 0x80B9      # \ Original operation
    lbz	r0, -0x4810(r7) # /
}
op bne- 0x4E8 @ $809abc2c   # Skip fetching default itCustomizer if already obtained

HOOK @ $808382f0    # Fighter::startFinal
{
    mtctr r12   # Original operation
    li r4, -1   # \ Pass extra parameters to fighter->onStartFinal
    li r5, 0    # /
}

HOOK @ $809ac104    # itManager::getCustomizer
{
    lis	r3, 0x80B9  # Original operation
    lwz r12, 0x8(r1)    
    cmpwi r4, 0x55  # \
    bne+ %end%      # | check if Double Cherry
    cmpwi r12, 0    # |
    bne+ %end%      # /
    li r4, 0x42 # Use Lighting itCustomizer
}

#####################################
# Setup paths for item archive pacs #
#####################################
    
op lwzx	r27, r3, r0 @ $809aeeb4 # \
op lwzx	r25, r3, r5 @ $809aeebc # |
CODE @ $809af1d0                # |
{                               # | Remove the need for redundant lower case item name strings
    addi r27, r31, 4016         # |
    addi r26, r31, 4016         # |
}                               # /

# Fetch alternate ItmCommonBrres.pac path
HOOK @ $809af094
{
    addi r5, r31, 0x1AE7    # "%s/%s/%s%s%s.%s"
    addi r7, r31, 0x1A44    # "item"
    addi r8, r31, 0x1A4C    # "Itm"
    addi r9, r31, 0x1A3C    # "Common"
    addi r10, r31, 6769     # "Brres"
    stw r14, 0x8(r1)        # ".pac"
    lbz r11, 0xEB1(r31)     # ITM_OVERRIDE_SETTING
    andi. r11, r11, 0x1     # \ Check if override brres
    beq+ %end%              # /
    addi r5, r31, 0x1AE6    # "/%s/%s/%s%s%s.%s"  
    addi r6, r31, 0x1A44    # "item"
    addi r7, r31, 0xE70     # ITM_OVERRIDE_STR_ADDR
}

# Fetch alternate ItmCommonParam.pac path
HOOK @ $809af0b0
{
    addi r5, r31, 0x1AE7    # "%s/%s/%s%s%s.%s"
    addi r7, r31, 0x1A44    # "item"
    addi r8, r31, 0x1A4C    # "Itm"
    addi r9, r31, 0x1A3C    # "Common"
    addi r10, r31, 6919     # "Param"
    stw r14, 0x8(r1)        # ".pac"
    lbz r11, 0xEB1(r31)     # ITM_OVERRIDE_SETTING
    andi. r11, r11, 0x2     # \ Check if override param
    beq+ %end%              # /
    addi r5, r31, 0x1AE6    # "/%s/%s/%s%s%s.%s"  
    addi r6, r31, 0x1A44    # "item"
    addi r7, r31, 0xE70     # ITM_OVERRIDE_STR_ADDR
}

# Fetch alternate ItmParam.pac path
HOOK @ $809af23c
{
    li r12, 0xE70
    lwz	r6, 0x4(r31)
    addi r3, r1, 0x24
    li r4, 0xef
    addi r5, r31, 0x1AE7    # "%s/%s/%s%s%s.%s"
    addi r7, r31, 0x1A44    # "item"
    addi r8, r31, 0x1A4C    # "Itm"
    lwz	r9, 0x04(r31)       # ""
    addi r10, r31, 6919     # "Param"
    stw r14, 0x8(r1)        # ".pac"
    lbz r11, 0xEB1(r31)     # ITM_OVERRIDE_SETTING
    cmpwi r16, 0x46     # \ 
    blt+ notPkmn        # | check if itKind is a common item
    cmpwi r16, 0x4f     # |
    beq- notPkmn        # /
    li r12, 0xF02
    cmplwi r17, 0x8000  # \ check if variant >= 0x8000, get from override folder if it is
    bge+ variantParam   # /
    cmpwi r16, 0x52     # \ check if itKind <= 0x52 (for stage specific items)
    ble- override       # /
    cmpwi r16, 0x62     # \ check if itKind >= 0x62 (Pokemon and Assist Trophies)
    blt+ notPkmn        # /    
    li r12, 0xE80
    cmpwi r17, 0x0       # \ check if variant > 0, get alt ItmParam if it is
    ble+ notPkmnOverride # / 
variantParam:
    stw r10, 0x8(r1)    # "Param"
    stw r14, 0xc(r1)    # ".pac"
    subi r5, r5, 0x64   # "%s/%s/%s%s%02d%s.%s"
    mr r10, r17         # variant
    cmplwi r17, 0x8000  # \ check if variant >= 0x8000, get ItmParam from override folder if it is
    bge- override       # /
notPkmnOverride:
    addi r11, r31, 0xE50    # \
    lbzx r11, r11, r16      # / PKM_OVERRIDE_SETTING
notPkmn:
    andi. r11, r11, 0x2     # \ Check if override param
    beq+ %end%              # /
override:
    lbzx r0, r31, r12       # \
    cmpwi r0, 0x0           # | Check if override string is empty
    beq+ %end%              # /
    subi r5, r5, 0x1        # "/%s/%s/%s%s%s.%s"  
    addi r6, r31, 0x1A44    # "item"
    add r7, r31, r12        # OVERRIDE_STR_ADDR
}

string "/%s/%s/%s/%s%s%02d%s.%s" @ $80B52507    # create string format for variant path
string "%s%02d.%s" @ $80B52531  # create "/%s/%s/%s/%s%s%02d%s%02d.%s" string format for fighter variant path
string "%s.%s" @ $80B52579 # create "/%s/%s/%s/%s%s%s.%s"
byte 0x2f @ $80B5251F # add '/' before "%s/%s/%s/%s%s%02d%s%02d.%s"
byte 0x2f @ $80B5256B # add '/' before "%s/%s/%s/%s%s%s.%s"
byte 0x00 @ $80B524FE   # add null terminator to get "Brres" as a string
byte 0x00 @ $80B52594   # add null terminator to get "Param" as a string

# Fetch alternate item brres path (i.e. for Pokemon and Assist Trophies)
HOOK @ $809af198
{
    addi r5, r31, 6884  # "%s/%s/%s/%s%s%s.%s"
    addi r12, r31, 6769 # \
    stw r12, 0x8(r1)    # / "Brres"
    li r12, 0xF02
    stw r14, 0xc(r1)    # ".pac"
    cmpwi r16, 0x52     # \ check if itKind <= 0x52 (for stage specific items)
    ble- override       # /
    li r12, 0xE80
    addi r11, r31, 0xE50    # \
    lbzx r11, r11, r16      # / PKM_OVERRIDE_SETTING
    andi. r11, r11, 0x1     # \ Check if override brres
    beq+ %end%              # /
override:
    addi r5, r31, 6883      # "/%s/%s/%s/%s%s%s.%s" 
    addi r6, r31, 0x1A44    # "item"
    add r7, r31, r12        # OVERRIDE_STR_ADDR
}

# Fetch alternate item param path (i.e. for Pokemon and Assist Trophies)
HOOK @ $809af1f8
{
    li r4, 255          # Original operation
    addi r12, r31, 6919 # \
    stw r12, 0x8(r1)    # / "Param"
    li r12, 0xF02
    stw r14, 0xc(r1)    # ".pac"
    cmpwi r16, 0x52     # \ check if itKind <= 0x52 (for stage specific items)
    ble- override       # /
    li r12, 0xE80
    addi r11, r31, 0xE50    # \
    lbzx r11, r11, r16      # / PKM_OVERRIDE_SETTING
    andi. r11, r11, 0x2     # \ Check if override param
    beq+ %end%              # /
override:
    addi r5, r31, 6883      # "/%s/%s/%s/%s%s%s.%s" 
    addi r6, r31, 0x1A44    # "item"
    add r7, r31, r12        # OVERRIDE_STR_ADDR
}

HOOK @ $809af13c
{
    xori r0, r0, 0x0001 # Original operation
    cmpwi r16, 0x62 # \ check if itKind >= 0x62 (Pokemon and Assist Trophies)
    blt+ %end%      # /
    cmpwi r17, 0x0  # \ check if variant > 0, get alt if it is
    bgt+ %end%      # /
    li r0, 0x0
}

op mr r11, r0 @ $809af0f8  # Allow items with no model to have variants
HOOK @ $809af150
{
    li r22, 532
    addi r12, r31, 6769 # \
    stw r12, 0xc(r1)    # / "Brres"
    cmpwi r11, 0x0      # \ Check if item uses no model
    beq- skipBrres      # /
formulatePath:
    li r12, 0xF02
    addi r5, r31, 6784  # "%s/%s/%s/%s%s%02d%s.%s"
    lwz	r6, 0x4(r31)
    addi r7, r31, 0x1A44    # "item"
    add r3, r1, r22
    li r4, 255          # Original operation
    mr r8, r25          # item name 
    mr r9, r21          # "Itm" or "Pkm" or "Asf" or "Wpn"
    mr r10, r24
    stw r17, 0x8(r1)    # variant
    stw	r14, 0x10(r1)   # ".pac"
    cmpwi r16, 0x52     # \ check if itKind <= 0x52 (for stage specific items)
    ble- override       # /
    cmplwi r17, 0x8000   # \ check if variant >= 0x8000, get from override folder if it is
    bge+ override       # /
    li r12, 0xE80
    addi r11, r31, 0xE50    # \
    lbzx r11, r11, r16      # / PKM_OVERRIDE_SETTING
    li r0, 0x1          # \
    cmpwi r22, 532      # |
    beq+ isBrres        # |
    li r0, 0x2          # | Check if override brres/param
isBrres:                # |
    and. r11, r11, r0   # / 
    beq+ notOverride   
override:
    addi r5, r31, 6783      # "/%s/%s/%s/%s%s%s.%s" 
    addi r6, r31, 0x1A44    # "item"
    add r7, r31, r12        # OVERRIDE_STR_ADDR
notOverride:
    crclr 6,6
    %call (snprintf)
skipBrres:
    addi r12, r31, 6919 # \
    stw r12, 0xc(r1)    # / "Param"
    cmpwi r22, 276
    li r22, 276
    addi r21, r31, 0x1A4C   # "Itm"
    bne+ formulatePath
}
op b 0xB0 @ $809af154   # Skip to formulate ItmParam

.macro buildFighterItemPath()
{   
    
}
CODE @ $809af148
{
    cmplwi r17, 0xFFFF  # \
    bgt+ 0xc            # / Check if variant id is in character specific range
}
HOOK @ $809af158
{
    rlwinm r12,r17,24,24,31 # \ (variant id & 0xFF00) >> 8 to get character item subvariant
    stw r12, 0x8(r1)        # /
    addi r12, r31, 6769     # \
    stw r12, 0xc(r1)        # / "Brres"
    stw r14, 0x14(r1)       # ".pac"
formulateBrresPath:
    li r3, 0x0
    andi. r4, r19, 0xFF    # Get ftKind from fourth parameter
    %call(ftInfo__getNamePtr)
    %lwi (r6, FIGHTER_STR)   # "Fighter"
    mr r7, r3
    addi r8, r31, 0x1A44    # "item"
    mr r9, r21              # "Itm" or "Pkm" or "Asf" or "Wpn"
    mr r10, r7              # Fighter name again

    addi r3, r1, 532
    li r4, 0xff
    addi r5, r31, 6807      # "/%s/%s/%s/%s%s%02d%s%02d.%s"
    rlwinm r12,r19,24,24,31 # \
    stw r12, 0x10(r1)       # / Costume id from fourth parameter
    crclr 6,6
    %call (snprintf)
brresItemPathObtained:
    li r3, 0x0
    andi. r4, r19, 0xFF    # Get ftKind from fourth parameter
    %call(ftInfo__getNamePtr)
    stw r3, 0x14(r1)

    stw r14, 0x10(r1)       # ".pac"
    li r22, 276             # Formulate param path
    addi r5, r31, 6783      # "/%s/%s/%s/%s%s%02d%s.%s"
    addi r12, r31, 6919     # \
    stw r12, 0xc(r1)        # / "Param"
formulateParamPath:
    %lwi (r6, FIGHTER_STR)   # "Fighter"
    lwz r7, 0x14(r1)
    addi r8, r31, 0x1A44    # "item"
    mr r9, r21              # "Itm" or "Pkm" or "Asf" or "Wpn"
    mr r10, r7              # Fighter name again

    li r4, 0xff
    add r3, r1, r22
    crclr 6,6
    %call (snprintf)
    cmpwi r22, 0x24
    li r22, 0x24            # Formulate common param path
    stw r14, 0xc(r1)        # ".pac"
    addi r12, r31, 6919     # \ "Param" 
    stw r12, 0x8(r1)        # /
    addi r5, r31, 6883      # "/%s/%s/%s/%s%s%s.%s"
    bne+ formulateParamPath
}
op b 0xEC @ $809af15c   # Skip to after normal formulation of ItmParam

op li r0, 0x1           @ $809af02c # \
op li r0, 0x1           @ $809af050 # | Only loop clearing out string once (not neccessary to clear out entire length and also interferes with shortening string on stack)
op li r0, 0x1           @ $809af204 # /
op stw r3, 0x20(r1)     @ $809aec34 # \
op stw r3, 0x20(r1)     @ $809af2b4 # |
op lwz r3, 0x20(r1)     @ $809af368 # | 
op addi r8, r1, 0x20    @ $809af208 # | Make room on stack for extra snprintf parameters
op addi r4, r1, 0x20    @ $809af2d0 # |
#op li r4, 0xef          @ $809af234 # |
#op addi r3, r1, 0x24    @ $809af228 # |
op addi r7, r1, 0x24    @ $809af2a0 # /

##########################
# Fighter Specific Items #
##########################
# Uses variant id ranges past 0x10000, (use Unknown24 in misc psa data to define which items to preload). 
## 0xZZ1XXYY (Z - costume id (must be ordered from greatest to smallest), X - subvariant with first must be 0, Y - itKind to clone)
## Internally itKind in the itArchive is set to 0x4B (Sidestepper) because stage items have more freedom, though the item instance itKind is set to the base item id to pass all the required checks
## ftSlot id * 0x100000 is added to variant id to differentiate archives between same fighters using different slots
# Searches for /fighter/<fighter>/item/Itm<Fighter><subvariantid>Brres<costumeid>.pac, /fighter/<fighter>/item/Itm<Fighter><subvariantid>Param.pac, /fighter/<fighter>/item/Itm<Fighter>Param.pac
## Itm<Fighter>Param.pac attribute index is based on subvariant id
## Loads on ftSlot::pushItem, deloads on ftSlot::exit
# Takes over fighter->onStartFinal virtual function to get an optional itCustomizer from fighter module
# TODO: Kirby support
## Might be able to get current fighter/ftslot copied and then should be able to spawn item
# TODO: Investigate having items know about costume id so it can differentiate between playing effects/sfx (maybe can make it a psa command?)
# TODO: Bring back Peach having items like bomb if item switch is on

op b 0xb4 @ $8084ea44   # skip preloading in ftDataProvider::comp
op b 0x84 @ $8084e67c   # skip preloading in ftDataProvider:isFinish      

HOOK @ $80829988    # Pass in extra SlotId and costumeId parameter to ftDataProvider::reqItem in ftSlot::pushItem
{
    lwz	r4, 0x8(r4) # Original operation
    lwz r5, 0x174(r31) # pass ftslot id
    lbz r6, 0x15B(r31) # pass costume id
}

HOOK @ $8084e854    # ftDataProvider::reqItem
{
    stb r5, 0x8(r1) # store ftslot id on stack
    stb r6, 0x9(r1) # store costume id on stack
    sth r27, 0xA(r1) # store ftKind on stack
    mr r3, r27  # Original operation
}
HOOK @ $8084e8b0    # ftDataProvider::reqItem
{
    lwzx r4, r4, r29    # Original operation
    cmplwi r4, 0xFFFF   # Check if 0x10000 or greater for character specific items
    ble- %end%
    rlwinm r4,r4,0,12,31    # itKind &= 0xfffff
    lbz r10, 0x8(r1)    # \
    slwi r10, r10, 20   # | variant = itKind + ftSlotNo*0x100000
    add r5, r4, r10     # /
    li r4, 0x4B     # itKind - SideStepper
}
HOOK @ $8084e8dc    # ftDataProvider::reqItem
{
    lbz r12, 0x9(r1)    # costumeId to load 
    cmplwi r4, 0xFFFF   # Check if 0x10000 or greater for character specific items
    ble- %end%
checkCostume: 
    rlwinm r8, r4, 12,24,31    # costumeId = (itKind >> 20) & 0xff;
    cmpw r12, r8        # \ check if costumeId to load is larger than current costume id
    bge+ foundCostume   # /
    addi r29, r29, 4    # \
    addi r27, r27, 1    # |
    lwz	r4, 0x60(r30)   # | increment entry
    lwz r4, 0x0(r4)     # |
    lwzx r4, r4, r29    # |
    b checkCostume      # /
foundCostume:
    rlwinm r4,r4,0,12,31    # itKind &= 0xfffff
    lbz r10, 0x8(r1)    # \
    slwi r10, r10, 20   # | variant = itKind + ftSlotNo*0x100000
    add r5, r4, r10     # /
    lhz r7, 0xA(r1)     # Pass in ftKind as last parameter
    slwi r8, r8, 8      # \ Add costumeId * 0x100 to last parameter
    add r7, r7, r8      # /
    li r4, 0x4B     # itKind - SideStepper
    %call (itManager__preloadItemKindArchive)
    lwz r4, 0x10(r3)                # \
    %lwd (r12, g_utArchiveManager3) # |
    lwz r3, 0x4(r12)                # | Get gfArchive from itmParam archive id
    %call (gfArchiveDatabase__get)  # /
    lbz r11, 0x8(r1)                    # \
    %lwi (r12, ITM_FT_PARAM_ARCHIVES)   # | Set ftSlot's global itmParam (so it can be reused for subsequent items)
    mulli r11, r11, 0x4                 # |
    stwx r3, r12, r11                   # /
}

HOOK @ $80827a80    # ftSlot::exit
{
    %lwd (r3, g_itManager)
    lwz r4, 0x174(r30)          # get ftSlot->id
    li r10, 0x0                         # \
    %lwi (r12, ITM_FT_PARAM_ARCHIVES)   # | Set ftSlot's global itmParam reference to NULL
    mulli r11, r4, 0x4                  # |
    stwx r10, r12, r11                  # /
    addi r4, r4, 18             # added parameter: itArchiveType = ftSlotId + 18
    %call (itManager__removeItemAllTempArchive)
    li r0, -1   # Original operation
}
HOOK @ $80827b28    # ftSlot::remove
{
    %lwd (r3, g_itManager)
    lwz r4, 0x174(r30)          # get ftSlot->id
    li r10, 0x0                         # \
    %lwi (r12, ITM_FT_PARAM_ARCHIVES)   # | Set ftSlot's global itmParam reference to NULL
    mulli r11, r4, 0x4                  # |
    stwx r10, r12, r11                  # /
    addi r4, r4, 18             # added parameter: itArchiveType = ftSlotId + 18
    %call (itManager__removeItemAllTempArchive)
    li r26, 0   # Original operation
}
HOOK @ $809bcfa4    # itArchive::isRemovable
{
    li r3, 0
    lwz r12, 0x0(r30)   # \
    cmpwi r12, 18       # | Check if itArchiveType >= 18 (fighter specific item)
    blt+ %end%          # /
    li r3, 1            # Remove immediately regardless
}

op cmpwi r27, -1 @ $809b2fd0    # itManager::getItemNum                     # \
op li r5, -1 @ $80914830    # aiStat::update                                # |
op li r5, -1 @ $80914bbc    # aiStat::update                                # | getItemNum itVariation -1 instead of 0
op li r5, -1 @ $809999ac    # BaseItem::lotCreate                           # |
op li r5, -1 @ $80a72fa4    # wnDiddyPeanutsStatusUniqProcess::initStatus   # /
HOOK @ $806d4b90    # scMelee::stopGame
{
    li r4, -1   # \
    li r5, -1   # | Pass extra parameters
    li r6, -1   # /
    %call(itManager__removeItemAll)
}
HOOK @ $809b276c # itManager::removeItemAll
{
    mr r29, r3      # Original operation
    stw r4, 0x8(r1)     # \ 
    stw r5, 0xc(r1)     # | Store extra parameters (target itKind , itVariant and creatorTaskId)
    stw r6, 0x10(r1)    # /
}
HOOK @ $809b279c # itManager::removeItemAll
{
    lwz r10, 0x8(r1)    # \
    cmpwi r10, -1       # | check if target itKind is -1 (i.e. remove all items)
    beq+ end            # /
    lwz r12, 0(r3)  
    lwz r11, 0x8C0(r12) # \
    cmpw r11, r10       # | check if baseItem->itKind == target itKind 
    bne+ noRemove       # /
    lwz r10, 0xC(r1)    # \
    cmpwi r10, -1       # | check if target itVariation is -1 (i.e. remove all variants of item)
    beq+ allVariants    # /
    lwz r11, 0x8C4(r12) # \
    cmpw r11, r10       # | check if baseItem->itVaration == target itVaration
    bne+ noRemove       # /
allVariants:
    lwz r10, 0x10(r1)   # \
    cmpwi r10, -1       # | check if target creatorTaskId is -1 (i.e. remove all variants of item)
    beq+ end            # /
    lwz r11, 0x8C8(r12) # \
    cmpw r11, r10       # | check if baseItem->creatorTaskId == target creatorTaskId
    beq+ end            # /
noRemove:
    %branch(0x809b27cc) # skip remove
end:
    lwz	r12, 0x6D8(r29) # Original operation
}
HOOK @ $809b27bc    # itManager::removeItemAll
{
    li r5, 0    # Original operation
    lwz r10, 0x8(r1)    # \
    cmpwi r10, -1       # | check if target itKind is -1 (i.e. remove all items)
    beq+ %end%          # /
    li r5, 2    # Display puff of smoke
}
HOOK @ $809b27fc # itManager::removeItemAll
{
    lwz r10, 0x8(r1)    # \
    cmpwi r10, -1       # | check if target itKind is -1 (i.e. remove all items)
    bne- %end%          # /
    bctrl       # clear item list
}
HOOK @ $809b69f4 # itManager::removeItemAllTempArchive
{
    mr r29, r3      # Original operation
    stw r4, 0x8(r1) # Store extra parameter (itArchiveType) on stack for later
}
HOOK @ $809b6a24 # itManager::removeItemAllTempArchive
{
    li r10, 1           # removeItem = true
    lwz r12, 0x8(r1)    # \ 
    cmpwi r12, 0        # |
    beq+ end            # | Check if passed in itArchiveType != 0 or != 17
    cmpwi r12, 17       # |
    beq+ end            # /

    li r10, 0           # removeItem = false
    lwz r11, 0x0(r31)   # \
    lwz r11, 0x8DC(r11) # |
    lwz r11, 0x0(r11)   # | Check if itArchiveType == item->itArchive->itArchiveType
    cmpw r12, r11       # |
    bne+ end            # /
    li r10, 1           # removeItem = true
end:
    cmpwi r10, 1
    lwz	r12, 0x6D8(r29) # \ Original operation
    addi r3, r29, 1752  # /
}
op bne+ 0x2c @ $809b6a28
HOOK @ $809b6a44 # itManager::removeItemAllTempArchive
{
    li r5, 0            # Original operation
    lwz r12, 0x8(r1)    # \
    cmpwi r12, 0        # |
    beq+ %end%          # | Check if passed in itArchiveType != 0 or != 17
    cmpwi r12, 17       # |
    beq+ %end%          # /
    
    lwz r11, 0x8DC(r4)  # \ 
    lwz r11, 0x0(r11)   # | Check if itArchiveType == item->itArchive->itArchiveType
    cmpw r12, r11       # |
    bne+ %end%          # /
    li r5, 3            # remove item force
}
HOOK @ $809b6a84    # itManager::removeItemAllTempArchive
{
    lwz r12, 0x8(r1)    # \ 
    cmpwi r12, 0        # |
    beq+ clear          # | Check if passed in itArchiveType == 0 or == 17 (don't clear entire itemArrayList if it is not)
    cmpwi r12, 17       # | 
    bne- %end%          # /
clear:
    bctrl           
}
op lwz r4, 0x8(r1) @ $809b6a8c  # clear out archives with type that was passed in

HOOK @ $809b23b0    # itManager::removeItemSub
{
    andi. r26, r5, 0x1
    andi. r0, r5, 0x2
    beq+ end 
    mr r30, r4

    mr r3, r4
    %call(soExternalValueAccesser__getStatusKind)
    cmpwi r3, 6
    beq- end
    stwu r1, -0x20(r1)

    addi r3, r1, 0x8
    mr r4, r30
    %call(soExternalValueAccesser__getPos)
    li r4, 0x22                 # \
    addi r5, r1, 0x8            # |
    li r6, 0                    # |
    li r7, 0                    # |
    %lf(f1, r12, _float_1_0)    # |
    lwz r3, 0x60(r30)           # |
    lwz r3, 0xd8(r3)            # | item->moduleAccesser->moduleEnumeration->soEffectModule->req(0x22, &pos, NULL, 0, -1, 1.0)
    lwz r3, 0x88(r3)            # |
    lwz r12, 0x0(r3)            # |
    lwz r12, 0x20(r12)          # |
    mtctr r12                   # |
    bctrl                       # /

    addi r1, r1, 0x20
    mr r4, r30
end:
    lbz	r30, 0x8D5(r4)  # Original operation (pass original itKind)
}

HOOK @ $8098e3b4    # BaseItem::deactivate
{
    bctrl   # Original operation
    %lwi(r12, g_itNullCustomizer)   # \ set itCustomizer to itNullCustomizer
    stw r12, 0x8D0(r30)             # / (prevents potential deloaded itCustomizers from fighter module from being called after game end)
}

# HOOK @ $80a6f680    # ftDiddyStatusUniqProcessSpecialPopGun::execFixPos
# {
#     lwz	r3, 0x8(r30)
#     %lwi(r4, 0x10000049)
#     %call(soExternalValueAccesser__getWorkInt)  # get ftSlotId
#     lwz	r3, 0x8(r30)    # Original operation
# }

##################
# Item Clone IDs #
##################
# Variants >= 0xA0XX, 0x20XX <= variant < 0x80XX will adopt id of XX

HOOK @ $809af30c    # itManager::preloadItemKindArchive
{
    lwz	r12, 0x20(r1)    # \ pass itArchive->variation to related item to preload
    lwz r5, 0xc(r12)     # /
    lwz r7, 0x10(r12)   # pass itArchive->commonParamId as fourth parameter
}
op nop @ $809af364    # eliminate ability to start preloading itKinds that are not the main itKind
op mr r5, r27 @ $809b0258   # \ pass itArchive->variation to related item to check if it is preloaded
op mr r5, r27 @ $809b02e4   # /
HOOK @ $809af2a8    # itManager::preloadItemKindArchive
{
    addi r9, r1, 532    # Original operation
    stw	r19, 0x8(r1)    # Pass commonParamId as extra parameter
}

HOOK @ $809aef04    # itManager::preloadItemKindArchive
{
    li r20, 8   # Original operation
    cmplwi r17, 0xFFFF  # \ Check if variant id is in character specific item range
    ble- %end%          # /
    srawi r12, r17, 20  # \ ftSlotId = variant / 0x100000
    addi r20, r12, 18   # / HeapType = ftSlotId + 18
}
HOOK @ $809bca28    # itArchive::__ct
{
    lwz	r4, 0x1C(r25)   # Original operation
    lwz r12, 0xc(r25)   # \
    cmplwi r12, 0xFFFF  # | Check if variant id is in character specific item range
    ble- %end%          # /
    srawi r12, r12, 20  # \ ftSlotId = variant / 0x100000
    addi r29, r12, 18   # | itArchiveType = ftSlotId + 18
    stw r29, 0x0(r25)   # / Store HeapType as itArchiveType (to be able to clear character specific items)
    li r31, 0xA         # Set ItemGroup to an unused value
}

HOOK @ $809bcbbc # itArchive::__ct
{
    li r6, 0    # Force unique = false
    lwz r12, 0xc(r25)   # \
    cmplwi r12, 0xFFFF  # | Check if itVariation >= 0x10000
    ble+ %end%          # /
    li r6, 2    # Force unique = true
}
HOOK @ $809bcc18    # itArchive::__ct
{
    li r6, 0    # Force unique = false
    lwz r12, 0xc(r25)   # \
    cmplwi r12, 0xFFFF  # | Check if itVariation >= 0x10000
    ble+ %end%          # /
    li r6, 2    # Force unique = true
}
HOOK @ $809bcc74    # itArchive::__ct
{
    mr r5, r29  # Use heapType instead of only ItemResource
    li r6, 0    # Force unique = false
    lwz r12, 0xc(r25)   # itArchive->itVariation
    lwz r11, 0x8(r25)   # itArchive->itKind
    cmpwi r11, 0x62                 # \ check if itKind >= 0x62 (Pokemon and Assist Trophies)
    blt+ notPokemonAssistVariant    # /   
    cmpwi r12, 0x0      # \ check if Pokemon/Assist variant 
    bgt- forceClone     # /
notPokemonAssistVariant:
    cmplwi r12, 0xFFFF  # | Check if itVariation >= 0x10000
    ble+ %end%          # /
forceClone:
    li r6, 2    # Force unique = true    
} 

HOOK @ $8098a514    # BaseItem::__ct
{
    lwz	r0, 0xC(r30)    # Original operation
    stb r0, 0x8D5(r29)  # Store original itKind in unused byte
    %lwi (r12, g_itKindVariationNums)   # \
    rlwinm r11, r0, 2, 0, 29            # |
    lwzx r12, r12, r11                  # | Check if variation
    cmpwi r12, -1000                    # |
    beq+ %end%                          # /
    lwz r12, 0x10(r30)      # \
    rlwinm r12,r12,0,17,15  # |
    cmpwi r12, 0x2000       # | If clone, set itKind to it's base itKind
    blt+ %end%              # |
    andi. r0,r12,0xFF       # /
}

HOOK @ $8098d524    # BaseItem::activate
{
    lwz r6, 0xc(r30)    # Original operation
    stb r6, 0x8D5(r29)  # Store original itKind in unused byte
    %lwi (r12, g_itKindVariationNums)   # \
    rlwinm r11, r6, 2, 0, 29            # |
    lwzx r12, r12, r11                  # | Check if variation
    cmpwi r12, -1000                    # |
    beq+ %end%                          # /
    lwz r12, 0x10(r30)      # \
    rlwinm r12,r12,0,17,15  # |
    cmpwi r12, 0x2000       # | If clone, set itKind to it's base itKind
    blt+ %end%              # |
    andi. r6,r12,0xFF       # /
}

op lbz r4, 0x8D5(r29) @ $8098a544   # BaseItem::__ct        \ pass original itKind to itManager::getItemKindArchive
op lbz r4, 0x8D5(r29) @ $8098d584   # BaseItem::activate    /

op lbz r4, 0x8D5(r29) @ $8098a570   # BaseItem::__ct        \ pass original itKind to itManager::getItemKindArchiveId
op lbz r4, 0x8D5(r29) @ $8098d5a0   # BaseItem::activate    /

op lbz r4, 0x8D5(r29) @ $8098a5c8   # BaseItem::__ct                \
op lbz r4, 0x8D5(r29) @ $8098d614   # BaseItem::activate            | pass original itKind to itManager::getItemKindArchiveGroup
op lbz r4, 0x8D5(r21) @ $80990194   # BaseItem::notifyEventAnimCmd  /

op lbz r28, 0x8D5(r3) @ $809b2b94   # itManager::createItemInstance # pass original itKind

CODE @ $809b1420    # itManager::createBaseItem
{
    cmpwi r0, 8  # \ If stage item then don't set itKind to -3 so it can check if archive exists
    bge- 0x1C    # /
} 
CODE @ $809b15e4    # itManager::createBaseItem
{
    cmpwi r0, 8  # \ If stage item then don't set itKind to -3 so it can check if archive exists
    bge- 0x1C    # /
}

HOOK @ $809c7820    # itResourceIdAccesserImpl::getItKind
{
    lwz r9, 0x8c4(r3)  # get itVariation 
    lbz r10, 0x8D5(r3)  # get original itKind
    lwz	r3, 0x8C0(r3)  # Original operation
    cmplwi r9, 0xFFFF          # \ Check if itVariation >= 0x10000
    blt+ notFighterItem         # /
    rlwinm r3, r9, 24,24,31    # kind = (itVaration >> 8) && 0xff (use subvariant index for param attributes)
    b %end%
notFighterItem:
    rlwinm r11, r10, 2, 0, 29   # \
    %lwi (r12, g_itKindGroups)  # |
    lwzx r12, r12, r11          # |
    cmpwi r12, 0x1              # |
    beq+ isCommonItem           # | Check if common item
    cmpwi r12, 0x6              # | 
    beq+ isCommonItem           # | 
    cmpwi r12, 0x7              # |
    beq+ isCommonItem           # / 
    mr r3, r10      # Use original itKind
    b %end%
isCommonItem:
    cmpwi r10, 0x32             # \
    bne+ notMeleeScrewAttack    # | 
    cmpwi r9, 8234              # | Use param entry 0x4b for Melee Screw Attack
    bne+ notMeleeScrewAttack    # |
    li r3, 0x4B                 # /
notMeleeScrewAttack:
    cmpwi r10, 0x8              # \
    bne+ %end%                  # | 
    cmpwi r9, 8200              # | Use param entry 0x4c for Flipper
    bne+ %end%                  # |
    li r3, 0x4c                 # /
}

HOOK @ $809ab8c8    # itManager::getItemKindArchiveId
{
    mr r3, r4
    cmpwi r0, 1   # Original operation
    bne+ %end% 
    cmpwi r5, 0x2000    # \ ids past 0x2000 use own model/param
    bltlr+              # /
    %lwi (r12, g_itKindVariationNums)   # \ 
    rlwinm r11, r4, 2, 0, 29            # | 
    lwzx r12, r12, r11                  # | Check g_itKindVariationNums[itKind] == -1000 (used by trophies/stickers/cds)
    cmpwi r12, -1000                    # |
    beqlr+                              # /
    rlwinm r5,r5,0,0,23 # \ archiveId = variant & 0xffffff00 + item kind
    add r3, r5, r4      # /
    blr
}

#######################################################
# Patch item creation functions to handle item clones #
#######################################################

HOOK @ $807c3240    # soItemManageModuleImpl::haveItem
{
    lwz	r6, 0x8(r6)     # Original operation
    cmplwi r4, 0xFFFF   # \ Check if itKind is in fighter specific range
    ble+ %end%          # /
    lwz r11, 0x10c(r6) # fighter->entryId
    %lwd (r12, g_ftEntryManager)    # \
    rlwinm r11, r11, 0, 24, 31      # |
    lwz r12, 0x0(r12)               # | ftEntryManager->ftEntries + (entryId & 0xff) (same functionality as ftEntryManager::getEntity)
    mulli r11, r11, 580             # |
    add r12, r12, r11               # /
    lwz r11, 0x18(r12)   # ftEntry->slotNo
    slwi r11, r11, 20   # \ variant = itKind + ftSlotNo*0x100000
    add r5, r4, r11     # /
    li r4, 0x4B         # set itKind to Sidestepper
}
HOOK @ $807c3394    # soItemManageModuleImpl::createThrowItem
{
    lwz	r7, 0x8(r7)     # Original operation
    cmplwi r6, 0xFFFF   # \ Check if variant is in fighter specific range
    ble+ %end%          # /
    lwz r11, 0x10c(r7) # fighter->entryId
    %lwd (r12, g_ftEntryManager)    # \
    rlwinm r11, r11, 0, 24, 31      # |
    lwz r12, 0x0(r12)               # | ftEntryManager->ftEntries + (entryId & 0xff) (same functionality as ftEntryManager::getEntity)
    mulli r11, r11, 580             # |
    add r12, r12, r11               # /
    lwz r11, 0x18(r12)  # ftEntry->slotNo
    slwi r11, r11, 20   # \ variant = itKind + ftSlotNo*0x100000
    add r6, r6, r11     # /
    li r5, 0x4b         # set itKind to Sidestepper
}
HOOK @ $8079813c    # soArticleMediatorHelper::createItem
{
    li r5, 0x0          # Original operation
    cmplwi r29, 0xFFFF  # \ check if clone item
    ble+ %end%          # /
    stw r3, 0xC(r1)     # Store itManager for later
    %lwd (r3, g_ftEntryManager)
    mr r4, r31                                      # \ get entryId from emitterTaskId
    %call (ftEntryManager__getEntryIdFromTaskId)    # /
    mr r4, r3                           # \
    %lwd (r3, g_ftEntryManager)         # | get ftEntry from entryId
    %call (ftEntryManager__getEntity)   # /
    lwz r11, 0x18(r3)  # ftEntry->slotNo
    slwi r11, r11, 20   # \ variant = itKind + ftSlotNo*0x100000
    add r5, r29, r11    # /
    li r4, 0x4b         # set itKind to Sidestepper
    mr r6, r31          # emitterTaskId
    lwz r9, 0x8(r1)     # Restore -1 in r9
    lwz r3, 0xC(r1)     # Restore itManager in r3
}
HOOK @ $80990004    # BaseItem::notifyEventAnimCmd
{
    lfs	f0, 0x0(r28)    # Original operation
    cmpwi r31, 0xFFFF   # \
    ble+ %end%          # /
    lwz r11, 0x8c4(r21) # baseItem->itVariant
    rlwinm r11,r11,0,8,11  # isolate ftSlotId (variant & 0x00f00000)
    add r31, r31, r11   # variant += ftSlotId
}
HOOK @ $80990328    # BaseItem::notifyEventAnimCmd
{
    mr r7, r31    # Original operation
    rlwinm r12,r31,0,17,15  # \
    cmpwi r12, 0x2000       # | check if clone item
    blt+ %end%              # /
    lbz r6, 0x8D5(r21)      # get original itKind of clone
}

op lwz r5, 0x4(r3) @ $809b637c  # \ Preload using variants
op mr r3, r23 @ $809b6384       # /

HOOK @ $809b1324    # itManager::createBaseItem
{
    stb r3, 0x8(r1) # \
    cmpwi r3, 0     # | If item is creatable, skip
    bne- %end%      # /
    mr r3, r15                              # \
    mr r4, r18                              # |
    li r5, 0                                # | Try item variant 0 instead
    cmplwi r19, 0xFFFF                      # |
    ble+ notFighterItem                     # | (or variant & 0xFFFF00FF if it's a fighter item)
    rlwinm r5,r19,0,24,15                   # |
notFighterItem:                             # |
    li r6, 1                                # |
    %call (itManager__checkCreatableItem)   # |
    cmpwi r3, 0                             # /
}
HOOK @ $809b137c    # itManager::createBaseItem
{
    andc r25, r19, r0   # Original operation
    lbz r12, 0x8(r1)    # \
    cmpwi r12, 0x1      # | If desired item variant isn't creatable
    beq+ %end%          # |
    li r25, 0x0         # use variant 0
    cmplwi r19, 0xFFFF         # \
    ble+ %end%                 # | variant & 0xFFFF00FF if it's a fighter item)-
    rlwinm r25,r19,0,24,15     # /
}
HOOK @ $809b1540    # itManager::createBaseItem
{
    andc r28, r19, r0   # Original operation
    lbz r12, 0x8(r1)    # \
    cmpwi r12, 0x1      # | Check if desired item variant isn't creatable
    beq+ %end%          # /
    li r28, 0x0         # use variant 0
    cmplwi r19, 0xFFFF         # \
    ble+ %end%                 # | variant & 0xFFFF00FF if it's a fighter item)-
    rlwinm r28,r19,0,24,15     # /
}
HOOK @ $809b0550    # itManager::getItemKindArchive
{   
    addi r3, r28, 200       # \
    lwz	r12, 0x0014(r12)    # |
    mtctr r12               # | Original operations
    bctrl	                # / 
    li r12, 0               # variant = 0
    cmplwi r31, 0xFFFF      # \ check if fighter item
    ble+ notFighterItem     # /
    rlwinm r12,r31,0,24,15  # variant = variant & 0xFFFF00FF
notFighterItem:             
    cmpw r29, r3            # Original operation
}                           
CODE @ $809b0554    # itManager::getItemKindArchive
{
    blt+ -0x4C      # Original operation
    li r29, 0x0     # \
    cmpw r31, r12   # | If itArchive with specific variant was not found, look for itArchive with default variant
    mr r31, r12     # |
    bne+ -0x5C      # /
}
HOOK @ $809b1cb4    # itManager::removeItemAfter
{
    addi r3, r24, 200       # \
    lwz	r12, 0x0014(r12)    # |
    mtctr r12               # | Original operations
    bctrl	                # / 
    li r12, 0               # variant = 0
    cmplwi r29, 0xFFFF      # \ check if fighter item
    ble+ notFighterItem     # /
    rlwinm r12,r29,0,24,15  # variant = variant & 0xFFFF00FF
notFighterItem:   
    cmpw r23, r3            # Original operation
}
CODE @ $809b1cb8    # itManager::removeItemAfter
{
    blt+ -0x4C      # Original operation
    li r23, 0x0     # \
    cmpw r29, r12   # | If itArchive with specific variant was not found, look for itArchive with default variant
    mr r29, r12     # |
    bne+ -0x5C      # /
}
HOOK @ $809b1e60    # itManager::removeItemAfter
{
    addi r3, r24, 200       # \
    lwz	r12, 0x0014(r12)    # |
    mtctr r12               # | Original operations
    bctrl	                # / 
    li r12, 0               # variant = 0
    cmplwi r23, 0xFFFF      # \ check if fighter item
    ble+ notFighterItem     # /
    rlwinm r12,r23,0,24,15  # variant = variant & 0xFFFF00FF
notFighterItem:   
    cmpw r26, r3            # Original operation
}
CODE @ $809b1e64    # itManager::removeItemAfter
{
    blt+ -0x4C      # Original operation
    li r26, 0x0     # \
    cmpw r23, r12   # | If itArchive with specific variant was not found, look for itArchive with default variant
    mr r23, r12     # |
    bne+ -0x5C      # /
}

##################################
# Adding Pokemon/Assist Variants #
##################################
# Add how many random variants you want into below array, if you want a non random variant then variant should be at least 1
# Variants load as Itm<Name><variantId>Param.pac, variants also use their own ItmParam called Itm<variantId>Param.pac
# Note: PSA should make sure that emitted shot item use right variant

int[178] |
0, |    # 0x00 - Assist Trophy
0, |    # 0x01 - Franklin Badge
0, |    # 0x02 - Banana Peel 
-24, |  # 0x03 - Barrel
0, |    # 0x04 - Beam Sword
0, |    # 0x05 - Bill
-2, |   # 0x06 - Bob-omb
-24, |  # 0x07 - Crate
0, |    # 0x08 - Bumper
-24, |  # 0x09 - Capsule
-24,|   # 0x0A - Rolling Crate
-1000,| # 0x0B - CD
0, |    # 0x0C - Gooey Bomb
0, |    # 0x0D - Cracker Launcher
0, |    # 0x0E - Cracker Launcher Shot
-3, |   # 0x0F - Coin
0, |    # 0x10 - Superspicy Curry
0, |    # 0x11 - Superspicy Curry Shot
0, |    # 0x12 - Deku Nut
0, |    # 0x13 - Mr. Saturn
-3, |   # 0x14 - Dragoon Part
0, |    # 0x15 - Dragoon Set
0, |    # 0x16 - Dragoon Sight
-1000,| # 0x17 - Trophy
0, |    # 0x18 - Fire Flower
0, |    # 0x19 - Fire Flower Shot
0, |    # 0x1A - Freezie
0, |    # 0x1B - Golden Hammer
0, |    # 0x1C - Green Shell
0, |    # 0x1D - Hammer
0, |    # 0x1E - Hammer Head
0, |    # 0x1F - Fan
-2, |   # 0x20 - Heart Container
0, |    # 0x21 - Homerun Bat
-24, |  # 0x22 - Party Ball
0, |    # 0x23 - Manaphy Heart
0, |    # 0x24 - Maxim Tomato
0, |    # 0x25 - Poison Mushroom
0, |    # 0x26 - Super Mushroom
0, |    # 0x27 - Metal Box
0, |    # 0x28 - Hothead
0, |    # 0x29 - Pitfall
0, |    # 0x2A - Pokeball
0, |    # 0x2B - Blast Box
0, |    # 0x2C - Ray Gun
0, |    # 0x2D - Ray Gun Shot
0, |    # 0x2E - Lipstick
0, |    # 0x2F - Lipstick Flower
0, |    # 0x30 - Lipstick Shot Dust Powder
0, |    # 0x31 - Sandbag
0, |    # 0x32 - Screw Attack
-1000,| # 0x33 - Sticker
0, |    # 0x34 - Motion Sensor Bomb
0, |    # 0x35 - Timer
0, |    # 0x36 - Smart Bomb
0, |    # 0x37 - Smash Ball
0, |    # 0x38 - Smoke Screen
0, |    # 0x39 - Spring
0, |    # 0x3A - Star Rod
0, |    # 0x3B - Star Rod Shot
0, |    # 0x3C - Soccer Ball
0, |    # 0x3D - Super Scope
0, |    # 0x3E - Super Scope Shot
0, |    # 0x3F - Starman
-29, |  # 0x40 - Food
0, |    # 0x41 - Team Healer
0, |    # 0x42 - Lightning
0, |    # 0x43 - Unira
0, |    # 0x44 - Bunny Hood
0, |    # 0x45 - Warp Star
25, |   # 0x46 - Subspace Trophy
1, |    # 0x47 - Subspace Key
1, |    # 0x48 - Subspace Trophy Stand
1, |    # 0x49 - Subspace Stock Ball
1, |    # 0x4A - Green Greens Apple
1, |    # 0x4B - Mario Bros. Sidestepper
1, |    # 0x4C - Mario Bros. Shellcreeper
-12, |  # 0x4D - Distant Planet Pellet
10, |   # 0x4E - Summit Vegetable
0, |    # 0x4F - HomeRun Sandbag
1, |    # 0x50 - Enemy Auroros 
1, |    # 0x51 - Enemy Koopa 1
1, |    # 0x52 - Enemy Koopa 2
0, |    # 0x53 - Snake Carboard Box
0, |    # 0x54 - Diddy Kong Peanut
0, |    # 0x55 - Link Bomb
0, |    # 0x56 - Peach Turnip
0, |    # 0x57 - ROB Gyro
0, |    # 0x58 - Diddy Kong Peanut Seed
0, |    # 0x59 - Snake Grenade
-3, |   # 0x5A - Zero Suit Samus Armor Piece
0, |    # 0x5B - Toon Link Bomb
0, |    # 0x5C - Wario Bike
0, |    # 0x5D - Wario Bike A
0, |    # 0x5E - Wario Bike B
0, |    # 0x5F - Wario Bike C
0, |    # 0x60 - Wario Bike D
0, |    # 0x61 - Wario Bike E
1, |    # 0x62 - Torchic
1, |    # 0x63 - Celebi
1, |    # 0x64 - Chikorita
1, |    # 0x65 - Chikorita Shot
1, |    # 0x66 - Entei
3, |    # 0x67 - Moltres
1, |    # 0x68 - Munchlax
1, |    # 0x69 - Deoxys
1, |    # 0x6A - Groudon
1, |    # 0x6B - Gulpin
1, |    # 0x6C - Staryu
1, |    # 0x6D - Staryu Shot   
1, |    # 0x6E - Ho-Oh
1, |    # 0x6F - Ho-Oh Shot
1, |    # 0x70 - Jirachi
1, |    # 0x71 - Snorlax
1, |    # 0x72 - Bellosom
1, |    # 0x73 - Kyogre
1, |    # 0x74 - Kyogre Shot
1, |    # 0x75 - Latias/Latios
1, |    # 0x76 - Lugia
1, |    # 0x77 - Lugia Shot
1, |    # 0x78 - Manaphy
1, |    # 0x79 - Weavile
1, |    # 0x7A - Electrode
1, |    # 0x7B - Metagross
1, |    # 0x7C - Mew
1, |    # 0x7D - Meowth
1, |    # 0x7E - Meowth Shot
1, |    # 0x7F - Piplup
1, |    # 0x80 - Togepi
1, |    # 0x81 - Goldeen
1, |    # 0x82 - Gardevoir
1, |    # 0x83 - Wobbuffet
1, |    # 0x84 - Suicune
1, |    # 0x85 - Bonsly
1, |    # 0x86 - Andross
1, |    # 0x87 - Andross Shot
1, |    # 0x88 - Barbara
1, |    # 0x89 - GrayFox
1, |    # 0x8A - RayMKII
1, |    # 0x8B - RayMKII Bomb
1, |    # 0x8C - RayMKII Gun
1, |    # 0x8D - Samurai Goroh
1, |    # 0x8E - Devil
-3, |    # 0x8F - Excitebike
1, |    # 0x90 - Jeff
1, |    # 0x91 - Jeff Pencil Bullet
1, |    # 0x92 - Jeff Pencil Rocket
1, |    # 0x93 - Lakitu
1, |    # 0x94 - Knuckle Joe
1, |    # 0x95 - Knuckle Joe Shot
1, |    # 0x96 - Hammer Bro
1, |    # 0x97 - Hammer Bro Hammer
1, |    # 0x98 - Helirin
1, |    # 0x99 - Kat/Ana
1, |    # 0x9A - Kat/Ana Ana
1, |    # 0x9B - Jill Dozer
1, |    # 0x9C - Lyn
1, |    # 0x9D - Little Mac
1, |    # 0x9E - Metroid
1, |    # 0x9F - Nintendog
1, |    # 0xA0 - Nintendog Full
1, |    # 0xA1 - MrResetti
1, |    # 0xA2 - Isaac
1, |    # 0xA3 - Isaac Shot
1, |    # 0xA4 - Saki
1, |    # 0xA5 - Saki Shot 1
1, |    # 0xA6 - Saki Shot 2
1, |    # 0xA7 - Shadow
1, |    # 0xA8 - War Infantry
1, |    # 0xA9 - War Infantry Shot
1, |    # 0xAA - Starfy
1, |    # 0xAB - War Tank
1, |    # 0xAC - War Tank Shot
1, |    # 0xAD - Tingle
1, |    # 0xAE - Lakitu Spiny
1, |    # 0xAF - Waluigi
1, |    # 0xB0 - Dr. Wright
1 |     # 0xB1 - Dr. Wright Building
@ $80ADB548

*08ADBD1A 000000DF  # Give Pokemon soundbanks, start at 0x00DF for Torchic
*10230004 00000001  # Uses SSE stage soundbanks since Pokemon don't appear in stages

op b 0x8 @ $809af258    # Allow shots to load their own soundbank

## For unique effects use names of normally unused ones in vs
# EffectBankID - EffectBankName - Pokemon (Item ID)
# 0x134 - mu_seal - Torchic (0x62)
# Celebi (0x63)
# 0x67 - ef_AdvCloud - Chikorita (0x64)
# 0x68 - ef_AdvJungle - Entei (0x66)
# 0x69 - ef_AdvRiver - Moltres (0x67)
# 0x6A - ef_AdvGrass - Munchlax (0x68)
# 0x6B - ef_AdvZoo - Deoxys (0x69)
# 0x6C - ef_AdvFortress - Groudon (0x6A)
# 0x6D - ef_AdvLakeside - Gulpin (0x6B)
# 0x6E - ef_AdvCave - Staryu (0x6C)
# 0x6F - ef_AdvRuinfront - Ho-Oh (0x6E)
# Jirachi (0x70)
# 0x70 - ef_AdvRuin - Snorlax (0x71)
# 0x71 - ef_AdvWild - Bellosom (0x72)
# 0x72 - ef_AdvCliff - Kyogre (0x73)
# 0x73 - ef_AdvHalberdOut - Latias/Latios (0x75)
# 0x74 - ef_AdvHalberdIn - Lugia (0x76)
# Manaphy (0x78)
# 0x75 - ef_AdvAncientOut - Weavile (0x79)
# 0x76 - ef_AdvFactory - Electrode (0x7A)
# 0x77 - ef_AdvDimension - Metagross (0x7B)
# Mew (0x7C)
# 0x78 - ef_AdvStadium - Meowth (0x7D)
# 0x79 - ef_AdvHalberdSide - Piplup (0x7F)
# 0x7A - ef_AdvStore - Togepi (0x80)
# 0x7B - ef_AdvFlyingPlate - Goldeen (0x81)
# 0x7C - ef_AdvEscape - Gardevoir (0x82)
# 0x131 - ef_coinshooter - Wobbuffet (0x83)
# 0x132 - ef_cleargetter - Suicune (0x84)
# 0x133 - ef_chararoll - Bonsly (0x85)

HOOK @ $809af278    # itManager::preloadItemKindArchive
{
    li r14, -1          # Set sfx group id to -1
    cmpwi r16, 0x86     # \ Check if assist
    bge+ useSoundbank   # / 
    andi. r12, r17, 0x800   # \ check if third last digit of variant < 8
    beq+ %end%              # /
    cmpwi r17, 0x0      # \ Check if variant <= 0
    ble- %end%          # / 
useSoundbank:
    lwzx r14, r3, r0    # Original operation
    andi. r14, r14, 0xffff  # Get sawnd id from last two bytes
    extsh r14, r14      # Convert to int
    sthx r17, r3, r0    # Store variant in first two bytes
    %lwi (r12, g_itKindEmissions)   # \
    mulli r11, r16, 14              # | itKindEmissions[kind]
    add r12, r12, r11               # /
    li r11, 0x0
checkEmission:
    lhzx r10, r12, r11  # emissions[index]
    cmplwi r10, 0xffff  # \ check if -1
    beq+ endOfEmissions # /
    mulli r10, r10, 0x4 # \ store variant in first two bytes
    sthx r17, r3, r10   # /
endOfEmissions:
    addi r11, r11, 0x2
    cmpwi r11, 14
    blt+ checkEmission
}
## TODO: Prevent in single player 4 player since no room to load extra Pokemon sawnds and all fighter sawnds

HOOK @ $809bca68    # itArchive::__ct
{
    li r5, 0x2      # Original operation
    cmpwi r31, 0x3  # \ Check if Pokemon item group
    bne+ %end%      # /
    li r5, 0xc      # Change sound heap to enemy sound heap
}

.macro checkItemSwitch(<itManagerReg>, <itKindReg>, <genParamReg>, <switchReg>)
{
    mr r8, <itKindReg>
    %lwd (r6, g_GameGlobal)     # \ g_GameGlobal->modeMelee
    lwz r6, 0x8(r6)             # /
    lwz r23, 0x4(<genParamReg>) # get variant id
    li r10, 0x1
    %lwi (r7, ITSWITCH_CHECK_INDICES)   # \
    mulli r9, r8, 2                     # |
    add r7, r7, r9                      # | check ITSWITCH_CHECK_INDICES to see if itKind is considered a container
    lbz r7, 0x1(r7)                     # |
    cmpwi r7, 0xFF                      # |
    bne+ notContainer                   # /
    lwz r12, 0x30(r6)   # modeMelee->itSwitch.itemSwitch 
    cmpwi r23, 6    # \ check if container with no items
    blt+ end        # / 
    li r11, 0x6         # \ variant / 6 to get type of container (i.e. canHaveItem, canHaveExplosion, canHaveEnemy)   
    divw r11, r23, r11  # /
    cmpwi r11, 0x2          # \ check if enemy container
    bne+ notEnemyContainer  # /
enemyContainer:
    li r11, 0x2
    lhz r0, 0x10BE(<itManagerReg>)  # \ 
    cmpwi r0, 0x96                  # | check if next assist is an enemy
    bne+ switchIsOff                # /
    lwz r9, 0x3C(r6)            # \ 
    cmpwi r9, 0                 # | Check if uncapped Assist amount
    blt- notEnemyContainer      # /

    lwz r0, 0x10C0(<itManagerReg>)  # \
    lbz	r9, 0x1169(<itManagerReg>)  # | check if this->numAssists + this->numAssistTrophies > 0
    add. r0, r0, r9                 # |
    bgt+ switchIsOff                # /
notEnemyContainer:
    addi r0, r11, 0x14 # add to get container variant switch index 
    slw r0, r10, r0             # \
    and r9, r12, r0             # | 
    neg r0, r9                  # | Check item switch
    or r0, r0, r9               # |
    rlwinm. r0, r0, 1, 31, 31   # | 
    bne+ end                    # /
switchIsOff:
    mulli r9, r11, 0x6 # \
    sub r23, r23, r9   # / variant = (variant % 6)
    addi r23, r23, 6        # \
    andis. r0, r12, 0x20    # | use container with items if on
    bne+ end                # /
    addi r23, r23, 12       # \
    andis. r0, r12, 0x80    # | use container with explosion if on
    bne+ end                # /
    subi r23, r23, 6
    cmpwi r11, 2                # \ check if already checked enemy container
    beq+ alreadyEnemyContainer  # /
    andis. r0, r12, 0x40        # \ use container with enemy if on
    bne+ enemyContainer         # /
alreadyEnemyContainer:
    subi r23, r23, 12       # use container with nothing in it
    b end
notContainer:
    cmpwi r23, 0x0      # \ check if not variant
    beq- end            # /
    cmpwi r23, 5000     # \ check if default variant     
    beq+ end            # /

    %lwi (r12, g_itKindGroups)
    rlwinm r11, <itKindReg>, 2, 0, 29
    lwzx r12, r12, r11
    cmpwi r12, 0x3          # \
    beq+ pokemonAssistItem  # | Check if Pokemon/Assist
    cmpwi r12, 0x2          # |
    beq+ pokemonAssistItem  # /
    cmpwi r12, 0x1      # \
    beq+ commonItem     # |
    cmpwi r12, 0x6      # | Check if common item
    beq+ commonItem     # |
    cmpwi r12, 0x7      # |
    bne+ end            # /
commonItem:
    %lwi (r12, g_itKindVariationNums)   # \ 
    lwzx r12, r12, r11                  # | Check g_itKindVariationNums[itKind] == -1000 (used by trophies/stickers/cds)
    cmpwi r12, -1000                    # |
    beq- end                            # /
    cmplwi r23, 0x2000  # \ check if variant is less than 0x2000
    blt+ end            # /
    b checkVariantOn
pokemonAssistItem:
    cmplwi r23, 0x8000      # \ check if stage items
    blt+ notStageVariant    # /
    li r8, 0x4b             # turn into stage item id
    b end
notStageVariant:
    lis r9, 0x8043
    cmpwi r11, 0x3      # \ check if Pokemon or Assist
    beq+ isPokemon      # /
isAssist: 
    lwz r12, 0x3C(r6)   # modeMelee->itSwitch.assistSwitch
    cmpwi r23, 0x1000   # \
    bge+ checkVariantOn # | check if in extra Assist/Pokemon range
    cmpwi r23, 0xF1B    # / 
    blt+ checkVariantOn 
    andi. r11, r23, 0xff                # \
    cmpwi r11, 0x20                     # | check if need extra switch
    blt+ checkExtraOn                   # / 
    lwz r12, -0x3DA8(r9)    # EXTRA_ITSWITCH.assistSwitch2
    b useExtraSwitch
isPokemon:
    lwz r12, 0x38(r6)   # modeMelee->itSwitch.pokemonSwitch
    cmpwi r23, 0x1000   # \
    bge+ checkVariantOn # | check if in extra Assist/Pokemon range
    cmpwi r23, 0xF1B    # / 
    blt+ checkVariantOn
    andi. r11, r23, 0xff                # \
    cmpwi r11, 0x20                     # | check if need extra switch
    blt+ checkExtraOn                   # /
    lwz r12, -0x3DAC(r9)    # EXTRA_ITSWITCH.pokemonSwitch2
useExtraSwitch:
    subi r11, r11, 0x20                  
checkExtraOn:
    slw r0, r10, r11            # \
    and r9, r12, r0             # | 
    neg r0, r9                  # | Check item switch
    or r0, r0, r9               # |
    rlwinm. r9, r0, 1, 31, 31   # /
    beq+ switchOff      
    li r10, -1
    b end
checkVariantOn:
    lwz r12, 0x30(r6)       # \ 
    andis. r12, r12, 0x4    # | Check if plus items is turned on
    bne+ end                # /
    li r23, 0x0     # set variant to 0 (all variants combine probabilities)
    b end
switchOff:
    li r10, 0
end:
    cmpwi r10, 0
    rlwinm r0, r8, 29, 3, 29   # \ 
    rlwinm r3, r8, 0, 27, 31   # | Original operation
    lwzx r0, <switchReg>, r0   # /
}
HOOK @ $809b39d8    # itManager::getPerBase
{
    lfs f1, 0x8(r23)  # get frequency
    cmpwi r0, 0     # Original operation
}
HOOK @ $809b39fc    # itManager::getPerBase
{
    %checkItemSwitch(r29, r22, r23, r31)
}
CODE @ $809b3a00 
{
    beq- 0x28
    blt- 0x10
}
op nop @ $809b3a14
HOOK @ $809b4d50    # itManager::getLotOneItemKind
{
    lfs f1, 0x8(r23)  # get frequency
    cmpwi r0, 0     # Original operation
}
HOOK @ $809b4d74    # itManager::getLotOneItemKind
{
    %checkItemSwitch(r31, r22, r23, r20)
}
CODE @ $809b4d78
{
    beq- 0x1CC 
    blt- 0x10
}
op nop @ $809b4d8c
op nop @ $809b4dac
HOOK @ $809b5654    # itManager::safeLotCreateItem
{
    lfs f1, 0x8(r19)  # get frequency
    cmpwi r0, 0     # Original operation
}
HOOK @ $809b5678    # itManager::safeLotCreateItem
{
    %checkItemSwitch(r15, r24, r19, r20)
}
CODE @ $809b567c    
{
    beq- 0x7F0
    blt- 0x10
}
op nop @ $809b576c
HOOK @ $809b56a4
{
    cmpwi r17, 0        # \ check if genParam is negative
    bge+ notEnemyLot    # /
    lhz r12, 0x10BC(r15)    # \
    lwz r11, 0x4(r19)       # |
    li r10, 0x1             # | check if next assist variation
    cmpw r11, r12           # |
    bne+ notNextAssist      # /
    li r10, 0x0
notNextAssist:
    cmpwi r10, 0x1
    b %end%
notEnemyLot: 
    fcmpo cr0,f31,f30   # Original operation
}

###############################
# Variant support for Pokemon #
###############################

op lhz r0, 0x2(r3) @ $809b0850    # itManager::isExclusiveManaphy
CODE @ $809b55a8    # itManager::safeLotCreateItem
{
    lhz r5, 0x0(r4) # Get itVariation from first two bytes
    lhz	r4, 0x2(r4) # Get itKind from last two bytes
}
HOOK @ $809b5918    # itManager::safeLotCreateItem
{
    lhz r23, 0x0(r3)    # Get itVariation from first two bytes
    lhz r21, 0x2(r3)    # Get itKind from last two bytes
}
CODE @ $809b5938    # itManager::safeLotCreateItem
{
    lhz r5, 0x0(r4) # Get itVariation from first two bytes
    lhz	r4, 0x2(r4) # Get itKind from last two bytes
}
HOOK @ $809b59b8    # itManager::safeLotCreateItem
{
    andi. r12, r20, 0xffff      # Get itKind from last two bytes
    cmpwi r12, 120              # Original operation
}
op lhz r0, 0x2(r3) @ $809b5a00    # itManager::safeLotCreateItem  
CODE @ $809b5a2c    # itManager::safeLotCreateItem
{
    lhz r5, 0x0(r4) # Get itVariation from first two bytes
    lhz	r4, 0x2(r4) # Get itKind from last two bytes
}
CODE @ $809b5afc    # itManager::safeLotCreateItem
{
    andi. r4, r20, 0xffff       # Get itKind from last two byte
    srwi r5, r20, 16            # Get itVariation from first two bytes
}
op b 0x38 @ $809b5c5c # Skip checking if variant is less than max variant
HOOK @ $809b1b4c    # itManager::removeItemAfter
{
    mr r26, r5          # \ Store itVariation on stack
    stw r26, 0x8(r1)    # /
}
HOOK @ $809b2088    # itManager::removeItemAfter
{
    srwi r12, r0, 16        # Get itVariation from first two bytes
    andi. r0, r0, 0xffff    # Get itKind from last two bytes
    cmpw r29, r0            # \ Check if desired itKind
    bne+ %end%              # /
    lwz r11, 0x8(r1)        # \ Check if desired itVariation
    cmpw r11, r12           # /
}
HOOK @ $809b2158    # itManager::removeItemAfter
{
    lwz r12, 0xc(r4)    # Get itArchive->itVariation
    cmpw r0, r29        # \ Check if desired itKind
    bne+ %end%          # /
    lwz r11, 0x8(r1)    # \ Check if desired itVariation
    cmpw r12, r11       # / 
}
CODE @ $809b0b9c    # itManager::checkCreatableItem
{
    lhz r5, 0x0(r4) # Get itVariation from first two bytes
    lhz	r4, 0x2(r4) # Get itKind from last two bytes
}
op lhz r4, 0x2(r3) @ $809b0ff8    # itManager::checkCreatableItem
CODE @ $809b1004    # itManager::checkCreatableItem
{
    lhz r5, 0x0(r3) # Get itVariation from first two bytes
    mr r3, r26      # Original operation
} 
HOOK @ $809ad7d4    # itManager::processBegin
{
    mr r5, r4   # Pass variation as extra parameter to itManager::preloadPokemon
    mr r4, r3   # Original operation
}
HOOK @ $809afcf0    # itManager::preloadPokemon
{
    mr r31, r3      # Original operation
    sth r5, 0x8(r1) # Store variation on stack
    cmpwi r5, 5000          # \ Check if variant == 5000
    bne+ notRandomVariant   # /
    li r3, 0x0
    %lwd (r12, g_GameGlobal)    # \
    lwz r12, 0x8(r12)           # |
    lwz r12, 0x30(r12)          # | Check if plus items is turned on
    andis. r12, r12, 0x4        # | 
    beq- noVariants             # /
    lhz	r3, 0xA(r1)         # Get itKind
    %lwi (r11, g_itKindVariationNums)  # \ 
    rlwinm r3, r3, 2, 0, 29            # | g_itKindVariationNums[itKind]
    lwzx r3, r11, r3                   # /
    %call (randi)           # Get random variation from 0 to itKindVariationNum
noVariants:
    sth r3, 0x8(r1) # Store new variantion on stack
notRandomVariant:
    mr r3, r31      # Put back itManager in r3
    lhz r4, 0xA(r1) # Put back itKind in r4
}
HOOK @ $809afd74    # itManager::preloadPokemon
{
    mr r30, r3
    mr r29, r30
    b startLoop
loop:
    subi r29, r29, 1
    addi r3, r31, 0x10C8    # \
    mr r4, r29              # |
    lwz r12, 0x10C8(r31)    # | itManager->itKindPokemonArrayList->at(index)
    lwz r12, 0xc(r12)       # |
    mtctr r12               # |
    bctrl                   # /
    lhz r10, 0x2(r3)    # \
    lhz r12, 0xA(r1)    # | Check if desired itKind already in the list of Pokemon
    cmpw r12, r10       # |
    bne+ startLoop      # /
    lhz r10, 0x0(r3)    # Get variant
    lhz r12, 0x8(r1)    # Get desired variant
    cmpw r10, r12       # \ Check if equal
    beq+ startLoop      # /                        
    cmpwi r10, 0x0      # \ 
    ble+ startLoop      # | Check if one of the variants is 0 (which does not use extra soundbank)
    cmpwi r12, 0x0      # | 
    ble+ startLoop      # /
    andi. r10, r10, 0x800   # \ 
    beq+ startLoop          # | check if either variant third last digit is < 8 (which does not use extra soundbank)
    andi. r12, r12, 0x800   # |  
    beq+ startLoop          # /
dontPreload:
    li r3, 0x0              # \ Don't preload if variant with same itKind already exists (to avoid clashing sfx group ids)
    %branch (0x809affc8)    # / 
startLoop:
    cmpwi r29, 0
    bgt+ loop
endLoop:
    %lbd (r12, PKM_OVERLOAD_AMOUNT_ADDR)        # \ Add Pokemon overload amount 
    addi r12, r12, DEFAULT_PKM_VARIETY_AMOUNT   # /
    cmpw r30, r12       # Original operation
}
HOOK @ $809ad73c    # itManager::processBegin
{
    %lbd (r12, PKM_OVERLOAD_AMOUNT_ADDR)        # \ Add Pokemon overload amount 
    addi r12, r12, DEFAULT_PKM_VARIETY_AMOUNT   # /
    cmpw r3, r12       # Original operation
}
HOOK @ $809afe68    # itManager::preloadPokemon
{
    andi. r11, r28, 0xffff      # Get itKind from last two bytes
    cmpw r11, r0                # \ Check if desired itKind
    bne+ %end%                  # /
    lwz r10, 0x8C4(r4)          # Get baseItem->itVariation
    srwi r12, r28, 16           # Get itVariation from first two bytes  
    cmpw r10, r12               # Check if desired itVariation
}
HOOK @ $809aff30    # itManager::preloadPokemon
{
    andi. r11, r28, 0xffff      # Get itKind from last two bytes
    cmpw r11, r0                # \ Check if desired itKind
    bne+ %end%                  # /
    lwz r10, 0xc(r3)            # Get itArchiveType->itVariation
    srwi r12, r28, 16           # Get itVariation from first two bytes 
    cmpw r10, r12               # Check if desired itVariation
}
op lhz r5, 0x8(r1) @ $809aff84  # itManager::preloadPokemon
op lhz r4, 0xA(r1) @ $809aff8c  # itManager::preloadPokemon

HOOK @ $809af008    # itManager::preloadItemKindArchive
{
    li r14, 0
    mr r3, r15              # \
    lwzu r12, 0xC8(r3)      # |
    lwz r12, 0x14(r12)      # | itManager->itArchiveArrayList.size()
    mtctr r12               # |
    bctrl                   # /
    mr r18, r3
    b startLoop
loop:
    mr r4, r18              # \
    mr r3, r15              # |
    lwzu r12, 0xC8(r3)      # | itArchive** archive = itManager->itArchiveArrayList.at(i)
    lwz r12, 0x10(r12)      # |
    mtctr r12               # |
    bctrl                   # /
    lwz r3, 0x0(r3)                     # \
    cmpwi r3, 0x0                       # | Check if itArchive is not null
    beq+ startLoop                      # / 
    lwz r4, 0x0(r3)                     # \
    cmpwi r4, 11                        # | Check if the itArchive has an itArchiveType of 11 
    bne+ startLoop                      # /
    lwz r4, 0x8(r3)                     # \
    rlwinm r6, r4, 2, 0, 29             # |
    %lwi (r12, g_itKindRemovableItKind) # |
    lwzx r5, r12, r6                    # | Check if the itArchive is the main archive for the Pokemon (i.e. not just the shot)
    cmpw r5, r4                         # | 
    bne- startLoop                      # /
    rlwinm r6, r16, 2, 0, 29            # \
    lwzx r6, r12, r6                    # | Check if corresponding itKind already exists
    cmpw r5, r6                         # |
    beq- startLoop                      # /
    addi r14, r14, 0x1                  # Add to Pokemon loaded in PokemonResource count
startLoop:
    subi r18, r18, 0x1
    cmpwi r18, 0
    bge- loop
    li r18, 11  # Set itArchiveType to 11 (custom itArchiveType for Pokemon loaded in PokemonResource)
    cmpwi r14, DEFAULT_PKM_VARIETY_AMOUNT   # \ Check if PokemonResource is full
    blt+ end                                # /
    li r18, 12      # Set itArchiveType to 12 (custom itArchiveType for Pokemon loaded in StageResource)
    li r20, 0x11    # Use StageResource to load Pokemon instead
end:
    mr r3, r20  # Original operation
}
HOOK @ $809af024    # itManager::preloadItemKindArchive
{   
    li r3, 0        # Original operation
    cmpwi r20, 0x11 # \ check if already using StageResource
    beq+ %end%      # /
    %lbd (r12, PKM_OVERLOAD_AMOUNT_ADDR)    # \
    cmpwi r12, 0x0                          # | Check if should be overloading Pokemon
    beq+ %end%                              # /
    li r20, 0x11    # Set to use StageResource
    %branch(0x809af008)
}
HOOK @ $809bca24    # itArchive::__ct
{   
    li r29, 38  # Original operation
    lwz r0,0x0(r25) # \
    cmpwi r0, 11    # | check if itArchiveType is 11 (i.e. Pokemon that should load to PokemonResource)
    beq+ %end%      # /
    li r29, 0x11    # Use StageResource to load Pokemon instead
}
HOOK @ $809ad238    # itManager::finish
{
    mr r3, r31                              # \
    li r4, 11                               # |
    %call (itManager__removeItemArchive)    # | Remove custion itArchiveType for Pokemon
    mr r3, r31                              # |
    li r4, 12                               # |
    %call (itManager__removeItemArchive)    # /
    li r0, -1   # Original operation
}

HOOK @ $809b0bf4    # itManager::checkCreatableItem
{
    %lwd (r12, g_GameGlobal)    # \
    lwz r12, 0x8(r12)           # |
    lwz r12, 0x38(r12)          # | Check if uncapped Pokemon amount
    cmpwi r12, 0                # |
    blt- %end%                  # /
    %lbd (r12, PKM_OVERLOAD_AMOUNT_ADDR)        # \ Add Pokemon overload amount 
    addi r12, r12, DEFAULT_PKM_VARIETY_SPAWN    # /
    cmpw r0, r12    # check if numPokemon + numPokeballs < default Pkm variety + pkm overload
}

op lbz r0, 0x1168(r26) @ $809b0bec  # itManager::checkCreatableItem \
op lbz r3, 0x1168(r15) @ $809b1968  # itManager::createBaseItem     |
op stb r0, 0x1168(r15) @ $809b1970  # itManager::createBaseItem     | Make numPokeballs only occupy a byte
op lbz r3, 0x1168(r24) @ $809b2350  # itManager::removeItemAfter    |
op stb r0, 0x1168(r24) @ $809b2358  # itManager::removeItemAfter    /

###############################
# Variant support for Assists #
###############################

op lhz r0, 0x10BE(r3) @ $809b0600   # itManager::isExclusiveSpecialItem
op lhz r0, 0x10BE(r3) @ $809af544   # itManager::removeRequestTrainingItem
op lhz r0, 0x10BE(r28) @ $809af698  # itManager::removeRequestTrainingItem
CODE @ $809b5514        # itManager::safeLotCreateItem
{
    lhz r4, 0x10BE(r15)     # Get itKind from last two bytes
    cmplwi r4, 0xFFFF       # Check if -1
}
op lhz r5, 0x10BC(r15) @ $809b5524  # itManager::safeLotCreateItem
CODE @ $809b5844        # itManager::safeLotCreateItem
{
    lhz r4, 0x10BE(r15)     # Get itKind from last two bytes
    cmplwi r4, 0xFFFF       # Check if -1
}
op lhz r5, 0x10BC(r15) @ $809b5854  # itManager::safeLotCreateItem
HOOK @ $809b5870    # itManager::safeLotCreateItem
{
    lhz r23, 0x10BC(r15)    # Get itVariation from first two bytes
    lhz r21, 0x10BE(r15)    # Get itKind from last two bytes
}
CODE @ $809b587c    # itManager::safeLotCreateItem
{
    lhz r4, 0x10BE(r15)     # Get itKind from last two bytes
    cmplwi r4, 0xFFFF       # Check if -1
}
op lhz r5, 0x10BC(r15) @ $809b588c  # itManager::safeLotCreateItem
CODE @ $809b0b44    # itManager::checkCreatableItem
{
    lhz r4, 0x10BE(r26)     # Get itKind from last two bytes
    cmplwi r4, 0xFFFF       # Check if -1
}
op lhz r5, 0x10BC(r26) @ $809b0b54  # itManager::checkCreatableItem
op lhz r0, 0x10BE(r26) @ $809b0f10  # itManager::checkCreatableItem
op lhz r0, 0x10BE(r28) @ $809ad444  # itManager::processBegin
op lhz r3, 0x10BE(r28) @ $809ad470  # itManager::processBegin
HOOK @ $809ad4ec    # itManager::processBegin
{
    mr r5, r4   # Pass variation as extra parameter to itManager::preloadAssist
    mr r4, r3   # Original operation
}
HOOK @ $809ad6f0    # itManager::processBegin
{
    mr r5, r4   # Pass variation as extra parameter to itManager::preloadAssist 
    mr r4, r3   # Original operation
}
HOOK @ $80952750    # stOperatorDropItemEvent::startOperator
{
    li r4, 134  # Original operation
    li r5, 0    # Pass variation as extra parameters to itManager::preloadAssist
}
CODE @ $809afa0c    # itManager::preloadAssist
{
    stwu r1,-0x30(r1)               # \
    mflr r0                         # | 
    stw r0,0x34(r1)                 # |
    addi r11,r1,0x30                # | Increase stack frame
}                                   # |
op addi	r11, r1, 0x30 @ $809afcc0   # |
op lwz r0, 0x34(r1) @ $809afcc8     # |
op addi r1, r1, 0x30 @ $809afcd0    # /
HOOK @ $809afa20    # itManager::preloadAssist
{
    stw r5, 0x8(r1)     # Store variation for later
    lwz	r5, 0x4C(r3)    # Original operation
}
CODE @ $809afa98    # itManager::preloadAssist
{
    lhz r4, 0x10BE(r3)
    cmplwi r4, 0xFFFF
}
CODE @ $809afaa4    # itManager::preloadAssist
{
    lhz r5, 0x10BC(r3)
    mr r3, r30
}
HOOK @ $809afc90    # itManager:preloadAssist
{
    lwz r3, 0x8(r1)         # \
    cmpwi r3, 5000          # | Check if variant == 5000
    bne+ notRandomVariant   # /
    li r5, 0x0
    %lwd (r12, g_GameGlobal)    # \
    lwz r12, 0x8(r12)           # |
    lwz r12, 0x30(r12)          # | Check if plus items is turned on
    andis. r12, r12, 0x4        # | 
    beq+ noVariants             # /
    %lwi (r11, g_itKindVariationNums)  # \ 
    rlwinm r5, r31, 2, 0, 29            # | g_itKindVariationNums[itKind]
    lwzx r5, r11, r5                   # /
    cmpwi r5, 0             # \ Check if itKindVariationNums < 0
    ble+ notRandomVariant   # /
    mr r3, r5
    %call (randi)           # Get random variation from 0 to itKindVariationNum
notRandomVariant:
    mr r5, r3               # Pass itVariation
noVariants:
    slwi r12, r5, 16    # \
    add r31, r12, r31   # / Add variation to itKind
    mr r3, r30      # Original operation
}
op andi. r4, r31, 0xFFFF @ $809afc98 # itManager:preloadAssist

op nop @ $809b0b00      # itManager::checkCreatableItem
HOOK @ $809b0b28        # itManager::checkCreatableItem
{
    li r0, 0
    %lwd (r12, g_GameGlobal)    # \
    lwz r12, 0x8(r12)           # |
    lwz r12, 0x3C(r12)          # | Check if uncapped Assist amount
    cmpwi r12, 0                # |
    blt- %end%                  # /
    lwz	r11, 0x10C0(r26)    # \
    lbz	r12, 0x1169(r26)    # | this->numAssists + this->numAssistTrophies
    add r0, r11, r12        # /
}

.macro checkAssistTrophy(<itKindReg>, <itVariationReg>)
{
    cmpwi <itKindReg>, 0    # \ check if itKind is an Assist Trophy
    beq+ isAssistTrophy     # /
    %lwi (r12, ITSWITCH_CHECK_INDICES)  # \
    mulli r11, <itKindReg>, 2           # |
    add r12, r12, r11                   # | check ITSWITCH_CHECK_INDICES to see if itKind is considered a container
    lbz r12, 0x1(r12)                   # |
    cmpwi r12, 0xFF                     # |
    bne+ end                            # /
    li r11, 0x6                     # \ variant / 6 to get type of container (i.e. canHaveItem, canHaveExplosion, canHaveEnemy)   
    divw r11, <itVariationReg>, r11 # /
    cmpwi r11, 0x2  # \ check if enemy container
    bne+ end        # / 
}
HOOK @ $809b1960    # itManager::createBaseItem
{
    %checkAssistTrophy(r18, r19)
isAssistTrophy:
    lbz r12, 0x1169(r15)    # \
    addi r12, r12, 0x1      # | this->numAssistTrophies += 1
    stb r12, 0x1169(r15)    # /
end:
    cmpwi r18, 42   # Original operation
}
HOOK @ $809b2348    # itManager::removeItemAfter
{
    lwz r10, 0x8(r1)    # get itVariation
    %checkAssistTrophy(r25, r10)
isAssistTrophy:
    lbz r12, 0x1169(r24)    # \
    subi r12, r12, 0x1      # | this->numAssistTrophies -= 1
    stb r12, 0x1169(r24)    # /
end:
    cmpwi r25, 42   # Original operation
}

############################################################################
# Allow stages to override probabilities of other Item sets in ItmGenParam #
############################################################################

HOOK @ $809b3bfc    # itManager::getRandBasicItemValue
{
    mr r25, r5      # Original operation
    li r4, 10000    # Pass genParamId as extra parameter to itManager::getRandBasicItemSheet
}
HOOK @ $809b3e30    # itManager::getRandBasicItemVariation
{
    mr r28, r4      # Original operation
    li r4, 10000    # Pass genParamId as extra parameter to itManager::getRandBasicItemSheet
}
HOOK @ $809b4fe8    # itManager::getLotKirbyNormalItemKind
{
    stw	r0, 0x28(r1)    # Original operation
    li r4, 10000        # Pass genParamId as extra parameter to itManager::getRandBasicItemSheet
}
HOOK @ $809b50cc    # itManager::getLotKirbyTabemonoItemKind
{
    mr r3, r31      # Original operation
    li r4, 10000    # Pass genParamId as extra parameter to itManager::getRandBasicItemSheet
}
HOOK @ $809b57ac    # itManager::safeLotCreateItem
{
    mr r3, r15      # Original operation
    li r4, 10000    # Pass genParamId as extra parameter to itManager::getRandBasicItemSheet
}
HOOK @ $809ad7a4    # itManager::processBegin
{
    mr r3, r28                                  # \
    li r4, 0x2A                                 # |
    %call (itManager__getRandBasicItemSheet)    # |
    mr r7, r3                                   # | Pass itSheet so ItmGen in stage can override Pokemon probabilities
    mr r0, r4                                   # |
}                                               # |
op nop @ $809ad7b0                              # /
HOOK @ $809ad4bc    # itManager::processBegin   
{                                               
    mr r3, r28                                  # \
    li r4, 0                                    # |
    %call (itManager__getRandBasicItemSheet)    # | 
    mr r7, r3                                   # | Pass itSheet so ItmGen in stage can override Assist probabilities
    mr r0, r4                                   # |
}                                               # |
op nop @ $809ad4c8                              # /
HOOK @ $809ad6c0    # itManager::processBegin 
{
    mr r3, r28                                  # \
    li r4, 0                                    # |
    %call (itManager__getRandBasicItemSheet)    # | 
    mr r7, r3                                   # | Pass itSheet so ItmGen in stage can override Assist probabilities
    mr r0, r4                                   # |
}                                               # |
op nop @ $809ad6cc                              # /
CODE @ $809b3a60    # itManager::getRandBasicItemSheet
{
    stwu r1,-0x50(r1)               # \
    mflr r0                         # |
    stw r0,0x54(r1)                 # |
    addi r11,r1,0x50                # | Make more room on stack
}                                   # |
op addi r11, r1, 0x50 @ $809b3bc0   # |
op lwz r0, 0x54(r1) @ $809b3bd0     # |
op addi r1, r1, 0x50 @ $809b3bd8    # /
HOOK @ $809b3a74    # itManager::getRandBasicItemSheet
{
    stw r4, 0x20(r1)    # Store genParamId extra parameter on stack
    lis	r5, 0x80B9      # Original operation
}
op lwz r4, 0x20(r1) @ $809b3b7c # Use desired genParamId (instead of always using 10000)

HOOK @ $8095219c        # stOperatorDropItemMelee::processBegin
{
    mr r29, r3                                  # \
    li r4, 10001                                # |
    %call (itManager__getRandBasicItemSheet)    # | Get item from 10001 in ItmGen rather than always picking only Bombs in Bomb Rain/Sudden Death
    stw r3, 0x8(r1)                             # | 
    stw r4, 0xc(r1)                             # /
    li r12, -1                                  # \           
    stw r12, 0x30(r1)                           # |
    stw r12, 0x34(r1)                           # |
    stw r12, 0x38(r1)                           # | allow all items to be on 
    stw r12, 0x3C(r1)                           # |
    stw r12, 0x40(r1)                           # |
    stw r12, 0x44(r1)                           # /
    mr r3, r29                                  # \
    addi r4, r1, 0x8                            # | 
    li r5, 10001                                # |
    addi r6, r1, 0x30                           # | pick item
    li r7, 0x0                                  # |
    %call (itManager__getLotOneItemKind)        # |
    mr r5, r3                                   # |
    mr r6, r4                                   # /
    mr r3, r29              # Put itManager back in r3
    li r0, 0                # Original operation
}
op b 0x8 @ $809521b8

HOOK @ $809521d0    # stOperatorDropItemMelee::processBegin
{
    cmpwi r3, 0x0   # Check if item was created
    lis	r3, 0x805A  # \ Original operations
    addi r5, r1, 32 # /
}
op beq+ 0x10 @ $809521d4 # Skip effect if item wasn't created 

HOOK @ $8095217c    # stOperatorDropItemMelee::processBegin
{
    lis	r3, 0x80B9      # \
    lwz	r3, -0x5BD8(r3) # |
    lwz	r12, 0x3C(r3)   # | g_Stage->getIteamDropStatus()
    lwz r12, 0x1f0(r12) # |
    mtctr r12           # |
    bctrl               # /
    cmpwi r3, 0x0
    bne+ end
    %branch(0x80952208)
end:
    lis	r3, 0x80B9  # Original operation
}

####################
# Item Switch Menu #
####################
op li r3, 688 @ $806ce974   # \
op li r3, 688 @ $806cea40   # | Increase size of muRuleTask (also need module edits for tournament mode compatibility)
op li r3, 688 @ $80692f50   # /

HOOK @ $806a3fb0    # muRuleTask::__ct
{
    cmpwi r25, 49           # \
    bne+ dontJumpToExtra    # |
    addi r19, r19, 0x110    # | Jump to extra muObjects if past normal itSwitch muObjects
dontJumpToExtra:            # |
    cmpwi r25, 54           # /
}
int 0x3A @ $806AD210  # muRuleTask::__ct set number of muObjects to construct in scn
HOOK @ $806a4368    # muRuleTask::__ct
{
    cmpwi r19, 49           # \
    bne+ dontJumpToExtra    # |
    addi r18, r18, 0x110    # | Jump to extra muObjects if past normal itSwitch muObjects
dontJumpToExtra:            # |
    cmpwi r19, 54           # /
}
HOOK @ $806a41d0    # muRuleTask::__ct
{
    cmpwi r19, 130          # \
    bne+ dontJumpToExtra    # |
    addi r18, r18, 0x4C     # | Jump to extra muObjects if past normal itSwitch muObjects
dontJumpToExtra:            # |
    cmpwi r19, 135          # /
}
HOOK @ $806a470c    # muRuleTask::__dt
{
    cmplwi r29, 130         # \
    bne+ dontJumpToExtra    # |
    addi r30, r30, 0x4C     # | Jump to extra muObjects if past normal itSwitch muObjects
dontJumpToExtra:            # |
    cmplwi r29, 135         # /
}
HOOK @ $806aa770    # muProcItemSwitch::init
{
    addi r4, r26, 32        # Original operation
    cmpwi r26, 49           # \
    blt+ %end%              # | Jump to extra muObjects if past normal itSwitch muObjects
    addi r4, r4, 68         # / 
}
HOOK @ $806aa72c    # muProcItemSwitch::init
{
    addi r4, r26, 32        # Original operation
    cmpwi r26, 49           # \
    blt+ %end%              # | Jump to extra muObjects if past normal itSwitch muObjects
    addi r4, r4, 68         # / 
}
HOOK @ $806aa788    # muProcItemSwitch::init
{
    addi r4, r26, 32        # Original operation
    cmpwi r26, 49           # \
    blt+ %end%              # | Jump to extra muObjects if past normal itSwitch muObjects
    addi r4, r4, 68         # / 
}
HOOK @ $806aa794    # muProcItemSwitch::init
{
    lbz r11, 0x679(r30)
    %lwi (r12, NUM_SUB_ITSWITCHES)
    lbzx r11, r12, r11
    lis	r12, 0x806B
    lfs f1, -0x2D14(r12)
    cmplw r26, r11 
    blt+ isVisible
    lfs f1, -0x2D18(r12)
isVisible:
    mr r3, r30
    addi r4, r26, 0x20
    cmpwi r26, 49           # \
    blt+ notExtraMuObject   # | Jump to extra muObjects if past normal itSwitch muObjects
    addi r4, r4, 68         # / 
notExtraMuObject:
    li r5, 0x2 
    %call (muProcMenu__setAnimFrame)
    addi r26, r26, 1    # Original operation
}
op cmpwi r26, 54 @ $806aa798 # muProcItemSwitch::init

HOOK @ $806aa7b0    # muProcItemSwitch::init 
{
    li r9, -1
    lbz r11, 0x679(r30)
    %lwi (r12, NUM_SUB_ITSWITCHES)  # \ Get NUM_SUB_ITSWITCH
    lbzx r10, r12, r11              # /
    addi r12, r12, 0x38             # \ Get SUB_ITSWITCH_ALL_START_END
    lbzx r11, r12, r11              # /
    li r12, 64                      
    sub r10, r12, r10               
    extsb. r11, r11                 # \ Check if negative
    blt+ isNegative                 # /
    srw r8, r9, r10                 # \
    subi r10, r10, 0x20             # | leftMask = -1 >> 64 - NUM_SUB_ITSWITCH 
    srw r7, r9, r10                 # /
    slw r3, r9, r11                 # \
    subi r11, r11, 0x20             # | rightMask = -1 << SUB_ITSWITCH_ALL_START
    slw r0, r9, r11                 # /
    and r3, r3, r7                  # \ mask = leftMask & rightMask 
    and r0, r0, r8                  # /
    b %end%                         
isNegative:
    sub r11, r10, r11               # \ 
    srw r0, r9, r11                 # | mask = -1 >> (64 - NUM_SUB_ITSWITCH - SUB_ITSWITCH_ALL_END)
    subi r11, r11, 0x20             # |
    srw r3, r9, r11                 # /
}
op nop @ $806aae94  # muProcItemSwitch::selectProc 
HOOK @ $806aae9c    # muProcItemSwitch::selectProc 
{
    lbz r11, 0x679(r27)                     # \
    %lwi (r12, SUB_ITSWITCH_ALL_START_END)  # |
    lbzx r12, r12, r11                      # | Don't unselect past certain integer if SUB_ITSWITCH_ALL_START_END is positive
    extsb. r12, r12                         # |
    blt+ %end%                              # |
    mr r31, r12                             # /
}
HOOK @ $806aaeb8    # muProcItemSwitch::selectProc  
{
    li r3, 0            # \
    li r4, 1            # |
    subi r5, r31, 0x1   # |
    cmplwi r31, 49      # |
    ble+ notExtra       # |
    subi r5, r5, 68     # |
notExtra:               # | Turn on bitflag
    %call (__shl2i)     # |
    lwz r0, 0x680(r27)  # |
    or r0, r0, r3       # | 
    stw r0, 0x680(r27)  # |
    lwz r0, 0x684(r27)  # |
    or r0, r0, r4       # |
    stw r0, 0x684(r27)  # /
    lbz r11, 0x679(r27)             # \
    %lwi (r10, NUM_SUB_ITSWITCHES)  # |
    lbzx r12, r10, r11              # |
    addi r10, r10, 0x38             # | Don't select all
    lbzx r11, r10, r11              # | numToSelect = NUM_SUB_ITSWITCH + SUB_ITSWITCH_ALL_START_END (if negative)
    extsb. r11, r11                 # | 
    bgt+ notNegative                # |
    add r12, r12, r11               # |
notNegative:                        # /
    cmplwi r31, 49          # \
    bne+ dontJumpToExtra    # |
    addi r31, r31, 68       # | 
dontJumpToExtra:            # | Jump to extra muObjects if past normal itSwitch muObjects
    blt+ dontAdd            # |
    addi r12, r12, 68       # |
dontAdd:                    # /
    cmplw r31, r12     
}
op nop @ $806aaf04  # muProcItemSwitch::selectProc  
HOOK @ $806aaf0c    # muProcItemSwitch::selectProc  
{
    lbz r11, 0x679(r27)                     # \
    %lwi (r12, SUB_ITSWITCH_ALL_START_END)  # | 
    lbzx r12, r12, r11                      # | Don't unselect past certain integer if SUB_ITSWITCH_ALL_START_END is positive
    extsb. r12, r12                         # |
    blt+ %end%                              # |
    mr r31, r12                             # /
}
HOOK @ $806aaf28    # muProcItemSwitch::selectProc  
{   
    li r3, 0            # \
    li r4, 1            # |
    subi r5, r31, 0x1   # |
    cmplwi r31, 49      # |
    ble+ notExtra       # |
    subi r5, r5, 68     # |
notExtra:               # |
    %call (__shl2i)     # | Turn off bitflag
    lwz r0, 0x680(r27)  # |
    not r3, r3          # |
    and r0, r0, r3      # | 
    stw r0, 0x680(r27)  # |
    lwz r0, 0x684(r27)  # |
    not r4, r4          # |
    and r0, r0, r4      # |
    stw r0, 0x684(r27)  # /
    lbz r11, 0x679(r27)             # \
    %lwi (r10, NUM_SUB_ITSWITCHES)  # |
    lbzx r12, r10, r11              # |
    addi r10, r10, 0x38             # | Don't unselect all
    lbzx r11, r10, r11              # | numToSelect = NUM_SUB_ITSWITCH + SUB_ITSWITCH_ALL_START_END (if negative)
    extsb. r11, r11                 # | 
    bgt+ notNegative                # |
    add r12, r12, r11               # |
notNegative:                        # /
    cmplwi r31, 49          # \
    bne+ dontJumpToExtra    # |
    addi r31, r31, 68       # | 
dontJumpToExtra:            # | Jump to extra muObjects if past normal itSwitch muObjects
    blt+ dontAdd            # |
    addi r12, r12, 68       # |
dontAdd:                    # /
    cmplw r31, r12    
}
HOOK @ $806aafb8    # muProcItemSwitch::selectProc  
{
    addi r4, r26, 32    # Original operation
    cmpwi r4, 0x51      # \ 
    blt+ %end%          # | Jump to extra muObjects if past normal itSwitch muObjects
    addi r4, r4, 68     # /
}
HOOK @ $806aaff4    # muProcItemSwitch::selectProc  
{
    addi r4, r26, 32    # Original operation
    cmpwi r4, 0x51      # \ 
    blt+ %end%          # | Jump to extra muObjects if past normal itSwitch muObjects
    addi r4, r4, 68     # /
}

op mulli r5, r5, 0x2 @ $806ab200    # muProcItemSwitch::printHelp
CODE @ $806ab230    # muProcItemSwitch::printHelp
{
    mulli r5, r0, 0x2
    addi r5, r5, 0x1
}
op li r5, 15 @ $806ab2a8   # muProcItemSwitch::printHelp
op li r5, 14 @ $806ab2c0   # muProcItemSwitch::printHelp
HOOK @ $806ab2ec    # muProcItemSwitch::printHelp
{
    subi r31, r8, 2     # Make msg index sequential
    mulli r31, r31, 0x3
    addi r5, r31, 16    
} 
op addi r5, r31, 18 @ $806ab2fc     # muProcItemSwitch::printHelp
op addi r5, r31, 17 @ $806ab310     # muProcItemSwitch::printHelp

byte[0x38] 0x35, 0, 0, 28, 28, 8, 0, | # num switch entries per sub category
0, 0, 0, 0, 0, 0, 0, |
0, 0, 0, 0, 0, 0, 0, |
0, 0, 0, 0, 0, 0, 0, |
0, 0, 0, 0, 0, 0, 0, |
0, 0, 0, 0, 0, 0, 0, |
0, 0, 0, 0, 0, 0, 0, |
0, 0, 0, 1, 0, 0, 0  |
@ $806AD300
byte[0x38] 0xFE, 0, 0, 1, 1, 3, 0, | # num switch entries per sub category
0, 0, 0, 0, 0, 0, 0, |
0, 0, 0, 0, 0, 0, 0, |
0, 0, 0, 0, 0, 0, 0, |
0, 0, 0, 0, 0, 0, 0, |
0, 0, 0, 0, 0, 0, 0, |
0, 0, 0, 0, 0, 0, 0, |
0, 0, 0, 0, 0, 0, 0  |
@ $806AD338
op bl -0x2B9768 @ $806aaa7c     # muProcItemSwitch::selectProc  # \ savegpr_24
op bl -0x2B9DA4 @ $806ab104     # muProcItemSwitch::selectProc  # / restgpr_24
HOOK @ $806aaad0    # muProcItemSwitch::selectProc
{
    %lwi (r12, NUM_SUB_ITSWITCHES)  # \
    lbz r11, 0x679(r27)             # |
    lbzx r11, r12, r11              # | check if only first row
    li r24, 1                       # |
    addi r25, r11, 0x1              # |
    cmpwi r11, 5                    # |
    ble+ end                        # /
    subi r11, r11, 5                # \ Calculate row and col limit based on num of entries
    li r12, 7                       # | colLimit = (numEntries - 5) % 7 - 1
    divw r12, r11, r12              # | rowLimit = (numEntries - 5) / 7
    addi r24, r12, 0x2              # |
    mulli r12, r12, 7               # |
    subf r12, r12, r11              # |
    subi r25, r12, 0x1              # /
end:
    rlwinm.	r0, r4, 0, 31, 31   # Original operation
}
op cmplw r0, r25 @ $806aab7c        # \
op cmplw r0, r25 @ $806aaae4        # | 
op mr r0, r25 @ $806aac8c           # | 
op cmplw r0, r25 @ $806aada8        # |
op subi r0, r24, 0x1 @ $806aaaec    # |
op mr r0, r24 @ $806aaaf8           # |
op cmplw r7, r24 @ $806aab5c        # | muProcItemSwitch::selectProc 
HOOK @ $806aab70                    # | Apply new rol and col limit
{                                   # |
    mr r12, r24                     # |
    cmpwi r12, 1                    # |
    beq+ oneRow                     # |
    subi r12, r24, 0x1              # |
oneRow:                             # |
    cmplw r7, r12                   # |
}                                   # |
op cmplw r7, r24 @ $806aac84        # |
op cmplw r7, r24 @ $806aada0        # /
HOOK @ $806AAAF0
{
	lwz r11, 0x670(r3)
	li r12, 6
    cmpwi r24, 0x1
    bne+ notOneRow
    mr r12, r25
    li r0, 1
notOneRow:
    stw r0, 0x674(r3)	# Original operation: Wrap around to bottom Y column from Item Frequency bar
    cmpw r11, r12
	ble+ %END%	
	stw r12, 0x670(r3)   # Fix X column so it doesn't try to go to the next row by accident
}
HOOK @ $806AAB98
{
	stw r0, 0x674(r3)	# Original operation: Go down one Y column
	lwz r11, 0x670(r3)
	li r12, 6
    cmpwi r24, 0x1
    bne+ notOneRow
    mr r12, r25
notOneRow:
    cmpw r11, r12
	ble+ %END%
	stw r12, 0x670(r3) # Fix X column so that it doesn't try to go too far to the right
}

op nop @ $806aa9a8  # muProcItemSwitch::proc        # Remove or normally used for old sticker/cd/trophy bitfield location

HOOK @ $800500cc    # gmMeleeInitData::gmInitMeleeDataDefault
{
    lis r12, 0x8043
    lis r11, 0x8000
    stw r11, -0x3DB4(r12)   # EXTRA_ITSWITCH.switch3 = 0x80000000
    stw r10, -0x3DB0(r12)   # EXTRA_ITSWITCH.switch4 = 0
    stw r11, -0x3DAC(r12)   # EXTRA_ITSWITCH.pokemonSwitch2 = 0x80000000
    stw r10, -0x3DA8(r12)   # EXTRA_ITSWITCH.assistSwitch2 = 0
    mr r6, r10              # pokemonSwitch and assistSwitch = 0
    %lwi (r12, 0xFFE7FFFF)  # \ Edit default itSwitch 
    stw	r12, 0x28(r31)      # /
}

byte[356] | # Set bitfield order for itSwitch
    0x01, 0x0, | # 0x00 - Assist Trophy
    0x2f, 0x0, | # 0x01 - Franklin Badge
    0x29, 0x0, | # 0x02 - Banana Peel 
    0x39, 0xFF,| # 0x03 - Barrel
    0x13, 0x0, | # 0x04 - Beam Sword
    0xFF, 0x0, | # 0x05 - Bill
    0x1E, 0x0, | # 0x06 - Bob-omb
    0x3A, 0xFF,| # 0x07 - Crate
    0x2A, 0x0, | # 0x08 - Bumper
    0x38, 0xFF,| # 0x09 - Capsule
    0x3B, 0xFF,| # 0x0A - Rolling Crate
    0x3F, 0x3, | # 0x0B - CD
    0x20, 0x0, | # 0x0C - Gooey Bomb
    0x1d, 0x0, | # 0x0D - Cracker Launcher
    0xFF, 0x0, | # 0x0E - Cracker Launcher Shot
    0xFF, 0x0, | # 0x0F - Coin
    0x10, 0x0, | # 0x10 - Superspicy Curry
    0xFF, 0x0, | # 0x11 - Superspicy Curry Shot
    0x22, 0x0, | # 0x12 - Deku Nut
    0x27, 0x0, | # 0x13 - Mr. Saturn
    0x09, 0x0, | # 0x14 - Dragoon Part
    0xFF, 0x0, | # 0x15 - Dragoon Set
    0xFF, 0x0, | # 0x16 - Dragoon Sight
    0x3F, 0x3, | # 0x17 - Trophy
    0x1c, 0x0, | # 0x18 - Fire Flower
    0xFF, 0x0, | # 0x19 - Fire Flower Shot
    0x23, 0x0, | # 0x1A - Freezie
    0x19, 0x0, | # 0x1B - Golden Hammer
    0x28, 0x0, | # 0x1C - Green Shell
    0x18, 0x0, | # 0x1D - Hammer
    0xFF, 0x0, | # 0x1E - Hammer Head
    0x15, 0x0, | # 0x1F - Fan
    0x08, 0x0, | # 0x20 - Heart Container
    0x14, 0x0, | # 0x21 - Homerun Bat
    0x3C, 0xFF,| # 0x22 - Party Ball
    0xFF, 0x0, | # 0x23 - Manaphy Heart
    0x07, 0x0, | # 0x24 - Maxim Tomato
    0x0b, 0x0, | # 0x25 - Poison Mushroom
    0x0A, 0x0, | # 0x26 - Super Mushroom
    0x0e, 0x0, | # 0x27 - Metal Box
    0x26, 0x0, | # 0x28 - Hothead
    0x25, 0x0, | # 0x29 - Pitfall
    0x02, 0x0, | # 0x2A - Pokeball
    0x04, 0x0, | # 0x2B - Blast Box
    0x1b, 0x0, | # 0x2C - Ray Gun
    0xFF, 0x0, | # 0x2D - Ray Gun Shot
    0x16, 0x0, | # 0x2E - Lipstick
    0xFF, 0x0, | # 0x2F - Lipstick Flower
    0xFF, 0x0, | # 0x30 - Lipstick Shot Dust Powder
    0x05, 0x0, | # 0x31 - Sandbag
    0x30, 0x0, | # 0x32 - Screw Attack
    0x3F, 0x3, | # 0x33 - Sticker
    0x1F, 0x0, | # 0x34 - Motion Sensor Bomb
    0x11, 0x0, | # 0x35 - Timer
    0x21, 0x0, | # 0x36 - Smart Bomb
    0x00, 0x0, | # 0x37 - Smash Ball
    0x24, 0x0, | # 0x38 - Smoke Screen
    0x2b, 0x0, | # 0x39 - Spring
    0x17, 0x0, | # 0x3A - Star Rod
    0xFF, 0x0, | # 0x3B - Star Rod Shot
    0x2D, 0x0, | # 0x3C - Soccer Ball
    0x1A, 0x0, | # 0x3D - Super Scope
    0xFF, 0x0, | # 0x3E - Super Scope Shot
    0x0D, 0x0, | # 0x3F - Starman
    0x06, 0x0, | # 0x40 - Food
    0x2e, 0x0, | # 0x41 - Team Healer
    0x12, 0x0, | # 0x42 - Lightning
    0x2c, 0x0, | # 0x43 - Unira
    0x0F, 0x0, | # 0x44 - Bunny Hood
    0x0C, 0x0, | # 0x45 - Warp Star
    0x31, 0x0, | # 0x46 - Subspace Trophy
    0x31, 0x0, | # 0x47 - Subspace Key
    0x31, 0x0, | # 0x48 - Subspace Trophy Stand
    0x31, 0x0, | # 0x49 - Subspace Stock Ball
    0x31, 0x0, | # 0x4A - Green Greens Apple
    0x31, 0x0, | # 0x4B - Mario Bros. Sidestepper
    0x31, 0x0, | # 0x4C - Mario Bros. Shellcreeper
    0x31, 0x0, | # 0x4D - Distant Planet Pellet
    0x31, 0x0, | # 0x4E - Summit Vegetable
    0x05, 0x0, | # 0x4F - HomeRun Sandbag
    0x31, 0x0, | # 0x50 - Enemy Auroros 
    0x31, 0x0, | # 0x51 - Enemy Koopa 1
    0x31, 0x0, | # 0x52 - Enemy Koopa 2
    0xFF, 0x0, | # 0x53 - Snake Carboard Box
    0xFF, 0x0, | # 0x54 - Diddy Kong Peanut
    0x3D, 0xFE, | # 0x55 - Link Bomb (Double Cherry)
    0xFF, 0x0, | # 0x56 - Peach Turnip
    0xFF, 0x0, | # 0x57 - ROB Gyro
    0x06, 0x0, | # 0x58 - Diddy Kong Peanut Seed
    0xFF, 0x0, | # 0x59 - Snake Grenade
    0xFF, 0x0, | # 0x5A - Zero Suit Samus Armor Piece
    0xFF, 0x0, | # 0x5B - Toon Link Bomb
    0xFF, 0x0, | # 0x5C - Wario Bike
    0xFF, 0x0, | # 0x5D - Wario Bike A
    0xFF, 0x0, | # 0x5E - Wario Bike B
    0xFF, 0x0, | # 0x5F - Wario Bike C
    0xFF, 0x0, | # 0x60 - Wario Bike D
    0xFF, 0x0, | # 0x61 - Wario Bike E
    0x00, 0x1, | # 0x62 - Pokemon Torchic
    0x3F, 0x1, | # 0x63 - Pokemon Celebi 
    0x01, 0x1, | # 0x64 - Pokemon Chikorita
    0xFF, 0x1, | # 0x65 - Pokemon Chikorita Shot
    0x02, 0x1, | # 0x66 - Pokemon Entei
    0x03, 0x1, | # 0x67 - Pokemon Moltres
    0x04, 0x1, | # 0x68 - Pokemon Munchlax
    0x05, 0x1, | # 0x69 - Pokemon Deoxys
    0x06, 0x1, | # 0x6A - Pokemon Groudon
    0x07, 0x1, | # 0x6B - Pokemon Gulpin
    0x08, 0x1, | # 0x6C - Pokemon Staryu
    0xFF, 0x1, | # 0x6D - Pokemon Staryu Shot
    0x09, 0x1, | # 0x6E - Pokemon Ho-Oh
    0xFF, 0x1, | # 0x6F - Pokemon Ho-Oh Shot
    0x3F, 0x1, | # 0x70 - Pokemon Jirachi
    0x0A, 0x1, | # 0x71 - Pokemon Snorlax
    0x0B, 0x1, | # 0x72 - Pokemon Bellosom
    0x0C, 0x1, | # 0x73 - Pokemon Kyogre
    0xFF, 0x1, | # 0x74 - Pokemon Kyogre Shot
    0x0D, 0x1, | # 0x75 - Pokemon Latias Latios
    0x0E, 0x1, | # 0x76 - Pokemon Lugia
    0xFF, 0x1, | # 0x77 - Pokemon Lugia Shot
    0x0F, 0x1, | # 0x78 - Pokemon Manaphy
    0x10, 0x1, | # 0x79 - Pokemon Weavile
    0x11, 0x1, | # 0x7A - Pokemon Electrode
    0x12, 0x1, | # 0x7B - Pokemon Metagross
    0x3F, 0x1, | # 0x7C - Pokemon Mew
    0x13, 0x1, | # 0x7D - Pokemon Meowth
    0xFF, 0x1, | # 0x7E - Pokemon Meowth Shot
    0x14, 0x1, | # 0x7F - Pokemon Piplup
    0x15, 0x1, | # 0x80 - Pokemon Togepi
    0x16, 0x1, | # 0x81 - Pokemon Goldeen
    0x17, 0x1, | # 0x82 - Pokemon Gardevoir
    0x18, 0x1, | # 0x83 - Pokemon Wobuffet
    0x19, 0x1, | # 0x84 - Pokemon Suicune
    0x1A, 0x1, | # 0x85 - Pokemon Bonsly
    0x00, 0x2, | # 0x86 - Assist Andross
    0xFF, 0x2, | # 0x87 - Assist Andross Shot
    0x01, 0x2, | # 0x88 - Assist Barbara
    0x02, 0x2, | # 0x89 - Assist Gray Fox
    0x03, 0x2, | # 0x8A - Assist Ray MKII
    0xFF, 0x2, | # 0x8B - Assist Ray MKII Bomb
    0xFF, 0x2, | # 0x8C - Assist Ray MKII Gun Shot
    0x04, 0x2, | # 0x8D - Assist Samurai Goroh
    0x05, 0x2, | # 0x8E - Assist Devil
    0x06, 0x2, | # 0x8F - Assist Excitebike
    0x07, 0x2, | # 0x90 - Assist Jeff
    0xFF, 0x2, | # 0x91 - Assist Jeff Pencil Bullet
    0xFF, 0x2, | # 0x92 - Assist Jeff Pencil Rocket
    0x08, 0x2, | # 0x93 - Assist Lakitu
    0x09, 0x2, | # 0x94 - Assist Knuckle Joe
    0xFF, 0x2, | # 0x95 - Assist Knuckle Joe Shot
    0x0A, 0x2, | # 0x96 - Assist Hammer Bro
    0xFF, 0x2, | # 0x97 - Assist Hammer Bro Hammer
    0x0B, 0x2, | # 0x98 - Assist Helirin
    0x0C, 0x2, | # 0x99 - Assist KatAna
    0xFF, 0x2, | # 0x9A - Assist KatAna Ana
    0x0D, 0x2, | # 0x9B - Assist Jill Dozer
    0x0E, 0x2, | # 0x9C - Assist Lyn
    0x0F, 0x2, | # 0x9D - Assist Little Mac
    0x10, 0x2, | # 0x9E - Assist Metroid
    0x11, 0x2, | # 0x9F - Assist Nintendog
    0xFF, 0x2, | # 0xA0 - Assist Nintendo Full
    0x12, 0x2, | # 0xA1 - Assist Mr. Resetti
    0x13, 0x2, | # 0xA2 - Assist Isaac
    0xFF, 0x2, | # 0xA3 - Assist Isaac Shot
    0x14, 0x2, | # 0xA4 - Assist Saki
    0xFF, 0x2, | # 0xA5 - Assist Saki Shot 1
    0xFF, 0x2, | # 0xA6 - Assist Saki Shot 2
    0x15, 0x2, | # 0xA7 - Assist Shadow
    0xFF, 0x2, | # 0xA8 - Assist War Infantry
    0xFF, 0x2, | # 0xA9 - Assist War Infantry Shot
    0x16, 0x2, | # 0xAA - Assist Starfy
    0x17, 0x2, | # 0xAB - Assist War Tank
    0xFF, 0x2, | # 0xAC = Assist War Tank Shot
    0x18, 0x2, | # 0xAD - Assist Tingle
    0xFF, 0x2, | # 0xAE - Assist Lakitu Spiny
    0x19, 0x2, | # 0xAF - Assist Waluigi
    0x1A, 0x2, | # 0xB0 - Assist Dr. Wright
    0xFF, 0x2  | # 0xB1 - Assist Dr. Wright Building
@ $8042C0D0
CODE @ $80050bc0    # gmItSwitch::gmCheckItemSwitch
{
    li r9, 0x1              
    mulli r12, r4, 0x2  # \
    subi r5, r5, 16176  # |
    add r5, r5, r12     # | 
    lbz r6, 0x0(r5)     # | Replace switch statement with ITSWITCH_CHECK_INDICES array 
    extsb r6, r6        # |
    lbz r0, 0x1(r5)     # /
    cmpwi r0, 0xFF      # \ Check if container
    beq- isContainer    # /
    cmpwi r0, 0xFE      # \ Check if Ex
    beq- isEx           # /
    cmpwi r0, 0x2       # \ Check if assist
    bne+ 0x700          # /
isAssist:
    cmpwi r4, 0x96      # \
    beq- 0x6F8          # | check if Hammer Bro
    cmpwi r4, 0x97      # |
    beq- 0x6F0          # /
    lwz r12, 0x4(r3)            # \
    slwi r10, r9, 1             # |
    and r11, r12, r10           # | 
    neg r10, r11                # | Check if assist is on
    or r10, r10, r11            # |
    rlwinm. r12, r10, 1, 31, 31 # |
    bne+ 0x6D4                  # /
    lwz r12, 0x4(r3)            # \
    slwi r10, r9, 3             # | 
    and r11, r12, r10           # | Check if container is off
    neg r10, r11                # | 
    or r10, r10, r11            # |
    rlwinm. r12, r10, 1, 31, 31 # |
    beq- 0x6B8                  # /
    lwz r12, 0x0(r3)            # \
    slwi r10, r9, 22            # | 
    and r11, r12, r10           # | Check if enemies are off
    neg r10, r11                # | 
    or r10, r10, r11            # |
    rlwinm. r12, r10, 1, 31, 31 # |
    beq- 0x69C                  # /
    b returnFalse
isEx:
    lbz r12, 0x1(r3)            # \
    slwi r10, r9, 2             # |
    b checkIfOn
isContainer:                    # |
    lwz r12, 0x4(r3)            # |
    slwi r10, r9, 3             # | 
checkIfOn:
    and r11, r12, r10           # | Check if container/ex is on
    neg r10, r11                # | 
    or r10, r10, r11            # |
    rlwinm. r12, r10, 1, 31, 31 # |
    li r0, 0x0
    bne+ 0x66C                  # /
returnFalse:
    li r3, 0
    blr          
} 
HOOK @ $80051340    # gmItSwitch::gmCheckItemSwitch
{
    lwz	r4, 0x8(r3)     # Original operation (get from itSwitch->pokemonSwitch)
    cmpwi r6, 0x20                      # \
    blt+ %end%                          # | If > 0x20 take from EXTRA_ITSWITCH.pokemonSwitch2
    %lwd (r4, EXTRA_ITSWITCH_POKEMON)   # |
    subi r6, r6, 0x20                   # /
}
HOOK @ $80051348    # gmItSwitch::gmCheckItemSwitch
{
    lwz	r4, 0xC(r3)     # Original operation (get from itSwitch->assistSwitch)
    cmpwi r6, 0x20                      # \
    blt+ %end%                          # | If > 0x20 take from EXTRA_ITSWITCH.assistSwitch2
    %lwd (r4, EXTRA_ITSWITCH_ASSIST)    # |
    subi r6, r6, 0x20                   # /
}
HOOK @ $8005134c    # gmItSwitch::gmCheckItemSwitch
{
    cmpwi r0, 3                 # \ Check if extra item switch
    bne+ end                    # /
    %lwi (r12, EXTRA_ITSWITCH)  # \
    lwz r4, 0x4(r12)            # |
    cmpwi r6, 0x20              # | If > 0x20 take from EXTRA_ITSWITCH.switch3 instead of switch4
    blt+ end                    # |
    lwz r4, 0x0(r12)            # |
    subi r6, r6, 0x20           # /
end:
    li r0, 1    # Original operation
}

op li r5, 2 @ $806a445c # muRuleTask::__ct
HOOK @ $806a4480    # muRuleTask::__ct
{
    mr r18, r3  # Original operation
    stw r21, 0x68C(r18) # Store gfArchive in muProcItemTask
}
HOOK @ $806aa4cc    # muProcItemSwitch::__ct
{
    li r30, 0   # Original operation
    stb r30, 0x679(r29) # Initialize page index
    stb r30, 0x67A(r29) # Initialize last page index
}
HOOK @ $806aadf0    # muProcItemSwitch::selectProc
{   
    mr r30, r4
    lbz r12, 0x67A(r27)
    %lwi (r8, NUM_SUB_ITSWITCHES)
    %lwd (r11, g_gfPadStatus)       # \
    li r7, 0x0                      # |
checkForRandomInput:                # |
    lhz r0, 0x46(r11)               # | 
    andi. r0, r0, 0x0020            # | 
    bne- randomSelect               # | Check for R input in each gfPadStatus
    addi r11, r11, 0x40             # |
    addi r7, r7, 0x1                # |
    cmpwi r7, 0x8                   # |
    ble+ checkForRandomInput        # /
    b notRandom 
randomSelect:
    lbzx r3, r8, r12        # \
    %call (randi)           # | get new cursor index 
    addi r29, r3, 0x2       # /
    li r4, 0x0              # play cursor sfx
    b setNewCursorPos
notRandom:    
    %lwd (r7, g_GameGlobal)     # \ g_GameGlobal->Record
    lwz r7, 0x24(r7)            # /
    li r11, 0x0
    cmpwi r12, 0x0
    bne+ notPage1    
    andi. r0, r4, 0x100 # \ Check for start input
    beq+ notPageTurn    # /
    mr r11, r29
    b changePage
notPage1:               
    andi. r0, r4, 0x20  # \ check for B input
    beq+ notPageTurn    # /
    li r29, 0x2
changePage:
    cmpw r11, r12       # \ check if index changed
    beq+ notPageTurn    # /
    lbzx r26, r8, r11   # \
    cmpwi r26, 0x0      # | check if has submenu
    beq+ notPageTurn    # /
    lwz r8, 0x680(r27)  
    lwz r9, 0x684(r27)
    lis r10, 0x8043
    cmpwi r12, 3
    beq- isAssistSwitch
    cmpwi r12, 4
    beq- isPokemonSwitch
    cmpwi r12, 5
    beq- isContainerSwitch
    cmpwi r12, 52
    beq- isExSwitch
    stw r9, 0x81c(r7)      # \ Store item switch     
    stw r8, 0x818(r7)      # /     
    b savedItSwitch
isAssistSwitch:
    stw r8, -0x3DBC(r10)    # \ 
    rlwinm r9,r9,31,0,31    # | Store in EXTRA_ITSWITCH_SAVE.assistSwitch
    stw r9, -0x3DB8(r10)    # /
    b savedItSwitch
isPokemonSwitch:  
    stw r8, -0x3DC4(r10)    # \ 
    rlwinm r9,r9,31,0,31    # | Store in EXTRA_ITSWITCH_SAVE.pokemonSwitch
    stw r9, -0x3DC0(r10)    # /
    b savedItSwitch
isContainerSwitch:
    lwz r8, 0x818(r7)       # \
    rlwimi r8,r9,21,3,10    # | Store in itemSwitch.containerSwitch
    stw r8, 0x818(r7)       # /
    b savedItSwitch
isExSwitch:
    lwz r8, 0x818(r7) 
    rlwimi r8,r9,29,0,2 #31-29
    stw r8, 0x818(r7) 
savedItSwitch:
    stb r11, 0x679(r27)
    lbz r12, 0x678(r27) # \ Store item frequency
    stb r12, 0x810(r7)  # /

    lwz r3, 0x68C(r27)              # \
    lis r4, 0x0001                  # |
    subi r0, r4, 2                  # |
    li r4, 1                        # | fileArchive->getData(1, pageIndex + 2, 0xfffe)
    addi r5, r11, 0x2               # |
    rlwinm r6, r0, 0, 16, 31        # |
    %call (gfFileArchive__getData)  # /
    mr r4, r3                   # \
    lwz r3, 0x66c(r27)          # | MuMsg->setMsgData(msgData);
    %call (MuMsg__setMsgData)   # /
    mr r3, r27
    lwz r4, 0x654(r27)
    %call (muProcItemSwitch__init)

    lbz r29, 0x67A(r27)         # reset page 
    li r30, 0                   # set pad to zero to not register other presses
    li r4, 0x23                 # play page turn sfx
setNewCursorPos:
    %lwd (r3, g_sndSystem)      # \
    li r5, -0x1                 # |
    li r6, 0x0                  # | g_sndSystem->playSE(sndID, -0x1, 0x0, 0x0, -0x1);
    li r7, 0x0                  # |
    li r8, -0x1                 # |
    %call (sndSystem__playSE)   # /
    li r9, 0x7          # \
    divw r10, r29, r9   # |
    mulli r9, r10, 0x7  # | this->currentRow = lastPageIndex / 7 + 1
    subf r9, r9, r29    # | this->currentCol = lastPageIndex % 7
    addi r7, r10, 0x1   # |
    stw r9, 0x670(r27)  # |
    stw r7, 0x674(r27)  # /
    mr r4, r30 
    mr r3, r27
    li r28, 2   # Update cursor
notPageTurn:
    rlwinm.	r0, r4, 0, 22, 22   # Original operation
}
HOOK @ $806ab0c8    # muProcItemSwitch::selectProc
{
    cmpwi r28, 0x1  # \ check if set as 0x2, force setCursor(true) if it is so that cursor updates
    bne+ %end%      # /
    cmplw r29, r0   # Original operation
}

HOOK @ $806aa718    # muProcItemSwitch::init
{
    addi r11, r26, 1     # Original operation
    lbz r12, 0x679(r30)  # \
    mulli r12, r12, 55   # | Add pageIndex*55  
    add r0, r11, r12     # /
}
HOOK @ $806ab468    # muProcItemSwitch::setCursor
{
    lbz r12, 0x679(r31) # \
    mulli r12, r12, 55  # | Add pageIndex*55  
    add r29, r29, r12   # /
    stw	r29, 0x14(r1)   # Original operation
}

op nop @ $806aa968  # Disable start press to backout
HOOK @ $806aa96c    # muProcItemSwitch::proc
{
    lbz r12, 0x679(r31)     # \
    lbz r11, 0x67A(r31)     # | 
    stb r12, 0x67A(r31)     # | Check if page changed
    cmpw r11, r12           # |
    beq+ isNotPageChanged   # /
    li r3, 0
isNotPageChanged:    
    and. r0, r29, r3    # Original operation
}

HOOK @ $806aa648    # muProcItemSwitch::init
{
    lwz	r5, 0xC(r3) # Original operation
    lis r11, 0x8043
    lbz r12, 0x679(r30)
    cmpwi r12, 3
    beq- isAssistSwitch
    cmpwi r12, 5
    beq- isContainerSwitch
    cmpwi r12, 52
    beq- isExSwitch
    cmpwi r12, 4
    bne+ %end% 
isPokemonSwitch:
    lwz r4, -0x3DC4(r11)    # \ 
    lwz r5, -0x3DC0(r11)    # | Get from EXTRA_ITSWITCH_SAVE.pokemonSwitch
    rlwinm r5,r5,1,0,31     # /
    b %end%
isAssistSwitch:
    lwz r4, -0x3DBC(r11)    # \ 
    lwz r5, -0x3DB8(r11)    # | Get from EXTRA_ITSWITCH_SAVE.assistSwitch
    rlwinm r5,r5,1,0,31     # / 
    b %end%
isContainerSwitch:          
    srawi r5,r4,21          # Get from itemSwitch->containerSwitch
    b %end%
isExSwitch:
    srawi r5,r4,29          # Get from itemSwitch->exSwitch

}
    
.macro applyExtraItemSwitch(<reg>)
{
    lis r12, 0x8043
    lwz r0, -0x3DC0(r12)    # \ globalRecord->gmItSwitch.pokemonSwitch = EXTRA_ITSWITCH_SAVE.pokemonSwitch1
    stw r0, 0x38(<reg>)     # /
    #lwz r0, -0x3DC4(r12)    # \ EXTRA_ITSWITCH.pokemonSwitch2 = EXTRA_ITSWITCH_SAVE.pokemonSwitch2
    #stw r0, -0x3DAC(r12)    # /
    #lwz r0, -0x3DBC(r12)    # \ EXTRA_ITSWITCH.assistSwitch2 = EXTRA_ITSWITCH_SAVE.assistSwitch2
    #stw r0, -0x3DA8(r12)    # /
    lwz r0, -0x3DB8(r12)    # globalRecord->gmItSwitch.assistSwitch = ASSIST_EXTRA_ITSWITCH_SAVE_ADDR.itemSwitch1
}

HOOK @ $806dcf38    # sqVsMelee::setupMelee
{
    %applyExtraItemSwitch(r31)
}
HOOK @ $806de870    # sqToMelee::setupMelee
{
    %applyExtraItemSwitch(r30)
}
HOOK @ $806dfe6c    # sqQuMelee::setupMelee
{
    %applyExtraItemSwitch(r30)
}
HOOK @ $806f1a6c    # sqTraining::setupTraining
{
    %applyExtraItemSwitch(r29)
}
HOOK @ $806def54    # sqSpMelee::setupSpMelee
{
    %applyExtraItemSwitch(r27)
}

word[12] 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, | # Stage Item switch
        0xFFE7FFFF, 0xFFFFFFFF, 0x7FFF7FFF, 0x7FFFFFDF, | # Classic Item switch
        0xFFE7BFFF, 0xfffffe17, 0x7FFF7FFF, 0x7Ff9f7df, | # All Star Item Switch
@ $8042c4b8
word[8] 0xFFE7FFFF, 0xFFFFFFFF, 0x7FFF7FFF, 0x7FFFFFDF, | # Target Smash
        0xFFE7BFFF, 0xfcebf016, 0x7FFF7FFF, 0x7ef9f7df, | # Multi Man Item Switch
@ $8042d088

op b 0x1c @ $800559ac  # Always use gmGetItemSwitchData_NormalStage[0] in gmGetItemSwitchData_NormalStage
CODE @ $806ee9bc    # sqEvent::setupEvent
{
    lwz r0, 0x28(r18)   # \
    stw r0, 0x30(r27)   # |
    lwz r0, 0x2c(r18)   # |
    stw r0, 0x34(r27)   # | Obtain item switch data from unused part of event node
    lwz r0, 0x30(r18)   # |
    stw r0, 0x38(r27)   # |
    lwz r0, 0x34(r18)   # |
    stw r0, 0x3c(r27)   # /
} 
HOOK @ $806efe08    # sqTargetBreak::setupTargetBreak
{
    %lwi(r12, 0x8042d088)   # \
    lwz r11, 0x0(r12)       # |
    stw r11, 0x30(r29)      # |
    lwz r11, 0x4(r12)       # |
    stw r11, 0x34(r29)      # | Use gmItSwitchData_Challenger[13] for target smash
    lwz r11, 0x8(r12)       # |
    stw r11, 0x38(r29)      # |
    lwz r11, 0xC(r12)       # |
    stw r11, 0x3C(r29)      # /
}
op subi	r4, r4, 0x3b48 @ $80055c5c   # \ Use gmGetItemSwitchData_NormalStage[1] for gmGetItemSwitchData_Simple
op li r0, 0x1 @ $80055ccc            # /
CODE @ $80055de4
{
    li r0, 0x20          # \ Use gmGetItemSwitchData_NormalStage[2] for gmGetItemSwitchData_AllStar
    subi r4, r4, 0x3b48  # /
}
CODE @ $80056074
{
    li r0, 0x10          # \ Use gmGetItemSwitchData_NormalStage[1] for gmGetItemSwitchData_Challenger
    subi r4, r4, 0x3b48  # /
}
op andis. r5,r0,0xffe7 @ $806f1a50 # Set mayhem and passive aggression to false in Training
op andis. r5,r4,0xffe1 @ $806dddc8 # Set mayhem and passive aggression to false in demo

######################
# Training Mode Menu #
######################
## TODO: Pokemon and Assist, preload ahead of time when on cursor, use R/L to cycle between lists?

CODE @ $80104af4    # IfMinigameTraining::createModel
{
    stw r30, 0xEC(r27)  # Store pointer to table of items
    li r12, 4           # \
    divw r12, r31, r12  # | store number of items
    stw r12, 0x2EC(r27) # /
    b 0x4C
}

op b 0x2C @ $80105110   # IfMinigameTraining::startMelee   
CODE @ $801059fc    # IfMinigameTraining::curPosProcItem
{
    mr r5, r31
    b 0x28
}
CODE @ $80105a44    # IfMinigameTraining::curPosProcItem
{
    lwz r12, 0xEC(r29)  # \
    mulli r11, r3, 0x4  # | get this->items[index]
    lwzx r3, r12, r11   # /
    b 0x20
}

op lhz r4, 0x132(r20) @ $80962248   # stOperatorInfoTraining::processBegin
CODE @ $809622d8    # stOperatorInfoTraining::processBegin
{
    lhz	r21, 0x132(r20) # get itKind
    lhz r22, 0x130(r20) # get itVariation
    b 0x38
}


## TODO: Infinite health and infinite bullets toggle part of more options
# HOOK @ $80999fd8  # Infinite bullets
# {
#     li r4, 0xff         # \
#     lis r5, 0x1000      # |
#     lwz r3, 0x60(r30)   # |
#     lwz r3, 0xd8(r3)    # |
#     lwz r3, 0x64(r3)    # | 
#     lwz r12, 0x0(r3)    # |
#     lwz r12, 0x1c(r12)  # |
#     mtctr r12           # |
#     bctrl               # /

#     lwz	r3, 0x8D0(r30)  # Original operation
# }
# HOOK @ $809bdf60    # Invincible
# {
#     fcmpo cr0,f1,f0   # Original operation
#     fcmpo cr0,f1,f1
# }
## TODO: Null check of ItmParam so use global instead (in the future params will be in the item psa file, tho having a common ItmParam shared among fighter items could be useful for common scripts)
## TODO: Disable coin if not in coin mode from item switch? then can have it in crate drop 
## TODO: Have clone/customizer item id in ItmParam instead of it being determined based on variant id? Accessible with itValueAccesser::getConstantIntCore. Could also use for common item brres and param id. Slowly could turn every hardcoded id check into flags from param (including stuff like itCustomizer getKineticFlags)
## TODO: Have an ItmParam be random drop chance from hit?
## TODO: Limit rolling crates to 10 otherwise it crashes with collision
## TODO: Handle extra options for replays
## TODO: For completion sake patch any functions that call gmGetItemSwitchData including net relatedfunctions

## TODO: Masterball selection in Pokemon switch

.include Source/Community/DoubleCherry.asm

#######################################################################################
Dragoon Parts Drops like a Normal Item With Multiplier If Parts Have Dropped [Kapedani] 
#######################################################################################
op li r4, 1 @ $809ae498 # Always have Dragoon on
op b 0xac @ $809b4ac0   # Skip checking if Dragoon is available and just have it be a regular item pull

HOOK @ $809b60c8    # itManager::getLotValue
{
    cmpwi r4, 0x14  # \ check if Dragoon
    bne+ end        # /
    lwz r12, 0x1494(r3)     # \
    rlwinm r11,r12,30,31,31 # |
    rlwinm r10,r12,31,31,31 # | ((flags & 2) >> 1) + ((flags & 4) >> 2) + ((flags & 8) >> 3)
    add r11,r11,r10         # |
    rlwinm r10,r12,29,31,31 # |
    add r12,r11,r10         # /
    lbz r11, 0x101D(r3)         # this->itemNums[0x14]
    cmpw r11, r12
    ble+ notLessThanItemNum
    mr r12, r11
notLessThanItemNum:
    cmpwi r12, 0x3      # \ check if all Dragoons out
    blt- notMaxDragoons # /
    fsubs f2, f2, f2    # set to 0
notMaxDragoons:
    addi r10, r3, 0x74  # \
    mulli r11, r12, 0x4 # | get multiplier based on number of dragoons out
    lfsx f1, r10, r11   # |
    fmuls f2, f1, f2    # /
end: 
    fmr	f1, f2  # Original operation
}

#############################################
Team Healer Always Heals Teammates [Kapedani]
#############################################
.alias g_ftManager                          = 0x80B87C28
.alias ftManager__getFighter                = 0x80814f20
.alias ftManager__getTeam                   = 0x80814a40
.alias ftManager__getEntryIdFromTaskId      = 0x80815cb0

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

HOOK @ $80844690    # Fighter::touchItem
{   
    li r24, -1
    li r5, 0                                # \
    mr r4, r3                               # |
    %lwd (r3, g_ftManager)                  # |
    %call (ftManager__getEntryIdFromTaskId) # | Get entryId from item's team owner task id
    cmpwi r3, 0                             # |
    blt+ notFighter                         # /
    mr r4, r3                   # \
    %lwd (r3, g_ftManager)      # |
    li r5, 0                    # | ftManager->getTeam(entryId, false, false)
    li r6, 0                    # |
    %call (ftManager__getTeam)  # /
    mr r24, r3
notFighter:
    %lwd (r3, g_ftManager)      # \
    lwz r4, 0x10c(r25)          # |
    li r5, 0                    # | ftManager->getTeam(fighter->entryId, false, false)
    li r6, 0                    # |
    %call (ftManager__getTeam)  # /
}
op b 0x30 @ $80844694

####################################################
Touch Items Notify Outside Event Get Item [Kapedani]
####################################################
.alias ftOutsideEventPresenter__notifyOutsideEventGetItem     = 0x80864e54

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

op b 0x2C @ $80844644   # Skip since being called below anyways
HOOK @ $80844d6c    # Fighter::touchItem
{
    addi r3,r25,0x13c   # this->outsideEventPresenter
    lwz r4, 0x8c0(r29)  # item->kind
    lwz r5, 0x8c4(r29)  # item->varation
    lwz r6, 0x3d28(r29) # item->genParamId
    lwz r7, 0x8bc(r29)  # item->instanceId
    %call (ftOutsideEventPresenter__notifyOutsideEventGetItem)
    lwz	r12, 0x3C(r25)  # Original operation
}


###########################################
Every Item Can Have Collision v2 [Kapedani]
###########################################
op nop @ $8098f6b8  # Always construct collision if it exists regardless of itKind
HOOK @ $8098f6d0    # BaseItem::reset
{
    li r24, 0x1
    cmpwi r5, 152   # \ Check if Helirin
    bne+ %end%      # / 
    li r24, 0x0
}     

######################################
Every Item Can Have Physics [Kapedani]
######################################
op li r3, 0x1 @ $8098d8b8

######################################################################################
Item Mayhem Mode (Item Switch Edition) + Butterfingers [MarioDox, DukeItOut, Kapedani]
######################################################################################
.alias g_GameGlobal                         = 0x805a00E0
.alias g_itValueAccesser                    = 0x80b8bf88

.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
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

HOOK @ $8098f870
{
    bctrl   # Original operation
    %lwi (r3, g_itValueAccesser)    # \
    addi r4, r26, 204               # |
    li r5, 23402                    # |
    li r6, 0                        # |
    lwz	r12, 0x4(r3)                # | g_itValueAccesser.getConstantIntCore(this->soModuleAccesser, 0x5B6A, 0)
    lwz	r12, 0x20(r12)              # |
    mtctr r12                       # |
    bctrl                           # /
    mr r31, r3
    %lwi (r3, g_itValueAccesser)    # \
    addi r4, r26, 204               # |
    li r5, 23403                    # |
    li r6, 0                        # | g_itValueAccesser.getConstantIntCore(this->soModuleAccesser, 0x5B6B, 0)
    lwz	r12, 0x4(r3)                # | 
    lwz	r12, 0x20(r12)              # |
    mtctr r12                       # |
    bctrl                           # /
    %lwd (r11, g_GameGlobal)    # \
    lwz r11, 0x8(r11)           # |
    lbz r11, 0x31(r11)          # | Check if Item Mayhem mode is on
    andi. r11, r11, 0x8         # |
    beq+ %end%                    # /
    lwz r12, 0x8c8(r26) # \
    cmpwi r12, -1       # | check if emitterTaskId is -1
    bne+ %end%          # /
    andis. r0, r3, 0x10 # \ check if hammer
    bne- %end%          # /
    cmpwi r31, 0x0  # \
    beq+ %end%      # |
    cmpwi r31, 0x1  # | check pickup type
    beq+ %end%      # |
    cmpwi r31, 0x4  # |
    bne- drop       # /
    andi. r0, r3, 0x8   # \ check if throwable
    beq+ %end%          # /
drop:
    addi r3, r26, 11316     # \
    li r4, 5                # |
    addi r5, r26, 204       # |
    lwz	r12, 0x2C34(r26)    # | this->statusModule.changeStatusForce(5, &this->moduleAccesser)
    lwz r12, 0x90(r12)      # |
    mtctr r12               # |
    bctrl                   # /
}

HOOK @ $80841160    # Fighter::dropItemCheck
{
    cmpwi r22, 2    # \ check if third parameter is 2 (i.e. dead)
    beq+ dropItem   # /
    %lwd (r11, g_GameGlobal)    # \
    lwz r11, 0x8(r11)           # |
    lbz r11, 0x31(r11)          # | Check if Item Mayhem mode is on
    andi. r11, r11, 0x8         # |
    beq+ end                    # /
dropItem:
    li r3, 0x0  # guarantee drop item
end:
    xoris r3, r3, 0x8000    # Original operation
}
HOOK @ $80841438    # Fighter::dropItemCheck
{
    %lwd (r11, g_GameGlobal)    # \
    lwz r11, 0x8(r11)           # |
    lbz r11, 0x31(r11)          # | Check if Item Mayhem mode is on
    andi. r11, r11, 0x8         # |
    beq+ end                    # /
    li r3, 0x0  # guarantee drop dragoon part
end:
    cmpw r3, r23    # Original operation
}
HOOK @ $8084161c    # Fighter::dropItemCheck
{
     %lwd (r11, g_GameGlobal)    # \
    lwz r11, 0x8(r11)           # |
    lbz r11, 0x31(r11)          # | Check if Item Mayhem mode is on
    andi. r11, r11, 0x8         # |
    beq+ end                    # /
    li r3, 0x0  # guarantee drop final smash
end:
    cmpw r3, r26    # Original operation
}

##################################
Passive Aggressive Mode [Kapedani]
##################################
.alias BaseItem__getCreaterItem             = 0x8099302c
.alias g_ftEntryManager                     = 0x80B87c48
.alias ftEntryManager__getEntryIdFromTaskId = 0x80823f90
.alias g_ftManager                          = 0x80B87C28
.alias ftManager__getFighter                = 0x80814f20
.alias gfTaskScheduler__getTaskById         = 0x8002f018

.alias g_GameGlobal                         = 0x805a00E0

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

.macro checkDisableFighterCollisionRoutine()
{
	stwu, r1, -0x10(r1)
	mflr r0
	stw r0, 0x14(r1)
	stw r31, 0x8(r1)
	mr r31, r3
	
    %lwd (r11, g_GameGlobal)    # \
    lwz r11, 0x8(r11)           # |
    lbz r11, 0x31(r11)          # | Check if Passive Agressive mode is on
    andi. r11, r11, 0x10        # |
    beq+ hitFighters            # /
### Passive Aggressive Mode ###	
    lwz r31, 0x28(r31)  	# \
    lwz r3, 0x8(r31)     	# |
    lwz r12, 0x3c(r3)       # | attackModule->moduleAccesser->stageObject->soGetKind()
    lwz r12, 0xA4(r12)      # |
    mtctr r12               # |
    bctrl                   # /
    cmpwi r3, 0x2       # \ Check if soKind is a weapon
    bne+ notWeapon      # /
### Checking Article Info ###	
    lwz r3, 0x8(r31)  	# \
    lwz r12, 0x3c(r3)   # | 
    lwz r12, 0x1e8(r12) # | moduleAccesser->weapon->getFounderTaskId()
    mtctr r12           # |
    bctrl               # /
    mr r5, r3                               # \
    lwz	r3, -0x43B8(r13)                    # |
    li r4, 0xc                              # | check if task exists
    %call(gfTaskScheduler__getTaskById)     # |
    cmpwi r3, 0                             # |
    beq- founderNotFound                    # /
    lwz r4, 0x28(r3)    # task->taskId
    b checkEmitter
founderNotFound:   
    lwz r3, 0xd8(r31) 	# \
    lwz r3, 0x18(r3)    # |
    lwz r12, 0x0(r3)   	# | moduleAccesser->moduleEnumeration->teamModule->getTeamOwnerId()
    lwz r12, 0x28(r12)  # |
    mtctr r12           # |
    bctrl               # /
    mr r4, r3
    b checkEmitter
notWeapon:
    cmpwi r3, 0x4       # \ Check if soKind is a item
    bne+ notItem        # /
### Checking Item Info ###
    lwz r3, 0x8(r31)  # moduleAccesser->stageObject
isItem:
    mr r31, r3
    %call (BaseItem__getCreaterItem)
    cmpwi r3, 0x0 
    bne+ isItem
    lwz r12, 0x8c0(r31)   # baseItem->itKind
    cmpwi r12, 0x15 	# \ check if Dragoon set
    beq- hitFighters	# /
    lwz r4, 0x8C8(r31) # baseItem->emitterTaskId
checkEmitter:
    %lwd (r3, g_ftEntryManager)                     # \
    li r5, 0                                        # |
    %call (ftEntryManager__getEntryIdFromTaskId)    # | Check if emitterTaskId belongs to a fighter
    cmpwi r3, 0                                     # |
    blt+ hitFighters                                # /
    mr r4, r3                       # \
    %lwd (r3, g_ftManager)          # |
    li r5, -1                       # | moduleAccesser = g_ftManager->getFighter(entryId, -1)
    %call (ftManager__getFighter)   # |
    lwz r31, 0x60(r3)             # /
    b checkBoss
notItem:
    cmpwi r3, 0x0       # \ Check if soKind is a fighter
    bne+ hitFighters    # / 
### Checking Fighter Info ###
    lwz r3, 0xD8(r31) # \
    lwz r3, 0x70(r3)    # |
    lwz r12, 0x0(r3)    # | moduleAccesser->moduleEnumeration->statusModule->getStatusKind()
    lwz r12, 0x48(r12)  # |
    mtctr r12           # |
    bctrl               # /
    cmpwi r3, 158           # \
    blt+ checkBoss          # | Check if status is affiliated with item melee attacks
    cmpwi r3, 163           # |
    ble+ hitFighters        # /
checkBoss:
    lwz r10, 0x8(r31)
    lwz r11, 0x10c(r10) # fighter->entryId
    %lwd (r12, g_ftEntryManager)    # \
    rlwinm r11, r11, 0, 24, 31      # |
    lwz r12, 0x0(r12)               # | ftEntryManager->ftEntries + (entryId & 0xff) (same functionality as ftEntryManager::getEntity)
    mulli r11, r11, 580             # |
    add r12, r12, r11               # /
    lwz r11, 0x58(r12)   # ftEntry->playerNo 
    %lwd (r12, g_GameGlobal)    # \
    lwz r12, 0x8(r12)           # | g_GameGlobal->modeMelee->playerInitData[playerNo]
    mulli r11, r11, 92          # |
    add r12, r12, r11           # /
JapaneseCheck:		# Look for "ボス"
	lis r5, 0x30DC		# \ r5 = "ボス"
	ori r5, r5, 0x30B9	# /
	lwz r4, 0xA4(r12);	cmpw r4, r5;	beq- hitFighters
	lwz r4, 0xA6(r12);	cmpw r4, r5;	beq- hitFighters
	lwz r4, 0xA8(r12);	cmpw r4, r5;	beq- hitFighters
	lwz r4, 0xAA(r12);	cmpw r4, r5;	beq- hitFighters
BOSScheck:
	lis r5, 0xFF22		# \ r5 = "BO"
	ori r5, r5, 0xFF2F	# /
	lis r6,	0xFF33		# \ r6 = "SS"
	ori r6, r6, 0xFF33 	# /
B_0a:
	lwz r4, 0xA4(r12); cmpw r4, r5; bne+ B_1a
	lwz r4, 0xA8(r12); cmpw r4, r6; beq- hitFighters
B_1a:
	lwz r4, 0xA6(r12); cmpw r4, r5; bne boss_Check
	lwz r4, 0xAA(r12); cmpw r4, r6; beq- hitFighters
boss_Check:		
	lis r5, 0xFF42		# \ r5 = "bo"
	ori r5, r5, 0xFF4F	# /
	lis r6,	0xFF53		# \ r6 = "ss"
	ori r6, r6, 0xFF53 	# /
B_0b:
	lwz r4, 0xA4(r12); cmpw r4, r5; bne+ B_1b
	lwz r4, 0xA8(r12); cmpw r4, r6; beq- hitFighters
B_1b:
	lwz r4, 0xA6(r12); cmpw r4, r5; bne notBoss
	lwz r4, 0xAA(r12); cmpw r4, r6; beq- hitFighters
boss_Check2:	
	lis r5, 0xFF22		# \ r5 = "Bo"
	ori r5, r5, 0xFF4F	# /
	lis r6,	0xFF53		# \ r6 = "ss"
	ori r6, r6, 0xFF53 	# /
B_0c:
	lwz r4, 0xA4(r12); cmpw r4, r5; bne+ B_1c
	lwz r4, 0xA8(r12); cmpw r4, r6; beq- hitFighters
B_1c:
	lwz r4, 0xA6(r12); cmpw r4, r5; bne notBoss
	lwz r4, 0xAA(r12); cmpw r4, r6; beq- hitFighters	
notBoss:

    lwz r3, 0x8(r31)  	# \
    lwz r12, 0x3c(r3)   # | 
    lwz r12, 0xA8(r12)  # | moduleAccesser->stageObject->soGetSubKind()
    mtctr r12           # |
    bctrl               # /
    cmpwi r3, 0x30          # \
    beq- gKoopa             # | Check ftKind for special case transformation Final Smashes 
    cmpwi r3, 0x31          # |
    bne+ normalFinalSmash   # /
warioMan:
    lis r4, 0x1200      # \
    addi r4, r4, 0x3d   # |
    lwz r3, 0xd8(r31) 	# |
    lwz r3, 0x64(r3)    # | moduleAccessor->moduleEnumeration->workManageModule->isFlag(0x1200003d)
    lwz r12, 0x0(r3)    # |
    lwz r12, 0x4c(r12)  # |
    mtctr r12           # |
    bctrl               # /
    cmpwi r3, 0x1           # \
    beq+ hitFighters    	# | check if flag is on (i.e. is it during WarioMan transformation)
    b normalFinalSmash      # /
gKoopa:
    lis r4, 0x1000      # \
    addi r4, r4, 0x40   # |
    lwz r3, 0xd8(r31) 	# |
    lwz r3, 0x64(r3)    # | moduleAccessor->moduleEnumeration->workManageModule->getInt(0x10000040)
    lwz r12, 0x0(r3)    # |
    lwz r12, 0x18(r12)  # |
    mtctr r12           # |
    bctrl               # /
    cmpwi r3, 0x2           # \
    bgt+ hitFighters        # / check if int > 0x2 (i.e. is it during Giga Bowser transformation)
normalFinalSmash:
    lis r4, 0x1200      # \
    addi r4, r4, 0x6    # |
    lwz r3, 0xd8(r31) 	# |
    lwz r3, 0x64(r3)    # | moduleAccessor->moduleEnumeration->workManageModule->isFlag(0x12000006)
    lwz r12, 0x0(r3)    # |
    lwz r12, 0x4c(r12)  # |
    mtctr r12           # |
    bctrl               # /
    cmpwi r3, 0x1           # \ Check if fighter has final smash
    bne+ dontHitFighters    # /
    lis r4, 0x1200      # \
    addi r4, r4, 0x8    # |
    lwz r3, 0xd8(r31) 	# |
    lwz r3, 0x64(r3)    # | moduleAccessor->moduleEnumeration->workManageModule->isFlag(0x12000008)
    lwz r12, 0x0(r3)    # |
    lwz r12, 0x4c(r12)  # |
    mtctr r12           # |
    bctrl               # /
    cmpwi r3, 0x0        # \ Check if fighter used final smash
    bne+ dontHitFighters # /
hitFighters:
	li r3, 0
	b end
dontHitFighters:
	li r3, 1			# Merit Disabling!
end:
	lwz r0, 0x14(r1)
	mtlr r0
	lwz r31, 0x8(r1)
	addi r1, r1, 0x10
	blr
}

.macro checkDisableFighterCollisionCategory(<reg>)
{
	mr r3, <reg>
	bla 0x758F60		# custom function below!
	cmpwi r3, 1
	bne- end
}
HOOK @ $80758F60
{
	%checkDisableFighterCollisionRoutine()
}

HOOK @ $80758F5C
{
	addi r1, r1, 0x20		# Original operation
	blr						# Making room for a function pointer to the above.
}

HOOK @ $80745d00    # soCollisionAttackModule::update
{
    %checkDisableFighterCollisionCategory(r31) # attackModule
    addi r3, r29, 0x44      # \
    lwz r12, 0x44(r29)      # |
    li r4, 1                # |
    lwz r12, 0xc(r12)       # |
    mtctr r12               # | clTarget = soCollisionAttackPart->clTargetArrayVector.at(1)
    bctrl                   # /
    lhz r0, 0x6(r3)         # \                            
    andi. r0,r0,0xfdbc      # | clTarget->categoryMask.isCollisionCategory0,1,6,9 = false
    sth r0, 0x6(r3)         # /
end:
    lwz	r6, 0x28(r31)   # Original operation
}

HOOK @ $80756288    # soCollisionCatchModuleImpl::set
{
    mr r30, r27   # Store r27 (catchModule)
    %checkDisableFighterCollisionCategory(r27) # catchModule
    lhz r6, 0x12(r29)       # \
    andi. r6,r6,0xdbcf      # | Change category mask to not hit fighter,stage or enemies
    sth r6, 0x12(r29)       # /
end:
    mr r4, r28      # Original operation
}

HOOK @ $80758d94    # soCollisionSearchhModuleImpl::set
{
    %checkDisableFighterCollisionCategory(r31) # searchModule
    lhz r6, 0x12(r27)       # \
    andi. r6,r6,0x6f3f      # | Change category mask to not hit fighter,stage or enemies
    sth r6, 0x12(r27)       # /
end:
    mr r4, r26  # Original operation
}

###################################
All Assists are Unlocked [Kapedani]
###################################
CODE @ $8004f3bc  # gmCheckAssistKindUseEnable
{
   li r3, 0x1  # \ return true immediately
   blr         # /
}

############################################################################
ItemEx Mayhem and Passive Aggression Modes default to Off on Boot [Kapedani]
############################################################################
HOOK @ $8004ec70    # GameGlobal::initSettingsFromSaveData
{
    stb    r4, 0x829(r3)   # Original operation
    lbz r11, 0x819(r3)     # \
    rlwinm r11,r11,0,29,26 # | Set Mayhem and Passive Aggression to false
    stb r11, 0x819(r3)     # /
}
HOOK @ $8004c9d8    # GameGlobal::init
{
    rlwinm r30,r30,0,13,10  # Set Mayhem and Passive Aggression to false
    stw    r30, 0x818(r3)  # Original operation
}

########################################################################################
utArchive::reqLoad 4th Parameter as 2 forces read instead of clone [DukeItOut, Kapedani]
########################################################################################
HOOK @ $800453F0
{
    mr r5, r22            # Original operation
    cmpwi r6, 0x2
    bne+ %end%
    lis r3, 0x8004      # \
    ori r3, r3, 0x5448  # | Force file to not clone.
    mtctr r3            # | 
    bctr                # / 
}