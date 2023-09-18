//=============================================================================
// ammo_AssaultRifle_Pickup.uc
//
// 
//
// 
//=============================================================================


class ammo_AssaultRifle_Pickup extends B9_Ammo;




//////////////////////////////////
// Initialization
//

defaultproperties
{
	fIniLookupName="AssaultRifle"
	AmmoAmount=30
	InventoryType=Class'ammo_AssaultRifle'
	PickupMessage="9mm Bullets"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_9mmClip_mesh'
}