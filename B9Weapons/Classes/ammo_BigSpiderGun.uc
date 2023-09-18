//=============================================================================
// ammo_BigSpiderGun
//
// 
//=============================================================================


class ammo_BigSpiderGun extends B9Ammunition;


//////////////////////////////////
// Initialization
//


defaultproperties
{
	fDamage=10
	MaxAmmo=120
	AmmoAmount=15
	PickupAmmo=15
	bInstantHit=true
	MyDamageType=Class'B9BasicTypes.damage_BigSpiderGun'
	PickupClass=Class'ammo_BigSpiderGun_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
}