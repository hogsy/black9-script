//=============================================================================
// ammo_LaunchedGrenade_Pickup.uc
//
// 
//
// 
//=============================================================================


class ammo_LaunchedGrenade_Pickup extends B9_Ammo;


//////////////////////////////////
// Resource imports
//
#exec TEXTURE IMPORT NAME=SwarmGunAmmoIcon FILE=Textures\SwarmGunAmmoIcon.bmp



//////////////////////////////////
// Initialization
//

defaultproperties
{
	fIniLookupName="GrenadeLauncher"
	AmmoAmount=8
	InventoryType=Class'ammo_LaunchedGrenade'
	PickupMessage="Grenade ammo"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_GrenadeShellBox_mesh'
}