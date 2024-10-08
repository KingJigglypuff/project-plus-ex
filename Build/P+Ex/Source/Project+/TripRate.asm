###################################################################
[Project+] Pitfall effect can have no-bury with trip rate 2.0 [Eon]
###################################################################
HOOK @ $8076CE84
{
	lwz r24, 0x60(r19) #load hitbox trip rate
	lis r25, 0x4000    #2.0 float
	cmpw r24, r25 	   #if trip rate = 2.0, dont burry.
	bne buryNormal
dontBury:
#pretends to be angle 0, keeps them grounded no matter the attack strength.
	li r24, 0
	li r25, 0
	lis r12, 0x8076
	ori r12, r12, 0xd0b0 
	mtctr r12
	bctr
buryNormal:
	li 24, 6
}

####################################################
Trip Rate Default for Stage Hazards is 0 [DukeItOut]
####################################################
HOOK @ $80980430
{
  lfs f1, -0x4D60(r4)
  stfs f1, 0x24(r3)
}
op stfs f0, 0x24(r31) @ $8098046C

############################################
Only Trip Rate 1.0 Can Trip Foes [DukeItOut]
############################################
op nop @ $8076D120
op lfs f1, 0x18(r13) @ $8076D124
op bne+ 0x40 @ $8076D130