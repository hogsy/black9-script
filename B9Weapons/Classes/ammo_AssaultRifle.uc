//=============================================================================
// ammo_AssaultRifle
//
// 
//=============================================================================


class ammo_AssaultRifle extends B9Ammunition;


//////////////////////////////////
// Initialization
//


defaultproperties
{
	fDamage=20
	fIniLookupName="AssaultRifle"
	MaxAmmo=450
	AmmoAmount=30
	PickupAmmo=30
	bInstantHit=true
	MyDamageType=Class'B9BasicTypes.damage_AssaultRifle'
	PickupClass=Class'ammo_AssaultRifle_Pickup'
}