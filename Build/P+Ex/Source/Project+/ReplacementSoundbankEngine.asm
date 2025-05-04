#############################################################################################################################################################
[Project+] RSBE v1.40 (/Project+/pf/sfx, can load soundbank clones for stages and items) (requires CSSLE) [InternetExplorer, DukeItOut, QuickLava, Kapedani]
#
# 1.31: The RWSD location check is now independent of Sound Resource size.
# 1.31a: SAWNDs Can Now Overwrite vBrawl's Header/Data Lengths (Requires FilePatchCodeSawndHeader.asm)
# 1.32: Allow SSE stages and items to have soundbank clones 
# 1.33: Allow common sawnds to have soundbank clones
# 1.34: Don't try to load override sawnds if override is empty
# 1.40: Merged in Header/Data Length Patching Logic, SAWNDs now load via SD Stream (FilePatchCodeSawndHeader.asm no longer required)
#############################################################################################################################################################
.alias sprintf                      = 0x803F89FC
.alias strcat                       = 0x803FA384
.alias itoa                         = 0x803fcb50
.alias SDStreamOpen                 = 0x805a7500
.alias SDStreamRead                 = 0x805a7700
.alias SDStreamClose                = 0x805a7650
.alias g_GameGlobal                 = 0x805a00E0
.alias g_itKindPkmSoundGroups       = 0x80ADBD18
.alias CustomSDLoadRoutine          = 0x805A7900
.alias STEX                         = 0x8053F000
.alias ITM_OVERRIDE_STR_ADDR        = 0x80B518F8 
.alias PKM_OVERRIDE_STR_ADDR        = 0x80B51908
.alias STAGE_ITEM_STR_ADDR          = 0x80B5198A
.alias SND_OVERRIDE_STR_ADDR        = 0x80B524E8
.alias CustomBankOff_Hi             = 0x000E
.alias CustomBankOff_Lo             = 0x3C6C
string[2] "/Project+/pf/sfx/%03X",".sawnd" @ $805A7D18
.alias sfxFolderStringAddr          = 0x805A7D24  # Points to the "/sfx" part 0xC chars into the above string.
.alias SawndStreamSlotID            = 0x10
.alias SawndStreamStatusBufferAddr  = 0x805A7D40
* 80000000 80406920
* 80000001 805A7D18
address $805A7D18 @ $805A7D00
* 045A7D10 919B6600		# What is this? Writes default address of MenuResource Heap when in muMenuMain layout to 0x805A7D10

.macro lwd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lwz     <reg>, temp_Lo(<reg>)
}
.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
}
.macro call(<addr>)
{
  %lwi(r12, <addr>)
  mtctr r12
  bctrl    
}

