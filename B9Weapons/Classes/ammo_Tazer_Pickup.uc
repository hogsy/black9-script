//=============================================================================
// ammo_Tazer_Pickup.uc
//
// 
//
// 
//=============================================================================


class ammo_Tazer_Pickup extends B9_Ammo;


//////////////////////////////////
// Resource imports
//
#exec TEXTURE IMPORT NAME=SwarmGunAmmoIcon FILE=Textures\SwarmGunAmmoIcon.bmp



//////////////////////////////////
// Initialization
//

defaultproperties
{
	AmmoAmount=10
	InventoryType=Class'ammo_Tazer'
	PickupMessage="Tazer Rounds"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_EnergyCell_mesh'
}