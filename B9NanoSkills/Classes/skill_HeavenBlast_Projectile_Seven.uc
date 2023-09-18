//=============================================================================
// skill_HeavenBlast_Projectile_Seven
//
// 
//=============================================================================



class skill_HeavenBlast_Projectile_Seven extends NanoProjectile;




defaultproperties
{
	fFxClass=Class'B9FX.NanoFX_HeavenBlast_Seven'
	fTrailFxClass=Class'B9FX.NanoFX_HeavenBlast_Seven'
	Speed=2000
	Damage=75
	MomentumTransfer=10000
	MyDamageType=Class'B9BasicTypes.damage_HeavenBlast'
	LightType=1
	LightEffect=13
	LightBrightness=1000
	LightRadius=10
	LightHue=39
	LightSaturation=100
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