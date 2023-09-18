//=============================================================================
// BlitSword_Attachment.uc
//
// Attachment for BlitSword weapon
//
// 
//=============================================================================


class BlitSword_Attachment extends B9_WeaponAttachment;


var BlitSwordFX			fFX;
var FX_Dummy_Position	fDummyPos;

//////////////////////////////////
// Functions
//

function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	
	if( fDummyPos == None )
	{
		fDummyPos		= Spawn( class'FX_Dummy_Position', Self, , Location, Rotation );
		fDummyPos.Tag	= 'BlitSwordFXPoint';
	}
	AttachToBone(fDummyPos, 'EmitterEnd');


	if( fFX == None )
	{
		fFX		= Spawn( class'BlitSwordFX', Self, , Location, Rotation );
	}
	AttachToBone(fFX, 'EmitterStart');
}


simulated function SpawnEffect()
{
}


simulated event ThirdPersonEffects()
{
	Super.ThirdPersonEffects();
}

event Destroyed()
{
	if( fFX != None )
	{
		fFX.Destroy();
	}
	if( fDummyPos != None )
	{
		fDummyPos.Destroy();
	}

	Super.Destroyed();
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
	Mesh=SkeletalMesh'B9Weapons_models.Blit_Sword_mesh'
}