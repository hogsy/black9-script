//=============================================================================
// ammo_HMGBullets_Pickup.uc
//
// 
//
// 
//=============================================================================


class ammo_HMGBullets_Pickup extends B9_Ammo;



//////////////////////////////////
// Initialization
//

defaultproperties
{
	fIniLookupName="HeavyMachinegun"
	AmmoAmount=100
	InventoryType=Class'ammo_HMGBullets'
	PickupMessage="Heavy Machinegun Bullets"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_9mmClip_mesh'
}