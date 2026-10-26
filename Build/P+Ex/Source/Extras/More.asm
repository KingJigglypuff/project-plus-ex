#.include Source/Extras/AiDebug.asm 
# Displays AI debug for CPU in P1 slot. Incompatible with CodeMenu.asm (In RSBE01.txt). One or the other must be ignored with # in front of .include

#.include Source/Extras/AerialForbiddenSDI.asm
# Allows for Melee-style SDI limitations preventing aerial characters from SDI-ing into the ground

#.include Source/Extras/AnimationBlend.asm
# Experimental code which allows for smoother transitions between character animations in certain cases

#.include Source/Extras/ASDImult.asm
# Allows SDI multipliers to ignore ASDI

#.include Source/Extras/AutosaveWiiLight.asm
# Turns on the Wii disc slot light when Autosave Replays is enabled in the code menu

#.include Source/Extras/QuickStart.asm
# Skips countdown for 1P matches, though this desyncs 1P replays 

#.include Source/Extras/ShorthopMacro.asm
# Adds a controller macro to force a short hop if 2 jump buttons are pressed

#.include Source/Extras/UncapDamageRatio.asm
# Allows the damage ratio setting to be anywhere from 0.1 to 9.9

#.include Source/Extras/USBGecko.asm
# Adds support for Gecko codes passed in by a USB Gecko

