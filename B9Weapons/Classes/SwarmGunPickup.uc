//=============================================================================
// SwarmGunPickup
//
// 
//
// 
//=============================================================================

class SwarmGunPickup extends WeaponPickup;

#exec OBJ LOAD FILE=..\animations\B9Weapons_models.ukx PACKAGE=B9Weapons_models

defaultproperties
{
	InventoryType=Class'SwarmGun'
	PickupMessage="You got the Swarmer Launcher!"
	Mesh=SkeletalMesh'B9Weapons_models.bazooka'
	CollisionRadius=34
	CollisionHeight=8
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}