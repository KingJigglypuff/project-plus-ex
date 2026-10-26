########################################
Final Smash Meter [MarioDox]
########################################

.alias FSMeterMax = 7200						# 2 minutes | Also must be duration of InfFace_TopN SRT anim in info.pac
.alias FSMeterLostDeath = FSMeterMax / 4		# Meter amount lost on death
.alias FSMeterGainDamageMult = 0x40440000		# Meter gained by damage dealt * this (40.0 | float to hex)
.alias FSMeterGainDamageTakenMult = 0			# Meter gained by damage taken * this (0 | float to hex)
.alias FSMeterDecay = 6							# Meter lost per frame after reaching max charge
.alias FSMeterWarnSFXAmount = FSMeterMax / 4	# Meter threshold to play warning sfx while decreasing from max charge
.alias FSMeterWarnSFXId = 0x2D
.alias FSMeterEndSFXId = 0x2E

## all of this is based of the idea that ftEntry->field_0x24 is unused
## will be split in two, using the upper half for flags (XXYY)
## X = meter decay threshold sfx flag
## Y = meter state (base,locked,ready,in-use)

op stw r31,0x0024(r3) @ $8081dd64 	# init/[ftEntry], instead of writing -1 we write 0

######################################
# Meter Main Code
######################################
HOOK @ $80823744					# process/[ftEntry]
{
	stwu r1,-0x10(r1)
	mflr r0
	stw r0,0x14(r1)
	lis r12,0x9018 					# \ access special versus option
	lbz r12,-0xC81(r12)				# / "Fixed camera"
	cmpwi r12,0x1
	bne+ end
meterShenanigans:
	lbz r4,0x25(r29)				# load meter state
	cmpwi r4,0x2
	beq- meterDecayFinal
	cmpwi r4,0x3
	beq- end_displayMeter
	lis r3,0x8062 					# \ ftManager
	ori r3,r3,0x9a00 				# /
	lis r12,0x8081 					# \ ftManager::isProcessTechnique (this checks if there's a loaded FS)
	ori r12,r12,0x4d70 				# |
	mtctr r12						# |
	bctrl							# /
	cmpwi r3,0x1
	beq- end_setStateLocked			# don't do meter stuff if a player has a final smash!
	lis r3,0x8062 					# \ ftManager
	ori r3,r3,0x9a00 				# /
	lis r12,0x8081 					# \ ftManager::getFighterOperation (this checks if the port has control, i.e. ready, go!)
	ori r12,r12,0x4b78 				# |
	lwz r4,0x4(r29) 				# | ftEntry->entryId
	mtctr r12						# |
	bctrl							# /
	cmpwi r3,0x1
	bne- end_displayMeter 			# no control! no meter!
	lbz r0,0xA(r29) 				# \ ftEntry->instances[ftEntry->activeInstanceIndex].fighter (transforming character stuff)
	rlwinm r0,r0,3,0,28				# | 
	add r3,r29,r0 					# |
	lwz r3,0x34(r3) 				# /
	lwz r3,0x60(r3)					# \ soStatusModuleImpl->getStatusKind
	lwz r3,0xD8(r3)					# |
	lwz r3,0x70(r3)					# |
	lwz r12,0x0(r3)					# |
	lwz r12,0x48(r12)				# |
	mtctr r12						# |
	bctrl							# /
	cmpwi r3,0xBD 					# don't do meter when dead
	beq- end_setStateBase
	cmpwi r3,0xBE					# when on the respawn platform
	beq- end_setStateBase
	cmpwi r3,0x10B					# and when unloaded
	beq- end_setStateBase
meterStart:
	lhz r12,0x26(r29) 				# load meter amount
	cmpwi r12,FSMeterMax
	bge- giveFinal
meterIncrement:
	addi r12,r12,0x1 				# increment meter
	sth r12,0x26(r29) 				# and store it
	b end_setStateBase
meterDecayFinal:
	lhz r12,0x26(r29) 				# load meter amount
	cmpwi r12,FSMeterDecay
	ble- removeFinal
	subi r12,r12,FSMeterDecay		# decrement meter
	sth r12,0x26(r29) 				# and store it
	cmpwi r12,FSMeterWarnSFXAmount	# did we hit our meter warning?
	bgt- end_setStateBase
	lbz r12,0x24(r29)				# load meter warning flag
	cmpwi r12,0x1					# did we already do the sound?
	beq- end_setStateBase
	lwz r3,-0x4250(r13)				# sndSystem
	li r4,FSMeterWarnSFXId
	li r5,-1
	li r6,0x0
	li r7,0x0
	li r8,-1
	lis r12,0x8007					# \ sndSystem::playSe
	ori r12,r12,0x42b0				# |
	mtctr r12						# |
	bctrl							# /
	li r12,0x1						# \ set warning flag
	stb r12,0x24(r29)				# /
	b end_setStateBase	
givefinal:
	li r12,FSMeterMax				# set the meter to maximum, just in case
	sth r12,0x26(r29)
	li r12, 0x2						# set meter state to ready
	stb r12,0x25(r29)
	mr r3,r29
	lis r12,0x8082 					# \ ftEntry::setFinal
	ori r12,r12,0x037c 				# |
	li r4, 0x1 						# | set FS type to 1 (can't be dropped)
	mtctr r12						# |
	bctrl							# /
	b end_displayMeter
removefinal:
	li r12,0x0						# set the meter to 0
	sth r12,0x26(r29)
	stb r12,0x25(r29) 				# set meter state to base
	stb r12,0x24(r29) 				# reset warning flag
	lbz r0,0xA(r29) 				# \ ftEntry->instances[ftEntry->activeInstanceIndex].fighter (transforming character stuff)
	rlwinm r0,r0,0x3,0x0,0x1c		# | 
	add r3,r29,r0 					# |
	lwz r3,0x34(r3) 				# /
	li r4,0x1
	li r5,0x1
	li r6,0x0
	lis r12,0x8083 					# \ Fighter::endFinal
	ori r12,r12,0x8318 				# |
	mtctr r12						# |
	bctrl							# /
	lwz r3,-0x4250(r13)				# sndSystem
	li r4,FSMeterEndSFXId
	li r5,-1
	li r6,0x0
	li r7,0x0
	li r8,-1
	lis r12,0x8007					# \ sndSystem::playSe
	ori r12,r12,0x42b0				# |
	mtctr r12						# |
	bctrl							# /
	b end_displayMeter
end_setStateBase:
	li r5,0x0
	b end_setMeterState
end_setStateLocked:
	li r5,0x1
end_setMeterState:
	lbz r12,0x25(r29)
	cmpwi r12,0x2
	beq- end_displayMeter
	stb r5,0x25(r29)
end_displayMeter:
	lis r3,0x8062 					# \ ftManager
	ori r3,r3,0x9a00 				# /
	lwz r4,0x4(r29)					# entryId
	lis r12,0x8081					# \ ftManager::getPlayerNo (necessary for IfPlayer)
	ori r12,r12,0x5ad0				# /
	mtctr r12
	bctrl
	mulli r0,r3,0x4 				# math for IfPlayer slot
	lis r3,0x805A					# \ IfMngr
	lwz r3,0x02D0(r3)				# /
	add r3,r3,r0 					# \ get the IfPlayer of the specific slot
	lwz r3,0x4C(r3)					# /
	cmpwi r3,0x0 					# \ no IfPlayer exists, don't do anything
	beq- end						# /
	lwz r3,0xb8(r3) 				# IfPlayer->MuObject_portrite
	mr r7,r3 						# save it for later
	lhz r4,0x26(r29) 				# \ starting meter int to float conversion
	lis r0,0x4330					# |
	stw r4,0xC(r1) 					# |
	lfd f0,-0x148(r13)				# | global main.dol double
	stw r0,0x8(r1) 					# |
	lfd f1,0x8(r1) 					# |
	fsubs f1,f1,f0					# /
	lis r12,0x800b	 				# \ setFrameTexSrt/[muObject]
	ori r12,r12,0x798c				# |
	mtctr r12						# |
	bctrl							# /
	lbz r12,0x25(r29)				# \ meter state to float conversion
	stw r12,0xC(r1)					# | store it into the double setup from earlier
	lfd f1,0x8(r1)					# | load it as a float
	fsubs f1,f1,f0					# / subtract it from the converter float from earlier
	mr r3,r7
	lis r12,0x800b	 				# \ setFrameTex/[muObject]
	ori r12,r12,0x7900				# |
	mtctr r12						# |
	bctrl							# /
end:
	lwz r3,0x2C(r29)				# original op
	lwz r0,0x14(r1)
	mtlr r0
	addi r1,r1,0x10
}

