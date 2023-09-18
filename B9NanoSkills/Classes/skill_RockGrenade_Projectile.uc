//=============================================================================
// skill_RockGrenade_Projectile
//
// Main projectile. Spawns evil gravel that does the actual damage.
//
// 
//=============================================================================



class skill_RockGrenade_Projectile extends Projectile;



var bool	bCanHitOwner, bHitWater;
var float	FuseTime;
var float	BounceDamping;

simulated function PostBeginPlay()
{
	local rotator	RandRot;
	local Pawn		P;

	P = Pawn(Owner);


	Super.PostBeginPlay();

	SetTimer( FuseTime, false );
	if ( Role == ROLE_Authority )
	{
		Velocity		= GetTossVelocity( P, Rotation );
		bCanHitOwner	= false;

		if ( P.HeadVolume.bWaterVolume )
		{
			bHitWater	= true;
			Velocity	*= 0.6;
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
	if ( ( Other != Owner ) || bCanHitOwner )
	{
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
	if ( speed < 20 ) 
	{
		bBounce		= false;
		SetRotation( Rotator( HitNormal ) );
		SetPhysics( PHYS_None );
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	FireSubmunitions();
	Destroy();
}


function FireSubmunitions()
{
	local rotator Dir;
	local int submunition;
	local vector V;

	V = Location;
	V.Z += 10;

	for( submunition = 0; submunition < 25; submunition++ )
	{
		Dir.pitch	= Rand(65535);
		Dir.roll	= 0;
		Dir.yaw		= Rand(65535);
		
		Spawn( class'skill_RockGrenade_SubProjectile',,, Location,Dir );
	}
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
		Explode( Location, Location );
	}
}




defaultproperties
{
	FuseTime=2.5
	BounceDamping=0.65
	Speed=1100
	Damage=50
	DamageRadius=512
	MomentumTransfer=50000
	MyDamageType=Class'B9BasicTypes.damage_RockGrenade'
	Physics=2
	DrawType=8
	StaticMesh=StaticMesh'SC_MeshParticles.Rock.rock1'
	bBounce=true
}