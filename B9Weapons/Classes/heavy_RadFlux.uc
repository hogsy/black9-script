//=============================================================================
// heavy_RadFlux.uc
//
// Rail Gun heavy weapon
//
// 
//=============================================================================


class heavy_RadFlux extends B9HeavyWeapon;


simulated function PlayFiring()
{
	if( Instigator.IsLocallyControlled() )
	{
		FakeTrace();
	}

	Super.PlayFiring();
}  


simulated function float GetROF()
{
	return fROF;
}

//////////////////////////////////
// Initialization
//





defaultproperties
{
	fAmmoExpendedPerShot=1
	fROF=0.05
	fUniqueID=23
	fForceFeedbackEffectName="RadFluxFire"
	fStreamyWeapon=true
	fIniLookupName="RadFlux"
	AmmoName=Class'ammo_RadFlux'
	PickupAmmoCount=255
	ReloadCount=255
	TraceDist=6240
	MaxRange=6240
	fContinuous=true
	PickupClass=Class'heavy_RadFlux_Pickup'
	AttachmentClass=Class'heavy_RadFlux_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.gen_assault_rifle_bricon'
	ItemName="RadFlux"
	Mesh=SkeletalMesh'B9Weapons_models.RadFluxRifle_mesh'
}