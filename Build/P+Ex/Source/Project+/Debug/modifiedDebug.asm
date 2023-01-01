.include Source/Project+/Debug/renderDebug.asm
.include "Source/Project+/Debug/Hurtboxes Hitboxes.asm"
.include "Source/Project+/Debug/Capsule Renderer.asm"
.include "Source/Project+/Debug/Stage Collisions.asm"
.include "Source/Project+/Debug/soGroundModule.asm"
.include "Source/Project+/Debug/gfSceneRoot.asm"

Debug Start Input v1.2 [Magus, ???, Eon]
* C21E6D1C 0000000D
* 7C03202E 3CC08058
* 60C63FFE A0A60000
* 54A507FF 3CC0805B
* 60C68A0A A0A60000
* 40820010 540700C7
* 41A20038 48000024
* 3CE01000 7CE738F8
* 7C003839 74070408
* 3D000408 7C074000
* 40A20018 64001000
* 2C050000 41A2000C
* 38A00004 B0A60000 #writes 4 instead of 0 here to allow pause to be detected cleanly
* 60000000 00000000

Debug On the Fly Character Switcher v1.4 (Knuckles added by Eon, Ridley added by KingJigglypuff) [Magus, Krisan Thyme, Eon]

HOOK @ $801E6CD8 
{
loc_0x0:
  stwu r1, -40(r1)
  stmw r24, 8(r1)
  lwzx r10, r4, r8
  stwx r6, r4, r8
  not r10, r10
  and. r10, r10, r6
  lis r31, 0x8058
  ori r31, r31, 0x3FFE
  lhz r30, 0(r31)
  rlwinm. r30, r30, 0, 31, 31
  beq+ loc_0xE0
  rlwinm. r31, r6, 0, 6, 6
  beq+ loc_0xE0
  rlwinm. r31, r10, 0, 15, 15
  beq+ loc_0x44
  li r26, -1
  b loc_0x50

loc_0x44:
  rlwinm. r31, r10, 0, 14, 14
  beq+ loc_0xE0
  li r26, 0x1

loc_0x50:
  rlwinm. r31, r6, 0, 7, 7
  beq+ loc_0x5C
  mulli r26, r26, 0xA

loc_0x5C:
  lis r27, 0x8058
  ori r27, r27, 0x3FB0
  lis r24, 0x9018
  ori r24, r24, 0xF5C
  li r31, 0x0

loc_0x70:
  addi r31, r31, 0x1
  cmpwi r31, 0x8
  beq- loc_0xE0
  lbzu r28, 92(r24)
  cmpwi r28, 0x3E
  beq+ loc_0x70
  lbz r30, 7(r24)
  subi r30, r30, 0x1
  cmpw r30, r29
  bne+ loc_0x70
  li r30, 0x0

#Check ID is in List
loc_0x9C:
  lbzx r25, r27, r30
  cmpw r25, r28
  bne+ loc_0xD0
  add r30, r30, r26
  cmpwi r30, 0x30 			#if >= 0x30, return to 0
  blt+ loc_0xB8
  subi r30, r30, 0x30 		#0x31 -> 0x1

loc_0xB8:
  cmpwi r30, 0x0 			#if < 0, return to 0x30
  bge+ loc_0xC4
  addi r30, r30, 0x30 		#-1 -> 0x2F

loc_0xC4:
  lbzx r25, r27, r30
  #stores new char id 
  stb r25, 0(r24)
  li r25, 0
  #sets costume and stuff to 0 
  stb r25, 0x5(r24)
  stb r25, 0x6(r24)
  b loc_0x70
loc_0xD0:
  addi r30, r30, 0x1
  cmpwi r30, 0x30 			#0x30
  beq- loc_0x70
  b loc_0x9C

loc_0xE0:
  lmw r24, 8(r1)
  addi r1, r1, 0x28
}

