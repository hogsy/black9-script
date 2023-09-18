//=============================================================================
// HandToHand_Pickup
//
// 
//
// 
//=============================================================================

class HandToHand_Pickup extends B9MeleeWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'HandToHand'
	PickupMessage="Acquired HandToHand"
	Mesh=SkeletalMesh'B9Items_models.MedKit_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}