//=============================================================================
// SwarmRocket.
//=============================================================================
class SwarmRocket extends Projectile;

#exec OBJ LOAD FILE=..\animations\B9Weapons_models.ukx PACKAGE=B9Weapons_models
#exec OBJ LOAD FILE=..\Sounds\B9SoundFX.uax PACKAGE=B9SoundFX

var bool bRing,bHitWater,bWaterStart;
var int NumExtraRockets;
var	SwarmRocketTrail trail;
//var	PclCOGLightPlasmaPrimary trail;
//var		PclGeistGrenadeLauncherRocket trail;
var smoketrail smoke;

// Missle logic
var Actor Seeking;
var vector InitialDir;
var vector DriftVector;
var float DriftTime;
var float Birth;


simulated function Destroyed()
{
	if ( Trail != None )
		Trail.Destroy();
	if ( Smoke != None )
		Smoke.FadeOut();
	Super.Destroyed();
}

function PostBeginPlay()
{
	local vector Dir;

	Dir = vector(Rotation);
	Velocity = speed * Dir;
	Acceleration = Dir * 50;
	if ( Instigator != None )
	{
		Seeking = Instigator.Controller.Target;
		DriftTime = VSize( Seeking.Location - Location ) * 0.0005;
		if ( DriftTime > 1.0 )
		{
			DriftTime = 1.0;
		}
	}
	else
	{
		DriftTime = 0.5;
	}
	Birth = Level.TimeSeconds;
	DriftVector.x = FRand() * 0.5 - 0.25;
	DriftVector.y = FRand() * 0.5 - 0.25;
	DriftVector.z = FRand() * 0.5 - 0.25;
	DriftVector = Normal(Dir + DriftVector);
	PostNetBeginPlay();
}

simulated function PostNetBeginPlay()
{
	if ( Trail == None )
	{
		Trail = Spawn(class'SwarmRocketTrail',self);
		//Trail.EMStartVelocity = -200 * Normal(Velocity);
		//Trail.EMCoreTextureLocationOffset = -10 * Normal(Velocity);
	}
	SetTimer(0.1, false);
}

simulated function Timer()
{
	local vector SeekingDir;
	local float MagnitudeVel;
	local float MaxTurn;
	local float TurnPercent;

	SetTimer(0.1, true);
	if ( Smoke == None )
	{
		Smoke = Spawn(class'SmokeTrail',self);
		//Smoke.EMStartVelocity = 200 * Normal(Velocity);
	}

	if ( InitialDir == vect(0,0,0) )
		InitialDir = Normal(Velocity);
		 
	if ( (Seeking != None) && (Seeking != Instigator) && Level.TimeSeconds - Birth > DriftTime ) 
	{
		SeekingDir = Normal(Seeking.Location - Location);
	}
	else
	{
		SeekingDir = DriftVector;
	}

	MaxTurn = 0.0125;
	MagnitudeVel = VSize(Velocity);
	Velocity /= MagnitudeVel;
	SeekingDir = Normal(SeekingDir);
	TurnPercent = SeekingDir Dot Velocity;
	if ( TurnPercent - 1 < -MaxTurn )
	{
		TurnPercent = MaxTurn / abs( TurnPercent - 1 );
	}
	else
	{
		TurnPercent = 1;
	}
	Velocity =  MagnitudeVel * ( SeekingDir * TurnPercent + Velocity * ( 1 - TurnPercent ) );	
	Acceleration = 25 * SeekingDir;	
	SetRotation(rotator(Velocity));
}

auto state Flying
{

	simulated function PhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		local waterring w;
		
		if (!NewVolume.bWaterVolume || bHitWater) Return;

		bHitWater = True;
		if ( Level.NetMode != NM_DedicatedServer )
		{
			w = Spawn(class'WaterRing',,,,rot(16384,0,0));
//			w.DrawScale = 0.2;
//			w.RemoteRole = ROLE_None;
			PlayAnim( 'Still', 3.0 );
		}		
		Velocity=0.6*Velocity;
	}

	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( (Other != instigator) && !Other.IsA('Projectile') ) 
			Explode(HitLocation,Normal(HitLocation-Other.Location));
	}

	function BlowUp(vector HitLocation)
	{
		HurtRadius(Damage,220.0, MyDamageType, MomentumTransfer, HitLocation );
		MakeNoise(1.0);
	}

	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		if( FRand() < 0.5f )
			PlaySound( sound'incoming_rocket_1a', SLOT_None, 1.0f, false );
		else
			PlaySound( sound'incoming_rocket_2a', SLOT_None, 1.0f, false );
		
		spawn(class'RocketExplosion',,,HitLocation + HitNormal*50,rotator(HitNormal));	
		BlowUp(HitLocation);
 		Destroy();
	}

	function BeginState()
	{
		PlayAnim( 'Idle', 0.2 );
		if ( PhysicsVolume.bWaterVolume )
		{
			bHitWater = True;
			Velocity=0.6*Velocity;
		}
	}
}

defaultproperties
{
	DriftTime=0.5
	Speed=900
	MaxSpeed=1600
	Damage=20
	MomentumTransfer=8000
	ExplosionDecal=Class'WarClassLight.BlastMark'
	LightType=1
	LightEffect=13
	LightBrightness=255
	LightRadius=6
	LightHue=28
	LifeSpan=60
	Mesh=SkeletalMesh'B9Weapons_models.Proj_DrunkMissile_mesh'
	AmbientGlow=96
	SoundRadius=14
	SoundVolume=255
	SoundPitch=100
	bBounce=true
	bFixedRotationDir=true
	RotationRate=(Pitch=0,Yaw=0,Roll=50000)
	DesiredRotation=(Pitch=0,Yaw=0,Roll=30000)
}