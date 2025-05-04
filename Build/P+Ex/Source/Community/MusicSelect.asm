##################################################
Select music for match on SSS v2 [Squidgy, mawwwk]
# updated to support StageEx
# button no longer affects pages/random/back
##################################################
# Press a custom button while hovering over a stage to open the My Music screen
# Press the custom button to select the song and automatically start the match
# Press A to preview songs, or B to back out

# --CONTROL OPTIONS--
# Button to open song select
# button values : 21 (X), 20 (Y), 19 (Start/+)
.alias button = 20
# Button to select a song in song select
# selectButton values : 21 (X), 20 (Y), 23 (Start/+)
# .alias selectButton = 23 - THIS IS NOW CONTROLLED IN THE MODULE
# Recommended to use the same button for opening song select and picking a song, 
# but note that some buttons (such as Start) use a different number for each

# --CUSTOM ADDRESSES USED--
# 80002810 - we use this address for a flag that tells us what step we are on
# 80002818 - we use this address for the selected song ID
# 8000281C - we use this address for selected stage index
# 80002820 - we use this address for selected stage type
# 80002824 - we use this address for SSS page
# 80002828 - we use this address to store the current mode
# 80002830 - port 1 hidden alt
# 80002834 - port 2 hidden alt
# 80002838 - port 3 hidden alt
# 8000283C - port 4 hidden alt

# --FLAG STATES--
# 1 - going to My Music, 2 - My Music opened, 3 - song chosen, 4 - backing out of My Music, 
# 5 - returning from My Music, 6 - back to SSS, 7 - highlight chosen stage/select stage

# macro to store selected hidden alt so it can load when picking songs
.macro storeHiddenAlt(<baseAddress>,<storeAddress>)
{
    lis r4, 0x9018                  # \ base address for port hidden alt status
    ori r4, r4, <baseAddress>       # /

    lis r10, 0x0004                 # \ offset to hidden alt status
    ori r10, r10, 0x3AD8            # |
    lwzx r4, r10 (r4)               # / store the status in r4

    lis r9, 0x8000                  # \ address where we WILL store port hidden alt
    ori r9, r9, <storeAddress>      # /

    stw r4, 0 (r9)                  # store status in our store location
}

# macro to retrieve any selected hidden alts
.macro retrieveHiddenAlt(<baseAddress>,<storeAddress>)
{
    lis r9, 0x8000                  # \ address where hidden alt is stored
    ori r9, r9, <storeAddress>      # |
    lwz r9, 0 (r9)                  # /

    lis r8, 0x9018                  # \ base address for port hidden alt status
    ori r8, r8, <baseAddress>       # /

    lis r10, 0x0004                 # \ offset to hidden alt status
    ori r10, r10, 0x3AD8            # |
    add r8, r10, r8                 # / final address

    stw r9, 0 (r8)                  # store hidden alt status
}

# macro to get the scene manager address
.macro getSceneManager()
{
    lis r12, 0x8002     # \ call getInstance/[gfSceneManager]
    ori r12, r12 0xd018 # |
    mtctr r12           # |
    bctrl               # / scene manager address placed in r3
}

# macro to reset all stored values
.macro cleanup(<valueRegister>,<addressRegister>)
{
    li <valueRegister>, 0                           # \ reset all stored values to 0
    stw <valueRegister>, 0 (<addressRegister>)      # |
    stw <valueRegister>, 0x8 (<addressRegister>)    # |
    stw <valueRegister>, 0xC (<addressRegister>)    # |
    stw <valueRegister>, 0x10 (<addressRegister>)   # |
    stw <valueRegister>, 0x14 (<addressRegister>)   # |
    stw <valueRegister>, 0x18 (<addressRegister>)   # |
    stw <valueRegister>, 0x20 (<addressRegister>)   # |
    stw <valueRegister>, 0x24 (<addressRegister>)   # |
    stw <valueRegister>, 0x28 (<addressRegister>)   # |
    stw <valueRegister>, 0x2C (<addressRegister>)   # /
}

