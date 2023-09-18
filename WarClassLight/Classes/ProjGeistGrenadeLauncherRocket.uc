//=============================================================================
// ProjGeistGrenadeLauncherRocket.
//=============================================================================
class ProjGeistGrenadeLauncherRocket extends Projectile;

#exec MESH IMPORT MESH=UTRocket ANIVFILE=..\WarClassContent\MODELS\eightballrocket_a.3D DATAFILE=..\WarClassContent\MODELS\eightballrocket_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=UTRocket X=0 Y=-250 Z=-30 YAW=-64

#exec MESH SEQUENCE MESH=UTRocket SEQ=All       STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=UTRocket SEQ=Still     STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=UTRocket SEQ=Wing     STARTFRAME=1   NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JuRocket1 FILE=..\WarClassContent\MODELS\eightballrocket.PCX LODSET=2
#exec MESHMAP SCALE MESHMAP=UTRocket X=2.2 Y=2.2 Z=4.5 YAW=128
#exec MESHMAP SETTEXTURE MESHMAP=UTRocket NUM=1 TEXTURE=Jurocket1

#exec AUDIO IMPORT FILE="..\WarClassContent\Sounds\RocketLauncher\brufly1c.Wav" NAME=RocketFly1 GROUP="RocketLauncher"

var bool bRing,bHitWater,bWaterStart,bAutoDestroy;
var int NumExtraRockets;

var PclGeistGrenadeLauncherRocket ParticleFX;

simulated function Destroyed()
{
	if ( (ParticleFX != None) && !bAutoDestroy)
		ParticleFX.Destroy();
	Super.Destroyed();
}

function PostBeginPlay()
{
	local vector Dir;

	Dir = vector(Rotation);
	Velocity = speed * Dir;
	Acceleration = Dir * 50;
	if ( ParticleFX == None )
		ParticleFX = Spawn(class'PclGeistGrenadeLauncherRocket',self);
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
			PlayAnim( 'Still', 3.0 );
		}		
		Velocity=0.6*Velocity;
	}

	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		//if ( (Other != instigator) && !Other.IsA('Projectile') )
		If ( Other!=Instigator && PclGeistGrenadeLauncherRocket(Other)==None ) 
			Explode(HitLocation,Normal(HitLocation-Other.Location));
	}

	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		if ( !bAutoDestroy )
		{
			bAutoDestroy=true;

			// Enable explosion emitters.
			ParticleFX.Emitters[0].Disabled=False;
			ParticleFX.Emitters[1].Disabled=False;
			ParticleFX.Emitters[2].Disabled=False;
			ParticleFX.Emitters[3].Disabled=False;

			// Enable wood chips.
			ParticleFX.Emitters[4].Disabled=False;
			ParticleFX.Emitters[5].Disabled=False;

			// Set location (explosion)
			ParticleFX.Emitters[0].StartLocationOffset += HitLocation + 10 * HitNormal;
			ParticleFX.Emitters[1].StartLocationOffset += HitLocation + 10 * HitNormal;
			ParticleFX.Emitters[2].StartLocationOffset += HitLocation + 10 * HitNormal;
			ParticleFX.Emitters[3].StartLocationOffset += HitLocation + 10 * HitNormal;

			// Set location (wood chips)
			ParticleFX.Emitters[4].StartLocationOffset += HitLocation + 50 * HitNormal;
			ParticleFX.Emitters[5].StartLocationOffset += HitLocation + 50 * HitNormal;
		
			// Auto destroy emitter
			ParticleFX.AutoDestroy=true;
		
			LifeSpan = 2.0;

			//spawn(class'ExplosionParticles',,,HitLocation + HitNormal*50,rotator(HitNormal));	
			BlowUp(HitLocation);
 			Destroy();
		}
	}

	function BeginState()
	{
		PlayAnim( 'Wing', 0.2 );
		if ( PhysicsVolume.bWaterVolume )
		{
			bHitWater = True;
			Velocity=0.6*Velocity;
		}
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
	bDynamicLight=true
	AmbientSound=Sound'RocketLauncher.RocketFly1'
	LifeSpan=6
	Mesh=VertMesh'UTRocket'
	DrawScale=0.02
	AmbientGlow=96
	SoundRadius=14
	SoundVolume=255
	SoundPitch=100
	bBounce=true
	bFixedRotationDir=true
	RotationRate=(Pitch=0,Yaw=0,Roll=50000)
	DesiredRotation=(Pitch=0,Yaw=0,Roll=30000)
	ForceType=1
	ForceRadius=200
	ForceScale=1.5
}