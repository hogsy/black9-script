//=============================================================================
// pistol_Magnum.uc
//
// Magnum Pistol weapon
//
// 
//=============================================================================


class pistol_Magnum extends B9LightWeapon;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAmmoExpendedPerShot=1
	fROF=150
	fUniqueID=8
	fForceFeedbackEffectName="MagnumFire"
	fIniLookupName="MagnumPistol"
	AmmoName=Class'ammo_MagnumBullet'
	PickupAmmoCount=8
	ReloadCount=8
	AutoSwitchPriority=2
	TraceDist=1888
	MaxRange=1888
	FireSound=Sound'B9SoundFX.Weapon.pMag_fire'
	PickupClass=Class'pistol_Magnum_Pickup'
	AttachmentClass=Class'pistol_Magnum_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.gen_pistol_bricon'
	ItemName="Magnum Pistol"
	Mesh=SkeletalMesh'B9Weapons_models.Magnum_mesh'
}