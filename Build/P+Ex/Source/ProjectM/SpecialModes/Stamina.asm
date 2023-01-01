##################################
P+ Stamina 5.0 [wiiztec,DukeitOut, ReplayFix by Eon]
##################################
HOOK @ $8077FB78
{
	lis r12,0x9018
	lbz r12, -3208(r12) 	#loads value of stamina/300% mode flag into r11
	cmpwi r12,2 
	bne ssdfc 				#branch to end if not stamina mode
	lis r12,0x8058
	ori r12,r12,0x82AC 		#loads stamina dead flags address into r12
	lwz r11,0x1C(r31) 		#(1)
	lwz r11,0x28(r11) 		#(2)
	cmplwi r11,0xFFFF
	ble end 				#branches to end if the value in r11 is not an address (prevents crashing from trying to load from a nonexistant address)
	lwz r11,0x10(r11) 		#(3)
	cmplwi r11,0xFFFF
	ble end 				#branches to end if the value in r11 is not an address (prevents crashing from trying to load from a nonexistant address)
	lbz r11,0x55(r11) 		#(1 2 3) loads player number ID into r11
	lbzx r6,r12,r11 		#loads current player stamina dead flag byte
	cmpwi r30,0xBE
	bne co 					#branches to continue on if character action is not respawn
	stbx r7,r12,r11 		#clears current player stamina dead flag
co:
	cmpwi r6,0x1D
	bne end 				#checks if current player stamina dead flag was set and branches to end if not
	cmpwi r30,0x4D
	bne end 				#branches to end if character is not lying down (allows for corpse juggling)
	stwu r1, -0x30(r1)
	lwz r8, 0x10(r31)		# \ Get Model Scale 
	lfs f0, 0x4C(r8)		# /
	lwz r8, 0x28(r31)		# \
	lfs f1, 0x60(r8)		# | Multiply Model Scale with Context Scale (Giant, Mini, etc)
	fmuls f0, f0, f1		# |
	stfs f0, 0x8(r1)		# /
	lis r3, 0x805A			# \
	lwz r3, 0x148(r3)		# / Consider the stage the owner
	addi r5, r1, 0xC		# pointer to XYZ position data
	li r6, 0				# pointer to XYZ rotate data (0 = not read)
	addi r7, r1, 0x18		# pointer to XYZ scale data
	lwz r4, 0x18(r31)		# \
	lfs f0, 0x0C(r4)		# | Get XYZ Pos
	lfs f1, 0x10(r4)		# |
	lfs f2, 0x14(r4)		# |
	stfs f0, 0x0(r5)		# |
	stfs f1, 0x4(r5)		# |
	stfs f2, 0x8(r5)		# /
	lfs f0, 0x8(r1)			# Get character size
	lis r4, 0x3F00			# \ 1.25x multiplier
	stw r4, 0x0(r7)			# |
	lfs f1, 0x0(r7)			# |
	fmuls f0, f0, f1 		# |
	stfs f0, 0x0(r7)		# |
	stfs f0, 0x4(r7)		# |
	stfs f0, 0x8(r7)		# /
	li r4, 0x4C				# Firecracker explosion (bank 0, ID 0x4C)
	lis r12, 0x8005			# \ 
	ori r12, r12, 0xF7E0	# | Run firecracker explosion effect
	mtctr r12				# |
	bctrl					# /
	lis r3, 0x805A
	lwz r3, 0x148(r3)  
	addi r5, r1, 0xC
	li r6, 0
	addi r7, r1, 0x18
	lfs f0, 0x8(r1)			# Model Scale
	stfs f0, 0x0(r7)
	stfs f0, 0x4(r7)
	stfs f0, 0x8(r7)
	lis r4, 0x104
	ori r4, r4, 0xD  		# Blue Flash (bank 0x104, ID 0xD)
	lis r12, 0x8005			# \ 
	ori r12, r12, 0xF7E0	# | Run flash sphere explosion effect 
	mtctr r12				# |
	bctrl					# / 
	addi r1, r1, 0x30 
	li r30,0xBD 			#set current player action to death
end:

ssdfc:
	stw r30,52(r29) 		#original instruction at hooked address
}

