//=============================================================================
// pistol_Tazer_Attachment.uc
//
// Attachment for Tazer Pistol weapon
//
// 
//=============================================================================


class pistol_Tazer_Attachment extends B9_WeaponAttachment;



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
	local TazerBeamFX Effect;

	GetEffectStart(Start,Rot);
	
	Effect = spawn(class'TazerBeamFX',Instigator,,Start,Rot );

	BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.X.Min=HitLoc.X;
	BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.X.Max=HitLoc.X;
	BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.Y.Min=HitLoc.Y;
	BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.Y.Max=HitLoc.Y;
	BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.Z.Min=HitLoc.Z;
	BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.Z.Max=HitLoc.Z;

	BeamEmitter(Effect.Emitters[0]).Disabled=false;
}

simulated event ThirdPersonEffects()
{
	if( bAutoFire )
	{
		SpawnEffect();			
	}

	Super.ThirdPersonEffects();
}



//////////////////////////////////
// Initialization
//


defaultproperties
{
	fMuzzleOffset=(X=20,Y=0,Z=2)
	FiringMode=MODE_Auto
	fAnimKind=4
	Mesh=SkeletalMesh'B9Weapons_models.StunGun_mesh'
}