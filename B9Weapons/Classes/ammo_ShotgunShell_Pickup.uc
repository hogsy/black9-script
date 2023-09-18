//=============================================================================
// ammo_ShotgunShell_Pickup.uc
//
// 
//
// 
//=============================================================================


class ammo_ShotgunShell_Pickup extends B9_Ammo;


//////////////////////////////////
// Resource imports
//
#exec TEXTURE IMPORT NAME=SwarmGunAmmoIcon FILE=Textures\SwarmGunAmmoIcon.bmp



//////////////////////////////////
// Initialization
//

defaultproperties
{
	fIniLookupName="Shotgun"
	AmmoAmount=10
	InventoryType=Class'ammo_ShotgunShell'
	PickupMessage="Shotgun Shells"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_ShotgunShellBox_mesh'
}