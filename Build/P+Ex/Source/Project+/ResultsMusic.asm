####################################################
Classic and All-Star Results Music Table [DukeItOut]
####################################################
HOOK @ $806E0980		# Classic Mode
{
	lbz r0, 0x33(r15)	# Get the character ID, original operation
	rlwinm r0, r0, 1, 0, 30	# Multiply by 2
	lis r3, 0x806E		# \ Get pointer to table
	lwz r3, 0x0988(r3)	# /
	lhzx r3, r3, r0		# Get 16-bit value for the song ID
	oris r0, r3, 0xFF00	# For unknown reasons, having FF in the two highest digits is used for verification
}
HOOK @ $806E3650		# All-Star Mode
{
	lbz r0, 0x98(r6)	# Get the character ID
	rlwinm r0, r0, 1, 0, 30	# Multiply by 2
	lis r3, 0x806E		# \ Get pointer to table
	lwz r3, 0x0988(r3)	# /
	lhzx r3, r3, r0		# Get 16-bit value for the song ID
	oris r0, r3, 0xFF00	# For unknown reasons, having FF in the two highest digits is used for verification
}
op b 0x8 @ $806E0984	# Skip operation afterwards since we are using a different load method
	.BA<-ClassicResultsTable
	.BA->$806E0988
	.GOTO->SkipResultsTable
ClassicResultsTable:
	half[128] | # Slots
		0x271A, 0x272D, 0x2739, 0x2748, | # Mario, Donkey Kong, Link, Samus
		0x2748, 0x2750, 0x275A, 0x276E, | # Zero Suit Samus, Yoshi, Kirby, Fox
		0x276F, 0x271C, 0x277A, 0x278F, | # Pikachu, Luigi, Captain Falcon, Ness
		0x281D, 0x271A, 0x273B, 0x273B, | # Bowser, Peach, Zelda, Sheik
		0x27C9, 0x27C9, 0x27C9, 0x280F, | # Ice Climbers, Popo, Nana, Marth
		0x27D4, 0x2765, 0x273F, 0x27A2, | # Mr. Game & Watch, Falco, Ganondorf, Wario
		0x275C, 0x27C0, 0x279F, 0x2796, | # Meta Knight, Pit, Olimar, Lucas
		0x272D, 0x2770, 0x2770, 0x2770, | # Diddy Kong, PT Charizard, Solo Charizard, PT Squirtle
		0x2770, 0x2770, 0x2770, 0x2758, | # Solo Squirtle, PT Ivysaur, Solo Ivysaur, Dedede
		0x2776, 0x278D, 0x27C4, 0x2770, | # Lucario, Ike, ROB, Jigglypuff
		0x273E, 0x2767, 0x27EC, 0x27FE, | # Toon Link, Wolf, Snake, Sonic
		0x281D, 0x27A2, 0x0000, 0x0000, | # Giga Bowser, Wario-Man, Red Alloy, Blue Alloy
		0x0000, 0x0000, 0x2788, 0xF000, | # Yellow Alloy, Green Alloy, Roy ("MarioD"), Mewtwo ("BossPackun")
		0x0000, 0xF001, 0x0000, 0x0000,	| # "Rayquaza", Knuckles ("PorkyStatue"), "Porky", "HeadRobo"
		0x2749, 0x2727, 0x0000, 0x0000, | # Ridley ("Ridley"), Waluigi ("Duon"), "MetaRidley", "Taboo"
		0x0000, 0x0000, 0x0000, 0x0000, | # "MasterHand", "CrazyHand", "None", "FighterEX3F"
		0xF002, 0x0000, 0x0000, 0x0000, | # Dark Samus ("FighterEX40"), "FighterEX41", "FighterEX42", "FighterEX43"
		0x0000, 0x0000, 0x0000, 0x0000, | # "FighterEX44", "FighterEX45", "FighterEX46", "FighterEX47"
		0x0000, 0x0000, 0x0000, 0x0000, | # "FighterEX48", "FighterEX49", "FighterEX4A", "FighterEX4B"
		0x0000, 0x0000, 0x0000, 0x0000, | # "FighterEX4C", "FighterEX4D", "FighterEX4E", "FighterEX4F"
		0x0000, 0x0000, 0x0000, 0x0000, | # "FighterEX50", "FighterEX51", "FighterEX52", "FighterEX53"
		0x0000, 0x0000, 0x0000, 0x0000, | # "FighterEX54", "FighterEX55", "FighterEX56", "FighterEX57"
		0x0000, 0x0000, 0x0000, 0x0000, | # "FighterEX58", "FighterEX59", "FighterEX5A", "FighterEX5B"
		0x0000, 0x0000, 0x0000, 0x0000, | # "FighterEX5C", "FighterEX5D", "FighterEX5E", "FighterEX5F"
		0x0000, 0x0000, 0x0000, 0x0000, | # "FighterEX60", "FighterEX61", "FighterEX62", "FighterEX63"
		0x0000, 0x0000, 0x0000, 0x0000, | # "FighterEX64", "FighterEX65", "FighterEX66", "FighterEX67"
		0x0000, 0x0000, 0x0000, 0x0000, | # "FighterEX68", "FighterEX69", "FighterEX6A", "FighterEX6B"
		0x0000, 0x0000, 0x0000, 0x0000, | # "FighterEX6C", "FighterEX6D", "FighterEX6E", "FighterEX6F"
		0x0000, 0x0000, 0x0000, 0x0000, | # "FighterEX70", "FighterEX71", "FighterEX72", "FighterEX73"
		0x0000, 0x0000, 0x0000, 0x0000, | # "FighterEX74", "FighterEX75", "FighterEX76", "FighterEX77"
		0x0000, 0x0000, 0x0000, 0x0000, | # "FighterEX78", "FighterEX79", "FighterEX7A", "FighterEX7B"
		0x0000, 0x0000, 0x0000, 0x0000, | # "FighterEX7C", "FighterEX7D", "FighterEX7E", "FighterEX7F"
# Original table at $80702418
SkipResultsTable:
	.RESET