========================================
Guide for Adding Ivysaur Costumes
========================================
Ivysaur uses custom motion trails for certain attacks involving her vines, custom gfx depending on leaf color, and custom gfx depending on bulb explosion.
All costumes will default to the colors that the default Ivysaur costume uses.

Sub Actions 0x65, 0x66, and 0x1C2 (all GFX Tab), as well as Sub Routines 0x13B20, 0x14590, 0x14610, 0x1FE9C, and 0x203CC control leaf colors

Sub Action 0x3C (GFX Tab) controls the Flash Light Effect for Nair
Sub Action 0x50 (GFX Tab) controls leaf motion trails
Sub Action 0x5D (GFX Tab) controls Up Smash explosion colors
Sub Action 0x70 (Main Tab) controls the overlay effect color and gfx for landing a pummel on Ivysaur
Sub Action 0x1CF, 0x1D0 (all GFX Tab) controls the Neutral Special overlay effect color
Sub Action 0x1D7 (GFX Tab) controls Up Special glow color

Sub Routine 0x146F8, 0x17690, 0x17EA8 control vine motion trails
Sub Routine 0x226EC controls overlay effect color and sweetspot gfx for landing moves that heal (similar to Sub Action 0x70)
Sub Routine 0x2625C controls Seed Bomb on-hit leaf colors
Sub Routine 0x27EB4 controls Neutral Special bulb colors

Article 0, Sub Action 0 (GFX Tab) controls Side Special leaf effects and motion trail
Article 1, Sub Action 0 (Main Tab) controls Down Special seed model
Article 1, Sub Action 0 (GFX Tab) controls Seed Bomb gfx when it's traveling
Article 1, Sub Action 2 (GFX Tab) controls Seed Bomb gfx when it hits something

Hex Maniac Ivysaur costumes use Darkness on-hit effects for certain hitboxes, located in:
Sub Actions 0x5D, 0x65, and 0x66 (Main Tab)
Article 1, Sub Action 0 (Main Tab)

========================================
If you have any questions, please feel free to ask in the #modding-discussion channel of the Project+ Discord server.
