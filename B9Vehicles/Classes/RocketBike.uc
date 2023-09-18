class RocketBike extends B9_Vehicle;

#exec OBJ LOAD FILE=..\staticmeshes\B9_Vehicle_meshes.usx Package=B9_Vehicle_meshes


var Vector lastLocation;

function PostBeginPlay()
{
	local vector	rotX, rotY, rotZ;


	Super.PostBeginPlay();

    GetAxes( Rotation, rotX, rotY, rotZ );

	fOperatorTrigger = Spawn( class'B9_VehicleTrigger', self, , Location + fOperatorTriggerOffset.X * RotX + fOperatorTriggerOffset.Y * RotY + fOperatorTriggerOffset.Z * RotZ );
	fOperatorTrigger.SetBase( Self );
	fOperatorTrigger.SetCollision( true, false, false );
	fOperatorTrigger.Set( 'nowpn_rocketsled_mount', 'nowpn_rocketsled_flying', 'nowpn_rocketsled_dismount', fOperatorTriggerOffset );

	// drop to the ground
	SetPhysics( PHYS_Falling );
}

function TryToDrive( Pawn p )
{
    if ( Driver == None )
	{        
		DriverEnter( p );
    }
}

event DriverEnter( Pawn p )
{
	Super.DriverEnter( p );
}

event DriverLeave()
{
	Super.DriverLeave();

	SetPhysics( PHYS_Falling );
}

simulated function HitWall( vector HitNormal, actor Wall )
{
//	Velocity	= 0.75 * ( ( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity );
/*
Velocity	= vect(0, 0, 0);
DriverLeave();
*/
}

event Landed(vector HitNormal)
{
	Super.Landed( HitNormal );
	//@@do damage here for hitting terrain
}
simulated function Tick( Float DeltaTime )
{
	local Actor		ground;
	local Vector	downLocation, hitLocation, hitNormal, hoverField;
	local Vector	repelVector;
	local float		repelTheta;
	local float		altitude;
	local float		cushion;
	local Rotator	turn;
	local float		turnTime;
	local Vector	thrust;
	local Vector	gravityVector;
	local bool		playingSequence;

	if ( Driver != none )
	{
		playingSequence	= fOperatorTrigger.PlayingSequence();

		if ( !playingSequence )
		{
			if ( Physics != Default.Physics )
			{
				SetPhysics( Default.Physics );
			}
		}
		else
		{
			Steering	= 0;
			Throttle	= -1;
		}

		turnTime		= fMax( DeltaTime, 1.0 );

		// turning
		turn		= Rotation;
		turn.Yaw	-= 16384 * DeltaTime * Steering;
		turn.Roll	= -8192 * Steering;
		if ( Abs( turn.Pitch ) > 1 )
		{
			turn.Pitch	+= -turn.Pitch * FClamp( DeltaTime, 0, 1 );
		}
		else
		{
			turn.Pitch	= 0;
		}

		SetRotation( turn );

		// speed
		if ( Throttle > 0 )
		{
			thrust		= ( vect( 1, 0, 0 ) * AirSpeed * Throttle * DeltaTime ) >> Rotation;
			Velocity	+= thrust;
		}
		else
		if ( Throttle < 0 )
		{
			Velocity	-= Velocity * 0.01;
		}

		if ( !playingSequence )
		{
			// hover
			gravityVector	= PhysicsVolume.Gravity;
			cushion			= 100 + 5;
			hoverField		= GetCollisionExtent();
			hoverField.z	-= 5;
			downLocation	= Location + vect( 0, 0, -1 ) * cushion;
			ground			= Trace( hitLocation, hitNormal, downLocation, Location, true, hoverField );
			if ( ground != None )
			{
				if ( VSize( hitNormal ) < 1 )
				{
					downLocation	= hitLocation * 1.5;
					ground			= Trace( hitLocation, hitNormal, ground.Location, Location, true );
					hitNormal		= Normal( Location - hitLocation );
				}
				altitude	= VSize( Location - hitLocation );
				altitude	= ( cushion - altitude ) / cushion;
				// might be colliding
				if ( altitude < 0 )
				{
					altitude	= 1;
				}
				Velocity	+= hitNormal * ( -Sqrt( 1 - altitude * altitude ) + 1 ) * VSize( gravityVector ) * DeltaTime * 10;
			}
		}
	}
}




defaultproperties
{
	fOperatorTriggerOffset=(X=-133.3,Y=-133.4,Z=-85)
	CamPos=(W=500,X=0,Y=0,Z=0)
	AirSpeed=800
	Physics=2
	DrawType=8
	StaticMesh=StaticMesh'B9_Vehicle_meshes.Genesis_rocket_sled.sled_chassis_luna'
	CollisionRadius=150
	CollisionHeight=85
}