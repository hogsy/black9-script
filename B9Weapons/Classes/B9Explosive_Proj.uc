class B9Explosive_Proj extends B9ProjectileBase;

#EXEC OBJ LOAD FILE=..\StaticMeshes\B9_Weapons_meshes.usx PACKAGE=B9_Weapons_meshes

var bool	bCanHitOwner, bHitWater;
var float	FuseTime;
var float	BounceDamping;

simulated function PostBeginPlay()
{
	local rotator	RandRot;


	Super.PostBeginPlay();

	SetTimer( FuseTime, false );
	if ( Role == ROLE_Authority )
	{
		if ( Instigator != None )
		{
			Velocity		= GetTossVelocity( Instigator, Rotation );
			fRandomSpin		= 500000;
			bCanHitOwner	= false;

			if ( Instigator.HeadVolume.bWaterVolume )
			{
				bHitWater	= true;
				Velocity	*= 0.6;
			}
		}
		// if this is being placed, then ther is no Instigator; move backwards until we hit something
		if ( Instigator == None )
		{
			Velocity	= vect( -5000, 0, 0 );
		}
	}
}

simulated function PhysicsVolumeChange( PhysicsVolume NewVolume )
{
	if ( !NewVolume.bWaterVolume || bHitWater ) 
		return;

	bHitWater = true;
	Spawn(class'WaterRing',,,,rot(16384,0,0));
	Velocity=0.6*Velocity;
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
	if ( ( Other != instigator ) || bCanHitOwner )
	{
		Velocity.Z	*= 0.5;
		HitWall( Normal( Velocity ), None );
	}
}

simulated function Landed( vector HitNormal )
{
	HitWall( HitNormal, None );
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	bCanHitOwner	= true;
	Velocity		= BounceDamping * ( ( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity );   // Reflect off Wall w/damping
	RandSpin( 10 );
	speed	= VSize( Velocity );
	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlaySound( ImpactSound, SLOT_Misc, 1.5, , 150, , true );
	}
	if ( Velocity.Z > 400 )
	{
		Velocity.Z	= 0.5 * ( 400 + Velocity.Z );
	}
	else
	if ( speed < 100 ) 
	{
		bBounce		= false;
		SetRotation( Rotator( HitNormal ) );
		SetPhysics( PHYS_None );
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	BlowUp( HitLocation );
	if ( Level.NetMode != NM_DedicatedServer )
	{
//		spawn(ExplosionDecal,,,,rot(16384,0,0));
  		spawn(class'ExplosionFX_One',,,HitLocation,rot(16384,0,0));
	}
 	Destroy();
}

simulated function Detonate()
{
	Explode( Location + Vect( 0, 0, 1 ) * 16, vect( 0, 0, 1 ) );
}

// This doesn't matter unless subclass makes itself block actors/players [ SetCollision(true, true, true) ],
event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	//Log("TakeDamage "$self$" "$Damage);
	if (Damage > 0)
		Detonate();
}

auto state Safe
{
	simulated function Timer()
	{
		GotoState( 'Armed' );
	}
}

state Armed
{
	function BeginState()
	{
		Detonate();
	}
}




defaultproperties
{
	FuseTime=2.5
	BounceDamping=0.05
	Speed=1100
	Damage=50
	DamageRadius=512
	MomentumTransfer=50000
	MyDamageType=Class'WarClassLight.WarDamageExplosion'
	ImpactSound=Sound'WarEffects.EightBall.GrenadeFloor'
	ExplosionDecal=Class'WarClassLight.BlastMark'
	Physics=2
	DrawType=8
	AmbientGlow=64
	CollisionRadius=20
	CollisionHeight=20
	bBounce=true
}