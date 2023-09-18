//=============================================================================
// ammo_SniperRifle
//
//
// 
//=============================================================================


class ammo_SniperRifle extends B9Ammunition;



//////////////////////////////////
// Initialization
//


defaultproperties
{
	fDamage=25
	fIniLookupName="SniperRifle"
	MaxAmmo=20
	AmmoAmount=4
	PickupAmmo=4
	bInstantHit=true
	MyDamageType=Class'B9BasicTypes.damage_SniperRifle'
	PickupClass=Class'ammo_SniperRifle_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
}