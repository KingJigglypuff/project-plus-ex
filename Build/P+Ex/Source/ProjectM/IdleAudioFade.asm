###################################
Idle Audio Fade v2.05 [InternetExplorer, mawwwk, DukeItOut]
###################################
.macro Word(<reg>, <arg1>)
{
.alias temp_Hi = <arg1> / 0x10000
.alias temp_Lo = <arg1> & 0xFFFF
    lis <reg>, temp_Hi
    ori <reg>, <reg>, temp_Lo
}

.alias InactiveFrames = 7200
float 1.0   @ $805A7404 # Max volume
float 0.25  @ $805A7408 # Min volume
float 0.975 @ $805A740C # Mult. per frame

HOOK @ $801BCE60
{
    lfs f0, 0x80(r29)                       # Original op
    
    lis r12, 0x805B; lwz r12, 0x50AC(r12)   # Check if in replay
    lwz r12, 0x10(r12); lwz r12, 0(r12)     # Skip volume change if so
    %Word(r11, 0x807039D8); cmpw r11, r12   # Compare with "sqReplay"
    beq %END%
    
    %Word(r5, 0x805BAD00)       # Addr for reading controller inputs
    %Word(r12, 0x805A7400)      # Addr storing frames since last input
    lfs f3, 0x0C(r12)           # Volume change per frame
    li r4, 0                    # Initialize port count 
	
    lwz r11, 0x10(r12)          # Check if fade multiplier is 0.0,
    cmpwi r11, 0                # i.e. slider muted from save file load
    bne checkController_Buttons
    
    lis r11, 0x3F80             # \ If fade is 0.0, initialize to 1.0
    stw r11, 0x10(r12)          # /

checkController_Buttons:
    addi r4, r4, 1              # Increment port check count
    lwz r11, 0x204(r5)          # If any button pressed, fail check
    cmpwi r11, 0
    bne inputSent

checkController_X:
    lbz r11, 0x30(r5)           # Check control stick X
    cmpwi r11, 0x20             # If in (32, 224), fail check
    blt checkController_Y
    cmpwi r11, 0xE0
    ble inputSent

checkController_Y:
    lbz r11, 0x31(r5)           # Check control stick Y
    cmpwi r11, 0x20             # If in (32, 224), fail check
    blt loopPorts
    cmpwi r11, 0xE0
    ble inputSent

loopPorts:
    addi r5, r5, 0x40           # Loop to next port address
    cmpwi r4, 8                 # 4 GCC + 4 Wii remote
    blt checkController_Buttons
    lwz r5, 0(r12)              # If no inputs given from any port, 
    addi r5, r5, 1              # increment inactive frame count
    b frameCountCheck

inputSent:
    li r5, 0					# Reset inactive frame count if given input

frameCountCheck:
    lfs f4, 0x10(r12)           # Load previous frame fade multiplier
    cmpwi r5, InactiveFrames    # If no inputs sent in x frames, fade out volume
    bge calcLowerVolume

# r12: address of frame count and multipliers @ $805A7400
# f1: Fade multiplier max       $805A7404
# f2: Fade multiplier min       $805A7408
# f3: Vol change per frame      $805A740C
# f4: Current frame fade mult   $805A7410
# f0: New volume (dynamic loc)
# f0 replaces value used by original op

calcRestoredVolume:
    lfs f1, 0x04(r12)       # Max fade multiplier (1.0)
    fdivs f4, f4, f3        # Divide twice to fade in faster
    fdivs f4, f4, f3
    fcmpu cr0, f4, f1       # Store min(vMax, vNew) in f4
    ble storeVolume
    fmr f4, f1              
    b storeVolume

calcLowerVolume:
    lfs f2, 0x08(r12)       # Min fade multiplier
    fmuls f4, f4, f3
    fcmpu cr0, f4, f2       # Store max(vMin, vNew) in f4
    bge storeVolume
    fmr f4, f2

storeVolume:
    stw r5, 0(r12)          # Store inactive frame count
    fmuls f0, f0, f4        # Update volume used by original op
    stfs f4, 0x10(r12)      # Store fade multiplier
}