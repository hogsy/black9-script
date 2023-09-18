//=============================================================================
// pistol_9mm.uc
//
// 9mm Pistol weapon
//
// 
//=============================================================================


class pistol_9mm extends B9LightWeapon;



//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAmmoExpendedPerShot=1
	fROF=200
	fReloadSound=Sound'B9Weapons_sounds.Firearms.reload_pistol'
	fUniqueID=7
	fForceFeedbackEffectName="9mmFire"
	fIniLookupName="9mmPistol"
	AmmoName=Class'ammo_9mmBullet'
	PickupAmmoCount=15
	ReloadCount=15
	TraceDist=1652
	MaxRange=1652
	FireSound=Sound'B9Weapons_sounds.Firearms.pistol_shot2'
	PickupClass=Class'pistol_9mm_Pickup'
	AttachmentClass=Class'pistol_9mm_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.gen_pistol_bricon'
	ItemName="9mm Pistol"
	Mesh=SkeletalMesh'B9Weapons_models.9mm_pistol_mesh'
}