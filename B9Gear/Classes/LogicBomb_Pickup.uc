//=============================================================================
// LogicBomb_Pickup
//
// 
//	
//=============================================================================

class LogicBomb_Pickup extends Pickup;


defaultproperties
{
	InventoryType=Class'LogicBomb'
	PickupMessage="Acquired Logic Bomb"
	PickupSound=Sound'B9Misc_Sounds.ItemPickup.pickup_item03'
	DrawType=8
	StaticMesh=StaticMesh'laxsMeshes.Bomb'
	CollisionRadius=5
	CollisionHeight=5
}