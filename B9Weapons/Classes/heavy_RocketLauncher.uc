//=============================================================================
// heavy_RocketLauncher.uc
//
// Assault Rifle weapon
//
// 
//=============================================================================


class heavy_RocketLauncher extends B9HeavyWeapon;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAmmoExpendedPerShot=1
	fReloadSound=Sound'B9Weapons_sounds.HeavyWeapons.rocket_launcher_reload1'
	fUniqueID=22
	fForceFeedbackEffectName="RocketLauncherFire"
	fProjectileWeapon=true
	fIniLookupName="RocketLauncher"
	AmmoName=Class'ammo_HeavyRocket'
	PickupAmmoCount=5
	ReloadCount=1
	TraceDist=15600
	MaxRange=15600
	FireSound=Sound'B9Weapons_sounds.HeavyWeapons.rocket_launcher_shot1'
	PickupClass=Class'heavy_RocketLauncher_Pickup'
	AttachmentClass=Class'heavy_RocketLauncher_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.Rocket_Launcher_bricon'
	ItemName="Rocket Launcher"
	Mesh=SkeletalMesh'B9Weapons_models.BigRedGun_mesh'
}