//=============================================================================
// pistol_SMG_Pickup
//
// 
//
// 
//=============================================================================

class pistol_SMG_Pickup extends B9LightWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'pistol_SMG'
	PickupMessage="Acquired Sub-Machine Gun."
	Mesh=SkeletalMesh'B9Weapons_models.SMG_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}