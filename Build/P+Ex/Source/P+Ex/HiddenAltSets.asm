#############################################################################################
[Legacy TE] Restrict Special Character Selection to L 1.1 [PyotrLuzhin, Yohan1044, DukeItOut]
#
# 1.1: Re-added support for Wiimote and Wiimote+Nunchuk
#############################################################################################
# op li r0, 0x40 @ $8068480C	# Old version of code
HOOK @ $8068480C                # Address = $(ba + 0x0068480C) [in "setToGlobal/[muSelCharTask]/mu_selchar.o" @ $806846E0, $806900A8]
{
	lwzx r0, r3, r0		# Original operation
	li r12, -0x21		# \ Load a filter FFFF FFDF to clear out 20 (GC/CC R)
	and r0, r0, r12		# /
}
int 0x80000 @ $806A080C	# Make Nunchucks use (-) instead of C

####################
AltR/Z EX Fix [Desi]
####################
op lwz r7, 0x0A14 (r28) @ $8084CFB8 # Load pointer to ".pac" string!
op lwz r6, 0x0A18 (r28) @ $8084CE28 # Load pointer to "Dark" string!
op lwz r7, 0x0A14 (r28) @ $8084CE30 # Load pointer to ".pac" string!

#################################################################################################
Hidden Alt Costume Sets Rework v1.1.5 [QuickLava]
# v1.1.5
# - Raised AltIDRangeStart to 60 to maintain support for Costume IDs 50-59
# - Lowered NumAltIDsStart to 68 so IDs 50-59 have corresponding Alt IDs
# - Introduced proper NumAlt ID Range Check, so NumAlt Behavior can be limited to a range of IDs (or disabled if NumAltIDsEnd set to 0).
# - Introduced AltIDRangeEnd, so Alt behavior can be disabled past a certain ID.
#################################################################################################
.alias AltIDRangeStart          = 60    # \ Costume IDs within this (inclusive) range are considered reserved for Alts!
.alias AltIDRangeEnd            = 127   # / Any below IDs that fall outside of this range *will not* be loaded!
.alias AltRID                   = 61    # R-Alt Costume ID
.alias AltZID                   = 62    # Z-Alt Costume ID
.alias NumAltIDsStart           = 68    # \ Costume IDs within this (inclusive) range are considered reserved for NumAlts! NumAlt ID for any
.alias NumAltIDsEnd             = 127   # / non-alt costume is ID + NumAltIDsStart! Requests to load NumAlts with IDs above NumAltIDsEnd are ignored!
.alias getSysPadStatus          = 0x8002AE48
.alias ftConvertKind            = 0x808545EC
.alias strcpy                   = 0x803FA280
.alias sprintf                  = 0x803F89FC
.alias PacPathPtrArray          = 0x817C7C00
.alias FPC_checkModSDFile       = 0x8001F59C
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
.macro sqAdvCheck()
{
    lis r12, 0x805B                     # \
    lwz r12, 0x50AC(r12)                # | Retrieve the pointer to the game mode's name string!
    lwz r12, 0x10(r12)                  # |
    lwz r12, 0x0(r12)                   # /
    lis r11, 0x8070                     # \
    ori r11, r11, 0x2B60                # | Compare that against the location of the "sqAdventure" string constant...
    cmplw cr7, r11, r12                 # / ... and store the result in CR7, so the result can be reused if necessary!
}
# Sets 
.macro IDWithinAltRange(<IDReg>, <DestCRF>, <WorkCRF>, <DestCRBit>)
{
  .alias tmp1 = <DestCRF> + <DestCRF>
  .alias DestCRF_LTBit = tmp1 + tmp1
  .alias DestCRF_ResultBit = DestCRF_LTBit + <DestCRBit>
  .alias tmp2 = <WorkCRF> + <WorkCRF>
  .alias tmp3 = tmp2 + tmp2
  .alias WorkCRF_GTBit = tmp3 + 1
  
  cmplwi cr<DestCRF>, <IDReg>, AltIDRangeStart             # \ 
  cmplwi cr<WorkCRF>, <IDReg>, AltIDRangeEnd               # / Check if the requested File ID is within the Alt Range,
  crnor DestCRF_ResultBit, DestCRF_LTBit, WorkCRF_GTBit    # ... and store result in the specified bit!
}
# These skip the code for loading .pcs files.
op b 0x1C @ $8084CE34                   # [in "req/[ftDataProvider]/ft_data_provider.o" @ $8084C368, Ghidra: $8085ADC0] Skips G&W Dark .pcs Load
op b 0x1C @ $8084CF38                   # [in "req/[ftDataProvider]/ft_data_provider.o" @ $8084C368, Ghidra: $8085AEC4] Skips Normal Char Dark .pcs Load
op b 0x1C @ $8084CFBC                   # [in "req/[ftDataProvider]/ft_data_provider.o" @ $8084C368, Ghidra: $8085AF48] Skips Normal Char Fake .pcs Load

