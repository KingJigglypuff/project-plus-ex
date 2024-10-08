#############################################
Event Status3 is Turbo [Bero]
#############################################
HOOK @ $806EEA74
{
  lbz r5, 0(r23)
  cmpwi r4, 3
  blt- %END%
  
  li r4, 2
  or r5, r5, r4
  stb r5, 1(r23)
  lis r5, 0x806E
  ori r5, r5, 0xEA9C
  mtctr r5
  bctr 
}

###############################################################
Event Rule Fixes [ds22, Eternal Yoshi, mawwwk, Magus, Motobug]
###############################################################
op b -0x250		@ $806D5F84 # Event #2: Remove constant P1 Final Smash

op nop			@ $806D5D84	# \ Event #4: Remove stage-specific win con (Skyworld platform breaking)
op li r0, 5		@ $806D5D88	# | 
op nop			@ $806D5D8C	# / 

op li r3, 1		@ $806D5F70	# Event #17: Remove stage-specific win con (Rumble Falls climb)

op li r3, 1		@ $806D5DF8	# Event #32: "Success!" instead of "Time!" on event clear

op nop			@ $806D60C4	# \ Event #28: Remove stage-specific win con (Hanenbow platform coloring)
op li r0, 5		@ $806D60C8	# |
op nop			@ $806D60CC # /

op b -0x3A0 	@ $806D617C # Event #30: Survive win con

op b 0x50		@ $806D644C	# Co-op Event #16: Remove Jigglypuff final smash win condition

# No longer used:
# op li r3, 1 @ $806D6038 # Event #23: Remove stage-specific win con (Norfair safety capsule)