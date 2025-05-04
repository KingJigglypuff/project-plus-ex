############################
Crush anywhere anytime [Eon] 
############################
op nop @ $8083b1ac 

######################################################################################
Damage Floor Attack Data Takes into Account Additional Hitbox Flags [Kapedani]
# Supports ignoreIntangibility, ignoreInvincibility, enableFriendlyFire, collisionMask
######################################################################################
.alias grCollStatus__getTouchLineMaterialType      = 0x80136160

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

## Set flags after detectionRate as first half of grGimmick::AttackData e.g. ignoreInvincibility
## Set unused 0x30, 0x34, and 0x38 fields of grGimmick::AttackData as slipChance, hitStopFrame and hitStopDelay
HOOK @ $80932c40    # stCollisionAttrParam::setSoCollsionAttackData
{
    lwz	r12, 0x3C(r4)   # Get flags from first half
    srawi r12, r12, 16	# Shift to the right
    or r3, r3, r12      # Append them to detectionRate bitfield
    stw	r3, 0x38(r5)    # Original operation
    lwz r12, 0x14(r4)   # \ set vector
    stw r12, 0x14(r5)   # /
    lfs f2, 0x30(r4)    # \ set slipChance
    stfs f2, 0x24(r5)   # /
    lfs f2, 0x34(r4)        # \
    fcmpo cr0, f2, f1       # | set hitStopFrame (if not 0)
    beq+ hitStopFrameNotSet # |
    stfs f2, 0x28(r5)       # |
hitStopFrameNotSet:         # /
    lfs f2, 0x38(r4)        # |
    fcmpo cr0, f2, f1       # | set hitStopDelay (if not 0)
    beq+ hitStopDelayNotSet # |
    stfs f2, 0x2C(r5)       # |
hitStopDelayNotSet:         # /
}
HOOK @ $80972168    # grYakumono::setSoCollisionAttackData
{
    lwz	r12, 0x3C(r5)   # Get flags from first half
    srawi r12, r12, 16  # Shift to the right
    or r7, r7, r12      # Append them to detectionRate bitfield
    stw	r7, 0x38(r4)    # Original operation
    lfs f2, 0x30(r5)    # \ set slipChance
    stfs f2, 0x24(r4)   # /
    lfs f2, 0x34(r5)             # \
    fcmpo cr1, f2, f1            # | set hitStopFrame (if not 0)
    beq+ cr1, hitStopFrameNotSet # |
    stfs f2, 0x28(r4)            # |
hitStopFrameNotSet:              # /
    lfs f2, 0x38(r5)             # |
    fcmpo cr1, f2, f1            # | set hitStopDelay (if not 0)
    beq+ cr1, hitStopDelayNotSet # |
    stfs f2, 0x2C(r4)            # |
hitStopDelayNotSet:              # /
}

## Second bit of grGimmick::AttackData->isSituationAir is isSituationODD
HOOK @ $80932bc0    # stCollisionAttrParam::setSoCollsionAttackData
{
    rlwinm r3, r3, 0, 29, 30
    lbz r12, 0x2F(r4)   # \
    andi. r12, r12, 0x1 # | set isSituationGround
    or r3, r3, r12      # /
}
op rlwinm r7, r7, 0, 29, 30 @ $809720f0     # \ grYakumono::setSoCollisionAttackData
op rlwimi r3, r10, 22, 29, 30 @ $8097211c   # /

