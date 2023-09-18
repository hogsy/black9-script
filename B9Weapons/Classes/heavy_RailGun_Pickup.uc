//=============================================================================
// heavy_RailGun_Pickup
//
// 
//
// 
//=============================================================================

class heavy_RailGun_Pickup extends B9HeavyWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'heavy_RailGun'
	PickupMessage="Heavy Machinegun"
	Mesh=SkeletalMesh'B9Weapons_models.RailGun_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}