#char IDs in alphabetical order
byte[0x30] |
0x0A, 0x40, 0x23, 0x1C, |	#Captain Falcon, Dark Samus, Dedede (King Dedede), Diddy Kong
0x01, 0x15, 0x07, 0x14, |	#Donkey Kong, Falco, Fox, GameWatch (Mr. Game and Watch)
0x16, 0x25, 0x06, 0x35, |	#Ganondorf, Ike, Kirby, Knuckles
0x0C, 0x2C, 0x02, 0x24, |	#Koopa (Bowser), GKoopa (Giga Bowser), Link, Lucario
0x1B, 0x09, 0x00, 0x13, |	#Lucas, Luigi, Mario, Marth
0x18, 0x33, 0x0B, 0x0D, |	#Meta Knight, Mewtwo, Ness, Peach
0x08, 0x1A, 0x19, 0x22, |	#Pikachu, Pikmin (Olimar), Pit, PokeFushigisou (Ivysaur)
0x1E, 0x20, 0x10, 0x11, |	#PokeLizardon (Charizard), PokeZenigame (Squirtle), Popo (Ice Climbers), Popo (Sopo)
0x27, 0x38, 0x26, 0x32, |	#Purin (Jigglypuff), Ridley, Robot (R.O.B.), Roy
0x03, 0x04, 0x2A, 0x2B, |	#Samus, SZeroSuit (Zero Suit Samus), Snake, Sonic
0x28, 0x39, 0x17, 0x2D, |	#Toon Link, Waluigi, Wario, Wario Man
0x29, 0x05, 0x0E, 0x0F  |   #Wolf, Yoshi, Zelda, Sheik
@ $80583FB0

[Project+] Debug Controls v1.4 (Dolphin Fix v1.1) [Magus, ???, Eon] # comments written with help from fudgepop01
HOOK @ $8002E5AC
{
	lbz r3, 0xB(r25)
	andi. r0, r3, 4
	bne unpause
	andi. r0, r3, 2
	beq end
	lbz r4, 0xA(r25)
	cmpwi r4, 0
	beq end
	li r0, 0
	b %end%
unpause:
	li r4, 0x6
	not r4, r4
	and r3, r3, r4
	stb r3, 0xB(r25)
	li r26, 0 #force pause this frame to disable inputs from being processed
end:
	lbz r0, 0xB(r25)
}
HOOK @ $8002E68C
{	
	lbz r3, 0xB(r25)
	andi. r3, r3, 2
	beq end
	li r0, 0
  stb r0, 0xA(r25)
end:
	lhz r30, 0x140(r25)
}

