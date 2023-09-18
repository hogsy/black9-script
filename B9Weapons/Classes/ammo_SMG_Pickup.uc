//=============================================================================
// ammo_SMG_Pickup.uc
//
// 
//
// 
//=============================================================================


class ammo_SMG_Pickup extends B9_Ammo;



//////////////////////////////////
// Initialization
//

defaultproperties
{
	fIniLookupName="SMG"
	AmmoAmount=30
	InventoryType=Class'ammo_SMG'
	PickupMessage="SMG Magazine"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_9mmClip_mesh'
}