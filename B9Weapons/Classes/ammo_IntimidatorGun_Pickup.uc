//=============================================================================
// ammo_IntimidatorGun_Pickup.uc
//
// 
//=============================================================================


class ammo_IntimidatorGun_Pickup extends B9_Ammo;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	AmmoAmount=15
	InventoryType=Class'ammo_IntimidatorGun'
	PickupMessage="9mm Bullets"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_9mmClip_mesh'
}