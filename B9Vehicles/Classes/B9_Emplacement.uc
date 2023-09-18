//=============================================================================
// B9_Emplacement
//
// 
//	Base class for manned weapons (turrets, etc)
// 
//=============================================================================



class B9_Emplacement extends B9_Vehicle
	abstract;


//////////////////////////////////
// Definitions
//



//////////////////////////////////
// Variables
//

var B9_EmplacementPart				fSeatPart;
var class<B9_EmplacementPart>		fSeatPartClass;
var vector							fSeatPartOffset;

var B9_EmplacementPart				fGunPart;
var class<B9_EmplacementPart>		fGunPartClass;
var vector							fGunPartOffset;

var Vector							fFireStart[2];
var Vector							fCameraOffset;

var float							fRateOfFire;
var byte							fNumberOfBarrels;
var byte							fBarrelToUse;




//////////////////////////////////
// Functions
//



//////////////////////////////////////////////////
// Creation
//

simulated function PostBeginPlay()
{
	local vector StartPos, X, Y, Z;


    Super.PostBeginPlay();
	GetAxes( Rotation, X, Y, Z );


	// Create the parts of the turret
	//

	if( fSeatPartClass != none )
	{
		StartPos = Location + (X*fSeatPartOffset.X) + (Y*fSeatPartOffset.Y) + (Z*fSeatPartOffset.Z);

		fSeatPart = spawn( fSeatPartClass, Self,, StartPos );
		fSeatPart.SetLocation( StartPos );
		fSeatPart.SetBase(self);
		fSeatPart.SetCollision( true, true, true);
	}
	
	if( fGunPartClass != none )
	{
		StartPos = Location + (X*fGunPartOffset.X) + (Y*fGunPartOffset.Y) + (Z*fGunPartOffset.Z);

		log( "StartPos  "$StartPos.X$" " $StartPos.Y$" "$StartPos.Z );

		fGunPart = spawn( fGunPartClass, Self,, StartPos );
		fGunPart.SetLocation( StartPos );
		fGunPart.SetBase(self);
		fGunPart.SetCollision( true, true, true );
	}
}


event Destroyed()
{
	if( fSeatPart != none )
	{
		fSeatPart.Destroy();
		fSeatPart = none;
	}

	if( fGunPart != none )
	{
		fGunPart.Destroy();
		fGunPart = none;
	}

	Super.Destroyed();
}



//////////////////////////////////////////////////
// Stuff from Engine.Vehicle
//

function TryToDrive(Pawn p)
{
    if( Driver == None )
	{        
		DriverEnter(p);
    }
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
    pc.GotoState( 'PlayerUsingTurret' );

	// Move the driver into position, and attach to car.
	Driver.SetCollision( false, false, false );
	Driver.bCollideWorld		= false;
	Driver.bPhysicsAnimUpdate	= false;
	Driver.Velocity				= vect( 0, 0, 0 );
	Driver.SetPhysics( PHYS_None );
	Driver.SetBase( Self );
}

//////////////////////////////////////////////////
// Movement / Camera
//

simulated function GetCameraPosition( out vector CamPos )
{}	// Get the coordinates of the camera attachment point



function OrientGun( rotator r )
{
	
	local rotator temp;

	//SetRotation( r );	

	temp = r;
//	temp.Pitch = 0;
//	temp.Roll = -r.Pitch;
	fGunPart.SetRotation( temp );

	temp.Pitch = 0;
//	temp.Roll = r.Roll;
	fSeatPart.SetRotation( temp );
}


simulated function Tick( Float DeltaTime )
{

}


//////////////////////////////////////////////////
// Firing logic
//

simulated function LocalFire()
{} // spawn local firing fx here; muzzle flash, sound, etc

function SpawnFire()
{} // fire the specific type of projectile/weapon

simulated function Fire( float value )
{
	ServerFire();

	if ( Role < ROLE_Authority )
	{
		LocalFire();
		GotoState('ClientTurretFiring');
	}
}

function ServerFire()
{
	GotoState('ServerTurretFiring');

	SpawnFire();
	LocalFire();
}

function ServerAfterFire()
{
	if( Instigator.PressingFire() )
	{
		Global.Fire(1);
	}
	else
	{
		GotoState('TurretIdle');
	}
}

simulated function ClientAfterFire()
{
	if( Instigator.PressingFire() )
	{
		Global.Fire(1);
	}
	else
	{
		GotoState('TurretIdle');
	}
}

//////////////////////////////////
// States
//
auto state TurretIdle
{

}


state ServerTurretFiring
{
	function Fire( float value ) {}

Begin:

	Sleep( fRateOfFire );
	ServerAfterFire();
}


state ClientTurretFiring
{
	function Fire( float value ) {}

Begin:

	ClientAfterFire();
}



//////////////////////////////////
// Initialization
//
defaultproperties
{
	fGunPartOffset=(X=0,Y=0,Z=420)
	fRateOfFire=1
	fNumberOfBarrels=1
	Physics=5
}