//=============================================================================
// heavy_RadFlux_Pickup
//
// 
//
// 
//=============================================================================

class heavy_RadFlux_Pickup extends B9HeavyWeaponPickup
	placeable;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	InventoryType=Class'heavy_RadFlux'
	PickupMessage="Rad Flux Rifle"
	Mesh=SkeletalMesh'B9Weapons_models.RadFluxRifle_mesh'
	MessageClass=Class'WarfareGame.PickupMessagePlus'
}