//=============================================================================
// ammo_MagnumBullet
//
// Magnum bullet ammunition
// Used for Magnum Pistol, Assault Rifle, SMG, Silenced Pistol, Suitcase Gun
//
// 
//=============================================================================


class ammo_MagnumBullet extends B9Ammunition;



//////////////////////////////////
// Initialization
//


defaultproperties
{
	fDamage=15
	fIniLookupName="MagnumPistol"
	MaxAmmo=48
	AmmoAmount=8
	PickupAmmo=8
	bInstantHit=true
	MyDamageType=Class'B9BasicTypes.damage_MagnumBullet'
	PickupClass=Class'ammo_MagnumBullet_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
}