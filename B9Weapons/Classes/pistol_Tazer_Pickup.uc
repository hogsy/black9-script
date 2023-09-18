//=============================================================================
// pistol_Tazer_Pickup
//
// 
//
// 
//=============================================================================

class pistol_Tazer_Pickup extends B9LightWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'pistol_Tazer'
	PickupMessage="Tazer Pistol"
	Mesh=SkeletalMesh'B9Weapons_models.StunGun_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}