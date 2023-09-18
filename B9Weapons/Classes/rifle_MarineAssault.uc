//=============================================================================
// rifle_MarineAssault.uc
//
// Big Ass Assault Rifle just for Marine AIs
//
// 
//=============================================================================


class rifle_MarineAssault extends B9HeavyWeapon;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAmmoExpendedPerShot=1
	fROF=600
	fIniLookupName="MarineAssaultRifle"
	AmmoName=Class'ammo_AssaultRifle'
	PickupAmmoCount=30
	ReloadCount=30
	TraceDist=7020
	MaxRange=7020
	FireSound=Sound'B9SoundFX.Bullet_Impacts.p9mm_fire'
	PickupClass=Class'rifle_MarineAssault_Pickup'
	AttachmentClass=Class'rifle_MarineAssault_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.Assault_Rifle_bricon'
	ItemName="Marine Assault Rifle"
	Mesh=SkeletalMesh'B9Weapons_models.Marine_Gun_mesh'
}