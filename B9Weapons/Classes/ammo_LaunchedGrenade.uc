//=============================================================================
// ammo_LaunchedGrenade
//
// 
//=============================================================================

class ammo_LaunchedGrenade extends B9Ammunition;

defaultproperties
{
	fIniLookupName="GrenadeLauncher"
	MaxAmmo=40
	AmmoAmount=8
	PickupAmmo=8
	bRecommendSplashDamage=true
	bTrySplash=true
	bLeadTarget=true
	bSplashDamage=true
	ProjectileClass=Class'proj_LaunchedGrenade'
	MyDamageType=Class'B9BasicTypes.damage_9mmBullet'
	PickupClass=Class'ammo_LaunchedGrenade_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
	ItemName="Grenade"
}