# this hook makes our button work on SSS
HOOK @ $806b5864 # hook where we check if A is being pressed on SSS
{
    # check to ensure this only works in regular VS mode
    mr r9, r3   # store r3

    %getSceneManager()   # \ get scene manager
    mr r10, r3           # | place scene manager into r10
    lwz r3, 0x10 (r10)   # | load currentSequence (10th offset from scene manager) into r3
    lwz r3, 0 (r3)       # / load address of currentSequence name into r3

    lis r4, 0x8070      # \ load address of string "sqVsMelee" into r4
    ori r4, r4, 0x17E0  # /

    lis r12, 0x803f         # \ call strcmp
    ori r12, r12, 0xa3fc    # |
    mtctr r12               # |
    bctrl                   # /

    cmpwi r3, 0         # \ if strings match, proceed
    beq versus          # / proceed

    lwz r3, 0x10 (r10)   # \ load currentSequence (10th offset from scene manager) into r3
    lwz r3, 0 (r3)      # / load address of currentSequence name into r3

    lis r4, 0x8070      # \ load address of string "sqSpMelee" into r4
    ori r4, r4, 0x17F8  # /

    lis r12, 0x803f         # \ call strcmp
    ori r12, r12, 0xa3fc    # |
    mtctr r12               # |
    bctrl                   # /

    cmpwi r3, 0         # \ if strings match, continue
    beq special         # / proceed

    lwz r3, 0x10 (r10)   # \ load currentSequence (10th offset from scene manager) into r3
    lwz r3, 0 (r3)      # / load address of currentSequence name into r3

    lis r4, 0x8070      # \ load address of string "sqTraining" into r4
    ori r4, r4, 0x1870  # /

    lis r12, 0x803f         # \ call strcmp
    ori r12, r12, 0xa3fc    # |
    mtctr r12               # |
    bctrl                   # /

    cmpwi r3, 0         # \ if strings don't match, skip
    beq training        # | proceed
    mr r3, r9           # | restore r3
    bne skip            # / skip

    versus:
    li r10, 1
    b continue

    special:
    li r10, 3
    b continue

    training:
    li r10, 12

    continue:
    mr r3, r9           # \ store r3
    %getSceneManager()  # | get scene manager
    mr r8, r3           # | store scene manager in r8
    mr r3, r9           # | restore r3
    lwz r8, 0x0280 (r8) # |check we are on Main Menu sequence
    cmpwi r8, 1         # |
    beq skip            # / if we are, skip

    # Check ID of selected stage icon
    lwz r9, 0x244 (r27)         # r27 is muSelectStageTask, offset 0x244 is selected stage icon
	cmpwi r9, 0x35; beq skip	# Page button
	cmpwi r9, 0x36;	beq skip	# Random button
	cmpwi r9, 0x37; beq skip	# Back button
    # Check index of selected stage
    lwz r9, 0x248 (r27)                 # \ r27 is muSelectStageTask, offset 0x248 is selected stage index
    cmpwi r9, 0; bge buttonPressed      # / if stage index is -1, check if stage alt list is dispalyed
    # If index is -1, check if we are on stage alt list
    lwz r9, 0x228 (r27)                 # \ offset 0x228 is current page
    cmpwi r9, 2; blt skip               # / if we aren't viewing stage alt list (page 2 aka Stage Builder), skip

    buttonPressed:
    rlwinm. r0, r3, 0, button, button # if button is being pressed, treat that as a valid stage select button
    bne goToMyMusic

    skip:
    rlwinm. r0, r3, 0, 23, 23 # original line
    b %end%

    goToMyMusic:
    lis r9, 0x8000     # \
    ori r9, r9, 0x2810 # |
    li r4, 1           # |
    stw r4, 0 (r9)     # / if we pressed the button, set the flag indicating to go to My Music

    #li r4, 1            # \ set the mode we will jump to from My Music - 1 is VS, 2 is tourney, 3 is special versus
    stw r10, 0x18 (r9)   # / right now is always 1, this could be expanded to work with other modes
}

# additional hook to ensure button works on CSS (prevents a crash with MMU enabled)
HOOK @ $806b5780
{
    # check to ensure this only works in regular VS mode
    mr r9, r3   # store r3

    %getSceneManager()  # \ get scene manager
    mr r10, r3          # | place scene manager in r3
    lwz r3, 0x10 (r10)   # | load currentSequence (10th offset from scene manager) into r3
    lwz r3, 0 (r3)      # / load address of currentSequence name into r3

    lis r4, 0x8070      # \ load address of string "sqVsMelee" into r4
    ori r4, r4, 0x17E0  # /

    lis r12, 0x803f         # \ call strcmp
    ori r12, r12, 0xa3fc    # |
    mtctr r12               # |
    bctrl                   # /

    cmpwi r3, 0         # \ if strings match, continue
    mr r3, r9           # | restore r3
    beq continue        # / proceed

    lwz r3, 0x10 (r10)   # \ load currentSequence (10th offset from scene manager) into r3
    lwz r3, 0 (r3)      # / load address of currentSequence name into r3

    lis r4, 0x8070      # \ load address of string "sqSpMelee" into r4
    ori r4, r4, 0x17F8  # /

    lis r12, 0x803f         # \ call strcmp
    ori r12, r12, 0xa3fc    # |
    mtctr r12               # |
    bctrl                   # /

    cmpwi r3, 0         # \ if strings match, continue
    beq continue        # / proceed

    lwz r3, 0x10 (r10)   # \ load currentSequence (10th offset from scene manager) into r3
    lwz r3, 0 (r3)       # / load address of currentSequence name into r3

    lis r4, 0x8070      # \ load address of string "sqTraining" into r4
    ori r4, r4, 0x1870  # /

    lis r12, 0x803f         # \ call strcmp
    ori r12, r12, 0xa3fc    # |
    mtctr r12               # |
    bctrl                   # /

    cmpwi r3, 0         # \ if strings don't match, skip
    beq continue        # | continue
    mr r3, r9           # | restore r3
    bne skip            # / skip

    continue:
    mr r3, r9           # \ store r3
    %getSceneManager()  # | get scene manager
    mr r8, r3           # | store scene manager in r8
    mr r3, r9           # | restore r3
    lwz r8, 0x0280 (r8) # |check we are on Main Menu sequence
    cmpwi r8, 1         # |
    beq skip            # / if we are, skip

    # Check ID of selected stage icon
    lwz r9, 0x244 (r27)         # r27 is muSelectStageTask, offset 0x244 is selected stage icon
	cmpwi r9, 0x35; beq skip	# Page button
	cmpwi r9, 0x36;	beq skip	# Random button
	cmpwi r9, 0x37; beq skip	# Back button
    # Check index of selected stage
    lwz r9, 0x248 (r27)                 # \ r27 is muSelectStageTask, offset 0x248 is selected stage index
    cmpwi r9, 0; bge buttonPressed      # / if stage index is -1, check if stage alt list is dispalyed
    # If index is -1, check if we are on stage alt list
    lwz r9, 0x228 (r27)                 # \ offset 0x228 is current page
    cmpwi r9, 2; blt skip               # / if we aren't viewing stage alt list (page 2 aka Stage Builder), skip

    buttonPressed:
    rlwinm. r0, r3, 0, button, button # if button is being pressed, treat that as a valid stage select button
    bne %end%

    skip:
    rlwinm. r0, r3, 0, 23, 23 # original line
    b %end%
}

