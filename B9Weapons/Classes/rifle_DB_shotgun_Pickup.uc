//=============================================================================
// rifle_DB_Shotgun_Pickup
//
// 
//
// 
//=============================================================================

class rifle_DB_Shotgun_Pickup extends B9HeavyWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'rifle_DB_shotgun'
	PickupMessage="9mm Pistol"
	Mesh=SkeletalMesh'B9Weapons_models.AssaultRifle_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}