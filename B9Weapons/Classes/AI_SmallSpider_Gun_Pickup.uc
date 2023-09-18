//=============================================================================
// AI_SmallSpider_Gun_Pickup
//
// 
//
// 
//=============================================================================

class AI_SmallSpider_Gun_Pickup extends B9HeavyWeaponPickup
	notplaceable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'AI_SmallSpider_Gun'
	PickupMessage="SmallSpider Gun"
	DrawType=0
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}