######################################################################
New Hitbox (soCollisionAttackData) Flags [Kapedani, DukeItOut]
######################################################################
# field_3C 
#	bit 00 - Pill Hitbox Shape (not custom. From Brawl)
#	bit 01 - KO after 100%
#	bit 02 - Rebound (When clear tramples. Accidentally unused in Brawl.)
## These bits are currently unused but are planned as properties ##
#	bit 03\- 2-Bit Tripping Float Argument "Gimmick Type" Usage
#	bit 04/	(would allow tripping value to be used for alt mechanics)
#	bit 05\
#	bit 06|- 3-Bit Hitbox Special Info
#	bit 07/
#
#	bit 08 - Ignore armor
#	bit 09 - Untechable
# field_30
#	bit 22 - Front-Only
#	
###
# new hitbox script flags
#	bit 00\- 2-Bit Tripping Rate Argument Usage
#	bit 01/ (0 = Trip Rate, 1 = Hitstun Mult?, 2 = Hitbox Bodypart Filter?, 3 = ?)
# 	bit 03 - Rebound (Coding error made unused in Brawl.)
#	bit 10\
#	bit 11|- 3-Bit Hitbox Special Info (for subtypes of elements, etc.)
#	bit 12/
#	bit 16 - Ignore Armor
#	bit 17 - Untechable
#
# new hitbox script special flags
#	bit 10 - Front-Only (i.e. Mewtwo's Disable, sourspots of Shulk's Back Slash)
#	bit 11 - KO After 100%
#
# currently unreserved hitbox settings within script flags
#
#	bit 23
#	bit 26
#
###
# grGimmick::AttackData
# field_49 bit 1 - KO After 100%
#####################################################################
.alias g_ftStatusUniqProcessDead				= 0x80b8989c
.alias ftStatusUniqProcessDead__decCoin			= 0x8087dc18
.alias soExternalValueAccesser__getWorkFlag  	= 0x80797710

.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
}
.macro branch(<addr>)
{
    %lwi(r12, <addr>)
    mtctr r12
    bctr
}
.macro call(<addr>)
{
  %lwi(r12, <addr>)
  mtctr r12
  bctrl    
}

# Initialize flags when initializing soCollisionAttackData
HOOK @ $80932b30    # stCollisionAttrParam::setSoCollsionAttackData
{
    lwz	r0, 0x54(r4)   # Original operation
    li r12, 0          # \
    stw r12, 0x30(r5)  # |
    stw r12, 0x34(r5)  # | zero out flags
    stw r12, 0x38(r5)  # |
    #stw r12, 0x3C(r5) # /
    lbz r11, 0x49(r4)       # \
    rlwinm r11,r11,29,1,1   # | set bit for DangerZone
    stw r11, 0x3C(r5)       # /
}
HOOK @ $80971ff8    # grYakumono::setSoCollisionAttackData
{
    li r7, 1    # Original operation
    li r12, 0           # \
    stw r12, 0x30(r4)   # |
    stw r12, 0x34(r4)   # | zero out flags
    stw r12, 0x38(r4)   # |
    stw r12, 0x3C(r4)   # /
}
HOOK @ $80972230    # grYakumono::setAttackGimmickDetails
{
    stw	r5, 0x0(r4) # Original operation
    li r5, 0           # \
    stw r5, 0x30(r4)   # |
    stw r5, 0x34(r4)   # | zero out flags
    stw r5, 0x38(r4)   # |
    stw r5, 0x3C(r4)   # /
}
HOOK @ $8074b308    	# soCollisionAttackModuleImpl::extractAnimCmdArg
{
    li r4, 0    # Original operation
    stw r4, 0x30(r8)   # \
    stw r4, 0x34(r8)   # | zero out flags
    stw r4, 0x38(r8)   # |
    stw r4, 0x3C(r8)   # /
}
HOOK @ $80746b84    # soCollisionAttackModuleImpl::notifyEventAnimCmd
{
    li r4, 0    # Original operation
    stw r4, 0xA68(r1)   # \
    stw r4, 0xA6C(r1)   # | zero out flags
    stw r4, 0xA70(r1)   # |
    stw r4, 0xA74(r1)   # /
}
HOOK @ $80747c5c    # soCollisionAttackModuleImpl::notifyEventAnimCmd
{
    li r4, 0    # Original operation
    stw r4, 0xA28(r1)   # \
    stw r4, 0xA2C(r1)   # | zero out flags
    stw r4, 0xA30(r1)   # |
    stw r4, 0xA34(r1)   # /
}
HOOK @ $80744cdc    # soCollisionAttackModuleImpl::setAbsolute
{
    bctrl   # Original operation
    li r12, 0           # \
    stw r12, 0x30(r3)   # |
    stw r12, 0x34(r3)   # | zero out flags
    stw r12, 0x38(r3)   # |
    stw r12, 0x3C(r3)   # /
}

