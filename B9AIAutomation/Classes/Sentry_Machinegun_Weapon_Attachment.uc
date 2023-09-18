//=============================================================================
// Sentry_Machinegun_Weapon_Attachment.uc
//
// Attachment for Sentry_Machinegun
// 
//=============================================================================


class Sentry_Machinegun_Weapon_Attachment extends B9_SentryWeaponAttachment;




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
	local emitter fx;

	Super.SpawnEffect();

	fx = spawn(class'B9FX.WeaponFX_SentryMachinegun',Instigator,,Location,Rotation);
	if( fx != None && fReferenceActor != None )
	{
		fReferenceActor.AttachToBone( fx, fAttachmentBone );
	}
	
//	if( FlashCount % 2 == 0 )
//	{
		spawn(class'B9FX.proj_TracerRound_TypeOne',Instigator,,Location,Rotation);
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
	fLightFXClass=Class'B9FX.LightFX_HeavyMachinegun'
	fCartridgeFXClass=Class'B9FX.EjectedBrass_A'
	FiringMode=MODE_Auto
	DrawType=8
}