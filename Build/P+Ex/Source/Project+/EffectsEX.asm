#################################################################################################################
Effect.pac Roster Expansion System (RSBE.Ver) V3 (Costume-Specific Etc File Support) [JOJI, DukeItOut, QuickLava]
# Rewrote code to finish in a single loop iteration, rather than needing to run multiple times. Additionally,
# characters now have 128 Ef IDs instead of just 64, which has necessitated moving the start of ROB's Ef IDs
# from 0x277 to 0x2B7. Additionally, removed the un-needed Yoshi IDs, as they weren't ever used.
#################################################################################################################
.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
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
.macro call(<addr>)
{
  %lwi(r12, <addr>)
  mtctr r12
  bctrl
}
.macro doCharNameCheck(<nameStrAddr>, <baseID>) # Used in the first HOOK to make adding new entries consistent! BaseIDs should be 0x80 apart!
{
  mr r3, r31                                 # Point r3 to the name string in the buffer.
  %lwi(r4, <nameStrAddr>)                    # And point r4 to the appropriate name string.
  addi r0, r27, 0x1                          # And we'll adjust the number of bytes to compare such that we'll include the null terminator.
  bl stringCompareSubroutine                 # Then do the comparison!
  li r12, <baseID>                           # Preload r12 with the base address for this character...
  beq costumeSpecificIDFound                 # ... and if the strings *did* match, then we'll branch and actually use that value!
}

.RESET

