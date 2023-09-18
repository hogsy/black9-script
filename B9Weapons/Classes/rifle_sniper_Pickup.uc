//=============================================================================
// rifle_sniper_Pickup
//
// 
//
// 
//=============================================================================

class rifle_sniper_Pickup extends B9HeavyWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'rifle_sniper'
	PickupMessage="Acquired Sniper Rifle"
	Mesh=SkeletalMesh'B9Weapons_models.SniperRifle_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}