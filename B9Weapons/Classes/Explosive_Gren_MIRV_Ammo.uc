class Explosive_Gren_MIRV_Ammo extends B9Ammunition;

defaultproperties
{
	fIniLookupName="MirvGrenade"
	MaxAmmo=200
	AmmoAmount=50
	PickupAmmo=50
	bRecommendSplashDamage=true
	bTossed=true
	bTrySplash=true
	bSplashDamage=true
	ProjectileClass=Class'Explosive_Gren_MIRV_Proj'
	MyDamageType=none
	PickupClass=Class'Explosive_Gren_MIRV_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
}