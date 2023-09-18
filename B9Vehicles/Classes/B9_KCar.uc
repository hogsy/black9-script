// Base class for 4-wheeled vehicles using Karma
class B9_KCar extends B9_KVehicle
    abstract;

const	kFrontLeft			= 0;
const	kFrontRight			= 1;
const	kRearLeft			= 2;
const	kRearRight			= 3;
const	kRearLeft2			= 4;
const	kRearRight2			= 5;
const	kWheelLocationCount	= 6;

var KTire	Wheel[ kWheelLocationCount ];
var vector	WheelPos[ kWheelLocationCount ];
var (B9_KCar) class<KTire> TireClass;

var (B9_KCar) float       MaxSteerAngle;   // (65535 = 360 deg)
var (B9_KCar) float       MaxBrakeTorque;  // Braking torque applied to all four wheels. Positive only.
var (B9_KCar) float       TorqueSplit;     // front/rear drive torque split. 1 is fully RWD, 0 is fully FWD. 0.5 is standard 4WD.

// B9_KCarWheelJoint setting for steering (see B9_KCarWheelJoint). Duplicated here for handiness.
var (B9_KCar) float       SteerPropGap;
var (B9_KCar) float       SteerTorque;
var (B9_KCar) float       SteerSpeed;

// B9_KCarWheelSuspension setting
var (B9_KCar) float       SuspStiffness;
var (B9_KCar) float       SuspDamping;
var (B9_KCar) float       SuspHighLimit;
var (B9_KCar) float       SuspLowLimit;
var (B9_KCar) float       SuspRef;

// KTire settings. Duplicated here for handy tuning.
var (B9_KCar) float       TireRollFriction;
var (B9_KCar) float       TireLateralFriction;
var (B9_KCar) float       TireRollSlip;
var (B9_KCar) float       TireLateralSlip;
var (B9_KCar) float       TireMinSlip;
var (B9_KCar) float       TireSlipRate;
var (B9_KCar) float       TireSoftness;
var (B9_KCar) float       TireAdhesion;
var (B9_KCar) float       TireRestitution;
var (B9_KCar) float       TireMass;

var (B9_KCar) float	   HandbrakeThresh; // speed above which handbrake comes on =]
var (B9_KCar) float	   TireHandbrakeSlip; // Additional lateral slip when handbrake engaged
var (B9_KCar) float	   TireHandbrakeFriction; // Additional lateral friction when handbrake engaged

var (B9_KCar) float       ChassisMass;

var (B9_KCar) float	   StopThreshold; // Forward velocity under which brakes become drive.

var (B9_KCar) InterpCurve	TorqueCurve; // Engine RPM in, Torque out.

var float    Brake; // between 0 and 1
var int      Gear;  // 1 is forward, -1 is backward. Currently symmetric power/torque curve

// Car output
var float              WheelSpinSpeed;  // Current (averaged) RPM of rear wheels
var const float        GearRatio;       // Ratio between wheels and engine
var float			   ForwardVel;		// Component of cars velocity in its forward direction.

// Internal
var bool			   IsDriving;
var bool			   HandbrakeEngaged;

function PostBeginPlay()
{
	local vector RotX, RotY, RotZ, lPos;
    local int i;


    Super.PostBeginPlay();

    GetAxes(Rotation,RotX,RotY,RotZ);

    // Set up suspension graphics
    // Create joints
    for ( i = 0; i < kWheelLocationCount; i++ )
    {
	    // Spawn wheels, and flip graphics where necessary
		Wheel[ i ]	= spawn( TireClass, self, , Location + ( WheelPos[ i ] >> Rotation ) );
		if ( ( i & 1 ) == 0 )
		{
			Wheel[ i ].SetDrawScale3D( vect( 1, -1, 1 ) );
		}

		// create Karma joints
		Wheel[ i ].WheelJoint					= spawn( class'KCarWheelJoint', self );
		Wheel[ i ].WheelJoint.KPos1				= WheelPos[ i ] / 50;
		Wheel[ i ].WheelJoint.KPriAxis1			= vect( 0, 0, 1 );
		Wheel[ i ].WheelJoint.KSecAxis1			= vect( 0, 1, 0 );
		Wheel[ i ].WheelJoint.KConstraintActor1	= self;
		Wheel[ i ].WheelJoint.KPos2				= vect( 0, 0, 0 );
		Wheel[ i ].WheelJoint.KPriAxis2			= vect( 0, 0, 1 );
		Wheel[ i ].WheelJoint.KSecAxis2			= vect( 0, 1, 0 );
		Wheel[ i ].WheelJoint.KConstraintActor2	= Wheel[ i ];
		Wheel[ i ].WheelJoint.SetPhysics( PHYS_Karma );
	}

	// Initially make sure parameters are sync'ed with Karma
	KVehicleUpdateParams();
}

