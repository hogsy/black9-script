//=============================================================================
// pistol_SawedOffShotgun_Pickup
//
// 
//
// 
//=============================================================================

class pistol_SawedOffShotgun_Pickup extends B9LightWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'pistol_SawedOffShotgun'
	PickupMessage="Sawed Off Shotgun"
	Mesh=SkeletalMesh'B9Weapons_models.BigRedGun_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}