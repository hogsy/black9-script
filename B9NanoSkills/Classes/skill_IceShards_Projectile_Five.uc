//=============================================================================
// skill_IceShards_Projectile
//
// Invisible projectile that is the real physical force behind the IceShards
//
// 
//=============================================================================



class skill_IceShards_Projectile_Five extends NanoProjectile;


defaultproperties
{
	fFxClass=Class'B9FX.NanoFX_iceshards_Five'
	fTrailFxClass=Class'B9FX.NanoFX_iceshards_Trail'
	Speed=1500
	MaxSpeed=1500
	Damage=75
	MomentumTransfer=10000
	MyDamageType=Class'B9BasicTypes.damage_IceShards'
	LightType=1
	LightEffect=13
	LightBrightness=85
	LightRadius=10
	LightHue=179
	LightSaturation=71
	bDynamicLight=true
	LifeSpan=20
	SoundRadius=2
	SoundVolume=75
	CollisionRadius=22
	CollisionHeight=11
	bFixedRotationDir=true
	ForceType=1
	ForceRadius=100
	ForceScale=0.6
}