# Dynamically builds target .sawnd filepath, if File found, opens Sawnd Stream and prepares Stream Status Buffer for following Hook!
HOOK @ $801C81B8	# [in "LoadGroup/[nw4r3snd6detail18SoundArchiveLoaderFUlPQ34nw]/" @ $801C8180]
{
  li r6, 512			# Restore Original Instruction
  stwu r1, -0x80(r1)
  stmw r3, 8(r1)
  lis r3, 0x805A
  ori r3, r3, 0x7000
  stwu r1, 8(r3)		# place r1 in 805A7008
  mr r1, r3
  
  li r29, 0x00          # r29 denotes whether or not we're allowed to try the fallback name!
  
  lwz r28, 0x18(r31)    # \
  lwz r28, 0x04(r28)    # |
  lwz r28, 0x28(r28)    # / Put Pointer to RSAR INFO Section (After Magic + Size) in r28

  %lwi(r27, SawndStreamStatusBufferAddr) # Setup Address to Sawnd Stream Peek/Status Array in r27!
  
  addi r26, r26, 0x07   # Add 7 to the incoming Soundbank Info Index to get its ID...
  
  cmplwi r26, 0x014b                 # \
  blt- skipIDPatch                   # | Check if this is a custom soundbank, cuz if so...
  addis r3, r28, CustomBankOff_Hi    # | ... we need to patch its ID in.
  stw r26, CustomBankOff_Lo(r3)      # / Store custom ID in the Reserved Custom Bank Group entry (offset 0xE3C6C)
skipIDPatch:

  lis r3, 0x805A
  ori r3, r3, 0x7D00
  stw r26, -0x20(r3)	# place r26 in 805A7CE0 after adding 7 to it. This will be the soundbank.
  addi r3, r1, 0x24		#\
  stw r3, 8(r1)			#/ Point r3 to our string buffer, and store its address on the stack! Will be our filepath when we're done!

setupComplete: 
  li r4, 0x0
  stw r4, 0x88(r1)  # zero item variant

  stw r4, 0xC(r1)		             # zero 805A700C, 805A7010 and 805A7018
  stw r4, 0x10(r1)		             #\
  stw r4, 0x18(r1)		             #/
  li r4, 0xFFFF			             #\-1 at 805A701C
  stw r4, 0x1C(r1)		             #/
  %lwi(r4, sfxFolderStringAddr)      # Point r4 to the main formatting string!
  subi r5, r26, 7                    # Put the soundbank Info Index into r5, in preparation to be sprintf'd
  %call (sprintf)                    # Sprintf!
                                     # [r1 + 0x24] is now "/sfx/[INFO_INDEX]"!

  cmpwi r26, 0x007    # \                                                                # Summary for the branching by ID done here:
  beq- altBank        # |                                                                # 0x000, 0x027, 0x0D5 - 0x0D8 are the Common Banks, go to altBank
  cmpwi r26, 0x02E    # |                                                                # 0x0D9 - 0x143 are SSE Banks, go to altBank
  beq- altBank        # | Check if common soundbank (000, 027, 0D5 - 0D8)                #    0x0D9 is Common, 0x0DA - 0x115 are Stages, 0x11D - 0x143 are Enemies/Bosses
  cmpwi r26, 0x0DC    # |                                                                # 0x04C - 0x0AF are "Stage Banks", also go to altBank
  blt+ notCommonBank  # |                                                                #    0x04C - 0x070 are Stages, 0x071 - 0x075 are Minigames, 0x076 - 0x092 are Items
  cmpwi r26, 0x0DF    # |                                                                # Everything else goes straight to NormalBank!
  ble+ altBank        # /                                                                # Note: All above numbers refer to Info Indices, Same as .sawnd file names!

notCommonBank:
  cmpwi r26, 0xE0
  blt+ notSubspaceBank
  cmpwi r26, 0x14A
  ble+ altBank

notSubspaceBank:
  cmpwi r26, 0x53            #\ Skip if not a normal stage soundbank
  blt+ concatSawndFiletype   # |
  cmpwi r26, 0xB6            # | Stage soundbanks are range 0x53-0xB6 (really 0x4C-0xAF)
  bgt+ concatSawndFiletype   #/
  
altBank:
  li r29, 0x1           # Enable the fallback name, for in case the file with our alternate path can't be found!
  lis r5, 0x5F00		# \ Load "_" into r5...
  stw r5, 0x20(r1)		# | ... and store it in preparation to strcat!
  addi r4, r1, 0x20		# | Point r4 to the "_" string,
  addi r3, r1, 0x24		# | Point r3 to the main string
  %call (strcat)        # / Strcat!
  addi r3, r1, 0x24     # Point r3 to newly concat'd string, should now be "/sfx/[INFO_INDEX]_"
  
  %lwi (r12, STEX)
  lwz r4, 0x1C(r12)		# Pointer to offset in string block for filename
  lwz r5, 0x4(r12)		# Pointer to string block
  add r4, r4, r12		# \ Obtain address for string of stage filename
  add r4, r4, r5		# /

  %lwd (r11, g_GameGlobal)    # \
  lwz r10, 0x8(r11)           # | 
  lhz r10, 0x1A(r10)          # |
  cmpwi r10, 0x3d             # | Check if gmGlobalModeMelee->meleeInitData.stageKind is SSE
  bne+ notSubspace            # /
  lwz r9, 0x30(r11)          # \ &advSaveData->lastJumpBone[20] 
  addi r4, r9, 1604          # /
  cmpwi r26, 0x0E0        # \ Check if SSE common bank
  beq+ pkmOverride        # /
  b notAssistOverride
notSubspace:
  cmpwi r26, 0x07E        # \
  blt+ notAssistOverride  # | 
  beq- pkmOverride        # | Check if Pokemon/Assist range
  cmpwi r26, 0x099        # |
  ble+ assistOverride     # /
  cmpwi r26, 0x0E1        # \
  blt+ notAssistOverride  # | Check if Subspace stage range (during Vs mode)
  cmpwi r26, 0x11C        # |
  ble+ assistOverride     # /
  b pkmOverride
assistOverride:  
  %lwi (r10, g_itKindPkmSoundGroups)
  subi r7, r26, 7
  li r12, 316
loopCheckForVariant:
  addi r9, r12, 2   # \
  lhzx r8, r10, r9  # |
  cmpw r7, r8       # | Check for desired sawnd associated with Assist/Pokemon
  bne+ notSfxGroup  # /
  lhzx r8, r10, r12 # \ Get variant and store
  stw r8, 0x88(r1)  # /
  cmplwi r8, 0x8000               # \
  blt- pkmOverride                # | use stage item str address if Pokemon variant >= 0x1000
  %lwi (r4, STAGE_ITEM_STR_ADDR)  # /
  b notAssistOverride     # break
notSfxGroup:                # \
  subi r12, r12, 4          # | Loop through itKindSndGroupIds for Pokemon/Assists
  cmpwi r12, 0x0            # |
  bge+ loopCheckForVariant  # /
pkmOverride:
  %lwi (r4, PKM_OVERRIDE_STR_ADDR)
notAssistOverride:
  cmpwi r26, 0x07D
  bne+ notItmOverride
  %lwi (r4, ITM_OVERRIDE_STR_ADDR)
notItmOverride:
  cmpwi r26, 0x007        # \
  beq- commonOverride     # |
  cmpwi r26, 0x02E        # |
  beq- commonOverride     # | Check if common soundbank (000, 027, 0D5 - 0D8)
  cmpwi r26, 0x0DC        # |
  blt+ notCommonOverride  # |
  cmpwi r26, 0x0DF        # |
  bgt- notCommonOverride  # /
commonOverride:
  %lwi (r4, SND_OVERRIDE_STR_ADDR)
notCommonOverride:
  lbz r12, 0x0(r4)     # \
  cmpwi r12, 0x0       # | Check if empty string
  beq+ fallbackName    # /
  bctrl				   # strcat again
  
  lwz r11, 0x88(r1)          # \
  cmpwi r11, 0x0             # | check if variant > 0
  beq+ concatSawndFiletype   # /
  addi r3, r1, 0x24          # \
  addi r4, r1, 0x20          # | concat '_'
  bctrl                      # /
  lwz r3, 0x88(r1)           # \
  addi r4, r1, 0x8c          # | turn variant into string
  li r5, 10                  # |
  %call (itoa)               # /
  addi r3, r1, 0x24          # \
  addi r4, r1, 0x8c          # | concat variant string
  %call (strcat)             # /
  b concatSawndFiletype

fallbackName:
  li r29, 0                          # Unset the fallback bit to signal we've already tried the non-alternate name!
  addi r3, r1, 0x24		             # Point r3 to our string buffer!
  %lwi(r4, sfxFolderStringAddr)      # Point r4 to the main formatting string!
  subi r5, r26, 7                    # Put the soundbank Info Index into r5, in preparation to be sprintf'd
  %call (sprintf)                    # Sprintf!
                                     # [r1 + 0x24] is now "/sfx/[INFO_INDEX]"!
  lwz r11, 0x88(r1)         # \
  cmpwi r11, 0x0            # | Check if variant > 0 ...
  beq+ concatSawndFiletype  # / ... and if not, then skip trying to apply its suffix!
                            # Otherwise though, if a variant *is* specified...
  addi r3, r1, 0x24         # \ Point r3 back to our string buffer again,
  addi r4, r1, 0x20         # | and point r4 back to the "_" we concat'd earlier.
  %call (strcat)            # / Strcat!
  lwz r3, 0x88(r1)          # \ Put variant ID into r3,
  addi r4, r1, 0x8c         # | point r4 to just after that ID (this'll be our variant ID string),
  li r5, 10                 # | and in base 10...
  %call (itoa)              # / ... convert our variant ID into a string!
  addi r3, r1, 0x24         # \ Then point r3 to our string buffer one more time,
  addi r4, r1, 0x8c         # | point r4 to our variant ID string...
  %call (strcat)            # / ... and strcat.
                            # At this point, [r1 + 0x24] is now "/sfx/[INFO_INDEX]_[VARIANT_ID]"!
  
concatSawndFiletype:
  addi r3, r1, 0x24		# Point r3 to our string buffer.
  lis r4, 0x805A        # \
  ori r4, r4, 0x7D2E	# / Point r4 to the ".sawnd " string...
  %call (strcat)        # ... and strcat!
                        # At this point, our filepath should be fully built!

tryOpenStream:
  addi r3, r1, 0x24     # Put built filepath string addr in r3
  li r4, SawndStreamSlotID   # Set Target Stream 
  %call (SDStreamOpen)
  cmpwi r3, 0x00             # Check if we successfully opened the stream.
  bne streamOpened           #
                             # If it failed to load:
  cmplwi r29, 0x1            # Check if the fallback flag is set.
  beq- fallbackName          # If it is, trigger the fallback attempt!
                             # If we *aren't* allowed a fallback though, we simply fail.
  stw r3, 0x00(r27)          # \
  stw r3, 0x04(r27)          # |
  stw r3, 0x08(r27)          # |
  stw r3, 0x0C(r27)          # / Zero Out Status array
  addi r3, r3, -0x01         # Set r3 to 0xFFFFFFFF...
  sth r3, 0x00(r27)          # ... and store as the Group ID in Status Array to 0xFFFF to signal the fail!
  b noSawnd
  
streamOpened:
  sth r26, 0x00(r27)    # Store Group ID in Status Array
  lwz r3, 0x08(r3)      # \
  lwz r3, 0x264(r3)     # / Get Length of file.
  stw r3, 0x0C(r27)     # Store File Length in Status Array
  mr r3, r4             # Move Slot ID into r3
  addi r4, r27, 0x04    # Point r4 to 0x04 bytes into Status Array, this is where we'll load our 0x08 peek
  li r5, 0x08           # Set r5 to peek length
  li r6, 0x01           # Set r6 to peek start offset (0x01, to skip Sawnd Ver. #)
  %call (SDStreamRead)  # Read our peek into the Working Area

						# Beginning of Sawnd Header Len Calc
						# Header Len =     1  (Sawnd Version Num)
						#                + 4  (Group)
						#                + 4  (Data Length)
						# + (Num Files * 0xC) (Length of Trips)
  lwz r4, 0x24(r28)     # Get offset of Groups Section Ref Vector in r5,
  add r4, r28, r4       # add it to INFO Section Address to point to Group Section Ref Vector
						# At this point, we have address of group vec in r4

  subi r8, r26, 0x7		# Get Group Info ID					
  cmplwi r8, 0x0144		# Check if this is a custom soundbank,
  blt- notCustomBank
  addis r3, r28, CustomBankOff_Hi    # \ if it is, get pointer to Reserved Custom Bank Group entry
  addi r3, r3, CustomBankOff_Lo      # / (INFO Section Address + 0xE3C6C)
  b sawndHeaderLenCalc
notCustomBank:
  mulli r8, r8, 0x8			# Multiply Info ID by 8 to index into vec
  add r3, r4, r8			# \ Add this offset to r4 (start of off vec)...
  lwz r3, 0x8(r3)			# / ... then load from 0x08 past that to get the offset to the Group Obj
  add r3, r28, r3			# Add that offset to start of INFO Section to get Group Obj addr
							# At this point, r3 is Group obj addr
sawndHeaderLenCalc:

  stw r3, 0x04(r27)         # Store the Group Obj's address in the Status Array
  lwz r7, 0x28(r3)			# Get number of files in group
  mulli r7, r7, 0xC			# Multiply file count by length of file triplet
  addi r7, r7, 0x09			# Add 0x09 to account for Tag, Group ID, and Data Len
                            # At this point, r7 is now Sawnd Header length!
  sth r7, 0x2(r27)          # Store Sawnd Header length in Status Array, Array setup complete!
  lwz r8, 0xC(r27)          # Retrieve Total Sawnd File Size
  sub r8, r8, r7            # Subtract Sawnd Header Length from File Size
  lwz r7, 0x8(r27)			# Grab Sawnd Data Length
  sub r8, r8, r7            # Subtract Sawnd Data Length from File Size
                            # At this point, r8 is Group Header Len, r7 is Data Len!
							
  lwz r11, 0x10(r3)			# Get stored header address from group header
  stw r8, 0x14(r3)			# Store calculated header length in group header
  add r11, r11, r8          # Add calc'd header length to header addr to get data addr
  stw r11, 0x18(r3)         # Store updated Data Addr in group header
  stw r7, 0x1C(r3)          # Store updated data length in group header

noSawnd:
  lis r1, 0x805A		# \
  ori r1, r1, 0x7000	#  | Retrieve old registers 
  lwz r1, 8(r1)			#  |
  lmw r3, 8(r1)			#  |
  addi r1, r1, 0x80		# /
}

