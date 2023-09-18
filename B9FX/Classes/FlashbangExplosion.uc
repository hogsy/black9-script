
class FlashBangExplosion extends Emitter;

event PostBeginPlay()
{
	PlaySound(Sound'B9Weapons_sounds.explosives.grenade_explo1',SLOT_Misc,1.0);
}

defaultproperties
{
	Emitters=/* Array type was not detected. */
	AutoDestroy=true
	Physics=10
	bNoDelete=false
	bDynamicLight=true
	bTrailerSameRotation=true
	RemoteRole=2
}