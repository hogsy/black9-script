//=============================================================================
// B9_CameraController
//
// CameraControllers Special 3rd person camera pawn controllers
//
// 
//=============================================================================

class B9_CameraController extends AIController
	native;

var protected float fDesiredDistance;

var protected bool fLostTarget;
var protected float fLostTargetTime;
var protected bool fHiddenTarget;
var protected float fHiddenTargetTime;
var protected bool fPartiallyHiddenTarget;
var protected float fPartiallyHiddenTargetTime;

var protected float fCameraPitch;
var protected float fCameraTurn;

var protected vector fLastVisibleCameraLocation;
var protected vector fLastVisibleTargetLocation;

var protected vector fTargetLastLocation;

var private float fDebugDeltaTime;

native(2100) final function Box GetBSPNodeInnerDimensions( vector location );
// Just like regular Trace, but only checking the BSP level geometry
native(2101) final function actor BSPTrace( out vector HitLocation, out vector HitNormal, vector TraceEnd, 
	optional vector TraceStart );

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local float d;
	local vector dir;

	Super.DisplayDebug(Canvas,YL, YPos);

	// Print out the distance from the target and the direction towards
	dir = Target.Location - Pawn.Location;
	d = VSize(dir);
	if ( d < 0.0001 )
	{
		d = 0.0001;
	}
	dir /= d;
	Canvas.DrawColor.B = 255;
	Canvas.DrawColor.G = 200;
	Canvas.DrawColor.R = 200;	
/*	Canvas.DrawText( "Target velocity: "$fDebugTargetVelocity );
	YPos += YL;
	Canvas.SetPos(4,YPos);
*/
}

// This should probably be defigned elsewhere so that it can be used by other classes
function Rotator GetEularAngles( vector direction )
{
	local vector up, right;

	up = vect(0,0,1);
	right = up Cross direction;
	return OrthoRotation( direction, right, up );
}

function PreBeginPlay()
{
	Super.PreBeginPlay();

	fLostTarget = false;
	fHiddenTarget = false;
	fPartiallyHiddenTarget = false;
	fCameraPitch = 0;
	fCameraTurn = 0;
}

function Possess(Pawn aPawn)
{
	Super.Possess(aPawn);

	aPawn.SetPhysics(PHYS_Flying);

	fLastVisibleCameraLocation = Pawn.Location;
}

function ResetCamera()
{
	if ( Owner != None )
	{
		Pawn.SetLocation(Owner.Location);
		Pawn.SetRotation(Owner.Rotation);
	}
}

function SetTarget( Actor _Target )
{
	Target = _Target;
	
	fLastVisibleTargetLocation = Target.Location;
	fTargetLastLocation = Target.Location;
}

function SetPitch( float delta )
{
	fCameraPitch = delta;
}

function SetTurn( float delta ) // Yaw
{
	fCameraTurn = delta;
}

function bool FirstPerson()
{
	if ( Pawn(Target) == None || PlayerController(Pawn(Target).Controller) == None )
	{
		return false;
	}
	else
	{
		return !PlayerController(Pawn(Target).Controller).bBehindView;
	}
}

function SetFirstPerson( bool firstPerson )
{
	if ( Pawn(target) != None && PlayerController(Pawn(target).Controller) != None )
	{
		PlayerController(Pawn(Target).Controller).bBehindView = !firstPerson;
	}
}

function CameraDist()
{
	if ( FirstPerson() || fDesiredDistance < 200 )
	{
		SetFirstPerson(false);
		fDesiredDistance = 200;
	}
	else if ( fDesiredDistance < 300 )
	{
		fDesiredDistance = 300;
	}
	else if ( fDesiredDistance < 600 )
	{
		fDesiredDistance = 600;
	}
	else if ( Pawn(Target) != None && PlayerController(Pawn(Target).Controller) != None )
	{		
		SetFirstPerson(true);
	}
	else
	{
		fDesiredDistance = 200;
	}
}

function vector GetLookAt()
{
	local vector loc;
	local Pawn PTarget;

	PTarget = Pawn(Target);

	loc = Target.Location;
	if ( PTarget != None )
	{
		loc.z += PTarget.EyeHeight;
	}

	return loc;
}

function UpdateView( float deltatime )
{
	local rotator ViewRotation;

	// Update view rotation
	if ( Target != None )		// Aim at target
	{
		ViewRotation = GetEularAngles(GetLookAt() - Pawn.Location);
	}
	else
	{
		ViewRotation = Rotation;
	}

	// Update rotation.
	Pawn.FaceRotation( ViewRotation, deltaTime );
}

function CameraMove( float DeltaTime )
{
}

event Tick( float DeltaTime )
{
	fDebugDeltaTime = DeltaTime;
	CameraMove(DeltaTime);
}

