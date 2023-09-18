//=============================================================================
// AI_BigSpider_Gun_Pickup
//
// 
//
// 
//=============================================================================

class AI_BigSpider_Gun_Pickup extends B9HeavyWeaponPickup
	notplaceable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'AI_BigSpider_Gun'
	PickupMessage="BigSpider Gune"
	DrawType=0
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}