## Set unusued 0x4C field of grGimmick::AttackData as ~categoryMask and ~partMask
HOOK @ $80932bdc    # stCollisionAttrParam::setSoCollsionAttackData
{
    lhz r12, 0x4C(r4)       # \ get category mask and shift
    rlwinm r12,r12,13,9,18  # /
    lbz r11, 0x4E(r4)       # \ get part mask and shift
    rlwinm r11,r11,1,23,26  # /
    or r12, r12, r11    # \ 
    not r12, r12        # | combine and bitflip, & with original mask
    and r6, r6, r12     # /
    stw	r6, 0x30(r5)    # Original operation
}
HOOK @ $80972140    # grYakumono::setSoCollisionAttackData
{
    lhz r12, 0x4C(r5)       # \ get category mask and shift
    rlwinm r12,r12,13,9,18  # /
    lbz r11, 0x4E(r5)       # \ get part mask and shift
    rlwinm r11,r11,1,23,26  # /
    or r12, r12, r11    # \ 
    not r12, r12        # | combine and bitflip, & with original mask
    and r8, r8, r12     # /
    stw	r8, 0x30(r4)    # Original operation
}

## Allow items to be affected by floor hazards
op andi. r4, r3, 0xFF @ $8098e654   # BaseItem::reset only use last bytes for knockback type
HOOK @ $8076de44    # soDamageTransactorActor::isCheckGroundDamage  (used for items) 
{
    stwu r1, -0x10(r1)
    mflr r0
    stw r0, 0x14(r1)

    %lwi (r3, 0x80b8bf88)   # \
    li r5, 0x5b71           # |
    li r6, 0                # |
    lwz	r12, 0x4(r3)        # | g_ItValueAccesser.getConstantIntCore(moduleAccesser, 0x5b71, 0)
    lwz	r12, 0x20(r12)      # |
    mtctr r12               # |
    bctrl                   # /
    srwi r3, r3, 31         # isCheck = value >> 31 

    lwz r0, 0x14(r1)
    mtlr r0
    addi r1, r1, 0x10
    # check param value to see if should give ground damage
}

## Timer before fighter can get hit again by floor hazard is based off detection rate
op nop @ $8085c7ac              # \
op lhz r3, 0x74(r5) @ $8085c7c4 # / ftDamageTransactorImpl::onGroundDamageAfter 

## Use collision attack flags to determine whether to apply floor hazard damage
op mr r20, r3 @ $80768260	# skip total status check for later
HOOK @ $80768300	# soDamageModuleImpl::check
{
    
    lwz r3, 0x3C(r22)		# \
	lwz r3, 0x8(r3)			# |
	lwz r12, 0x3c(r3)		# |
	lwz r12, 0xA4(r12)      # | this->moduleAccesser->stageObject->soGetKind() 
    mtctr r12               # | 
    bctrl                   # /
    lwz r12, 0x40(r1)   # get category mask
    cmpwi r3, 0     # isFighter
    bne+ notFighter
    rlwinm. r0,r12,19,31,31   
    b checkCategory             # isCategoryFighter
notFighter:
    cmpwi r3, 1     # isEnemy
    bne+ notEnemy
    rlwinm. r0,r12,18,31,31   
    b checkCategory             # isCategoryEnemy
notEnemy:
    cmpwi r3, 4     # isItem
    bne+ notItem
    rlwinm. r0,r12,16,31,31     
    b checkCategory             # isCategoryItem
notItem:
    cmpwi r3, 3     # isGimmick
    bne+ notYakumono
    rlwinm. r0,r12,13,31,31     
    b checkCategory             # isCategoryGimmick
notYakumono:
    cmpwi r3, 2     # isWeapon
    bne+ isCategory             
    rlwinm. r0,r12,11,31,31    # isCategoryItemE
checkCategory:
    beq+ noHit
isCategory:
    lwz r12, 0x48(r1)		
    cmpwi r20, 0	
	beq+ hit	    
	cmpwi r20, 1    # \ check if invincible
    beq+ invincible # /
    cmpwi r20, 2    # \ check if intangible 
    bne+ noHit      # /
intangible:
	andi. r0, r12, 0x2000	# check if ignore intangibility
    bne+ hit 
    b noHit
invincible:
    andi. r0, r12, 0x4000   # check if ignore invincibility   
	bne+ hit	            
noHit:
	%branch(0x80768314)
hit:
	lwz	r4, 0xC(r1)	# Original operation
}
HOOK @ $807682f8    # soDamageModuleImpl::check
{
    lwz r12, 0x48(r1)           # \
    rlwinm. r11,r12,24,31,31    # | check if friendly fire is enabled
    bne+ %end%                  # /
    cmpw r0, r3 # Original operation
}

