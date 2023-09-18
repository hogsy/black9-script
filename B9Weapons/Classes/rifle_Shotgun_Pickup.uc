//=============================================================================
// rifle_Shotgun_Pickup
//
// 
//
// 
//=============================================================================

class rifle_Shotgun_Pickup extends B9HeavyWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'rifle_Shotgun'
	PickupMessage="SB shotgun"
	Mesh=SkeletalMesh'B9Weapons_models.AssaultRifle_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}