//=============================================================================
// BlitDagger_Attachment.uc
//
// Attachment for BlitDagger weapon
//
// 
//=============================================================================


class BlitDagger_Attachment extends B9_WeaponAttachment;


//////////////////////////////////
// Functions
//

function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}


simulated function SpawnEffect()
{
	Super.SpawnEffect();
}


simulated event ThirdPersonEffects()
{
	Super.ThirdPersonEffects();
	      
	SpawnEffect();
}

//////////////////////////////////
// Initialization
//

defaultproperties
{
	fWeaponPose=2
	fIdleAmbientSound=Sound'B9Misc_Sounds.ElectrifiedFloor.floor_spark_loop1'
	fIdleAmbientSoundRadius=100
	fIdleAmbientSoundVolume=30
	fLightFXClass=Class'B9FX.LightFX_Tazer'
	FiringMode=MODE_Slash
	fAnimKind=4
	Mesh=SkeletalMesh'B9Weapons_models.BlitDagger_mesh'
}