HOOK @ $8083bf30    # Fighter::notifyEventChangeStatus
{
    cmpwi r25, 101          # \ check if status is StopWall 
    bne+ notStopWall    # /
checkWallDamage:
    li r4, 0x2          # \
    lwz	r3, 0xD8(r28)   # |
    lwz r3, 0x38(r3)    # |
    lwz r12, 0x8(r3)    # | moduleAccesser->moduleEnumeration->damageModule->check(2)
    lwz r12, 0x38(r12)  # |
    mtctr r12           # |
    bctrl               # /
notStopWall:
    lwz	r3, 0xD8(r28)   # Original operation
}
HOOK @ $808784cc    # ftStatusUniqProcessDamageFlyReflect::initStatus
{
    li r4, 0x2          # \
    lwz	r3, 0xD8(r30)   # |
    lwz r3, 0x38(r3)    # |
    lwz r12, 0x8(r3)    # | moduleAccesser->moduleEnumeration->damageModule->check(2)
    lwz r12, 0x38(r12)  # |
    mtctr r12           # |
    bctrl               # /
    lwz	r5, 0xD8(r30)   # Original operation
}
HOOK @ $8076c140    # soDamageModuleActor::onGroundDamage
{
    stw r3, 0x8(r1)     # \
    lwz	r12, 0x0(r3)    # |
    mr r5, r31          # |
    li r6, 0x0          # |
    lwz r4, 0x3C(r29)   # | call onGroundDamageAfter before onDamage so that work int for no ground damage frame can get set
    lwz r12, 0x4C(r12)  # | pass NULL as r6 to signify early call
    mtctr r12           # |
    bctrl               # |
    lwz r3, 0x8(r1)     # /
    lwz	r12, 0x0(r3) # Original operation
}

# HOOK @ $8070fe44    # StageObject::processMapCorrection   # Note: "Proper" way instead of the above three checks but can't tech which is less funny (maybe can check transition to see if would tech?)
# {
#     bctrl       # Original operation
#     li r4, 0x2          # \
#     lwz	r3, 0xD8(r30)   # |
#     lwz r3, 0x38(r3)    # |
#     lwz r12, 0x8(r3)    # | moduleAccesser->moduleEnumeration->damageModule->check(2)
#     lwz r12, 0x38(r12)  # |
#     mtctr r12           # |
#     bctrl               # /
# }

HOOK @ $80767d54    # soDamageModuleImpl::check
{
    lis	r31, 0x80B8     # Original operation
    cmpwi r23, 0x2      # \
    bne+ %end%          # | check if second parameter is 2 and skip to checking ground damage
    %branch(0x80768220) # /
}

# TODO: Support other collision attack flags?
# TODO: Untechable walls collision option

#############################################################################################################################################
Fix Number of Hit Groups Retrieved in Yakumono::setCollisionHitSelfCatagory, setCollisionHitOpponentCatagory and setSituationKind [Kapedani]
#############################################################################################################################################

HOOK @ $8096e340    # Yakumono::setCollisionHitSelfCatagory
{
    lwz r3, 0x180(r29)  # \
    lwz r3, 0x20(r3)    # |
    lwz r12, 0x0(r3)    # |
    lwz r12, 0xBC(r12)  # | this->soModuleAccesser.enumerationStart->collisionHitModule->getGroupNum()
    mtctr r12           # |
    bctrl               # |
    mr r0, r3           # /
}

