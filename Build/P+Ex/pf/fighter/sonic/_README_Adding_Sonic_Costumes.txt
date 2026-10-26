========================================
Guide for Adding Sonic Costumes
========================================

Sonic uses individual Etc files for each costume. These files include a GFX bank, the "ef_sonicX[..]" ARC, that stores textures & models for his runtrail, special move auras, and other color data.

=====================================
Initial steps for new costume slots
=====================================
When adding a new Sonic costume slot, you must duplicate and rename files to match your new costume number.

1. Duplicate an existing SonicEtc file and rename it to match the new costume number.
2. Inside the new SonicEtc file, rename the ef_sonicX[..] ARC to match the new costume number.
3. Rename the following in the EFLS and REFF nodes to match the costume number:
	- PtcSonicAttackAirLwX##
	- PtcSonicSpinTraceX##
	- PtcSonicSpinTraceLX##
	- PtcSonicIdlingX##
	- PtcSonicHomingTraceX##
	- PtcSonicGimmickJumpX##

For custom textures inside the Etc file, follow these color matching rules:
hanm_zanzo00: texture color should match the top of the shoe.
eff_sonic_runtrace: stripes should always match the corresponding costume, and follow this color scheme (from top to bottom):
	Leg, Top of shoe, Middle of shoe, Bottom of shoe

=====================================
Special move auras
=====================================
Sonic's spin trail models, particle effects, and smoke effects (for Jet Set costumes) are stored inside costume Etc files.

Colors of Sonic's spin aura are stored in Model Data nodes inside the ef_sonicX## ARC, listed below:
- Model Data 0: Spin auras used on Neutral & Down specials, controlled via the Shader Color Block colors 0 and 1 in both of its materials.
- Model Data 5: Aura on grounded Side Special, controlled via the LightChannel0 MaterialColor in both of its materials.
- Model Data 6: Spinning aura on aerial Side Special, controlled via the LightChannel0 MaterialColor in both of its materials.
- Model Data 7: Aura around slide kick during Side Special, controlled via the Shader Color Block colors 0 and 1 in both of its materials.

In Jet Set costumes Etc files, the PtcSonicRollSmokeX## REFF Particple entry controls their particle colors. 
Color1Secondary and Color2Secondary control the colors of the smoke. Both should be identical except for the alpha values, which should be 255 and 0 respectively.

Colored orb gfx on Side Special are controlled via CLR0 nodes in FitSonic.pac. Different colors can be assigned to added costumes by editing Sub Routine 0x2E5AC in a PSA editor.

=====================================
Particles
=====================================
Particle effects are controlled by Animations inside of each REFF entry of the Etc file, namely 0 and ALPHA0PRI.
These will need to be edited within a hex editor, and use RRGGBB color formatting in most cases.
The primary color for each is located between 0x00000030-0x00000032 (for RR,GG,BB respectively) and 0x00000040-0x00000042 for the secondary colors.

This is applicable to:
PtcSonicSpinTraceX##
PtcSonicSpinTraceLX##
PtcSonicSpinTraceLZRing
PtcSonicIdlingX##
PtcSonicHomingTraceX##
PtcSonicHomingTraceRing

For PtcSonicSpinTraceLZRing and PtcSonicHomingTraceRing, Color1Primary will need to be set to the hex color you're using as well in order to show properly in-game. Color1Secondary should also be set to a similar color.

For consistent trail colors, reference these values from Sonic's default costume: 

Purple: #400080, #8000FF
Blue: #0000FF, #0020FF, #0040FF, #0060FF
Baby blue: #40C0FF, #80DFFF, #80E0FF

Trails for PtcSonicAttackAirLwX## (Down Air) and SonicGimmickJumpLight (Up Special) use a similar system, but with visibility values between each color value. 

Starting at 0x00000038 in both the "0" and "ALPHA0PRI" animations, they are formatted as RR VS GG VS BB VS. Most times, the VS values should be left as 00.

=====================================
If you have any questions, please feel free to ask in the #modding-discussion channel of the Project+ Discord.