# additional hook to ensure button works on CSS (prevents a crash with MMU enabled)
HOOK @ $806b589c
{
    # check to ensure this only works in regular VS mode
    mr r9, r3   # store r3

    %getSceneManager()  # \ get scene manager
    mr r10, r3          # | place scene manager in r3
    lwz r3, 0x10 (r10)   # | load currentSequence (10th offset from scene manager) into r3
    lwz r3, 0 (r3)      # / load address of currentSequence name into r3

    lis r4, 0x8070      # \ load address of string "sqVsMelee" into r4
    ori r4, r4, 0x17E0  # /

    lis r12, 0x803f         # \ call strcmp
    ori r12, r12, 0xa3fc    # |
    mtctr r12               # |
    bctrl                   # /

    cmpwi r3, 0         # \ if strings match, continue
    mr r3, r9           # | restore r3
    beq continue        # / proceed

    lwz r3, 0x10 (r10)   # \ load currentSequence (10th offset from scene manager) into r3
    lwz r3, 0 (r3)      # / load address of currentSequence name into r3

    lis r4, 0x8070      # \ load address of string "sqSpMelee" into r4
    ori r4, r4, 0x17F8  # /

    lis r12, 0x803f         # \ call strcmp
    ori r12, r12, 0xa3fc    # |
    mtctr r12               # |
    bctrl                   # /

    cmpwi r3, 0         # \ if strings match, continue
    beq continue        # / proceed

    lwz r3, 0x10 (r10)   # \ load currentSequence (10th offset from scene manager) into r3
    lwz r3, 0 (r3)       # / load address of currentSequence name into r3

    lis r4, 0x8070      # \ load address of string "sqTraining" into r4
    ori r4, r4, 0x1870  # /

    lis r12, 0x803f         # \ call strcmp
    ori r12, r12, 0xa3fc    # |
    mtctr r12               # |
    bctrl                   # /

    cmpwi r3, 0         # \ if strings don't match, skip
    beq continue        # | continue
    mr r3, r9           # | restore r3
    bne skip            # / skip

    continue:
    mr r3, r9           # \ store r3
    %getSceneManager()  # | get scene manager
    mr r8, r3           # | store scene manager in r8
    mr r3, r9           # | restore r3
    lwz r8, 0x0280 (r8) # |check we are on Main Menu sequence
    cmpwi r8, 1         # |
    beq skip            # / if we are, skip

    # Check ID of selected stage icon
    lwz r9, 0x244 (r27)         # r27 is muSelectStageTask, offset 0x244 is selected stage icon
	cmpwi r9, 0x35; beq skip	# Page button
	cmpwi r9, 0x36;	beq skip	# Random button
	cmpwi r9, 0x37; beq skip	# Back button
    # Check index of selected stage
    lwz r9, 0x248 (r27)                 # \ r27 is muSelectStageTask, offset 0x248 is selected stage index
    cmpwi r9, 0; bge buttonPressed      # / if stage index is -1, check if stage alt list is dispalyed
    # If index is -1, check if we are on stage alt list
    lwz r9, 0x228 (r27)                 # \ offset 0x228 is current page
    cmpwi r9, 2; blt skip               # / if we aren't viewing stage alt list (page 2 aka Stage Builder), skip

    buttonPressed:
    rlwinm. r0, r3, 0, button, button # if button is being pressed, treat that as a valid stage select button
    bne %end%

    skip:
    rlwinm. r0, r3, 0, 23, 23 # original line
    b %end%
}

# this hook makes it so that turn order is kept intact when stage selection option is set to taking turns
HOOK @ $80055584 # gmSetRuleSelStage - when we set which player is in control
{
    lis r8, 0x8000     # \
    ori r8, r8, 0x2810 # |
    lwz r8, 0 (r8)     # | get flag
    cmpwi r8, 7        # | if flag is 7 (coming from My Music), skip changing which player is in control
    beq %end%          # /

    stb r7, 0 (r5) # original line, sets which player is in control
}

# this hook stores the stage index if we open the alt stage submenu
HOOK @ $806b59e8 # muSelectStageTask:buttonProc - when we set the stage index to -1
{
    lis r3, 0x8000          # \ get address
    ori r3, r3, 0x2810      # /

    lwz r8, 0x248 (r29)     # \ offset 248 is stage index
    stw r8, 0xC (r3)        # / store stage index

    done:
    stw r0, 0x0248 (r29) # original code, sets stage index
}

# this hook stores stage info before we go to My Music
HOOK @ $806c905c # muSelectStageTask:process - when we set info for selected stage
{
    lis r8, 0x8000     # \
    ori r8, r8, 0x2810 # |
    lwz r7, 0 (r8)     # | get flag
    cmpwi r7, 1        # | if flag is not 1 (going to My Music), skip to end
    bne done           # /

    lwz r7, 0x248 (r5)  # \ r5 is muSelectStageTask, offset 248 is stage index
    cmpwi r7, -1        # | if stage index is -1, skip storing it
    beq setType         # |
    stw r7, 0xC (r8)    # / store stage index

    setType:
    lwz r7, 0x254 (r5)    # \ offset 254 is stage type
    stw r7, 0x10 (r8)     # / store stage type

    lis r7, 0x8049	    # \
    ori r7, r7, 0x6000	# | address where the SSS page is
    lbz r7, 0 (r7)	    # |
    stb r7, 0x14 (r8)	# / store current page

    done:
    stw r0, 0x0288 (r3) # original line
}

