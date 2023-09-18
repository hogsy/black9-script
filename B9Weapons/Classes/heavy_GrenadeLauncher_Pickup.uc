//=============================================================================
// heavy_GrenadeLauncher_Pickup
//
// 
//
// 
//=============================================================================

class heavy_GrenadeLauncher_Pickup extends B9HeavyWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'heavy_GrenadeLauncher'
	PickupMessage="Grenade Launcher"
	Mesh=SkeletalMesh'B9Weapons_models.GrenadeLauncher_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}