.BA <- LocalMemoryStart
.GOTO -> LocalMemoryEnd
LocalMemoryStart:                       # We're going to use this area as a space to store some variables and constants!
word 0x00000000                         # These 4 bytes store the requested Alt Type for each player slot!
string[6] |                             # These are the string constants we'll be using to load different sets of files.
"EtcAlt", "AltZ", "AltR",|
"/fighter/%s%s%s%s",|
"/fighter/%s%s%02d%s",|
"_00"
LocalMemoryEnd:
.alias AltRequestLocalMemOff   = 0x00
.alias EtcAltStrLocalMemOff    = 0x04
.alias Alt0StrLocalMemOff      = 0x07
.alias AltZStrLocalMemOff      = 0x0B
.alias AltRStrLocalMemOff      = 0x10
.alias StrAltFmtStrLocalMemOff = 0x15
.alias NumAltFmtStrLocalMemOff = 0x27
.alias KHatAltStrLocalMemOff   = 0x3B
.BA -> $8084CE38
.alias LocalMemoryAddrLoc = 0x8084CE38  # We're gonna store the address for this in the area skipped by the first .pcs skip above!
.RESET                                  # And finally reset BA and PO.

# As we leave CSS, record what alt is being requested based on the buttons being held on each controller!
HOOK @ $80684790               # [in "setToGlobal/[muSelCharTask]/mu_selchar.o" @ $806846E0, Ghidra: $8069002C]
{
  mr r15, r3                            # Temporarily store r3 and r4, since we'll need them later.
  mr r28, r4                            #
  lis r3, 0x805A                        # \
  lwz r3, 0x40(r3)                      # / Get g_gfPadSystem Address
  lwz r4, 0x1DC(r24)                    # Grab current controller ID
  addi r5, r1, 0x58                     # Point read destination to the stack space set aside for it!
  %call(getSysPadStatus)                # Get pad status.

  mr r3, r15                            # \
  mr r4, r28                            # / Restore r3 and r4's values!
  lwz r28, 0x01BC (r24)                 # Restore Original Instruction, Get Costume File ID in r28!

  %lwd(r11, LocalMemoryAddrLoc)         # Then grab the address for our Local Memory from the Addr Loc.
  
  lwz r12, 0x58(r1)                     # Load the currently held buttons!
  rlwinm r15, r12, 28, 30, 31           # Rotate the button states we care about down into the first nibble of r15. None = 0, Z = 1, R = 2, Both = 3
  
  lwz r0, 0x1DC(r24)                    # Re-get the controller ID...
  stbx r15, r11, r0                     # ... and use it to store the requested alt in the appropriate spot in our Local Storage!
}
# Ensure that ALL Alt Requests are cleared on return to the CSS to avoid redundant Alt loading when returning from SSS!
HOOK @ $8068292C               # [in "__ct/[muSelCharTask]/mu_selchar.o" @ $80682924, Ghidra: $8068e1c8]
{
  %lwd(r4, LocalMemoryAddrLoc)          # Grab the address for our Local Memory from the Addr Loc.
  li r12, 0x00                          # \
  stw r12, AltRequestLocalMemOff(r4)    # / Zero out the Alt Request word!
  lis r4, 0x806A                        # Restore Original Instruction
}
# Clear each port's Alt Request on fighter init so further fighters spawned in that slot don't use it by accident, and to fix Event mode!
HOOK @ $80814338               # [in "createFighter/[ftManager]/ft_manager.o" @ $80814334, Ghidra: $808222C4] 
{
  andi. r0, r4, 0x07                     # Get the Player ID for this Fighter...
  cmplwi r0, 0x3                         # ... and if it's above 3 (Player 4)...
  bgt- exit                              # ... skip to the exit.
  %lwd(r11, LocalMemoryAddrLoc)          # Grab the address for our Local Memory from the Addr Loc.
  li r12, 0x00                           # ... zero out r12...
  stbx r12, r11, r0                      # ... and use it to zero out the Alt Request for this fighter!
exit:
  mflr r0                                # Restore Original Instruction
}

