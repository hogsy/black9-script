//=============================================================================
// ammo_RailGun_Pickup.uc
//
// 
//
// 
//=============================================================================


class ammo_RailGun_Pickup extends B9_Ammo;


//////////////////////////////////
// Resource imports
//
#exec TEXTURE IMPORT NAME=SwarmGunAmmoIcon FILE=Textures\SwarmGunAmmoIcon.bmp



//////////////////////////////////
// Initialization
//

defaultproperties
{
	fIniLookupName="RailGun"
	AmmoAmount=5
	InventoryType=Class'ammo_RailGun'
	PickupMessage="Rail Gun Rounds"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_RailGunClip_mesh'
}