######################################
# onDamage
######################################

.alias FSMtDmgMult_Hi = FSMeterGainDamageMult / 0x10000
.alias FSMtDmgMult_Lo = FSMeterGainDamageMult & 0xFFFF

.alias FSMtDmgMultTaken_Hi = FSMeterGainDamageTakenMult / 0x10000
.alias FSMtDmgMultTaken_Lo = FSMeterGainDamageTakenMult & 0xFFFF

HOOK @ $80840aa0 					# notifyEventOnDamage/[Fighter]
{
	stwu r1,-0x14(r1)
	mflr r0
	stw r0,0x18(r1)
	stw r6,0x10(r1) 				# we need to store this address for later
	lis r12,0x9018 					# \ access special versus option
	lbz r12,-0xC81(r12)				# / "Fixed camera"
	cmpwi r12,0x1
	bne+ end
	lis r3,0x8062 					# \ ftManager
	ori r3,r3,0x9a00 				# /
	lis r12,0x8081 					# \ ftManager::isProcessTechnique (this checks if there's a loaded FS)
	ori r12,r12,0x4d70 				# /
	mtctr r12
	bctrl
	cmpwi r3,0x1
	beq- end 						# don't do meter stuff if a player has a final smash!
	lwz r3,0x98(r30)				# soDamage->teamOwnerId
	lis r12,0x8002					# \ gfTask::getTask()
	ori r12,r12,0xdc40				# /
	mtctr r12
	bctrl
	cmpwi r3,0x0
	beq- end
	mr r5,r3
	lwz r12,0x3C(r5)				# \ soGetKind()
	lwz r12,0xA4(r12)				# /
	mtctr r12
	bctrl
	cmpwi r3,0x0
	bne- addMeterVictim				# not a fighter
addMeterAttacker:
	lwz r4,0x10c(r5) 				# fighter->entryId
	lwz r12,0x10c(r29)				# victimFighter->entryId
	cmpw r4,r12
	beq- addMeterVictim				# don't add extra attacking meter if you're attacking yourself!
	lis r7,FSMtDmgMult_Hi			# \ load multiplier
	ori r7,r7,FSMtDmgMult_Lo		# /
	bl addMeter
addMeterVictim:
	lwz r4,0x10c(r29) 				# victimFighter->entryId
	lis r7,FSMtDmgMultTaken_Hi		# \ load multiplier
	ori r7,r7,FSMtDmgMultTaken_Lo	# /
	bl addMeter
	b end
addMeter:
	stwu r1,-0x14(r1)
	mflr r0
	stw r0,0x18(r1)
	lis r3,0x8062					# \ ftEntryManager
	ori r3,r3,0x4780				# /
	lis r12,0x8082					# \ ftEntryManager::getEntity
	ori r12,r12,0x3b24				# /
	mtctr r12
	bctrl
	mr r12,r7						# load multiplier
	lhz r7,0x26(r3) 				# load meter amount
	lfs f5,0x4(r30) 				# soDamage->damage
	stw r12,0x8(r1)					# \
	li r12,0x0						# | empty out the bottom half of the double for the multiplier
	stw r12,0xC(r1)					# |
	lfd f6,0x8(r1)					# /
	fmul f5,f5,f6 					# multiply the damage with the multiplier
	fctiw f5,f5						# \ float to int converstion
	stfd f5,0x8(r1)					# |
	lwz r4,0xC(r1) 					# /
	add r7,r7,r4					# add the damage to the meter
	sth r7,0x26(r3)
	lwz r0,0x18(r1)
	mtlr r0
	addi r1,r1,0x14
	blr
end:
	lwz r6,0x10(r1)
	mr r4,r30		 				# original op
	lwz r0,0x18(r1)
	mtlr r0
	addi r1,r1,0x14
}