// Call this if you change any parameters (tire, suspension etc.) and they
// will be passed down to each wheel/joint.
function KVehicleUpdateParams()
{
	local int	i;


	Super.KVehicleUpdateParams();

	// steering
    Wheel[ kRearLeft ].WheelJoint.bKSteeringLocked = true;
    Wheel[ kRearRight ].WheelJoint.bKSteeringLocked = true;
    Wheel[ kRearLeft2 ].WheelJoint.bKSteeringLocked = true;
    Wheel[ kRearRight2 ].WheelJoint.bKSteeringLocked = true;
    
    Wheel[ kFrontLeft ].WheelJoint.bKSteeringLocked = false;
    Wheel[ kFrontLeft ].WheelJoint.KProportionalGap = SteerPropGap;
    Wheel[ kFrontLeft ].WheelJoint.KMaxSteerTorque = SteerTorque;
    Wheel[ kFrontLeft ].WheelJoint.KMaxSteerSpeed = SteerSpeed;

    Wheel[ kFrontRight ].WheelJoint.bKSteeringLocked = false;
    Wheel[ kFrontRight ].WheelJoint.KProportionalGap = SteerPropGap;
    Wheel[ kFrontRight ].WheelJoint.KMaxSteerTorque = SteerTorque;
    Wheel[ kFrontRight ].WheelJoint.KMaxSteerSpeed = SteerSpeed;

    KSetMass( ChassisMass );

    for ( i = 0; i < kWheelLocationCount; i++ )
	{
		// suspension
		Wheel[ i ].WheelJoint.KSuspHighLimit	= SuspHighLimit;
		Wheel[ i ].WheelJoint.KSuspLowLimit		= SuspLowLimit;
		Wheel[ i ].WheelJoint.KSuspStiffness	= SuspStiffness;
		Wheel[ i ].WheelJoint.KSuspDamping		= SuspDamping;

		// Sync params with Karma.
		Wheel[ i ].WheelJoint.KUpdateConstraintParams();

	    Wheel[ i ].KSetMass( TireMass );

		// Tire params handy tuning
		Wheel[ i ].RollFriction = TireRollFriction;
		Wheel[ i ].LateralFriction = TireLateralFriction;
		Wheel[ i ].RollSlip = TireRollSlip;
		Wheel[ i ].LateralSlip = TireLateralSlip;
		Wheel[ i ].MinSlip = TireMinSlip;
		Wheel[ i ].SlipRate = TireSlipRate;
		Wheel[ i ].Softness = TireSoftness;
		Wheel[ i ].Adhesion = TireAdhesion;
		Wheel[ i ].Restitution = TireRestitution;
	}
}

// Tell it your current throttle, and it will give you an output torque
// This is currently like an electric motor
function float Engine(float Throttle)
{
    local float	torque;
    
	torque	= Abs( Throttle ) * Gear * InterpCurveEval( TorqueCurve, WheelSpinSpeed );

    return torque;
}

