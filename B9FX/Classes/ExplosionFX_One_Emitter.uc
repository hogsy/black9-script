class ExplosionFX_One_Emitter extends Emitter;

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