# Hijack the Costume File ID watcher to inject our own ID when we request an alt, loading a different costume!
HOOK @ $809463EC               # [in  "processBegin/[stLoaderPlayer]/st_loader_player.o" @ $80946004, Ghidra: $809540cc]
{
  lbz r5, 0x05(r3)                      # Restore Original Instruction: Get character's Costume File ID.
  %IDWithinAltRange(r5, 0, 1, 2)        # \
  beq %END%                             # / If an Alt is already applied, skip the code cuz the ID is already right!
  
  lwz r12, 0x48(r30)                    # Otherwise, get player slot from stLoaderPlayer struct!
  %lwd(r11, LocalMemoryAddrLoc)         # Then grab the address for our Local Memory from the Addr Loc.
  lbzux r12, r11, r12                   # Grab the alt request for the relevant port, and also point r11 to that byte for later!
  cmplwi r12, 0x00                      # \
  beq %END%                             # / If no Alt is being requested, we can leave.
  
  cmplwi r12, 0x03                      # If we wanted NumAlts though...
  addi r5, r5, NumAltIDsStart           # ... we'll encode that by adding the base NumAltID to the requested ID!
  cmplwi cr7, r5, NumAltIDsEnd          # Validate that the resulting ID is within the allowed NumAlt Range...
  ble+ cr7, numAltGood                  # ... and if it is, then our adjusted ID is good! Leave it in place and continue!
  subi r5, r5, NumAltIDsStart           # If it *is* too high though, consider the adjusted ID invalid and restore the original!
numAltGood:
  bge exit                              # ... and branch to the exit.

  cmplwi r12, 0x02                      # If instead we wanted R-Alt...
  li r5, AltRID                         # ... load r5 with the appropriate ID...
  beq exit                              # ... and branch to the exit.

  li r5, AltZID                         # And lastly, if we wanted Z-Alt load that ID. No branch needed though, we're already here.
exit:
  %IDWithinAltRange(r5, 0, 1, 2)        # \ Verify that the final Alt ID is within the valid range...
  beq storeID                           # / ... and if it is, continue to storing it!
  lbz r5, 0x05(r3)                      # Otherwise, our Alt ID was bad, restore the original value!
storeID:
  stb r5, 0x5(r3)                       # Store our final modified ID on the way out!
}
# If we're requesting an Alt, check if the file actually exists before attempting to switch!
.alias NameBuf1StackOff = 0x08
.alias NameBuf2StackOff = 0x34
.alias NameBufTotalStackLen = 0x70      # Note: the below "stwu r1" line MUST use the negative version of this value!
HOOK @ $80946424               # [in  "processBegin/[stLoaderPlayer]/st_loader_player.o" @ $80946004, Ghidra: $809543B0]
{
  cmplw r3, r0                          # Restore Original Instruction: Compare Stored Costume ID w/ Incoming Costume ID...
  beq %END%                             # ... and if they're the same, we can skip this code!
  
  %IDWithinAltRange(r0, 6, 7, 2)        # \ Additionally, check if the Costume ID is within the Alt Range...
  bne cr6, %END%                        # / ... and if it isn't, skip! Compare in CR6/7 to avoid overwriting the previous comparison!
  
  stwu r1, -0x70(r1)                    # Push some extra space onto the stack, for if we need to build our strings here!
  
  mr r10, r0                            # Stash File ID for later!
  lbz r3, 0x00(r31)                     # Get the current Slot ID from the PlayerInit Struct...
  addi r4, r1, NameBuf1StackOff         # And point r4 to our local buffer!
  %call(ftConvertKind)                  # Then convert our Slot ID to a Fighter ID!
  lwz r12, NameBuf1StackOff(r1)         # Load the result ID...
  rlwinm r12, r12, 2, 0, 29             # ... and quadruple it, so we can use it as an index into the .pac path ptr array!
  %lwi(r4, PacPathPtrArray)             # Get address to ptr array.
  lwz r9, 0xA10(r4)                     # While we've got this address, also grab and stash the ".pac" path string for later!
  lwzx r4, r4, r12                      # Additionally, use it to grab the pointer to our fighter's .pac path string!
  addi r3, r1, NameBuf1StackOff         # Point r3 to our string buffer again...
  %call(strcpy)                         # ... and copy the string over!
                                        # Note: A fact of the strcpy implementation is that r7 is always the ptr the function writes to...
                                        # ... and that r0 is always the reg chars are copied with (and thus, post copy, is the null-terminator).
  stb r0, -0x4(r7)                      # We also know the copied str always ends in ".pac", so we can write r0 to r7 - 0x4 to terminate before that!
                                        # The last thing we need to do here is sprintf to make our new filepath, and we need a 0-length default...
                                        # ... string in r7 to use in case we're doing a string-alt! That r7 points to null already is perfect for this!
  
  %lwd(r11, LocalMemoryAddrLoc)         # Grab the pointer to our Local Memory...
  addi r3, r1, NameBuf2StackOff         # Point r3 to our destination buffer!
  addi r4, r11, StrAltFmtStrLocalMemOff # Assume for now that we're looking at a non-numbered alt, point r4 to the relevant format string!
  addi r5, r1, NameBuf1StackOff         # Point the first string argument at our truncated .pac path from before!
  mr r8, r9                             # And copy the ".pac" string pointer into r8!
  
  addi r6, r11, AltZStrLocalMemOff      # Assume by default that we're looking at AltZ
  
  cmplwi r10, AltRID                    # \
  bne 0x8                               # | If instead it was AltR, swap in that string!
  addi r6, r11, AltRStrLocalMemOff      # / 
  
  cmplwi r10, NumAltIDsStart            # \
  blt notNumAlt                         # | If instead it was a NumAlt...
  subi r7, r10, NumAltIDsStart          # | ... prepare the number argument in r7...
  addi r4, r11, NumAltFmtStrLocalMemOff # | ... point to the appropriate formatting string...
  addi r6, r11, Alt0StrLocalMemOff      # / ... and point to the proper "Alt" string!
notNumAlt:
  %call(sprintf)
  
  addi r3, r1, NameBuf2StackOff         # Point r3 to the filepath we just wrote.
  %call(FPC_checkModSDFile)             # And check if the file exists! If the file exists, r3 returns 0!
  cmplwi r3, 0x00                       # \ Do the comparison against 0! But to match the polarity of the check after this hook...
  crnor 2, 2, 2                         # | ... invert our comparison result! So bne fires if file found, beq fires otherwise!
  bne- exit                             # / So, if the file was found, skip disabling the Alt and allow the reload!

disableAlt:
  lbz r0, 0x5B(r30)                     # Grab the originally selected costume from the Loader...
  stb r0, 0x5(r31)                      # ... and store it in the PlayerInit struct to disable the attempt!
  li r12, 0x00                          # Zero out r12.
  %lwd(r11, LocalMemoryAddrLoc)         # Grab the pointer to our Local Memory...
  lwz r0, 0x48(r30)                     # ... then regrab the controller ID for this character...
  stbx r12, r11, r0                     # ... and zero out the relevant alt request!
  
exit:
  addi r1, r1, NameBufTotalStackLen     # Pop the extra space off the stack!
}

