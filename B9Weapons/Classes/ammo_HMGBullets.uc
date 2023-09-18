//=============================================================================
// ammo_HMGBullets
//
// 
//=============================================================================


class ammo_HMGBullets extends B9Ammunition;




//////////////////////////////////
// Initialization
//


defaultproperties
{
	fIniLookupName="HeavyMachinegun"
	MaxAmmo=1000
	AmmoAmount=100
	PickupAmmo=100
	bInstantHit=true
	MyDamageType=Class'B9BasicTypes.damage_HMGBullets'
	PickupClass=Class'ammo_HMGBullets_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
}