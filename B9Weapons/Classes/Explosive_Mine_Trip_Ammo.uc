class Explosive_Mine_Trip_Ammo extends B9Ammunition;

defaultproperties
{
	fIniLookupName="TripMine"
	MaxAmmo=200
	AmmoAmount=50
	PickupAmmo=50
	bRecommendSplashDamage=true
	bTossed=true
	bTrySplash=true
	bSplashDamage=true
	ProjectileClass=Class'Explosive_Mine_Trip_Proj'
	MyDamageType=none
	PickupClass=Class'Explosive_Mine_Trip_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
}