# Overrides general Fake Costume check in Req Resource 8 block: Block only used if in SSE and Fake!
HOOK @ $8084CF64               # [in "req/[ftDataProvider]/ft_data_provider.o" @ $8084C368, Ghidra: $8085AEF0]
{
  %sqAdvCheck()
  bne+ cr7, notSSE                      # If not in SSE, skip Fake check.
  cmplwi r23, 13                        # \
  b %END%                               # / Otherwise, do the normal check and exit.
notSSE:
  crandc 2, 2, 2                        # If we're not in Subspace, ANDC the CR0 EQ bit with itself to ensure we fail the Fake check!
}
# Overrides general Dark Costume check in Req Resource 8 block: Block only used if in SSE and Dark, or Alt Requested
HOOK @ $8084CEE0               # [in "req/[ftDataProvider]/ft_data_provider.o" @ $8084C368, Ghidra: $8085ae6c]
{
  %sqAdvCheck()
  bne+ cr7, notSSE                      # If not in SSE, skip Dark check.
  cmplwi r23, 12                        # \
  b %END%                               # / Otherwise, do the normal check and exit.
  
notSSE:
  %IDWithinAltRange(r23, 0, 1, 2)       # Check if ID is in Alt Range, store result in CR0 EQ to stay in the Dark branch if Alt signaled!
}
# Swap in Alt strings before sprintf!
HOOK @ $8084CF54               # [in "req/[ftDataProvider]/ft_data_provider.o" @ $8084C368, Ghidra: $8085AEE0]
{
  addi r4, r29, 0xAC0                   # Restore Original Intruction: Setup default formatting string!
  %IDWithinAltRange(r23, 0, 1, 2)       # \
  bne %END%                             # / Check if the Costume ID is within the Alt Range, and if it isn't skip!

  %lwd(r11, LocalMemoryAddrLoc)         # Then grab the address for our Local Memory from the Addr Loc.
  addi r6, r11, AltZStrLocalMemOff      # Assume to start that we're requesting the Z Alt, so point r6 to the "AltZ" string!
  cmplwi r23, AltRID                    # Then, check if instead we're asking for R Alt...
  bne 0x8                               # ... and if so...
  addi r6, r11, AltRStrLocalMemOff      # ... instead point to the "AltR" string!

  cmplwi r23, NumAltIDsStart            # That's all we have to do actually for Z and R alts...
  blt %END%                             # ... so we can exit if we're not dealing with Alt type 3.

NumAlt:                                 # If we are though...
  addi r4, r11, NumAltFmtStrLocalMemOff # ... we'll set up our replacement formatting string...
  addi r6, r11, Alt0StrLocalMemOff      # ... put the address for our "Alt" string in r6
  mr r8, r7                             # ... move the ".pac" string to r8...
  subi r7, r23, NumAltIDsStart          # ... and setup our Alt Number in r7 by subtracting back out the the start of our number range!
}

