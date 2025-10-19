###########################################################
Extra Fighters on Random Select [GeraRReal]
# Based on work by QuickLava and MarioDox.

# The code relies on having the code on Project+Ex due to
# depending on a number of codes added to the build.

# You can store up to 32 extra characters on Random Select.
# Hold L and press X or Y to swap.
# Allows L+X, L+Y, AND touching to work on SlotEx fighters
###########################################################
.BA<- ExtraFighterData
.BA -> $804ECFC0 ## Store
.GOTO -> MyCode

ExtraFighterData:
	byte[32] |
0x29, 0xFF, 0xFF, 0xFF,  | # Random, Empty, Empty, Empty
0xFF, 0xFF, 0xFF, 0xFF,  | # Empty, Empty, Empty, Empty
0xFF, 0xFF, 0xFF, 0xFF,  | # Empty, Empty, Empty, Empty
0xFF, 0xFF, 0xFF, 0xFF,  | # Empty, Empty, Empty, Empty
0xFF, 0xFF, 0xFF, 0xFF,  | # Empty, Empty, Empty, Empty
0xFF, 0xFF, 0xFF, 0xFF,  | # Empty, Empty, Empty, Empty
0xFF, 0xFF, 0xFF, 0xFF,  | # Empty, Empty, Empty, Empty
0xFF, 0xFF, 0xFF, 0xFF	 | # Empty, Empty, Empty, Empty

MyCode:
.RESET
.alias MaxChar = 1
.alias Write = 0x804ECFC0
// Grab L, R and Z input from previous getSysPadStatus
HOOK @ $80689A90
{
  lwz r17, 0x48(r1)
  rlwinm r17, r17, 28, 29, 31
  lwz r0, 0xA4(r30)
}

.macro lwd(<reg>, <addr>)
{
  .alias  temp_Lo = <addr> & 0xFFFF
  .alias  temp_Hi_ = <addr> / 0x10000
  .alias  temp_r = temp_Lo / 0x8000
  .alias  temp_Hi = temp_Hi_ + temp_r
  lis     <reg>, temp_Hi
  lwz     <reg>, temp_Lo(<reg>)
}

.macro saveGPR()
{
	stwu r1, -0x80(r1)
	stmw r3, 0x8(r1)
}
.macro loadGPR()
{
	lmw r3, 0x8(r1)
	addi r1, r1, 0x80
}
.macro reloadGPR()
{
	lmw r3, 0x8(r1)
}
.macro charPic()
{
  lis r12, 0x8069
  ori r12, r12, 0x742C
  mtctr r12
  li r12, 0
  bctrl
}
.macro sendSystemCharKind()
{
  lis r12, 0x8069
  ori r12, r12, 0x6570
  mtctr r12
  li r12, 0
  bctrl
}

.macro incCostume()
{
  lis r12, 0x8069
  ori r12, r12, 0xA22C
  mtctr r12
  li r12, 0
  bctrl
}
.macro decCostume()
{
  lis r12, 0x8069
  ori r12, r12, 0xA340
  mtctr r12
  li r12, 0
  bctrl
}
# A macro for the setZeldas check, for Extra Fighters
.macro setZeldas()
{
  %reloadGPR()
  lwz r4, 0x1E8(r3)

  lis r12, 0x8069
  ori r12, r12, 0x4934
  mtctr r12
  li r12, 0
  bctrl
}

# A macro for the setPoke3 check, for SlotEx
.macro setSlotEx()
{
  cmpwi r0, 4
  bge 0x40 # Skip if the checks are repeated more than 4 times
  %lwd(r16, 0x806948C8)
  mulli r29, r29, 4
  add r16, r16, r29
  lbzx r28, r16, r17
  lbzx r29, r16, r4
  cmpwi r29, 0xFF
  bne 0x10
  %loadGPR()
  b %END%
  cmpw r28, r29
  bne 0xC
  mr r29, r19
  b SlotEx

  stw r4, 0x1F0(r3)
  %sendSystemCharKind()
  %loadGPR()
  %saveGPR()
  %lwd(r5, 0x806948C8)
  lwz r4, 0x1F0(r3)
  lwz r6, 0x1B8(r3)
  mulli r6, r6, 4
  add r6, r6, r4
  lbzx r4, r5, r6
  lwz r6, 0x1BC(r3)
  lwz r5, 0x1B4(r3)
  %charPic()
}