HOOK @ $8096e2c4    # Yakumono::setCollisionHitOpponentCatagory
{
    lwz r3, 0x180(r28)  # \
    lwz r3, 0x20(r3)    # |
    lwz r12, 0x0(r3)    # |
    lwz r12, 0xBC(r12)  # | this->soModuleAccesser.enumerationStart->collisionHitModule->getGroupNum()
    mtctr r12           # |
    bctrl               # |
    mr r0, r3           # /
}

HOOK @ $8096e6e4    # Yakumono::setSituationKind
{
    lwz r3, 0x180(r30)  # \
    lwz r3, 0x20(r3)    # |
    lwz r12, 0x0(r3)    # |
    lwz r12, 0xBC(r12)  # | this->soModuleAccesser.enumerationStart->collisionHitModule->getGroupNum()
    mtctr r12           # |
    bctrl               # |
    mr r0, r3           # /
}

######################################
Added option for true warps [Kapedani]
######################################
.alias soCollisionAttackPart__initPos      = 0x8074361c
.alias soCollisionCatchPart__initPos       = 0x80755a9c
.alias soCollisionSearchPart__initPos      = 0x807585bc

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

HOOK @ $808472b0    # Fighter::warp
{
    stw r4, 0x8(r1)     # Store pos on stack
    bctrl   # Original operation
    andi. r0, r30, 0x2  # \ check second bit of last parameter
    beq+ %end%          # /
    lwz	r3, 0xD8(r31)   # \
    fmr	f1, f31         # |
    lwz	r3, 0xC(r3)     # | moduleAccesser->moduleEnumeration->postureModule->setLr(lr)
    lwz	r12, 0x0(r3)    # |
    lwz	r12, 0x30(r12)  # |
    mtctr r12           # |
    bctrl               # /
    lwz r4, 0x8(r1)     # \
    li r5, 0	        # |
    lwz r3, 0xd8(r31)   # |
    lwz r3, 0x10(r3)    # | moduleAccesser->moduleEnumeration->groundModule->relocate(&pos, 0x0)
    lwz r12, 0x8(r3)    # | 
    lwz r12, 0x2C(r12)  # |
    mtctr r12           # |
    bctrl               # /
    lwz r3, 0x8(r31)    # \
    lwz r12, 0x3C(r3)   # |
    lwz r12, 0xB4(r12)  # | moduleAccesser->stageObject->updateNodeSRT()
    mtctr r12           # |
    bctrl               # /
    # li r4, 0x1          # \
    # lwz r3, 0xd8(r31)   # |
    # lwz r3, 0x10(r3)    # | 
    # lwz r12, 0x8(r3)    # | moduleAccesser->moduleEnumeration->groundModule->update(1)
    # lwz r12, 0x34(r12)  # |
    # mtctr r12           # |
    # bctrl               # /
    ## Update collision modules to reset hitbox interpolation
    li r4, -1          # \ 
    lwz r3, 0xd8(r31)   # |
    lwz r3, 0x1C(r3)    # | 
    lwz r12, 0x0(r3)    # | moduleAccesser->moduleEnumeration->collisionAttackModule->clear(-1)
    lwz r12, 0x1C(r12)  # |
    mtctr r12           # |
    bctrl               # /
    li r4, -1          # \
    lwz r3, 0xd8(r31)   # | 
    lwz r3, 0x30(r3)    # |
    lwz r12, 0x0(r3)    # | moduleAccesser->moduleEnumeration->collisionCatchModule->clear(-1)
    lwz r12, 0x1C(r12)  # |
    mtctr r12           # |
    bctrl               # /
    li r4, -1           # \
    lwz r3, 0xd8(r31)   # | 
    lwz r3, 0x34(r3)    # |
    lwz r12, 0x0(r3)    # | moduleAccesser->moduleEnumeration->collisionSearchModule->clear(-1)
    lwz r12, 0x1C(r12)  # |
    mtctr r12           # |
    bctrl               # /
    %branch(0x808472f0)
}

