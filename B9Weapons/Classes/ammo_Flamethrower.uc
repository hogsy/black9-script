//=============================================================================
// ammo_Flamethrower
//
// Energy Cell ammunition
// Used for flamethrower, rad flux rifle, and other energy-based weapons
//
// 
//=============================================================================


class ammo_Flamethrower extends B9Ammunition;



//////////////////////////////////
// Functions
//


//////////////////////////////////
// Initialization
//


defaultproperties
{
	fIniLookupName="Flamethrower"
	MaxAmmo=1275
	AmmoAmount=255
	PickupAmmo=255
	bInstantHit=true
	MyDamageType=Class'B9BasicTypes.damage_FlameThrower'
	PickupClass=Class'ammo_Flamethrower_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
}