# macro for the code that sends us to My Music
.macro goToMyMusic(<register>,<case>,<stageSelectCase>)
{
    lwz r0, 0x0008 (<register>) # original code

    cmpwi r0, <stageSelectCase> # if we are not changing stages, check if we're returning from My Music
    bne %end%

    %getSceneManager()  # \ get scene manager
    lwz r9, 0x0284 (r3) # | offset 284 from scene manager stores stage builder/regular stage
    cmpwi r9, 3         # | 3 means stage builder, 1 means regular
    bne flagCheck       # / if it's not a stage builder stage, go to flag check
    
    lis r9, 0x8000      # \
    ori r9, r9, 0x2810  # / get stored values

    %cleanup(r7,r9)     # reset all stored values to 0
    b %end%             # go to end

    flagCheck:
    lis r9, 0x8000     # \
    ori r9, r9, 0x2810 # |
    lwz r4, 0 (r9)     # | get flag
    cmpwi r4, 1        # | if flag isn't 1 (going to My Music), jump to end
    bne %end%          # /

    # store hidden alts if any were selected
    %storeHiddenAlt(0x0b40, 0x2830)
    %storeHiddenAlt(0x0b9C, 0x2834)
    %storeHiddenAlt(0x0bf8, 0x2838)
    %storeHiddenAlt(0x0c54, 0x283C)

    # if we're on SSS and flag is 1, go to main menu
    li r0, <case> # set switch/case to pick main menu option
}

# this hook makes it so our button sends us to My Music instead of starting the match - VS
HOOK @ $806dcb50 # hook for transitioning to a match
{
    %goToMyMusic(r15, 0x10, 0x7)
}

# this hook makes it so our button sends us to My Music instead of starting the match - Special
HOOK @ $806deaac # hook for transitioning to a match
{
    %goToMyMusic(r30, 0x10, 0x7)
}

# this hook makes it so our button sends us to My Music instead of starting the match - Training
HOOK @ $806f1574 # hook for transitioning to a match
{
    %goToMyMusic(r15, 0xb, 0x6)
}

# this hook makes it so we get warped to My Music instead of just the main menu
HOOK @ $806cc050 # The instruction for when we go to main menu
{
    lis r8, 0x8000      # \
    ori r8, r8, 0x2810  # |
    lwz r8, 0 (r8)      # | get flag
    cmpwi r8, 1         # | if flag isn't 1 (going to My Music), just run original code
    bne done            # /

    li r3, 12 # otherwise, force it to go to My Music
    
    done:
    cmpwi r5, 0 # original code
}

# this hook makes it so that the icons, thumbnails, and other elements don't display when we go to My Music
HOOK @ $806b10d0 # when we call dispPage in muSelectStageTask:initProcWithScreen
{
    lis r4, 0x8000      # \
    ori r4, r4, 0x2810  # |
    lwz r4, 0 (r4)      # | get flag
    cmpwi r4, 1         # | if flag isn't 1 (going to My Music), just run original code
    bne done            # /

    lis r12, 0x806b     # jump to address after dispPage call
    ori r12, r12 0x10dc
    mtctr r12
    bctr

    done:
    lwz r4, 0x0228 (r26) # original code
}

# THESE HOOKS HAVE BEEN MOVED TO THE sora_menu_main.rel
# # this hook makes the tracklist open and hides elements when we go to My Music
# HOOK @ $8117de68 # My Music function that runs every frame
# {
#     lis r4, 0x8000      # \
#     ori r4, r4, 0x2810  # |
#     lwz r4, 0 (r4)      # | get flag
#     cmpwi r4, 1         # |
#     bne done            # / if flag isn't 1, just do original code
	
#     mr r9, r3

#     %getSceneManager()      # \ get scene manager
#     lis r4, 0x806A          # |
#     ori r4, r4 0xDBE4       # | store address of string "muMenuMain" in r4
#     lis r12, 0x8002         # | call searchScene
#     ori r12, r12, 0xd3f4    # |
#     mtctr r12               # |
#     bctrl                   # | r3 is now muMenuMain
#     lwz r8, 0x38c (r3)      # | offset 0x38c of muMenuMain is muProcOptSong
#     lwz r8, 0x694 (r8)      # / offset 0x694 of muProcOptSong is muSelectStageTask

#     lwz r3, 0x0050 (r8)   # \ hides cursor
#     lwz r4, 0x0200 (r8)   # |
#     lwz r12, 0 (r3)       # |
#     lwz r4, 0x0010 (r4)   # |
#     lwz r12, 0x003C (r12) # |
#     mtctr r12             # |
#     bctrl                 # /

#     lwz r3, 0x0214 (r8)    # \ hides highlights around the SSS icon
#     lwz r4, 0x0204 (r8)    # |
#     lwz r12, 0 (r3)        # |
#     lwz r4, 0x0010 (r4)    # |
#     lwz r12, 0x003C (r12)  # |
#     mtctr r12              # |
#     bctrl                  # /

#     lis r3, 0x0000
#     ori r3, r3, 0x0003
#     stw r3, 0x0224 (r8) # flip the flag to disable cursor

#     lis r3, 0x0000
#     ori r3, r3, 0x0001
#     stw r3, 0x0274 (r8) # flip flag to open track list

#     lis r3, 0x8000     # \
#     ori r3, r3, 0x2810 # |
#     li r4, 2           # |
#     stw r4, 0 (r3)     # / set our flag to 2, meaning My Music is opened

#     mr r3, r9 # restore r3

#     done:
#     lwz r0, 0x0664 (r3) # original code
# }

# # this hook forces My Music to open the correct tracklist
# HOOK @ $8117defc # manipulate this instruction so that the correct track list is displayed
# {
#     lis r9, 0x8000      # \
#     ori r9, r9, 0x2810  # |
#     lwz r7, 0 (r9)      # | get flag
#     cmpwi r7, 2         # |
#     bne done            # / if flag isn't 2 (on My Music from SSS)

#     lis r7, 0x805a      # \ load the chosen stage ID instead of a default
#     lwz r7, 0xE0 (r7)   # | 0x805a00e0 - GameGlobal
#     lwz r7, 0x14 (r7)   # | offset 0x14 - gmSelStageData
#     lhz r7, 0x22 (r7)   # | offset 0x22 - stage ID
    
#     b %end%

#     done:
#     li r7, 66 # original line
# }

# # this hook makes our button work on the track list
# HOOK @ $8117f030 # when checking what button is pressed with tracklist open
# {
#     lis r4, 0x8000      # \
#     ori r4, r4, 0x2810  # |
#     lwz r7, 0 (r4)      # | get flag
#     cmpwi r7, 2         # |
#     bne done            # / if flag isn't 2 (on My Music from SSS)

