//=============================================================================
// heavy_FlameThrower_Pickup
//
// 
//
// 
//=============================================================================

class heavy_FlameThrower_Pickup extends B9HeavyWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'heavy_FlameThrower'
	PickupMessage="Heavy Machinegun"
	Mesh=SkeletalMesh'B9Weapons_models.flamethrower_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}