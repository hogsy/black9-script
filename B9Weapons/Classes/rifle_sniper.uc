//=============================================================================
// rifle_sniper.uc
//
// 9mm Pistol weapon
//
// 
//=============================================================================


class rifle_sniper extends B9HeavyWeapon;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAmmoExpendedPerShot=1
	fReloadSound=Sound'B9Weapons_sounds.HeavyWeapons.reload_sniper'
	fHasScope=true
	fScopeMagnify=8
	fUniqueID=15
	fForceFeedbackEffectName="SniperFire"
	fIniLookupName="SniperRifle"
	AmmoName=Class'ammo_SniperRifle'
	PickupAmmoCount=4
	ReloadCount=1
	TraceDist=23400
	MaxRange=23400
	FireSound=Sound'B9Weapons_sounds.HeavyWeapons.sniper_fire2'
	PickupClass=Class'rifle_sniper_Pickup'
	AttachmentClass=Class'rifle_sniper_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.gen_assault_rifle_bricon'
	ItemName="Sniper Rifle"
	Mesh=SkeletalMesh'B9Weapons_models.SniperRifle_mesh'
}