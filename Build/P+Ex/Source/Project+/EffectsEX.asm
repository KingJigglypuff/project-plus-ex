########################################################################################################################
Effect.pac Roster Expansion System (RSBE.Ver) V4 (Global Costume-Specific Etc File Support) [JOJI, DukeItOut, QuickLava]
# V3: Rewrote code to finish in a single loop iteration, rather than needing to run multiple times. Additionally,
# characters now have 128 Ef IDs instead of just 64, which has necessitated moving the start of ROB's Ef IDs
# from 0x277 to 0x2B7. Additionally, removed the un-needed Yoshi IDs, as they weren't ever used.
# V4: Further expanded to allow the system to work for *any* character, as well as allow any character to use their
# actual name for their Effects Bank. Maintains legacy support for Sonic, ROB, and Knuckles' existing ID ranges, along
# with support for the old "ef_customXX" naming scheme.
########################################################################################################################
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
.macro doHardCodedNameCheck(<nameStrAddr>, <baseID>) # Used in the first HOOK to make adding new entries consistent! BaseIDs should be 0x80 apart!
{
  addi r3, r1, StrBufName2StackOff           # Point r3 to the directory name we matched on.
  %lwi(r4, <nameStrAddr>)                    # And point r4 to the appropriate name string.
  addi r0, r27, 0x1                          # And we'll adjust the number of bytes to compare such that we'll include the null terminator.
  bl stringCompareSubroutine                 # Then do the comparison!
  bne 0xC                                    # 
  li r28, <baseID>                           # Overwrite r28 with the specified base address for this character...
  b finalizeID                               # ... and branch out to finalize our ID!
}

.RESET

