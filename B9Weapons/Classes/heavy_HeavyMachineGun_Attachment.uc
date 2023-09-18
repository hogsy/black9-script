//=============================================================================
// heavy_HeavyMachineGun_Attachment.uc
//
// Attachment for Heavy Machinegun weapon
//
// 
//=============================================================================


class heavy_HeavyMachineGun_Attachment extends B9_WeaponAttachment;




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
//	if( FlashCount % 3 == 0 )
//	{
		GetEffectStart(Start,Rot);
		spawn(class'B9FX.proj_TracerRound_TypeOne',Instigator,,Start,rotator(HitLoc - Start));
//	}
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
	fMuzzleOffset=(X=40,Y=0,Z=2)
	fMuzzleRotationOffset=(Pitch=0,Yaw=32768,Roll=0)
	fMuzzleClass=Class'B9FX.MuzzleFlashFX_Big'
	fLightFXClass=Class'B9FX.LightFX_HeavyMachinegun'
	fCartridgeFXClass=Class'B9FX.EjectedBrass_A'
	FiringMode=MODE_Auto
	fAnimKind=3
	Mesh=SkeletalMesh'B9Weapons_models.BigRedGun_mesh'
}