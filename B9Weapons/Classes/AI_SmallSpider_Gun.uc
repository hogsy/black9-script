//=============================================================================
// AI_SmallSpider_Gun.uc
//
// SmallSpider Gun
//
// 
//=============================================================================


class AI_SmallSpider_Gun extends B9HeavyWeapon;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAmmoExpendedPerShot=1
	fROF=600
	fNoiseLevel=0.5
	fUniqueID=17
	fIniLookupName="SmallSpiderGun"
	AmmoName=Class'ammo_SpiderBotGun'
	PickupAmmoCount=30
	ReloadCount=30
	TraceDist=6144
	MaxRange=6144
	FireSound=Sound'B9GenesisCharacters_sounds.SmallSpiderBot.recluse_gun_shot1'
	PickupClass=Class'AI_SmallSpider_Gun_Pickup'
	AttachmentClass=Class'AI_SmallSpider_Gun_Attachment'
	Icon=Texture'B9HUD_textures.Browser.BigRedGun_BrIcon_tex'
	ItemName="SmallSpider Gun"
	DrawType=0
}