//=============================================================================
// pistol_Silenced_Pickup
//
// 
//
// 
//=============================================================================

class pistol_Silenced_Pickup extends B9LightWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'pistol_Silenced'
	PickupMessage="Silenced Pistol"
	Mesh=SkeletalMesh'B9Weapons_models.MagnumSilenced_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}