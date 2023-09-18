//=============================================================================
// ammo_Tazer
//
// Tazer Ammunition
// 
//=============================================================================


class ammo_Tazer extends B9Ammunition;


//////////////////////////////////
// Initialization
//


defaultproperties
{
	fIniLookupName="AssaultRifle"
	MaxAmmo=20000
	AmmoAmount=1000
	PickupAmmo=1000
	bInstantHit=true
	MyDamageType=Class'B9BasicTypes.damage_Tazer'
	PickupClass=Class'ammo_Tazer_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
}