#
* 80000007 80583FF4 #gr7 = 80583ff4
* 80000001 80583FF8 #gr1 = 80583ff8
* 80000002 80583FFC #gr2 = 80583ffc
* 80000003 805B8A08 #gr3 = 805b8a08
* 80000004 80584000 #gr4 = 80584000
* 80000006 804DE4B0 #gr6 = 804de4b0
* 60000003 00000000 #block0 = next code address repeat 3 times
* 86410004 FFFFFFFF #gr4 = gr4 ^ 0xFFFFFFFF
* 88330004 00000006 #gr4 = gr4 & gr6
* 8A000844 00000020 #memcpy 8 bytes from [gr4] into [gr4]+0x20 
* 8A000864 00000000 #memcpy 8 bytes from [gr6] into [gr4]
* 4A001004 00000000 #set po = gr4
#debug enable
* 38000000 FF9F0060 #if heldInput && 0x60 == 0x60 #if lr current frame
* 38000020 FFFB0004 # if pressedInput && 0x4 == 0x4 #and dpad down 
* 86410002 00000001 #   gr2 ^ 0x1
* E2000002 00000000 #endif*2
#if debug enabled
* 28583FFE FFFE0001 #if 16 bits at [0x80583FFE] && 0x1 == 0x1 
#option 1
* 38000000 FFDF0020 # if heldInput && 0x20 == 0x20 #if L current frame
* 38000020 FFFD0002 #   if pressedInput && 0x2 = 0x2 #if dpad right
* 86010002 00010000 #     gr2 = gr2 + 1
* 2C583FFC 00000002 #     if gr2 > 2
* 02583FFC 00000000 #        gr2 = 0
* 66100018 00000000 #        if execution is false skip this chunk 
PULSE 
{ #if hitbox display ended, reenable models
  stwu r1, -0x100(r1)
  stmw r0, 0x20(r1)
	mflr r0
	stw r0, 0x104(r1)

  lis r31, 0x8067
  ori r31, r31, 0x2F40
  #fighter
  mr r3, r31
  li r4, 1
  li r5, 1
  lis r30, 0x8000
  ori r30, r30, 0xD234
  mtctr r30
  bctrl   
  #gfx
  mr r3, r31
  li r4, 4
  li r5, 1
  lis r30, 0x8000
  ori r30, r30, 0xD234
  mtctr r30
  bctrl   
  #itemsarticles
  mr r3, r31
  li r4, 2
  li r5, 1
  lis r30, 0x8000
  ori r30, r30, 0xD234
  mtctr r30
  bctrl   
  #specialItems
  mr r3, r31
  li r4, 3
  li r5, 1
  lis r30, 0x8000
  ori r30, r30, 0xD234
  mtctr r30
  bctrl   
  #specialFX
  mr r3, r31
  li r4, 5
  li r5, 1
  lis r30, 0x8000
  ori r30, r30, 0xD234
  mtctr r30
  bctrl 

  lwz r0, 0x104(r1)
  mtlr r0
  lmw r0, 0x20(r1)
  addi r1, r1, 0x100
  blr 
}
* E2000003 00000000 # endif
#debug pause
* 38000020 EFFF1000 # if pressedInput && 0x1000 = 0x1000 #if start pressed
* 86410003 00000002 #   gr3 = gr3 ^ 2 # xor 1 replaced with xor 2 so debug pause is identifiable
* E2000001 00000000 # endif
#option 3
* 38000020 FFEF0010 # if pressedInput && 0x10 = 0x10 #if z pressed
* 2A5B8A0A FF000000 #  if 0x805B8A0A & 0xFF00 != 0x0000 #not frame advance frame
* 025B8A0A 00000102 #    0x805B8A0A = 0x102
* E2000002 00000000 # endif
#option 4
* 38000000 FFBF0040 # if heldInput && 0x40 = 0x40
* 38000020 FFFE0001 #   if pressedInput && 0x1 = 0x1
* 86410001 00000001 #     gr1 = gr1 + 1
* E2000002 00000000 # endif
#option 5
* 38000000 F7FF0800 # if heldInput && 0x80 = 0x80 
* 38000020 FFFD0002 #   if pressedInput && 0x2 = 0x2
* 86010001 00010000 #     gr1 = gr1 + 0x10000
* 2C583FF8 00000002 #     if gr1 > 2
* 02583FF8 00000000 #        gr1 = 0
* 6610000A 00000000 
PULSE 
{ #if stage render ended, reenable models
  stwu r1, -0x100(r1)
  stmw r0, 0x20(r1)
	mflr r0
	stw r0, 0x104(r1)

  lis r3, 0x8067
  ori r3, r3, 0x2F40
  li r4, 0
  li r5, 1
  lis r12, 0x8000
  ori r12, r12, 0xD234
  mtctr r12
  bctrl 

  lwz r0, 0x104(r1)
  mtlr r0
  lmw r0, 0x20(r1)
  addi r1, r1, 0x100
  blr 
}
* E2000002 00000000 # endif
#option 6
* 38000000 F7FF0800 # if heldInput && 0x800 = 0x800
* 38000020 FFFE0001 #   if pressedInput && 0x1 = 0x1
* 86410007 00000001 #     gr7 = gr7 ^ 0x1
* E2000004 00000000 # endif
                    #endif
#endofLoop
* 80100004 00000008 #gr4 += 0x8
* 80100006 00000008 #gr6 += 0x8
* 62000000 00000000 #repeat block0, for all 4 ports
* 4A000000 90000000 #po = 0x9000000
#if debug mode off
* 3817F36A 00FF0000 #if 8017F36A && 0xFF = 0x0
* 02583FF0 00070000   #0x80583FF0 = 0
* E0000000 80008000 #endif
#All Vanilla code Prior to here

#Z to frame advance in dolphin fix 
HOOK @ $80048E24
{ 
lis r16, 0x805C
addi r16, r16, -0x75F6
lhz r16, 0(r16)
cmpwi r16, 0
bne _cameraLocked

_cameraUnlocked:
lbz	r7, 0x0002 (r5)
b _end
_cameraLocked: 
li	r7, 255
_end:
}

