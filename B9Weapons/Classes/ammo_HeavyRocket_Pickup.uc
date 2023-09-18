//=============================================================================
// ammo_HeavyRocket_Pickup.uc
//
// 
//
// 
//=============================================================================


class ammo_HeavyRocket_Pickup extends B9_Ammo;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	fIniLookupName="RocketLauncher"
	AmmoAmount=3
	InventoryType=Class'ammo_HeavyRocket'
	PickupMessage="Rockets"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_RPG_mesh'
}