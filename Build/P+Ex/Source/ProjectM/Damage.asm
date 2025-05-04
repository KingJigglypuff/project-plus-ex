##################################################################################
[Project M] Half Damage from Outside Sources While Grabbed v1.3 [Magus, DukeItOut]
##################################################################################
HOOK @ $80769E58
{
	lfs f0, 4(r31)		# Original operation
  
	lwz r4, 0x3C(r23)		# \
	lwz r4, 0x08(r4)		# |
	lwz r5, 0x3C(r4)		# |
	lwz r5, 0xA4(r5)		# | Check if a fighter.
	mtctr r5				# |
	mr r5, r3				# |
	bctrl					# |
	cmpwi r3, 0				# |
	mr r3, r5				# |
	bne- %END%				# /
  
  
  lwz r4, 0x60(r4)	
  lwz r5, 0x5C(r4)		  # \
  lwz r5, 0x94(r5)		  # | Get character grabbing
  cmpwi r5, 0; beq- %END% # | (if none, don't bother!)
  lwz r5, 0x44(r5)		  # /
  lwz r6, 0x28(r24)		# \ Owner of hitbox (if a projectile, won't match character grabbing)
  cmpw r5, r6			# /
  beq- %END%			# If it matches, don't halve damage!
	
halveDamage:	
	lfs f2, 0x14(r13)		# \ 
	fmuls f0, f0, f2		# | halve the damage!
	stfs f0, 4(r31)			# /
}

########################################################
Stale Moves Stale Damage Output but not KBG v3.2 [Magus]
########################################################
HOOK @ $80769F5C
{
  //fmuls f2, f27, f28 # Original operation

  lwz r12, 0x28(r24)
  lwz r3, 0x08(r12)
  lwz r3, 0x3C(r3)
  lwz r3, 0xA4(r3)
  mtctr r3
  bctrl
  
  lfs f3, -0x5BA8(r2) # 1.0	# Default used for stage elements and bosses.
  
  andi. r0, r3, 1; bne- loc_0x1C
  # Stage hazards and subspace enemies break this code as they don't have a concept of staling! Use the default value!
  # 0 = Fighter, 1 = Enemy/Boss, 2 = Article, 3 = Stage Hazard, 4 = Item
  
  lwz r12, 0xD0(r12)
  lfs f3, 8(r12)		# Staling multiplier

loc_0x1C:
  fdivs f2, f28, f3		# Divide by staling to remove it from the knockback!
  fctiwz f2, f2
  stfd f2, 0x10(r2)
  lhz r12, 0x16(r2)		# save this int
  lfd f0, -0x7B90(r2)	# 176.0* (slightly modified for int conversion)
  stfd f0, 0x10(r2)
  sth r12, 0x16(r2)
  lfd f2, 0x10(r2)		# Basically this is flooring the perceived damage to the nearest whole number
  fsub f2, f2, f0
  fmuls f2, f27, f2
}

#####################################
Stale Move Ratio Modifier [spunit262]
#####################################
float[10] 0.0, 0.09, 0.08, 0.07, 0.06, 0.05, 0.04, 0.03, 0.02, 0.01 @ $80FC0988
#First one is a Freshness bonus. Starting from second float, the queue starts. Damage - (Damage * (Total Queue floats))

######################################################
Store Hitbox Damage into Variables On Hit v1.3 [Magus]
######################################################
HOOK @ $8083FDF8
{
  stfs f30, 0x114(r29)	# Original operation
  
  lfs f1, 0x10(r13)	# 0.0
  
  lwz r12, 0x70(r31) # \
  lwz r12, 0x20(r12) # | LA-Float
  lwz r12, 0x14(r12) # /
  
  lbz r0, 0x21(r30)
  cmpwi r0, 1; beq- hitHurt   # Hit Hurtbox
  cmpwi r0, 2; beq- hitResist # Hit Shield/Counter
  cmpwi r0, 0; bne- %END%     # Hit Hitbox (Absorbers are 4. Not checked here.)
							  # Reflectors are probably 3, but no non-projectile attacks
							  # can be reflected, even in later Smash titles.
hitResist:	# Hit a Shield, Counter or opposing Hitbox
  stfs f30, 0x18(r12)	# Set LA-Float 6
  stfs f1, 0x1C(r12)	# Clear LA-Float 7
  b %END%

hitHurt:	# Hit a Hurtbox
  stfs f30, 0x1C(r12)	# Set LA-Float 7
  stfs f1, 0x18(r12)	# Clear LA-Float 6
}

###########################################
Store Damage Absorbed into Variable [Magus]
###########################################
HOOK @ $807531AC
{
  lwz r5, 0x70(r29)	# \
  lwz r5, 0x20(r5)	# | LA-Float 6
  lwz r5, 0x14(r5)	# |
  stfs f1, 0x18(r5) # /
  mr r5, r27
}