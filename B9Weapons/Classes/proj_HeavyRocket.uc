

class proj_HeavyRocket extends B9ProjectileBase;


var	Emitter fTrail;


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Level.NetMode == NM_Client )
	{
		LifeSpan = 10.0;
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

simulated function PostNetBeginPlay()
{
	if ( fTrail == None )
	{
		fTrail = Spawn(class'fx_turretEXP_proj_trail', self);
	}
	SetTimer(0.1, false);
}


simulated function Destroyed()
{
	if( fTrail != None )
	{
		fTrail.Destroy();
		fTrail = None;
	}
	
	Super.Destroyed();
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	Super.HitWall( HitNormal, Wall );
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	BlowUp( HitLocation );
	if ( Level.NetMode != NM_DedicatedServer )
	{
  		spawn(class'ExplosionFX_Two_Emitter',,,HitLocation,rot(16384,0,0));
	}
 	Destroy();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	If ( Other != Instigator )
	{
		if ( Role == ROLE_Authority )
		{
			Other.TakeDamage( Damage, instigator, HitLocation, MomentumTransfer*Vector(Rotation), MyDamageType);	
		}
		
		Explode(HitLocation, vect(0,0,1));
	}
}

defaultproperties
{
	fIniLookupName="RocketLauncher"
	Speed=5000
	MaxSpeed=5000
	Damage=50
	MomentumTransfer=10000
	MyDamageType=Class'B9BasicTypes.damage_HeavyRocket'
	LifeSpan=10
	Mesh=SkeletalMesh'B9Weapons_models.Proj_RPG_mesh'
	SoundRadius=2
	SoundVolume=75
	CollisionRadius=22
	CollisionHeight=11
	bFixedRotationDir=true
	ForceType=1
	ForceRadius=100
	ForceScale=0.6
}