# Checks Stream Status Buffer, and if previous hook opened its Sawnd successfully, patches the new info into the BRSAR!
HOOK @ $801C8370	# [in "LoadGroup/[nw4r3snd6detail18SoundArchiveLoaderFUlPQ34nw]/" @ $801C8180]
{
  stwu r1, -0x80(r1)
  stmw r3, 8(r1)
  lis r3, 0x805A
  ori r3, r3, 0x7000
  stwu r1, 8(r3)		# place r1 in 805A7008
  mr r1, r3
  addi r26, r26, 0x7	# add 7 to the soundbank ID for who knows what reason.
  lis r3, 0x805A
  ori r3, r3, 0x7D00
  stw r26, -0x20(r3)	# place r26 in 805A7CE0 after adding 7 to it. This will be the soundbank.

  %lwi(r28, SawndStreamStatusBufferAddr)
  # lis r28, 0x805A       # \ 
  # ori r28, r28, 0x7D40  # / Setup Address to Sawnd Stream Peek/Status Array in r28! ----------------------------> # $805A7D40 is Buffer for Sawnd Stream Status and Info!
                                                                                                                  # 0x00 is 16-bit Group ID if Stream Loaded, 0xFFFF if not
  lwz r29, 0x18(r31)    # \                                                                                       # 0x02 is 16-bit Sawnd Header Length
  lwz r29, 0x04(r29)    # |                                                                                       # 0x04 is 32-bit INFO Section Group Object Address
  lwz r29, 0x28(r29)    # / Put Pointer to RSAR INFO Section (After Magic + Size) in r29!                         # 0x08 is 32-bit Sawnd Data Length
                                                                                                                  # 0x0C is 32-bit Sawnd File Length
  lhz r4, 0x00(r28)          # Try to load the last loaded Group ID from the Sawnd Stream Status Array!
  cmplw r4, r26              # See if it matches the .sawnd we're processing right now!
  beq+ streamGood            # If they match, then we can process the rest of the stream.
  
  li r3, 0x1                 # If they don't, we need to set r3 to 1 so we load from BRSAR after this...
  b clearStatusArray         # ... and skip straight to clearing the Status Array.
  
streamGood:                  # But otherwise...
  li r3, SawndStreamSlotID   # Set up our Stream ID
  mr r4, r27                 # Set r4 to our allocation address!
  lwz r5, 0x0C(r28)          # Load .sawnd length into r5
  lhz r6, 0x02(r28)          # Load .sawnd header length into r6, which'll be our offset to read from, and also
  sub r5, r5, r6             # ... subtract the .sawnd header length from the file length actual soundbank length!
  lwz r7, 0x08(r28)          # Load .sawnd data length into r7...
  sub r5, r5, r7             # ... and subtract *that* from soundbank length to get just header length!
  %call (SDStreamRead)       # Read the header portion of the soundbank in our .sawnd into its rightful place in the allocated area!
                             # We're going to come back and read the rest of the data in after we finish patching the BRSAR!
							 # But first, read in the full .sawnd header, since we need its information for our patching.
  li r3, SawndStreamSlotID   # Set r3 to our Stream ID
  add r4, r27, r5            # Set our destination to just after the soundbank header we just read in
  addi r5, r6, -0x1          # Set our read length to the .sawnd header length - 1 (to skip the version byte)
  li r6, 0x01                # Set our offset to 0x01 to skip the version byte and read in the .sawnd header
  %call (SDStreamRead)       # And read! This reads the .sawnd header to just after the soundbank header we just read!

  lwz r20, 0x04(r28)         # Retrieve Group Header Object Address from Status Array
  lwz r20, 0x24(r20)         # Get offset to Group Entry Vector
  add r20, r29, r20          # Add that offset to the INFO Section address to get address of Group's Entry Ref Vec!

  lwz r21, 0x1C(r29)         # Get File Header Reference Vector Offset from INFO Section
  add r21, r29, r21          # Add offset to INFO Section address to get address of File Header Ref Vec!
  addi r21, r21, 0x8         # And add 0x8 to that, to point to the first offset in the list (for lwzx'ing later).

  addi r22, r4, -0x4         # Point r22 to 0xC before first set of File Triplets in .sawnd header!
  
                             # Beginning of patching loop!
  lwz r3, 0x00(r20)          # Load number of Files to patch into r3...
  mtctr r3                   # ... and put it into CTR, to manage how many loop iterations we do.
  li r7, 0x00                # Set up Header Length Accumulator
  li r8, 0x00                # Set up Data Length Accumulator
  
patchingLoopHead:
  lwzu r3, 0x08(r20)         # Push r20 to current Group Entry offset, and load its value!
  add r3, r29, r3            # Add that offset to the INFO Section address to get Group Entry address.
  
  lwzu r5, 0x0C(r22)         # Push r22 to current set of File Info Triplets, and load File ID!

  rlwinm r4, r5, 3, 0, 28    # Multiply the ID by 8, for use in indexing into the File ID list.
  lwzx r4, r21, r4           # Load the offset to this File's Offset...
  add r4, r29, r4            # ... and add it to the INFO section address to get the File Header's address!

  add r6, r27, r7            # Get address for current File in .sawnd.
  lwz r6, 0x08(r6)           # Load new File Header length from .sawnd.

  stw r5, 0x00(r3)           # Store the new File ID in the Group Entry
  lwz r5, 0x08(r22)          # Load File Data length from .sawnd
  stw r7, 0x04(r3)           # Store the accumulated Header Offset in the Group Entry
  stw r6, 0x08(r3)           # Store new File Header Length in the Group Entry
  stw r8, 0x0C(r3)           # Store the accumulated Data Offset in the Group Entry
  stw r5, 0x10(r3)           # Store new File Data Length in the Group entry

  stw r6, 0x00(r4)           # Store new File Header Length in File Header
  stw r5, 0x04(r4)           # Store new File Data Length in File Header

  add r7, r7, r6             # Add new File Header Length to Header Length Accumulator
  add r8, r8, r5             # Add new File Data Length to Data Length Accumulator

bdnz+ patchingLoopHead

  lwz r3, 0x04(r28)          # Get Group Header Address from Status Array
  lwz r4, 0x14(r3)           # Get final Group Header Length...
  add r4, r27, r4            # ... and add it to the .sawnd destination, to get read destination for Group Data section.
  lwz r5, 0x1C(r3)           # Get final Group Data Length, this'll be our read length.
  lwz r6, 0x0C(r28)          # Get full .sawnd Length again...
  sub r6, r6, r5             # ... and subtract Data Length from it, to get read offset (pointing to .sawnd Data Section)
  li r3, SawndStreamSlotID   # Set r3 to our Sawnd Stream slot!
  %call (SDStreamRead)       # And read the Data Section of the .sawnd into the rest of the allocated space!
  
  li r3, SawndStreamSlotID   # Finally, set r3 to our Sawnd Stream slot...
  %call (SDStreamClose)      # ... close the stream...
  li r3, 0x00                # ... and set r3 to 0 to ensure we skip loading from the BRSAR as we leave!
  
clearStatusArray:
  li r12, 0x00
  stw r12, 0x00(r28)         # \
  stw r12, 0x04(r28)         # |
  stw r12, 0x08(r28)         # |
  stw r12, 0x0C(r28)         # / Zero Out Status array
  addi r12, r12, -0x01       # Set r12 to 0xFFFFFFFF...
  sth r12, 0x00(r28)         # ... and store as the Group ID in Status Array to signal nothing is open!
  
exit:
  cmpwi r3, 0x0			# if r3 is zero, skip loading later
  lis r5, 0x805A		# \
  ori r5, r5, 0x7D00	# | store soundbank 
  stw r3, -0x10(r5)		# /
  lis r1, 0x805A		# \
  ori r1, r1, 0x7000	#  | Retrieve old registers 
  lwz r1, 8(r1)			#  |
  lmw r3, 8(r1)			#  |
  addi r1, r1, 0x80		# /
  mtctr r12
  beq- skipBRSAR		# see above
  bctrl 				# read from BRSAR
  b %END%
skipBRSAR:
  mr r3, r7
}
HOOK @ $801C8658
{
  lis r16, 0x805A		    #\
  ori r16, r16, 0x7D00		#/load 805A7D00, the hacked area
  lwz r17, -0x10(r16)		#\
  cmpwi r17, 0x0		    #/check if the sawnd is 0. It shouldn't be!
  bne- loc_0x20
  mr r3, r7
  li r25, 0x0
  beq- %END%

loc_0x20:
  bctrl 
  li r18, 0x1
  stw r18, -0x10(r16)
  nop 
}

