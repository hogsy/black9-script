//=============================================================================
// ammo_ShotgunShell
//
// 9mm bullet ammunition
// Used for 9mm Pistol, Assault Rifle, SMG, Silenced Pistol, Suitcase Gun
//
// 
//=============================================================================


class ammo_ShotgunShell extends B9Ammunition;




//////////////////////////////////
// Initialization
//


defaultproperties
{
	fDamage=10
	fIniLookupName="Shotgun"
	MaxAmmo=15
	AmmoAmount=1
	PickupAmmo=1
	bInstantHit=true
	MyDamageType=Class'B9BasicTypes.damage_ShotgunShell'
	PickupClass=Class'ammo_ShotgunShell_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
}