function Tick(float Delta)
{
    local float		tana, sFactor, outputTorque, diffSplit;
	local vector	worldForward;


	worldForward = vect( 1, 0, 0 ) >> Rotation;
	ForwardVel = Velocity Dot worldForward;
	//Log("F:"$ForwardVel$"FVec:"$worldForward$"R:"$Rotation);

	if ( Driver == None )
	{
		Gear	= 0;
		Brake	= 1;
	}
	else
	{
		if ( fOperatorTrigger.PlayingSequence() )
		{
			Throttle	= 0;
			Steering	= 0;
			Brake		= 1;
		}
		else
		if(Throttle > 0.01) // pressing forwards
		{
			if(ForwardVel < -StopThreshold && Gear != 1) // going backwards - so brake first
			{
				//Log("F - Brake");
				Gear = 0;
				Brake = 1;
				IsDriving = false;
			}
			else // stopped or going forwards, so drive
			{
				//Log("F - Drive");
				Gear = 1;
				Brake = 0;
				IsDriving = true;
			}
		}
		else if(Throttle < -0.01) // pressing backwards
		{
			// We have to release the brakes and then press reverse again to go into reverse
			if(ForwardVel < StopThreshold && IsDriving == false)
			{
				//Log("B - Drive");
				Gear = -1;
				Brake = 0;
				IsDriving = false;
			}
			else // otherwise, we are going forwards, or still holding brake, so just brake
			{
				//Log("B - Brake");
				Gear = 0;
				Brake = 1;
				IsDriving = true;
			}
		}
		else // not pressing either
		{
			// If stationary, stick brakes on
			if(Abs(ForwardVel) < StopThreshold)
			{
				//Log("B - Brake");
				Gear = 0;
				Brake = 1;	
				IsDriving = false;
				HandbrakeEngaged = false; // force handbrake off if stopped.
			}
			else // otherwise, coast
			{
				//Log("Coast");
				Gear = 0;
				Brake = 0;
				IsDriving = false;
			}
		}

		KWake(); // currently, never let the car go to sleep whilst being driven.
	}

	// If we are going forwards, steering, and pressing the brake,
	// enable extra-slippy handbrake.
	if((ForwardVel > HandbrakeThresh || HandbrakeEngaged == true) && Abs(Steering) > 0.01 && Brake == 1)
	{
		//Log("HANDBRAKE!!");
		Wheel[ kRearLeft ].LateralFriction = TireLateralFriction + TireHandbrakeFriction;
		Wheel[ kRearLeft ].LateralSlip = TireLateralSlip + TireHandbrakeSlip;

		Wheel[ kRearRight ].LateralFriction = TireLateralFriction + TireHandbrakeFriction;
		Wheel[ kRearRight ].LateralSlip = TireLateralSlip + TireHandbrakeSlip;

		Wheel[ kRearLeft2 ].LateralFriction = TireLateralFriction + TireHandbrakeFriction;
		Wheel[ kRearLeft2 ].LateralSlip = TireLateralSlip + TireHandbrakeSlip;

		Wheel[ kRearRight2 ].LateralFriction = TireLateralFriction + TireHandbrakeFriction;
		Wheel[ kRearRight2 ].LateralSlip = TireLateralSlip + TireHandbrakeSlip;

		HandbrakeEngaged=true;
	}
	else
	{
		Wheel[ kRearLeft ].LateralFriction = TireLateralFriction;
		Wheel[ kRearLeft ].LateralSlip = TireLateralSlip;

		Wheel[ kRearRight ].LateralFriction = TireLateralFriction;
		Wheel[ kRearRight ].LateralSlip = TireLateralSlip;

		Wheel[ kRearLeft2 ].LateralFriction = TireLateralFriction;
		Wheel[ kRearLeft2 ].LateralSlip = TireLateralSlip;

		Wheel[ kRearRight2 ].LateralFriction = TireLateralFriction;
		Wheel[ kRearRight2 ].LateralSlip = TireLateralSlip;

		HandbrakeEngaged=false;
	}

    WheelSpinSpeed = (Wheel[ kRearLeft ].SpinSpeed + Wheel[ kRearRight ].SpinSpeed + Wheel[ kRearLeft2 ].SpinSpeed + Wheel[ kRearRight2 ].SpinSpeed)/4;
    //log("WheelSpinSpeed:"$WheelSpinSpeed);

    // Motor
    outputTorque = Engine(Throttle);

	// FRONT
    Wheel[ kFrontLeft ].WheelJoint.KMotorTorque = 0.5 * outputTorque * (1-TorqueSplit);
    Wheel[ kFrontRight ].WheelJoint.KMotorTorque = 0.5 * outputTorque * (1-TorqueSplit);

	// REAR
    Wheel[ kRearLeft ].WheelJoint.KMotorTorque = 0.5 * outputTorque * TorqueSplit/2;
    Wheel[ kRearRight ].WheelJoint.KMotorTorque = 0.5 * outputTorque * TorqueSplit/2;
    Wheel[ kRearLeft2 ].WheelJoint.KMotorTorque = 0.5 * outputTorque * TorqueSplit/2;
    Wheel[ kRearRight2 ].WheelJoint.KMotorTorque = 0.5 * outputTorque * TorqueSplit/2;

    // Braking
    Wheel[ kFrontLeft ].WheelJoint.KBraking = Brake * MaxBrakeTorque;
    Wheel[ kFrontRight ].WheelJoint.KBraking = Brake * MaxBrakeTorque;
    Wheel[ kRearLeft ].WheelJoint.KBraking = Brake * MaxBrakeTorque;
    Wheel[ kRearRight ].WheelJoint.KBraking = Brake * MaxBrakeTorque;
    Wheel[ kRearLeft2 ].WheelJoint.KBraking = Brake * MaxBrakeTorque;
    Wheel[ kRearRight2 ].WheelJoint.KBraking = Brake * MaxBrakeTorque;

    // Steering

	// if in 'look steer' mode - reverse steering if we are going backwards.
	if(Gear == -1 && bLookSteer)
		tana = Tan(6.283/65536 * -Steering * MaxSteerAngle);
	else
		tana = Tan(6.283/65536 * Steering * MaxSteerAngle);

    sFactor	= 0.5 * tana * ( 2 * WheelPos[ kFrontLeft ].Y ) / Abs( WheelPos[ kFrontLeft ].X - WheelPos[ kRearLeft ].X );
    Wheel[ kFrontLeft ].WheelJoint.KSteerAngle = 65536/6.283 * Atan( tana, (1-sFactor) );
    Wheel[ kFrontRight ].WheelJoint.KSteerAngle = 65536/6.283 * Atan( tana, (1+sFactor) );
}


defaultproperties
{
	MaxSteerAngle=3900
	MaxBrakeTorque=50
	TorqueSplit=0.5
	SteerPropGap=1000
	SteerTorque=1000
	SteerSpeed=15000
	SuspStiffness=50
	SuspDamping=5
	SuspHighLimit=1
	SuspLowLimit=-1
	TireRollFriction=1
	TireLateralFriction=1
	TireRollSlip=0.085
	TireLateralSlip=0.06
	TireMinSlip=0.001
	TireSlipRate=0.0005
	TireSoftness=0.0002
	TireMass=0.5
	HandbrakeThresh=1000
	TireHandbrakeSlip=0.06
	TireHandbrakeFriction=-0.5
	ChassisMass=4
	StopThreshold=100
	TorqueCurve=(Points=/* Array type was not detected. */,InVal=0,OutVal=150)
	Gear=1
}