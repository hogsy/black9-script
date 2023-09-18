//=============================================================================
// rifle_MarineAssault_Pickup
//
// 
//
// 
//=============================================================================

class rifle_MarineAssault_Pickup extends B9HeavyWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'rifle_MarineAssault'
	PickupMessage="Assault Rifle"
	Mesh=SkeletalMesh'B9Weapons_models.Marine_Gun_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}