//=============================================================================
// heavy_RocketLauncher_Pickup
//
// 
//
// 
//=============================================================================

class heavy_RocketLauncher_Pickup extends B9HeavyWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'heavy_RocketLauncher'
	PickupMessage="Rocket Launcher"
	Mesh=SkeletalMesh'B9Weapons_models.RocketLauncher_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}