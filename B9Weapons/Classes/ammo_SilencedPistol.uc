//=============================================================================
// ammo_SilencedPistol
//
// 9mm bullet ammunition
// Used for 9mm Pistol, Assault Rifle, SMG, Silenced Pistol, Suitcase Gun
//
// 
//=============================================================================


class ammo_SilencedPistol extends B9Ammunition;


//////////////////////////////////
// Initialization
//


defaultproperties
{
	fDamage=5
	fIniLookupName="SilencedPistol"
	MaxAmmo=40
	AmmoAmount=5
	PickupAmmo=5
	bInstantHit=true
	MyDamageType=Class'B9BasicTypes.damage_SilencedPistol'
	PickupClass=Class'ammo_SilencedPistol_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
}