###############################################################
[P+Ex] SlotsEX Rewrite v1.0.2 [MarioDox, GerraRReal, QuickLava]
###############################################################
.BA<- Table
.GOTO->Table_Skip
Table:
word [128] |                                        # CSS Slot IDs   Names
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x00 - 0x03 |  Mario, Donkey, Link, Samus
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x04 - 0x07 |  SZerosuit, Yoshi, Kirby, Fox,
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x08 - 0x0B |  Pikachu, Luigi, Captain, Ness,
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x0C - 0x0F |  Bowser, Peach, Zelda, Sheik
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x10 - 0x13 |  IceClimber, Marth, G&W, Falco
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x14 - 0x17 |  Ganon, Wario, MetaKnight, Pit
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x18 - 0x1B |  Pikmin, Lucas, Diddy, Pokemon Trainer
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x1C - 0x1F |  Charizard, Squirtle, Ivysaur, Dedede
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x20 - 0x23 |  Lucario, Ike, Robot, Jigglypuff
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x24 - 0x27 |  ToonLink, Wolf, Snake, Sonic
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x28 - 0x2B |
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x2C - 0x2F |  ????, Roy, Mewtwo, Knuckles
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x30 - 0x33 |
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x34 - 0x37 |
0x38393A3B, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x38 - 0x3B |  ZakoBoy, ZakoGirl, ZakoChild, ZakoBall
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x3C - 0x3F |
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x40 - 0x43 |  EX Characters
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x44 - 0x47 |
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x48 - 0x4B |
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x4C - 0x4F |
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x50 - 0x53 |
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x54 - 0x57 |
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x58 - 0x5B |
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x5C - 0x5F |
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x60 - 0x63 |
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x64 - 0x67 |
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x68 - 0x6B |
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x6C - 0x6F |
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x70 - 0x73 |
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x74 - 0x77 |
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,|    # 0x78 - 0x7B |
0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF      # 0x7C - 0x7F |
Table_Skip:
.BA -> $806948C8                                    # Note: this address is typically in the range of the "exchangePoke3ToGmCharKind" function!
.alias LocalMemoryAddrLoc = 0x806948C8              # We return early from that function with this code, so the remaining memory there is safe to use!
.alias MaxCharCount = 128
.alias TableLengthInBytes = 512
.RESET
.macro lwd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lwz     <reg>, temp_Lo(<reg>)
}
.macro PTSlotCompareBody(<idReg>, <CRField>)
{
  .alias tmp1 = <CRField> + <CRField>
  .alias tmp2 = tmp1 + tmp1
  .alias eqBit = tmp2 + 2

  %lwd(r11, LocalMemoryAddrLoc)      # Get table pointer...
  rlwinm r12, <idReg>, 2, 0, 29      # ... quadruple incoming char ID to get offset to table entry...
  add r11, r11, r12                  # ... and add that to the table address to get the target entry address.
  lbz r12, 0x03(r11)                 # Grab the final byte of the entry...
  cmplwi cr<CRField>, r12, 0xFF      # ... compare it against 0xFF...
  crnor eqBit, eqBit, eqBit          # ... and flip CR0's EQ bit, so the following branch fires if r12 *is* 0xFF (ie. PT slot not requested)!
}

# Restore vBrawl Zelda/Shiek & PT Behavior
# Leave these commented out if you're using a build which separates the sub-slot characters into their own CSS Slots (eg. most PM/P+/P+Ex builds)
# op beq 0xC @ $80697EEC             # \
# op beq 0xC @ $80697F58             # / Restore switching between Zelda/Sheik on CSS
# op bgt 0x98 @ $80693D20            # Restores vBrawl Return to CSS behavior (PT Pokemon -> PT, Sheik -> Zelda, ZSS -> Samus)

# Adjusts a read from the PT ID Array to use our table, while also freeing up the rest of the function body
# for our use in storing stuff. In particular we store the address for our table in the freed space, very useful lol
HOOK @ $806948C4                # [in "exchangePoke3ToGmCharKind/[muSelCharPlayerArea]/mu_selcha" @ 0x806948C4, Ghidra: $806A0160]
{
  %lwd(r4, LocalMemoryAddrLoc)       # Get table pointer...
  addi r4, r4, 0x6C                  # ... and point to PT's entry (at offset 0x1B * 4 = 0x6C).
  lbzx r3, r4, r3                    # Grab the requested ID from the list...
  blr                                # ... then return!
}

# Replaces: op cmpwi cr1, r29, RED	@ $80694a34
HOOK @ $80694A34                # [in "setPoke3/[muSelCharPlayerArea]/mu_selchar_player_area.o" @ 0x80694A04, Ghidra: $806A02D0]
{
  %PTSlotCompareBody(r29, 1)
}
op lbzx r29, r11, r4 @ $80694a80     # LBZX the new ID from the character's table entry address, as was set up in the previous hook!
op b 0x40 @ $80694A3C                # Ensure we actually proceed with applying the ID from the table if a valid entry was detected!

