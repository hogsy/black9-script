//=============================================================================
// AI_Intimidator_Gun.uc
//
// Intimidator Gun
//
// 
//=============================================================================


class AI_Intimidator_Gun extends B9HeavyWeapon;
// THIS IS VERY DIFFERENT FROM OTHER GUNS, IF THE AI_Intimidator_Gun seems too accurate, change the aimerror varible
// back to its original value 550 which is doubled in game because it is a trace weapon!
// MFH

//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAmmoExpendedPerShot=1
	fROF=1
	fNoiseLevel=111
	fFireSoundVolumeLevel=500
	fFireSoundRadius=1500
	fUniqueID=17
	fIniLookupName="IntimidatorGun"
	AmmoName=Class'ammo_IntimidatorGun'
	PickupAmmoCount=30
	ReloadCount=30
	aimerror=100
	TraceDist=6144
	MaxRange=6144
	FireSound=Sound'B9GenesisCharacters_sounds.Intimidator.intimidator_gun_shot1'
	PickupClass=Class'AI_Intimidator_Gun_Pickup'
	AttachmentClass=Class'AI_Intimidator_Gun_Attachment'
	Icon=Texture'B9HUD_textures.Browser.BigRedGun_BrIcon_tex'
	ItemName="Intimidator Gun"
	DrawType=0
}