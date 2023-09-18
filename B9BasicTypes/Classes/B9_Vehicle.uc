class B9_Vehicle extends Vehicle;



var	Pawn				Driver;

var (B9_Vehicle) float	Steering; // between -1 and 1
var (B9_Vehicle) float	Throttle; // between -1 and 1

var (B9_Vehicle) bool	bLookSteer;		// Indicates how if vehicle should steer towards where you are looking,
var (B9_Vehicle) float	LookSteerSens;	// Sensitivity of steering as you look left around

// trigger used to operate the vehicle
var const vector		fOperatorTriggerOffset;
var B9_VehicleTrigger	fOperatorTrigger;


var (B9_Vehicle) int      CamPosIndex;  // Current viewpoint in this vehicle (see arrays below).
                                      // Can't use bBehindView because we always want to render the vehicle.
var (B9_Vehicle) const    plane    CamPos[4];    // set of viewpoints around the car. 
                                      // (x,y,z) represesnts camera position in vehicle space.
                                      // w represents distance to orbit about that point.




function Use()
{
	if ( Driver != None )
	{
		Throttle	= 0;
	    Steering	= 0;

		fOperatorTrigger.UsedBy( Driver );
	}
}

function PreSequence( Pawn user )
{
}

function PostSequence( Pawn user )
{
}

event EncroachedBy( Actor Other )
{
}

// possible interactions
function int GetHUDActions( Pawn other )
{
	local int	HUDActions;


	if ( Driver != None )
	{
		// only attackable if driven by an enemy
		if ( Driver != other )
		{
			if ( Driver.Controller != None )
			{
				if ( Driver.Controller.AttitudeTo( other ) < ATTITUDE_Ignore )
				{
					HUDActions	= HUDActions | kHUDAction_Attack;
				}
			}
		}
	}
	else
	{
		HUDActions	= HUDActions | kHUDAction_Use | kHUDAction_Attack;
	}

	return HUDActions;
}

// relative location to display interaction info
function vector GetHUDActionLocation()
{
	if ( Driver != None )
	{
		return Super.GetHUDActionLocation();
	}

	return Location + fOperatorTriggerOffset;
}

event DriverEnter( Pawn p )
{
	local PlayerController	pc;


	// Set pawns current controller to control the vehicle pawn instead
	Driver	= p;

	pc	= PlayerController( p.Controller );
	pc.Unpossess();
	pc.Possess( Self );

	// Change controller state to driver
    pc.GotoState( 'PlayerDriving' );

	// Move the driver into position, and attach to car.
	Driver.SetCollision( false, false, false );
	Driver.bCollideWorld		= false;
	Driver.bPhysicsAnimUpdate	= false;
	Driver.Velocity				= vect( 0, 0, 0 );
	Driver.SetPhysics( PHYS_None );
	Driver.SetBase( Self );
}

event DriverLeave()
{
	local PlayerController	pc;
	local Actor				hitActor;
	local vector			hitLocation;
	local vector			hitNormal;


	// Do nothing if we're not being driven
	if ( Driver == None )
	{
		return;
	}

	// Set the vehicle controller to now control the player
	pc	= PlayerController( Controller );
	pc.Unpossess();
	pc.Possess( Driver );

	// Place the driver outside the car
	Driver.PlayWaiting();
	Driver.bPhysicsAnimUpdate	= Driver.Default.bPhysicsAnimUpdate;

    Driver.Acceleration	= vect( 0, 0, 24000 );
	Driver.SetPhysics( PHYS_Falling );
	Driver.SetBase( None );
	Driver.bCollideWorld	= true;
	Driver.SetCollision( true, true, true );

	// try to ensure the Driver is far enough away from the vehicle and ground
	hitActor	= Driver;// just to get loop started
	while ( HitActor != None )
	{
		hitActor	= Driver.Trace( hitLocation, hitNormal, Driver.Location, Driver.Location + vect( 0, 0, 1 ) * Driver.CollisionHeight * 2, true, Driver.GetCollisionExtent() );
		if ( hitActor != None )
		{
			if ( VSize( hitNormal ) < 1 )
			{
				hitNormal	= vect( 0, 0, 1 );
			}
			Driver.SetLocation( Driver.Location + hitNormal * 2 );
		}
	}

	Driver		= None;
    Throttle	= 0;
    Steering	= 0;
}




defaultproperties
{
	bLookSteer=true
	LookSteerSens=0.0001
	CamPos[0]=(W=0,X=0,Y=-25,Z=130)
	CamPos[1]=(W=350,X=0,Y=0,Z=100)
	CamPos[2]=(W=600,X=0,Y=0,Z=100)
	bCanBeBaseForPawns=true
	CollisionRadius=1
	CollisionHeight=1
}