CODE @ $808472f0    # Fighter::warp
{
    andi. r0, r30, 0x1
    beq- 0x84
} 

HOOK @ $80998888    # BaseItem::warp
{
    bctrl	# Original operation
    li r4, -1           # \ 
    lwz r3, 0x60(r30)   # |
    lwz r3, 0xd8(r3)    # |
    lwz r3, 0x1C(r3)    # | 
    lwz r12, 0x0(r3)    # | moduleAccesser->moduleEnumeration->collisionAttackModule->clear(-1)
    lwz r12, 0x1C(r12)  # |
    mtctr r12           # |
    bctrl               # /
    li r4, -1           # \
    lwz r3, 0x60(r30)   # |
    lwz r3, 0xd8(r3)    # | 
    lwz r3, 0x30(r3)    # |
    lwz r12, 0x0(r3)    # | moduleAccesser->moduleEnumeration->collisionCatchModule->clear(-1)
    lwz r12, 0x1C(r12)  # |
    mtctr r12           # |
    bctrl               # /
    li r4, -1           # \
    lwz r3, 0x60(r30)   # |
    lwz r3, 0xd8(r3)    # | 
    lwz r3, 0x34(r3)    # |
    lwz r12, 0x0(r3)    # | moduleAccesser->moduleEnumeration->collisionSearchModule->clear(-1)
    lwz r12, 0x1C(r12)  # |
    mtctr r12           # |
    bctrl               # /
}


HOOK @ $807447b4    # soColliisonAttackModuleImpl::clear
{
    lwz	r12, 0x0(r3)  # Original operation
    cmpwi r31, 0x0
    bge+ %end%
    lwz	r12, 0x14(r12)  # \ 
    mtctr r12           # | collisionAttackPartArray->size()
    bctrl               # /
    mr r31, r3
    b startLoop
loop:
    mr r4, r31
    lwz	r3, 0x30(r30)   # \
    lwz	r12, 0(r3)      # |
    lwz	r12, 0xC(r12)   # | this->collisionAttackPartArray->at(index)
    mtctr r12           # |
    bctrl               # /
    lwz r0, 0x0(r3)     # \
    cmpwi r0, 0x0       # | if part->status != Status_Inactive
    beq+ startLoop      # /
    li r0, 0x1          # \ set to Status_Set to reset interpolation
    stw r0, 0x0(r3)     # / 
startLoop:
    subi r31, r31, 0x1
    cmpwi r31, 0x0
    bge+ loop
    %branch(0x8074482c)
}

HOOK @ $80756228    # soCollisionCatchModuleImpl::clear
{   
    stw r3, 0x8(r1)   
    lwz	r3, 0x2C(r3)    # Original operation  
    cmpwi r4, 0x0
    bge+ %end%
    lwz	r12, 0x0(r3)    # \
    lwz	r12, 0x14(r12)  # | collisionCatchPartArray->size()
    mtctr r12           # | 
    bctrl               # /
    stw r3, 0xC(r1)
    b startLoop 
loop:
    lwz r3, 0x8(r1)     # \
    lwz	r3, 0x2C(r3)    # |
    lwz	r12, 0(r3)      # |
    lwz	r12, 0xC(r12)   # | this->collisionCatchPartArray->at(index)
    mtctr r12           # |
    bctrl               # /
    lwz r0, 0x0(r3)     # \
    cmpwi r0, 0x0       # | if part->status != Status_Inactive
    beq+ startLoop      # /
    li r0, 0x1          # \ set to Status_Set to reset interpolation
    stw r0, 0x0(r3)     # / 
startLoop:
    lwz r4, 0xC(r1)
    subi r4, r4, 0x1
    stw r4, 0xC(r1)
    cmpwi r4, 0x0
    bge+ loop
    %branch(0x80756244)
}

