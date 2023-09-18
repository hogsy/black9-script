//=============================================================================
// ammo_SniperRifle_Pickup.uc
//
// 
//
// 
//=============================================================================


class ammo_SniperRifle_Pickup extends B9_Ammo;



//////////////////////////////////
// Initialization
//

defaultproperties
{
	fIniLookupName="SniperRifle"
	AmmoAmount=4
	InventoryType=Class'ammo_SniperRifle'
	PickupMessage="Sniper Rounds"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_RailGunClip_mesh'
}