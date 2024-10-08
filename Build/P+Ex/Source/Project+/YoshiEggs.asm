###########################################################
Yoshi Eggs are Costume Based v1.2β [ds22] 
# 
# 1.1: (char id fix fix)
# 1.2: Made compatible with tex files.
# 1.2β: Reverted mdl+tex compatibility temporarily.
#			(behaves like 1.1)
###########################################################
HOOK @ $80A1580C
{
  	lwz r31, 0x1C(r26); lwz r31, 0x28(r31);  lwz r31, 0x10(r31); lbz r31, 0x55(r31)

	lwz r26, 0x08(r26); lwz r26,0x110(r26)	# Get character instance ID

  	cmpwi r26, 0x5;     beq- Kirby
Yoshi:
  	lis r26, 0x80B8;    lwz r26, 0x7C50(r26);lwz r26, 0(r26)
  	mulli r31, r31, 0x4D4
  	add r26, r26, r31
  	# lwz r4, 0x20(r26)	# 0x18 + 8	# 1.2 version, requires Mdl+Tex split codes
	
	# 1.1/1.2β Loop through costume slots. The block below until the next 1.1/1.2β comment 
	#	should be removed when updated back to 1.2
	addi r26, r26, 0x18
YoshiLoop:
	lwzu r4, 4(r26); cmpwi r4, 0xFF; bge+ YoshiLoop 
	# 1.1/1.2β
	
	stw r4, 0x14(r1)
	b finish
Kirby:
  	stw r5, 0x14(r1)
finish:
  	mr r31, r3
}
op NOP @ $80A15820	# NOP's original stw r5, 0x14(r1) since the same value is also used for the model and animation

#############################################################
[Project+] Yoshi's eggshell particles are Colored [DukeItOut]
#############################################################
# Use in conjunction with the above code, the code adding 
# support for additional efect animations and a module 
# modified to use these new features
#############################################################
HOOK @ $80892AF8
{
	lwz r3, 0xD8(r29)	# Original operation
	lwz r4, 0x44(r18)	# Parent (Yoshi)
	lwz r4, 0x70(r4)
	lwz r4, 0x20(r4)	# LA
	lwz r4, 0x0C(r4)	# Basic
	lwz r4, 0xD8(r4)	# 54 (Color)
	
	lwz r5, 0x64(r3)
	lwz r5, 0x24(r5)	# RA
	lwz r5, 0x0C(r5)	# Basic
	stw r4, 0x40(r5)	# 16 (store Yoshi color)
}
HOOK @ $80A15CE0
{
	stw r5, 0x10(r1)		# We need this still.
	lwz r3, 0x60(r6)		# Character inside egg.	
	lwz r3, 0x70(r3)		#
	lwz r3, 0x24(r3)		# RA
	lwz r3, 0x0C(r3)		# Basic
	lwz r8, 0x40(r3)		# 16: Costume ID of the Yoshi that made this egg.
    lis r12, 0x8006
    ori r12, r12, 0x06A8
    mtctr r12 
	li r4, 2			# CHR animation to use
	mr r5, r8
	mr r6, r8
	li r7, 0
	li r9, 128			# Custom identifier
    bctrl				# Set the animation indexes of this effect!	

	lwz r5, 0x10(r1)
	lis r3, 0x80AE		# Original operation.
}

#########################################################
[Project+] Yoshi's Egg break out intang 14 > 9 [Fracture]
#########################################################
int 9 @ $80B88FD4

##############################################
Yoshi Eggs don't despawn when Yoshi dies [Eon]
##############################################
op nop @ $80A15CC0

##############################################################
[Project+] Egged Damage Multiplier (0.5x -> 0.75x) [DukeItOut]
##############################################################
float 0.75 @ $80B88758
