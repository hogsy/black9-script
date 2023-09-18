//=============================================================================
// ammo_SMG
//
// 
//=============================================================================


class ammo_SMG extends B9Ammunition;


//////////////////////////////////
// Initialization
//


defaultproperties
{
	fDamage=8
	fIniLookupName="SMG"
	MaxAmmo=450
	AmmoAmount=30
	PickupAmmo=30
	bInstantHit=true
	MyDamageType=Class'B9BasicTypes.damage_SMG'
	PickupClass=Class'ammo_SMG_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
}