# Replaces: op cmpwi r4, RED	@ $806948f4
HOOK @ $806948F4                # [in "exchangeCharKindDetail/[muSelCharPlayerArea]/mu_selchar_p" @ 0x806948D4, Ghidra: $806A0190]
{
  %PTSlotCompareBody(r4, 0)
}
op nop @ $806948E4                   # \
op nop @ $806948F0                   # / Disable a pair of branches preventing IDs lower than 0xE to be properly checked.
op lbzx r4, r11, r0 @ $80694928      # LBZX the new ID from the character's table entry address, as was set up in the previous hook!

# Replaces: op cmpwi r28, RED	@ $806965b4
HOOK @ $806965B4                # [in "sendSystemCharKind/[muSelCharPlayerArea]/mu_selchar_playe" @ 0x80696570, Ghidra: $806A1E50]
{
  %PTSlotCompareBody(r28, 0)
}
op nop @ $806965A4                   # \
op nop @ $806965B0                   # / Disable a pair of branches preventing IDs lower than 0xE to be properly checked.
op lbzx r28, r11, r0 @ $806965E8     # LBZX the new ID from the character's table entry address, as was set up in the previous hook!

# Reset selectedPoke when moving between character slots on the CSS!
# Ensures selected sub-slot isn't maintained across characters with this system enabled.
HOOK @ $80697040                # [in "setCharKind/[muSelCharPlayerArea]/mu_selchar_player_area_" @ 0x80696F60, Ghidra: $806A28DC]
{
  mr r4, r3                          # Restore Original Instruction
  li r3, 0x00                        # \
  stw r3, 0x1F0(r30)                 # / Zero out selectedPoke.
}

# Handles Getting Coll Type!
HOOK @ $80697B9C                # [in "getCollKind/[muSelCharPlayerArea]/mu_selchar_player_area_" @ 0x80697B08, Ghidra: $806A3438]
{
  subic r10, r0, 0x9                 # Subtract 9 from the case ID so that PT's case ID is now 0.
  cmplwi r10, 0x3                    # \
  bgt+ exit                          # / Then exit if the resulting value isn't between 0 and 3 (PT and the mons)

  %lwd(r11, LocalMemoryAddrLoc)      # Grab the table address.
  lwz r12, 0x1B8(r19)                # First, grab the active character slot...
  rlwinm r12, r12, 2, 0, 29          # ... quadruple it to get the offset to the associated table entry...
  add r11, r11, r12                  # ... and add it to the table address to get its address.

  lbz r9, 0x00(r11)                  # Load the parent ID into r9...
  lbzx r10, r11, r10                 # ... and the active sub-slot ID into r10!

exit:
  rlwinm r0, r0, 2, 0, 29            # Restore Original Instruction
}
op cmplw r4, r9     @ $80697FBC # \
op cmplw r3, r10    @ $80697FCC # / Case 9:  PT Parent Slot
op cmplw r4, r9     @ $8069802C # \
op cmplw r3, r10    @ $8069803C # / Case 10: PT 1st Child Slot
op cmplw r4, r9     @ $8069809C # \
op cmplw r3, r10    @ $806980AC # / Case 11: PT 2nd Child Slot
op cmplw r4, r9     @ $8069810C # \
op cmplw r3, r10    @ $8069811C # / Case 12: PT 3rd Child Slot

# Handles CSS Return Slot IDs!
HOOK @ $80693D1C                # [in "initCharKind/[muSelCharPlayerArea]/mu_selchar_player_area" @ 0x80693D18, Ghidra: $8069F5B8]
{
  subi r12, r4, 0x28
  cmplwi r12, 0x1
  ble exit
  
  %lwd(r11, LocalMemoryAddrLoc)      # Get table pointer...
  subi r11, r11, 0x4                 # ... and set it up for our loop!
  li r12, MaxCharCount               # \ Set the count register up to limit the number
  mtctr r12                          # / of character entries we'll attempt to read in our loop.
charEntryLoopHead:
  li r10, 0x0                        # Reset sub-slot index!
  lbzu r12, 0x4(r11)                 # Load the first byte of the current character entry...
  cmplwi r12, 0xFF                   # ... and check if it's null!
  beq+ skipChecks                    # If it is the slot is inactive, skip checking the following bytes!
  cmplw r12, r4                      # Additionally, compare the loaded ID with the incoming one...
  beq- skipChecks                    # ... and if they're equal, skip the other checks!

subSlotLoopHead:
  addi r10, r10, 0x1                 # Increment sub-slot index...
  lbzx r5, r11, r10                  # ... and load the associated byte from this entry!
  cmplw r5, r4                       # Compare the loaded byte with the incoming ID...
  beq- entryMatch                    # ... and if they match, jump to the match label!
  cmplwi r10, 0x3                    # \
  blt+ subSlotLoopHead               # / If we didn't match, restart the loop if there are still sub-slots to check!
  b skipChecks                       # If we failed to find a match altogether, ensure we skip past the match found code.

  entryMatch:                        # \
  mr r4, r12                         # / If we *did* find a match, then overwrite r4 with the first byte's ID!

  skipChecks:
  cmplw r12, r4                      # Compare the loaded value with the original ID.
  bc 0, 2, charEntryLoopHead         # Only repeat loop if there are still entries to check AND the last check failed!

  bne+ exit                          # Re-use the previous check to exit early if we didn't find a match!
  stw r10, 0x1F0(r3)                 # Otherwise, store the matching sub-slot index in the selectedPoke field.
  
  exit:
  cmplwi r0, 0x1B                    # Restore Original Instruction
}

