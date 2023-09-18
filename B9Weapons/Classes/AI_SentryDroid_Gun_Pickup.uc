//=============================================================================
// AI_SentryDroid_Gun_Pickup
//
// 
//
// 
//=============================================================================

class AI_SentryDroid_Gun_Pickup extends B9LightWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'AI_SentryDroid_Gun'
	PickupMessage="Acquired Droid Pistol."
	Mesh=SkeletalMesh'B9Weapons_models.AutoPistol_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}