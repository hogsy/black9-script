//=============================================================================
// Tazer_Pickup
//
// 
//
// 
//=============================================================================

class Tazer_Pickup extends B9MeleeWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'Tazer'
	PickupMessage="Acquired Tazer"
	DrawType=8
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}