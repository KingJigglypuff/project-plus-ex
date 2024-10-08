=====================================
Guide for Adding Sonic Costumes
=====================================

Sonic uses individual Etc files for each costume. These files include a GFX bank, the "ef_sonicX[..]" ARC, that stores his runtrail texture/model.

When adding Sonic costume slots, make sure to copy an existing SonicEtc file as well, and rename it to match the costume number.
Inside the SonicEtc file, rename the ef_sonicX[..] ARC to match the new costume number, and make the proper adjustments to the textures inside.

The "zanzo" texture colors should match the top of the shoe color.
eff_sonic_runtrace stripes should always match the corresponding costume, and follow this color scheme (from top to bottom):
1) Leg
2) Top of shoe
3) Middle of shoe
4) Bottom of shoe


=====================================
New steps for Project+ v3.0+
=====================================

Firstly, there are new GFX on side special that have colored orbs follow Sonic. These are located in FitSonic.pac and use clr0 files to adjust their colors.

Sonic's spin trail models, particle effects, and smoke effects (for Jet Set costumes) have been moved to his Etc files! This allows for colored spin trails for each costume.

In addition to renaming the "ef_sonicX[..]" ARC to match your costume slot, you'll need to rename the following in the EFLS and REFF files:

PtcSonicAttackAirLwX##
PtcSonicSpinTraceX##
PtcSonicSpinTraceLX##
PtcSonicIdlingX##
PtcSonicHomingTraceX##
PtcSonicGimmickJumpX##


Old models:

ModelData0 contains one version of his normal spin aura used on Down and neutral specials.
Their colors are controlled by the Shader Color Block colors 0 and 1 when selecting the "spin" and "spin2" materials.

ModelData0 contains the other version of his normal spin aura used on Down and neutral specials.
Their colors are also controlled by the Shader Color Block colors 0 and 1 when selecting the "spin" and "spin2" materials.


New models:

ModelData5 is the aura around Sonic on the grounded version of Side Special.
Its color can be controlled via the LightChannel0 MaterialColor in both of its materials.

ModelData6 is the spinning aura around Sonic in the aerial version of Side Special.
Its color can be controlled via the LightChannel0 MaterialColor in both of its materials.

ModelData7 is the aura around the slide kick that can be performed out of Side Special.
Their appearance is controlled by the Shader Color Block colors 0 and 1 when selecting the "SlideKick Trace" and "SlideLight" materials.


Particle effects are controlled by the "0" and sometimes "ALPHA0PRI" animations inside of each REFF section of the Etc file. 
These will need to be edited within a hex editor, and use RRGGBB color formatting in most cases. 
The primary color for each is located between 0x00000030-0x00000032 (for RR,GG,BB respectively) and 0x00000040-0x00000042 for the secondary colors.


Default Sonic uses these colors, and it is recommended to reference these values if creating your own trail colors.

Dark purple #400080
Close to purple #8000FF

Deeper blue #0000FF
Slightly lighter blue #0020FF
Lighter blue #0040FF
Even lighter blue #0060FF

Near baby blue #40C0FF

Baby blue #80DFFF
Baby blue #80E0FF


The following particles in Sonic's file use this system:

PtcSonicSpinTraceX##
PtcSonicSpinTraceLX##
PtcSonicSpinTraceLZRing
PtcSonicIdlingX##
PtcSonicHomingTraceX##
PtcSonicHomingTraceRing


For "PtcSonicSpinTraceLZRing" and "PtcSonicHomingTraceRing", Color1Primary will need to be set to the hex color you're using as well in order to show properly ingame.
Color1Secondary should also be set to a similar color.


For PtcSonicAttackAirLwX## (down air trails) and SonicGimmickJumpLight (up special trails), these use a similar system, but with visibility values between each color value. 

Starting at 0x00000038 in both the "0" and "ALPHA0PRI" files, they are formatted as RR VS GG VS BB VS. Most times, the VS values should be left as 00.


Finally, for Jet Set costumes, PtcSonicRollSmokeX## controls their particle colors in each Etc file. 
In the Particle entry, Color1Secondary and Color2Secondary control the colors of the smoke, and should both be set to the same color except for the alpha values, which should be 255 and 0 respectively.


If you have any questions, please feel free to ask in the #modding-discussion channel of the Project+ Discord.