HOOK @ $80758d30    # soCollisionSearchModuleImpl::clear
{
    stw r3, 0x8(r1)   
    lwz	r3, 0x2C(r3)    # Original operation  
    cmpwi r4, 0x0
    bge+ %end%
    lwz	r12, 0x0(r3)    # \
    lwz	r12, 0x14(r12)  # | collisionSearchPartArray->size()
    mtctr r12           # | 
    bctrl               # /
    stw r3, 0xC(r1)
    b startLoop 
loop:
    lwz r3, 0x8(r1)     # \
    lwz	r3, 0x2C(r3)    # |
    lwz	r12, 0(r3)      # |
    lwz	r12, 0xC(r12)   # | this->collisionSearchPartArray->at(index)
    mtctr r12           # |
    bctrl               # /
    lwz r0, 0x0(r3)     # \
    cmpwi r0, 0x0       # | if part->status != Status_Inactive
    beq+ startLoop      # /
    li r0, 0x1          # \ set to Status_Set to reset interpolation
    stw r0, 0x0(r3)     # / 
startLoop:
    lwz r4, 0xC(r1)
    subi r4, r4, 0x1
    stw r4, 0xC(r1)
    cmpwi r4, 0x0
    bge+ loop
    %branch(0x80758d4c)
}

######################################
Fix Ground Damage Vector v2 [Kapedani]
######################################
.alias atan2 = 0x80400b38
.alias pi = 0x805a4d10

.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
}
.macro ld(<freg>, <reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lfd     <freg>, temp_Lo(<reg>)
}
.macro call(<addr>)
{
    %lwi(r12, <addr>)
    mtctr r12
    bctrl    
}

op nop @ $807683e4  # skip 361 check so that can calculate lr
CODE @ $8076841c    # soDamageModuleImpl::setGroundDamage
{
    lfs	f2, 0x20(r1)    # \ get x and y
    lfs f1, 0x24(r1)    # /
    fneg f8, f6         # lr = -1.0
    fcmpo cr0, f2, f7   # \ checkif x < 0
    bge+ positive       # / 
    fmr f8, f6          # lr = 1.0
positive:
    stfs f8, 0x7C(r30)  
    lwz r0,0x14(r28)    # \
    cmpwi r0, 361       # | check if angle 361
    bne+ 0x68           # /
    fabs f2, f2         # make x dir positive 
    %call (atan2)       
    lfs	f7, 0x3C(r31)   # \
    fcmpo cr0, f1, f7   # |
    bge+ 0x2C           # | 
    %ld(f8, r12, pi)    # | angle = angle >= 0 ? angle : 2*pi + angle
    fadds f8, f8, f8    # |
    fadds f1, f8, f1    # |
    b 0x18              # /
}
op b 0x44 @ $80768848   # skip assigning lr based on wall hit

######################################################################
Stage Speed Affects Motion Paths, Wind, Conveyors and Water [Kapedani]
######################################################################
.alias g_GameGlobal                         = 0x805a00E0
.alias g_globalMotionRatio                   = 0x80B33680 