HOOK @ $80840c38   # Fighter::notifyEventOnDamage
{   
    lbz r12, 0x78(r30)      # \ 
    andi. r0, r12, 0x40     # | check if danger zone
    beq+ %end%              # /

    mr r3, r29          # \
    lwz	r12, 0x3C(r3)   # |
    lwz	r12, 0x2EC(r12) # | Fighter->getOwner()
    mtctr r12           # |
    bctrl               # /
    lwz r10, 0x0(r3)    # \
    lwz r10,0x8(r10)    # | Check if ftOwner->ftOwnerData->hitPointMax was set  
    cmpwi r10, 0x0      # |
    beq- notStamina     # /  
    mr r3, r29										# \
	%lwi (r4, 0x12000018)							# |
	%call (soExternalValueAccesser__getWorkFlag)	# | Check if knocked out
	cmpwi r3, 0										# |
	beq- %end%										# /
    b toDead
notStamina:

    lfs f1, 0x0(r30)    # \
    lfs f2, 0x4(r30)    # | get prev damage (totalDamge - damage)
    fsubs f1, f1, f2    # /
    lis r12, 0x42c8     # \
    stw r12, 0x8(r1)    # | make 100.0 on stack
    lfs f0, 0x8(r1)     # /
    fcmpo cr0, f1, f0   # \ check if prevDamage < 100.0
    blt+ %end%          # /
toDead:   
    mr r3, r29          # \
    mr r4, r30          # |
    li r5, 0x2          # |
    lwz	r12, 0x3C(r3)   # | fighter->dropItemCheck(damage, 2)
    lwz r12, 0x2d8(r12) # |
    mtctr r12           # |
    bctrl               # /

    li r4, 6			# \ 
    mr r3, r29          # |
    lwz	r12, 0x3C(r3)   # | fighter->toDead(6)
	lwz r12, 0x280(r12)	# | 
	mtctr r12			# |
	bctrl				# /
    %branch(0x80840cd8)
}

op cmplwi r22, 0 @ $8084109c    # \ change condition to == 0 instead of != 1
op beq+ 0x658 @ $808410a4       # /
HOOK @ $8084189c    # Fighter::dropItemCheck
{   
    rlwinm. r23,r22,31,31,31    # third parameter also houses whether it is a ko or not if set to 0x2
    lwz	r22, 0x84(r1)   # Original operation
    beq+ %end%
    li r22, 0x0
    %lwi (r3, g_ftStatusUniqProcessDead)    # \
    mr r4, r30                              # | drop half coins on ko
    %call(ftStatusUniqProcessDead__decCoin) # |
    mr r22, r3                              # /
}
HOOK @ $808418dc    # Fighter::dropItemCheck
{   
    cmpwi r23, 0x0      # \ 
    beq+ end            # | Skip lostCoin if it's a ko (already happened in decCoin)
    %branch(0x8084195c) # /
end:
    cmpwi r3, 0
}
HOOK @ $807468C0
{
	stwu r1, -0x10(r1)
	
	mr r3, r28			# Command
	addi r4, r1, 8		# Where to write info to temporarily
	li r5, 12			# Flags are argument 12, Special Flags are argument 14 if Special

	lwz r12, 0(r3)		# Command Info
	lwz r12, 0x20(r12)	# Pointer info to data table for command
	mtctr r12
	bctrl				# Get argument
	
	lwz r6, 0x8(r1)		# Pointer to flag info
	lbz r5, 0xC(r1)		# \
	cmpwi r5, 1			# | Boolean error check byte
	beq- error			# /
	
	lwz r4, 0x4(r6)		# Data for argument
	addi r5, r1, 0xAC8	# Hitbox info being generated (AB8 + 10 offset)

	lwz r3, 0x3C(r5)	#
	rlwimi r3, r4, 1, 2, 2		# Rebound Bit
	rlwimi r3, r4, 7, 3, 5		# Three-Bit Element Subtype Info (not implemented)
	rlwimi r3, r4, 29, 3, 4		# Two-Bit Gimmick Type (not implemented)
	rlwimi r3, r4, 8, 8, 9		# Ignore Armor and Untechable (not implemented)

	lwz r7, 8(r28)# \ Get command type
	lbz r7, 1(r7) # |
	cmpwi r7, 21  # | checking if this might be a special offensive collision
	bne+ finish	  # /
	
	lwz r4, 0x14(r6)	# Move two arguments ahead for special flags!
	
	lwz r7, 0x30(r5)
	rlwimi r7, r4, 20, 22, 22	# Front-Only
	stw r7, 0x30(r5)
	
	# rlwimi r3, r4, 10, 1, 1	# KOs instantly at 100%+ (currently disabled to prevent false positives)
finish:
	stw r3, 0x3C(r5)	# Store settings
error:

	# addi r5, r1, 0xAC8	#
	# lwz r3, 0x30(r5)	#
	# ori r3, r3, 0x200	# TEST LR
	# stw r3, 0x30(r5)	#
	
	addi r1, r1, 0x10	
	lwz r12, 0(r26)		# Original operation
}
op li r29, 0 		 @ $8074685C # moved to r29 from r28 because r29 is no longer used
op stb r29, 0x10(r1) @ $80746864 # but we want r28 for the above!
op stb r29, 0x14(r1) @ $80746880 #

