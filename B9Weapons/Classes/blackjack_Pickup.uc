//=============================================================================
// blackjack_Pickup
//
// 
//
// 
//=============================================================================

class blackjack_Pickup extends B9MeleeWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'blackjack'
	PickupMessage="Acquired blackjack"
	DrawType=8
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}