[Project+] Debug Camera, No HUD/Tags (Dolphin Fix v1.2) [Igglyboo, Link, Y.S, Phantom Wings, Magus, Eon]

#No HUD/Tags section removed
#HOOK @ $800E08D4
#{
#lis r10, 0x8058
#addi r10, r10, 0x3FFA
#lhz r10, 0(r10)
#cmpwi r10, 1
#beq _CameraFrozen
#_CameraNormal: 
#ori	r5, r5, 0x0020 
#b _end
#_CameraFrozen:
#li r5, 0
#_end:
#}
#
#HOOK @ $800E5190
#{
#lis r10, 0x8058
#addi r10, r10, 0x3FFA
#lhz r10, 0(r10)
#cmpwi r10, 1
#blt _end
#_CameraFrozen:
#li r4,0
#_end:
#stw	r4, 0x0354 (r3)
#}

HOOK @ $800A6C1C
{
lis r10, 0x8058
addi r10, r10, 0x3FFA
lhz r10, 0(r10)
cmpwi r10, 0
bne _end
_CameraNormal:
stfs	f0, 0x0060 (r7)
_end:
}

HOOK @ $800A6C24
{
bne _end
stfs	f0, 0x0064 (r7)
_end:
}

HOOK @ $800A6C2C
{
bne _end
stfs	f0, 0x0068 (r7)
_end:
}

HOOK @ $800A6C48
{
bne _end
stfs	f0, 0x00C0 (r7)
_end:
}

HOOK @ $800A6C50
{
bne _end
stfs	f0, 0x00C4 (r7)
_end:
}

HOOK @ $800A6C58
{
bne _end
stfs	f0, 0x00CC (r7)
_end:
}

HOOK @ $800AA840
{
lis r10, 0x8058
addi. r10, r10, 0x3FFA
lhz r10, 0(r10)
cmpwi r10, 0
bne _end
_CameraNormal:
stfs	f0, 0x0060 (r30)
_end:
}

HOOK @ $800AA84C
{
bne _end
stfs	f0, 0x0064 (r30)
_end:
}

HOOK @ $800AA854
{
bne _end
stfs	f2, 0x0068 (r30)
_end:
}

HOOK @ $800AA874
{
cmpwi r10, 0
bne _end
_CameraNormal:
stfs	f4, 0x006C (r30)
stfs	f3, 0x0070 (r30)
stfs	f2, 0x0074 (r30)
_end:
}
.op nop @ $800AA878
.op nop @ $800AA87C

HOOK @ $800A0690
{
lis r10, 0x8058
addi. r10, r10, 0x3FFA
lhz r10, 0(r10)
cmpwi r10, 0
bne _end
_CameraNormal:
stfs	f1, 0x006C (r31)
_end:
}
HOOK @ $800A069C
{
bne _end
stfs	f0, 0x0070 (r31)
_end:
}
HOOK @ $800A06A8
{
bne _end
stfs	f1, 0x0074 (r31)
_end:
}
HOOK @ $800A06B4
{
bne _end
stfs	f0, 0x0060 (r31)
_end:
}
HOOK @ $800A06C0
{
bne _end
stfs	f1, 0x0064 (r31)
_end:
}
!Debug Hitbox Display v1.2.1 [Magus]
* C270DE50 0000003C
* 3D808058 618C3FFC
* A18C0000 2C0C0000
* 41A201C4 9421FF84
* BC610008 7FE802A6
* 7D9D6378 3D80805C
* 83CC8A0C 83DE0060
* 827E0094 81930044
* 7C0CF000 4082018C
* 839E0010 839C003C
* 837E0018 C05C0004
* C062A458 819C0014
* 2C0C0000 40800008
* C062A464 39600000
* 91620034 91620038
* 9162003C C023000C
* EC211024 D0220014
* C0230008 C01B0014
* EC210028 EC211024
* EC2100F2 C002A464
* EC210032 D022001C
* C0230004 C01B0010
* EC210028 EC211024
* D0220020 C0230000
* C01B000C EC210028
* EC211024 EC2100F2
* D0220024 C023003C
* C01B0014 EC210028
* EC211024 EC2100F2
* C002A464 EC210032
* D0220028 C0230038
* C01B0010 EC210028
* EC211024 D022002C
* C0230034 C01B000C
* EC210028 EC211024
* EC2100F2 D0220030
* 3B400088 3B20001C
* 3B000034 3AE00014
* 3A800000 2C1D0001
* 40820008 3A800001
* 3AA00000 3AC00000
* 819E0028 7C046000
* 41A00020 3AA00001
* 3AC00006 819E0030
* 7C046000 4180000C
* 3AA00002 3AC00008
* 39C02329 7E639B78
* 7F44D378 38A00000
* 7CC2CA14 7CE2C214
* 39000000 39200003
* 39400000 7C22BC2E
* 92C20010 3D80807A
* 618C3DC0 7D8903A6
* 4E800421 2C140001
* 41820020 3A940001
* 3B200028 3AD60001
* 2C150000 40A2FFAC
* 3AD60002 4BFFFFA4
* 7FE803A6 B8610008
* 3821007C 9421FFE0
* 60000000 00000000

