//=============================================================================
// rifle_DB_Shotgun.uc
//
// 9mm Pistol weapon
//
// 
//=============================================================================


class rifle_DB_Shotgun extends B9HeavyWeapon;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAmmoExpendedPerShot=2
	fROF=15
	fUniqueID=16
	fForceFeedbackEffectName="DoubleShotgunFire"
	fShotgunWeapon=true
	fShotgunPellets=12
	fIniLookupName="DoubleBarrelShotgun"
	AmmoName=Class'ammo_ShotgunShell'
	ReloadCount=2
	TraceDist=1950
	MaxRange=1950
	FireSound=Sound'B9SoundFX.Weapon.pMag_fire'
	PickupClass=Class'rifle_DB_shotgun_Pickup'
	AttachmentClass=Class'rifle_DB_shotgun_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.shotgun_double_bricon'
	ItemName="Double-Barrelled Shotgun"
	Mesh=SkeletalMesh'B9Weapons_models.AssaultRifle_mesh'
}