HOOK @ $800E14A4
{
  stwu r1, -32(r1)
  lis r12, 0x9018
  lbz r12, -3208(r12);  cmpwi r12, 0x2;  bne- %END%
  lis r0, 0x8120;  		cmplw r21, r0;  bgt- %END%
						cmplw r30, r0;  blt- %END%
  lbz r11, 2(r30);  	mulli r11, r11, 0x5C
  lis r12, 0x9018;  	ori r12, r12, 0xC1C
  lhzx r4, r12, r11

}
HOOK @ $80816108
{
	cmpwi r24, 0x5;  bne- loc_0x1C
   	addi r3, r3, 0x1

loc_0x1C:
  	subic. r21, r3, 1
}
# HOOK @ $80816588
# {
#   cmpwi r20, 0x0
#   beq %end%

# loc_0x18:
#   addi r5, r5, 0x1

# }

# HOOK @ $80816088
# {
#   cmpwi r20, 0x0
#   beq- %end%

# loc_0x18:
#   addi r4, r4, 0x1
# }

# HOOK @ $80816794
# {
# loc_0x0:
#   mr r0, r3
#   cmpwi r20, 0x0
#   beq- loc_0x20

# loc_0x1C:
#   addi r0, r3, 0x1

# loc_0x20:

# }
op b 0x80 @ $8083BBA0 #disable stamina death from double counting death (replaces above three branches involving r20)


* C20E1588 00000005
* 2C180005 40820018
* 3800001D 3D808058
* 618C82AC 897B0001
* 7C0C59AE 9421FF90
* 60000000 00000000

op nop @ $8083BAE0 #disable red flash from being dead.

* C2766828 00000005
* 3D809018 896CF378
* 2C0B0002 40820010
* 896CF37E 2C0B0001
* 40820008 981E0048
* 60000000 00000000
#start/[scMelee]
HOOK @ $806CF1B4
{
loc_0x0:
  lwz r3, 4(r4)
  lis r12, 0x9018
  lbz r12, -3208(r12)
  cmpwi r12, 0x2
  bne- loc_0x28
  cmpwi r0, 0x12
  bne- loc_0x28
  li 0, 0
  lis r12,0x8058
  ori r12,r12,0x82AC
  stw r0, 0(r12) 			#clears stamina dead flags for all players

  rlwinm r3, r3, 24, 8, 31
  rlwinm r3, r3, 8, 0, 23
  ori r3, r3, 0x28

loc_0x28:
}
* 046DF124 48000018


op li r3, 0x0 @ $80816090
op li r0, 0x0 @ $8083B844
op nop @ $806DF0FC
op li r3, 0x40 @ $809559F0
op nop @ $80947370
op li r0, 0x0 @ $806A5C78
op li r0, 0x0 @ $806A8570
op b 0x8 @ $806DEB3C
op b 0xC @ $806DEDF0
op li r0, 0x0 @ $8068F04C
op li r0, 0x0 @ $8068F290
op li r0, 0x0 @ $80690754
op li r29, 0x64 @ $806A0350
op li r30, 0x64 @ $8069F3D4
op li r30, 0x64 @ $8069F898
op li r31, 0x64 @ $8069FDD4
op li r0, 0x0 @ $800E5B94

HOOK @ $8005542C
{
  lis r12, 0x9018
  lbz r12, -3208(r12);  cmpwi r12, 0x2;  beq- loc_0x18
  lwz r6, 16(r4)
  b %END%

loc_0x18:
  cmpwi r0, 0x0;  beq- loc_0x40
  cmpwi r0, 0x1;  beq- loc_0x48
  cmpwi r0, 0x2;  beq- loc_0x50
  cmpwi r0, 0x3;  beq- loc_0x58
  cmpwi r0, 0x4;  beq- loc_0x50

loc_0x40:
  li r12, 0x101;  b loc_0x5C

loc_0x48:
  li r12, 0x102;  b loc_0x5C

loc_0x50:
  li r12, 0x202;  b loc_0x5C

loc_0x58:
  li r12, 0x201

loc_0x5C:
  sth r12, 36(r3)
  li r0, 0x0
}
* 046873B0 38000000
HOOK @ $8085CCF8
{
  lbz r3, 109(r3)
  lis r12, 0x9018
  lbz r11, -3196(r12);  cmpwi r11, 0x2;  bne- %END%
  li r3, 0x0
}

P+ Stamina X/Y world wrap option 5.3 [wiiztec,Phantom Wings,Magus]
* C272E8A4 00000013
* 3D809018 896CF378
* 2C0B0002 40820010
* 896CF385 2C0B0002
* 4182000C D043000C
* 48000074 3D8080B8
* 618CA428 818C0000
* 816C0080 3D808058
* 618C82A4 C2AC001C
* C2CCFFFC C2EC0030
* C22B0000 C24B0004
* C26B0008 C28B000C
* EE31B828 EE52B82A
* 3D609018 896B0F3B
* 2C0B000B 41820010
* EE73A82A EE94A828
* 4800000C EE73A828
* EE94B028 D22C0010
* D24C0018 D26C0004
* D28C0024 00000000

