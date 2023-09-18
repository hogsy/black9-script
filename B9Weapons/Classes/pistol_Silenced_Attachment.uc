//=============================================================================
// pistol_Silenced_Attachment.uc
//
// Attachment for Silenced Pistol weapon
//
// 
//=============================================================================


class pistol_Silenced_Attachment extends B9_WeaponAttachment;



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
	fCartridgeFXClass=Class'B9FX.EjectedBrass_A'
	FiringMode=MODE_Normal
	fAnimKind=1
	Mesh=SkeletalMesh'B9Weapons_models.MagnumSilenced_mesh'
}