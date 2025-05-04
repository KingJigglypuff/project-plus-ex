################################################
Weapon Data Fix Automatic [ds22, Desi, Kapedani]
################################################
# Modified Kirby Module passes copyAbilityKind in r10 to createArray, which is then passed to getWeaponData

op mr r4, r10 @ $808526F4	# Mario Fireball
op mr r4, r10 @ $80852afc	# Pikachu Thunder Jolt2
op mr r4, r10 @ $80853ff0	# Ness PK Flash
op mr r4, r10 @ $80853c0c	# Popo Ice Shot
op mr r4, r10 @ $80854144	# Koopa Breath
op mr r4, r10 @ $80854298	# Game Watch Sausage
op mr r4, r10 @ $80854404	# Toon Link Bow
op mr r4, r10 @ $80854494	# Toon Link Bow Arrow
op mr r4, r10 @ $808537fc	# Luigi Fireball
op mr r4, r10 @ $80852dd4	# Fox Blaster
op mr r4, r10 @ $80852e68	# Fox Blaster Bullet
op mr r4, r10 @ $80852fe0	# Falco Blaster
op mr r4, r10 @ $80853074	# Falco Blaster Bullet
op mr r4, r10 @ $8085311c	# Wolf Blaster
op mr r4, r10 @ $808531b0	# Wolf Blaster Bullet
op mr r4, r10 @ $8085280c	# Link Bow
op mr r4, r10 @ $8085326c	# Robot Beam
op mr r4, r10 @ $8085289c	# Link Bow Arrow
op mr r4, r10 @ $80853364	# Dedede Starmissle
op mr r4, r10 @ $8085340c	# Diddy Gun
op mr r4, r10 @ $80853504	# Yoshi Tamago
op mr r4, r10 @ $808536a8	# Shiek Needle
op mr r4, r10 @ $8085373c	# Shiek Needle Have
op mr r4, r10 @ $808538a8	# Lucas PK Flash
op mr r4, r10 @ $80853D28 	# Samus CShot
op mr r4, r10 @ $80852a80	# Pikachu Thunder Jolt
op mr r4, r10 @ $80853ABC	# Pit Bow
op mr r4, r10 @ $80853B54	# Pit Bow Arrow
op mr r4, r10 @ $80853994	# Peach Kinopio
op mr r4, r10 @ $80853F00	# Lucario Aura Ball
op mr r4, r10 @ $80853a14	# Peach Kinopio Spore

HOOK @ $80a3d6ac	# wnPeachKinopio::__ct
{
	addi r5, r1, 0x70	# Original operation
	lwz r12, 0x8(r23)	# \ store copyAbilityKind in unused byte of wnModueleAccesserBuildData
	stb	r12, 0xD(r5)	# /
}
HOOK @ $80a3f1a8	# soModuleAccesserBuilder<wnPeachKinopio>::__ct
{
	addi r4, r15, 2040	# Original operation
	lbz r5, 0xD(r17)	# pass copyAbilityKind as an extra parameter to soGenerateArticleManageModuleBuilder 
}
HOOK @ $80a3f48c	# soGenerateArticleManageModuleBuilder<wnPeachKinopio>::__ct
{
	lwz	r0, 0x18(r3)	# Original operation
	stb r5, 0x9(r1)		# Store copyAbilityKind on stack
}
HOOK @ $80a3f5f0	# soGenerateArticleManageModuleBuilder<wnPeachKinopio>::__ct
{
	mr r4, r19	# Original operation
	lbz r10, 0x9(r1)
}
HOOK @ $80a3f664	# soGenerateArticleManageModuleBuilder<wnPeachKinopio>::__ct
{
	mr r4, r18	# Original operation
	lbz r10, 0x9(r1)
}
HOOK @ $80a3f6dc	# soGenerateArticleManageModuleBuilder<wnPeachKinopio>::__ct
{
	mr r4, r18	# Original operation
	lbz r10, 0x9(r1)
}
HOOK @ $80a3f750	# soGenerateArticleManageModuleBuilder<wnPeachKinopio>::__ct
{
	mr r4, r18	# Original operation
	lbz r10, 0x9(r1)
}
HOOK @ $80a3f7c8	# soGenerateArticleManageModuleBuilder<wnPeachKinopio>::__ct
{
	mr r4, r18	# Original operation
	lbz r10, 0x9(r1)
}
HOOK @ $80a3f840	# soGenerateArticleManageModuleBuilder<wnPeachKinopio>::__ct
{
	mr r4, r18	# Original operation
	lbz r10, 0x9(r1)
}

###########################################
Kirby Copy Ability ID Conversion [Kapedani]
###########################################
## Get conversion from modified module

HOOK @ $80a1a55c	# ftKirbyCopyAbilityIdConverter::convCorrectToOrigId
{
	lwz r3, 0x8(r30)	# \
	addis r3, r3, 0x2	# |
	subi r3, r3, 0x48d4	# |
	lwz r12, 0x0(r3)	# | moduleAccesser->stageObject->copyAbilityModule->convertId()
	lwz r12, 0x1C(r12)	# |
	mtctr r12			# |
	bctrl 				# /
}
HOOK @ $80a1a4bc	# ftKirbyCopyAbilityIdConverter::convOrigToCorrectId
{
	lwz r3, 0x8(r30)	# \
	addis r3, r3, 0x2	# |
	subi r3, r3, 0x48d4	# |
	lwz r12, 0x0(r3)	# | moduleAccesser->stageObject->copyAbilityModule->convertId()
	lwz r12, 0x1C(r12)	# |
	mtctr r12			# |
	bctrl 				# /
}

## TODO: Investigate the neccessity of the codes below

#########################
EX Hat DESTROY Fix [Desi]
#########################
#Again, couldn't tell you why, but this works.
#This fixes something related to the game unloading assets related to kirby characters, and increases the mask from 40 to 80.
#Thing is, i don't think it's masking the character ID, so i don't know why this works, but it does.
op rlwinm. r0, r3, 26, 30, 30 @ $800273F4