HOOK @ $8072E8A8
{
	lis r12,0x9018
	lbz r11, -3208(r12) #loads value of stamina/300% mode flag into r11
	cmpwi r11,2 
	bne oi #branch to original instruction if not stamina mode
	lbz r11, -3195(r12)
	cmpwi r11,2 #loads value of blastzones on/off flag into r11
	beq co #branch to continue on if stamina type 2, 3 or 5
oi:
	stfs f1,16(r3)
	b endend
co:
	stwu r1,-128(r1)
	stmw r2,8(r1) #creates a stack frame so I can freely use all registers
	lis r11,0x8000 #loads 0x80000000 into r11
	lwz r5,136(r3) #phantom wings stuff
	stfs f1,4(r4) #?????
	lis r6,0x8058
	ori r6,r6,0x82A4 #loads address of XYWW floats into r6
	lfs f17,4(r4) #loads float coordinate of current player's Y position into f17
	lfs f18,4(r6) #loads float coordinate of stage's top wrap point into f18
	lfs f19,0x24(r6) #loads float coordinate of stage's bottom wrap point into f19
	lwz r17,4(r4) #loads float coordinate of current player's Y position into r17
	lwz r18,4(r6) #loads float coordinate of stage's top wrap point into r18
	lwz r19,0x24(r6) #loads float coordinate of stage's bottom wrap point into r19
	lfs f20,0(r4) #loads float coordinate of current player's X position into f20
	lfs f21,0x10(r6) #loads float coordinate of stage's left wrap point into f21
	lfs f22,0x18(r6) #loads float coordinate of stage's right wrap point into f22
	lwz r20,0(r4) #loads float coordinate of current player's X position into r20
	lwz r21,0x10(r6) #loads float coordinate of stage's left wrap point into r21
	lwz r22,0x18(r6) #loads float coordinate of stage's right wrap point into r22
detcd:
	li r7,7
	li r8,0
	lbz r9,188(r3)
	cmpwi r9,7
	bne sc #branch to sanity check if r9 isn't 7
	li r9,5
	stb r9,188(r3) #phantom wings stuff (part of the original x world wrap code, I don't know what it does)
sc:
	cmpwi r30,8
	bne end #branches to end if r30 isn't 8 (prevents crash)
	lwz r12,0x1C(r31) #(1)
	cmplw r12,r11
	blt end #sanity check, branches to end if r12 is not a valid address
	lwz r12,0x28(r12) #(2)
	cmplw r12,r11
	blt end #sanity check, branches to end if r12 is not a valid address
	lwz r27,0x10(r12)
	lbz r24,0x55(r27) #(1 2) loads player number ID into r24
	lwz r28,0x10(r27) #loads value that can identify what is wrapping into r28?
	cmplwi r28,0xFFFF
	bgt end #branches to end if value in r28 is greater than 0xFFFF to prevent items from wrapping
	addi r11,r6,0x08 #loads stamina dead flags address into r11
	lbzx r25,r11,r24 #loads current player stamina dead flag byte into r25 from stamina dead flags address + PNID
	cmpwi r25,0x1D
	beq end #branches to end if current player's stamina dead flag is set (to allow blastzones to corpse cleanup)
	lwz r12,0x7C(r31)
	lhz r11,0x06(r12) #loads current player previous action into r11
	lhz r12,0x3A(r12) #loads cureent player action into r12
	cmpwi r12,0xBC
	beq end #branches to end if current action is drowning (if allowed you would drown forever)
	cmpwi r12,0xBE
	beq end #branches to end if current action is respawn (if allowed you take wrap damage on respawn)
	cmpwi r12,0xC6
	beq end #branches to end if current action is eaten by summit fish (if allowed you're trapped in the fish)
	cmpwi r12,0xF1
	beq end #branches to end if current action is Kirby/MK uthrow (if allowed you take wrap damage and jump up through the stage)
	cmpwi r11,0x116
	beq end #branches to end if current action is final smash (some final smashes crash when wrapping)
	lwz r11,0x64(r31)
	lwz r11,-0xC(r11)
	lbz r11,0x3F(r11) #loads current player is grabbed/being thrown flag into r11
	cmpwi r11,1
	beq end #branches to end if current player is grabbed/thrown (prevents ganondorf/kirby/DDDK cheese)
scc:
	fcmpo cr0,f17,f18
	blt bwpc #branches to bottom wrap point check if current player's Y coordinate is less than the stage's top wrap point
	li r10,0xAD #sets flag 0xAD in r10 indicating a wrap is in progress
	subis r17,r19,1 #sets current player Y coordinate to bottom wrap point -0x10000 (adds about .5-1 in float)
bwpc:
	fcmpo cr0,f17,f19
	bgt lwpc #branches to left wrap point check if current player's Y coordinate is greater than the stage's bottom wrap point
	li r10,0xAD #sets flag 0xAD in r10 indicating a wrap is in progress
	subis r17,r18,1 #sets current player Y coordinate to top wrap point -0x10000 (subtracts about .5-1 in float)
lwpc:
	fcmpo cr0,f20,f21
	bgt rwpc #branches to right wrap point check if current player's X coordinate is greater than the stage's left wrap point
	li r10,0xAD #sets flag 0xAD in r10 indicating a wrap is in progress
	subis r20,r22,1 #sets current player X coordinate to right wrap point -0x10000 (subtracts about .5-1 in float)
rwpc:
	fcmpo cr0,f20,f22
	blt adc #branches to AD check if current player's X coordinate is less than the stage's right wrap point
	li r10,0xAD #sets flag 0xAD in r10 indicating a wrap is in progress
	subis r20,r21,1 #sets current player X coordinate to left wrap point -0x10000 (adds about .5-1 in float)
adc:
	cmpwi r10,0xAD
	bne end #branches to end if a wrap is not in progress
	stb r7,0xBC(r3)
	stb r8,0x75(r5) #phantom wings stuff (part of the original x world wrap code, disables stage collision while wrapping)
	nop
	addi r30,r6,0x38 #Loads WD AD flags address into r30
	lwz r12,8(r31)
	lwz r11,0x110(r12) #loads alternate character ID into r11
	cmpwi r11,0xF
	bne fs #branches to flag store if character isn't ice climbers
	lhz r11,0xFC(r12) #loads popo or nana ID into r11
	cmpwi r11,1
	beq nwd #branches to no wrap damage if nana
fs:
	stbx r10,r30,r24 #stores AD flag to WD AD flags address + PNID
nwd:
	subi r30,r30,4
	stbx r10,r30,r24 #stores AD flag to HI AD flags address + PNID
	stb r24,0x0C(r6) #stores current player PNID
end:
	stw r17,16(r3) #stores current player Y coordinate
	stw r20,12(r3) #stores current player X coordinate
	lmw r2,8(r1) #reloads previous register values back from the stack
	addi r1,r1,128 #sets stack pointer back to where it was before now that the space is free again
endend:
}