function MoveQuicklyTowards( vector destination, float deltaTime )
{
	local vector dir;
	local float d, speed;

	if ( Pawn.AccelRate == 0 )
	{
		return;
	}

	if ( deltaTime < 0.0001 )
	{
		deltaTime = 0.0001;
	}

	dir = destination - Pawn.Location;	// Get the path
	d = VSize( dir );	// Get the distance
	if ( d < 0.0001 )
	{
		return;
	}
	dir /= d;	// Normalize the vector

	// Reduce speed if approaching destination
	speed = Pawn.AccelRate * deltaTime;
	if ( speed != 0 )
	{
		speed = d / speed;
	}
	else
	{
		speed = 0;
	}
	if ( speed > 1 )
	{
		speed = 1;
	}
	Pawn.Velocity += Pawn.AccelRate * dir * speed;
//	Pawn.Acceleration += Pawn.AccelRate * dir * speed;
}

function float GetFloorCeilingClearance()
{
	local vector hitLocation1, hitLocation2, hitNormal, offset;
	local actor hitActor;
	local float height, shortest;
	local int count;

	if ( Target == None )
	{
		return 0;
	}

	shortest = 1000;

	offset.Z = 0;
	for ( count = 0; count < 4; count++ )
	{
		// To ceiling
		if ( ( count & 1 ) == 1 )
		{
			offset.X = Target.CollisionRadius;
		}
		else
		{
			offset.X = -Target.CollisionRadius;
		}
		if ( count < 2 )
		{
			offset.Y = Target.CollisionRadius;
		}
		else
		{
			offset.Y = -Target.CollisionRadius;
		}
		hitActor = Trace( hitLocation1, hitNormal, GetLookAt() + offset + vect(0,0,1000), GetLookAt() + offset );
		if ( hitActor == None )
		{
			continue;
		}

		// To floor
		hitActor = Trace( hitLocation2, hitNormal, GetLookAt() + offset + vect(0,0,-1000), GetLookAt() + offset );
		if ( hitActor == None )
		{
			continue;
		}

		height = hitLocation1.Z - hitLocation2.Z;

		if ( height < shortest )
		{
			shortest = height;
		}
	}

	return shortest;
}

function ApproachTarget( float deltaTime )
{
	local float d, deltaD, speed, speedPercent;
	local vector dir, xAxis, yAxis, zAxis;
	local vector BSPLeafColBndsExt;
	local float roomHeight, allowedDistance;

	if ( Target != None )
	{
		// Check the height about the target -- see if we need to pull the camera in closer
		// Check for headroom inside the BSP
		roomHeight = GetFloorCeilingClearance();		

		if ( roomHeight < 200 )
		{
			allowedDistance = 100;
		}
		else if ( roomHeight < 400 )
		{
			allowedDistance = 200;
		}
		else if ( roomHeight < 800 )
		{
			allowedDistance = 400;
		}
		else
		{
			allowedDistance = fDesiredDistance;
		}

		if ( allowedDistance > fDesiredDistance )
		{
			allowedDistance = fDesiredDistance;
		}

		// Get distances and directions from target

		dir = GetLookAt() - Pawn.Location;	// Get the path
		dir.z = 0;	// Handle z axis differently
		d = VSize( dir );	// Get the distance
		if ( d < 1 )
		{
			d = 1;
			GetAxes( Target.Rotation, xAxis, yAxis, zAxis );
			dir = xAxis;
		}
		dir /= d;	// Normalize the vector
		deltaD = d - allowedDistance;
		if ( deltaD > 100 )
		{
			if ( !fLostTarget )
			{
				fLostTarget = true;
				fLostTargetTime = Level.TimeSeconds;
			}
		}
		else
		{
			fLostTarget = false;
		}

		// Calculate new accelerations

//		if ( !fPartiallyHiddenTarget )
//		{
			MoveQuicklyTowards( Pawn.Location + dir * deltaD, deltaTime );
//		}
	}
}

function RepositionCamera()
{
	local vector hitLocation, hitNormal, boxExtent, destination;

	destination = Pawn.Location;
	destination.z = Target.Location.z;

	boxExtent = Pawn.CollisionRadius * vect(1,1,0);
	boxExtent.Z = Pawn.CollisionHeight;
	if ( Trace( hitLocation, hitNormal, destination, Target.Location, false, boxExtent ) != None )
	{
		Pawn.SetLocation(hitLocation);
	}
	else
	{
		Pawn.SetLocation(destination);
	}
}

function bool DirectLineOfSight()
{
	return FastTrace( Target.Location, Pawn.Location );
}

function vector GetTargetLock()
{
	return Pawn(Target).Controller.Target.Location;
}

