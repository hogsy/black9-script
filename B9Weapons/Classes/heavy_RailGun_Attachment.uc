//=============================================================================
// heavy_RailGun_Attachment.uc
//
// Attachment for Heavy Machinegun weapon
//
// 
//=============================================================================


class heavy_RailGun_Attachment extends B9_WeaponAttachment;


//////////////////////////////////
// Functions
//

function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}


simulated function SpawnEffect()
{
	local vector		Start;
	local rotator		Rot;
	local Emitter		fx;

	GetEffectStart(Start,Rot);

	//fx = Spawn( class'RailGunTrail', Self, , Start, Rot );
	fx = Spawn( class'WeaponFX_RailGun', Self, , Start, Rot );

	BeamEmitter(fx.Emitters[0]).BeamEndPoints[0].Offset.X.Min=HitLoc.X;
	BeamEmitter(fx.Emitters[0]).BeamEndPoints[0].Offset.X.Max=HitLoc.X;
	BeamEmitter(fx.Emitters[0]).BeamEndPoints[0].Offset.Y.Min=HitLoc.Y;
	BeamEmitter(fx.Emitters[0]).BeamEndPoints[0].Offset.Y.Max=HitLoc.Y;
	BeamEmitter(fx.Emitters[0]).BeamEndPoints[0].Offset.Z.Min=HitLoc.Z;
	BeamEmitter(fx.Emitters[0]).BeamEndPoints[0].Offset.Z.Max=HitLoc.Z;

	BeamEmitter(fx.Emitters[0]).RotationNormal=HitLoc;
//	BeamEmitter(fx.Emitters[0]).BeamDistanceRange.Min = 10000;
//	BeamEmitter(fx.Emitters[0]).BeamDistanceRange.Max = 10000;

	spawn(class'B9FX.proj_TracerRound_TypeTwo',Instigator,,Start,rotator(HitLoc - Start));
}


simulated event ThirdPersonEffects()
{
	SpawnEffect();
	Super.ThirdPersonEffects();
}




//////////////////////////////////
// Initialization
//

defaultproperties
{
	fMuzzleOffset=(X=40,Y=-3,Z=9)
	FiringMode=MODE_Auto
	fAnimKind=3
	Mesh=SkeletalMesh'B9Weapons_models.RailGun_mesh'
}