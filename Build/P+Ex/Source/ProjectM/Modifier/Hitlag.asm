####################################
Hitlag Modifier [Magus] 
####################################
#	float 0.33333333 @ $80B87AEC # d * float(hitlag modifier)  # Hitlag mult written by code menu so disabled here
	float 3.0 @ $80B87AF0 # Additional frames after d * hitlag multiplier is calculated
op nop @ $80772B78
HOOK @ $80772B90
{
	fmuls f0, f0, f4
	fctiwz f0, f0
}

Article Hitlag Common [Magus]
* 06584210 00000080
* D8020010 D8420018
* 81230060 81090050
* 80E90028 80E70030
* 89840025 1D8C0090
* 7CE76214 3D8080B8
* 618C7AEC C00C0000
* C04C0004 EC010032
* EC00102A C0470038
* EC0000B2 FC00001E
* D8020020 A1820026
* 81280010 7C0C4800
* 40810014 91880010
* 8988001C 618C00C0
* 9988001C C8020010
* C8420018 7D4903A6
* 4E800420 00000000

###########################################
Article Hitlag Overwritten Branch Addresses
###########################################
CODE @ $80584300
{
  lis r10, 0x808E
  ori r10, r10, 0x537C
  b -0xF8
}