function RotateCamera( float deltaTime )
{
	local vector position, targetLock;
	local float d, d2;
	local rotator orientation, targetLockOrientation;
	local int maxPitch;
	local float speed, rate;
	local float naturalPitch;
	local int lockThreshold; 
	
	position = Pawn.Location - GetLookAt();
	d = VSize(position);
	if ( d == 0 )
	{
		d = 1;
		position = vect(1,0,0);
	}
	else
	{
		position /= d;
	}

	// Retrieve the Eular angles --> this might not be the best way to do this
	orientation = GetEularAngles( position );

	orientation.yaw += fCameraTurn * deltaTime;
	orientation.pitch += fCameraPitch * deltaTime;
	orientation.roll = 0;


	// Clamp pitch
	maxPitch = 8192;
	if ( orientation.pitch > maxPitch )
	{
		orientation.pitch = maxPitch;
	}
	else if ( orientation.pitch < -maxPitch )
	{
		orientation.pitch = -maxPitch;
	}

	// Find and move slowly toward natural pitch
	if ( deltaTime < 0.0001 )
	{
		deltaTime = 0.0001;
	}
	naturalPitch = float(maxPitch) * d / 1600;
	rate = 16384;
	speed = rate * deltaTime;
	if ( speed != 0 )
	{
		speed = ( naturalPitch - orientation.pitch ) / speed;
	}
	else
	{
		speed = 0;
	}
	if ( speed > 1 )
	{
		speed = 1;
	}
	else if ( speed < -1 )
	{
		speed = -1;
	}

	orientation.pitch += (rate * speed * deltaTime);

	position.x = d;
	position.y = 0;
	position.z = 0;
	position = position >> orientation;		// Transform point (rotate)

	// During camera rotation, camera needs to instantly steer at its desired orientation regardless to physics
	Pawn.MoveSmooth( position + GetLookAt() - Pawn.Location );
}

function bool InPlainView()
{
	local vector hitLocation, hitNormal, boxExtent;

	// Performing full trace, may be excessive and slow!!!!!
	boxExtent = Pawn.CollisionRadius * vect(1,1,0);
	boxExtent.Z = Pawn.CollisionHeight;
	if ( Trace( hitLocation, hitNormal, Target.Location, Pawn.Location, false, boxExtent ) != None )
	{
		return false;
	}
	else
	{
		return true;
	}
}

// Rotate the camera to get the target back in view
function RotateInView(float deltaTime)
{
	local vector targetVector, cameraVector, oldCameraVector;
	local rotator destination, current, delta;
	local int angle;

	cameraVector = Pawn.Location - GetLookAt();
	targetVector = fLastVisibleTargetLocation - GetLookAt();

	current = GetEularAngles(cameraVector);
	destination = current;

	if ( targetVector != vect(0,0,0) )
	{
		destination = GetEularAngles(targetVector);
	}
	else
	{
		oldCameraVector = fLastVisibleCameraLocation - GetLookAt();
		destination = GetEularAngles(oldCameraVector);
	}

	delta = destination - current;
	delta *= 2.0;	// Add a little extra to get around tough corners
/*	angle = 65536;
	if ( delta.pitch < 0 )
	{
		fCameraPitch -= angle * deltaTime;
	}
	else if ( delta.pitch > 0 )
	{
		fCameraPitch += angle * deltaTime;
	}
	if ( delta.yaw < 0 )
	{
		fCameraTurn -= angle * deltaTime;
	}
	else if ( delta.yaw > 0 )
	{
		fCameraTurn += angle * deltaTime;
	}
*/
	fCameraTurn += delta.yaw;
	fCameraPitch += delta.pitch;	
}

auto state Flying
{
	function CameraMove( float DeltaTime )
	{
		local vector targetDelta;
		// Check if we need to reposition the camera
		if ( fLostTarget && Level.TimeSeconds - fLostTargetTime > 1.5 || fHiddenTarget && Level.TimeSeconds - fHiddenTargetTime > 1.5 )
		{
			RepositionCamera();
			fLostTarget = false;
			fHiddenTarget = false;
			fPartiallyHiddenTarget = false;
		}


		// Update speed and acceleration
		Pawn.Acceleration = vect(0,0,0);
		Pawn.Velocity = vect(0,0,0);
		Acceleration = Pawn.Acceleration;
		Velocity = Pawn.Velocity;

		// Match speed with target
		Pawn.Velocity = Target.Velocity * 0.5;	// This is a controversial feature --> reduce to 50%
		targetDelta = GetLookAt() - fTargetLastLocation;
//		if ( !fPartiallyHiddenTarget )
//		{
//			MoveQuicklyTowards( Pawn.Location + targetDelta, DeltaTime );
//		}
		fTargetLastLocation = GetLookAt();

		// Check distance from player
		ApproachTarget( deltaTime );

		// Check if target is visible
		if ( !DirectLineOfSight() )
		{
			if ( !fHiddenTarget )
			{
				fHiddenTarget = true;
				fHiddenTargetTime = Level.TimeSeconds;
			}
		}
		else
		{
			fHiddenTarget = false;
		}

		if ( !InPlainView() )
		{
			if ( !fPartiallyHiddenTarget )
			{
				fPartiallyHiddenTarget = true;
				fPartiallyHiddenTargetTime = Level.TimeSeconds;
			}
			else if ( Level.TimeSeconds - fPartiallyHiddenTargetTime > 0.5 )
			{
				RotateInView(deltaTime);
			}
		}
		else
		{
			fLastVisibleCameraLocation = Pawn.Location;
			fLastVisibleTargetLocation = GetLookAt();
			fPartiallyHiddenTarget = false;
		}

		// Rotate (Orbit) camera
		RotateCamera(deltaTime);

		UpdateView(deltaTime);
	}

	function BeginState()
	{
		Super.BeginState();
		Pawn.SetPhysics(PHYS_Flying);
	}

Begin:
}

defaultproperties
{
	fDesiredDistance=300
}