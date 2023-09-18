//=============================================================================
// BlitDagger_Pickup
//
// 
//
// 
//=============================================================================

class BlitDagger_Pickup extends B9MeleeWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'BlitDagger'
	PickupMessage="Acquired BlitDagger"
	Mesh=SkeletalMesh'B9Weapons_models.BlitDagger_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}