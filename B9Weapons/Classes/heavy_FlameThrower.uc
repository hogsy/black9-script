//=============================================================================
// heavy_FlameThrower.uc
//
// Rail Gun heavy weapon
//
// 
//=============================================================================


class heavy_FlameThrower extends B9HeavyWeapon;


//////////////////////////////////
// Functions
//

function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	AmmoType.AmmoAmount -= fAmmoExpendedPerShot;
}

function ProjectileFire()
{
}

simulated function float GetROF()
{
	return fROF;
}

simulated function PlayFiring()
{
	if( Instigator.IsLocallyControlled() )
	{
		FakeTrace();
	}

	Super.PlayFiring();
}  


//////////////////////////////////
// Initialization
//






defaultproperties
{
	fAmmoExpendedPerShot=1
	fROF=0.05
	fUniqueID=21
	fForceFeedbackEffectName="FlameThrowerFire"
	fStreamyWeapon=true
	fProjectileWeapon=true
	fIniLookupName="Flamethrower"
	AmmoName=Class'ammo_Flamethrower'
	PickupAmmoCount=255
	ReloadCount=255
	ShakeMag=0
	shaketime=0
	ShakeVert=(X=0,Y=0,Z=0)
	ShakeSpeed=(X=0,Y=0,Z=0)
	TraceDist=6144
	MaxRange=6144
	PickupClass=Class'heavy_FlameThrower_Pickup'
	AttachmentClass=Class'heavy_FlameThrower_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.FlameThrower_bricon'
	ItemName="Flamethrower"
	Mesh=SkeletalMesh'B9Weapons_models.flamethrower_mesh'
}