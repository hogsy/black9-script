//=============================================================================
// rifle_Assault_Pickup
//
// 
//
// 
//=============================================================================

class rifle_Assault_Pickup extends B9HeavyWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'rifle_Assault'
	PickupMessage="Assault Rifle"
	Mesh=SkeletalMesh'B9Weapons_models.AssaultRifle_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}