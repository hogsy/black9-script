class Explosive_Mine_Trip_Proj extends B9Explosive_Proj
	placeable;


var TriggerBeam	Beam;
var float		BeamRange;


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	// no Instigator if placed in map with editor
	if ( Instigator == None )
	{
		Velocity	= vect( -500, 0, 0 ) >> Rotation;
	}
}

simulated function HitWall( vector HitNormal, actor Wall )
{
log("Hit Wall^^^^^^^^^^^^^^^^^^^^^^^^^^ " $ Wall );

	if( Wall.IsA( 'Pawn' ) == False )
	{
		// stick to this object
		Velocity	= vect( 0, 0, 0 );
		Super.HitWall( HitNormal, Wall );

		SetCollisionSize(40.0f, 15.0f);

		if (Beam == None)
		{
			Beam	= spawn( class'TriggerBeam', self, , Location, Rotation );
			if ( Beam != None )
			{
				Beam.Safe( BeamRange );
			}
		}

		GotoState( 'Safe' );
	}
	else	//hit a player so bounce off
	{
		Velocity = 0.6 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
		Velocity.Z = FMin(Velocity.Z * 0.6, 700);
		speed = VSize(Velocity * 0.6 );
	}
}

function Detonate()
{
	if ( Beam != None )
	{
		Beam.Destroy();
	}

	Super.Detonate();
}

auto state Placing
{
	function Timer()
	{
		// if still placing ( dropping ), just blow up
		Detonate();
	}
}

auto state Safe
{
	function BeginState()
	{
		SetTimer( FuseTime, false );
		SetCollision(true, true, true);
		SetCollisionSize(3.0f, 3.0f);
	}

	function Timer()
	{
		if ( Beam != None )
		{
			Beam.Armed();
		}
		GotoState( 'Armed' );
	}
}

state Armed
{
	function BeginState()
	{
		// wait for trigger
	}

	event Bump( actor Other )
	{
		Detonate();
	}

	function Tick( float Delta )
	{
		if ( ( Beam != None ) && ( Beam.Triggered ) )
		{
			Detonate();
		}
	}
}




defaultproperties
{
	BeamRange=10000
	fIniLookupName="TripMine"
	DrawType=2
	Mesh=SkeletalMesh'B9Weapons_models.LaserTripBomb_mesh'
}