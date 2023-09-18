//=============================================================================
// ammo_SpiderBotGun_Pickup.uc
//
// 
//=============================================================================


class ammo_SpiderBotGun_Pickup extends B9_Ammo;



//////////////////////////////////
// Initialization
//

defaultproperties
{
	AmmoAmount=15
	InventoryType=Class'ammo_SpiderBotGun'
	PickupMessage="9mm Bullets"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_9mmClip_mesh'
}