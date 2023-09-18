//=============================================================================
// BlitSword_Pickup
//
// 
//
// 
//=============================================================================

class BlitSword_Pickup extends B9MeleeWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'BlitSword'
	PickupMessage="Acquired BlitSword"
	Mesh=SkeletalMesh'B9Weapons_models.Blit_Sword_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}