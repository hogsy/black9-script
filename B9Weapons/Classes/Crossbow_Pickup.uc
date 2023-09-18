//=============================================================================
// Crossbow_Pickup
//
// 
//
// 
//=============================================================================

class Crossbow_Pickup extends B9LightWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'Crossbow'
	PickupMessage="Crossbow"
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}