//=============================================================================
// heavy_RadFlux_Attachment.uc
//
// Attachment for Heavy Machinegun weapon
//
// 
//=============================================================================


class heavy_RadFlux_Attachment extends B9_WeaponAttachment;


var float				fFireTimer;

//////////////////////////////////
// Functions
//

function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}


simulated function SpawnLocalEffect()
{
	local vector Start;
	local rotator Rot;
	local RadFluxFX Effect;


	if( Role < ROLE_Authority || Role == ROLE_Authority && !Instigator.IsLocallyControlled() )
	{
		GetEffectStart(Start,Rot);
		
		Effect = spawn(class'RadFluxFX',Instigator,,Start,Rot );
		
		BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.X.Min=HitLoc.X;
		BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.X.Max=HitLoc.X;
		BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.Y.Min=HitLoc.Y;
		BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.Y.Max=HitLoc.Y;
		BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.Z.Min=HitLoc.Z;
		BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.Z.Max=HitLoc.Z;
		
		BeamEmitter(Effect.Emitters[0]).Disabled=false;
	}
}

simulated function SpawnEffect()
{
	local vector Start;
	local rotator Rot;
	local RadFluxFX Effect;
	
	Super.SpawnEffect();


	if( Role == ROLE_Authority && Instigator.IsLocallyControlled() )
	{
		GetEffectStart(Start,Rot);
		
		Effect = spawn(class'RadFluxFX',Instigator,,Start,Rot );
		
		BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.X.Min=HitLoc.X;
		BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.X.Max=HitLoc.X;
		BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.Y.Min=HitLoc.Y;
		BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.Y.Max=HitLoc.Y;
		BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.Z.Min=HitLoc.Z;
		BeamEmitter(Effect.Emitters[0]).BeamEndPoints[0].Offset.Z.Max=HitLoc.Z;
		
		BeamEmitter(Effect.Emitters[0]).Disabled=false;
	}
}


simulated event ThirdPersonEffects()
{
	Super.ThirdPersonEffects();

	SpawnEffect();
}

simulated function Tick( float Delta )
{
	if( bAutoFire )
	{
		fFireTimer += Delta;
		if( fFireTimer >= 0.05 )
		{
			SpawnLocalEffect();
			fFireTimer=0.0;
		}
	}
}

//////////////////////////////////
// Initialization
//

defaultproperties
{
	fMuzzleOffset=(X=40,Y=0,Z=2)
	fFiringAmbientSound=Sound'WeaponSounds.Decapitator.decapFire'
	fFiringAmbientSoundRadius=400
	fFiringAmbientSoundVolume=200
	FiringMode=MODE_Auto
	fAnimKind=3
	Mesh=SkeletalMesh'B9Weapons_models.RadFluxRifle_mesh'
}