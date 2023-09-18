//=============================================================================
// rifle_Assault.uc
//
// Assault Rifle weapon
//
// 
//=============================================================================


class rifle_Assault extends B9HeavyWeapon;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAmmoExpendedPerShot=1
	fROF=600
	fUniqueID=17
	fForceFeedbackEffectName="AssaultRifleFire"
	fIniLookupName="AssaultRifle"
	AmmoName=Class'ammo_AssaultRifle'
	PickupAmmoCount=30
	ReloadCount=30
	TraceDist=7020
	MaxRange=7020
	FireSound=Sound'B9SoundFX.Bullet_Impacts.p9mm_fire'
	PickupClass=Class'rifle_Assault_Pickup'
	AttachmentClass=Class'rifle_Assault_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.Assault_Rifle_bricon'
	ItemName="Assault Rifle"
	Mesh=SkeletalMesh'B9Weapons_models.AssaultRifle_mesh'
}