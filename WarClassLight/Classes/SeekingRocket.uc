//=============================================================================
// SeekingRocket.
//=============================================================================
class SeekingRocket extends Projectile;

#exec AUDIO IMPORT FILE="..\WarClassContent\Sounds\RocketLauncher\brufly1c.Wav" NAME=RocketFly1 GROUP="RocketLauncher"

#EXEC OBJ LOAD FILE=..\StaticMeshes\jm_heavydude_rockets.usx PACKAGE=jm_heavydude_rockets
#EXEC OBJ LOAD FILE=..\Textures\jm_manhatten_project.utx PACKAGE=jm_manhatten_project

var Actor Seeking;
var vector InitialDir;
var bool bRing,bHitWater,bWaterStart;
var int NumExtraRockets;
var	PclCOGRocketTrail trail;

replication
{
	// Relationships.
	reliable if( Role==ROLE_Authority )
		Seeking, InitialDir;
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
	Trail = Spawn(class'PclCOGRocketTrail ',self);
	Trail.SetBase(Self);
}

simulated function Timer()
{
	local vector SeekingDir;
	local float MagnitudeVel;

	SetTimer(0.1, true);
	if ( InitialDir == vect(0,0,0) )
		InitialDir = Normal(Velocity);
		 
	if ( (Seeking != None) && (Seeking != Instigator) ) 
	{
		SeekingDir = Normal(Seeking.Location - Location);
		if ( (SeekingDir Dot InitialDir) > 0 )
		{
			MagnitudeVel = VSize(Velocity);
			SeekingDir = Normal(SeekingDir * 0.5 * MagnitudeVel + Velocity);
			Velocity =  MagnitudeVel * SeekingDir;	
			Acceleration = 25 * SeekingDir;	
			SetRotation(rotator(Velocity));
		}
	}
	if ( bHitWater || (Level.NetMode == NM_DedicatedServer) )
		Return;
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
		spawn(class'PclCOGRocketReallyBigExplosion',,,HitLocation + HitNormal*50,rotator(HitNormal));	
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
	Speed=900
	MaxSpeed=1600
	Damage=140
	MomentumTransfer=80000
	MyDamageType=Class'Exploded'
	SpawnSound=Sound'WarEffects.EightBall.Ignite'
	ExplosionDecal=Class'BlastMark'
	LightType=1
	LightEffect=13
	LightBrightness=255
	LightRadius=6
	LightHue=28
	DrawType=8
	StaticMesh=StaticMesh'jm_heavydude_rockets.boomstick.jm_coalition_rocket'
	bDynamicLight=true
	AmbientSound=Sound'RocketLauncher.RocketFly1'
	LifeSpan=10
	AmbientGlow=96
	SoundRadius=14
	SoundVolume=255
	SoundPitch=100
	bBounce=true
	bFixedRotationDir=true
	RotationRate=(Pitch=0,Yaw=0,Roll=65535)
}