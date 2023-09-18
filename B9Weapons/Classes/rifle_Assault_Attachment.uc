//=============================================================================
// rifle_Assault_Attachment.uc
//
// Attachment for Assault Rifle weapon
//
// 
//=============================================================================


class rifle_Assault_Attachment extends B9_WeaponAttachment;




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

	// Tracers
	//
	if( FlashCount % 2 == 0 )
	{
		GetEffectStart(Start,Rot);
		spawn(class'B9FX.proj_TracerRound_TypeOne',Instigator,,Start,rotator(HitLoc - Start));
	}
}


simulated event ThirdPersonEffects()
{
	Super.ThirdPersonEffects();
	      
	SpawnEffect();
}

simulated function name GetMuzzleSocketName()
{
	return 'Muzzle';
}

//////////////////////////////////
// Initialization
//

defaultproperties
{
	fCartridgeFXOffset=(X=20,Y=20,Z=10)
	fMuzzleOffset=(X=40,Y=0,Z=2)
	fMuzzleRotationOffset=(Pitch=0,Yaw=32768,Roll=0)
	fMuzzleClass=Class'B9FX.MuzzleFlashFX_Medium'
	fLightFXClass=Class'B9FX.LightFX_HeavyMachinegun'
	fCartridgeFXClass=Class'B9FX.EjectedBrass_A'
	FiringMode=MODE_Auto
	fAnimKind=3
	Mesh=SkeletalMesh'B9Weapons_models.AssaultRifle_mesh'
}