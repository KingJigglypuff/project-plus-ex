
#####################################
RSS Page Switch [DukeItOut, Kapedani]
#####################################

.alias g_GameGlobal                 = 0x805a00E0
.alias g_muSelectStageFileTask		= 0x806BB388
.alias muProcStageSwitch__init		= 0x806ab724
.alias muProcStageSwitch__exit		= 0x806ac0e8
.alias muSelectStageSwitch__selectSequential	= 0x806b7618
.alias muSelectStageSwitch__selectRandom	= 0x806b74f0
.alias muProcMenu__setAnimUpdateRate	= 0x806a53f8
.alias MuObject__changeTexPatAnimN	= 0x800b4c14
.alias MuObject__changeClrAnimN		= 0x800b50cc
.alias MuMsg__printIndex			= 0x800b91b8
.alias g_sndSystem                   = 0x805A01D0
.alias sndSystem__playSE             = 0x800742b0
.alias gfFileIORequest__setReadParam1	= 0x8002239c
.alias gfFileIO__readFile 			= 0x8001bf0c
.alias gfFileIO__writeSDFile		= 0x8001d740
.alias g_gfPadSystem				= 0x805A0040
.alias gfPadSystem__getSysPadStatus	= 0x8002ae48
.alias sprintf						= 0x803f89fc
.alias randi                        = 0x8003fc7c
.alias __memfill                    = 0x8000443c
.alias FPC_BUILD_NAME				= 0x80406920
.alias _pf               			= 0x80507b70
.alias STAGE_FOLDER 				= 0x8053EFE4

.alias STAGE_PAGES					= 0x8042C524
.alias STAGE_PAGES_IDS				= 0x8042C525
.alias RSS_EXDATA					= 0x8042C4E8
.alias RSS_HAZARD_DATA				= 0x8042C506
.alias RSS_EXDATA_BONUS				= 0x8042C840
.alias RSS_EXDATA_PATH_FULL			= 0x8042C808
.alias RSS_EXDATA_PATH				= 0x8042C80C
.alias RSS_CURRENT_PRESET			= 0x8042C81C
.alias STAGE_SLOTS_COSMETIC			= 0x8042C5EC
.alias CURRENT_PAGE					= 0x80496000
.alias PAGE_INDEX					= 0x8042C821
.alias RANDOM_LAST_STAGEKIND		= 0x8042C820
.alias STAGE_STRIKE_TABLE			= 0x8042C822
.alias ASL_BUTTON					= 0x800B9EA2
.alias MUSIC_SELECT_STEP			= 0x80002810

.alias MAX_PAGES 					= 0x5
.alias DEFAULT_RSS_INDEX			= 0x00	# Index of main .rss to load/save, Netplay - 0xFF
.alias NUM_PRESETS					= 0x7	# Change for more presets

.alias LAST_PRESET = NUM_PRESETS - 1

