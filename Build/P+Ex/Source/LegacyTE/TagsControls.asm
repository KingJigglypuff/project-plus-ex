[Legacy TE] Holding L when new name at CSS goes to custom controls & back to CSS v1.21 [ChaseMcDizzle]
* C269B860 0000000D
* 3E208000 62312800
* 82510000 2C120000
* 41820018 3A60FFFF
* 3E208069 6231B890
* 7E2903A6 4E800420
* 3E40FFFF 6252FFFF
* 7C039000 4082002C
* 81FD000C 71EF0040
* 2C0F0040 4082001C
* 3A400001 92510000
* 3D00805A 810800E0
* 8108001C 9A680028
* 2C030000 00000000
* C268D7C0 00000009
* 3D008000 61082800
* 81080000 2C080000
* 4182002C 3800000C
* 38600004 38C00004
* 3BA00004 3BC00055
* 3BE00003 3E008068
* 6210D7F4 7E0903A6
* 4E800420 7C00F000
* 60000000 00000000
* C202D654 0000000C
* 3D008000 61082800
* 81080000 2C080000
* 41820048 2C080001
* 4182000C 2C080002
* 41820020 3C808070
* 608418EC 38E00002
* 3D008000 61082800
* 90E80000 4800001C
* 3C808070 608417E0
* 38E00000 3D008000
* 61082800 90E80000
* 7C7A1B78 00000000

[Project+] X To toggle Rumble V1.2 (requires Fracture's Controls) [ChaseMcDizzle, Fracture, Yohan1044] 
#CSS tag colour based on rumble removed as had buggy effects on song title and nametag colouring

#If current tag has rumble on, remember for later
#* C269F6B8 00000006
#* 1DE40124 3E00805A
#* 621000E0 82100000
#* 82100028 7E107A14
#* 8A1000EC 2C100001
#* 40820008 3A2000FF
#* 7C641B78 00000000

#If tag is remembered to have rumble, change colour
#* C206A1AC 00000004
#* 2C1100FF 40820014
#* 39200024 39000037
#* 38E0008E 3A200000
#* 7D2621AE 00000000

#Alters Rumble of tag
* C269FEC8 0000000E
* 89C30060 2C0E0001
* 41810058 70CE0400
* 2C0E0400 4082004C
* 81C30044 2C0EFFFF
* 41820040 2C0E0000
* 41820038 39CEFFFF
* 1DCE0002 39CE0070
* 7DC3722E 1EEE0124
* 3DE0805A 61EF00E0
* 81EF0000 81EF0028
* 7DEFBA14 8B0F00EC
* 6B180001 9B0F00EC
* 8004000C 7CF83B78
* 60000000 00000000
#Scrolls Through list
* C26A01D0 00000006
* 7318000F 2C180002
* 4181000C 3A600421
* 4800001C 54000739
* 40820014 3F00806A
* 631802FC 7F0903A6
* 4E800420 00000000
* C26A0518 00000004
* 2C130421 41820014
* 3E60800B 62733C5C
* 7E6903A6 4E800421
* 60000000 00000000
#SetFrameMatCol on scroll
* C26A0548 00000004
* 2C130421 41820014
* 3E60800B 62737A18
* 7E6903A6 4E800421
* 60000000 00000000
#setFontColor on scroll
* C26A05CC 00000004
* 2C130421 41820014
* 3E60800B 627393A4
* 7E6903A6 4E800421
* 60000000 00000000
#playSoundEffect on scroll
* C26A02F8 00000006
* 2C130421 41820018
* 3E608007 627342B0
* 7E6903A6 4E800421
* 4800000C 827A0048
* 927A0044 3A600000
* 60000000 00000000

##################################################
[Project+] CSS Tags with Rumble are Coloured [Eon] 
##################################################
#Logic to find if rumble on for tag from `CSS Tags with Rumble are teal, X To toggle V1.2 [ChaseMcDizzle, Fracture, Yohan1044]`
#Logic to find if rumble on for port from `[Project+] Customize Controls on CSS V9.1 + C-stick taunts renamed [Fracture]`
HOOK @ $8069f9fc
{
  cmpwi r19, -1   #makes sure CSS custom control menu isnt open, remove top 5 lines if that code isnt included in your build
  beq renderColours
  li r16, 0
  li r17, 0
  b end
renderColours:

  #getTagNo
  subi r15, r27, 0x1
  cmpwi r15, -1
  beq portRumble

#checks tag ordering, finds current working tag
  mulli r15,r15, 0x2 
  addi r15, r15, 0x68
  lhzx r15, r3, r15

  mulli r15, r15, 0x124
  #Is rumble enabled?
  lis r16, 0x805A
  lwz r16, 0xE0(r16)
  lwz r16, 0x28(r16)
  add r16,r16,r15
  lbz r16, 0xEC(r16)
  b storeCentre

  #specific rumble check for player port
portRumble:
  lbz r16,96(r24)
  cmpwi r16,1
  bgt- 0x24
  lbz r16,87(r24)
  subi r16,r16,49
  lis r15,-28649
  ori r15,r15,48736
  lbzx r16,r15,r16

  #if current working tag is centre tag, remember its value for if going off-centre
storeCentre:
  cmpw r25, r27
  bne end
  mr r17, r16

  #original command (is working tag centred)
end:
  cmpwi r26, 4
}
#Centred Tag
HOOK @ $8069fa0c 
{
  li r18, 0x0

  cmpwi r16, 1
  bne %end%
  li r20, 0x00  #red
  li r19, 0x90  #green
  li r18, 0x90  #blue
}
#Off Centre Tag
HOOK @ $8069fa1c
{
  li r18, 0x50
  cmpwi r16, 1
  bne %end%
  li r20, 0x10  #red
  li r19, 0x80  #green
  li r18, 0x80  #blue
}
#Changing from Centred to Off Centre
HOOK @ $806a05c8 
{
  li r8, 0xFF
  cmpwi r17, 1
  bne %end%
  li r5, 0x10
  li r6, 0x80
  li r7, 0x80
}




###########################################################
[Legacy TE] Load Player Tags on Win Screen v2 [PyotrLuzhin]
###########################################################
HOOK @ $800E7C5C
{
  stw r5, 0(r2)
  lwz r12, -0x4340(r13)
  lwz r12, 8(r12)
  lwz r0, 0xB8(r30)
  mulli r0, r0, 0x5C
  add r12, r12, r0
  addi r12, r12, 0x98
  lhz r0, 12(r12)
  cmpwi r0, 0x0
  beq- loc_0x48
  addi r4, r12, 0xC
  addi r3, r2, 0x4
  lis r11, 0x8006		# \
  ori r11, r11, 0xBCA8	# | utf16to8
  mtctr r11				# |
  bctrl 				# /
  addi r5, r2, 0x4
  b loc_0x4C

loc_0x48:
  lwz r5, 0(r2)

loc_0x4C:
  li r4, 0x0
  lwz r3, 0x654(r30)
}
