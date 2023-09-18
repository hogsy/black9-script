//=============================================================================
// ammo_MagnumBullet_Pickup.uc
//
// 
//
// 
//=============================================================================


class ammo_MagnumBullet_Pickup extends B9_Ammo;


//////////////////////////////////
// Resource imports
//
#exec TEXTURE IMPORT NAME=SwarmGunAmmoIcon FILE=Textures\SwarmGunAmmoIcon.bmp



//////////////////////////////////
// Initialization
//

defaultproperties
{
	fIniLookupName="MagnumPistol"
	AmmoAmount=8
	InventoryType=Class'ammo_MagnumBullet'
	PickupMessage="Magnum Bullets"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_9mmClip_mesh'
}