op li r0, 11 @ $8005EAD0
address $8059DAB8 @ $80451A88
address $80452C54 @ $80451A8C
address $80452C64 @ $80451A90
string "custom"                   @  $80416F60
.alias CustomStrAddr              = 0x80416F60
.alias CustomSchemeIDsStart       = 0x137
.alias SonicStrAddr               = 0x8059D734
.alias SonicIDsStart              = 0x237
.alias RobStrAddr                 = 0x8059D6F4
.alias RobIDsStart                = 0x2B7
# Setup Knuckles String
address $8059D722 @ $80451C0C
string "knuckles" @ $8059D722
.alias KnuxStrAddr                = 0x8059D722
.alias KnuxIDsStart               = 0x337
.alias HardcodedIDsEnd            = 0x3B7
.alias MaxFighterCount            = 0x100
.alias PerCostumeEfIDsPerFighter  = 0x80
.alias PerCostumeEfIDsStart       = HardcodedIDsEnd
.alias PerCostumeEfIDsCount       = 0x8000             # eg. 0x80 for each of the allowed 0x100 Fighter Slots
.alias PerCostumeEfIDsEnd         = PerCostumeEfIDsStart + PerCostumeEfIDsCount
.alias GenericEfIDsStart          = PerCostumeEfIDsEnd
.alias GenericEfIDsCount          = MaxFighterCount    # eg. 1 ID For Each Character
.alias GenericEfIDsEnd            = GenericEfIDsStart + GenericEfIDsCount
.alias MaxID                      = GenericEfIDsEnd
.alias HexStrToNum                = 0x80392994
.alias DecStrToNum                = 0x80392D88
.alias StrBufNameMaxLen           = 0x18
.alias StrBufName1StackOff        = 0x08
.alias StrBufName2StackOff        = StrBufName1StackOff + StrBufNameMaxLen
.alias StrBufTotalStackLen        = 0x40       # Note: the below "stwu r1" line MUST use the negative version of this value!
HOOK @ $8005EFCC                  # Address = $(ba + 0x0005EFCC) [in "searchResourceId/[ecMgr]/ec_mgr.o" @ $8005EC64, Ghidra: $8005efcc]
{
  addi r31, r31, 0x4                         # Restore Original Instruction!
  cmplwi r27, 0x137                          # If in the loop, we're at a vBrawl Effect ID...
  blt %END%                                  # ... skip code! So we only do the code body if we're looking at expanded IDs (Ex Chars, Per-Costume IDs)
  
  stwu r1, -0x40(r1)                         # Otherwise, allocate some space on the stack for our string buffer...
  addi r31, r1, StrBufName1StackOff          # ... and point r31 to the name buffer space within that space!
                                             # Prepare to lowercase and copy the name from the incoming string into our buffer!
  li r0, 0x00                                # Set end char to null terminator to copy the whole string.
  addi r3, r29, 0x3                          # Put the incoming string address into r3!
  mr r4, r31                                 # Copy the buffer address into r4!
  bl stringByteCopySubroutine                # Run the byte copy routine! This returns the length in r3!
  
handleCustomXXScheme:                        # Handle the old "ef_custom##" naming scheme!
  cmplwi r3, 0x8                             # \
  bne+ determineCharacter                    # / If the string isn't 8 chars long, it can't be a "ef_custom##" string, so skip forward!
  li r0, 0x6                                 # Set number of characters to compare to 6!
  %lwi(r3, CustomStrAddr)                    # Point r3 to the "custom" string we have stored...
  mr r4, r31                                 # ... and r4 to the name we copied into our buffer before.
  bl stringCompareSubroutine                 # Compare the strings (the subroutine will do the actual comparison for us).
  bne determineCharacter                     # If the strings aren't equal, we're using a different naming scheme, skip forawrd!
  addi r3, r31, 0x6                          # Otherwise, convert the str suffix to a number! Point r3 to the number part of the Ef Bank name...
  li r4, 0x02                                # ... set the number of characters to read...
  %call(HexStrToNum)                         # ... and call!
  addi r27, r3, CustomSchemeIDsStart         # Then add the base ID to the result to get the ID for this EX Character!
  b rigStrcmp                                # And we're done! Skip the rest, just rig the strcmp and exit!

determineCharacter:                          # Next determine the character we're looking at!
  li r28, 0x00                               # Zero r28, as we'll use this as our Fighter ID counter.
  lis r26, 0x817C                            # \ Prepare pointer to FitChar.pac Path address array, since we'll be using
  ori r26, r26, 0x7BFC                       # / the folder name portion of those strings to check our Ef Bank name against!
nameSearchLoopHead:
  lwzu r3, 0x4(r26)                          # Grab the address of the current FitChar.pac Path.
  addi r4, r1, StrBufName2StackOff           # Point r4 to the designated destination region in our String Buffer.
  li r0, 0x2F                                # Set r0 to '/' so we'll stop at the slash in the filepath.
  bl stringByteCopySubroutine                # Copy and lowercase the folder name to the destination in the String Buffer!
  mr r27, r3                                 # Backup the length of the directory name...
  mr r0, r3                                  # ... and copy it into r0 to limit the coming comparison.
  mr r3, r31                                 # \
  addi r4, r1, StrBufName2StackOff           # / Point r3 and r4 to the respective name buffers...
  bl stringCompareSubroutine                 # ... and compare!
  bne+ continueLoop                          # If they're not equal, skip further checks and continue the loop.
                                             # Otherwise, we need to do some further checks!
  add r3, r31, r27                           # Point r3 to what should be the Ef Bank Name's terminator if this is a true match.
  lbz r0, 0x00(r3)                           # Load the terminator...
  cmplwi r0, 0x00                            # ... and if it's null...
  beq nonCostumeSpecificMatch                # ... then this is non-costume specific match! We can jump out of our loop!
  lbzu r12, 0x1(r3)                          # Otherwise, maybe it's a Costume-Specific Name. Grab the char after the potential terminator (advancing r3)...
  subi r12, r12, 0x30                        # \
  cmplwi r12, 0x9                            # | ... and if it isn't a number (ie. 0x30 - 0x39)...
  bgt continueLoop                           # / ... then continue the loop, cuz this isn't a Costume-Specific Name match!
  cmplwi r0, 0x78                            # If it was though, check if the proper terminator is in place...
  beq costumeSpecificMatch                   # ... and branch out if so! Note: we check for 'x', not 'X', cuz we lowercased on copy.
continueLoop:
  addi r28, r28, 0x1                         # Otherwise, increment the Fighter ID counter...
  cmplwi r28, 0x80                           # ... and if as long as we're not at the Max Fighter ID...
  blt+ nameSearchLoopHead                    # ... continue the search!
searchFailed:
  lis r27, 0xFFFF                            # If we didn't branch in either of the above, it means the strings didn't match!
  b exit                                     # In that case, we'll invalidate out the ID here to force us to leave the loop!
  
nonCostumeSpecificMatch:
  addi r27, r28, GenericEfIDsStart           # If ID is non-costume-specific, final ID is just GenericIDStart + FID!
  b rigStrcmp
costumeSpecificMatch:                        # Otherwise, determine Costume ID (r3 already points to ID part of EfBankName)!
  li r4, 0x3                                 # Set r4 to convert 3 bytes to support 3 decimal digits...
  %call(DecStrToNum)                         # ... and call! After this, r3 should be Costume ID!
  mr r26, r3                                 # Backup ID in r26, since we no longer need the string addr from the loop.
  rlwinm r28, r28, 7, 0, 24                  # Multiply the Fighter ID by 0x80, to set up base EfID.
  addi r28, r28, PerCostumeEfIDsStart        # Add start ID to Base EfID.
                                             # Lastly, process the legacy hardcoded IDs (just comment them out if they're undesired).
  %doHardCodedNameCheck(SonicStrAddr, SonicIDsStart)    # Check and Branch for Sonic!
  %doHardCodedNameCheck(RobStrAddr, RobIDsStart)        # Check and Branch for ROB!
  %doHardCodedNameCheck(KnuxStrAddr, KnuxIDsStart)      # Check and Branch for Knuckles!
  
finalizeID:
  add r27, r28, r26                          # Add base ID in r28 to costume ID in r26, and we're done!
  
rigStrcmp:
  addi r12, r29, 0x3
  stw r12, 0x00(r31)                         # Store the address of the r29 string in our buffer area, so we force-pass the upcoming strcmp!
exit:
  addi r1, r1, StrBufTotalStackLen           # Pop the extra space off the stack!
  b %END%
  
stringByteCopySubroutine:                    # r3 = string address, r4 = destination address, r0 = end char, returns len in r3
  subi r11, r3, 0x1                          # Prepare read ptr in r11
  li r3, StrBufNameMaxLen                    # \
  mtctr r3                                   # / Use the CTR to enforce a maximum copy length.
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
  bdnz+ copyLoopHead
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
op cmplwi r27, MaxID @ $8005EFD0 
op cmplwi r3, MaxID @ $8005F01C 
op cmplwi r3, MaxID @ $8005F0A8
 
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