op li r0, 11 @ $8005EAD0
address $8059DAB8 @ $80451A88
address $80452C54 @ $80451A8C
address $80452C64 @ $80451A90
.alias SonicStrAddr             = 0x8059D734
.alias SonicFirstID             = 0x237
.alias RobStrAddr               = 0x8059D6F4
.alias RobFirstID               = 0x2B7
# Setup Knuckles String
address $8059D722 @ $80451C0C
string "knuckles" @ $8059D722
.alias KnuxStrAddr              = 0x8059D722
.alias KnuxFirstID              = 0x337
.alias MaxID                    = 0x3B7
.alias HexStrToNum              = 0x80392994
.alias DecStrToNum              = 0x80392D88
string "custom"                 @  $80416F60
.alias CustomStrAddr            = 0x80416F60
.alias StrBufStackOff           = 0x08
.alias StrBufTotalStackLen      = 0x40       # Note: the below "stwu r1" line MUST use the negative version of this value!
HOOK @ $8005EFCC                # Address = $(ba + 0x0005EFCC) [in "searchResourceId/[ecMgr]/ec_mgr.o" @ $8005EC64, Ghidra: $8005efcc]
{
  addi r31, r31, 0x4                         # Restore Original Instruction!
  cmplwi r27, 0x137                          # If in the loop, we're at a vBrawl Effect ID...
  blt %END%                                  # ... skip code! So we only do the code body if we're looking at expanded IDs (Ex Chars, Per-Costume IDs)
  
  stwu r1, -0x40(r1)                         # Otherwise, allocate some space on the stack for our string buffer...
  addi r31, r1, StrBufStackOff               # ... and point r31 to the string buffer space within that space!
                                             # Prepare to lowercase and copy the name from the incoming string into our buffer!
  li r0, 0x58                                # Set end char to 'X'
  addi r3, r29, 0x3                          # Put the incoming string address into r3!
  mr r4, r31                                 # Copy the buffer address into r4!
  bl stringByteCopySubroutine                # Run the byte copy routine!
  
  mr r27, r3                                 # Stash the length of that string, since we might need it later.
  cmplwi r27, 0x8                            # \
  bne+ costumeSpecificIDs                    # / If the string isn't 8 chars long, it can't be a "custom__" string, it's not for an EX Char!
  
                                             # Prepare to compare our string with our stored "custom" string!
  li r0, 0x6                                 # Set number of characters to compare to 6!
  %lwi(r3, CustomStrAddr)
  mr r4, r31                                 # And r4 is still r31 from when we set it before, so we can leave that alone.
  bl stringCompareSubroutine                 # Compare the strings!
  bne costumeSpecificIDs                     # The subroutine will do the actual comparison for us; if the strings aren't equal, we're looking at an EX Char!
  
                                             # Prepare to convert the number suffix to a raw number!
  addi r3, r31, 0x6                          # Point r3 to the number part of our name string...
  li r4, 0x02                                # ... set the number of characters to read...
  %call(HexStrToNum)                         # ... and call!
  addi r27, r3, 0x137                        # Then add that to 0x137 to get the ID for this EX Character!
  b rigStrcmp  
   
costumeSpecificIDs:
  add r3, r29, r27                           # Point r3 to r29 plus r27 (length of the name portion of the string)...
  addi r3, r3, 0x4                           # ... then add 4 to account for "ef_" and "X", so r3 points to number part of the string!
  li r4, 0x3                                 # Then set r4 to the number of bytes to convert...
  %call(DecStrToNum)                         # ... and call!
  mr r28, r3                                 # Store the converted result in r28 for now, since this'll be the basis for final ID!
  
                                             # Next determine the character we're looking at!
  %doCharNameCheck(SonicStrAddr, SonicFirstID)    # Check and Branch for Sonic!
  %doCharNameCheck(RobStrAddr, RobFirstID)        # Check and Branch for ROB!
  %doCharNameCheck(KnuxStrAddr, KnuxFirstID)      # Check and Branch for ROB!
                                             
  li r27, 0x7FFF                             # If we didn't branch in either of the above, it means the strings didn't match!
  b exit                                     # In that case, we'll invalidate out the ID here to force us to leave the loop!
  
costumeSpecificIDFound:
  add r27, r12, r28                          # If we *did* find a match though, we'll add the base ID in r12 to the costume num in r28!
  
rigStrcmp:
  addi r12, r29, 0x3
  stw r12, 0x00(r31)                         # Store the address of the r29 string in our buffer area, so we force-pass the upcoming strcmp!
exit:
  addi r1, r1, StrBufTotalStackLen           # Pop the extra space off the stack!
  b %END%
  
stringByteCopySubroutine:                    # r3 = string address, r4 = destination address, r0 = end char, returns len in r3
  subi r11, r3, 0x1                          # Prepare read ptr in r11
  li r3, 0x00                                # Zero out r3, this will hold string size!
copyLoopHead:
  lbzu r12, 0x01(r11)
  cmplw r12, r0                              # \
  beq copyLoopExit                           # / If loaded byte is terminator char, exit! 
  cmplwi r12, 0x20                           # \
  blt- copyLoopExit                          # / If loaded byte is an invalid string char, exit!
  cmplwi r12, 0x40                           # \
  blt+ copyLoopWrite                         # | 
  cmplwi r12, 0x5A                           # | If the loaded byte is between 0x40 and 0x5A (inclusive)...
  bgt+ copyLoopWrite                         # /
  addi r12, r12, 0x20                        # ... it's an uppercase letter, so add 0x20 to convert from upper to lowercase!
copyLoopWrite:
  stbx r12, r4, r3                           # Store the byte in the next spot in the destination buffer...
  addi r3, r3, 0x1                           # ... and increment length tally in r3!
  b copyLoopHead
copyLoopExit:
  li r12, 0x00                               # \
  stbx r12, r4, r3                           # / Cap our string with a null terminator!
  blr                                        # Return from subroutine!
  
stringCompareSubroutine:                     # r3 = string1 address, r4 = string2 address, r0 = # chars to check, returns 0 in r3 if equal, otherwise if not!
  mtctr r0                                   # Put the number of characters to check into the count register to enforce that limit!
  subi r11, r3, 0x1                          # \
  subi r4, r4, 0x1                           # / Prepare r0 and r4 for use as our 
cmpLoopHead:
  lbzu r0, 0x1(r11)                          # \
  lbzu r12, 0x1(r4)                          # / Load the bytes to compare.
  subf. r3, r0, r12                          # Subtract one from the other, if they're the same it'll come out to 0!
  bc 8, 2, cmpLoopHead                       # If *either* the two bytes aren't the same, or we've checked all the bytes we care about...
  blr                                        # ... return! If we made it through the entire loop with the values equal the whole time, r3 is 0!            
}
op cmpwi r27, MaxID @ $8005EFD0 
op cmpwi r3, MaxID @ $8005F01C 
op cmpwi r3, MaxID @ $8005F0A8
 