######################################
# setDead
######################################
HOOK @ $808162ec 					# setDead/[ftManager]
{
	lhz r12,0x26(r28) 				# load meter amount
	cmpwi r12,FSMeterLostDeath
	bgt+ subtractMeter
	lis r12,0x0
	b updateMeter
subtractMeter:
	subi r12,r12,FSMeterLostDeath
updateMeter:
	sth r12,0x26(r28)
	lbz r12,0x25(r28) 				# load meter state
	cmpwi r12,0x2
	bne- end						# reset meter state only if ready
	li r12,0x0						# set meter state to base
	stb r12,0x25(r28)
	stb r12,0x24(r28)				# reset warning flag
end:
	mr r4,r24 						# original op
}

#######################################
## Final Smash termination meter reset
## not using fighter::endFinal as it gets called multiple times normally in vanilla fighters, it caused problems
## instead, this hook is right before the FS resource gets unloaded, after all the models and gfx are gone
#######################################
HOOK @ $8082370c					# process/[ftEntry]
{
	lis r12,0x9018 					# \ access special versus option
	lbz r12,-0xC81(r12)				# / "Fixed camera"
	cmpwi r12,0x1
	bne+ end
	lbz r12,0x25(r29)				# get meter state
	cmpwi r12,0x3					# is it using a final smash?
	bne- end
	li r12,0x0
	stb r12,0x25(r29)				# set meter state to base
	sth r12,0x26(r29) 				# empty the meter
	stb r12,0x24(r29)				# reset warning flag
end:
	lwz r0,0x18(r29)				# original op
}

