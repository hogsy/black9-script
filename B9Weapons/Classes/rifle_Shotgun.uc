//=============================================================================
// rifle_Shotgun.uc
//
// single-barrelled shotgun weapon
//
// 
//=============================================================================


class rifle_Shotgun extends B9HeavyWeapon;




//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAmmoExpendedPerShot=1
	fROF=15
	fUniqueID=14
	fForceFeedbackEffectName="ShotgunFire"
	fShotgunWeapon=true
	fShotgunPellets=10
	fIniLookupName="Shotgun"
	AmmoName=Class'ammo_ShotgunShell'
	ReloadCount=5
	TraceDist=1950
	MaxRange=1950
	FireSound=Sound'B9SoundFX.Weapon.pMag_fire'
	PickupClass=Class'rifle_Shotgun_Pickup'
	AttachmentClass=Class'rifle_Shotgun_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.shotgun_single_bricon'
	ItemName="Shotgun"
	Mesh=SkeletalMesh'B9Weapons_models.AssaultRifle_mesh'
}