class Explosive_Gren_Frag_Ammo extends B9Ammunition;

defaultproperties
{
	fIniLookupName="FragGrenade"
	MaxAmmo=200
	AmmoAmount=50
	PickupAmmo=50
	bRecommendSplashDamage=true
	bTossed=true
	bTrySplash=true
	bSplashDamage=true
	ProjectileClass=Class'Explosive_Gren_Frag_Proj'
	MyDamageType=Class'B9BasicTypes.damage_Explosive_Gren_Frag'
	PickupClass=Class'Explosive_Gren_Frag_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
}