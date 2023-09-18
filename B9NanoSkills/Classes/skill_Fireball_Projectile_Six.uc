//=============================================================================
// skill_Fireball_Projectile_Six
//
// 
//=============================================================================



class skill_Fireball_Projectile_Six extends NanoProjectile;



defaultproperties
{
	fFxClass=Class'B9FX.NanoFX_fireball_Six'
	fTrailFxClass=Class'B9FX.NanoFX_fireballTrail_Six'
	fImpactFxClass=Class'B9FX.ExplosionFX_One_Emitter'
	Speed=1500
	MaxSpeed=1500
	Damage=75
	MomentumTransfer=10000
	MyDamageType=Class'B9BasicTypes.damage_Fireball'
	LightType=4
	LightEffect=13
	LightBrightness=1000
	LightRadius=10
	LightHue=28
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