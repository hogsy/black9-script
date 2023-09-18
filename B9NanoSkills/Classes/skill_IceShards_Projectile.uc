//=============================================================================
// skill_IceShards_Projectile
//
// Invisible projectile that is the real physical force behind the IceShards
//
// 
//=============================================================================



class skill_IceShards_Projectile extends NanoProjectile;


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
   log("Post Begin Play Called for Iceshard");
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

	If( Other != Owner )
	{
		if ( Role == ROLE_Authority )
		{
			dmg = Damage;
			Other.TakeDamage( dmg, instigator, HitLocation, MomentumTransfer*Vector(Rotation), MyDamageType);	
		}
		
		Explode(HitLocation, vect(0,0,1));
	}
}


defaultproperties
{
	Speed=1500
	MaxSpeed=1500
	Damage=75
	MomentumTransfer=10000
	MyDamageType=none
	LightType=1
	LightEffect=13
	LightBrightness=255
	LightRadius=6
	LightHue=28
	DrawType=8
	StaticMesh=StaticMesh'B9_Effects_meshes.Iceshock.iceshockA'
	bDynamicLight=true
	LifeSpan=20
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