# Allow Slots with the same Char ID to use the same Costume if they have different sub-slot IDs.
HOOK @ $80696FCC                # [in "setCharKind/[muSelCharPlayerArea]/mu_selchar_player_area_" @ 0x80696F60, Ghidra: $806A2868]
{
  cmplw r31, r0                    # Restore Original Instruction: Compare our Char ID with Opposing Port's
  bne+ %END%                       # If they're not, we can just skip out of the code.
  lwz r11, 0x1F0(r30)              # \
  lwz r12, 0x1F0(r4)               # / Otherwise, instead grab their sub-slot IDs...
  cmplw r11, r12                   # ... and compare with those instead!
}
HOOK @ $80698408                # [in "setPlayerKind/[muSelCharPlayerArea]/mu_selchar_player_are" @ 0x80698348, Ghidra: $806A3D44]
{
  cmplw r30, r0                    # Restore Original Instruction: Compare our Char ID with Opposing Port's
  bne+ %END%                       # If they're not, we can just skip out of the code.
  lwz r11, 0x1F0(r3)               # \
  lwz r12, 0x1F0(r6)               # / Otherwise, instead grab their sub-slot IDs...
  cmplw r11, r12                   # ... and compare with those instead!
}
HOOK @ $806984A8                # [in "setPlayerKind/[muSelCharPlayerArea]/mu_selchar_player_are" @ 0x80698348, Ghidra: $806A3CA4]
{
  cmplw r30, r0                    # Restore Original Instruction: Compare our Char ID with Opposing Port's
  bne+ %END%                       # If they're not, we can just skip out of the code.
  lwz r11, 0x1F0(r28)              # \
  lwz r12, 0x1F0(r5)               # / Otherwise, instead grab their sub-slot IDs...
  cmplw r11, r12                   # ... and compare with those instead!
}
HOOK @ $8069A2AC                # [in "incCharColorNo/[muSelCharPlayerArea]/mu_selchar_player_ar" @ 0x8069A22C, Ghidra: $806A5B48]
{
  cmplw r30, r0                    # Restore Original Instruction: Compare our Char ID with Opposing Port's
  bne+ %END%                       # If they're not, we can just skip out of the code.
  lwz r11, 0x1F0(r31)              # \
  lwz r12, 0x1F0(r5)               # / Otherwise, instead grab their sub-slot IDs...
  cmplw r11, r12                   # ... and compare with those instead!
}
HOOK @ $8069A3BC                # [in "decCharColorNo/[muSelCharPlayerArea]/mu_selchar_player_ar" @ 0x8069A340, Ghidra: $806A5C58]
{
  cmplw r30, r0                    # Restore Original Instruction: Compare our Char ID with Opposing Port's
  bne+ %END%                       # If they're not, we can just skip out of the code.
  lwz r11, 0x1F0(r31)              # \
  lwz r12, 0x1F0(r5)               # / Otherwise, instead grab their sub-slot IDs...
  cmplw r11, r12                   # ... and compare with those instead!
}
HOOK @ $80684E8C                # [in "changeDuplicateCharColor/[muSelCharTask]/mu_selchar.o" @ 0x80684DCC, Ghidra: $80690728]
{
  cmplw r28, r4                    # Compare our Char ID with Opposing Port's
  bne+ exit                        # If they're not, we can just skip out of the code.
  lwz r11, 0x1F0(r25)              # \
  lwz r12, 0x1F0(r3)               # / Otherwise, instead grab their sub-slot IDs...
  sub r12, r11, r12                # ... get the difference between those values...
  add r4, r4, r12                  # ... and add it to the opposing ID, so if the sub-IDs were different, the main IDs will be too!
exit:
  stw r4, 0x00(r6)                 # Restore Original Instruction
}

