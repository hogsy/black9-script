// ====================================================================
//  Class:  WarClassLight.ProjPulseNormal
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class ProjPulseNormal extends Projectile;

var PclCOGPulseBeam ParticleFX;

simulated function Destroyed()
{
	if ( ParticleFX != None )
		ParticleFX.Destroy();
		
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.8, true);
	if ( Level.NetMode == NM_Client )
		LifeSpan = 2.0;
	else
		Velocity = Speed * vector(Rotation);
	if ( Level.bDropDetail )
	{
		LightType = LT_None;
		bDynamicLight = false;
	}

	if ( Level.NetMode != NM_DedicatedServer )
	{
		ParticleFX = Spawn(class'PclCOGPulseBeam',self);
	}
}

simulated function Timer()
{
	if ( Level.bDropDetail )
	{
		LightType = LT_None;
		bDynamicLight = false;
	}
	if ( (Physics == PHYS_None) && (LifeSpan > 0.5) )
		LifeSpan = 0.5;
}

simulated function Explode(vector HitLocation, vector HitNormal)
{

	SpawnEffect(none,HitLocation,HitNormal);
	Super.Explode(HitLocation, HitNormal);

}

simulated function SpawnEffect(actor Other, vector HitLocation, vector HitNormal)
{
	local PclCOGP9Hit Hit;

	Hit = spawn(class 'PclCOGP9hit',Other,,HitLocation + HitNormal,rotator(HitNormal));
	if (Other!=None)
		Hit.SetBase(Other);
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	local vector HitNormal;

	If ( Other!=Instigator )
	{
		if ( Role == ROLE_Authority )
			Other.TakeDamage( Damage, instigator, HitLocation, MomentumTransfer*Vector(Rotation), MyDamageType);

		// Spawn the effect		

		HitNormal = Normal(HitLocation-Other.Location);
		SpawnEffect(Other,HitLocation,HitNormal);
		Destroy();
	}
}

auto State Flying
{
Begin:
	LifeSpan = 2.0;
}

defaultproperties
{
	Speed=5000
	MaxSpeed=65000
	Damage=15
	MomentumTransfer=10000
	MyDamageType=Class'WarDamageEnergy'
	ExplosionDecal=Class'BoltScorch'
	ExploWallOut=10
	LifeSpan=0.5
	SoundRadius=10
	SoundVolume=218
	bFixedRotationDir=true
	ForceType=1
	ForceRadius=100
	ForceScale=0.6
}