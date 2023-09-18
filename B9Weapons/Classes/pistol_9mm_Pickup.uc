//=============================================================================
// pistol_9mm_Pickup
//
// 
//
// 
//=============================================================================

class pistol_9mm_Pickup extends B9LightWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'pistol_9mm'
	PickupMessage="Acquired 9mm Pistol."
	Mesh=SkeletalMesh'B9Weapons_models.9mm_pistol_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}