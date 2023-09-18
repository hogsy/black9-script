//=============================================================================
// heavy_HeavyMachineGun_Pickup
//
// 
//
// 
//=============================================================================

class heavy_HeavyMachineGun_Pickup extends B9HeavyWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'heavy_HeavyMachineGun'
	PickupMessage="Heavy Machinegun"
	Mesh=SkeletalMesh'B9Weapons_models.BigRedGun_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}