####################################
Rebound Flag Works Again [DukeItOut]
####################################
#
# The Brawl devs messed up the flag that allows moves to not
# rebound. This recreates the behavior.
#
# Despite this bug, multiple moves in Brawl still set the flag
# as in Melee and other titles, making it clear this was a mistake.
###################################################################
HOOK @ $808400EC
{
	lwz r5, 0x60(r31)	# Original operation
	lwz r4, 0x7C(r5)	# \ Hitbox ID that triggered
	lbz r4, 0xA5(r4)	# / 
	lwz r3, 0x28(r5)	# Hitbox Data
	lwz r3, 0x30(r3)	# \
	lwz r12, 0x0(r3)	# | Get to data
	lwz r12, 0xC(r12)	# /
	mtctr r12
	bctrl
	lwz r3,  0x40(r3)	# Hitbox Info "field_0x3C"
	andis. r3, r3, 0x2000	# \ If rebound not set, then trample!
	bne- %END%				# /
	ba 0x84010C				# Go ahead and skip the action change!
}

#######################################
Front-Only Flag Works Again [DukeItOut]
#######################################
# Mewtwo did not get far enough along
# in Brawl for them to fully code this
# in. It has a fully unused bit.
#
# Supports usage by items, players
# and projectiles.
#
# Also is reacted to by Subspace
# enemies, Sandbag, Dedede minions,
# Pikmin and bosses.
#######################################
HOOK @ $80741E64
{
	cmpwi r3, 0; beq- bail
	
	stwu r1, -0x20(r1)	
	stw r3, 0x8(r1)
	li r3, 2
	mtctr r3	# Counter
	
	mr r5, r15		# Collision A
	mr r4, r22		# Collision A ID
	b firstPass
secondPass:	
	mr r5, r16		# Collision B
	mr r4, r20		# Collision B ID
firstPass:
	lwz r3, 0x4(r5)
	lwz r11, 0x00(r5); cmpwi r11, 3; bge- normal		 # skip if the interaction was triggered
														 # by a reflector, absorber or detector!	
	# Type of hitboxes 
	# (0 = Hitbox, 1 = Hurtbox, 2 = Shield/Counter, 3 = Reflector, 4 = Absorber, 5 = Detector)
	lbz r0, 0x10(r5); cmpwi r0, 2; beq- enemy			# 02 = Subspace Enemy
					  cmpwi r0, 10; beq- fighterCheck	# 10 = Fighter
								    blt- normal			# 11 = Item
					  cmpwi r0, 12; bgt- normal			# 12 = Article
notFighter:
	li r6, 0x40	# Offset when Hitbox/Reflector/Detector
	cmpwi r11, 1; bne- notObjectHurt
enemy:
	li r6, 0x30	# Offset when Hurtbox (strangely, Hotheads use hurtboxes as absorbers) or an SSE enemy
notObjectHurt:
	lwzx r6, r3, r6
	lwz r3, 0x8(r6)		# Get base of object info!
	cmpwi r11, 1; bne- checkDir		# The below are only inspected for ID if the hurtbox will trigger!
	cmpwi r0, 11; blt- enemyCheck	# Behave the same for all Subspace enemies! 
				  bgt+ projectileCheck			  
###
itemCheck:
	lwz r3, 0x8C0(r3)	# Item ID 
	cmpwi r3, 0x06; beq- checkDir	# Bob-Omb
	cmpwi r3, 0x13; beq- checkDir	# Mr. Saturn
	cmpwi r3, 0x31; beq- checkDir	# Sandbag
	cmpwi r3, 0x37; beq- checkDir	# Smash Ball (Yes, really.)
	cmpwi r3, 0x4F; beq- checkDir	# HRC Sandbag
	cmpwi r3, 0x96; beq- checkDir	# Hammer Bro/Custom Crate Enemy
	cmpwi r3, 0xAA; beq- checkDir	# Starfy				  
	b normal
###	
enemyCheck:
	lwz r3, 0xAC(r3)
	cmpwi r3, 0x06; beq- normal		# Roturret/Deathpod rotates from a fixed point!
	cmpwi r3, 0x2E; beq- normal		# Petey Piranha faces the screen!
	cmpwi r3, 0x36; beq- normal		# Duon has two heads!
	b checkDir
###
projectileCheck:
	lwz r3, 0xB8(r3)	# Article ID
	cmpwi r3, 51; beq- checkDir		# check if Waddle Dee, Waddle Doo or Gordo!
	cmpwi r3, 67; beq+ checkDir		# check if Pikmin!	
	b normal
###
fighterCheck:
	cmpwi r11, 0
	li r11, 0x38		# Hitbox
	beq+ notFighterHit
	li r11, 0x4C		# Hurtbox, Shield, Reflector, Absorber, Detector
notFighterHit:
	lwzx r6, r3, r11
###
checkDir:
	mfctr r11
	stw r11, 0xC(r1)	# Store counter as it will get overwritten by the below call
	mulli r11, r11, 8
	addi r12, r1, 0x8	# Saves to 18 (0x8+0x18) and 10 (0x8+0x8) on the respective passes
	stwx r6, r12, r11	#
	
	lwz r3, 0x0(r5); cmpwi r3, 0; bne- notAttackCheck	# Collision Type

	lwz r3, 0x28(r6)
	lwz r3, 0x30(r3)		# r4 is the collision ID. See above for how it is obtained.
	lwz r12, 0(r3)
	lwz r12, 0xC(r12)	
	mtctr r12		
	bctrl

	lwz r12, 0xC(r1)
	mtctr r12			# Counter (2 = Pass 1, 1 = Pass 2)
	
	lwz r12, 0x34(r3) 		# "field_0x30"
	andi. r3, r12, 0x200	# Bit for front-only
	beq+ 0x8				# If clear, proceed as now!
	li r3, 6				# Front-Only!!
	
notAttackCheck:
	addi r12, r1, 0xC	# Saves to 1C (0xC+0x18) and 14 (0xC+0x8) on the respective passes 
	stbx r3, r12, r11
	bdnz+ secondPass
## Finished pass of trying to determine hitbox information. ##		
	lwz r17, 0x18(r1)	# Collision A's Main Object
	lwz r11, 0x10(r1)	# Collision B's Main Object
	
	lbz r18, 0x1C(r1) 	# Get the collision types again
	lbz r19, 0x14(r1) 	#
	
	cmpwi r18, 6; beq- dirCheck 	# \ See if either collision is a front-only hitbox!
	cmpwi r19, 6; bne+ normal		# /
	
dirCheck:
	
	lwz r18, 0x18(r17)	# Movement Info for Collision A
	lwz r19, 0x18(r11)	# Movement Info for Collision B
	
	lfs f1, 0x40(r18)	# Direction of attacker.
	lfs f0, 0x40(r19)	# Direction of potential recipient.
	fcmpu cr0, f0, f1	# \ See if they are facing different directions.
	bne+ diffDir		# /
	li r3, 0			# Don't react to the hitboxes as this is direction-only!
	b forceSkip
diffDir:
normal:
	lwz r3, 0x8(r1)
forceSkip:
	addi r1, r1, 0x20
	
	
bail:
	cmplwi r3, 1	# Original operation
}


