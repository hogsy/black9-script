//=============================================================================
// ammo_Flamethrower_Pickup.uc
//
// 
//
// 
//=============================================================================


class ammo_Flamethrower_Pickup extends B9_Ammo;


//////////////////////////////////
// Resource imports
//
#exec TEXTURE IMPORT NAME=SwarmGunAmmoIcon FILE=Textures\SwarmGunAmmoIcon.bmp



//////////////////////////////////
// Initialization
//

defaultproperties
{
	fIniLookupName="Flamethrower"
	AmmoAmount=50
	InventoryType=Class'ammo_Flamethrower'
	PickupMessage="Energy Cell"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_EnergyCell2_mesh'
}