!Debug Ledgegrab Box Display v1.1 [Magus]
* C2135B8C 0000003B
* 3D808058 618C3FF8
* A18C0000 2C0C0000
* 41A201C0 7D6802A6
* 3D808012 618C0674
* 7C0B6000 408201AC
* 9421FF84 BC610008
* 7FE802A6 83D40018
* 83DE0064 83DE0030
* 827E0094 839E0010
* 839C003C 837E0018
* C0FC0004 C082A458
* 819C0014 2C0C0000
* 40800014 C082A464
* FC602890 FCA00890
* FC201890 C062A468
* EC633824 D0620014
* C07B000C EC651828
* EC633824 EC630132
* D0620020 D0620038
* D06200B0 D06200C8
* C07B000C EC611828
* EC633824 ECC30132
* D0C20050 D0C20068
* D0C20080 D0C20098
* C07B0010 EC621828
* EC833824 D082001C
* D0820034 D082004C
* D0820064 C07B0010
* EC601828 ECE33824
* D0E2007C D0E20094
* D0E200AC D0E200C4
* 3AA00000 3AC00000
* 7C571378 96B70018
* 3AD60001 2C160008
* 4180FFF4 92A20028
* 92A20054 92A20058
* 92A2006C 92A20084
* 92A20088 92A2009C
* 92A200B8 92A20010
* 82A2A4CC 3AC00000
* 3AE20014 96B70018
* 3AD60001 2C160008
* 4180FFF4 92A20040
* 92A200A0 82A29EF8
* 92A20070 92A200D0
* 82A2A4D4 92A20024
* 92A2003C 92A200B4
* 92A200CC 3AE00018
* 39C02329 7E639B78
* 38800058 38A00000
* 7CC2BA14 38E6000C
* 39000000 39200003
* 39400000 C0220014
* 3D80807A 618C3DC0
* 7D8903A6 4E800421
* 2C1700C0 3AF70018
* 4180FFC0 7FE803A6
* B8610008 3821007C
* 382100A0 00000000

!Debug Collision and TopN Display [Magus]
* C2132C10 00000034
* 90030038 3D408058
* 614A3FF6 A14A0000
* 2C0A0000 41A20184
* 3D408011 6149B608
* 614AD5B0 7D0802A6
* 7C085000 4182000C
* 7C084800 40A20164
* 9421FF84 BC610008
* 7FE802A6 7C1F4800
* 41820008 7F56D378
* 83D60018 83DE0064
* 83DE0030 827E0094
* 839E0010 839C003C
* 837E0018 C01C0004
* C022A458 819C0014
* 2C0C0000 40800008
* C022A464 C0429490
* EC420024 D0420014
* C042A468 EC420024
* D0420018 C07B000C
* C09B0010 C0A3001C
* EC451828 EC420024
* EC420072 D0420030
* C0A30024 EC451828
* EC420024 EC420072
* D042003C C0A30010
* EC452028 EC420024
* D0420044 C0A30018
* EC452028 EC420024
* D0420050 C0A30008
* EC452028 EC420024
* D042002C D0420038
* C0429638 EC420072
* D042001C 3AA00000
* 92A20020 92A20024
* 92A20028 92A20034
* 92A20040 92A20048
* 92A2004C 92A20054
* 3AC0000A 3AA00014
* 3AE0001C 39C02329
* 7E639B78 38800088
* 38A00000 7CC2BA14
* 38E20020 39000000
* 39200003 39400000
* 7C22AC2E 92C20010
* 3D80807A 618C3DC0
* 7D8903A6 4E800421
* 3AC0000B 3AA00018
* 2C17004C 3AF7000C
* 4180FFB4 7FE803A6
* B8610008 3821007C
* 60000000 00000000

