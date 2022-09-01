Angle 0x200/0x202 and 0x201/0x203 are inwards and outwards sending autolinks, 0x202 and 0x203 are based on distance from centre and users speed [Eon]
HOOK @ $8076B57C
{
    beq %end%
    cmpwi r4, 0x200 #inwards sending
    beq inwards
    cmpwi r4, 0x202
    beq inwards 
    cmpwi r4, 0x201 #outwards sending
    beq outwards
    cmpwi r4, 0x203 #outwards sending
    beq outwards
	b %end%
inwards:
    lfs f0, 0x20(r8) #x hit position
    lfs f1, 0x80(r8) #x hitbox position
    fsubs f0, f1, f0 #x = hitbox-hitpos
    lfs f1, 0x24(r8) #y hit position
    lfs f2, 0x84(r8) #y hitbox position
    fsubs f1, f2, f1 #y = hitbox-hitpos
	stfs f0, 0x0(r6)
	stfs f1, 0x4(r6)
	b %end%
	
outwards:
    lfs f0, 0x20(r8) #x hit position
    lfs f1, 0x80(r8) #x hitbox position
    fsubs f0, f0, f1 #x = hitbox-hitpos
    lfs f1, 0x24(r8) #y hit position
    lfs f2, 0x84(r8) #y hitbox position
    fsubs f1, f1, f2 #y = hitbox-hitpos
	stfs f0, 0x0(r6)
	stfs f1, 0x4(r6)
	#eq flag is currently set to true so will continue into autolink code but with position dif instead of speed
}
#custom knockback values for angles 0x202 and 0x203
HOOK @ $8076cefc
{
    cmpwi r0, 365
    beq %end%
    cmpwi r8, 0
    beq %end%
    cmpwi r0, 0x202 #inwards sending
    beq inwards
    cmpwi r0, 0x203 #outwards sending
    beq outwards
	b %end%
inwards:
    lis r0, 0xBE80 #multiplier of distance from 
    b both
outwards:
    lis r0, 0x3E80
both:
    stw r0, 0x20(r1)
    lfs f0, 0x20(r1)
    
    lfs f1, 0x8C(r19) #xspeed
    lfs f2, 0x20(r19) #x hit position
    lfs f3, 0x80(r19) #x hitbox position
    fsubs f2, f2, f3 #x = hitbox-hitpos
    fmuls f2, f2, f0 #x = x*0.25 or x*-0.25
    #maybe add a cap to how much this has an effect/could do inverse or something depending on use

    fadds f1, f1, f2 #x = x + speed
    stfs f1, 0x20(r1)

    lfs f1, 0x90(r19) #yspeed of attacker
    lfs f2, 0x24(r19) #y hit position
    lfs f3, 0x84(r19) #y hitbox position
    fsubs f2, f2, f3 #y = hitbox-hitpos
    fmuls f2, f2, f0 #y = y*0.25 or y*-0.25
    #maybe add a cap to how much this has an effect/could do inverse or something depending on use
    
    fadds f1, f1, f2 #y = y + speed
    stfs f1, 0x24(r1)

    #could also add some overall cap to this

end:
    lis r12, 0x8076
    ori r12, r12, 0xCF48
    mtctr r12
    bctr
}

Hitbox Object Passed as extra Arg to getDamageAngle [Eon] 
HOOK @ $8076D948
{
	mr r3, r30
	mr r6, r31 #add arg 4 to be ConnectedHitbox
}
HOOK @ $8076CCF8
{
	mr r3, r18
	mr r6, r19 #add arg 4 to be ConnectedHitbox
}
#Fixes a crash when hitting Dedede's minions.
HOOK @ $808e788c
{
  mr r3, r23
  mr r6, r24
}

#adding arg4 of getDamageAngle/[soDamageUtilActor]  
HOOK @ $8076DF8C
{
	stw r6, 0x10(r1)
	lwz r6, 0x0(r5) #original command
}
#passing it as arg 6 of getDamageAngle/[soDamageUtil]
HOOK @ $8076E03C
{
	fmr r6, f28 #original command
	lwz r8, 0x10(r1)
}