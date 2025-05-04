####################################################
P+ Stamina REDUX v1.3 [wiiztec, DukeItOut, Kapedani]
####################################################

.alias g_ftDataCommon							= 0x80B88268
.alias g_ftManager                          	= 0x80B87C28
.alias ftManager__getFighter                	= 0x80814f20
.alias ftManager__getPlayerNo					= 0x80815ad0
.alias ftManager__getOwner						= 0x808159e4
.alias ftManager__lostCoin						= 0x808169ec
.alias Fighter__warp							= 0x80847274
.alias g_ftEntryManager                     	= 0x80B87c48
.alias ftEntryManager__getEntity            	= 0x80823b24
.alias ftEntryManager__getEntryIdFromTaskId 	= 0x80823f90
.alias ftOwner__isDropOnlyBill					= 0x8081d788
.alias g_itManager                          	= 0x80B8B7F4
.alias itManager__createItem					= 0x809b1a18
.alias itManager__createMoney					= 0x809b433c
.alias BaseItem__setScale 						= 0x8099a228
.alias BaseItem__warp 							= 0x80998814
.alias BaseItem__getCreaterItem             	= 0x8099302c
.alias BaseItem__getParam						= 0x80997270
.alias g_Stage									= 0x80B8A428
.alias g_ftStatusUniqProcessDead				= 0x80b8989c
.alias ftStatusUniqProcessDead__decCoin			= 0x8087dc18
.alias soExternalValueAccesser__getLr 			= 0x807974c8
.alias soExternalValueAccesser__getStatusKind 	= 0x80797608
.alias soExternalValueAccesser__getWorkFlag  	= 0x80797710
.alias soExternalValueAccesser__getWorkInt		= 0x807976d8
.alias soValueAccesser__getConstantFloat 		= 0x80796c6c
.alias g_IfMngr									= 0x805A02D0   
.alias IfPlayer__setDamageState 				= 0x800e3684
.alias g_GameGlobal                         	= 0x805a00E0
.alias g_ecMgr									= 0x805a0148
.alias ecMgr__setEffect 						= 0x8005F7E0
.alias gfTask__getTask							= 0x8002dc40
.alias randf									= 0x8003fb64
.alias _float_1_0								= 0x80AD7DCC

.alias STAGEEX_COLOR_OVERLAY					= 0x8053F00C

