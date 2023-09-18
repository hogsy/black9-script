//=============================================================================
// heavy_GrenadeLauncher.uc
//
// Assault Rifle weapon
//
// 
//=============================================================================


class heavy_GrenadeLauncher extends B9HeavyWeapon;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAmmoExpendedPerShot=1
	fROF=8
	fUniqueID=18
	fForceFeedbackEffectName="GrenadeLauncherFire"
	AmmoName=Class'ammo_LaunchedGrenade'
	PickupAmmoCount=8
	ReloadCount=8
	TraceDist=7800
	MaxRange=7800
	FireSound=Sound'B9SoundFX.Bullet_Impacts.p9mm_fire'
	PickupClass=Class'heavy_GrenadeLauncher_Pickup'
	AttachmentClass=Class'heavy_GrenadeLauncher_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.gen_rocket_launcher_bricon'
	ItemName="Grenade Launcher"
	Mesh=SkeletalMesh'B9Weapons_models.GrenadeLauncher_mesh'
}