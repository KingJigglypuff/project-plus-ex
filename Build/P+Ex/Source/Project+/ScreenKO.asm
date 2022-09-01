##########################################
Screen KO Timer & Position Modifier [ds22]
##########################################
int 0x3F @ $80FA044C
int 0x3E @ $80FA0454
int 0x2D @ $80FA0458
float 133.320007 @ $80FA0460
float -10.0 @ $80FA046C


###############################################################
Frozen StarScreen KO goes into regular StarSceen KO V1.1 [ds22]
###############################################################
op b 0x5C @ $8087C93C
op b 0x58 @ $8087CB60

##############################################################
[Project+] Screen KO Camera Doesn't Zoom inappropriately [Eon]
##############################################################
HOOK @ $8087CD4C
{
	lwz r3, 0xD8(r27)
	lwz r3, 0x64(r3)
	lis r4, 0x1000
	lwz r12, 0(r3)
	lwz r12, 0x18(r12)
	mtctr r12
	bctrl
	mr r31, r3 	#get Entity ID

	lwz r3, 0xD8(r27)
	lwz r3, 0x60 (r3)
	addi r4, r1, 0xf8
	li r5, 0
	lwz r12, 0 (r3)
	lwz r12, 0xC4(r12)
	mtctr r12
	bctrl 		#getSubjectRange, placed into r1+0xf8

	lis r26, 0x80B8
	lwz r29, 0x7C28(r26)
	lwz r28, 0xD8(r27)
	lwz r25, 0xC(r28)
	lwz r28, 0x60(r28)

	li r3, 0xB0 #time for temp camera
	lis r12, 0x8087
	ori r12, r12, 0xc7BC
	mtctr r12
	bctr
}
op b 0x28C @ $8087CAC0 #star ko point to above injection to fix couple frames of zoom on that


#############################################################
[Project+] Guarantee Pain Voice Clip on Screen KO [DukeItOut]
#
# Makes it bypass an oversight in the Brawl coding that could 
# make hitting the screen not call a voice clip, occasionally
#############################################################
op lwz r4, 4(r4) @ $8087D3E4

#####################################################################
[Project+] Melee-Style Screen KO Animation Sequence [ds22, DukeItOut]
# Based on "Screen KO Direction Fix [ds22]"
# Forces a subaction change when they bounce off of the screen
#####################################################################
float 1.4  @ $80FA0474  # Screen Ricochet initial Y speed (normally 1.0)
float 0.28 @ $80FA0478  # Screen Ricochet Y acceleration (normally 0.2)
float 2.5  @ $80FA047C  # Screen Ricochet Y max downward speed (inverse of the above, normally 1.7)
float -0.2 @ $80FA0480  # Screen Ricochet Z speed (normally -1.0)
# This part operates when screen KOs start
HOOK @ $8087CBC4
{
	lwz r3, 0x18(r27)	# \
	lis r4, 0x42B4		# | 90.0 (-90.0 / 0xC2B4 in PM). Forces characters to always face "away from" the screen.
	stw r4, 0x60(r3)	# /
	li r3,  0x29		# \ Set the Screen KO subaction 0x29 (Damage tumble). Original operation.
}
# This part is read when you hit the screen
HOOK @ $8087D3F0
{
	stwu r1, -0x40(r1)

	addi r4, r1, 0x8
    li r3, 0xD0         # Set subaction ID to D0 (Wall impact)
    stw r3, 0x0(r4)     # set subaction ID
	lis r12, 0x3F00		# \
	stw r12, 0x8(r4)	# / animation speed (0.5x)
	li r12, 0			# Clear value
	stw r12, 0x4(r4)	# first frame of animation (0.0)
	stw r12, 0xC(r4)	# \ Clear these two (integer value at 0xC, 4 byte settings at 0x10-0x13)
	stw r12, 0x10(r4)	# /
	lwz r3, 0xD8(r29)	# \
	lwz r3, 0x8(r3)		# |
	lwz r12, 0x0(r3)	# | Change subaction
	lwz r12, 0x80(r12)	# |
	mtctr r12			# |
	bctrl				# /
	
	addi r1, r1, 0x40
	
	lis r12, 0x8087			# \
	ori r12, r12, 0xD828	# | Go to address it normally
	mtctr r12				# | jumps to.
	bctr					# /
}