# G&W Alt Costume Compatibility Fix!
HOOK @ $8084CDDC               # [in "req/[ftDataProvider]/ft_data_provider.o" @ $8084C368, Ghidra: $8085AD68]
{
  %sqAdvCheck()
  bne+ cr7, notSSE                      # If not in SSE, skip Dark check.
  cmplwi r23, 12                        # \
  b %END%                               # / Otherwise, do the normal check and exit.
  
notSSE:
  %IDWithinAltRange(r23, 0, 1, 2)       # Check if ID is in Alt Range, store result in CR0 EQ to stay in the Dark branch if Alt signaled!
}
op bne cr7, 0x104 @ $8084CDE4           # To avoid duplicating stuff, if we enter the Alt branch while not in SSE, branch to the general logic we use for other characters!


# Kirby Hat Alt Compatibility Fix!
HOOK @ $8084DE44                # [in "req/[ftDataProvider]/ft_data_provider.o" @ $8084C368, $8085BDD0]
{
  %sqAdvCheck()
  bne+ cr7, notSSE                      # If not in SSE, skip Dark check.
  cmplwi r8, 12                         # \
  b %end%                               # / Otherwise, do the normal check and exit.
notSSE:
  cmplwi cr7, r23, NumAltIDsStart       # \  If our File ID corresponds to a Numbered Alt...
  blt cr7, 0x8                          # |  ... subtract the base Num Alt ID from it to correct the numbering!
  subi r8, r23, NumAltIDsStart          # /  (Also, compare into CR7 so we can reuse the result in the following HOOK!)
  crandc 2, 2, 2                        # If we aren't in SSE, then AND the EQ bit with its compliment to ensure we always load a hat!
}
HOOK @ $8084DED8               # [in "req/[ftDataProvider]/ft_data_provider.o" @ $8084C368, $8085BE64]
{
  crclr	6, 6                            # Restore Original Instruction
  rlwinm r5, r8, 0, 25, 31              # If we're loading costume-specific hats, sprintf the File Number using our adjusted ID from the above hook!
}
HOOK @ $8084DF28                # [in "req/[ftDataProvider]/ft_data_provider.o" @ $8084C368, $8085BEB4]
{
  addi r6, r1, 0x20		                # Restore Original Instruction, r6 to the ID string we sprintf'd before.
  %IDWithinAltRange(r23, 0, 1, 2)       # \
  bne %END%                             # /  Check if the Costume ID is within the Alt Range, and if it isn't skip!
  
  %lwd(r11, LocalMemoryAddrLoc)         # If instead we *are* looking at an Alt, grab the pointer to our local memory, cuz we'll stage our string there.
  lwz r12, 0x00(r6)                     # Assume we want a Num Alt to start, so load the printed ID into r12 before we change r6.
  addi r6, r11, KHatAltStrLocalMemOff   # Point r6 to the Kirby Hat Alt base string.
  bge- cr7, writeToAltStr               # Reuse the comparison in CR7 from the last HOOK, if we're looking at a Num Alt, branch!
  lis r12, 0x5A00                       # \
  cmpwi r23, AltZID                     # | Otherwise, if we're asking for the Z-Alt, load null-terminated "Z" into r12, then branch.
  beq- writeToAltStr                    # /
  lis r12, 0x5200                       # Only other option is R-Alt, load null-terminated "R" into r12, but no branch cuz we're here already.
writeToAltStr:
  stw r12, 0x1(r6)
}