float 5.0 @ $805882D4
float 20.0 @ $805882C0
float 60.0 @ $805882A0
float 5.0 @ $805882B8

* C2118E24 0000000B
* 3D809018 896CF378
* 2C0B0002 40820044
* 896CF385 2C0B0002
* 40820038 3D608000
* 7C1F5840 4180002C
* 881F0055 3D80901C
* 618C4928 7D6C00AE
* 2C0B00AD 40820014
* 896CFFE0 7C0B0000
* 40820008 4E800020
* 9421FE60 00000000
* 141C4900 41A00000
* 141C4920 42700000



HOOK @ $8076052C
{	
	#temporary normal interpolation fix, moves the problem to only within stamina mode
	lis r12,0x9018
	lbz r11, -3208(r12) #loads value of stamina/300% mode flag into r11
	cmpwi r11,2 
	bne end 			#branch to original instruction if not stamina mode


	lis r7,0x8000 #loads 0x80000000 into r7
	lis r12,0x8138 #loads 0x81380000 into r11
	lwz r11,0xC8(r24) #(1)
	cmplw r11,r7
	blt end

	cmplw r11,r12
	bgt end #sanity checks, they branch to end if value in r11 is invalid as an address

	lwz r11,0x1C(r11) #(2)
	cmplw r11,r7
	blt end

	cmplw r11,r12
	bgt end #sanity checks, they branch to end if value in r11 is invalid as an address

	lwz r11,0x28(r11) #(3)
	cmplw r11,r7
	blt end

	cmplw r11,r12
	bgt end #sanity checks, they branch to end if value in r11 is invalid as an address

	lwz r11,0x10(r11) #(4)
	cmplw r11,r7
	blt end

	cmplw r11,r12
	bgt end #sanity checks, they branch to end if value in r11 is invalid as an address

	lbz r11,0x55(r11) #(1 2 3 4) loads player number ID into r11
	lis r12,0x8058
	ori r12,r12,0x82D8 #loads interpolation AD flags address into r12
	lbzx r7,r12,r11 #loads current player's currently wrapping flag (AD) into r7 from interpolation AD flags address + PNID
	cmpwi r7,0xAD
	blt end #branches to end if interpolation AD flag not set

	li r27,1 #loads 1 into r27 (if r27 is 1 hitboxes are not interpolated)
	addi r7,r7,1 #adds 1 to AD flag
	stbx r7,r12,r11 #stores incremented AD flag to interpolation AD flags address + PNID
	cmpwi r7,0xB2
	blt end #branches to end if interpolation AD flag is not 0xB0 yet (used as a timer to disable hitbox interpolation for 3 frames)

	stbx r15,r12,r11 #clears current player interpolation AD flag
end:
	cmplwi r27,1 #original instruction at hooked address
}


