#########################################
Special Angles [Eon, Kapedani, DukeItOut]
#########################################
# 0x200(362)/0x202 and 0x201/0x203 are inwards and outwards sending autolinks, 0x202 and 0x203 are based on distance from centre and users speed [Eon]

.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
}
.macro branch(<addr>)
{
    %lwi(r12, <addr>)
    mtctr r12
    bctr
}

HOOK @ $8076B57C    # soDamageUtil::getDamageAngle
{
    cmpwi r4, 365
    beq- %end%
    stw r4, 0x8(r1)     # \
    stw r5, 0xc(r1)     # | save required regs for rest of function
    stfs f3, 0x10(r1)   # /
    li r4, 0x0          # \
    lwz r3, 0xd8(r3)    # | 
    lwz r3, 0x38(r3)    # |
    lwz r12, 0x8(r3)    # | moduleAccesser->moduleEnumeration->damageModule->getDamage(0)
    lwz r12, 0x50(r12)  # |
    mtctr r12           # |
    bctrl               # /    
    lwz r4, 0x8(r1)     # \ 
    lwz r5, 0xc(r1)     # | restore required regs for rest of function
    lfs f3, 0x10(r1)    # |
    mr r6, r29          # /
    cmpwi r3, 0x0   # \ check if soDamage is null 
    beq- %end%      # /

    cmpwi r4, 0x200 #inwards sending
    beq inwards
    cmpwi r4, 0x202
    beq inwards 
    cmpwi r4, 0x201 #outwards sending
    beq outwards
    cmpwi r4, 0x203 #outwards sending
    beq outwards
    cmpwi r4, 362
    bne+ %end%    
inwards:
    lfs f0, 0x20(r3) #x hit position
    lfs f1, 0x80(r3) #x hitbox position
    lfs f2, 0x24(r3) #y hit position
    lfs f3, 0x84(r3) #y hitbox position
    b calcDisplacement 
outwards:
    lfs f1, 0x20(r3) #x hit position
    lfs f0, 0x80(r3) #x hitbox position
    lfs f3, 0x24(r3) #y hit position
    lfs f2, 0x84(r3) #y hitbox position
calcDisplacement:
    fsubs f0, f1, f0 #x = hitbox-hitpos
    fsubs f1, f3, f2 #y = hitbox-hitpos
	stfs f0, 0x0(r6)
	stfs f1, 0x4(r6)
	#eq flag is currently set to true so will continue into autolink code but with position dif instead of speed
}
#custom knockback values for angles 0x202 and 0x203
HOOK @ $8076cefc
{
    cmpwi r0, 365
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
    %branch(0x8076CF48)
}