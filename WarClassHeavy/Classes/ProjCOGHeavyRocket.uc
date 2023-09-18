// ====================================================================
//  Class:  WarClassHeavy.ProjCOGHeavyRocket
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class ProjCOGHeavyRocket extends Projectile;

#exec AUDIO IMPORT FILE="..\WarClassContent\Sounds\RocketLauncher\brufly1c.Wav" NAME=RocketFly1 GROUP="RocketLauncher"

#EXEC OBJ LOAD FILE=..\StaticMeshes\jm_heavydude_rockets.usx PACKAGE=jm_heavydude_rockets
#EXEC OBJ LOAD FILE=..\Textures\jm_manhatten_project.utx PACKAGE=jm_manhatten_project
								

var bool bRing,bHitWater,bWaterStart;
var int NumExtraRockets;

var	PclCOGRocketTrail trail;
var int MisslePosition;			// Used to determine the position of the missle

var Actor SeekTarget;
var vector InitialDir;

replication
{
	// Relationships.
	reliable if( Role==ROLE_Authority )
		SeekTarget, MisslePosition, InitialDir;
}


simulated function Timer()
{
	local vector SeekingDir;
	local float MagnitudeVel;

	SetTimer(0.1, true);
	
	if ( InitialDir == vect(0,0,0) )
		InitialDir = Normal(Velocity);

	if ( (SeekTarget != None) && (SeekTarget != Instigator) ) 
	{
		SeekingDir = Normal(SeekTarget.Location - Location);
		if ( (SeekingDir Dot InitialDir) > 0 )
		{
			MagnitudeVel = VSize(Velocity);
			SeekingDir = Normal(SeekingDir * 1 * MagnitudeVel + Velocity);
			Velocity =  MagnitudeVel * SeekingDir;	
			Acceleration = 25 * SeekingDir;	
			SetRotation(rotator(Velocity));
		}
	}
}

simulated function Destroyed()
{
	if ( Trail != None )
	{
		Trail.Emitters[0].AutomaticInitialSpawning=False;
		Trail.Emitters[0].RespawnDeadParticles=false;
		Trail.Emitters[1].AutomaticInitialSpawning=False;
		Trail.Emitters[1].RespawnDeadParticles=false;
		Trail.Emitters[1].ParticlesPerSecond=0;
		Trail.AutoReset=False;
		Trail.AutoDestroy=True;
	}
	
	Super.Destroyed();
}

simulated function PostNetBeginPlay()
{
	local vector Dir;

	Dir = vector(Rotation);
	Velocity = speed * Dir;
	Acceleration = Dir * 50;

	if ( (Pawn(Owner).IsLocallyControlled() ) || (ROLE!=ROLE_Authority) )
	{
		Trail = Spawn(class'PclCOGRocketTrail ',self);
		Trail.SetBase(Self);
	}
	
	if ( (LifeSpan<Default.LifeSpan-1) || (Owner==None) || (WarCogHeavy(Owner)==None) )
		return;
		
	// Tell the Pawn to animate
	
	if ( (MisslePosition & 0x01)==0x01 )
		WarCogHeavy(Owner).PlayFiring(1.0,'missleleft');
	else
		WarCogHeavy(Owner).PlayFiring(1.0,'missleright');
	
}

auto state Flying
{

	simulated function PhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if (!NewVolume.bWaterVolume || bHitWater) Return;

		bHitWater = True;
		if ( Level.NetMode != NM_DedicatedServer )
		{
			Spawn(class'WaterRing',,,,rot(16384,0,0));
		}		
		Velocity=0.6*Velocity;
	}

	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( (Other != instigator) && !Other.IsA('Projectile') ) 
			Explode(HitLocation,Normal(HitLocation-Other.Location));
	}

	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		spawn(class'PclRocketExplosion',,,HitLocation,rotator(HitNormal));	
		BlowUp(HitLocation);
 		Destroy();
	}

	function BeginState()
	{
		if ( PhysicsVolume.bWaterVolume )
		{
			bHitWater = True;
			Velocity=0.6*Velocity;
		}
		
		SetTimer(0.1, true);

	}
}

defaultproperties
{
	Speed=3000
	MaxSpeed=3500
	Damage=140
	DamageRadius=512
	MomentumTransfer=80000
	MyDamageType=Class'WarClassLight.WarDamageExplosion'
	SpawnSound=Sound'WarEffects.EightBall.Ignite'
	ImpactSound=Sound'WarEffects.EightBall.GrenadeFloor'
	ExplosionDecal=Class'WarClassLight.BlastMark'
	LightType=1
	LightEffect=13
	LightBrightness=255
	LightRadius=6
	LightHue=28
	DrawType=8
	StaticMesh=StaticMesh'jm_heavydude_rockets.boomstick.jm_coalition_rocket'
	bDynamicLight=true
	LifeSpan=6
	AmbientGlow=96
	SoundRadius=14
	SoundVolume=255
	SoundPitch=100
	bBounce=true
	bFixedRotationDir=true
	RotationRate=(Pitch=0,Yaw=0,Roll=65535)
}