#######################################
Handle Dead Types [Kapedani, DukeItOut]
# DeadType 4 (vanilla) - crush
# DeadType 5 - stamina explode death
# DeadType 6 - explode death from hitbox
#######################################
.alias g_stLoaderManager            = 0x80B8A6D0
.alias g_ecMgr						= 0x805a0148
.alias ecMgr__setEffect 			= 0x8005F7E0

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
.macro branch(<addr>)
{
    %lwi(r12, <addr>)
    mtctr r12
    bctr
}
.macro call(<addr>)
{
  %lwi(r12, <addr>)
  mtctr r12
  bctrl    
}

HOOK @ $8087bf40	# ftStatusUniqProcessDead::initStatus
{
	%lwi(r4, 0x10000028)	# \
	lwz r3, 0xd8(r27)		# |
	lwz r3, 0x64(r3)		# | moduleAccesser->moduleEnumeration->workModule->getInt(0x12000018)
	lwz r12, 0x0(r3)		# |
	lwz r12, 0x18(r12)		# |
	mtctr r12				# |
	bctrl					# /
	stw r3, 0x7C(r1)	# Store on stack
	cmpwi r3, 4         # \
    beq- createMoney    # | check if 4 or 5
    cmpwi r3, 5	        # |
	bne+ end            # /
createMoney:
	%branch(0x8087c198)	# create money as if dying from bottom blast zone
end:
	lwz	r5, 0xD8(r27)	# Original operation
}

