renderDebug/[gfSceneRoot] [Eon]
.alias stageID = 0
.alias fighterID = 1
.alias itemsarticlesID = 2 #also includes primids etc
.alias specialItemsID = 3 #specific items e.g. beam sword for some reason, assist trophy, food, starman, lightning, warpstar, star rod, goey bomb, freezie, hothead, team healer, screw attack, 
.alias gfxID = 4
.alias specificFXID = 5 #seems like it might literally just be the blue falcon
.alias unk2ID = 6 #not spawned at all on spawn
.alias unk3ID = 7 #appears once on spawn, is always on #ecMgr, seems to literally just be the manager itself, not what it draws?
.alias interfaceID = 8

#3,5,6,7 are confusing ones, everything else is understood

HOOK @ $8000E7AC
{
	stwu r1, -0x10 (r1)
	mflr r0
	stw r0, 0x14(r1)
	stw r31, 0x0C(r1)
	stw r30, 0x08(r1)
	mr r31, r3

	lis r30, 0x8000
	ori r30, r30, 0xD234
char:
	lis r3, 0x8058
    ori r3, r3, 0x3FFC
    lhz r3, 0x0(r3)
    cmpwi r3, 2
    bne stage
	mr r3, r31
	li r4, fighterID
	li r5, 0
	mtctr r30
	bctrl
	mr r3, r31
	li r4, gfxID
	li r5, 0
	mtctr r30
	bctrl
#	rlwimi r0, r5, 5, 26, 26
#	stb r0, 0x399(r3) #disables gfx draw too

	mr r3, r31
	li r4, itemsarticlesID
	li r5, 0
    mtctr r30
	bctrl	
	mr r3, r31
	li r4, specialItemsID
	li r5, 0
	mtctr r30
	bctrl
	mr r3, r31
	li r4, specificFXID
	li r5, 0
	mtctr r30
	bctrl
#disable stage render
stage:
	lis r3, 0x8058
    ori r3, r3, 0x3FF8
    lhz r3, 0x0(r3)
    cmpwi r3, 2
    bne end
	mr r3, r31
	li r4, stageID
	li r5, 0
	mtctr r30
	bctrl
end:
	lwz r0, 0x14(r1)
	lwz r31, 0x0C(r1)
	lwz r30, 0x08(r1)
	mtlr r0
	addi r1, r1, 0x10
	blr	

}