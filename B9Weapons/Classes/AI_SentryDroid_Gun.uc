//=============================================================================
// AI_SentryDroid_Gun.uc
//
// 9mm Pistol weapon
//
// 
//=============================================================================


class AI_SentryDroid_Gun extends B9LightWeapon;


//////////////////////////////////
// Resource imports
//
#exec TEXTURE IMPORT NAME=SwarmGunIcon FILE=Textures\SwarmGunIcon.bmp


//////////////////////////////////
// Variables
//



//////////////////////////////////
// Functions
//



//////////////////////////////////
// States
//



//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAmmoExpendedPerShot=1
	fROF=100
	fUniqueID=7
	fIniLookupName="LightDroidGun"
	AmmoName=Class'ammo_9mmBullet'
	PickupAmmoCount=15
	ReloadCount=15
	TraceDist=1652
	MaxRange=1652
	FireSound=Sound'B9SoundFX.Bullet_Impacts.p9mm_fire'
	PickupClass=Class'AI_SentryDroid_Gun_Pickup'
	AttachmentClass=Class'AI_SentryDroid_Gun_Attachment'
	Icon=Texture'B9HUD_textures.Browser.ThugPistol_BrIcon_tex'
	ItemName="Droid Pistol"
	Mesh=SkeletalMesh'B9Weapons_models.AutoPistol_mesh'
}