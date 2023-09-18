//=============================================================================
// Tazer_Attachment.uc
//
// Attachment for Tazer weapon
//
// 
//=============================================================================


class Tazer_Attachment extends B9_WeaponAttachment;


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
	fMuzzleOffset=(X=0,Y=16,Z=8)
	fMuzzleRotationOffset=(Pitch=0,Yaw=32768,Roll=0)
	fMuzzleClass=Class'B9FX.MuzzleFlashFX_VerySmall'
	fLightFXClass=Class'B9FX.LightFX_Tazer'
	FiringMode=MODE_Slash
	fAnimKind=4
	DrawType=8
}