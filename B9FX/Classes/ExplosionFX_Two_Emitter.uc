class ExplosionFX_Two_Emitter extends Emitter;

// Just like Explosion one but a bit bigger and a little variable in size
event PostBeginPlay()
{
	PlaySound(Sound'B9Weapons_sounds.explosives.grenade_explo1',SLOT_Misc,1.0);
}


defaultproperties
{
	Emitters=/* Array type was not detected. */
	AutoDestroy=true
	bNoDelete=false
}