.macro moduloInc(<reg>,<max>)
{
  cmpwi <reg>, <max>
  beq 0xC
  addi <reg>, <reg>, 1
  b 0x8
  li <reg>, 0
}
.macro moduloDec(<reg>,<max>)
{
  cmpwi <reg>, 0
  beq 0xC
  addi <reg>, <reg>, -1
  b 0x8
  li <reg>, <max>
}
.macro shoulderButtonCheck()
{
  cmpwi r17, 0x4
  beq CheckSlot
}

# Fixes an issue where Extra Fighters would default to the amount of costumes the assigned slot would have... by assigning the current ID.
.macro CostumeFix()
{
  lwz r30, 0x1B8(r3)
  cmpwi r30, 0x29
  bne %END%
  %lwd(r30,Write)
  lwz r17, 0x1E8(r3)
  lbzx r30, r30, r17
  li r17, 0
}
# Ditto
.macro CostumeFixII()
{
  lwz r0, 0x1B8(r5)
  cmpwi r0, 0x29
  bne %END%
  %lwd(r28,Write)
  lwz r17, 0x1E8(r5)
  lbzx r0, r28, r17
  li r17, 0
  li r28, 0
}
.macro Uhh()
{
  lwz r4, 0x1B8(r31)
  cmpwi r4, 0x29
  beq 0xC
  mr r4, r3
  b %END%
  %lwd(r4,Write)
  lwz r9, 0x1E8(r31)
  lbzx r4, r4, r9
  li r9, 0
}

# sendSystemCharKind
op cmpwi r28, 0x29 @ $806965A8
op beq 0x14 @ $806965AC
op b 0x2C @ $806965DC
op b 0x3C @ $806965CC
HOOK @ $806965C4
{
  %lwd(r4,Write)
}
HOOK @ $806965C8
{
  lbzx r28, r4, r0
  li r4, 0
  lwz r31, 0x1BC(r3)
}

#decCharColorNo
HOOK @ $8069A354
{
  %CostumeFix()
}
HOOK @ $8069A3B8
{
  %CostumeFixII()
}
HOOK @ $8069A414
{
  %Uhh()
}

#incCharColorNo
HOOK @ $8069A240
{
  %CostumeFix()
}
HOOK @ $8069A2A8
{
  %CostumeFixII()
}
HOOK @ $8069A304
{
  %Uhh()
}

# exchangeCharKingDetail
CODE @ $806948E8
{
  nop 
  nop 
}
HOOK @ $806948D4
{
  %saveGPR()
  %lwd(r14, Write)
  li r15, -1
Loop:
  addi r15, r15, 1
  lbzx r5, r14, r15
  cmpw r4, r5
  beq End
  cmpwi r5, 0xFF
  beq Fail
  b Loop
Fail:
  crnor 2, 2, 2
End:
  %loadGPR()
}
CODE @ $806948D8
{
  bne 0x1C
  %lwd(r5, Write)
  b 0x1C
}
op nop @ $80694904
op lbzx r4, r5, r0 @ $80694908

#initCharKind
HOOK @ $80693D18
{
  li r12, 0
  %lwd(r11, Write)                   # Get Extra Fighter table pointer
  add r11, r11, r12
  lbz r11, 0(r11)                    # Get Slot ID
  cmpwi r11, 0xFF                    # If the slot is 0xFF, skip to the one that handles SlotEx
  beq ActualCodeStart
  cmpw r4, r11
  beq 0xC
  addi r12, r12, 1
  b -0x24
  li r4, 0x29                        # Go back to 0x29 and revert to Random
  stw r12, 0x1E8(r3)
ActualCodeStart:
  subi r0, r4, 3
}

