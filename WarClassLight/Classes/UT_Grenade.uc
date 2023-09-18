//=============================================================================
// Grenade.
//=============================================================================
class UT_Grenade extends Projectile;

#exec MESH IMPORT MESH=UTGrenade ANIVFILE=..\WarClassContent\MODELS\eightballrocket_a.3D DATAFILE=..\WarClassContent\MODELS\eightballrocket_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=UTGrenade X=0 Y=0 Z=0 YAW=-64

#exec MESH SEQUENCE MESH=UTGrenade SEQ=All       STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=UTGrenade SEQ=WingIn    STARTFRAME=0   NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JuRocket1 FILE=..\WarClassContent\MODELS\eightballRocket.PCX
#exec MESHMAP SCALE MESHMAP=UTGrenade X=2.2 Y=2.2 Z=4.3 YAW=128
#exec MESHMAP SETTEXTURE MESHMAP=UTGrenade NUM=1 TEXTURE=JuRocket1

var bool bCanHitOwner, bHitWater;
var float Count, SmokeRate;

simulated function PostBeginPlay()
{
	local vector X,Y,Z;

	Super.PostBeginPlay();
	if ( Level.NetMode != NM_DedicatedServer )
		PlayAnim('WingIn');
	SetTimer(2.5+FRand()*0.5,false);                  //Grenade begins unarmed

	if ( Role == ROLE_Authority )
	{
		GetAxes(Instigator.GetViewRotation(),X,Y,Z);	
		Velocity = X * (Instigator.Velocity Dot X)*0.4 + Vector(Rotation) * (Speed +
			FRand() * 100);
		Velocity.z += 210;
		MaxSpeed = 1000;
		RandSpin(50000);	
		bCanHitOwner = False;
		if ( Instigator.HeadVolume.bWaterVolume )
		{
			bHitWater = True;
			Velocity=0.6*Velocity;			
		}
	}	
}

simulated function BeginPlay()
{
	if ( (Level.DetailMode != DM_Low) && !Level.bDropDetail ) 
		SmokeRate = 0.03;
	else 
		SmokeRate = 0.15;
}

simulated function PhysicsVolumeChange( PhysicsVolume NewVolume )
{
	if ( !NewVolume.bWaterVolume || bHitWater ) 
		return;

	bHitWater = True;
	Spawn(class'WaterRing',,,,rot(16384,0,0));
	Velocity=0.6*Velocity;
}

simulated function Timer()
{
	Explosion(Location+Vect(0,0,1)*16);
}

simulated function Tick(float DeltaTime)
{
	local UT_BlackSmoke b;

	if ( bHitWater || Level.bDropDetail ) 
	{
		Disable('Tick');
		Return;
	}
	Count += DeltaTime;
	if ( (Count>Frand()*SmokeRate+SmokeRate) && (Level.NetMode!=NM_DedicatedServer) ) 
	{
		b = Spawn(class'UT_BlackSmoke');
		b.RemoteRole = ROLE_None;		
		Count=0;
	}
}

simulated function Landed( vector HitNormal )
{
	HitWall( HitNormal, None );
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
	if ( (Other!=instigator) || bCanHitOwner )
		Explosion(HitLocation);
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	bCanHitOwner = True;
	Velocity = 0.75*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
	RandSpin(100000);
	speed = VSize(Velocity);
	if ( Level.NetMode != NM_DedicatedServer )
		PlaySound(ImpactSound, SLOT_Misc, 1.5,,150,,true);
	if ( Velocity.Z > 400 )
		Velocity.Z = 0.5 * (400 + Velocity.Z);	
	else if ( speed < 20 ) 
	{
		bBounce = False;
		SetPhysics(PHYS_None);
	}
}

simulated function Explosion(vector HitLocation)
{
	BlowUp(HitLocation);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		spawn(class'BlastMark',,,,rot(16384,0,0));
  		spawn(class'ExplosionParticles',,,HitLocation,rot(16384,0,0));
	}
 	Destroy();
}

defaultproperties
{
	Speed=600
	MaxSpeed=1000
	Damage=120
	MomentumTransfer=50000
	MyDamageType=Class'Exploded'
	ImpactSound=Sound'WarEffects.EightBall.GrenadeFloor'
	ExplosionDecal=Class'BlastMark'
	Physics=2
	Mesh=VertMesh'UTGrenade'
	DrawScale=0.02
	AmbientGlow=64
	bBounce=true
	bFixedRotationDir=true
	DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
}