op cmplwi r4, 2701 @ $80061200
HOOK @ $80061218                # Address = $(ba + 0x00061218) [in "traceStart/[ecMgr]/ec_mgr.o" @ $80061160]
{
    lwzx r4, r4, r9                          # Restore Original Instruction
    cmplwi r21, 0x87                         # \
    blt %END%                                # / If Trace ID is less than 0x87 (beginning of Expanded IDs), exit.
    li r4, 0x28                              # Otherwise, assume to start that we're looking at Roy's IDs at the beginning of the Range.
    cmplwi r21, 0x8d                         # \
    blt %END%                                # / If our Trace ID is less than 0x8D (and greater than 0x87), then use Roy's Effect ID and exit.
    subi r12, r21, 0x8d                      # Otherwise, trace is for another Ef, so get appropriate Ef ID! Adjust Trace ID so first EX Trace is 0x00...
	li r4, 0xA                               # ... set r4 to 10...
	divwu r4, r12, r4                        # ... and divide! Thanks to Integer rounding, end result is just the integer Ef ID for that Trace!
	addi r4, r4, 0x137                       # Then add 0x137 to get the final ID!
}
string "TexRoySwordTrace00"  @ $80416F80
.alias TexRoyStrAddr        = 0x80416F80
string "TexCustom00Trace00"  @ $80416FA0
.alias TexCustStrAddr       = 0x80416FA0
HOOK @ $80061278                # Address = $(ba + 0x00061278) [in "traceStart/[ecMgr]/ec_mgr.o" @ $80061160]
{
    lwzx r4, r4, r9                          # Restore Original Instruction
    cmplwi r21, 0x87                         # \
    blt %END%                                # / If Trace ID is less than 0x87 (beginning of Expanded IDs), exit.
	%lwi(r4, TexRoyStrAddr)                  # Otherwise, assume to start that we're looking at Roy's IDs, so point r4 to RoyTex String!
    subi r12, r21, 0x87                      # Subtract 0x87 out of the Trace ID so Roys IDs start at 0x00...
    addi r12, r12, 0x30                      # ... then add 0x30 to convert it to ASCII...
    stb r12, 0x11(r4)                        # ... and store it as the final char in the TexRoy string.
    cmplwi r21, 0x8d                         # \ 
    blt %END%                                # / Check if Trace ID is less than 0x8D (indicating we ARE looking at Roy's IDs), exit if we are.
	
	                                         # Otherwise, trace is for a custom Effect bank!
	%lwi(r4, TexCustStrAddr)                 # Point r4 at the TexCustom string.
    subi r12, r21, 0x8d                      # Adjust Trace ID so first EX Trace is 0x00...
	li r11, 10                               # ... set r11 to 10...
	divwu r11, r12, r11                      # ... and divide! Thanks to Integer rounding, end result is just the integer Ef ID for that Trace!
	mulli r5, r11, 10                        # \
	sub r5, r12, r5                          # / Then use the result of the division to get the 0-based ID % 10 in r5...
	addi r5, r5, 0x30                        # ... add 0x30 to convert it to ASCII...
    stb r5, 0x11(r4)                         # ... then store it as the Trace ID in the string!
	                                         # Then handle converting and writing in the two digits of the Ef ID!
	rlwinm r12, r11, 28, 28, 31              # First digit, rotate second-lowest nibble into the bottom of r12.
    cmplwi r12, 10                           # \
    blt 0x8                                  # | If the digit is greater than 10, add an extra 7 so it converts to 'A' in ASCII.
    addi r12, r12, 0x7                       # / Otherwise, skip that addition.
    addi r12, r12, 0x30                      # Add 0x30 to convert to ASCII...
    stb r12, 0x9(r4)                         # ... and store it as the other digit in the string.
	                                         
	rlwinm r12, r11, 0, 28, 31               # Second digit, rotate lowest nibble into the bottom of r12.
    cmplwi r12, 10                           # \
    blt 0x8                                  # | If the digit is greater than 10, add an extra 7 so it converts to 'A' in ASCII.
    addi r12, r12, 0x7                       # / Otherwise, skip that addition.
    addi r12, r12, 0x30                      # Add 0x30 to convert to ASCII...
    stb r12, 0xa(r4)                         # ... and store the result in the string. First digit done.
}
* E0000000 80008000             # Full Terminator: ba = 0x80000000, po = 0x80000000