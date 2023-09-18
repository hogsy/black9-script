//=============================================================================
// Grenade.
//=============================================================================
class B9_TossedGrenade extends Projectile;

#EXEC OBJ LOAD FILE=..\StaticMeshes\B9_Weapons_meshes.usx PACKAGE=B9_Weapons_meshes

var bool bHitWater;
var PclCOGGrenadeSmoke Tail;

simulated function PostBeginPlay()
{
	local rotator RandRot;

	Super.PostBeginPlay();
	SetTimer(2.5+FRand()*0.5,false);                  //Grenade begins unarmed
	if ( Role == ROLE_Authority )
	{
		Velocity = GetTossVelocity(Instigator, Rotation);
		RandSpin(35000);	
		if ( Instigator.HeadVolume.bWaterVolume )
		{
			bHitWater = True;
			Velocity *= 0.6;			
		}
	}	
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	Tail = Spawn(class'PclCOGGrenadeSmoke',self);
	Tail.SetBase(Self);
	Tail.Emitters[1].Disabled=true;
}

simulated function Destroyed()
{
	if ( Tail != None )
	{
		Tail.Emitters[0].AutomaticInitialSpawning=False;
		Tail.Emitters[0].RespawnDeadParticles=false;
		Tail.Emitters[1].AutomaticInitialSpawning=False;
		Tail.Emitters[1].RespawnDeadParticles=false;
		Tail.Emitters[1].ParticlesPerSecond=0;
		Tail.AutoReset=False;
		Tail.AutoDestroy=True;
	}
	
	Super.Destroyed();
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
	Explode(Location+Vect(0,0,1)*16, vect(0,0,1));
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	BlowUp(HitLocation);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		spawn(class'BlastMark',,,,rot(16384,0,0));
  		spawn(class'PclCOGRocketReallyBigExplosion',,,HitLocation,rot(16384,0,0));
	}
 	Destroy();
}

defaultproperties
{
	Speed=1100
	Damage=50
	DamageRadius=512
	MomentumTransfer=50000
	MyDamageType=Class'WarClassLight.WarDamageExplosion'
	ImpactSound=Sound'B9Weapons_sounds.explosives.grenade_bounce1'
	ExplosionDecal=Class'WarClassLight.BlastMark'
	Physics=2
	DrawType=8
	AmbientGlow=64
	bBounce=true
}