//=============================================================================
// GrapplingHook_Pickup
//
// 
//
// 
//=============================================================================

class GrapplingHook_Pickup extends B9LightWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'GrapplingHook'
	PickupMessage="Acquired Grappling Hook."
	Mesh=SkeletalMesh'B9Weapons_models.GrapplingHook_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}