Debug Body Collision State, Armor, and Hitstun Overlays v1.2 [Magus]
* C274D318 0000002A
* 3D408058 614A3FFC
* A14A0000 2C0A0000
* 41A20138 81430064
* 3CA09340 7C0A2800
* 40800128 812A00B8
* 3CC08100 7C093000
* 41800118 38C00000
* 2C040001 40A20010
* 3CE007F9 60E70791
* 480000F0 2C040000
* 41A20010 3CE00707
* 60E7F991 480000DC
* 810A0044 80E80048
* C028004C 2C070003
* 40A10010 3CE0A107
* 60E7FF00 48000044
* 41A0001C 3CE0F907
* 60E70700 C0280050
* C042975C EC2100B2
* 48000028 2C070001
* 40A10010 3CE007D0
* 60E7D000 48000014
* 41A00030 3CE0647B
* 60E7E8FF 4800007C
* FC20081E D8220010
* A1020016 2C0800FF
* 40A10008 390000FF
* 7CE74378 4800005C
* 80EA007C 80E70038
* 2C070043 41A00058
* 2C070048 41810050
* 810A0070 81080020
* 8108000C 810800E0
* 2C080001 41800038
* 39000061 41820008
* 39000091 2C070045
* 3CE0FF81 60E70700
* 40A0000C 3CE0D0D0
* 60E70700 7CE74378
* 90E900B8 B0C90064
* 38C00100 B0C900EC
* 7C832378 00000000
* C27CA8DC 00000005
* 3D808058 618C3FFC
* A18C0000 2C0C0000
* 41A2000C 2C002329
* 48000008 2C00FFFF
* 60000000 00000000

![Project+] Clear Debug GFX Common [Magus, Eon] 
#Relocated higher in function chain to catch article case
HOOK @ $8070fc98
{

checkIfHitboxRenderEnabled:
  lis r10, 0x8058
  ori r10, r10, 0x3FF0
  lhz r9, 12(r10)
  lhz r8, 6(r10)
  lhz r7, 8(r10)
  or r9, r9, r8
  mulli r9, r9, 0x10
  or r9, r9, r7
  cmpwi r9, 0x0
  beq+ loc_0xB0
hitboxRender:  
  stwu r1, -124(r1)
  stmw r3, 8(r1)
  mflr r31
  mr r24, r9

  lwz r29, 0x0094 (r29)   #\  gets graphics ID for hitbox gfx
  lwz r29, 0x0048 (r29)   #/

loc_0x48:
  rlwinm. r12, r24, 0, 28, 31
  beq- loc_0x60
  li r12, 0xF
  andc r24, r24, r12
  li r8, 0x58
  b callGfxDestroyer

loc_0x60:
  rlwinm. r12, r24, 0, 24, 27
  beq- loc_0xA4
  li r12, 0xF0
  andc r24, r24, r12
  li r8, 0x88

callGfxDestroyer:
  lis r3, 0x805A
  lwz r3, 0x148(r3)
  mr r4, r29
  lis r5, 0x100
  subi r5, r5, 0x100
  li r6, 0x0
  li r7, 0x0
  lis r12, 0x8006
  ori r12, r12, 0xE20
  mtctr r12
  bctrl 

  b loc_0x48

loc_0xA4:
  mtlr r31
  lmw r3, 8(r1)
  addi r1, r1, 0x7C

loc_0xB0:
  lwz r3, 0x00D8 (r29)

}
