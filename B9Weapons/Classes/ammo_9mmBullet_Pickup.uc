//=============================================================================
// ammo_9mmBullet_Pickup.uc
//
// 
//
// 
//=============================================================================


class ammo_9mmBullet_Pickup extends B9_Ammo;


//////////////////////////////////
// Resource imports
//
#exec TEXTURE IMPORT NAME=SwarmGunAmmoIcon FILE=Textures\SwarmGunAmmoIcon.bmp



//////////////////////////////////
// Initialization
//

defaultproperties
{
	fIniLookupName="9mmPistol"
	AmmoAmount=15
	InventoryType=Class'ammo_9mmBullet'
	PickupMessage="9mm Bullets"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_9mmClip_mesh'
}