.macro lf(<freg>, <reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lfs     <freg>, temp_Lo(<reg>)
}
.macro lfu(<freg>, <reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lfsu    <freg>, temp_Lo(<reg>)
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
.macro lwdu(<reg1>, <reg2>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg2>, temp_Hi
    lwzu    <reg1>, temp_Lo(<reg2>)
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
HOOK @ $80839248	# Fighter::processFixPosition	
{
	mr r3, r26
	%lwi (r4, 0x12000018)
	%call (soExternalValueAccesser__getWorkFlag)
	cmpwi r3, 0
	beq+ end
	mr r3, r26
	%call (soExternalValueAccesser__getStatusKind)
	cmpwi r3, 0xBD
	beq+ end 

	mr r3, r26         	# \
    lwz	r12, 0x3C(r26) 	# |
    lwz	r12, 0x2EC(r12) # | Fighter->getOwner()
    mtctr r12         	# |
    bctrl               # /
	mr r25, r3
	lwz r10, 0x0(r3)    # \
    lwz r10, 0x8(r10)   # | Check if ftOwner->ftOwnerData->hitPointMax was set  
    cmpwi r10, 0x0      # |
    beq+ end          	# /

	mr r3, r26			# \
	lwz r12, 0x3c(r26)	# |
	lwz r12, 0x9C(r12)	# | Check if Fighter->getInput()
	mtctr r12			# |
	bctrl 				# /
	lwz r12, 0x4(r3)	# \
	lwz r12, 0x18(r12)	# | input->getButton()
	mtctr r12			# |
	bctrl 				# /
	stw r3, 0xc(r1)
	
	lwz r4, 0x28(r26)	# fighter->taskId
    %lwd(r3, g_ftEntryManager) 			
	addi r5, r1, 0x8	# outInstanceIndex
	%call(ftEntryManager__getEntryIdFromTaskId) 
    lwz r3, 0x8(r1) 		# \
    cmpwi r3, 3     		# | check if outInstanceIndex == 3 (i.e it is a double fighter)
    beq- notSelfDestruct   # /
	
	mr r3, r25			# \
	lwz r12, 0xc(r3) 	# |
	lwz r12, 0xc(r12)	# | ftOwner->isSubOwner()
	mtctr r12			# |
	bctrl 				# /
	cmpwi r3, 0x1		# \ check if subOwner (i.e. Nana)
	beq- keepBody		# /
	lwz r3, 0xc(r1)
	andi. r0, r3, 0x3		# \ 
	cmpwi r0, 0x3			# | check if attack + special is pressed
	bne+ notSelfDestruct	# /
destructSelf:
	li r4, 5
	b selfDestruct
notSelfDestruct:

	lwz r10, 0x0(r25)    # \
    lbz r10, 0x18(r10)  # | Check if ftOwner->ftOwnerData->fighterSubColor >= 0
	extsb. r10, r10		# |
	bge+ skipPump		# /
notSubColor:
	%lwd (r11, g_GameGlobal)	# \
	lwz r11, 0x8(r11)			# | GameGlobal->globalModeMelee->meleeInitData.stageKind
	lhz r11, 0x1a(r11)			# /
	cmpwi r11, 0x3d			# \ check if stage id == adventure
	beq+ noStageOverlay		# /
	%lwdu(r12, r9, STAGEEX_COLOR_OVERLAY)
	andi. r12, r12, 0xFF	# Check alpha settings
	bne- skipPump			# If the alpha was clear, then behave normally and do not provide an overlay
noStageOverlay:
	
	lwz r3, 0xd8(r28)	# \
	lwz r3, 0xAC(r3)	# |
	lwz r12, 0x0(r3)	# | moduleAccesser->moduleEnumeration->colorBlendModule->getSubColor()
	lwz r12, 0x50(r12)	# |
	mtctr r12			# |
	bctrl 				# /
	stw r3, 0x10(r1)
	rlwinm. r4,r3,24,24,31
	andi. r3, r3, 0xff	# get sub color alpha channel
	li r5, 0xFF		# set sub color to white (default)
	cmpwi r4, 1					# \ check sub color to determine whether in recovery
	bne+ checkForCrashBreaker	# /
recovery:
	cmpwi r3, 0x1		# \ check if finished recovery
	beq+ finalRecovery	# / 
	li r5, 1			# set sub color to black
finalRecovery:
	subi r3, r3, 0x1	# decrement alpha channel
	stb r5, 0x10(r1)
	stb r5, 0x11(r1)
	stb r5, 0x12(r1)
	stb r3, 0x13(r1)
	b changeColor
checkForCrashBreaker:
	lwz r11, 0xc(r1)

	li r12, 2			# \
	divw r12, r3, r12	# |
	mulli r12, r12, 2	# | alpha % 2 to check if even/odd to determine whether to next press button or not to increment crash breaker / alpha channel
	subf r12, r12, r3	# |
	cmpwi r12, 0x0		# |
	beq+ isEven			# /
isOdd:
	andi. r0, r11, 0x2	# \ check if not pressing Special
	bne+ decreasePump 	# /
	b increasePump
isEven:
	andi. r0, r11, 0x2	# \ check if pressing Special
	beq+ decreasePump 	# /
increasePump:
	addi r3, r3, 0x9
	beq+ updateColor
decreasePump:
	cmpwi r3, 0x1
	ble+ skipPump 
	subi r3, r3, 0x2
updateColor:
	stb r3, 0x13(r1)
	cmpwi r3, 0xF0
	blt+ belowCrashBreaker
	li r5, 1		# set sub color to black
belowCrashBreaker:
	stb r5, 0x10(r1)
	stb r5, 0x11(r1)
	stb r5, 0x12(r1)

	blt+ changeColor
	lwz r12, 0xd8(r28)	# \
	lwz r12, 0xc(r12)	# | &moduleAccesser->moduleEnumeration->postureModule->pos
	addi r4, r12, 0xc	# /
	lfs f1, 0x40(r12)	# postureModule->lr
	%lwd (r3, g_itManager)
	li r5, 0x06		# \ Spawn Bob-omb sudden death variant
	li r6, 0x1		# /
	li r7, -1
	li r8, 0
	li r9, 0
	andi. r10, r7, 0xFFFF
	stw r8, 0x8(r1)
	stw r10, 0xc(r1)
	%call (itManager__createItem)

	cmpwi r3, 0x0
	beq+ changeColor 
	stw r3, 0x8(r1)
	
	li r4, 7			# \
	lwz r5, 0x60(r3)	# |
	lwz r3, 0xd8(r5)	# |
	lwz r3, 0x70(r3)	# | item->moduleAccesser->moduleEnumeration->statusModule->changeStatusForce(7, moduleAccesser)
	lwz r12, 0x0(r3)	# | Change Bob-omb status so that it immediately explodes on spawn
	lwz r12, 0x90(r12)	# |
	mtctr r12			# |
	bctrl				# /
	
	lwz r10, 0xd8(r28)		# moduleAccesser->moduleEnumeration
	lwz r8, 0x4(r10)		# \ moduleEnumeration->modelModule->modelScale
	lfs f0, 0x4C(r8)		# /
	lwz r8, 0xc(r10)		# \ moduleEnumeration->postureModule->baseScale
	lfs f1, 0x3c(r8)		# /
	fmuls f0, f0, f1		# Multiply modelScale with baseScale
	lis r4, 0x4000			# \ 
	stw r4, 0xc(r1)			# | 2.0x multiplier
	lfs f2, 0xc(r1)			# |
	fmuls f1, f0, f2		# /

	lwz r3, 0x8(r1)		# \
	lwz r3, 0x60(r3)	# \
	lwz r3, 0xd8(r3)	# |
	lwz r3, 0xc(r3)		# |
	lwz r12, 0x0(r3)	# | baseItem->moduleAccesser->moduleEnumeration->postureModule->setScale(scale)
	lwz r12, 0x64(r12)	# |
	mtctr r12			# |
	bctrl 				# /

	# lis r4, 0x3FA0		# \ 
	# stw r4, 0xc(r1)		# | 1.25x multiplier
	# lfs f1, 0xc(r1)		# /
	# lwz r3, 0x8(r1)		# \
	# lwz r3, 0x60(r3)	# |
	# lwz r3, 0xd8(r3)	# |
	# lwz r3, 0x1c(r3)	# | baseItem->moduleAccesser->moduleEnumeration->attackModule->setPowerMul(2.0)
	# lwz r12, 0x0(r3)	# |
	# lwz r12, 0xC8(r12)	# | 
	# mtctr r12			# |
	# bctrl 				# /

	lwz r3, 0x8(r1)
	mflr r0 
	stw r0, 0x8(r1) 
	bl explode
explodeAttackData:
	word 0x23	# power 
	word 0x0	# \
	word 0x0	# | offsetPos (0.0, 0.0, 0.0)
	word 0x0	# /
	word 0x4119999a # size (9.6)
	word 0x169	# vector
	word 0x1E	# reactionEffect
	word 0x0	# reactionFix
	word 0x5A	# reactionAdd
	word 0x0	# tripRate (0.0)
	word 0x3F800000	# hitStopMultiplier (1.0)
	word 0x3F800000	# sdiMultiplier (1.0)
	word 0x007FEDE5
	word 0x96014000
	word 0x00106100
	word 0x00000000

explode:
	mflr r6 			# \
	li r4, 0			# |
	li r5, 0			# |
	lwz r3, 0x60(r3)	# |
	lwz r3, 0xd8(r3)	# |
	lwz r3, 0x1c(r3)	# | item->moduleAccesser->moduleEnumeration->attackModule->set(0, 0, &attackData)
	lwz r12, 0x0(r3)	# |
	lwz r12, 0x24(r12)	# |
	mtctr r12			# |
	bctrl 				# /

	lwz r0, 0x8(r1)
	mtlr r0

changeColor:
	addi r4, r1, 0x10	# \
	li r5, 0x1 			# |
	lwz r3, 0xd8(r28)	# |
	lwz r3, 0xAC(r3)	# |
	lwz r12, 0x0(r3)	# | moduleAccesser->moduleEnumeration->colorBlendModule->setSubColor(&color, true)
	lwz r12, 0x48(r12)	# |
	mtctr r12			# |
	bctrl				# /

skipPump:
	mr r3, r26
	%call (soExternalValueAccesser__getStatusKind)
	cmpwi r3, 0x4D
	bne+ end
	lbz r3, 0x10(r1)	# \
	cmpwi r3, 0x1 		# | check if subcolor is 1 
	beq+ noSmashbreaker	# /
	lbz r3, 0x13(r1)	# \ check if subColor alpha is <= 1
	cmpwi r3, 0x1		# | extend destruct requirement until lying down anim is finished
	ble+ noSmashbreaker	# /
	lwz r3, 0xd8(r28)	# \
	lwz r3, 0x8(r3)		# |
	lwz r12, 0x0(r3)	# | moduleAccesser->moduleEnumeration->motionModule->getEndFrame()
	lwz r12, 0x44(r12)	# |
	mtctr r12			# |
	bctrl 				# /
	stfs f1, 0x8(r1)

	lwz r3, 0xd8(r28)	# \
	lwz r3, 0x8(r3)		# |
	lwz r12, 0x0(r3)	# | moduleAccesser->moduleEnumeration->motionModule->getFrame()
	lwz r12, 0x38(r12)	# |
	mtctr r12			# |
	bctrl 				# /
	lfs f2, 0x8(r1)				# \
	fsubs f1, f2, f1			# |
	%lf (f0, r12, _float_1_0)	# | check if (endFrame - frame > 1.0) 
	fcmpo cr0, f1, f0			# |
	bgt+ end					# /
noSmashbreaker:
	mr r3, r25			# \
	lwz r12, 0xc(r3) 	# |
	lwz r12, 0xc(r12)	# | ftOwner->isSubOwner()
	mtctr r12			# |
	bctrl 				# /
	cmpwi r3, 0x1		# \ check if subOwner (i.e. clone)
	beq- destructSelf	# /

	lwz r25, 0x0(r25) 
    lwz r10, 0x34(r25)  # \
    cmplwi r10, 0x1     # | Check if ftOwnerData->stockCount == 0
    blt+ keepBody   	# /
destruct:
	li r4, 6			# \ 
selfDestruct:
	mr r3, r26          # |
    lwz	r12, 0x3C(r26)  # | 
	lwz r12, 0x280(r12)	# | fighter->toDead(5/6)
	mtctr r12			# |
	bctrl				# /
	b end
keepBody:	
	li r4, 0			# \
	li r5, -1			# |
	lwz r3, 0xd8(r28)	# |
	lwz r3, 0x60(r3)	# |	
	lwz r12, 0x0(r3)	# | moduleAccesser->moduleEnumeration->cameraModule->setEnableCamera(0, -1)
	lwz r12, 0x38(r12)	# |
	mtctr r12			# |
	bctrl				# /
end:
	lis	r3, 0x80B8		# Original operation
}
HOOK @ $8083b310	# Fighter::toDead
{
	li r4, 0x28				# \
	lwz r3, 0xd8(r29)		# |
	lwz r3, 0x88(r3)		# |
	lwz r12, 0x0(r3)		# | moduleAccesser->moduleEnumeration->effectModule->removeCommon(0x28)
	lwz r12, 0xA4(r12)		# | 
	mtctr r12				# |
	bctrl					# /

	mr r3, r26         	# \
    lwz	r12, 0x3C(r26) 	# |
    lwz	r12, 0x2EC(r12) # | Fighter->getOwner()
    mtctr r12         	# |
    bctrl               # /
	li r5, 0x0 			# \ 
	stw r5, 0x8(r1)		# | Set no subcolor by default
	addi r4, r1, 0x8	# /
	lwz r10, 0x0(r3)    # \
    lbz r10, 0x18(r10)  # | Check if ftOwner->ftOwnerData->fighterSubColor >= 0
	extsb. r10, r10		# |
	blt+ notSubColor	# /
	%lwd (r9, g_ftDataCommon)	# \
	lwz r9, 0x48(r9)			# |
	mulli r10, r10, 0x4			# | Get sub color
	add r4, r10, r9				# |
	li r5, 0x1 					# /
notSubColor:
	%lwdu(r12, r9, STAGEEX_COLOR_OVERLAY)
	andi. r12, r12, 0xFF	# Check alpha settings
	beq- noStageOverlay		# If the alpha was clear, then behave normally and do not provide an overlay
	%lwd (r11, g_GameGlobal)	# \
	lwz r11, 0x8(r11)			# | GameGlobal->globalModeMelee->meleeInitData.stageKind
	lhz r11, 0x1a(r11)			# /
	cmpwi r11, 0x3d			# \ check if stage id == adventure
	beq+ noStageOverlay		# /
	mr r4, r9				# Use stage colour overlay
	li r5, 1				# Enable overlay
noStageOverlay:
	lwz r3, 0xd8(r29)	# |				
	lwz r3, 0xAC(r3)	# | moduleEnumeration->colorBlendModule->setSubColor(&color, false)
	lwz r12, 0x0(r3)	# | 
	lwz r12, 0x48(r12)	# |
	mtctr r12			# |
	bctrl				# /
	lis	r4, 0x80AD	# Original operation
}
HOOK @ $807c976c	# soColorBlendModuleImpl::setSubColor
{
	stb	r30, 0x150(r26)	# Original operation
	sth r30, 0x14a(r26)	# \ initialize subcolor to 0
	sth r30, 0x14c(r26)	# /
}

HOOK @ $8087c464	# ftStatusUniqProcessDead::initStatus
{
	lwz r12, 0xd0(r12)	# \
	mtctr r12			# | cameraModule->getSubject(0)
	bctrl 				# /
	cmpwi r3, 0x0		# \
	beq+ noSubject		# |
	lbz r3, 0x0(r3)		# | store whether camera is enabled on stack
noSubject:				# |
	stb r3, 0x78(r1)	# /
	lwz r3, 0xD8(r27)	# \
	li r4, 0			# |
	lwz r3, 0x60(r3)	# | Original operation
	lwz r12, 0x0(r3)	# |
	lwz r12, 0x34(r12)	# /
}
HOOK @ $8087c7f4	# ftStatusUniqProcessDead::initStatus
{
	lbz r12, 0x78(r1)		# \
	andi. r12, r12, 0x80	# | check if camera is enabled from storage on stack
	bne+ end				# /
	%lwi(r4, 0x12000018)	# \
	lwz r3, 0xd8(r27)		# |
	lwz r3, 0x64(r3)		# | moduleAccesser->moduleEnumeration->workModule->isFlag(0x12000018)
	lwz r12, 0x0(r3)		# |
	lwz r12, 0x4C(r12)		# |
	mtctr r12				# |
	bctrl					# /
	cmpwi r3, 0x0	# \ check if knocked out
	beq+ end 		# /
	%branch(0x8087c810)	# skip setting temporary camera upon blastzone death
end:
	fmr	f1, f31		# Original operation
}
HOOK @ $8087dbe4	# ftStatusUniqProcessDead::exitStatus
{
	lwz r3, 0xd8(r30)		# \
	lwz r3, 0x64(r3)		# |
	%lwi (r4, 0x12000018)	# |
	lwz r12, 0x0(r3)		# | moduleAccesser->moduleEnumeration->workManageModule->offFlag(0x12000018)
	lwz r12, 0x54(r12)		# | 
	mtctr r12				# |
	bctrl					# /
	lwz r3, 0xd8(r30)	# Original operation
}

HOOK @ $80948494	# stLoaderPlayer::entryEntityRebirth
{
	lhz	r4, 0x22(r30)	# Original operation (playerInitData->startDamage)
	lbz r12, 0x1C(r30)	# \
	extsb. r12, r12		# | Check if stamina
	bge+ %end%			# /
	lhz r4, 0x24(r30)	# playerInitData->hitPointMax
}

HOOK @ $80816088	# ftManager::setDead
{
	cmpwi r24, 0x5;  bne- addDeadCount
	lwz r10, 0x0(r29)   # \
    lwz r10, 0x34(r10) 	# | Check if ftOwner->ftOwnerData->stockCount <= 1
    cmplwi r10, 0x1     # /
	bgt+ %end%		# Skip adding to dead count
addDeadCount:
	addi r4, r4, 1	# Original operation
}
HOOK @ $80816108	# ftManager::setDead
{
	cmpwi r24, 0x5;  bne- loc_0x1C
	lwz r10, 0x0(r29)   # \
    lwz r10, 0x34(r10) 	# | Check if ftOwner->ftOwnerData->stockCount <= 1
    cmplwi r10, 0x1     # /
	ble+ loc_0x1C
   	addi r3, r3, 0x1	# Counteract subtracting stock (will be done in toDead later)
loc_0x1C:
  	subic. r21, r3, 1	# Original operation
}

HOOK @ $8083bb58	# Fighter::toKnockOut
{
	%lwd (r12, g_ftManager)	# \
	lbz r12, 0x6a(r12)		# | check if g_ftManager->gameRule is coin mode
	cmpwi r12, 0x2 			# |
	bne+ notCoinMode		# /
	# Remove coins on knockout
	%lwi (r3, g_ftStatusUniqProcessDead)
	mr r4, r30
	%call (ftStatusUniqProcessDead__decCoin)
	stw r3, 0x8(r1)
	mr r3, r29
	%lwi (r4, 0x10000000)
	%call (soExternalValueAccesser__getWorkInt)
	mr r4, r3
	%lwd (r3, g_ftManager)
	%call (ftManager__getOwner)
	%call (ftOwner__isDropOnlyBill)
	mr r9, r3
	lwz r7, 0x8(r1)
	%lwd (r3, g_itManager)
	li r12, 0x0				# \
	stw r12, 0x8(r1)		# |
	%lwi (r12, 0x3f800000)	# | Speed [0.0, 1.0]
	stw r12, 0xc(r1)		# /
	lwz r4, 0x28(r29)		# fighter->taskId
	lwz r12, 0xd8(r30)	# \
	lwz r12, 0xc(r12)	# | &moduleAccesser->moduleEnumeration->postureModule->pos
	addi r5, r12, 0xc	# /
	addi r6, r1, 0x8	
	li r8, 0x1			
	%call (itManager__createMoney)
notCoinMode:	
	mr r3, r29          # \
    lwz	r12, 0x3C(r29)  # |
    lwz	r12, 0x2EC(r12) # | Fighter->getOwner()
    mtctr r12           # |
    bctrl               # /
	lwz r10, 0x0(r3)    # \
    lwz r10, 0x34(r10) 	# | Check if ftOwner->ftOwnerData->stockCount > 1
    cmplwi r10, 0x1     # /
	lwz	r6, 0xD8(r30)	# \ Original operation
	mr r3, r30			# /
}
op bgt+ 0xC4 @ $8083bb5c	# Skip slowdown and setting beat/sd
HOOK @ $8083bb88	# Fighter::toKnockOut
{
	#mr r4, r3	# Original operation
	#stw r4, 0x30(r1)	# Store configured slowStrength
	li r28, 60
	li r4, 5
}
op lwz r12, 0x2c(r12) @ $8083bb94	# call soSlowModule->set instead of setSlow
HOOK @ $8083bbb8	
{
	bctrl	# Original operation
	lwz r3, 0xc(r1)
	%call (gfTask__getTask)
	cmpwi r3, 0x0
	beq- %end% 
	li r4, 5
	#lwz r4, 0x30(r1)	# \
	mr r5, r28			# |
	lwz r3, 0x60(r3)	# |
	lwz r3, 0xd8(r3)	# |
	lwz r3, 0xB8(r3)	# | stageObject->moduleAccesser->moduleEnumeration->slowModule->set(slowStrengh, duration)
	lwz r12, 0x8(r3)	# |
	lwz r12, 0x2c(r12)	# |
	mtctr r12			# |
	bctrl				# /
}

HOOK @ $8095869c	# stOperatorRuleMelee::doStockGift
{
	mr r17, r3	# Original operation
	mr r4, r17
	%lwd (r3, g_ftManager)
    li r5, -1
    %call (ftManager__getFighter)
    cmpwi r3, 0x0
	beq+ end
	%call (soExternalValueAccesser__getStatusKind)
	cmpwi r3, 0x10B
end:
	lwz	r3, 0x7C28(r20)	# Orginal operation
}
op bne+ 0x68 @ $809586a0	# Skip stock gift if they aren't inactive

op nop @ $8083bffc	# Fighter::notifyEventChangeStatus	# allow knocked out fighter to be grabbed
op nop @ $8083dba0	# Fighter::notifyEventLink 	\ allow knocked out fighter to touch items
op nop @ $80844364	# Fighter::touchItem 		/

op b -0x28 @ $806df0fc

op li r3, 0x0 @ $80816090
op li r0, 0x0 @ $8083B844
#op nop @ $806DF0FC
op li r3, 0x40 @ $809559F0
op nop @ $80947370
op li r0, 0x0 @ $806A5C78
op li r0, 0x0 @ $806A8570
op b 0x8 @ $806DEB3C
op b 0xC @ $806DEDF0
op li r0, 0x0 @ $8068F04C
op li r0, 0x0 @ $8068F290
op li r0, 0x0 @ $80690754
op li r29, 0x64 @ $806A0350
op li r30, 0x64 @ $8069F3D4
op li r30, 0x64 @ $8069F898
op li r31, 0x64 @ $8069FDD4
op li r0, 0x0 @ $800E5B94
op nop @ $806eeb8c
op nop @ $8083bc6c	# don't turn off catch check in collisionHitModule

HOOK @ $806df0e4	# sqSpMelee::setupSpMelee
{
	sth	r3, 0xBA(r6)	# Original operation
	lbz r0, 0x7(r26)	# gmSetRule->stageChoice
	lbz r12,0x29(r27)
  	cmpwi r0, 0x1;  beq- noBlastZones
  	cmpwi r0, 0x2;  beq- normalKnockbackNoBlastZones
  	cmpwi r0, 0x3;  beq- normalKnockback
  	cmpwi r0, 0x4;  bne+ %end%
	lbz r11, 0xB(r27)	# \
	ori r11, r11, 0x80	# | Set camera stabilization
	stb r11, 0xB(r27)	# /
normalKnockbackNoBlastZones:
  	ori r12, r12, 0xc0
	b storeSetting
noBlastZones:
  	ori r12, r12, 0x40
	b storeSetting
normalKnockback:
	ori r12, r12, 0x80
storeSetting:
    stb r12,0x29(r27)
}

HOOK @ $8005542C	# gmSetRuleSelStage
{
  lwz r6, 0x10(r4)	# Original operation
  lbz r12, 0x18(r3)	# \ 
  cmpwi r12, 0x2	# | Check if gmSetRule->spMeleeSetting1 is stamina
  bne- %end%		# /
  li r0, 0x0		# Set stage choice to pick
}

* 046873B0 38000000

#########################################################
# Stamina Behaviour is Defined Individually Per Fighter #
#########################################################
CODE @ $80861c38    # ftOutsideEventPresenter::notifyOutsideEventSetDamage
{
    lwz r10, 0x0(r3)    # \
    lwz r10,0x8(r10)    # |  Check if ftOwner->ftOwnerData->hitPointMax was set  
    cmpwi r10, 0x0      # |
    beq- 0x18           # /
}

CODE @ $808619a0    # ftOutsideEventPresenter::addDamage
{
    lwz r10, 0x0(r3)    # \
    lwz r10,0x8(r10)    # |  Check if ftOwner->ftOwnerData->hitPointMax was set  
    cmpwi r10, 0x0      # |
    beq- 0x18           # /
}

CODE @ $808616ac    # ftOutsideEventPresenter::onDamage
{
    lwz r10, 0x0(r3)    # \
    lwz r10,0x8(r10)    # |  Check if ftOwner->ftOwnerData->hitPointMax was set  
    cmpwi r10, 0x0      # |
    beq- 0x18           # /
}

CODE @ $80843354    # Fighter::setCurry
{
    lwz	r12, 0x3C(r3)   # \
    lwz	r12, 0x2EC(r12) # | Fighter->getOwner()
    mtctr r12           # |
    bctrl               # /
    lwz r10, 0x0(r3)    # \
    lwz r10,0x8(r10)    # | Check if ftOwner->ftOwnerData->hitPointMax was set  
    cmpwi r10, 0x0      # |
    beq- 0x58           # /
}

CODE @ $80840dcc    # Fighter::notifyEventAddDamage
{
    mr r3, r31         	# \
    lwz	r12, 0x3C(r3)   # |
    lwz	r12, 0x2EC(r12) # | Fighter->getOwner()
    mtctr r12           # |
    bctrl               # /
    lwz r10, 0x0(r3)    # \
    lwz r10,0x8(r10)    # | Check if ftOwner->ftOwnerData->hitPointMax was set  
    cmpwi r10, 0x0      # |
    beq- 0x58           # / 
}

CODE @ $80840c40 # Fighter::notifyEventOnDamage
{
    mr r3, r29          # \
    lwz	r12, 0x3C(r3)   # |
    lwz	r12, 0x2EC(r12) # | Fighter->getOwner()
    mtctr r12           # |
    bctrl               # /
    lwz r10, 0x0(r3)    # \
    lwz r10,0x8(r10)    # | Check if ftOwner->ftOwnerData->hitPointMax was set  
    cmpwi r10, 0x0      # |
    beq- 0x58           # /  
}

HOOK @ $8085ccf8	# ftDamageTransactorImpl::getDamageForReaction
{
	stfs f1, 0x8(r1)	# Store float on stack
    lwz r3, 0x8(r4)    	# \
    lwz	r12, 0x3C(r3)   # |
    lwz	r12, 0x2EC(r12) # | Fighter->getOwner()
    mtctr r12           # |
    bctrl               # /
	lwz r12, 0x0(r3)    # \
	li r3, 0x0			# |
    lwz r12,0x8(r12)    # | Check if ftOwner->ftOwnerData->hitPointMax was set  
    cmpwi r12, 0x0      # |
	beq- notStamina		# /
	li r3, 0x1
notStamina:
	lfs f1, 0x8(r1)		# Restore float
	mr r4, r31			# Restore moduleAccesser to be in r4
	%lwd (r12, g_GameGlobal)
  	lwz r12, 0x8(r12)
  	lbz r11, 0x29(r12)
  	andi. r11, r11, 0x80
	beq+ %end%
  	li r3, 0x0
}

###############################
# Revive Knockedout Opponents #
###############################
HOOK @ $80840e08 	# Fighter::notifyEventAddDamage
{
	fcmpo cr0,f1,f0	# Original operation
	blt+ %end%		# Skip if health is below 1.0
	mr r3, r31										# \
	%lwi (r4, 0x12000018)							# |
	%call (soExternalValueAccesser__getWorkFlag)	# | Check if knocked out
	cmpwi r3, 0x0									# |
	beq+ end										# /
	mr r3, r31         	# \
    lwz	r12, 0x3C(r3)   # |
    lwz	r12, 0x2EC(r12) # | Fighter->getOwner()
    mtctr r12           # |
    bctrl               # /
	mr r29, r3
	lwz r12, 0xc(r3) 	# \
	lwz r12, 0xc(r12)	# | ftOwner->isSubOwner()
	mtctr r12			# |
	bctrl 				# /
	cmpwi r3, 0x1		# \ check if subOwner (i.e. Nana)
	beq- isSubOwner		# /
	lwz r3, 0x0(r29)		# \
	lwz r10, 0x34(r3) 		# |
	cmpwi r10, 0x0			# |
	bne+ hasStocksRemaining	# | Set stock count to 1 if zero stocks
	addi r10, r10, 0x1		# |
	stw r10, 0x34(r3)		# |
hasStocksRemaining:			# /
	%lwd (r3, g_ftManager)			# \
	lwz r4, 0x10C(r31)				# | ftManager->getPlayerNo(fighter->entryId)
	%call (ftManager__getPlayerNo)	# /
	%lwd (r12, g_GameGlobal)	# \
	lwz r12, 0x8(r12)			# | 
	mulli r3, r3, 92			# | playerId = g_GameGlobal->globalModeMelee.playerInitData[playerNo].playerId
	add r12, r12, r3			# |
	lbz r3, 0x9A(r12)			# /
	%lwd (r12, g_IfMngr)		# \
	add r11, r12, r3			# |
	lbz r3, 0x68(r11)			# | g_IfMngr->ifPlayers[g_ifMngr->field_0x68[playerId]]
	mulli r3, r3, 4				# | 
	add r3, r3, r12				# |
	lwz r3, 0x4C(r3)			# /
	li r4, 3					
	%call (IfPlayer__setDamageState)
isSubOwner:	
	mr r3, r31										# \
	%call (soExternalValueAccesser__getStatusKind)	# |
	cmpwi r3, 0x4D									# | Check if lying down
	mr r5, r30										# |
	lwz r30, 0xd8(r30)								# |
	bne+ notLyingDown								# /
	li r4, 0x51			# \
	lwz r3, 0x70(r30)	# |	
	lwz r12, 0x0(r3)	# | moduleEnumeration->statusModule->changeStatusRequest(0x51, moduleAccesser)
	lwz r12, 0x14(r12)	# | Force getup since can't input anything while lying down and then revived
	mtctr r12			# |
	bctrl				# /
notLyingDown:
	li r5, 0x0 			# \ 
	stw r5, 0x8(r1)		# | Set no subcolor by default
	addi r4, r1, 0x8	# /
	lwz r10, 0x0(r29)   # \
    lbz r10, 0x18(r10)  # | Check if ftOwner->ftOwnerData->fighterSubColor >= 0
	extsb. r10, r10		# |
	blt+ notSubColor	# /
	%lwd (r9, g_ftDataCommon)	# \
	lwz r9, 0x48(r9)			# |
	mulli r10, r10, 0x4			# | Get sub color
	add r4, r10, r9				# |
	li r5, 0x1 					# /
notSubColor:
	%lwdu(r12, r9, STAGEEX_COLOR_OVERLAY)
	andi. r12, r12, 0xFF	# Check alpha settings
	beq- noStageOverlay		# If the alpha was clear, then behave normally and do not provide an overlay
	%lwd (r11, g_GameGlobal)	# \
	lwz r11, 0x8(r11)			# | GameGlobal->globalModeMelee->meleeInitData.stageKind
	lhz r11, 0x1a(r11)			# /
	cmpwi r11, 0x3d			# \ check if stage id == adventure
	beq+ noStageOverlay		# /
	mr r4, r9				# Use stage colour overlay
	li r5, 1				# Enable overlay
noStageOverlay:
	lwz r3, 0xAC(r30)	# | moduleEnumeration->colorBlendModule->setSubColor(&color, false)
	lwz r12, 0x0(r3)	# | 
	lwz r12, 0x48(r12)	# |
	mtctr r12			# |
	bctrl				# /
	lwz r3, 0x64(r30)		# \
	%lwi (r4, 0x12000018)	# |
	lwz r12, 0x0(r3)		# | moduleEnumeration->workManageModule->offFlag(0x12000018)
	lwz r12, 0x54(r12)		# | 
	mtctr r12				# |
	bctrl					# /
	li r4, 0x28				# \
	lwz r3, 0x88(r30)		# |
	lwz r12, 0x0(r3)		# | moduleEnumeration->effectModule->removeCommon(0x28)
	lwz r12, 0xA4(r12)		# | 
	mtctr r12				# |
	bctrl					# /
	li r4, 0x0			# \
	lwz r3, 0x5c(r30)	# |
	lwz r12, 0x0(r3)	# | moduleEnumeration->controllerModule->setOff(false)
	lwz r12, 0xb4(r12)	# |
	mtctr r12			# |
	bctrl 				# /
	li r4, 1			# \
	li r5, -1			# |
	lwz r3, 0x60(r30)	# |	
	lwz r12, 0x0(r3)	# | moduleEnumeration->cameraModule->setEnableCamera(1, -1)
	lwz r12, 0x38(r12)	# |
	mtctr r12			# |
	bctrl				# /
end:
	cmplwi r30, 0x0	# Operation to force bge+
}

HOOK @ $80844700	# Fighter::touchItem
{
	stfs f1, 0x8(r1)	# Store damage
	mr r3, r25
	%lwi (r4, 0x12000018)
	%call (soExternalValueAccesser__getWorkFlag)
	cmpwi r3, 0
	beq+ end

	mr r3, r25         	# \
    lwz	r12, 0x3C(r25) 	# |
    lwz	r12, 0x2EC(r12) # | Fighter->getOwner()
    mtctr r12         	# |
    bctrl               # /
	lwz r10, 0x0(r3) 	# \
    lwz r0, 0x8(r10)   	# | Check if ftOwner->ftOwnerData->hitPointMax was set  
    cmpwi r0, 0x0      	# |
    beq+ end          	# /
	lfs f1, 0x8(r1)		# \
	lfs f2, 0x8(r10)	# |
	fsubs f1, f1, f2	# | amountNeededToBeAlive = damage - hitPointMax + 1 (guarantee a revive)
	fadds f1, f1, f0 	# /
	fmuls f31,f2,f31	# Multiply hitPointMax with multiplier
	fadds f31,f1,f31	# healAmount = amountNeededToBeAlive + fractionOfHitPointMax
	b %end%
end:
	lfs f1, 0x8(r1)
	fmuls f31,f1,f31	# Original operation
}
HOOK @ $808449c8	# Fighter::touchItem
{
	fmuls f31,f1,f31	# Original operation
	mr r3, r25
	%lwi (r4, 0x12000018)
	%call (soExternalValueAccesser__getWorkFlag)
	cmpwi r3, 0
	beq+ %end%
	mr r3, r25         	# \
    lwz	r12, 0x3C(r25) 	# |
    lwz	r12, 0x2EC(r12) # | Fighter->getOwner()
    mtctr r12         	# |
    bctrl               # /
	mr r23, r3
	li r4, 0			# \
	lwz r3, 0xD8(r28)	# |
	lwz r3, 0x38(r3)	# |
	lwz r12, 0x8(r3)	# | moduleAccesser->moduleEnumeration->damageModule->getDamage(0)
	lwz r12, 0x50(r12)	# |
	mtctr r12			# |
	bctrl 				# /	
	%lf (f0, r12, _float_1_0)
	lwz r10, 0x0(r23) 	# \
    lwz r0, 0x8(r10)   	# | Check if ftOwner->ftOwnerData->hitPointMax was set  
    cmpwi r0, 0x0      	# |
    beq+ %end%          # /
	lfs f2, 0x8(r10)	# \
	fsubs f1, f1, f2	# | amountNeededToBeAlive = damage - hitPointMax + 1 (guarantee a revive)
	fadds f1, f1, f0 	# /
	fadds f31, f1, f31	# amountHeal += amountNeededToBeAlive
}

##########################################
# P+ Stamina X/Y world wrap option REDUX #
##########################################

HOOK @ $8083aa54	# Fighter::processFixCamera
{
	lwz r4, 0x10C(r30)  # fighter->entryId
    %lwd(r3, g_ftEntryManager)
    %call(ftEntryManager__getEntity)
	lwz r12, 0x4c(r3)			# \
	cmpwi r12, 0x0				# | check if ftEntry->instances[3].fighter == NULL i.e. no double
	bne+ disableMagnifierGlass	# /

	mr r3, r30          # \
    lwz	r12, 0x3C(r3)   # |
    lwz	r12, 0x2EC(r12)	# | Fighter->getOwner()
    mtctr r12           # |
    bctrl               # /
	lwz r10, 0x0(r3)    # \
    lwz r10,0x8(r10)    # | Check if ftOwner->ftOwnerData->hitPointMax was set  
    cmpwi r10, 0x0      # |
	beq+ end			# /
	lwz r10, 0x0(r3)			# \
	lwz r10, 0x34(r10)			# | check if ftOwner->ftOwnerData->stockCount == 0
	cmplwi r10, 0x0      		# |
	beq+ disableMagnifierGlass	# /
	%lwd (r12, g_GameGlobal)	# \
  	lwz r12, 0x8(r12)			# |
  	lbz r11, 0x29(r12)			# | Check if world wrap is enabled
  	andi. r11, r11, 0x40		# |
	beq+ end					# /
	
	mr r3, r30										# \
	%lwi (r4, 0x12000018)							# |
	%call (soExternalValueAccesser__getWorkFlag)	# | Check if knocked out
	cmpwi r3, 0										# |
	bne- end										# /
	mr r3, r30
	%call (soExternalValueAccesser__getStatusKind)
	mr r29, r3
	cmpwi r3,0xBC	# \ check if drowning
	beq- end 		# /
	cmpwi r3,0xBE	# \ check if respawning
	beq- end 		# /
	cmpwi r3,0xC6	# \ check if eaten by Summit fish
	beq- end 		# /
	cmpwi r3,0xDC	# \ check if warp star
	beq- end		# /
	cmpwi r3,0xF1	# \ check if Kirby/MK uthrow 
	beq- end 		# /
	cmpwi r3,0x116	# \ check if Final Smash
	beq- end 		# /
	cmpwi r3, 0x10E # \ check if entrance
	beq- end		# /
disableMagnifierGlass:
	%branch (0x8083ab90)	# Disable magnifier glass
end:	
	lwz	r5, 0xD8(r31)	# Original operation
}

HOOK @ $8083ade4	# Fighter::processFixCamera
{
	mr r28, r3					
	%lwd (r12, g_GameGlobal)	# \
  	lwz r12, 0x8(r12)			# | 
  	lbz r11, 0x29(r12)			# | Check if world wrap is enabled
  	andi. r11, r11, 0x40		# |
	beq+ end					# /
	mr r3, r30          # \
    lwz	r12, 0x3C(r3)   # |
    lwz	r12, 0x2EC(r12)	# | Fighter->getOwner()
    mtctr r12           # |
    bctrl               # /
	lwz r10, 0x0(r3)    # \
    lwz r10,0x8(r10)    # | Check if ftOwner->ftOwnerData->hitPointMax was set  
    cmpwi r10, 0x0      # |
	beq+ end			# /

	mr r3, r30										# \
	%lwi (r4, 0x12000018)							# |
	%call (soExternalValueAccesser__getWorkFlag)	# | Check if knocked out
	cmpwi r3, 0										# |
	bne- end										# /
	mr r3, r30
	%call (soExternalValueAccesser__getStatusKind)
	mr r29, r3
	cmpwi r3,0xBC	# \ check if drowning
	beq- end 		# /
	cmpwi r3,0xBE	# \ check if respawning
	beq- end 		# /
	cmpwi r3,0xC6	# \ check if eaten by Summit fish
	beq- end 		# /
	cmpwi r3,0xDC	# \ check if warp star
	beq- end		# /
	cmpwi r3,0xF1	# \ check if Kirby/MK uthrow 
	beq- end 		# /
	cmpwi r3,0x116	# \ check if Final Smash
	beq- end 		# /
	cmpwi r3, 0x10E # \ check if entrance
	beq- end		# /
	cmpwi r3, 0xBD  # \ 
    beq- end        # | check if dead
	cmpwi r3, 0x10B	# |
	beq- end		# /
	
	addi r3, r1, 0xc	# \
	lwz r4, 0xd8(r31)	# |
	lwz r4, 0xc(r4)		# |
	lwz r12, 0x0(r4)	# | moduleAccesser->moduleEnumeration->postureModule->getPos()
	lwz r12, 0x18(r12)	# |
	mtctr r12			# |
	bctrl 				# /

	%lwd (r4, g_Stage)	# \ g_Stage->cameraParam
	lwz r3, 0x78(r4)	# /
	lfs f0, 0x20(r3)	# \ cameraParam->centerPos
	lfs f1, 0x24(r3)	# /

	lfs f3, 0x0(r3)		# \ 
	lfs f4, 0x4(r3)		# | cameraParam->cameraRange
	lfs f5, 0x8(r3)		# |
	lfs f6, 0xc(r3)		# /
	lfs f7, 0x58(r4)	# \ 
	lfs f8, 0x5C(r4)	# | stage->deadRange
	lfs f9, 0x60(r4)	# |
	lfs f10, 0x64(r4)	# /

	fadds f3, f3, f0	# \
	fadds f4, f4, f0	# | add centerPos to camera range
	fadds f5, f5, f1	# |
	fadds f6, f6, f1	# /
	fadds f7, f7, f0	# \
	fadds f8, f8, f0	# | add centerPos to dead range
	fadds f9, f9, f1	# |
	fadds f10, f10, f1	# /

	lis r12, 0x4220		# \
	stw r12, 0x8(r1)	# | make 40.0 on stack
	lfs f2, 0x8(r1)		# /
	fadds f5, f5, f2	# \
	fsubs f6, f6, f2	# | add/subtract from cameraRange (actual camera tends to view a bit more than the range)
	lis r12, 0x41f0		# \
	stw r12, 0x8(r1)	# | make 30.0 on stack
	lfs f2, 0x8(r1)		# /
	fsubs f3, f3, f2	# |
	fadds f4, f4, f2	# /

	fcmpo cr0, f3, f7			# \
	bge+ withinLeftBlastzone	# |
	fmr f3, f7					# |
withinLeftBlastzone:			# |
	fcmpo cr0, f4, f8			# |
	ble+ withinRightBlastzone	# |
	fmr f4, f8					# |
withinRightBlastzone:			# | Ensure new cameraRange isn't past the dead range
	fcmpo cr0, f5, f9			# |
	ble+ withinTopBlastzone		# |
	fmr f5, f9					# |
withinTopBlastzone:				# |
	fcmpo cr0, f6, f10			# |
	bge+ withinBottomBlastzone	# |
	fmr f6, f10					# |
withinBottomBlastzone:			# /

	lfs f0, 0xc(r1)		# posX
	lfs f1, 0x10(r1)	# posY

	lis r12, 0x40a0		# \
	stw r12, 0x8(r1)	# | make 5.0 on stack
	lfs f2, 0x8(r1)		# /

	fcmpo cr0, f1, f6	# \
	ble- isBottom		# |
	cmpwi r28, 0x1		# |
	beq- isBottom		# |
	fcmpo cr0, f0, f3	# |
	ble- isLeft			# |
	cmpwi r28, 0x2		# |
	beq- isLeft			# | Check if fighter pos is past the boundary ranges
	fcmpo cr0, f0, f4	# |
	bge- isRight		# |
	cmpwi r28, 0x3		# |
	beq- isRight		# |
	fcmpo cr0, f1, f5	# |
	bge- isTop			# |
	cmpwi r28, 0x0		# |
	bne+ end			# /
isTop:
	li r28, 0x0
	fadds f1, f6, f2
	b newPosY
isBottom:
	li r28, 0x1
	fsubs f1, f5, f2
newPosY:
	#li r28, 5
	stfs f1, 0x10(r1)
	b setPos
isLeft:
	li r28, 0x2
	fsubs f1, f4, f2
	b newPosX
isRight:
	li r28, 0x3
	fadds f1, f3, f2
newPosX:
	#li r28, 1
	stfs f1, 0xc(r1)
setPos:
	## Prevents sticking to ground collision 
	## Known Oddities:
	# Falco side b due to how the move is designed stretches to where he is causing a screen wide hitbox

	mr r3, r30
	%call(soExternalValueAccesser__getLr)
	mr r3, r30
	addi r4, r1, 0xc
	li r5, 0x2
	%call (Fighter__warp)

	%lwd (r12, g_ftManager)	# \
	lbz r12, 0x6a(r12)		# | check if g_ftManager->gameRule is coin mode
	cmpwi r12, 0x2 			# |
	bne+ notCoinMode		# /	

	%call(randf)				# \
	%lfu(f2, r12, _float_1_0)	# | 
	lfs f3, 0x48(r12)			# |
	fmuls f1, f1, f3			# | randf()*0.2 + 1.0
	fadds f1, f1, f2			# |
	stfs f1, 0x8(r1)			# /
	
	mr r3, r30          # \
    lwz	r12, 0x3C(r3)   # |
    lwz	r12, 0x2EC(r12)	# | Fighter->getOwner()
    mtctr r12           # |
    bctrl               # /
	lwz r12, 0x0(r3)	# \ ftOwner->data->coinDropRate
	lfs f1, 0x4c4(r12)	# /
	lfs f3, 0x8(r1)
	lis r12, 0x40a0		# \
	stw r12, 0x8(r1)	# | make 5.0 on stack
	lfs f2, 0x8(r1)		# /
	fmuls f1, f1, f2	# \ multiply by coin drop rates
	fmuls f1, f1, f3	# /
	fctiwz f1, f1 		# \ convert to int
	stfd f1, 0x18(r1)	# /
	%call (ftOwner__isDropOnlyBill)
	mr r9, r3
	lwz r7, 0x1c(r1)	# get num coins
	%lwd (r3, g_itManager)
	li r12, 0x0				# \
	stw r12, 0x18(r1)		# | Speed [0.0, 0.0]
	stw r12, 0x1c(r1)		# /
	lis r11, 0x3F80		# 1.0
	lis r10, 0xbf80		# -1.0
	cmpwi r28, 0x1		
	beq- isBottomRotate 
	cmpwi r28, 0x2		
	beq- isLeftRotate	
	cmpwi r28, 0x3		
	beq- isRightRotate
isTopRotate:
	stw r11, 0x1c(r1)
	b finishedRotating
isBottomRotate:
	stw r10, 0x1c(r1)
	b finishedRotating
isLeftRotate:
	stw r10, 0x18(r1)
	b finishedRotating 
isRightRotate:
	stw r11, 0x18(r1)
finishedRotating:
	lwz r4, 0x28(r30)		# fighter->taskId
	addi r5, r1, 0xc	
	addi r6, r1, 0x18	
	li r8, 0x1			
	%call (itManager__createMoney)
	cmpwi r3, 0
	ble+ notCoinMode
	li r6, 0			
	mr r5, r3			
	lwz r4, 0x10C(r30)	# fighter->entryId
	%lwd(r3, g_ftManager)
	%call(ftManager__lostCoin)
notCoinMode:

	li r4, 0			# \
	lwz r3, 0xd8(r31)	# |
	lwz r3, 0x54(r3)	# |
	lwz r12, 0x0(r3)	# | moduleAccesser->moduleEnumeration->linkModule->getParent(0)
	lwz r12, 0x34(r12)	# |
	mtctr r12			# |
	bctrl				# /
	cmpwi r3, 0			# \ check if being held
	beq- noHeld			# /
	stw r3, 0x8(r1)
	lwz r12, 0x3c(r3)       # \ 
    lwz r12, 0xA4(r12)      # | stageObject->soGetKind()
    mtctr r12               # |
    bctrl                   # /
	cmpwi r3, 0x0		# \ check if holder is a fighter
	bne+ interruptLink	# /
	lwz r3, 0x8(r1)     # \
    lwz	r12, 0x3C(r3) 	# |
    lwz	r12, 0x2EC(r12) # | Fighter->getOwner()
    mtctr r12         	# |
    bctrl               # /
	lwz r10, 0x0(r3)    # \
    lwz r10,0x8(r10)    # | Check if ftOwner->ftOwnerData->hitPointMax was set  
    cmpwi r10, 0x0      # |
	beq- interruptLink	# /
	b noLink
noHeld:
	li r4, 0			# \
	lwz r3, 0xd8(r31)	# |
	lwz r3, 0x54(r3)	# |
	lwz r12, 0x0(r3)	# | moduleAccesser->moduleEnumeration->linkModule->getNode(0)
	lwz r12, 0x50(r12)	# |
	mtctr r12			# |
	bctrl				# /
	cmpwi r3, 0			# \ check if holding
	beq- noLink			# /
	stw r3, 0x8(r1)
	lwz r12, 0x3c(r3)       # \ 
    lwz r12, 0xA4(r12)      # | stageObject->soGetKind()
    mtctr r12               # |
    bctrl                   # /
	cmpwi r3, 0x0	# \ check if held is a fighter
	bne+ noLink		# /

	li r4, 0			
	stw r4, 0x18(r1)
	lwz r3, 0x8(r1)		# \
	lwz r3, 0x60(r3)	# |
	lwz r3, 0xd8(r3)	# |
	lwz r3, 0x5C(r3)	# |
	lwz r12, 0x0(3)		# | moduleAccesser->moduleEnumeration->controllerModule->getClatterTime(0)
	lwz r12, 0xd4(r12)	# |
	mtctr r12			# |
	bctrl 				# /
	lfs f2, 0x18(r1)	# \
	fcmpo cr0, f1, f2	# | check if clatterTime > 0 (i.e. can already break out of grab)
	bgt+ noLink			# /
	li r4, 1			# \
	lwz r3, 0xd8(r31)	# |
	lwz r3, 0x5C(r3)	# |
	lwz r12, 0x0(3)		# | moduleAccesser->moduleEnumeration->controllerModule->getTriggerCount(1)
	lwz r12, 0xa4(r12)	# |
	mtctr r12			# |
	bctrl 				# /
	cmpwi r3, 6			# \
	bge+ interruptHeldLink	# / if not pressed B within last 6 frames
	stw r3, 0x18(r1)
	li r4, 1			# \
	lwz r3, 0x8(r1)		# |
	lwz r3, 0x60(r3)	# |
	lwz r3, 0xd8(r3)	# |
	lwz r3, 0x5C(r3)	# |
	lwz r12, 0x0(3)		# | heldFighter->moduleAccesser->moduleEnumeration->controllerModule->getTriggerCount(1)
	lwz r12, 0xa4(r12)	# |
	mtctr r12			# |
	bctrl 				# /
	lwz r4, 0x18(r1)
	cmpw r3, r4		# \ if pressed B sooner than holder
	bgt+ noLink		# /
interruptHeldLink:
	lwz r3, 0x8(r1)		# \
	lwz r5, 0x60(r3)	# | heldFighter->moduleAccesser->moduleEnumeration
	lwz r3, 0xd8(r5)	# /
	b interrupt		
interruptLink:
	lwz r3, 0xd8(r31)	# \
	mr r5, r31			# |
interrupt:
	li r4, 0x40			# |
	lwz r3, 0x70(r3)	# | moduleAccesser->moduleEnumeration->statusModule->changeStatusRequest(0x40, moduleAccesser)
	lwz r12, 0x0(r3)	# | 
	lwz r12, 0x14(r12)	# |
	mtctr r12 			# |
	bctrl 				# /
noLink:
	li r4, 0			# \
	lis r12, 0x40a0		# |
	stw r12, 0x8(r1)	# |
	lfs f1, 0x8(r1)		# |
	lwz r3, 0xd8(r31)	# | 
	lwz r3, 0x38(r3)	# | moduleAccesser->moduleEnumeration->damageModule->addDamage(5.0, 0)
	lwz r12, 0x8(r3)	# | 
	lwz r12, 0x4c(r12)	# |
	mtctr r12 			# |
	bctrl				# /
noAddDamage:
	
dontWarp:
	li r28, -1
end:
	cmpwi r28, -1
	mr r4, r28
}

HOOK @ $80994d74	# BaseItem::processGameProc
{
	stw r3, 0x14(r1)	# Store check dead area
	cmpwi r3, 0		# Original operation
}
HOOK @ $80994e4c	# BaseItem::processGameProc
{
	%lwd (r12, g_GameGlobal)	# \
  	lwz r12, 0x8(r12)			# |  
  	lbz r11, 0x29(r12)			# | Check if world wrap is enabled
  	andi. r11, r11, 0x40		# |
	beq+ end					# /
	mr r3, r31 
isItem:
  	stw r3, 0x18(r1)  # baseItem
  	%call (BaseItem__getCreaterItem)
  	cmpwi r3, 0x0 
  	bne+ isItem
  	lwz r3, 0x18(r1)   # \
  	lwz r4, 0x8C8(r3)  # / itemInfo.baseItem->emitterTaskId
  	%lwd (r3, g_ftEntryManager)                     # \
  	li r5, 0                                        # |
  	%call (ftEntryManager__getEntryIdFromTaskId)    # | Check if emitterTaskId belongs to a fighter
  	cmpwi r3, 0                                     # |
  	bge- end                                   		# /

	mr r3, r31 					# \
	li r4, 0x5b6B				# |
	%call(BaseItem__getParam)	# | check if Pokemon/Assist
	andi. r3, r3, 0x0C00		# |
	bne+ end					# /

	%lwi(r4, 0x10000009)	# \
	addi r3, r31, 0x2aac	# |
	lwz r12, 0x0(r3)		# | this->workManageModule.getInt(0x10000009)
	lwz r12, 0x18(r12)		# |
	mtctr r12				# |
	bctrl					# /
	cmpwi r3, -1		
	beq+ noLifeTime		
	subi r4, r3, 0x40
	stw r4, 0x18(r1)
	%lwi(r5, 0x10000009)	# \
	addi r3, r31, 0x2aac	# |
	lwz r12, 0x0(r3)		# | this->workManageModule.setInt(life - 5, 0x10000009)
	lwz r12, 0x1C(r12)		# |
	mtctr r12				# |
	bctrl					# /
	lwz r3, 0x18(r1)	# \
	cmpwi r3, 0			# | check if lifetime is less than 0
	ble+ end			# /

noLifeTime:
	%lwd (r4, g_Stage)	# \ g_Stage->cameraParam
	lwz r3, 0x78(r4)	# /
	lfs f0, 0x20(r3)	# \ cameraParam->centerPos
	lfs f1, 0x24(r3)	# /

	lfs f3, 0x0(r3)		# \ 
	lfs f4, 0x4(r3)		# | cameraParam->cameraRange
	lfs f5, 0x8(r3)		# |
	lfs f6, 0xc(r3)		# /
	lfs f7, 0x58(r4)	# \ 
	lfs f8, 0x5C(r4)	# | stage->deadRange
	lfs f9, 0x60(r4)	# |
	lfs f10, 0x64(r4)	# /

	fadds f3, f3, f0	# \
	fadds f4, f4, f0	# | add centerPos to camera range
	fadds f5, f5, f1	# |
	fadds f6, f6, f1	# /
	fadds f7, f7, f0	# \
	fadds f8, f8, f0	# | add centerPos to dead range
	fadds f9, f9, f1	# |
	fadds f10, f10, f1	# /

	lis r12, 0x4220		# \
	stw r12, 0x18(r1)	# | make 40.0 on stack
	lfs f2, 0x18(r1)	# /
	fadds f5, f5, f2	# \
	fsubs f6, f6, f2	# | add/subtract from cameraRange (actual camera tends to view a bit more than the range)
	lis r12, 0x41f0		# \
	stw r12, 0x18(r1)	# | make 30.0 on stack
	lfs f2, 0x18(r1)	# /
	fsubs f3, f3, f2	# |
	fadds f4, f4, f2	# /

	fcmpo cr0, f3, f7			# \
	bge+ withinLeftBlastzone	# |
	fmr f3, f7					# |
withinLeftBlastzone:			# |
	fcmpo cr0, f4, f8			# |
	ble+ withinRightBlastzone	# |
	fmr f4, f8					# |
withinRightBlastzone:			# | Ensure new cameraRange isn't past the dead range
	fcmpo cr0, f5, f9			# |
	ble+ withinTopBlastzone		# |
	fmr f5, f9					# |
withinTopBlastzone:				# |
	fcmpo cr0, f6, f10			# |
	bge+ withinBottomBlastzone	# |
	fmr f6, f10					# |
withinBottomBlastzone:			# /

	lfs f0, 0x20(r1)		# posX
	lfs f1, 0x24(r1)		# posY

	lis r12, 0x40a0		# \
	stw r12, 0x18(r1)	# | make 5.0 on stack
	lfs f2, 0x18(r1)	# /

	lwz r12, 0x14(r1)
	fcmpo cr0, f1, f6	# \
	ble- isBottom		# |
	cmpwi r12, 0x1		# |
	beq- isBottom		# |
	fcmpo cr0, f0, f3	# |
	ble- isLeft			# |
	cmpwi r12, 0x2		# |
	beq- isLeft			# | Check if fighter pos is past the boundary ranges
	fcmpo cr0, f0, f4	# |
	bge- isRight		# |
	cmpwi r12, 0x3		# |
	beq- isRight		# |
	fcmpo cr0, f1, f5	# |
	bge- isTop			# |
	cmpwi r12, 0x0		# |
	bne+ end			# /
isTop:
	fadds f1, f6, f2 
	b setY 
isBottom:
	fsubs f1, f5, f2
setY:
	stfs f1, 0x24(r1)
	b setPos
isLeft:
	fsubs f1, f4, f2
	b setX
isRight:
	fadds f1, f3, f2
setX:
	stfs f1, 0x20(r1)
setPos:
	li r4, 0				# \
	li r5, -1				# |
	addi r3, r31, 0x28d4	# |
	lwz r12, 0x0(r3)		# | baseItem->cameraModule.setEnableCamera(-1, 0)
	lwz r12, 0x38(r12)		# |
	mtctr r12				# |
	bctrl					# /

	mr r3, r31
	addi r4, r1, 0x20
	%call(BaseItem__warp)

	li r3, 0x0
	%branch(0x80994e6c)

end:
	lwz	r12, 0x2C34(r31)	# Original operation
}

# [Legacy TE] New DBZ Lite with camera stabilization 2.0 [wiiztec] [wiiztec,Yohan1044] (write non-zero value to 9018F387 to toggle off)
HOOK @ $8009CB3C
{
  bctrl 
  stwu r1, -128(r1)
  stmw r2, 8(r1)
  %lwd (r12, g_GameGlobal)
  lwz r12, 0x8(r12)
  lbz r11, 0xB(r12)
  andi. r11, r11, 0x80
  beq- loc_0x180
  lis r12, 0x8049
  lbz r11, 19026(r12)
  cmpwi r11, 0x1
  bne- loc_0x180
  lis r12, 0x805B
  ori r12, r12, 0x6D20
  lis r14, 0x8058
  ori r14, r14, 0x8500
  li r7, 0x0
  li r18, 0x0

loc_0x50:
  lfsx f16, r12, r18
  lfsx f20, r14, r18
  lfs f23, -20(r14)
  fadds f24, f16, f20
  fdivs f24, f24, f23
  fadds f24, f24, f20
  fdivs f24, f24, f23
  fadds f24, f24, f20
  fdivs f24, f24, f23
  fcmpo cr0, f16, f20
  bgt- loc_0x84
  fsubs f21, f20, f16
  b loc_0x88

loc_0x84:
  fsubs f21, f16, f20

loc_0x88:
  lfs f22, -32(r14)
  cmpwi r18, 0x60
  blt- loc_0xA0
  cmpwi r18, 0x64
  bgt- loc_0xA0
  lfs f22, -28(r14)

loc_0xA0:
  cmpwi r18, 0x2C
  beq- loc_0xC0
  cmpwi r18, 0x5C
  beq- loc_0xC0
  cmpwi r18, 0x74
  beq- loc_0xC0
  cmpwi r18, 0xCC
  bne- loc_0xC4

loc_0xC0:
  lfs f22, -48(r14)

loc_0xC4:
  fcmpo cr0, f21, f22
  blt- loc_0x124
  sth r7, -22(r14)
  lbz r11, -24(r14)
  cmpwi r11, 0xDC
  beq- loc_0x11C
  lhz r15, -38(r14)
  addi r15, r15, 0x1
  sth r15, -38(r14)
  lhz r11, -42(r14)
  cmpwi r11, 0xADC
  beq- loc_0x104
  cmpwi r15, 0x22
  blt- loc_0x154
  li r15, 0xADC
  sth r15, -42(r14)

loc_0x104:
  lhz r15, -40(r14)
  addi r15, r15, 0x1
  sth r15, -40(r14)
  cmpwi r15, 0x2F
  blt- loc_0x154
  stw r7, -42(r14)

loc_0x11C:
  li r11, 0xDC
  stb r11, -24(r14)

loc_0x124:
  lbz r11, -24(r14)
  cmpwi r11, 0xAC
  beq- loc_0x154
  lhz r11, -22(r14)
  cmpwi r11, 0x778
  addi r11, r11, 0x1
  sth r11, -22(r14)
  blt- loc_0x150
  li r11, 0xAC
  stb r11, -24(r14)
  sth r7, -22(r14)

loc_0x150:
  fmr f16, f24

loc_0x154:
  stfsx f16, r14, r18
  stfsx f16, r12, r18
  addi r18, r18, 0x4
  cmpwi r18, 0xD0
  blt+ loc_0x50
  lhz r11, -36(r14)
  addi r11, r11, 0x1
  sth r11, -36(r14)
  cmpwi r11, 0x3C
  blt- loc_0x180
  stw r7, -38(r14)

loc_0x180:
  lmw r2, 8(r1)
  addi r1, r1, 0x80
}

* 045884EC 40000000
* 045884E0 40A00000
* 045884E4 3FE374BC
* 045884D0 41200000	

######################################################################
Throws Don't Cut Early for Victim Damage in Stamina [codes, DukeItOut]
######################################################################
HOOK @ $8083BCF0  # inside toKnockOut/[Fighter]/(fighter.o)
{
on_call_to_cause_death:
  lwz r12, 0x7C(r5)   # \ 
  lhz r12, 0x3A(r12)  # / path to current action
  cmpwi r12, 0x42     # if in thrown, don't call changeStatusRequest/[soStatusModuleImpl]/(so_status_module_impl.o)
  beq- thrown         # this check should eventually get hit and fail when the throw ends, properly causing the character
  bctrl               # to finally be knocked out from the stamina loss
thrown:
}
