//=============================================================================
// AI_Intimidator_Gun_Pickup
//
// 
//
// 
//=============================================================================

class AI_Intimidator_Gun_Pickup extends B9HeavyWeaponPickup
	notplaceable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'AI_Intimidator_Gun'
	PickupMessage="Intimidator Gune"
	DrawType=0
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}