//=============================================================================
// katana_Pickup
//
// 
//
// 
//=============================================================================

class katana_Pickup extends B9MeleeWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'katana'
	PickupMessage="Acquired Katana"
	Mesh=SkeletalMesh'B9Weapons_models.Katana_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}