* C276802C 0000000C
* C03A0094 3D808058
* 618C82DC 3D608100
* 8076003C 7C035840
* 41800040 8063001C
* 7C035840 41800034
* 80630028 7C035840
* 41800028 80630010
* 7C035840 4180001C
* 88630055 7D6C18AE
* 2C0B00AD 4082000C
* C02CFFDC 7DEC19AE
* 60000000 00000000

HOOK @ $80960F48
{
	lbz r0,180(r3)
	lis r12,0x9018
	lbz r11,-3208(r12) #loads value of stamina/300% mode flag into r11
	cmpwi r11,2 
	bne end #branch to end if not stamina mode
	lbz r11,-3195(r12)
	cmpwi r11,2 #loads value of blastzones on/off flag into r11
	bne end #branch to end if not stamina type 2, 3 or 5
	li r0,0
end:
}
* 205B7458 3FE38E39
* 045882D4 41A00000

* E0000000 80008000


[Legacy TE] New DBZ Lite with camera stabilization 2.0 [wiiztec] [wiiztec,Yohan1044] (write non-zero value to 9018F387 to toggle off)
* C209CB3C 00000032
* 4E800421 9421FF80
* BC410008 3D809018
* 896CF378 2C0B0002
* 40820168 896CF367
* 2C0B0004 4082015C
* 3D808049 896C4A52
* 2C0B0001 4082014C
* 3D80805B 618C6D20
* 3DC08058 61CE8500
* 38E00000 3A400000
* 7E0C942E 7E8E942E
* C2EEFFEC EF10A02A
* EF18B824 EF18A02A
* EF18B824 EF18A02A
* EF18B824 FC10A040
* 4181000C EEB48028
* 48000008 EEB0A028
* C2CEFFE0 2C120060
* 41800010 2C120064
* 41810008 C2CEFFE4
* 2C12002C 4182001C
* 2C12005C 41820014
* 2C120074 4182000C
* 2C1200CC 40820008
* C2CEFFD0 FC15B040
* 4180005C B0EEFFEA
* 896EFFE8 2C0B00DC
* 41820044 A1EEFFDA
* 39EF0001 B1EEFFDA
* A16EFFD6 2C0B0ADC
* 41820014 2C0F0022
* 4180005C 39E00ADC
* B1EEFFD6 A1EEFFD8
* 39EF0001 B1EEFFD8
* 2C0F002F 41800040
* 90EEFFD6 396000DC
* 996EFFE8 896EFFE8
* 2C0B00AC 41820028
* A16EFFEA 2C0B0778
* 396B0001 B16EFFEA
* 41800010 396000AC
* 996EFFE8 B0EEFFEA
* FE00C090 7E0E952E
* 7E0C952E 3A520004
* 2C1200D0 4180FEEC
* A16EFFDC 396B0001
* B16EFFDC 2C0B003C
* 41800008 90EEFFDA
* B8410008 38210080
* 60000000 00000000
* 045884EC 40000000
* 045884E0 40A00000
* 045884E4 3FE374BC
* 045884D0 41200000

######################################################################
Throws Don't Cut Early for Victim Damage in Stamina [codes, DukeItOut]
######################################################################
HOOK @ $8083BCF0  # inside toKnockOut/[Fighter]/(fighter.o)
{
on_call_to_cause_death:
  lwz r12, 0x7C(r5)   # \ 
  lhz r12, 0x3A(r12)  # / path to current action
  cmpwi r12, 0x42     # if in thrown, don't call changeStatusRequest/[soStatusModuleImpl]/(so_status_module_impl.o)
  beq- thrown         # this check should eventually get hit and fail when the throw ends, properly causing the character
  bctrl               # to finally be knocked out from the stamina loss
thrown:
}