#     rlwinm. r0, r29, 0, selectButton, selectButton # if button is being pressed, treat that as a valid select button
#     bne buttonPressed

#     done:
#     rlwinm. r0, r29, 0, 22, 22 # otherwise, just do original code
#     b %end%

#     buttonPressed:
#     li r7, 3
#     stw r7, 0 (r4) # set flag to 3
#     cmpwi r0, 1 # force the check to fail, so it counts as pressing A
# }

# # this hook stores the chosen song ID when we choose a song
# HOOK @ $8117f07c # when playing a song on my music
# {
#     li r6, 1 # original line

#     lis r8, 0x8000     # \
#     ori r8, r8, 0x2810 # |
#     lwz r7, 0 (r8)     # | get flag
#     cmpwi r7, 3        # |
#     bne %end%          # / if flag isn't 3, skip

#     li r7, 4
#     stw r7, 0 (r8) # set flag to 4, meaning we are returning to SSS

#     lis r8, 0x8000     # \ storing song ID for stage to use
#     ori r8, r8, 0x2810 # | address where we will store song ID
#     stw r30, 0x8 (r8)  # / set stored song ID to the one we are playing - r30 stores current song ID at this point
# }

# # this hook is to make it so pressing our button will keep the song playing even if it is already playing
# HOOK @ $8117f03c # when checking if a song is already playing on My Music when we hit A
# {
#     lis r8, 0x8000      # \
#     ori r8, r8, 0x2810  # |
#     lwz r7, 0 (r8)      # | get flag
#     cmpwi r7, 3         # |
#     bne done            # / if flag isn't 3, skip
#     li r0, 0 # force to count as not playing

#     done:
#     cmpwi r0, 0 # original code
# }

# # this hook is to ensure that pressing our button will trigger the song selection
# HOOK @ $8117f060 # another when we press A on track list
# {
#     lis r8, 0x8000      # \
#     ori r8, r8, 0x2810  # |
#     lwz r7, 0 (r8)      # | get flag
#     cmpwi r7, 3         # |
#     bne done            # / if flag isn't 3, skip
#     li r0, 0 # force to count as not playing

#     done:
#     cmplw r30, r0 # original line
# }

# # this hook is so that when we back out, we'll return to SSS
# HOOK @ $8117e670 # exit/[muProcOptSong] (when exiting My Music)
# {
#     lis r8, 0x8000     		# \
#     ori r8, r8, 0x2810 		# |
#     lwz r7, 0 (r8)     		# | get flag
#     cmpwi r7, 4        		# |
#     bne done			    # / if flag isn't 4, skip

#     li r7, 5
#     stw r7, 0 (r8) 		# set flag to 5, returning from My Music

#     # Old scene change code, no longer used, could be useful reference
#     #lis r9, 0x805b		    # \ tell scene manager to change scenes to vs
#     #ori r9, r9, 0x5030		# | load scene manager into r9
#     #li r10, 0x0		    # |
#     #stb r10, 0x002C (r9)	# |
#     #stb r10, 0x002D (r9)	# |
#     #stb r10, 0x002E (r9)	# |
#     #stb r10, 0x002F (r9) 	# | set some flags that need to be 0
#     #lis r9, 0x805b		    # | 
#     #ori r9, r9, 0x8ba0		# | load scene manager into r9
#     #li r10, 0x1		    # |
#     #stw r10, 0x0284 (r9) 	# | this flag determines what screen we go to from main - 0x1 is VS
#     #li r10, 0x2		    # |
#     #stw r10, 0x0288 (r9) 	# / set flag used by scene manager to 2, triggering scene change

#     mr r10, r3              # \ change scenes - store r3 first
#     %getSceneManager()      # | get scene manager
#     mr r9, r3               # | put scene manager in r9
#     mr r3, r10              # | restore r3
#     lwz r9, 0x4 (r9)        # | this offset gives us the flag to determine what scene to change to
#     lwz r10, 0x18 (r8)      # | load the scene number we stored - right now is always 0x1
#     stw r10, 0x0AB0 (r9)    # /

#     done:
#     mr r31, r3 			# original line
# }

# # this hook is to force the tracklist to close when an option is chosen
# HOOK @ $8117e4b0 # check if B is pressed when My Music tracklist is open
# {
#     lis r9, 0x8000      # \
#     ori r9, r9, 0x2810  # |
#     lwz r8, 0 (r9)      # | get flag
#     cmpwi r8, 4         # |
#     bne done            # / if flag isn't 4, skip

#     li r0, 0x20 # count as we are pressing B
#     cmpwi r0, 0
#     b %end%

#     done:
#     rlwinm. r0, r3, 0, 26, 26 # original line
# }

# # this hook is to ensure we back all the way out to SSS when B is pressed, and to play the correct sound based on the button pressed
# HOOK @ $8117e4e4 # when setting the sound ID for the button pressed while My Music tracklist is open
# {
#     li r4, 2            # original line, sets sound ID to backing out sound

#     lis r9, 0x8000      # \
#     ori r9, r9, 0x2810  # |
#     lwz r8, 0 (r9)      # | get flag
#     cmpwi r8, 2         # |
#     bne nextCheck       # / if flag isn't 2 (pressed B), check if it's 4

#     li r8, 4
#     stw r8, 0 (r9)      # | set flag to 4

#     # clear ASL input
#     lis r8, 0x800C
#     li r9, 0
#     sth r9, -0x615E (r8)

#     # This fixes an issue where looking at the songs for a stage alt would force that alt to load when the stage was selected
#     li r9, 0            # \
#     lis r8, 0x8053      # |
#     ori r8, r8, 0xe000  # | this address stores the chosen stage ID, which is used to determine if we should reload or not
#     sth r9, 0x0FB8 (r8) # / by setting it to 0, the game will see no stage as loaded, and reload the file

