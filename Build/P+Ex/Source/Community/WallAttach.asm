#####################################################
Projectiles and items can stick anywhere [MarioDox]
#####################################################
# makes it so only fighters are affected by the "can't stick"/"no walljump" flag

HOOK @ $80734904				#attach/[soGroundModuleImpl]
{
	stw r3,0x5C(r1)				# risky, but save soGroundModuleImpl in the stack, as all references to it after get lost
	lwz r3,0x28(r3)				# original op
}

.macro checkKind()
{
	lwz r3,0x5C(r1)				# get the soGroundModule that was saved in the stack
	lwz r3,0x54(r3)				# soGroundModuleImpl->moduleAccesser
	lwz r3,0x8(r3)				# soModuleAccesser->stageObjectPtr
	lwz r12,0x3C(r3)			# \
	lwz r12,0xA4(r12)           # | soGetKind
	mtctr r12					# |
	bctrl						# /
	cmpwi r3,0x0				# is a fighter?
	beq- default
	li r0,0x0					# set this register to 0, as the next command flips it
	b %END%
default:
	rlwinm r0,r0,25,31,31		# original op, gets flag
}

HOOK @ $80734a0c				#attach/[soGroundModuleImpl]
{
	%checkKind()
}

HOOK @ $80734b20				#attach/[soGroundModuleImpl]
{
	%checkKind()
}

HOOK @ $80734c34				#attach/[soGroundModuleImpl]
{
	%checkKind()
}

HOOK @ $80734d48				#attach/[soGroundModuleImpl]
{
	%checkKind()
}