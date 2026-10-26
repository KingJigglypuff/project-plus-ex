Barrels Don't Reset Jumps Outside of Subspace [DukeItOut, MarioDox]
HOOK @ $8083CAC0
{
	lwz r12, 0x7C(r25)	# \ Get the action.
	lwz r12, 0x38(r12)	# /
    cmpwi r12, 0xC0		# \ Barrel Cannon Launch Action
    bne+ normal			# / Don't modify behavior for other actions!
    lis r12,0x805B		# \
    lwz r12,0x50AC(r12)	# |
    lwz r12,0x10(r12)	# |
    lwz r12,0x0(r12)	# |
    lwz r12,0x0(r12)	# / get Scene name
    lis r0,0x7371		# sq
    ori r0,r0,0x4164	# Ad(venture)
	cmpw r12, r0
	bne- %END%			# If not matching, then the stage with the barrel isn't in Subspace!
normal:
    bctrl # Reset jump count. Original operation.
}