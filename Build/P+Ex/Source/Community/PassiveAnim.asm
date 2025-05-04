######################################################################################
Force "PassiveAnim" Texture Animations To Play Indefinitely 1.2 [DukeItOut, QuickLava]
######################################################################################
#
# If the SRT animation named "PassiveAnim" exists 
# and was the last animation played, it will continue playing
# and will refuse to update when the CHR animation changes
#
# You can use this to make looping aesthetic animations! This is 
# incompatible with models with texture movement on eyes, however.
# You have to choose between eye movement and this as they both
# involve texture animation.
#
# To make them exclusive to a particular costume for a character,
# make only the desired costume ID range for that character
# play "PassiveAnim" upon loading into the game within a modified
# module. 
#
# In modded modules, this is often set using subaction 3 within 
# the PSA, which is where it will be getting the animation 
# name from normally.
#
# Please, only exploit this code with characters!
#
# 1.1: Fixed oversight related to other code changes
# 1.2: Moved AnimString to an Embed, reworked method for detecting caller function.
######################################################################################
HOOK @ $8072A6FC            # [0x254 bytes into symbol "create/[soAnimObj]/so_anim_obj.o" @ 0x8072A4A8]
{
    bl animNameEmbed        # DATA EMBED (0x10 bytes) 
    word 0x50617373         # \   "Pass...
    word 0x69766541         # | ...iveA...
    word 0x6E696D00         # / ...nim"
    word 0x80720C0C         # LR Value for call to this func from "change/[soMotionModuleImpl]"
animNameEmbed:              
    mflr r4                 # Pull Anim Name Str addr from LR (into r4 so we can use it in the coming func call if this next check passes).
    lwz r11, 0x94(r1)       # Grab this stack frame's LR value to see where this function was called from...
    lwz r12, 0x0C(r4)       # ... along with the expected LR value from the embed space.
    cmplw r11, r12          # If they're not the same...
    bne ActNormal           # ... we didn't come from the right function, exit!
                            # If we came from the *right* one though, we can rely on r27 being field_0xc8 of a soMotionModule and continue!
    mr r3, r28              # Grab Motion Animation BRRES in r3 for func call.
    lis r12, 0x8018         # \
    ori r12, r12, 0xDDF4    # |
    mtctr r12               # | Get pointer to animation "PassiveAnim" if present
    bctrl                   # /
    cmpwi r3, 0             # \ Give up if it doesn't exist.
    beq- ActNormal          # /
                            # Otherwise though, 
    lwz r12, -0x38(r27)     # Grab the soMotionModule's Active Anim Vector addr...
    lwz r12, 0x18(r12)      # ... and get the current initialized SRT0 Anim from there (0x10 for CLR0 if you want to lock that too elsewhere).
    cmpwi r12, 0            # \ Check if it exists!
    beq ActNormal           # /
    lwz r4, 0x2C(r12)       # Get pointer to SRT0 data for looping aesthetic animation
    cmpw r3, r4             # \ if the two addresses don't match in location, it isn't PassiveAnim
    bne+ ActNormal          # / 
            
    lis r12, 0x8072         # \
    ori r12, r12, 0xA770    # |
    mtctr r12               # | skip setting up an SRT0 animation if PassiveAnim is playing!
    bctr                    # /
    
ActNormal:
    mr r3, r28      # Original operation, gets animation name from r30
}
