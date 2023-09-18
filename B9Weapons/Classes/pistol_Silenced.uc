//=============================================================================
// pistol_Silenced.uc
//
// Silenced Pistol weapon
//
// 
//=============================================================================


class pistol_Silenced extends B9LightWeapon;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAmmoExpendedPerShot=1
	fROF=120
	fNoiseLevel=0.1
	fUniqueID=9
	fForceFeedbackEffectName="SilencedFire"
	fIniLookupName="SilencedPistol"
	AmmoName=Class'ammo_SilencedPistol'
	PickupAmmoCount=5
	ReloadCount=5
	AutoSwitchPriority=3
	TraceDist=1170
	MaxRange=1170
	FireSound=Sound'B9Weapons_sounds.Firearms.bullet_ric06'
	PickupClass=Class'pistol_Silenced_Pickup'
	AttachmentClass=Class'pistol_Silenced_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.gen_pistol_bricon'
	ItemName="Silenced Pistol"
	Mesh=SkeletalMesh'B9Weapons_models.MagnumSilenced_mesh'
}