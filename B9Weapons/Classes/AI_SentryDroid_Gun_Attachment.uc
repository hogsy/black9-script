//=============================================================================
// AI_SentryDroid_Gun_Attachment.uc
//
// Attachment for 9mm Pistol weapon
//
// 
//=============================================================================


class AI_SentryDroid_Gun_Attachment extends B9_WeaponAttachment;


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
	fCartridgeFXOffset=(X=20,Y=20,Z=10)
	fMuzzleOffset=(X=0,Y=16,Z=8)
	fMuzzleRotationOffset=(Pitch=0,Yaw=32768,Roll=0)
	fLightFXClass=Class'B9FX.LightFX_HeavyMachinegun'
	fCartridgeFXClass=Class'B9FX.EjectedBrass_A'
	FiringMode=MODE_Normal
	fAnimKind=1
	Mesh=SkeletalMesh'B9Weapons_models.AutoPistol_mesh'
}