#     b %end%

#     nextCheck:
#     cmpwi r8, 4     # \
#     bne %end%       # | if flag isn't 4 (pressed custom button), skip
#     li r4, 1        # / otherwise, set sound ID to confirmation sound (we selected a song instead of backing out)
# }
# END REL HOOKS

# this hook makes sure we go back to SSS from My Music
HOOK @ $806b5670 # check if B is pressed on My Music screen
{
    lis r9, 0x8000      # \
    ori r9, r9, 0x2810  # |
    lwz r9, 0 (r9)      # | get flag
    cmpwi r9, 4         # |
    bne done            # / if flag isn't 4, just do original code

    # this snippet makes it so we pause the frames while we return to SSS
    lis r3, 0x805A      # \ get gfApplication
    lwz r3, -0x54 (r3)  # | gfApplication stored in r3
    addi r3, r3, 0xD0   # | gfApplication + 0xD0 = gfKeepFrameBuffer stored in r3
    lis r12, 0x8002     # | call startKeepFrameBuffer (mislabled in symbol map)
    ori r12, r12 0x4e20 # |
    mtctr r12           # |
    bctrl               # /

    li r0, 0x200 # count as we are pressing B
    cmpwi r0, 0
    b %end%

    done:
    rlwinm. r0, r0, 0, 22, 22 # original line
}

# this hook makes it so the cursor doesn't display for a split second when backing out of My Music
HOOK @ $806b4290 # where we restore the cursor in selectingProc/[muSelectStageTask]
{
    lwz r3, 0x0050 (r27) # original line

    lis r4, 0x8000      # \
    ori r4, r4, 0x2810  # |
    lwz r4, 0 (r4)      # | get flag
    cmpwi r4, 4         # |
    bne %end%           # / if flag is not 4, just do original code

    lis r12, 0x806b     # jump to address after Insert call
    ori r12, r12, 0x42b0
    mtctr r12
    bctr
}

# these hooks make it so we don't play a second backing out sound when we back out from music selection
HOOK @ $806b567c # loading sound ID in buttonProc:muSelectStageTask (for My Music)
{
    li r4, 2            # original lines

    lis r9, 0x8000      # \
    ori r9, r9, 0x2810  # |
    lwz r9, 0 (r9)      # | get flag
    cmpwi r9, 4         # | check that flag is 4
    bne %end%           # / if not, end

    lis r12, 0x806b     # jump to address after playSE call
    ori r12, r12 0x5698
    mtctr r12
    bctr
}

# same as above, but for process:muMenuMain
HOOK @ $806cea08
{
    li r4, 2            # original lines

    lis r9, 0x8000      # \
    ori r9, r9, 0x2810  # |
    lwz r9, 0 (r9)      # | get flag
    cmpwi r9, 4         # | check that flag is 4
    bne %end%           # / if not, end

    lis r12, 0x806c     # jump to address after playSE call
    ori r12, r12 0xea24
    mtctr r12
    bctr
}

# this hook makes it so we play a normal confirmation sound instead of the stage select sound when opening the music select
HOOK @ $806b5cec # loading sound ID in buttonProc:muSelectStageTask (for SSS)
{
    li r4, 19 # original line

    lis r9, 0x8000      # \
    ori r9, r9, 0x2810  # |
    lwz r9, 0 (r9)      # | get flag
    cmpwi r9, 1         # | check that flag is 1
    bne %end%           # / if not, end

    # this snippet makes it so we pause the frames while we go to My Music, so that the "Ready to Fight" text doesn't display
    mr r9, r3
    lis r3, 0x805A      # \ get gfApplication
    lwz r3, -0x54 (r3)  # | gfApplication stored in r3
    addi r3, r3, 0xD0   # | gfApplication + 0xD0 = gfKeepFrameBuffer stored in r3
    lis r12, 0x8002     # | call startKeepScreen (mislabeled in symbol map)
    ori r12, r12 0x4e20 # |
    mtctr r12           # |
    bctrl               # /
    mr r3, r9

    li r4, 1 # play normal confirm sound instead
}

# this hook makes it so we play a normal confirmation sound instead of the stage select sound when opening the music select from ASL sub menu
HOOK @ $806b5e5c # loading sound ID in buttonProc:muSelectStageTask (for SSS from ASL sub menu)
{
    li r4, 19 # original line

    lis r9, 0x8000      # \
    ori r9, r9, 0x2810  # |
    lwz r9, 0 (r9)      # | get flag
    cmpwi r9, 1         # | check that flag is 1
    bne %end%           # / if not, end

    # this snippet makes it so we pause the frames while we go to My Music, so that the "Ready to Fight" text doesn't display
    mr r9, r3
    mr r8, r0
    lis r3, 0x805A      # \ get gfApplication
    lwz r3, -0x54 (r3)  # | gfApplication stored in r3
    addi r3, r3, 0xD0   # | gfApplication + 0xD0 = gfKeepFrameBuffer stored in r3
    lis r12, 0x8002     # | call startKeepScreen (mislabeled in symbol map)
    ori r12, r12 0x4e20 # |
    mtctr r12           # |
    bctrl               # /
    mr r3, r9
    mr r0, r8

    li r4, 1 # play normal confirm sound instead
}

# this hook makes it so we play the stage select sound when a song is selected
HOOK @ $806b53a0 # muSelectStageTask:randomProc - loading audience cheer sound
{
    lis r9, 0x8000      # \
    ori r9, r9, 0x2810  # |
    lwz r9, 0 (r9)      # | get flag
    cmpwi r9, 7         # | check that flag is 7
    bne done            # / if not, end

    lwz r3, 0x01D0 (r31)    # \ set parameters for playSE
    li r4, 19               # | 19 is ID for stage select sound
    li r5, -1               # |
    li r6, 0                # |
    li r7, 0                # |
    li r8, -1               # |
    lis r12, 0x8007         # | call playSE
    ori r12, r12, 0x42B0    # |
    mtctr r12               # |
    bctrl                   # /

    lis r9, 0x8000          # \
    ori r9, r9, 0x2810      # |
    li r3, 0                # |
    stw r3, 0x0 (r9)        # / set flag to 0 - we are done

    done:
    lwz r3, 0x01D0 (r31) # original line
}

