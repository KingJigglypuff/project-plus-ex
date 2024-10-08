###############################################
Sword Trail Hitlag fix V2 [MarioDox,DukeItOut]
###############################################
# Makes it so trail effects will stop
# alongside the object that created them
# like in other Smash Bros. games.
#
# V2: Fixed issue where certain trails
# actually don't want to have hitstop.
#
# R.O.B.'s laser is the only example where this 
# is currently desired to have an exception.
###############################################
HOOK @ $800656A8
{
	mr r4, r3 			# Original operation
	stw r21, 0x98(r3)	# Trace ID for future reference	(normally a trace is a size of 0x84.)
						# (We're abusing allocation logic that makes it instead reserve 0xA0!)
}
HOOK @ $80065750
{
	mr r4, r3			# Original operation 
	stw r21, 0x98(r3)	# Trace ID for future reference (though this is for when no texture is found!)
}
HOOK @ $800659F0
{
	cmplw r29, r0		# Original operation
	beq- %END%			# If it was already going to not branch then don't read below!
	lwz r3, 0x98(r31)	# Custom Trace ID variable
	cmplwi cr1, r3, 0xC;	blt+ cr1, ForcePause	# \ normal R.O.B. laser traces
	cmplwi cr1, r3, 0xD;	ble- cr1, %END%			# /
	cmplwi cr1, r3, 0x1EB;	blt- cr1, ForcePause	# \ ef_custom23 (R.O.B.)
	cmplwi cr1, r3, 0x1F4;  ble- cr1, %END%			# / 
ForcePause:
	crnot 2, 2			# inverts the "bne" determination from the first operation comparison
						# so that it won't branch away from pausing
}

#########################################################
Solid Trail ID Specifier [MarioDox, DukeItOut]
#########################################################
.macro trailIsSolid(<traceID>)
{
    cmpwi    r26, <traceID>
    beq-    ForceSolid
}
.macro trailIsSolidRange(<traceMinID>,<traceMaxID>)
{
    cmpwi    r26, <traceMinID>
    blt+	 0xC
	cmpwi	 r26, <traceMaxID>
	ble-	 ForceSolid
}
HOOK @ $8006131c
{
    stw        r31, 0x8(r1)     		# original op
    %trailIsSolid(0x174)        		# Dark Pit
    %trailIsSolid(0x175)        		# Classic Pit
	%trailIsSolidRange(0x1ED, 0x1EE)	# Virtual Boy ROB normal, max laser
	%trailIsSolidRange(0x462, 0x463)	# Sceptile Seed trails
    b %END%
ForceSolid:
    li        r6, 0x1           # Tells the game this trail won't be see through
}

#################################
ecTrace render Fix [MarioDox]
#################################
# Fixes a weird issue where one side of Sword Trails would not render if no effect is on screen and if the hud was enabled.
HOOK @ $800662dc #renderXlu/[ecTrace]
{
    stw        r0, 0x314(r1)
    mr         r16, r3
    li         r3, 0x0             # Cull Mode 0 (CULL_NONE)
    stwu     r1, -0x10(r1)
    mflr     r0
    lis     r12, 0x801F         # \
    ori     r12, r12, 0x136C     # | GXSetCullMode/[GXGeometry]
    mtctr     r12                 # |
    bctrl                         # /
    addi     r1, r1, 0x10
    mr         r3, r16
}