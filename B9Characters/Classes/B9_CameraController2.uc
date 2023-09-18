//=============================================================================
// B9_CameraController2
//
// CameraControllers Special 3rd person camera pawn controllers
//
// 
//=============================================================================

class B9_CameraController2 extends AIController
	native
	config(user);
	
	
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

// Camera Controls
var protected int fDesiredCameraDist;
var protected int fLastDesiredCameraDist;
var protected int fCurrentCameraDist;
var protected int fCameraPitch;
var protected int fCameraTurn;

var globalconfig bool fCameraSpring;

var protected vector fTargetLastLocation;

native(2110) static final function vector GetBestVantagePoint();
native(2111) static final function ShowVantagePointGraph( Canvas canvas );
native(2112) static final function vector DampenVelocity( vector velocity );

const kFullAngle = 65536;
const kMaxPitch = 14080;

const kFadeMaxDist = 100;
const kFadeMinDist = 25;

function PostBeginPlay()
{
	if ( Pawn != None )
	{
		Pawn.SetLocation(GetLookAt());
		Pawn.Move(vect(100,0,0));
	}
	ResetCamera();
}

function FadeOutTarget()
{
	local float dist;
	
	if ( Pawn(Target) != None && B9_PlayerController(Pawn(Target).Controller) != None )
	{
		if ( B9_PlayerController(Pawn(Target).Controller).fCloakState != kUnCloaked )
		{
			return;
		}
	}
	
	dist = VSize( GetLookAt() - Pawn.Location );
	
	if ( dist < kFadeMaxDist )
	{
		dist -= kFadeMinDist;
		if ( dist < 0 )
		{
			dist = 0;
		}
		Target.AdjustAlphaFade( 128 * dist / ( kFadeMaxDist - kFadeMinDist ) );
	}
	else
	{
		Target.RemoveColorModifierSkins();
	}
}

function ResetCamera()
{
	local vector x, y, z;
	local float size;
	local rotator angles;
	
	if ( Owner != None && Pawn !=None )
	{
		x = Pawn.Location - GetLookAt();
		angles = GetEularAngles(x);
		if ( angles.pitch > kMaxPitch )
		{
			angles.pitch = kMaxPitch;
		}
		else if ( angles.pitch < -kMaxPitch )
		{
			angles.pitch = -kMaxPitch;
		}
		GetAxes( angles, x, y, z );
		Pawn.SetLocation( Owner.Location );
		Pawn.Move( x * fDesiredCameraDist );
		Pawn.FaceRotation( Owner.Rotation, 1 );
		UpdateView(1);
	}

	if ( Target != None )
	{
		fTargetLastLocation = Target.Location;
	}
}

function Possess( Pawn aPawn )
{
	Super.Possess(aPawn);

	if ( Pawn != None )
	{
		Pawn.SetLocation(GetLookAt());
		Pawn.Move(vect(100,0,0));
	}
	ResetCamera();	
}

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

simulated event RenderOverlays( canvas Canvas )
{
	GetBestVantagePoint();
//	ShowVantagePointGraph( Canvas );
//	log( "scdTemp:  B9_CameraController2::RenderOverlays" );

}


//////////////////////////
// Misc Helper Functions
//

// This should probably be defigned elsewhere so that it can be used by other classes
function Rotator GetEularAngles( vector direction )
{
	local vector up, right;
	local float size;

	up = vect(0,0,1);
	size = VSize( direction );
	if ( size < 0.0001 )
	{
		size = 0.0001;
	}
	direction /= size;

	right = up Cross direction;
	return OrthoRotation( direction, right, up );
}



//////////////////////////////////////////////////
// Interface to PlayerController functions
//

function SetPitch( float delta, float deltaTime )
{
	fCameraPitch += delta * deltaTime;
}

function SetTurn( float delta, float deltaTime ) // Yaw
{
	fCameraTurn += delta * deltaTime;
}

function NextCameraDist()
{
	if ( FirstPerson() || fDesiredCameraDist < 200 )
	{
		SetFirstPerson(false);
		fCurrentCameraDist = 50;
		fDesiredCameraDist = 200;
	}
	else if ( fDesiredCameraDist < 300 )
	{
		fDesiredCameraDist = 300;
	}
	else if ( fDesiredCameraDist < 600 )
	{
		fDesiredCameraDist = 600;
	}
	else if ( Pawn(Target) != None && PlayerController(Pawn(Target).Controller) != None )
	{		
		SetFirstPerson(true);
	}
	else
	{
		fDesiredCameraDist = 200;
	}
}

function SetTarget( Actor actor )
{
	Target = actor;
	fTargetLastLocation = Target.Location;
}