# this hook makes it so we don't play the audience cheer when opening the music select
HOOK @ $806b46bc # loading sound ID in selectingProc:muSelectStageTask (for SSS)
{
    li r4, 22 # original line

    lis r9, 0x8000      # \
    ori r9, r9, 0x2810  # |
    lwz r9, 0 (r9)      # | get flag
    cmpwi r9, 1         # | check that flag is 1
    bne %end%           # / if not, end

    lis r12, 0x806b     # jump to address after playSE call
    ori r12, r12, 0x46d4
    mtctr r12
    bctr
}

# this hook makes it so we don't play the audience cheer when opening the music select from ASL sub menu
HOOK @ $806b550c # loading sound ID in selectingProc:muSelectStageTask (for SSS with ASL sub menu)
{
    li r4, 22 # original line

    lis r9, 0x8000      # \
    ori r9, r9, 0x2810  # |
    lwz r9, 0 (r9)      # | get flag
    cmpwi r9, 1         # | check that flag is 1
    bne %end%           # / if not, end

    lis r12, 0x806b     # jump to address after playSE call
    ori r12, r12, 0x5524
    mtctr r12
    bctr
}

# macro for the code that sends us to My Music
.macro returnFromMyMusic(<register1>,<register2>)
{
    lis r5, 0x8000      # \
    ori r5, r5, 0x2810  # |
    lwz r10, 0 (r5)     # | get flag
    cmpwi r10, 5        # | if flag isn't 5 (returning from My Music), jump to end
    bne done            # /

    # otherwise, load SSS
    li <register1>, 0x5

    li r10, 6           # \
    stw r10, 0 (r5)     # / set our flag to 6

    mr r10, r3              # \ store r3
    %getSceneManager()      # | get scene manager
    mr r5, r3               # | put scene manager in r5
    mr r3, r10              # | restore r3
    li r10, 1               # | set flag to 1
    stw r10, 0x0284 (r5)    # / setting this flag to 1 will make it go to SSS

    done:
    stw <register1>, 0xc (<register2>) # original line
}

# this hook makes it so we go to SSS after backing out from My Music - VS
HOOK @ $806dcbc8 # when transitioning to VS, we set this to tell the game to go to SSS after mem change
{
    %returnFromMyMusic(r24, r15)
}

# this hook makes it so we go to SSS after backing out from My Music - Special
HOOK @ $806deb64 # when transitioning to Special, we set this to tell the game to go to SSS after mem change
{
    %returnFromMyMusic(r21, r30)
}

# this hook makes it so we go to SSS after backing out from My Music - Training
HOOK @ $806f15ac # when transitioning to Training, we set this to tell the game to go to SSS after mem change
{
    %returnFromMyMusic(r29, r15)
}

# this hook is used to ensure addresses correctly indicate we're on SSS after returning from My Music
HOOK @ $806be64c # runs every frame on process/[scMemoryChange]
{
    lis r5, 0x8000      # \
    ori r5, r5, 0x2810  # |
    lwz r10, 0 (r5)     # | get flag
    cmpwi r10, 6        # | if flag isn't 6, go to end
    bne done            # /

    li r10, 7           # \
    stw r10, 0 (r5)     # / set our flag to 7 - set pages

    li r0, 1            # this flag indicates what screen we're on after this, 1 in this case means SSS
    b %end%

    done:
    li r0, 0 # original line
}

# this hook checks if we are changing pages, and if so, doesn't set the flag to go to music select
HOOK @ $806b58d0 # just after checking if we are changing pages
{
    lis r5, 0x8000      # \
    ori r5, r5, 0x2810  # |
    lwz r10, 0 (r5)
    cmpwi r10, 1        # if flag is not 1, go to end
    bne done

    li r10, 0           # \
    stw r10, 0 (r5)     # / set our flag to 0 - we changed pages, didn't select a stage

    done:
    lis r3, 0x806C # original line
}

# this hook forces the song ID to be the one we selected
HOOK @ $8010f9e4 # hook just before calling setBgmId when loading stage
{
    lis r10, 0x8000         # \
    ori r10, r10, 0x2810    # |
    lwz r7, 0x8 (r10)       # | get song ID
    cmpwi r7, 0             # |
    beq done                # / if stored song ID is set to 0, jump to original line

    mr r6, r7               # set r6 (param4 for setBgmId) to song ID, which will force it to be picked
    li r7, 0
    stw r7, 0x8 (r10)       # set stored song ID to 0

    done:
    mr r4, r28 # original line
}

# this hook forces the match to start when returning from My Music and also retrieves hidden alts
HOOK @ $806b42d4 # muSelectStageTask:selectingProc - when we check if a button is pressed
{
    lis r8, 0x8000          # \
    ori r8, r8, 0x2810      # |
    lwz r9, 0x0 (r8)        # | get flag
    cmpwi r9, 7             # |
    bne done                # / if flag is not 7, jump to original line

    # Retrieve hidden alts
    %retrieveHiddenAlt(0x0b40, 0x2830)
    %retrieveHiddenAlt(0x0b9C, 0x2834)
    %retrieveHiddenAlt(0x0bf8, 0x2838)
    %retrieveHiddenAlt(0x0c54, 0x283C)

    li r3, 3    # setting to 3 forces us to random

    done:
    cmpwi r3, 2 # original line
}

