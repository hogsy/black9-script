//=============================================================================
// ammo_SilencedPistol_Pickup.uc
//
// 
//
// 
//=============================================================================


class ammo_SilencedPistol_Pickup extends B9_Ammo;


//////////////////////////////////
// Resource imports
//
#exec TEXTURE IMPORT NAME=SwarmGunAmmoIcon FILE=Textures\SwarmGunAmmoIcon.bmp



//////////////////////////////////
// Initialization
//

defaultproperties
{
	fIniLookupName="SilencedPistol"
	AmmoAmount=5
	InventoryType=Class'ammo_SilencedPistol'
	PickupMessage="Silenced Magnum Bullets"
	Mesh=SkeletalMesh'B9Weapons_models.Ammo_9mmClip_mesh'
}