.macro lbd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lbz     <reg>, temp_Lo(<reg>)
}
.macro lbdu(<reg1>, <reg2>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg2>, temp_Hi
    lbzu    <reg1>, temp_Lo(<reg2>)
}
.macro lhd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lhz     <reg>, temp_Lo(<reg>)
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
.macro sbd(<reg1>, <reg2>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg2>, temp_Hi
    stb     <reg1>, temp_Lo(<reg2>)
}
.macro shd(<reg1>, <reg2>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg2>, temp_Hi
    sth     <reg1>, temp_Lo(<reg2>)
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

#op lis r7, 0x0010 @ $806c8734
#op lis r7, 0x0010 @ $806c8750
#op li r4, 43 @ $806c8748	# load sc_selcharacter2.pac in MenuResource instead of InfoExtraResource

string "%s%s%s%s/%s%02X.rss" @ $8042C808  

op cmpwi r25, 41 @ $806a4104	# \ Use same model for all 41 panes
op b 0x4C @ $806a410c			# / 
op nop @ $806ad03c				# Use the same cursor for all panes

op lwz r0, 0x750(r22) @ $806ac7e4	# \
op cmplwi r21, 41 @ $806ac818		# | Have Turn on All Normal Stages turn on Every stage in page
op lwz r0, 0x758(r22) @ $806ac890	# |
op cmplwi r21, 41 @ $806ac8c8		# | As well as patch button functionality to account for every stage
op lwz r5, 0x750(r22) @ $806acc64	# |
op b 0x64 @ $806accc8				# |
op lwz r0, 0x750(r31) @ $806abd50	# /

HOOK @ $806ab708	# muProcStageSwitch::__ct
{
	sth r0, 0x762(r30)	# \ Clear out additional byte at 0x763 (so it can be used as current page number)
	sth r0, 0x764(r30)	# / Clear out additional bytes at 0x764 and 0x765 (so it can be used to keep track of whether in hazard switch and can be used to keep track of last page)	
} 	
op lwz r5, 0x688(r23) @ $806abb18
op mr r5, r22 @ $806abe24
op mr r5, r27 @ $806ac264
#op mr r21, r24 @ $806acb1c
HOOK @ $806acb1c	# muProcStageSwitch::selectProc
{
	cmpwi r24, 0x29 			# \ Check if Custom Stage button is pressed
	bne+ notHazardSwitchButton	# /
	mr r3, r22
	%call (muProcStageSwitch__exit)
	mr r3, r22
	lbz r12, 0x764(r3)	# \
	not r12, r12		# | Flip between RSS/Hazard switch
	andi. r12, r12, 0x1	# |
	stb r12, 0x764(r3) 	# /
	lwz r4, 0x654(r3)
	%call (muProcStageSwitch__init)
	li r4, 0x23
	%lwd (r3, g_sndSystem)      # \
    li r5, -0x1                 # |
    li r6, 0x0                  # | g_sndSystem->playSE(0x23, -0x1, 0x0, 0x0, -0x1);
    li r7, 0x0                  # |
    li r8, -0x1                 # |
    %call (sndSystem__playSE)   # /

	%branch (0x806acd2c)
notHazardSwitchButton:
	#li r12, 0x0							# \ reset RSS_CURRENT_PRESET
	#%shd(r12, r11, RSS_CURRENT_PRESET)	# /
	mr r21, r24
	cmpwi r24, 0x1f
	blt+ %end%
	addi r21, r24, 0x9 
}
HOOK @ $806a4170	# muRuleTask::__ct
{
	stw	r3, 0x248(r20)	# Original operation
	addi r4, r31, 1024	# "MenMainSwitch0106_TopN__0"
	%call (MuObject__changeTexPatAnimN)	# Initialize pat anim for go to Hazard switch button
	lwz r3, 0x248(r20)
}
op li r5, 0x14 @ $806abd2c	# \ setAnimFrame also change pat frame along with clr for Hazard switch button
op li r5, 0x14 @ $806abd44	# /

HOOK @ $806ac260	# muProcStageSwitch::selectProc
{	
	li r29, -1
	andi. r0, r23, 0x40	# \ check if L press (go back preset)
	bne- changePreset	# /
	li r29, 1 
	andi. r0, r23, 0x80	# \ check if R press (go forward preset)
	beq+ end			# /
changePreset:

	li r4, 0x1EE9				# \
	%lwd (r3, g_sndSystem)      # |
    li r5, -0x1                 # |
    li r6, 0x0                  # | g_sndSystem->playSE(0x1EE9, -0x1, 0x0, 0x0, -0x1);
    li r7, 0x0                  # |
    li r8, -0x1                 # |
    %call (sndSystem__playSE)   # /

	mr r3, r22
	%call (muProcStageSwitch__exit)
	
	stwu r1, -0xF0(r1)
	addi r3, r1, 0x40				# \
    %lwi (r4, RSS_EXDATA_PATH)		# | Build file name
	%lwd (r5, STAGE_FOLDER)			# | "/stage/"
	%lwi (r6, 0x806AEE7B)			# / "Switch"
	mr r7, r6
	lhz r8, 0x10(r4)		# \
	add r8, r8, r29			# |
	cmpwi r8, NUM_PRESETS	# | add to RSS_CURRENT_PRESET (reset to 0 if past preset index)
	blt+ notReset			# |
	li r8, 0x0				# |
notReset:					# /
	cmpwi r8, 0x0			# \
	bge+ notNegative		# |
	li r8, LAST_PRESET		# /
notNegative:
	sth r8, 0x10(r4)			
	cmpwi r8, 0x0				# \
	bne+ notDefault				# | set default if preset 0x0
	li r8, DEFAULT_RSS_INDEX	# |
notDefault:						# /
	%call (sprintf)					
	
	addi r3, r1, 0x10
	addi r4, r1, 0x40
	%lwi(r5, RSS_EXDATA)
    li r6, 0x0
	li r7, 0x0
    %call (gfFileIORequest__setReadParam1)
	addi r3, r1, 0x10
	%call (gfFileIO__readFile)
	addi r1, r1, 0xF0

	mr r3, r22
	lwz r4, 0x654(r3)
	%call (muProcStageSwitch__init)
end:
	lwz	r29, 0x73C(r22)	# Original operation
}
# HOOK @ $806ac78c	# muProcStageSwitch::selectProc
# {
# 	li r5, 0x0							# \ reset RSS_CURRENT_PRESET when turn page on is set
# 	%shd(r5, r11, RSS_CURRENT_PRESET)	# /
# 	lwz	r3, 0x66C(r22)			# \
# 	li r4, 0					# | update preset name 
# 	li r6, 0					# |
# 	%call(MuMsg__printIndex)	# /
# 	lwz	r3, 0x64C(r22)	# Original operation
# }

op b 0x2c @ $806ac83c
op b 0x444 @ $806ac8e8
op b 0x34 @ $806acb84

HOOK @ $806ac154	# muProcStageSwitch::exit
{
	lbz r9, 0x763(r30)		# Get page
	lbz r11, 0x764(r30)		# \		
	cmpwi r11, 0xff			# | check if exiting from RSS
	bne+ notExiting			# /
	li r9, 0			# \ 
	stb r9, 0x763(r30)	# | set page and type to 0
	stb r9, 0x764(r30)	# /
	b end
notExiting:

	%lwi (r12, RSS_EXDATA)			# \
	mulli r10, r9, 0x6				# |
	mulli r11, r11, 0x1e			# |
	add r10, r10, r11				# |
	add r8, r12, r10				# |
	lbz r10, 0x739(r30)				# \	
	andi. r10, r10, 0x3				# | 
	stb r10, 0x0(r8)				# |
	lbz r10, 0x73A(r30)				# |
	stb r10, 0x1(r8)				# | Store random/hazard stage switch data for current page
	lhz r10, 0x73C(r30)				# |
	sth r10, 0x2(r8)				# |
	lhz r10, 0x73E(r30)				# |
	sth r10, 0x4(r8)				# /
end:	
	stb r9, 0x765(r30)	# Store last page
	lwz	r0, 0x14(r1)	# Original operation
}

op nop @ $806ac968
CODE @ $806ac98c # muProcStageSwitch::selectProc
{		
	## Increment pages if Turn on All Melee Stages is selected
	mr r3, r22
	%call (muProcStageSwitch__exit)

	%lbdu(r12, r10, STAGE_PAGES)
	li r11, -1
loc_hasStage:
	cmpwi r12, 0x0
	addi r11, r11, 0x1
	lbzu r12, 0x28(r10)  
	bne+ loc_hasStage
	lbz r9, 0x763(r22)
	addi r9, r9, 0x1 			# Increment page
	cmpwi r9, MAX_PAGES			# \
	bge+ resetPageNumber		# |
	cmpw r9, r11 				# | check if in max pages
	blt+ dontResetPageNumber	# |
resetPageNumber:				# / 
	li r9, 0x0					
dontResetPageNumber:
	stb r9, 0x763(r22)

	li r4, 0x23
	%lwd (r3, g_sndSystem)      # \
    li r5, -0x1                 # |
    li r6, 0x0                  # | g_sndSystem->playSE(0x23, -0x1, 0x0, 0x0, -0x1);
    li r7, 0x0                  # |
    li r8, -0x1                 # |
    %call (sndSystem__playSE)   # /

	mr r3, r22
	lwz r4, 0x654(r3)
	%call (muProcStageSwitch__init)
	b 0x314
}

op nop @ $806abdb4
HOOK @ $806abdb8	# muProcStageSwitch::init
{
	lbz r12, 0x763(r31)	# \
	stw r12, 0x20c(r1)	# | 
	lfd f1, 0x208(r1)	# | pass page number as float to get anim frame of next page
	lfd f2, 0xb8(r25)	# |
	fsubs f1, f1, f2	# /
}
op li r5, 0x4 @ $806abdc4	# setAnimFrame to modify only pat anim
op b 0x14 @ $806abea8
op b 0x14 @ $806acb6c
HOOK @ $806a40b4	# muRuleTask::__ct
{
	stw	r3, 0x1A0(r20)	# Original operation
	addi r4, r31, 868
	%call (MuObject__changeTexPatAnimN)	# Initialize pat anim for go to Hazard switch button
	lwz r3, 0x1A0(r20)
}

HOOK @ $806ab88c	# muProcStageSwitch::init
{
	## Set number of Normal stages accessible
	lbz r12, 0x763(r31)
  	mulli r11, r12, 40  	# \
	%lwi(r12, STAGE_PAGES)	# | get number of stages in pages
	lbzx r29, r11, r12		# /
	stw r29, 0x15C(r1)
	cmpwi r29, 0x1f
	ble+ lessThanMaxNormalStages
	li r29, 0x1f
lessThanMaxNormalStages:
	stw r29, 0x704(r31)
}
HOOK @ $806ab908	# muProcStageSwitch::init
{
	## Set number of Melee stages accessible
	lwz r29, 0x15C(r1)
	subi r29, r29, 0x1F
	cmpwi r29, 0x0
	bgt+ moreThanZero
	li r29, 0
moreThanZero:
 	stw	r29, 0x730(r31)
}

HOOK @ $806abac0	# muProcStageSwitch::init
{
	lwz	r3, 0x64C(r31)	# \
	add r3, r3, r24		# | this->muObjects[i + 0x57]
	lwz r3, 0x15c(r3)	# /
	subi r4, r26, 0x1420	# "MenMainSwitch0105_TopN__0"
	lbz r12, 0x764(r31)		# \
	cmpwi r12, 0x0			# | check if hazard switch
	beq+ notHazardSwitch	# /
	subi r4, r26, 0x1412	# "105_TopN__0"
notHazardSwitch:
	%call (MuObject__changeClrAnimN)		# \
	mr r3, r31								# |
	addi r4, r22, 0x57						# | Set animUpdateRate to 0.0 to ensure anim doesn't play 
	li r5, 0x10								# |
	lfs	f1, 0xB0(r25)						# |
	%call (muProcMenu__setAnimUpdateRate)	# /
	
	## Set animIndex of icon
	%lwi(r10, STAGE_PAGES_IDS)
	lbz r12, 0x763(r31)	# \
	mulli r12, r12, 40	# | pages[pageNumber]
	add r12, r10, r12 	# /
	lwz	r11, 0x688(r23)	# Original operation
	lbzx r12, r12, r11	# Get stage slot
	mulli r12, r12, 0x2	# \ 
	#lwz r10, -0x4(r10)	# | get cosmetic id
	#addi r10, r10, 0x1	# |
	addi r10, r10, 0xC8
	lbzx r10, r10, r12	# /
	subi r0, r10, 0x1
}
HOOK @ $806abc24	# muProcStageSwitch::init
{
	lwz	r3, 0x64C(r31)	# \
	add r3, r3, r27		# | this->muObjects[i + 0x76]
	lwz r3, 0x1d8(r3)	# /
	subi r4, r26, 0x1420	# "MenMainSwitch0105_TopN__0"
	lbz r12, 0x764(r31)		# \
	cmpwi r12, 0x0			# | check if hazard switch
	beq+ notHazardSwitch	# /
	subi r4, r26, 0x1412	# "105_TopN__0"
notHazardSwitch:
	%call (MuObject__changeClrAnimN)		# \
	mr r3, r31								# |
	addi r4, r22, 0x76						# | Set animUpdateRate to 0.0 to ensure anim doesn't play 
	li r5, 0x10								# |
	lfs	f1, 0xB0(r25)						# |
	%call (muProcMenu__setAnimUpdateRate)	# /

	## Set animIndex of icon
	%lwi(r10, STAGE_PAGES_IDS)
	lbz r12, 0x763(r31)	# \
	mulli r12, r12, 40	# | pages[pageNumber]
	add r12, r10, r12 	# /
	lwz	r11, 0x708(r28)	# Original operation
	addi r11, r11, 0x1f	# 
	lbzx r12, r12, r11	# Get stage slot
	mulli r12, r12, 0x2	# \ 
	addi r10, r10, 0xC8 # | get cosmetic id
	lbzx r10, r10, r12	# /
	subi r0, r10, 0x1
}

HOOK @ $806abf04	# muProcStageSwitch::init
{
	%lhd(r5, RSS_CURRENT_PRESET)
}
CODE @ $806abf0C	# muProcStageSwitch::init
{
	# print preset name
	li r6, 0x0
	bl -0x5F2D58	# MuMsg::printIndex 
}
HOOK @ $806acf24	# muProcStageSwitch::setCursor
{
	subi r5, r29, 19	
	%lwi(r10, STAGE_PAGES_IDS)
	lbz r12, 0x763(r28)	# \
	mulli r12, r12, 40	# | pages[pageNumber]
	add r12, r10, r12 	# /
	lbzx r12, r12, r5	# Get stage slot
	mulli r12, r12, 0x2	# \ 
	addi r10, r10, 0xC8 # | get cosmetic id
	lbzx r5, r10, r12	# /
	addi r5, r5, NUM_PRESETS
}
HOOK @ $806acf74	# muProcStageSwitch::setCursor
{
	subi r5, r29, 2		
	%lwi(r10, STAGE_PAGES_IDS)
	lbz r12, 0x763(r28)	# \
	mulli r12, r12, 40	# | pages[pageNumber]
	add r12, r10, r12 	# /
	lbzx r12, r12, r5	# Get stage slot
	mulli r12, r12, 0x2	# \ 
	addi r10, r10, 0xC8 # | get cosmetic id
	lbzx r5, r10, r12	# /
	addi r5, r5, NUM_PRESETS
}
op li r5, NUM_PRESETS @ $806acf08	# custom stages button line index
CODE @ $806acedc	# muProcStageSwitch::setCursor
{
	# print preset name
	lwz	r3, 0x066C (r3)
	%lhd(r5, RSS_CURRENT_PRESET)
	li r4, 0x0
	li r6, 0x0
	bl -0x5F3D38	# MuMsg::printIndex
}
HOOK @ $806ad070	# muProcStageSwitch::setCursor
{
	## Set animIndex of stage preview
	cmpwi r29, 0x0
	beq- notStagesSelected
	subi r29, r29, 0x2
	cmpwi r29, 0x30
	blt+ notMeleeStages
	subi r29, r29, 17
notMeleeStages:
	%lwi(r10, STAGE_PAGES_IDS)
	lbz r12, 0x763(r28)	# \
	mulli r12, r12, 40	# | pages[pageNumber]
	add r12, r10, r12 	# /
	lbzx r12, r12, r29	# Get stage slot
	mulli r12, r12, 0x2	# \ 
	addi r10, r10, 0xC8 # | get cosmetic id
	lbzx r10, r10, r12	# /
	addi r29, r10, 0x1

notStagesSelected:
	stw	r29, 0xBC(r1)
}

HOOK @ $806aba38	# muProcStageSwitch::init
{
	lwz	r3, 0x064C(r31)	# Original operation
	lbz r12, 0x765(r31)	# \
	lbz r11, 0x763(r31)	# | check if page number changed
	cmpw r11, r12		# |
	beq+ %end% 			# /
	%branch (0x806aba60)	# skip intro anim
}
HOOK @ $806aba4c	# muProcStageSwitch::init
{
	lwz	r3, 0x64C(r31)		# \ this->muObjects[0x54] (title)
	lwz	r3, 0x150(r3)		# /
	subi r4, r26, 0x14BC	# "MenMainSwitch0101_TopN__0"
	lbz r22, 0x764(r31)		# \
	cmpwi r22, 0x0			# | check if hazard switch
	beq+ notHazardSwitch	# /
	subi r4, r26, 0x14AE	# "101_TopN__0"
notHazardSwitch:
	%call (MuObject__changeTexPatAnimN)		# \
	mr r3, r31								# |
	li r4, 0x54								# | Set animUpdateRate to 0.0 to ensure anim doesn't play 
	li r5, 4								# |
	lfs	f1, 0xB0(r25)						# |
	%call (muProcMenu__setAnimUpdateRate)	# /

	lwz	r3, 0x64C(r31)		# \ this->muObjects[0x55]	(turn all stages)
	lwz	r3, 0x154(r3)		# /
	subi r4, r26, 0x1488	# "MenMainSwitch0106_TopN__0"
	cmpwi r22, 0x0			# \ check if hazard switch
	beq+ notHazardSwitch2	# /
	subi r4, r26, 0x147A	# "106_TopN__0"
notHazardSwitch2:
	%call (MuObject__changeClrAnimN)		# \
	mr r3, r31								# |
	li r4, 0x55								# | Set animUpdateRate to 0.0 to ensure anim doesn't play 
	li r5, 0x10								# |
	lfs	f1, 0xB0(r25)						# |
	%call (muProcMenu__setAnimUpdateRate)	# /

	lfs	f1, 0xB0(r25)	# Original operation
}


HOOK @ $806cb200	# scStrap::process
{
	lwz	r30, 0x24(r31)	# Original operation
	stwu r1, -0xF0(r1)
    
	addi r3, r1, 0x40				# \
    %lwi (r4, RSS_EXDATA_PATH)		# | Build file name
	%lwd (r5, STAGE_FOLDER)			# | "/stage/"
	%lwi (r6, 0x806AEE7B)			# | "Switch"
	mr r7, r6						# |
	li r8, DEFAULT_RSS_INDEX		# /
	li r12, -1			# \ set RANDOM_LAST_STAGEKIND to -1
	stb r12, 0x14(r4)	# /
	li r12, 0x0			# \ set RSS_CURRENT_PRESET to 0
	sth r12, 0x10(r4)	# /
	%call (sprintf)					
	
	addi r3, r1, 0x10
	addi r4, r1, 0x40
	%lwi(r5, RSS_EXDATA)
    li r6, 0x0
	li r7, 0x0
    %call (gfFileIORequest__setReadParam1)
	addi r3, r1, 0x10
	%call (gfFileIO__readFile)
	addi r1, r1, 0xF0
}

HOOK @ $806ab938	# muProcStageSwitch::init
{
	%lwi (r12, RSS_EXDATA)	# \
	lbz r10, 0x763(r31)		# |
	mulli r10, r10, 0x6		# | 
	lbz r11, 0x764(r31)		# |
	mulli r11, r11, 0x1e	# | Get random (or hazard) stage switch data for current page
	add r10, r10, r11		# |
	lhzx r11, r12, r10 		# | 
	slwi r11,r11,8			# |
	lbz r3, 0x764(r31)		# \
	slwi r3,r3,18			# | Get whether or not in hazard switch
	or r11, r3, r11		 	# /
	addi r10, r10, 0x2		# |
	lwzx r3, r12, r10		# /
}

HOOK @ $806ac04c	# muProcStageSwitch::proc
{
	%lwi (r12, RSS_EXDATA)			# \
	lbz r9, 0x763(r31)				# |
	mulli r10, r9, 0x6				# |
	lbz r11, 0x764(r31)				# |
	mulli r11, r11, 0x1e			# |
	add r10, r10, r11				# |
	add r8, r12, r10				# |
	lbz r10, 0x739(r31)				# \
	andi. r10, r10, 0x3				# |
	stb r10, 0x0(r8)				# |
	lbz r10, 0x73A(r31)				# | 
	stb r10, 0x1(r8)				# | Store random/hazard stage switch data for current page
	lhz r10, 0x73C(r31)				# |
	sth r10, 0x2(r8)				# |
	lhz r10, 0x73E(r31)				# |	
	sth r10, 0x4(r8)				# /
	li r11, 0x0				# \
checkIfEnabled:				# |
	lbzx r10, r12, r11 		# |
	cmpwi r10, 0x0			# |
	bne+ exit				# | Loop to check if at least one stage is enabled
	addi r11, r11, 0x1		# |
	cmpwi r11, 0x1e			# |
	blt+ checkIfEnabled		# /
	li r4, 0x3                 	# play beep sound
    %lwd (r3, g_sndSystem)      # \
    li r5, -0x1                 # |
    li r6, 0x0                  # | g_sndSystem->playSE(0x3, -0x1, 0x0, 0x0, -0x1);
    li r7, 0x0                  # |
    li r8, -0x1                 # |
    %call (sndSystem__playSE)   # /
	%branch (0x806ac0c8)	# don't exit if no stages are enabled	
exit:
    %lwi (r4, RSS_EXDATA_PATH_FULL)	
	lhz r12, 0x14(r4)	# \
	cmpwi r12, 0x0		# | Only save if RSS_CURRENT_PRESET is 0
	bne+ dontSave		# /

	stwu r1, -0x70(r1)				# \
	addi r3, r1, 0x40				# | Build file name
	%lwi (r5, FPC_BUILD_NAME)		# |	
	%lwi (r6, _pf)					# | "pf"
	%lwd (r7, STAGE_FOLDER)			# | "/stage/"
	%lwi (r8, 0x806AEE7B)			# | "Switch"
	mr r9, r8						# |
	li r10, DEFAULT_RSS_INDEX		# |
	%call (sprintf)					# /
	addi r3, r1, 0x10				# \
	li r5, 0						# |
	stw r5, 0x4(r3)					# |
	stw r5, 0x10(r3)				# |
	%lwi (r4, RSS_EXDATA)			# | Write random stage switch data for current page
	stw r4, 0xc(r3)					# |
	addi r4, r1, 0x40				# |
	stw r4, 0x0(r3)					# |
	li r4, 772 						# |
	stw r4, 0x8(r3)					# |
	li r4, -1						# |
	stw r4, 0x14(r3)				# |
	%call (gfFileIO__writeSDFile)	# |
	addi r1, r1, 0x70 				# /

dontSave:
	li r12, 0xff		# \
	stb r12, 0x764(r31)	# / set to 0xff to indicate full exit

	lbz	r0, 0x762(r31)	# Original operation
}									
op nop @ $806ac0a8	# \ Don't save to normal RSS record location
op nop @ $806ac0b4	# /

HOOK @ $806a7aa4	# muProcRule1::selectProc
{
	%lwd (r12, g_GameGlobal)	# \
  	lwz r12, 0x1C(r12)    		# | g_GameGlobal->setRule->spMeleeOption1
  	lbz r12, 0x18(r12)    		# /
  	cmpwi r12, 0x2        		# \ Check if stamina mode
  	beq- end      				# /
	%lwi (r3, STAGE_STRIKE_TABLE)   # \
    li r4, 0x0              		# | Clear all stage strikes from the table when another stage choice is selected
    li r5, 0x1e             		# | 
    %call (__memfill)       		# /
	mr r3, r23 		# Restore this in r3
end:
	cmpwi r24, 2	# Original operation
}


HOOK @ $80682988	# muSelCharTask::__ct
{
	stw	r31, 0x64(r30)	# Original operation
	%sbd (r31, r12, RSS_EXDATA_BONUS)	# Reset
}
HOOK @ $806b50d4	# muSelectStageTask::randomProc
{
	stwu r1, -0x48(r1)
	%lwd (r3, g_gfPadSystem)				# \
	lwz r4, 0x278(r31)						# | 
	addi r5, r1, 0x8						# | get input
	%call (gfPadSystem__getSysPadStatus)	# |
	lwz r12, 0xc(r1)						# /

	li r11, 0x0
	andi. r0, r12, 0x1000	# \ check if start is pressed
	beq+ noAltRandom		# /
	andi. r0, r12, 0x40		# \ 
	beq+ isNotL				# | check if L input
	ori r11, r11, 0x4		# |	
isNotL:						# /
	andi. r0, r12, 0x20		# \
	beq+ isNotR				# | check if R input
	ori r11, r11, 0x2		# |
isNotR: 					# /
	%sbd (r11, r12, RSS_EXDATA_BONUS)
noAltRandom:
	addi r1, r1, 0x48
	lwz	r29, 0x6158(r31)	# Original operation
}

HOOK @ $806b40d0	# muSelectStageTask::onlineProc
{
	li r4, 0x0
	%call (muSelectStageSwitch__selectSequential)
}
HOOK @ $806b4e90	# muSelectStageTask::randomProc
{
	li r4, 0x0
	%call (muSelectStageSwitch__selectSequential)
}
HOOK @ $806b4b30	# muSelectStageTask::selectingProc
{
	li r4, 0x0
	lwz r12, 0x228(r27)	# \
	cmpwi r12, 0x2		# | set to select only custom stages if on custom stages page
	bne+ notCustomPage	# |
	li r4, 0x2			# /
notCustomPage:	
	%call (muSelectStageSwitch__selectSequential)
}
HOOK @ $806b7c80	# muSelectStageTask::processDefaultWithoutScreen
{	
	li r4, 0x0
	%call (muSelectStageSwitch__selectSequential)
}
HOOK @ $806b7ca0	# muSelectStageTask::processDefaultWithoutScreen
{
	li r4, 0x1
	li r11, 0x8		# keep track of if sequential
	%sbd (r11, r12, RSS_EXDATA_BONUS)
}

op nop @ $806b762c	# muSelectStageTask::selectSequential
CODE @ $806b7638	# muSelectStageTask::selectSequential
{
selectRandom:
	addi r28, r1, 0x8
	li r30, 0x0	# Number of selected stages 
	li r6, 0x0	# Page number
	%lwi (r12, RSS_EXDATA)
	%lwi (r29, STAGE_PAGES_IDS)
	cmpwi r27, 0x2 
	beq- addCustomStage 
nextPage:
	#lwz r4, 0x2(r12) 
	#lwz r5, 0x5C(r12)
	lhz r4, 0x2(r12)
	slwi r4,r4,16
	lhz r11, 0x4(r12)
	or r4, r4, r11
	lhz r5, 0x33C(r12)
	slwi r5,r5,16
	lhz r11, 0x33E(r12)
	or r5, r5, r11
	li r3, -1		# \
	xor r5, r5, r3	# / Invert the strike table
	and r4, r5, r4
	li r7, 0x0	# Stage index in current page
	lbz r8, -0x1(r29)		# get number of stages in page
notExtraPages:
	cmpwi r8, 0x0
	ble+ noStagesLeft
	andi. r0, r4, 0x1
	srawi r4, r4, 1
	beq+ notSelected
	lbzx r3, r29, r7 
	stb r6, 0x0(r28) 
	stb r7, 0x1(r28)
	stb r3, 0x2(r28)
	cmpwi r27, 0x0		# \ check if random mode should prevent picking last stage
	bne+ select			# /
	%lbd(r10, RANDOM_LAST_STAGEKIND)	# \
	cmpw r3, r10						# | check if stage is last stage picked
	beq- notSelected					# /
select:
	addi r28, r28, 3
	addi r30, r30, 1
notSelected:
	addi r7, r7, 0x1
	cmpwi r7, 0x1F
	bne+ notMeleeStagesStart
	lhz r4, 0x0(r12)
	lhz r5, 0x33A(r12)
	li r3, -1		# \
	xor r5, r5, r3	# / Invert the strike table
	and r4, r5, r4
notMeleeStagesStart:
	subi r8, r8, 0x1
	b notExtraPages
noStagesLeft:	
	addi r12, r12, 0x6
	addi r29, r29, 40
	addi r6, r6, 0x1
	cmpwi r6, MAX_PAGES
	blt+ nextPage
	cmpwi r27, 0x0			# \ check if random mode allows repeats
	bne+ ableToPickRepeat	# /
	cmpwi r30, 0x0			# \	check if no stages available
	bne+ ableToPickRepeat	# /
	addi r30, r30, 1	# set to 1 so repeat can be picked
ableToPickRepeat:
	lbz r11, 0x33A(r12) # \ Get RSS_EXDATA_BONUS to check if custom stages are on
	andi. r0, r11, 0x1	# /
	beq+ noCustomStages	
addCustomStage:
	%lwd (r31, g_muSelectStageFileTask)	# \
	cmpwi r31, 0x0						# | check if g_muSelectStageFileTask exists
	beq+ noCustomStages					# /
	lwz r12, 0x50(r31)	# \ 
	lwz r11, 0x60(r31)	# | get number of custom stages
	add r31, r12, r11	# /
	cmpwi r31, 0x0		# \ check if there is at least one custom stage
	beq+ noCustomStages	# /
	li r11, 0xff		# \
	stb r11, 0x0(r28)	# / stageEntries[numStages].page = 0xff
	addi r30, r30, 0x1	
noCustomStages:
	#li r4, 43
	#li r10, 0x1
	#li r3, 14
	cmpwi r30, 0x0
	bgt+ hasStages
	%lwi (r3, STAGE_STRIKE_TABLE)   # \
    li r4, 0x0              		# | Clear all stage strikes from the table
    li r5, 0x1e             		# | 
    %call (__memfill)       		# /
	b selectRandom
hasStages:
	mr r3, r30 			# \
	%call (randi)		# |
	addi r28, r1, 0x8	# | get random stage entry
	mulli r3, r3, 0x3	# | 
	add r28, r28, r3	# |
	lbz r10, 0x0(r28)	# /
	cmpwi r10, 0xff		# \ check if stage builder stage was picked
	bne+ notCustomStage	# /
	%sbd(r10, r12, RANDOM_LAST_STAGEKIND)	# save RANDOM_LAST_STAGEKIND as 0xFF 
	mr r3, r31			# \ get random index
	%call (randi)		# /
	li r6, 0x0		# loadType = nand
	%lwd (r12, g_muSelectStageFileTask)	# \ 
	lwz r12, 0x50(r12)					# | check if greater than number of custom stages in nand
	cmpw r3, r12						# |
	blt+ notSD							# /
	li r6, 0x1			# \	loadType = sd
	sub r3, r3, r12		# / index -= numNandStages
notSD:
	li r10, 0x2 		# | selectedStageEntry.index = randi(numStageBuilderStages)
	stw r6, 0x8(r26)	# | selectedStageEntry.stageKind = loadType
	stw r3, 0x4(r26)	# | selectedStageEntry.page = 0x2
	b normal			# /
notCustomStage:
	%lwi (r12, STAGE_STRIKE_TABLE)	
	lbz r3, 0x1(r28)
	lbz r4, 0x2(r28)
	stb r4, -0x2(r12)	# save RANDOM_LAST_STAGEKIND
	cmpwi r27, 0x1		# \ check if ordered stage choice
	bne+ notOrdered		# /
	mulli r11, r10, 0x6				# \
	add r12, r12, r11				# |
	mr r9, r3						# |
	cmpwi r9, 0x1f					# |
	blt+ notMeleeStages				# |
	subi r9, r9, 0xF 				# | Keep track which stages have been picked in STAGE_STRIKE_TABLE
	subi r12, r12, 0x2				# |
notMeleeStages:						# |
	#lwz r8, 0x2(r12)				# |
	lhz r8, 0x2(r12)				# |
	slwi r8,r8,16					# |
	lhz r11, 0x4(r12)				# |
	or r8, r8, r11					# |
	li r6, 1						# |
	slw r6, r6, r9					# |
	or r8, r8, r6					# |
	#stw r8, 0x2(r12)				# |
	sth r8, 0x4(r12)				# |
	srawi r8,r8,16					# |
	sth r8, 0x2(r12)				# /
notOrdered:
	mulli r5, r4, 0x2 
	subi r29, r29, 0x1
	lbzx r6, r29, r5   	
	stw r6, 0x8(r26)
	stw r3, 0x4(r26)	
	%sbd (r10, r12, CURRENT_PAGE)
	cmpwi r10, 2
	blt+ normal
	li r10, 0x0		# Extra pages are clones of page 1!
normal:
	stw r10, 0x0(r26)
	addi r11, r1, 13456
	b 0xB8  
}
op nop @ $806b40fc	# \
op nop @ $806b4eb8 	# |
op nop @ $806b4b5c	# | Skip exchanging srStageKind for muStageKind
op nop @ $806b7cdc	# /
op lwz r0, 0x34(r1) @ $806b4148	# \
op lwz r0, 0x18(r1) @ $806b4f04	# | Set loadType
op lwz r0, 0x28(r1) @ $806b4ba8	# |
op lwz r0, 0x28(r1) @ $806b7d2c # /
HOOK @ $806b4f54	# muSelectStageTask::randomProc
{	
	%lwd (r12, g_muSelectStageFileTask) # \
	lwz r12, 0x388(r12)					# |
	rlwinm.	r0, r0, 25, 31, 31			# |
	beq+ checkIfNand					# | check load type instead of just always grabbing from nand
	cmpwi r12, 0x1						# |
	b %end%								# |
checkIfNand:							# |
	cmpwi r12, 0x0						# /
}
HOOK @ $806b5010	# muSelectStageTask::randomProc
{
	%lwd (r12, g_muSelectStageFileTask) # \
	lwz r12, 0x388(r12)					# |
	rlwinm.	r0, r0, 25, 31, 31			# |
	beq+ checkIfNand					# | check load type instead of just always grabbing from nand
	cmpwi r12, 0x1						# |
	b %end%								# |
checkIfNand:							# |
	cmpwi r12, 0x0						# /
}

CODE @ $806b74f0	# muSelectStageTask::selectRandom (turn into function to get hazard setting)
{
	%lwi (r12, RSS_HAZARD_DATA)
	mulli r10, r4, 0x6				# \
	add r12, r12, r10				# |
	cmpwi r3, 0x1f					# |
	blt+ notMeleeStages				# |
	subi r3, r3, 0xF 				# | 
	subi r12, r12, 0x2				# | Get hazard setting from selected stage
notMeleeStages:						# |
	#lwz r10, 0x2(r12)				# |
	lhz r10, 0x2(r12)				# |
	slwi r10,r10,16					# |
	lhz r12, 0x4(r12)				# |
	or r10, r10, r12				# |
	not r10, r10					# |
	sraw r10, r10, r3				# |
	andi. r3, r10, 0x1				# |
	blr
}

HOOK @ $806c9030	# scSelStage::process
{
	%lbd (r4, CURRENT_PAGE)
	lbz r8, 0x45(r5)	# selectStageTask->hazard

	lwz r3, 0x6158(r5)	# selectStageTask->selectedEntry.index
	lwz r9, 0x40(r5)	# \
	cmplwi r9, 0x2		# | check if setting < 3
	ble- setHazard 		# /
random:
	%call(muSelectStageSwitch__selectRandom)	# get hazard setting
	mr r8, r3
setHazard:
	lwz	r5, 0x3AC(r31)
	%lwd(r3, g_GameGlobal)
	lwz	r4, 0x14(r3)

	stb r8, 0x25(r4)	# set hazard
	lwz	r0, 0x258(r5)	# Original operation
}
HOOK @ $806dcee8	# sqVsMelee::setupMelee
{
	lbz r12, 0x25(r26)			# \
	lbz r11, 0x29(r31)			# | set hazard setting in 0x21 bit
	rlwimi r11, r12, 5, 26, 26	# |
	stb r11, 0x29(r31)			# /
	rlwinm r3, r27, 0, 16, 31	# Original operation
}
HOOK @ $806deefc	# sqSpMelee::setupSpMelee
{
	lbz r12, 0x25(r22)			# \
	lbz r11, 0x29(r27)			# | set hazard setting in 0x21 bit
	rlwimi r11, r12, 5, 26, 26	# |
	stb r11, 0x29(r27)			# /
	rlwinm r3, r23, 0, 16, 31	# Original operation
}
HOOK @ $806dfe2c	# sqQuMelee::setupMelee
{
	lbz r12, 0x25(r25)			# \
	lbz r11, 0x29(r30)			# | set hazard setting in 0x21 bit
	rlwimi r11, r12, 5, 26, 26	# |
	stb r11, 0x29(r30)			# /
	rlwinm r3, r26, 0, 16, 31	# Original operation
}
HOOK @ $806de824	# sqToMelee::setupMelee
{
	lbz r12, 0x25(r26)			# \
	lbz r11, 0x29(r30)			# | set hazard setting in 0x21 bit
	rlwimi r11, r12, 5, 26, 26	# |
	stb r11, 0x29(r30)			# /
	lbz	r4, 0x24(r26)	# Original operation
}
HOOK @ $806f1a0c	# sqTraining::setupTraining
{
	lbz r12, 0x25(r23)			# \
	lbz r11, 0x29(r29)			# | set hazard setting in 0x21 bit
	rlwimi r11, r12, 5, 26, 26	# |
	stb r11, 0x29(r29)			# /
	lbz	r4, 0x24(r23)	# Original operation
}

## TODO: Use gfFileIO request for read/write
## TODO: Dpad to switch pages (left/right), hazard (down/up)? (need to check whether is sideways wiimote)

#####################################################################################################
# Stage Striking & Page Switch (Requires Custom SSS) [Magus, InternetExplorer, DukeItOut, Kapedani] #
#####################################################################################################
# address 9017BE70: Random Stage Switch block for Melee+Custom
# address 9017BE74: Random Stage Switch block for Brawl
# address 8053E570: Stage Strike Block for Melee
# address 8053E574: Stage Strike Block for Brawl
# address 8053E578: Stage Strike Block for Extra
# address 8053E57C: Stage Strike Block for Extra2 (Unused)

HOOK @ $806bfd68	# stDecentralizationNandLoader::loadFiles2
{
	%lwi (r3, STAGE_STRIKE_TABLE)   # \
    li r4, 0x0              		# | Clear all stage strikes from the table
    li r5, 0x1e             		# | 
    %call (__memfill)       		# /
	li r0, 0	# Original operation
}

HOOK @ $806b09ec	# muSelectStageTask::create
{
	%lwi (r3, PAGE_INDEX)   	# \
    li r4, 0x0              	# | Clear all stage strikes from the table
    li r5, 0x24             	# / TODO: Probs find an unused byte in muSelectStage for page index
	%lwd (r12, MUSIC_SELECT_STEP)	# \
	cmpwi r12, 0x0					# | check if during Music Select
	beq+ notMusicSelect				# /
	li r5, 0x1F		# Only clear until end of stage strikes
notMusicSelect:
    %call (__memfill)       
	mr r3, r31			# Original operation
}

HOOK @ $806B586C	# muSelectStageTask::buttonProc
{
 	lwz r12, -0x43C0(r13)
  	lwz r12, 0x284(r12);  	cmpwi r12, 1;  bne- skipStageStrike	# Skip if SSS is not active
	#lwz r12, 0x250(r29);	cmpwi r12, 10; ble- clearTable		# Skip if SSS has not been present for more than 10 frames
	#mr r4, r12
	stwu r1, -0x50(r1)
  	stmw r18, 0x18(r1)
	#lis r12, 0x8049
	#lwz r12, 0x6000(r12)
	#stw r12, 0x8(r1)
	%lwi (r26, RSS_EXDATA)
	addi r25, r26, 0x33A # STAGE_STRIKE_TABLE
	mr r28, r3
	# lwz r3, 0xC(r25)
	# cmpwi r3, 0;	beq+ noSecondBell
	# cmpw  r4, r3;	blt- noSecondBell
	# li r5, 0				# \ Only play once.
	# stw r5, 0xC(r25)		# /
	# lis r3, 0x805A			# \
	# li r4, 0x1EEC				# | Play SFX 1EEC (Menu 44)
	# lis r12, 0x806A			# |
	# ori r12, r12, 0x83F4	# |
	# mtctr r12				# |
	# bctrl					# /	

	
noSecondBell:
	#mr r3, r28
	lbz r4, -0x1(r25) 		# previously processed page 
	%lbd (r5, CURRENT_PAGE)
	cmpw r4, r5;	beq dontRefresh

	stb r5, -0x1(r25)
	li r24, 0x2				# Set that we are striking all stages not on this page or 
	lbz r23, 0x230(r29)
	b clearLoopStart		# Go up to deal with the BG and cursor	
dontRefresh:
	cmpwi r5, 4;	beq noStageStrike	# Custom stage page?
  	#rlwinm. r0, r3, 0, 13, 13;  bne- noStageStrike				# 0x00400000	# Classic Controller B?		(0040)
  	andi. r0, r3, 0x200;		bne- clearAllStrikes			# 0x200			# B
	#rlwinm. r0, r3, 0, 20, 20;  bne- StrikeAllOffInStageSwitch	# 0x00000800	# \ GameCube Controller Y	(0800)
  	#rlwinm. r0, r3, 0, 14, 14;  bne- StrikeAllOffInStageSwitch	# 0x00020000	# / Classic Controller Y	(0020)
  	rlwinm. r0, r3, 0, 21, 21;  bne- PrepareToStrikeStage		# 0x00000400	# \ GameCube Controller X	(0400)
  	rlwinm. r0, r3, 0, 12, 12;  bne- PrepareToStrikeStage		# 0x00080000	# / Classic Controller X	(0008)
  	#rlwinm. r0, r3, 0, 27, 27;  bne- clearAllStrikes			# 0x00000010	# \ GameCube Controller Z	(0010)
  	#rlwinm. r0, r3, 0, 10, 10;  bne- clearAllStrikes			# 0x00200000	# / Classic Controller ZL/ZR
	li r23, 1				# \ Passive mode
	li r24, 0x3				# /
	lwz r28, 0x248(r29)		# Current selection on the stage selection screen
	cmpwi r28, -1
	beq- noStageStrike
	b setLoopStart
# This part of the code is how it will now strike stages.
# r23 modes: 	0 = Clearing
# 			 	1 = Striking One Stage
#				2 = Striking All Stages
#				3 = Passive
PrepareToStrikeStage:	

	lwz r12, 0x244(r29)				# \
	cmpwi r12, 0x36					# | check if currently hovered over random
	beq- StrikeAllOffInStageSwitch	# /
	lwz r28, 0x248(r29)		# Current selection on the stage selection screen
	cmpwi r28, -1			# \ But if we already disabled it . . . . . no point in doing so again
	beq- dontRestrike		# /
	lis r3, 0x805A			# \
	li r4, 0x24 			# | Play SFX 24 (Menu 15)
	lis r12, 0x806A			# |
	ori r12, r12, 0x83F4	# |
	mtctr r12				# |
	bctrl					# /
	li r23, 1				# We are only striking one stage!
	li r24, 0x1				# Set that we are striking
	b setLoopStart
StrikeAllOffInStageSwitch:	
	li r8, 0
	li r12, 0
loopThroughStageSwitch:
	lhzx r4, r26, r12		# \ Copy Melee stage switch settings
	lhzx r5, r25, r12		# |
	mr r7, r5 				# | 
	li r6, -1				# | \ But invert them!
	xor r4, r4, r6			# | /
	or r4, r4, r5			# |
	#oris r4, r4, 4			# | but always set custom stages to be struck
	sthx r4, r25, r12		# / 
	oris r7, r7, 4 			# \if bans changed, remember it
	cmpw r4, r7 			# |
	beq notChanged 			# |
	li r8, 1				# /
notChanged:
	addi r12, r12, 0x2
	cmpwi r12, 0x1E
	blt+ loopThroughStageSwitch

	cmpwi r8, 1				# \if no bans changed, skip sfx 
	bne 0x1C 				# / 
	lis r3, 0x805A			# \
	li r4, 0x1EEC			# | Play SFX 1EEC (Menu 44)
	lis r12, 0x806A			# |
	ori r12, r12, 0x83F4	# |
	mtctr r12				# |
	bctrl					# /	
	
	li r24, 0x2				# Set that we are striking all stages not on this page or 
	lbz r23, 0x230(r29)
	b clearLoopStart		# Go up to deal with the BG and cursor	
	
clearAllStrikes:
	li r12, 0x0
loopThroughStrikes:
	lhzx r24, r25, r12		# \
	cmpwi r24, 0			# |
	bne+ needToClear 		# |
	addi r12, r12, 0x2		# |
	cmpwi r12, 0x1E			# | Don't do this if there is nothing to clear!
	blt+ loopThroughStrikes	# |
	b noStageStrike			# /

needToClear:
	lis r3, 0x805A			# \
	li r4, 0x1EEA			# | Play SFX 1EEA (Menu 42)
	lis r12, 0x806A			# |
	ori r12, r12, 0x83F4	# |
	mtctr r12				# |
	bctrl					# /		
	lbz r23, 0x230(r29)		# Stage count on page.	
	li r24, 0				# Set that we are clearing
	subi r3, r25, 0x1	    # \
    li r4, 0x0              # | Clear all stage strikes from the table
    li r5, 0x1f             # | 
    %call (__memfill)       # /
	
###
clearLoopStart:
	li r28, 0
setLoopStart:
	stw r28, 0x10(r1)
	stw r23, 0x0C(r1)
clearLoop:
	mr r4, r28				#
# prerequisite: r3 = page as observed by Brawl, r4 = stage on page (i.e. the 21st is 0x14. The first is 0x00)
	mulli r12, r28, 4		# \
	addi r12, r12, 0x8C		# | Access pointer to stage icons. To get the frame, pull 0x98 from r31.
	lwzx r31, r29, r12		# /
	stw r31, 0x14(r1)
	cmpwi r24, 3
	bne notIdle
	lwz r12, 0x14(r31)		# \
	lwz r12, 0x10(r12)		# | Get the current frame.
	lwz r12, 0x18(r12)		# /
	lis r0, 0x43C8
	cmpw r12, r0
	bge dontRestrike
	b noStageStrike
notIdle:
	# lis r12, 0x806B			# \
	# ori r12, r12, 0x8F50	# | Obtain the stage slot in this location
	# mtctr r12				# |
	# bctrl					# /
	cmpwi r24, 0			# \ The table was already cleared if this is 0, so don't strike it, then!
	beq notStrikingSlot		# /
	lbz r9, -0x1(r25)
	mulli r9, r9, 0x6
	add r12, r25, r9
	li r10, 0x1
	mr r6, r4
	#lwz r5, 0x2(r12)
	lhz r5, 0x2(r12)				
	slwi r5,r5,16					
	lhz r11, 0x4(r12)				
	or r5, r5, r11					

	cmpwi r4, 0x1f
	blt+ notMeleeSlot
	subi r6, r6, 0x1F
	lhz r5, 0x0(r12)
notMeleeSlot:	 
	slw r10, r10, r6

	#lwz r5, 0x0(r12)	
	#lwz r6, 0x0(r6)
	cmpwi r24, 2;	beq- blanketStrikeCheck
	cmpwi r24, 3;	beq+ dontRestrike
	b setStrikeStatus
blanketStrikeCheck:
	and. r0, r10, r5
	#and. r0, r4, r5			# \ Don't mess with this slot if it is set to appear in random!
	beq+ skipSet			# /
	b doneStrikingSlot
setStrikeStatus:
	or r10, r10, r5
	#or r4, r4, r5			# Make sure to include bits set, before!
strikeBehavior:
	cmpwi r4, 0x1F
	blt+ storeNormal 
	sth r10, 0x0(r12)
	b copyStrikes
storeNormal:	
	sth r10, 0x4(r12)				
	srawi r10,r10,16				
	sth r10, 0x2(r12)				
	#stw r10, 0x2(r12)
	#stw r4, 0(r12)			#
copyStrikes:	
doneStrikingSlot:
notStrikingSlot:
	lis r3, 0x8049
	lbz r3, 0x6000(r3)
	%call (0x806B8F50)	# Obtain the stage slot in this location
	%call (0x800AF6A0)	# Access the float for this stage number's icon
	cmpwi r24, 0			# \ Only apply the strike mark if it is requested
	beq clearing			# /
	stwu r1, -0x10(r1)		# \
	lis r0, 0x43C8			# | 400.0
	stw r0, 0x8(r1)			# |
	lfs f0, 0x8(r1)			# | Add 400.0 to the stage texture that is being increased so it goes to the set with strike imagery
	fadds f1, f0, f1		# |
	addi r1, r1, 0x10		# /
clearing:
	lwz r3, 0x14(r1)		# \
	lis r12, 0x800B			# |
	ori r12, r12, 0x7900	# | Set the frame
	mtctr r12				# |
	bctrl					# /
skipSet:	
	lwz r28, 0x10(r1)
	lwz r23, 0x0C(r1)
	addi r28, r28, 1
	stw r28, 0x10(r1)
	cmpw r28, r23
	blt+ clearLoop
	
dontRestrike:
clearSplash:
	li r0, -1				# \ Invalidate current stage selection
	stw r0, 0x248(r29)		# /
	stwu r1, -0x10(r1)		# \
	lis r0, 0x42A0			# |
	stw r0, 0x8(r1)			# | Set the background image to 80.0 (blank)
	lfs f1, 0x8(r1)			# |
	addi r1, r1, 0x10		# /
	lwz r3, 0x80(r29)		# Pointer to background image
	lis r12, 0x800B			# \
	ori r12, r12, 0x7900	# | Set the frame
	mtctr r12				# |
	bctrl					# /	
	lwz r3, 0x214(r29)		# \
	lwz r4, 0x204(r29)		# | Make the highlight cursor disappear
	lwz r12, 0(r3)			# |
	lwz r4, 0x10(r4)		# |
	lwz r12, 0x3C(r12)		# |
	mtctr r12				# |
	bctrl					# /
	
noStageStrike:	
finishStageStrike:	
	lmw r18, 0x18(r1)
	#lwz r3, 0x8(r1)
	#lis r12, 0x8049
	#stw r3, 0x6000(r12)	
  	addi r1, r1, 0x50
doneStageStrike:
	lwz r3, 0x13C(r1)				# Retrieve input and floats, again
skipStageStrike:
  	rlwinm. r0, r3, 0, 19, 19		# Start button check
}
HOOK @ $806B7A5C
{
	lis r11, 0x8053;  ori r11, r11, 0xE570	# \
	li r6, -1								# |	Prepare the table of strikable stages
	lwz r12, 0(r11);  xor r12, r12, r6		# /
	and r5, r5, r12							# Filter them out from the accessible stages
	lwz r12, 4(r11);  xor r12, r12, r6		# Omit the stages already eliminated
	lwz r6, 0x24(r21);  and r6, r6, r12
	cmpwi r5, 0x0;  bne+ %END%				# Skip if no stages removed????
	cmpwi r6, 0x0;  bne+ %END%				# Skip if no strikes?
	lwz r5, 0x20(r21);  lwz r6, 0x24(r21)
}
