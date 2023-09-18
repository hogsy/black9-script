//=============================================================================
// ammo_SpiderBotGun
//
// 
//=============================================================================


class ammo_SpiderBotGun extends B9Ammunition;


//////////////////////////////////
// Initialization
//


defaultproperties
{
	fDamage=3
	MaxAmmo=120
	AmmoAmount=15
	PickupAmmo=15
	bInstantHit=true
	MyDamageType=Class'B9BasicTypes.damage_SpiderBotGun'
	PickupClass=Class'ammo_SpiderBotGun_Pickup'
	Icon=Texture'SwarmGunAmmoIcon'
}