######################################
# Battle Portrait Creation
# added extra code to set visibility frame for the meter if meter mode is active
# r23 = IfPlayer
######################################
HOOK @ $800e086c					# createModel/[IfPlayer]
{
	lis r12,0x9018 					# \ access special versus option
	lbz r12,-0xC81(r12)				# / "Fixed camera"
	cmpwi r12,0x1
	bne+ end
	lwz r3,0xb8(r23) 				# IfPlayer->MuObject_portrite
	lfs f1,-0x2C(r13)				# load 1.0
	lis r12,0x800b	 				# \ setFrameNode/[muObject]
	ori r12,r12,0x7798				# |
	mtctr r12						# |
	bctrl							# /
end:
	lwz r3,0xF8(r23) 				# original op	
}

######################################
# startFinal
# if meter is full, set meter to being used
######################################
HOOK @ $80837e80					# startFinalCommon/[Fighter]
{
	lis r12,0x9018 					# \ access special versus option
	lbz r12,-0xC81(r12)				# / "Fixed camera"
	cmpwi r12,0x1
	bne+ end
	lwz r4,0x10c(r30) 				# fighter->entryId
	lis r3,0x8062					# \ ftEntryManager
	ori r3,r3,0x4780				# /
	lis r12,0x8082					# \ ftEntryManager::getEntity
	ori r12,r12,0x3b24				# |
	mtctr r12						# |
	bctrl							# /
	lbz r12,0x25(r3)				# load meter state
	cmpwi r12,0x2
	bne- end						# do the below only if your meter is full!
	li r12,0x3
	stb r12,0x25(r3)				# set meter state to on use
end:
	li r4,23019						# original op
}


######################################
# damage hook
# reduce damage by half during a meter final smash
######################################
HOOK @ $80745334					# getPower/[soCollisionAttackModuleImpl]
{
	mr r7,r3						# we need to save our soCollisionAttackModule, for the code below
	stwu r1,-0x10(r1)				# original op
}

HOOK @ $80745350					# getPower/[soCollisionAttackModuleImpl]
{
	stwu r1,-0x14(r1)
	mflr r0
	stw r0,0x18(r1)
	stw r4,0x8(r1)					# storing for later
	lis r12,0x9018 					# \ access special versus option
	lbz r12,-0xC81(r12)				# / "Fixed camera"
	cmpwi r12,0x1
	bne+ end
	addi r12,r7,0x60				# soCollisionAttackModule->soCollision
	lwz r3,0x14(r12)				# soCollision->taskId
	lis r12,0x8002					# \ gfTask::getTask()
	ori r12,r12,0xdc40				# |
	mtctr r12						# |
	bctrl							# /
	cmpwi r3,0x0
	beq- end
	mr r5,r3
	lwz r12,0x3C(r5)				# \ soGetKind()
	lwz r12,0xA4(r12)				# |
	mtctr r12						# |
	bctrl							# /
	cmpwi r3,0x0
	beq- getEntry					# is a fighter
	cmpwi r3,0x3
	bgt- end						# not a weapon or item
	mr r3,r5
	lis r12,0x8079					# \ soExternalValueAccesser::getTeamOwnerId
	ori r12,r12,0x75b0				# |
	mtctr r12						# |
	bctrl							# /	
	cmpwi r3,0x0
	beq- end
	mr r4,r3
	lis r3,0x8062					# \ ftEntryManager
	ori r3,r3,0x4780				# /
	li r5,0x0
	lis r12,0x8082					# \ ftEntryManager::getEntryIdFromTaskId
	ori r12,r12,0x3f90				# |
	mtctr r12						# |
	bctrl							# /
	cmpwi r3,0x0
	beq- end
getEntry:
	lwz r4,0x10c(r5)				# Fighter->entryId
	lis r3,0x8062					# \ ftEntryManager
	ori r3,r3,0x4780				# /
	lis r12,0x8082					# \ ftEntryManager::getEntity
	ori r12,r12,0x3b24				# |
	mtctr r12						# |
	bctrl							# /
meter:
	lbz r12,0x25(r3)				# load meter state
	cmpwi r12,0x3					# is meter in use?
	bne- end
	lfs f2,-0x3c(r13)				# load 0.5
	fmul f1,f1,f2					# multiply the damage
end:
	lis r3,0x80AD					# original op
	lwz r4,0x8(r1)
	lwz r0,0x18(r1)
	mtlr r0
	addi r1,r1,0x14
}

