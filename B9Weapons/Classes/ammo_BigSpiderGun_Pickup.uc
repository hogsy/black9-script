//=============================================================================
// ammo_BigSpiderGun_Pickup.uc
//
// 
//=============================================================================


class ammo_BigSpiderGun_Pickup extends B9_Ammo;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	AmmoAmount=15
	InventoryType=Class'ammo_BigSpiderGun'
	PickupMessage="9mm Bullets"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_9mmClip_mesh'
}