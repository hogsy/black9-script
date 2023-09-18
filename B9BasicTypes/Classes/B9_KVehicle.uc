class B9_KVehicle extends KVehicle;




// trigger used to operate the vehicle
var const vector		fOperatorTriggerOffset;
var B9_VehicleTrigger	fOperatorTrigger;

var (B9_KVehicle) bool		  bLookSteer;		// Indicates how if vehicle should steer towards where you are looking,
var (B9_KVehicle) float	LookSteerSens;	// Sensitivity of steering as you look left around

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
	local vector			exitOffset;
	local float				exitDist;
	local float				minDist;


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

	// try to ensure the Driver is far enough away
	exitOffset	= fOperatorTriggerOffset;
	exitDist	= VSize( exitOffset );
	minDist		= CollisionRadius + Driver.CollisionRadius + 10;
	if ( exitDist < minDist )
	{
		exitOffset	= Normal( exitOffset ) * minDist;
	}
	Driver.SetLocation( Location + ( exitOffset >> Rotation ) );

	Driver		= None;
    Throttle	= 0;
    Steering	= 0;
}

// As with KActor, shooting a vehicle applies an impulse
function TakeDamage( int damage, Pawn instigatedBy, Vector hitLocation, Vector momentum, class< DamageType > damageType )
{
    KAddImpulse( momentum, hitlocation );
}

event KVehicleUpdateParams();




defaultproperties
{
	bLookSteer=true
	LookSteerSens=0.0001
	CamPosIndex=2
	CamPos[0]=(W=0,X=0,Y=-25,Z=130)
	CamPos[1]=(W=350,X=0,Y=0,Z=100)
	CamPos[2]=(W=600,X=0,Y=0,Z=100)
}