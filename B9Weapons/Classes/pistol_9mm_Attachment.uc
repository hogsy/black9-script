//=============================================================================
// pistol_9mm_Attachment.uc
//
// Attachment for 9mm Pistol weapon
//
// 
//=============================================================================


class pistol_9mm_Attachment extends B9_WeaponAttachment;


//////////////////////////////////
// Functions
//

function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}

simulated function SpawnEffect()
{
	local vector Start;
	local rotator Rot;

	Super.SpawnEffect();

	if( FlashCount % 2 == 0 )
	{
		GetEffectStart(Start,Rot);
		spawn(class'B9FX.proj_TracerRound_TypeTwo',Instigator,,Start,rotator(HitLoc - Start));
	}
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
	fMuzzleClass=Class'B9FX.MuzzleFlashFX_VerySmall'
	fLightFXClass=Class'B9FX.LightFX_HeavyMachinegun'
	fCartridgeFXClass=Class'B9FX.EjectedBrass_A'
	FiringMode=MODE_Normal
	fAnimKind=1
	Mesh=SkeletalMesh'B9Weapons_models.9mm_pistol_mesh'
}