//=============================================================================
// pistol_Magnum_Pickup
//
// 
//
// 
//=============================================================================

class pistol_Magnum_Pickup extends B9LightWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'pistol_Magnum'
	PickupMessage="Acquired Magnum Pistol."
	Mesh=SkeletalMesh'B9Weapons_models.Magnum_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}