////////////////////////////
// Camera View functions
//

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

function vector GetLookAt()
{
	local vector loc, x, y, z;
	local Actor ATarget;
	local Pawn PTarget;
	
	if ( Target != None )
	{
		ATarget = Target;
	}
	else
	{
		ATarget = Owner;
	}

	PTarget = Pawn(ATarget);

	loc = ATarget.Location;
	if ( PTarget != None )
	{
		loc.z += PTarget.EyeHeight;
	}

	return loc;
}

function float AngleDifference( int angle1, int angle2 )
{
	local int diff1, diff2;

	angle1 = angle1 & ( kFullAngle - 1 );
	angle2 = angle2 & ( kFullAngle - 1 ); 

	if ( angle1 < 0 )
	{
		angle1 += kFullAngle;
	}

	if ( angle2 < 0 )
	{
		angle2 += kFullAngle;
	}

	diff1 = angle1 - angle2;
	if ( angle1 > angle2 )
	{
		diff2 = angle1 - kFullAngle - angle2;			
	}
	else
	{
		diff2 = angle1 + kFullAngle - angle2;
	}

	if ( abs(diff1) > abs(diff2) )
	{
		return diff2;
	}
	else
	{
		return diff1;
	}
}

function float DegreesToRadians( int degrees )
{
	return 2.0 * PI * float(degrees) / float(kFullAngle);
}

function int RadiansToDegrees( float radians )
{
	local int degrees;
	
	degrees = radians * float(kFullAngle) / ( 2.0 * PI );

	return degrees & ( kFullAngle - 1 );
}

function float ClampAngleVelocity( float angle )
{
	if ( angle > PI * 0.5 )
	{
		angle = PI * 0.5;
	}
	else if ( angle < -PI * 0.5 )
	{
		angle = -PI * 0.5;
	}

	return angle;
}

function UpdateView( float deltatime )
{
	local rotator LookRotation;
	local vector direction;

	// Update view rotation
	if ( Target != None )		// Aim at target
	{
		LookRotation = GetEularAngles(GetLookAt() - Pawn.Location);
	}
	else
	{
		LookRotation = Rotation;
	}

	// Update rotation.
	Pawn.FaceRotation( LookRotation, deltaTime );
}

///////////////////////////////////////////
// Camera Pawn Movement functions
//

function CameraMove( float DeltaTime )
{
}

function TurnCameraTowardsFacing()
{
	local vector cameraDir;
	local rotator cameraAngle, distAngle;
	local Quat targetQuat, cameraQuat, distQuat;

/*	targetQuat = RotatorToQuat(Target.Rotation);
	cameraDir = Target.Location - Pawn.Location;
	cameraDir.z = 0;
	cameraAngle = GetEularAngles(cameraDir);
	cameraQuat = RotatorToQuat(cameraAngle);

	distQuat = targetQuat * cameraQuat;
	distAngle = QuatToRotator(distQuat);

	if ( abs(distAngle.yaw) > 16384 - 4096 )
	{
		fCameraTurn += distAngle.yaw;
	}*/
}

function RotateCamera( float deltaTime )
{
	local vector x, y, z;
	local rotator orientation;
	
	// Get current rotation

	orientation.pitch = fCameraPitch;
	orientation.yaw = fCameraTurn;
	
	// Clamp pitch
	if ( orientation.pitch > kMaxPitch )
	{
		orientation.pitch = kMaxPitch;
	}
	else if ( orientation.pitch < -kMaxPitch )
	{
		orientation.pitch = -kMaxPitch;
	}
	
	fCameraPitch = orientation.pitch;

	// Reposition Camera
	Pawn.SetLocation( GetLookAt() );
	GetAxes( orientation, X, Y, Z );
//	Pawn.MoveSmooth( X * fDesiredCameraDist );
	Pawn.Move( X * fCurrentCameraDist );
}

function bool TargetIsVisible()
{
	local actor hitActor;
	local vector hitLocation, hitNormal, offset;
	local pawn pTarget;
	local float x, y, z;
	
	pTarget = Pawn(Target);
	
	if ( pTarget == None )
	{
		return true;	// errrrr...
	}
	
	// SCD$$$ Performing lots and lots of traces hear, this might be slow!
	//
	
	hitActor = Trace( hitLocation, hitNormal, Target.Location, Pawn.Location, false );
	if ( hitActor == None )
	{
		return true;
	}

	for ( z = 0; z < pTarget.CollisionHeight; z += pTarget.CollisionHeight / 2 )
	{
		for ( y = -pTarget.CollisionRadius; y < pTarget.CollisionRadius; y += pTarget.CollisionRadius / 2 )
		{
			for ( x = -pTarget.CollisionRadius; x < pTarget.CollisionRadius; x += pTarget.CollisionRadius / 2 )
			{
				offset.x = x;
				offset.y = y;
				offset.z = z;
				hitActor = Trace( hitLocation, hitNormal, Target.Location + offset, Pawn.Location, false );
				if ( hitActor == None )
				{
					return true;
				}
			}
		}
	}
}