# this hook forces random to pick our stage if returning from My Music
HOOK @ $806b4bd8 # muSelectStageTask:selectingProc - after we set all IDs for random
{
    lis r5, 0x8000          # \
    ori r5, r5, 0x2810      # |
    lwz r4, 0x0 (r5)        # | get flag
    cmpwi r4, 7             # |
    bne done                # / if flag is not 7, jump to original line

    lis r4, 0x805a          # \ load the chosen stage ID instead of a default
    lwz r4, 0xE0 (r4)       # | 0x805a00e0 - GameGlobal
    lwz r4, 0x14 (r4)       # | offset 0x14 - gmSelStageData
    lhz r4, 0x22 (r4)       # | offset 0x22 - stage ID
    stw r4, 0x0258 (r27)    # / r27 is muSelectStageTask, offset 258 is selectedId

    lwz r4, 0x10 (r5)
    stw r4, 0x0254 (r27)    # offset 254 is selectedType

    lbz r3, 0x14 (r5)
    lis r4, 0x8049          # \ Store page number for P+ stage system
    ori r4, r4, 0x6000      # |
    stb r3, 0 (r4)          # /

    cmpwi r3, 0x2           # \ if page is >= 2, set it to 0, to prevent issues with P+ stage system
    blt setPage             # |
    li r3, 0x0              # |
    setPage:                # |
    stw r3, 0x6154 (r27)    # / offset 6154 is page in vBrawl

    setIndex:
    lwz r4, 0xC (r5)
    stw r4, 0x6158 (r27)    # offset 6158 is index

    mr r10, r0              # store r0
    lis r12, 0x806b         # \ call MuStageTblAccess_GetStageKind
    ori r12, r12, 0x8f50    # |
    mtctr r12               # |
    bctrl                   # | stageKind placed in r3
    stw r4, 0x615C (r27)    # / offset 615C is stageKind

    mr r0, r10              # restore r0

    done:
    stw r0, 0x0224 (r27) # original line, sets state
}

# this hook is to make it so that the stage is NOT automatically picked if we back out from My Music
HOOK @ $806b533c # muSelectStageTask:randomProc - when we check muSelectStageTask:setting
{
    lis r3, 0x8000          # \
    ori r3, r3, 0x2810      # |
    lwz r5, 0x0 (r3)        # | get flag
    cmpwi r5, 7             # |
    bne done                # / if flag is not 7, jump to original line

    lwz r5, 0x8 (r3)        # \ get song ID
    cmpwi r5, 0             # |
    bne done                # / if stored song ID is not 0, we chose a song, so continue as normal

    li r5, 0                # \ set muSelectStageTask:setting to 0
    stw r5, 0x40 (r31)      # / offset 0x40 is setting

    li r5, 0                # \ set muSelectStageTask:state to 0 - stage not selected yet
    stw r5, 0x224 (r31)     # / offset 0x224 is state

    li r0, 2                # force r0 for comparison, so we skip the stage selecting code

    done:
    cmpwi r0, 2 # original line
}

# this hook is to make it stages aren't deselected when backing out of My Music after selecting a stage on pages after the first
HOOK @ $806b6000 # muSelectStageTask:buttonProc - immediately after checking for page change
{
    lis r3, 0x8000          # \
    ori r3, r3, 0x2810      # |
    lwz r5, 0x0 (r3)        # | get flag
    cmpwi r5, 7             # |
    bne done                # / if flag is not 7, jump to original line

    lwz r5, 0x250 (r29)     # \ 0x250 is frame count
    cmpwi r5, 12            # |
    blt done                # / only perform code if SSS has been up for 12 frames

    # set cursor position, just so stage gets highlighted even if it was removed by page change
    lwz r5, 0x200 (r29)     # \ 0x200 is cursor pointer
    lfs f4, 0x3C (r5)       # | offset 0x3C is cursor X position
    stfs f4, 0x3C (r5)      # / set cursor X position

    lfs f4, 0x40 (r5)       # \ 0x40 is cursor Y position
    stfs f4, 0x40 (r5)      # / set cursor Y position

    %cleanup(r5,r3)         # reset all stored values to 0

    done:
    mr r3, r31 # original line
}

# this hook resets all of our stored values when we return to the main menu
HOOK @ $806dce4c # hook in sqVsMelee/setNext when we are changing to main menu
{
    lis r5, 0x8000      # \
    ori r5, r5, 0x2810  # |
    lwz r6, 0 (r5)      # |
    cmpwi r6, 1         # | if flag is 1 (going to My Music), jump to end
    beq done            # /

    %cleanup(r7,r5)     # reset all stored values to 0

    done:
    stb	r30, 0x0448 (r3) # original line
}

# fixes the code not working on expansion stages if build doesn't have salty runback fix
op NOP @ $8010F9C0

####################################################
CSS Selections Preserved in Special Versus [Squidgy]
####################################################
op nop @ $806de9e8 # nop so we always enter the if

# needs this so rules settings don't break
HOOK @ $806de9f0 # set all necessary values
{
    stw	r0, 0x0008 (r31) # original line
    stw r0, 0x11 (r31)
}

op nop @ $806de9f4 # nop so we still set up SSS stuff, normally it would skip it when we go in the if

# this sets up the SSS stuff
HOOK @ $806dea1c
{
    stw r3, -0x5B08 (r4) # original line, sets SSS stuff

    lis r12, 0x806d     # jump to address to end function
    ori r12, r12 0xea34
    mtctr r12
    bctr
}

###################################################################
Only Reset Team Setting Upon Entering Training [Squidgy, Kapedani]
###################################################################
.alias g_GameGlobal                         = 0x805a00E0

.macro lwd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lwz     <reg>, temp_Lo(<reg>)
}

CODE @ $806f14d0  # sqTraining::start
{
    %lwd(r12, g_GameGlobal)
    lwz r12, 0x10(r12)
    li r11, 0x0
    stb r11, 0x33(r12)
}