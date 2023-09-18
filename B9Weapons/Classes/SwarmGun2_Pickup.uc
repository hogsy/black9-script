//=============================================================================
// SwarmGun2_Pickup
//
// 
//
// 
//=============================================================================

class SwarmGun2_Pickup extends WeaponPickup;

defaultproperties
{
	InventoryType=Class'SwarmGun2'
	PickupMessage="You got the Swarmer Launcher!"
	PickupSound=Sound'WarEffects.Pickups.WeaponPickup'
	Mesh=SkeletalMesh'B9Weapons_models.bazooka'
	CollisionRadius=34
	CollisionHeight=8
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}