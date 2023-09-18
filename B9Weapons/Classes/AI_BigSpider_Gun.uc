//=============================================================================
// AI_BigSpider_Gun.uc
//
// BigSpider Gun
//
// 
//=============================================================================


class AI_BigSpider_Gun extends B9HeavyWeapon;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAmmoExpendedPerShot=1
	fROF=600
	fUniqueID=17
	fIniLookupName="BigSpiderGun"
	AmmoName=Class'ammo_BigSpiderGun'
	PickupAmmoCount=30
	ReloadCount=30
	TraceDist=6144
	MaxRange=6144
	FireSound=Sound'B9SoundFX.Bullet_Impacts.p9mm_fire'
	PickupClass=Class'AI_BigSpider_Gun_Pickup'
	AttachmentClass=Class'AI_BigSpider_Gun_Attachment'
	Icon=Texture'B9HUD_textures.Browser.BigRedGun_BrIcon_tex'
	ItemName="BigSpider Gun"
	DrawType=0
}