######################################
# processUpdate
# fixes double cherry causing meter FSs to drop smash balls
######################################
HOOK @ $80838ec0					# processUpdate/[Fighter]
{
	lis r12,0x9018 					# \ access special versus option
	lbz r12,-0xC81(r12)				# / "Fixed camera"
	cmpwi r12,0x1
	bne+ end
	lwz r4,0x10c(r29) 				# fighter->entryId
	lis r3,0x8062					# \ ftEntryManager
	ori r3,r3,0x4780				# /
	lis r12,0x8082					# \ ftEntryManager::getEntity
	ori r12,r12,0x3b24				# |
	mtctr r12						# |
	bctrl							# /
	lbz r12,0x25(r3) 				# load meter state
	cmpwi r12,0x2					# is meter ready?
	blt- noMeter					# don't change behavor
	li r5,0x1					# set FS type to 1 (can't be dropped)
	b end
noMeter:
	li r5,0x0					# original op
end:
	lwz r3,0x7c28(r30)				# reset r3
	lwz r4,0x10C(r29)				# original op
}
op nop @ $80838ec4					# processUpdate/[Fighter]

##################################################################################################
Smash Balls can't break with a loaded FS and Smash Balls break immediately in training [MarioDox]
##################################################################################################
HOOK @ $809A2AB4		#onPreDamageCheck/[itSmashBallCustomizer]
{
	mr r31,r4					# save BaseItem
	lis r3,0x8062 					# \ ftManager
	ori r3,r3,0x9a00 				# /
	lis r12,0x8081 					# \ ftManager::isProcessTechnique (this checks if there's a loaded FS)
	ori r12,r12,0x4d70 				# |
	mtctr r12					# |
	bctrl						# /
	cmpwi r3,0x1					# there's a loaded FS?
	beq- skip
	lis r12,0x805B					# \
	lwz r12,0x50AC(r12)				# |
	lwz r12,0x10(r12)				# |
	lwz r12,0x0(r12)				# |
	lwz r12,0x0(r12)				# / get Scene name
	lis r3,0x7371					# sq
	ori r3,r3,0x5472				# Tr(aining)
	cmpw r3,r12
	bne- end
	mr r3,r31
	lis r4,0x2200					# \ RA-BIT
	ori r4,r4,0x0002				# / 2 (isDead flag)
	lwz r3,0x60(r3)					# \
	lwz r3,0xD8(r3)					# |
	lwz r3,0x64(r3)					# | soWorkManageModuleImpl
	lwz r12,0x0(r3)					# |
	lwz r12,0x50(r12)				# | onFlag
	mtctr r12					# |
	bctrl						# /
	lwz r31,0x3C(r26)				# original op (originally r6)
	cmpwi r30,0xFF					# impossible cmp
	b %END%
skip:
	mr r3,r31
	lis r4,0x1100					# \ LA-FLOAT
	ori r4,r4,0x0006				# / 6 (hp)
	lwz r3,0x60(r3)					# \
	lwz r3,0xD8(r3)					# |
	lwz r3,0x64(r3)					# | soWorkManageModuleImpl
	lwz r12,0x0(r3)					# |
	lwz r12,0x38(r12)				# | getFloat
	mtctr r12					# |
	bctrl						# /
	lfs f0,0x28(r26)				# get damage dealt
	fcmpu cr0, f0, f1				# is the damage higher than the health?
	blt- end
	mr r3,r31
	lfs f1,0x18(r13)				# 1.0f
	fadds f1,f1,f0					# new health value: damage dealt + 1
	lis r4,0x1100					# \ LA-FLOAT
	ori r4,r4,0x0006				# / 6 (hp)
	lwz r3,0x60(r3)					# \
	lwz r3,0xD8(r3)					# |
	lwz r3,0x64(r3)					# | soWorkManageModuleImpl
	lwz r12,0x0(r3)					# |
	lwz r12,0x3C(r12)				# | setFloat
	mtctr r12					# |
	bctrl						# /
	lis r12,0x809a
	ori r12,r12,0x2b48
	mtctr r12
	bctr
end:
	cmpwi r30,10					# previous cmp to be restored
	lwz r31,0x3C(r26)				# original op (originally r6)
}
