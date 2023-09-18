//=============================================================================
// Crossbow.uc
//
// Crossbow
//
// 
//=============================================================================


class Crossbow extends B9LightWeapon;



function ProjectileFire()
{
	Log("Crossbow.ProjectileFile");
	Super.ProjectileFire();
}


//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAmmoExpendedPerShot=1
	fUniqueID=24
	fForceFeedbackEffectName="CrossbowFire"
	fIniLookupName="Crossbow"
	AmmoName=Class'ammo_CrossbowBolt'
	PickupAmmoCount=20
	ReloadCount=1
	AutoSwitchPriority=9
	FireSound=Sound'B9SoundFX.Weapon.wep_MT'
	InventoryGroup=9
	PickupClass=Class'Crossbow_Pickup'
	AttachmentClass=Class'Crossbow_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.Crossbow_bricon'
	ItemName="Crossbow"
	Mesh=SkeletalMesh'B9Weapons_models.Crossbow_mesh'
}