.macro lf(<freg>, <reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lfs     <freg>, temp_Lo(<reg>)
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


op nop @ $80979670  # grGimmickMotionPath::startMove        # \
op nop @ $80979708  # grGimmickMotionPath::startMove        # | disable applying global motion ratio (apply later)
op nop @ $8097955c  # grGimmickMotionPath::setFrameUpdate   # |
op nop @ $80979268  # grGimmickMotionPath::processAnim      # /
HOOK @ $80978edc    # grGimmickMotionPath::processAnim
{
    lfs	f0, 0x158(r3)   # Original operation
    %lwd(r12, g_GameGlobal) 
    lwz r12, 0x44(r12)      
    lfs f4, 0x4(r12)    # g_GameGlobal->stageData->motionRatio
    lfs f5, 0x8(r12)    # g_GameGlobal->stageData->motionSubRatio
    fmuls f4, f4, f5    # multiply together
    %lf(f5, r12, g_globalMotionRatio)
    fmuls f4, f4, f5    # multiply with global motion ratio
    fmuls f0, f0, f4    # multiply with motion ratio of motion path
}
HOOK @ $80979288    # grGimmickMotionPath::processAnim
{
    lfs	f1, 0x158(r3)   # Original operation
    %lwd(r12, g_GameGlobal) 
    lwz r12, 0x44(r12)      
    lfs f4, 0x4(r12)    # g_GameGlobal->stageData->motionRatio
    lfs f5, 0x8(r12)    # g_GameGlobal->stageData->motionSubRatio
    fmuls f4, f4, f5    # multiply together
    %lf(f5, r12, g_globalMotionRatio)
    fmuls f4, f4, f5    # multiply with global motion ratio
    fmuls f1, f1, f4    # multiply with motion ratio of motion path
}
HOOK @ $80979240    # grGimmickMotionPath::processAnim
{
    fmuls f2,f0,f3  # Original operation
    %lwd(r12, g_GameGlobal) 
    lwz r12, 0x44(r12)      
    lfs f4, 0x4(r12)    # g_GameGlobal->stageData->motionRatio
    lfs f5, 0x8(r12)    # g_GameGlobal->stageData->motionSubRatio
    fmuls f4, f4, f5    # multiply together
    fmuls f2, f2, f4    # multiply with motion ratio of motion path
}
HOOK @ $80979334    # grGimmickMotionPath::update
{
    lfs	f1, 0x15C(r3)   # Original operation
    %lwd(r12, g_GameGlobal) 
    lwz r12, 0x44(r12)      
    lfs f4, 0x4(r12)    # g_GameGlobal->stageData->motionRatio
    lfs f5, 0x8(r12)    # g_GameGlobal->stageData->motionSubRatio
    fmuls f4, f4, f5    # multiply together
    %lf(f5, r12, g_globalMotionRatio)
    fmuls f4, f4, f5    # multiply with global motion ratio
    fmuls f1, f1, f4    # multiply with motion ratio of motion path
}
HOOK @ $80979370    # grGimmickMotionPath::fixedPosition
{
    lfs	f1, 0x15C(r3)   # Original operation
    %lf(f5, r12, g_globalMotionRatio)
    fmuls f1, f1, f5    # multiply with global motion ratio
}

HOOK @ $80935cfc    # stAreaManager::getMovementArea
{
    lfs	f0, 0x8(r4)     # Original operation
    %lwd(r12, g_GameGlobal) 
    lwz r12, 0x44(r12)      
    lfs f4, 0x4(r12)    # g_GameGlobal->stageData->motionRatio
    lfs f5, 0x8(r12)    # g_GameGlobal->stageData->motionSubRatio
    fmuls f4, f4, f5    # multiply together
    fmuls f0, f0, f4    # multiple with speed
}
HOOK @ $80935d70    # stAreaManager::getMovementArea
{
    lfs	f0, 0x8(r4)     # Original operation
    %lwd(r12, g_GameGlobal) 
    lwz r12, 0x44(r12)      
    lfs f4, 0x4(r12)    # g_GameGlobal->stageData->motionRatio
    lfs f5, 0x8(r12)    # g_GameGlobal->stageData->motionSubRatio
    fmuls f4, f4, f5    # multiply together
    fmuls f0, f0, f4    # multiple with speed
}
HOOK @ $80935e28    # stAreaManager::getWater
{
    lfs	f0, 0xC(r4)     # Original operation
    %lwd(r12, g_GameGlobal) 
    lwz r12, 0x44(r12)      
    lfs f4, 0x4(r12)    # g_GameGlobal->stageData->motionRatio
    lfs f5, 0x8(r12)    # g_GameGlobal->stageData->motionSubRatio
    fmuls f4, f4, f5    # multiply together
    fmuls f0, f0, f4    # multiple with speed
}