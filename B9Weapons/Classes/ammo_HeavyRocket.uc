//=============================================================================
// ammo_HeavyRocket
//
// 
//=============================================================================

class ammo_HeavyRocket extends B9Ammunition;

defaultproperties
{
	fIniLookupName="RocketLauncher"
	MaxAmmo=60
	AmmoAmount=3
	PickupAmmo=3
	bRecommendSplashDamage=true
	bTrySplash=true
	bLeadTarget=true
	bSplashDamage=true
	ProjectileClass=Class'proj_HeavyRocket'
	MyDamageType=Class'B9BasicTypes.damage_HeavyRocket'
	PickupClass=Class'ammo_HeavyRocket_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
	ItemName="Heavy Rocket"
}