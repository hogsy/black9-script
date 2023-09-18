//=============================================================================
// heavy_HeavyMachineGun.uc
//
// Heavy Machinegun heavy weapon
//
// 
//=============================================================================


class heavy_HeavyMachineGun extends B9HeavyWeapon;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAmmoExpendedPerShot=1
	fROF=800
	fUniqueID=19
	fForceFeedbackEffectName="HMGFire"
	fIniLookupName="HeavyMachinegun"
	AmmoName=Class'ammo_HMGBullets'
	PickupAmmoCount=100
	ReloadCount=100
	TraceDist=15600
	MaxRange=15600
	FireSound=Sound'B9SoundFX.Weapon.pMag_fire'
	PickupClass=Class'heavy_HeavyMachineGun_Pickup'
	AttachmentClass=Class'heavy_HeavyMachineGun_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.gen_assault_rifle_bricon'
	ItemName="HeavyMachineGun"
	Mesh=SkeletalMesh'B9Weapons_models.BigRedGun_mesh'
}