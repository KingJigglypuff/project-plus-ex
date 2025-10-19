###########################################################################################
Screw Jump Aerial (Action 0xB0) Enters Free-Fall if Entered Upon Being Hit [KingJigglypuff]
###########################################################################################
# For use with the Screw Attack (Melee) item. Opponents enter the Free-fall state (Action 0x10) after being stricken with the item (the action checks if your knockback velocity equals 0, and executes custom coding if it's not). Requires Eon's Pointer Wizardry system.
* 4A000000 8054a880
* 16000000 00000118
* 00000005 21000000
* 00000005 22000010
* 00000000 00000060
* 00000000 00000044
* 00000000 00000040
* 00000000 00000018
* 00000006 00000007
* 00000005 21000000
* 00000000 00000003
* 00000001 00000000
* 00000000 00000010
* 00000006 00000001
* 00000000 0000272D
* 00000000 00000019
* 00000006 00000003
* 00000006 00000007
* 00000005 000003EA
* 00000000 00000000
* 00000005 00000BC8
* 00000001 00000000
* 00000005 11000000
* 00000000 000000B1
* 00000006 00000001
* 00000000 80FC1870
* 00000002 8054a948
* 121A0600 8054a880
* 000A0400 8054a8b0
* 02010200 8054a8d0
* 02000300 8054a8e0
* 02040400 8054a8f8
* 12060200 8054a918
* 000E0000 8054a928
* 02010200 8054a928
* 00070100 8054a938
* 000F0000 00000000
* 00000000 00000000

CODE @ $80FAE46C #ScrewJumpAerial: 0x80F9FC20 + 0xE84C, replaces top command.
{
	word 0x00070100; word 0x8054a940				#(Sub Routine) Param Offset: 0x8054a880
	word 0x00020000; word 0x0						#Nop
}