HOOK @ $8087c638	# ftStatusUniqProcessDead::initStatus
{	
	lwz r12, 0x7C(r1)	# \ 
	cmpwi r12, 4		# | check if dead type is less than 4
	blt+ end			# /
	%branch(0x8087c740)	# skip blastzone effect and go into setTemporaryCamera
end:
	lwz	r5, 0xD8(r27)	# Original operation
}
HOOK @ $8087c82c	# ftStatusUniqProcessDead::initStatus
{
	lwz r12, 0x7C(r1)	    # \
	cmpwi r12, 4		    # | check if dead type is 4 or greater (continue to make effect)
	bge+ %end% 			    # /
    %branch(0x8087cd68) # Original operation
}
HOOK @ $8087C838	# ftStatusUniqProcessDead::initStatus
{
	ori r4, r3, 18		# Get SSE effect
    lwz r12, 0x7C(r1)   # \
    cmpwi r12, 4        # | check if dead type is crush
    bne+ notCrush       # /	
    %lwd (r12, g_stLoaderManager)   # \
    lwz r12, 0x1C(r12)              # | g_stLoaderManager->stageLoader->stageKind == Stage_Subspace
    lwz r11, 0x8C(r12)              # |
    cmpwi r11, 0x3d		            # /
    beq+ %END% 	# Branch if in SSE
    lwz r11, 0x94(r12)              # | check if g_stLoaderManager->stageLoader->effectBankId is battlefield
    cmpwi r11, 0x32                 # |
    bne+ notCrush                   # /
	%lwi(r4, 0x320001)  # First effect ID in ef_StgBattlefield
    b %end%
notCrush:
    lwz r12, 0xd8(r27)		# moduleAccesser->moduleEnumeration
	lwz r8, 0x4(r12)		# \ moduleEnumeration->modelModule->modelScale
	lfs f0, 0x4C(r8)		# /
	lwz r8, 0xc(r12)		# \ moduleEnumeration->postureModule->baseScale
	lfs f1, 0x3c(r8)		# /
	fmuls f0, f0, f1		# \ Multiply modelScale with baseScale
	stfs f0, 0x7C(r1)		# /
	%lwd (r3, g_ecMgr)
	addi r5, r1, 0x108		# &postureModule->pos
	li r6, 0				# pointer to XYZ rotate data (0 = not read)
	addi r7, r1, 0x98		# pointer to XYZ scale data
	lis r4, 0x3F00			# \ 0.5x multiplier
	stw r4, 0x0(r7)			# |
	lfs f1, 0x0(r7)			# |
	fmuls f0, f0, f1 		# |
	stfs f0, 0x0(r7)		# |
	stfs f0, 0x4(r7)		# |
	stfs f0, 0x8(r7)		# /
	li r4, 0x4C				# Firecracker explosion (bank 0, ID 0x4C)
	%call (ecMgr__setEffect)
	%lwd (r3, g_ecMgr) 
	addi r5, r1, 0x108
	li r6, 0
	addi r7, r1, 0x98
	lfs f0, 0x7C(r1)	    # Model Scale
	stfs f0, 0x0(r7)
	stfs f0, 0x4(r7)
	stfs f0, 0x8(r7)
	lis r4, 0x104
	ori r4, r4, 0xD  		# Blue Flash (bank 0x104, ID 0xD)
	%call (ecMgr__setEffect)
    %branch(0x8087c874)
}