######################################################################
#[Legacy TE] New Load Flag Commands For Etc 1.3 [DukeItOut, QuickLava]
# v1.3: Now supports numbered Alt set!
######################################################################
# Changes trigger condition for Case 6, Motion
HOOK @ $8084D104               # [in "req/[ftDataProvider]/ft_data_provider.o" @ $8084C368, Ghidra: $8085B090]
{
    rlwinm r0, r0, 0, 26, 27
    cmpwi r0, 0x10
}
op bne- 0xC @ $8084D108
# Changes trigger condition for Case 5, Etc
HOOK @ $8084D23C               # [in "req/[ftDataProvider]/ft_data_provider.o" @ $8084C368, Ghidra: $8085B1C8]
{
    rlwinm r0, r0, 0, 26, 27
    mr r12, r0                          # Use r12 to smuggle r0 down to $8084D29C HOOK!
    cmpwi r0, 0x10
}
op bne- 0xC @ $8084D240
# Changes trigger condition for Case 7, MotionEtc
HOOK @ $8084D314               # [in "req/[ftDataProvider]/ft_data_provider.o" @ $8084C368, Ghidra: $8085B2A0]
{
    rlwinm r0, r0, 0, 26, 27
    cmpwi r0, 0x10
}
op beq- 0xC @ $8084D318
HOOK @ $8082EF88               # [in "setAiResource/[ftInput]/ft_input.o" @ $8082EEE0]
{
    rlwinm r0, r0, 0, 26, 27
    cmpwi r0, 0x10
}
op bne- 0x28 @ $8082EF8C
# Changes the Etc files that get loaded for costume-specific Etc chars
HOOK @ $8084D29C               # [in "req/[ftDataProvider]/ft_data_provider.o" @ $8084C368, Ghidra: $8085B228]
{
  lis r6, 0x80B0                        # \
  ori r6, r6, 0xA67C                    # / Point r6 to the proper "Etc" string, since the vBrawl location is wrong in PM/P+. Could also lwz 0xA2C(r28)?
  mr r3, r12                            # Pull the LoadFlags we stashed in r12 (see $8084D23C HOOK) into r3...
  cmplwi r3, 0x00                       # ... and compare against 0x00!
  beq+ NormalBehavior                   # If neither bit is set, then we don't care about the costume or Alt, use NormalBehavior!

  mr r8, r7                             # Otherwise, move ".pac" into r8 to make room for our extra argument...
  andi. r7, r27, 0x7F                   # ... and grab the costume ID (w/o Clear Bit) in r7 for use as our potential number argument.
  %lwd(r4, LocalMemoryAddrLoc)          # Then grab the address for our Local Memory from the Addr Loc.
                                        # For the non-numbered alts, just branch to the relevant section for the requested alt.
  cmplwi r7, AltZID;  beq- SetAltZ      # If we're asking for Z-Alt, branch to that segment.
  cmplwi r7, AltRID;  beq- SetAltR      # If we're asking for R-Alt, branch to that segment.
  
                                        # For the numbered ones though (and regular costumes, since they're also numbered)...
  cmplwi r7, NumAltIDsStart             # ... compare the costume ID with the start of the num alt ID range...
  blt+ notNumAlt                        # ... and if we're below it, then we definitely aren't asking for an alt, so skip!
  subi r7, r7, NumAltIDsStart           # If we *are* though, setup our Alt Number in r7 by subtracting back out the the start of our number range!
  addi r6, r4, EtcAltStrLocalMemOff     # Additionally, point r6 to the "EtcAlt" string in our local memory!
notNumAlt:
  mr r12, r7                            # ... and also copy it into r12, cuz for the binning math we'll need an unmodified copy of the number!
  cmplwi r3, 0x20                       # If only the 0x20 bit of the LoadFlags is set, then every costume gets its own Etc file...
  beq+ perCostume                       # ... so we'll skip this process for binning things into sets!

perCostumeSet:                          # This section bins sets down to the nearest 10 (except the first set, that one's 20 long).
moduloFunction:
  cmpwi r7, 10; blt- modulo_10
  subi r7, r7, 10
  b moduloFunction
modulo_10:
  sub r7, r12, r7
  cmpwi r7, 10; bne notFirstSet
  subi r7, r7, 10                       # First twenty costumes use the same Etc file if a set!
notFirstSet:

perCostume:
  %sqAdvCheck()                         # Check if we're in SSE...
  bne+ cr7, notSSE                      # ... and if we aren't, skip the Dark and Fake checks!
  cmpwi r7, 12; beq SetDark             # Otherwise, if we're in SSE, do the necessary checks...
  cmpwi r7, 13; beq SetFake             # ... and branch to the appropriate sections.
notSSE:                                 # Note: Dark and Fake don't trigger if using sets. That's by design.
  addi r4, r4, NumAltFmtStrLocalMemOff  # Lastly, set up the formatting string for numbered Etc files...
  b %END%                               # ... then exit!

NormalBehavior:
  addi r4, r29, 0xAC0; b %END%          # If we're using normal behavior, we just want the normal format string, apply that and exit.
SetDark:
  addi r7, r17, 0x10; b stringEtcName   # For Dark, point r7 to the Dark string and branch!
SetFake:
  addi r7, r17, 0x18; b stringEtcName   # Same for Fake, point r7 to the Fake string and branch!
SetAltZ:
  addi r7, r4, AltZStrLocalMemOff       # For AltZ, point to the custom string in Local Storage...
  b stringEtcName                       # ... and branch.
SetAltR:
  addi r7, r4, AltRStrLocalMemOff       # And for AltR point to custom string, but we don't need to branch cuz we're already at stringEtcName.
stringEtcName:
  addi r4, r4, StrAltFmtStrLocalMemOff  # Lastly, set up the format string for string alts, and we're done!
}
op NOP @ $8084D2A4              # Prevent overwriting r4 after the above HOOK so we keep the desired formatting string!



