#######################################
Max Items Spawnable 8 -> 12 [DukeItOut]
#######################################
byte 12 @ $809B1423
byte 12 @ $809B15E7
byte 12 @ $80962237
byte 12 @ $80962263

##############################################################################################
Additional Item Switch Frequency Settings 'VERY HIGH', 'INTENSE', and 'BOMB RAIN' [DukeItOut]
#
#Requires new entries 155-158 in mu_menumain.pac->MenuRule->Misc Data[0]
#Requires adding PAT animation for MenMainSwitch0002_TopN__0
#Requires new texture assets "MenMainSwitch04Per05", "MenMainSwitch04Per06", and 
#	"MenMainSwitch04Per07"
#
# TODO: Add Bomb Rain as a 6th option, place Tagout where Bomb Rain is
###############################################################################################
.BA<-FREQUENCY_TABLE
.BA->$80ADAD5C        # Where the HIGH speed's max speed usually resides
.GOTO->FrequencyCode

FREQUENCY_TABLE:
float[12] |
	1200.0, 1500.0, | # Low
     500.0,  800.0, | # Medium
     300.0,  500.0, | # High
     120.0,  240.0, | # Very High
	 100.0,  160.0, | # Intense 
	  60.0,   80.0  | # Bomb Rain
	  
FrequencyCode:
.RESET
op rlwinm r0, r0, 0, 29, 31 @ $80951E8C # Allows up to 8 item frequency settings instead of 4
byte 6 @ $806AACEB    # Allow three more frequency settings
byte 6 @ $806AB4BF    # Makes the flashing arrows on the menu respond to the additions
byte 0x15 @ $806AAD1F # \ Enable PAT animation changes on the Item Switch object (previously 0x11 for CHR and CLR only)
byte 0x15 @ $806AAC0F # | This is used to allow the Item Switch's text to change as you scroll.
byte 0x15 @ $806AA6FB # /
HOOK @ $806A3F60
{
	lwz r3, 0xC4(r20)	# Get Item Switch graphic object
	addi r4, r31, 504	# Get animation name "MenMainSwitch0002_TopN__0"
	lis r12, 0x800B			# \
	ori r12, r12, 0x4C14	# |
	mtctr r12				# | Set the model to have the texture animation with this name
	bctrl					# /
	lwz r3, 0xC4(r20)	# Original operation
}
HOOK @ $806AAB98
{
	stw r0, 0x674(r3)	# Original operation: Go down one Y column
	lwz r0, 0x670(r3)
	cmpwi r0, 6
	ble+ %END%
	li r0, 6			# Fix X column so that it doesn't try to go too far to the right
	stw r0, 0x670(r3) 
}
HOOK @ $806AAAF0
{
	stw r0, 0x674(r3)	# Original operation: Wrap around to bottom Y column from Item Frequency bar
	lwz r0, 0x670(r3)
	cmpwi r0, 6
	ble+ %END%
	li r0, 6			# Fix X column so it doesn't try to go to the next row by accident
	stw r0, 0x670(r3) 
}
HOOK @ $80952128
{
    lis r12, 0x80AE          # \ Access pointer at 80ADAD5C
    lwz r12, -0x52A4(r12)    # /
    lfsx f2, r12, r29        #
    addi r29, r29, 4         # Access to max of range
    lfsx f0, r12, r29        #
}
HOOK @ $806AB200 # Handles item frequency text
{
    cmpwi r5, 3; ble+ Normal
    addi r5, r5, 75        # Normally in Project M, this message block has 154 entries. 79+76 = 155 to get a new entry #155
Normal:
    addi r5, r5, 76        # Normal position for item frequency description
}
HOOK @ $806AB234 # Handles item frequency description
{
    cmpwi r5, 3; ble+ Normal
    addi r5, r5, 25        # Normally in Project M, this message block has 154 entries when including Stamina's additions. 29+129 = 158
Normal:
    addi r5, r5, 129 # Original operation, gets offset to text index for item frequency description using the item frequency as an offset
}