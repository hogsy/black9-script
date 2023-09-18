//=============================================================================
// ammo_RadFlux_Pickup.uc
//
// 
//
// 
//=============================================================================


class ammo_RadFlux_Pickup extends B9_Ammo;


//////////////////////////////////
// Resource imports
//
#exec TEXTURE IMPORT NAME=SwarmGunAmmoIcon FILE=Textures\SwarmGunAmmoIcon.bmp



//////////////////////////////////
// Initialization
//

defaultproperties
{
	fIniLookupName="RadFlux"
	AmmoAmount=100
	InventoryType=Class'ammo_RadFlux'
	PickupMessage="RadFlux Power"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_EnergyCell_mesh'
}