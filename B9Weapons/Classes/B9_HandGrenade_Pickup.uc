//=============================================================================
// B9_HandGrenade_Pickup 
//
// 
//=============================================================================

class B9_HandGrenade_Pickup extends B9_AccumulativeItemPickup;

defaultproperties
{
	Amount=5
	InventoryType=Class'B9_HandGrenade'
	PickupMessage="You got a Hand Grenade!  Kaboom!"
	PickupSound=Sound'B9Misc_Sounds.ItemPickup.pickup_item05'
	Mesh=SkeletalMesh'B9Weapons_models.FragGrenade_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}