//////////////////////////////////
// Main Camera Logic Functions
//

event Tick( float DeltaTime )
{
	CameraMove(DeltaTime);
}

function Actor GetOwnerTarget()
{
	local Pawn PTarget;
	
	if ( Target != None )
	{
		PTarget = Pawn(Target);
	}
	else if ( Owner != None )
	{
		PTarget = Pawn(Target);
	}
	else
	{
		return None;
	}
	
	if ( PTarget != None )
	{
		if ( PTarget.Controller != None )
		{
			return PTarget.Controller.Target;
		}
		else
		{
			return None;
		}
	}
	else
	{
		return None;
	}	
}

state TargetLock
{
	function NextCameraDist()
	{
	}
	
	function vector GetLookAt()
	{
		local vector loc, x, y, z;
		local Actor ATarget;
		local Pawn PTarget;
		
		if ( Target != None )
		{
			ATarget = Target;
		}
		else
		{
			ATarget = Owner;
		}

		PTarget = Pawn(ATarget);

		loc = ATarget.Location;
		if ( PTarget != None )
		{
			loc.z += PTarget.CollisionHeight;
		}

		return loc;
	}
	
	function vector GetTargetLoc()
	{
		local Pawn POwner;
		local Controller OwnerController;
		local Actor OwnerTarget;
		local vector loc, X, Y, Z;
		local Vector	hitLocation, hitNormal, traceEnd, traceStart;
		
		if ( Target != None && Pawn(Target) != None )
		{
			POwner = Pawn(Target);
		}
		else if ( Owner != None && Pawn(Owner) != None )
		{
			POwner = Pawn(Owner);
		}
		else
		{
			return vect(0,0,0);
		}
		
		OwnerController = POwner.Controller;
		if ( OwnerController == None )
		{
			return vect(0,0,0);
		}
		
		// use the aim hit location as the view target
		GetAxes( OwnerController.GetViewRotation(), X, Y, Z );
		traceStart	= POwner.Weapon.GetFireStart( X, Y, Z );
		traceEnd	= traceStart + X * 10000;
		if ( Trace( hitLocation, hitNormal, traceEnd, traceStart, false ) == None )
		{
			hitLocation	= traceEnd;
		}

		return hitLocation;
	}

	function CameraMove( float DeltaTime )
	{
		local vector X, Y, Z;
		local rotator destRotation;
		local Actor OwnerTarget;
		
		ApproachTarget(deltaTime);
		
		OwnerTarget = GetOwnerTarget();
		
		if ( OwnerTarget == None )
		{
			return;
		}
				
		destRotation = GetEularAngles( GetLookAt() - GetTargetLoc() );
		
		// Rotate (Orbit) camera
		// Reposition Camera
		Pawn.SetLocation( GetLookAt() );
		GetAxes( destRotation, X, Y, Z );
		Pawn.Move( X * fCurrentCameraDist );		
		
		fCameraTurn = destRotation.yaw;
		fCameraPitch = destRotation.pitch;

		UpdateView(deltaTime);

		FadeOutTarget();
	}

	event BeginState()
	{
		fLastDesiredCameraDist = fDesiredCameraDist;
		fDesiredCameraDist = 75;
	}
	
	event EndState()
	{
		fDesiredCameraDist = fLastDesiredCameraDist;
	}
}

function ApproachTarget( float DeltaTime )
{
	local float speed;
	
	speed = fDesiredCameraDist - fCurrentCameraDist;

	if ( speed > Pawn.AccelRate )
	{
		speed = Pawn.AccelRate;
	}
	else if ( speed < -Pawn.AccelRate )
	{
		speed = -Pawn.AccelRate;
	}
	
	fCurrentCameraDist += speed;
}

auto state Orbiting
{
	function CameraMove( float DeltaTime )
	{
		ApproachTarget( deltaTime );
		
		// Rotate (Orbit) camera
		RotateCamera(deltaTime);

		UpdateView(deltaTime);
		FadeOutTarget();
	}
}

defaultproperties
{
	fDesiredCameraDist=300
	fCurrentCameraDist=300
	fCameraSpring=true
	AttitudeToPlayer=6
}