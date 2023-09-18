//=============================================================================
// pistol_SawedOffShotgun.uc
//
// SawedOffShotgun Pistol weapon
//
// 
//=============================================================================


class pistol_SawedOffShotgun extends B9LightWeapon;


//////////////////////////////////
// Initialization
//


defaultproperties
{
	fAmmoExpendedPerShot=1
	fUniqueID=13
	fForceFeedbackEffectName="SawedOffShotgunFire"
	fShotgunWeapon=true
	fShotgunPellets=8
	fIniLookupName="SawedOffShotgun"
	AmmoName=Class'ammo_ShotgunShell'
	PickupAmmoCount=10
	ReloadCount=5
	TraceDist=1780
	MaxRange=1780
	FireSound=Sound'B9SoundFX.Weapon.pMag_fire'
	PickupClass=Class'pistol_SawedOffShotgun_Pickup'
	AttachmentClass=Class'pistol_SawedOffShotgun_Attachment'
	Icon=none
	ItemName="SawedOffShotgun Pistol"
	Mesh=SkeletalMesh'B9Weapons_models.BigRedGun_mesh'
}