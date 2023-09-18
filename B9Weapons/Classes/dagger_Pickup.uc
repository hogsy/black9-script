//=============================================================================
// dagger_Pickup
//
// 
//
// 
//=============================================================================

class dagger_Pickup extends B9MeleeWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'dagger'
	PickupMessage="Acquired dagger"
	DrawType=8
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}