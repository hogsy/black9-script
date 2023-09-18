//=============================================================================
// ammo_SwarmGun2_Pickup.uc
//
// 
//
// 
//=============================================================================


class ammo_SwarmGun2_Pickup extends B9_Ammo;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	AmmoAmount=5
	InventoryType=Class'Ammo_SwarmGun2'
	PickupMessage="Drunk Missiles"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_DrunkMissile_mesh'
}