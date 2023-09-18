//=============================================================================
// pistol_SMG.uc
//
// SMG Pistol weapon
//
// 
//=============================================================================


class pistol_SMG extends B9LightWeapon;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAmmoExpendedPerShot=1
	fROF=600
	fReloadSound=Sound'B9Weapons_sounds.Firearms.reload_uzi'
	fUniqueID=12
	fForceFeedbackEffectName="SMGFire"
	fIniLookupName="SMG"
	AmmoName=Class'ammo_SMG'
	PickupAmmoCount=30
	ReloadCount=30
	bRapidFire=true
	TraceDist=3510
	MaxRange=3510
	FireSound=Sound'B9Weapons_sounds.Firearms.uzi_shot1'
	InventoryGroup=2
	PickupClass=Class'pistol_SMG_Pickup'
	AttachmentClass=Class'pistol_SMG_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.gen_SMG_bricon'
	ItemName="Sub-Machinegun"
	Mesh=SkeletalMesh'B9Weapons_models.SMG_mesh'
}