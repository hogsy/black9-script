//=============================================================================
// skill_RockShards_Projectile
//
// Invisible projectile that is the real physical force behind the RockShards
//
// 
//=============================================================================



class skill_RockGrenade_SubProjectile extends Projectile;


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Level.NetMode == NM_Client )
	{
		LifeSpan = 5.0;
	}
	else
	{
		Velocity = Speed * vector(Rotation);
	}

	if ( Level.bDropDetail )
	{
		LightType = LT_None;
		bDynamicLight = false;
	}
}

simulated function BlowUp(vector HitLocation)
{
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	Super.HitWall( HitNormal, Wall );
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	MakeNoise(1.0);

	if ( Level.NetMode != NM_DedicatedServer )
	{
  		spawn(class'B9_HeavyWallHitEffect',,,HitLocation,rot(16384,0,0));
	}
 	
	Destroy();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	local float dmg;
	
	if ( Role == ROLE_Authority )
	{
		dmg = Damage;
		Other.TakeDamage( dmg, instigator, HitLocation, MomentumTransfer*Vector(Rotation), MyDamageType);	
	}
	
	Explode(HitLocation, vect(0,0,1));
}


defaultproperties
{
	Speed=1000
	MaxSpeed=1000
	Damage=10
	MomentumTransfer=10000
	MyDamageType=Class'B9BasicTypes.damage_RockGrenade'
	DrawType=8
	StaticMesh=StaticMesh'SC_MeshParticles.Rock.Rock2'
	LifeSpan=0.5
	DrawScale=0.5
	AmbientGlow=96
	SoundRadius=2
	SoundVolume=75
	SoundPitch=100
	CollisionRadius=22
	CollisionHeight=11
	bFixedRotationDir=true
	ForceType=1
	ForceRadius=100
	ForceScale=0.6
}