//=============================================================================
// ammo_9mmBullet
//
// 9mm bullet ammunition
// Used for 9mm Pistol, Assault Rifle, SMG, Silenced Pistol, Suitcase Gun
//
// 
//=============================================================================


class ammo_9mmBullet extends B9Ammunition;


//////////////////////////////////
// Initialization
//


defaultproperties
{
	fDamage=10
	fIniLookupName="9mmPistol"
	MaxAmmo=120
	AmmoAmount=15
	PickupAmmo=15
	bInstantHit=true
	MyDamageType=Class'B9BasicTypes.damage_9mmBullet'
	PickupClass=Class'ammo_9mmBullet_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
}