# Press X
HOOK @ $80689D40
{
  %shoulderButtonCheck()
IncCostume: # Change costume
  %incCostume()
  b %END%
CheckSlot: # Check Slots for...
  %saveGPR()
  mr r4, r31
  lis r10, 0xFFFF
  ori r10, r10, 0xFFFF
  mr r31, r30
  mr r30, r3
  lwz r29, 0x01B8(r3)
  cmpwi r29, 0x29
  li r0, 0
  bne SlotEx
ExtraFighter:
  stw r0, 0x1BC(r3)
  lwz r4, 0x1E8(r3)
  %moduloInc(r4,MaxChar)
  stw r4, 0x1E8(r3)
  %setZeldas()
  b bEND
SlotEx:
  mr r8, r0           # use r8 to increment because r0 defaults to 0 - this is all done to skip duplicate slots
  addi r8, r8, 1      # increment selected SlotEx position by 1
  mr r0, r8           # move incremented value to r0
  mr r19, r29
  lwz r4, 0x1F0(r3)
  subi r4, r4, 1      # decrement r4 by 1
  add r4, r4, r8      # add currently selected slot to r4 - basically allows us to "skip" slot to get to the next one
  %moduloInc(r4,3)
  mr r17, r4
  %moduloDec(r17,3)
  %setSlotEx()
bEND:
  %loadGPR()
}

# Press Y
HOOK @ $80689D4C
{
  %shoulderButtonCheck()
IncCostume: # Change costume
  %decCostume()
  b %END%
CheckSlot: # Check Slots for...
  %saveGPR()
  mr r4, r31
  lis r10, 0xFFFF
  ori r10, r10, 0xFFFF
  mr r31, r30
  mr r30, r3
  lwz r29, 0x01B8(r3)
  cmpwi r29, 0x29
  li r0, 0
  bne SlotEx
ExtraFighter:
  stw r0, 0x1BC(r3)
  lwz r4, 0x1E8(r3)
  %moduloDec(r4,MaxChar)
  stw r4, 0x1E8(r3)
  %setZeldas()
  b bEND
SlotEx:
  mr r8, r0           # use r8 to increment because r0 defaults to 0 - this is all done to skip duplicate slots
  addi r8, r8, 1      # increment selected SlotEx position by 1
  mr r0, r8           # move incremented value to r0
  mr r19, r29
  lwz r4, 0x1F0(r3)
  addi r4, r4, 1      # increment r4 by 1
  sub r4, r4, r8      # subtract currently selected slot from r4 - basically allows us to "skip" slot to get to the next one
  %moduloDec(r4,3)
  mr r17, r4
  %moduloInc(r17,3)
  %setSlotEx()
bEND:
  %loadGPR()
}

# Reset setZeldas check if moving the token away
HOOK @ $80697044
{
  stw r3, 0x1E8(r30)
  mr r3, r30
}

## Change the sound effects to the scrolling one if holding L
HOOK @ $80689D9C
{
  cmpwi r17, 4
  beq audio_23
  b normal
audio_23:
  li r4, 0x23
  b %END%
normal:
  li r4, 0x0
}

HOOK @ $8068AE1C
{
  cmpwi r27, 0x29
  bne %END%
  %lwd(r17,Write)
  lwz r18, 0x1E8(r28)
  lbzx r17, r18, r17
}

## setZeldas patches
op lis r5, 0x804E @ $8069493C
op ori r5, r5, 0xCFC0 @ $80694944
op lwz r5, 0x0(r5) @ $8069498C
op cmpwi r29, 0x29 @ $80694964

HOOK @ $80697440
{
  cmpwi r4, 0x29
  bne OGInstruction
  %lwd(r14,Write)
  lwz r15, 0x1E8(r3)
  lbzx r4, r14, r15
OGInstruction:
  cmpwi r4, 0x28
}

HOOK @ $8068AFC4
{
  cmpwi r29, 0x29
  bne OGInstruction
  %lwd(r14,Write)
  lwz r29, 0x1E8(r30)
  lbzx r29, r14, r29
OGInstruction:
  lwz r4, 0x1B8(r30)
}