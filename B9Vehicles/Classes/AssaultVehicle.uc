// Urban Assault Rover
class AssaultVehicle extends B9_KCar
    placeable;

#exec OBJ LOAD FILE=..\staticmeshes\B9_Vehicle_meshes.usx Package=B9_Vehicle_meshes
#exec OBJ LOAD FILE=..\sounds\BuggySounds.uax Package=BuggySounds




// 'suspension' graphics that are updated to match wheel height
var const vector			ShockOffset[ kWheelLocationCount ];
var AssaultVehicleShock	Shock[ kWheelLocationCount ];

var AssaultVehicleDriverDoor	fAssaultVehicleDriverDoor;

/*
// taillight - indicates if you are braking/reversing
var const vector	TailLightOffset;
var AssaultVehicleTailLight	TailLight[2];
var (AssaultVehicle) byte	TailLightBrightness;
*/

/*
// Back gun WeaponTurret, with starting position relative to car
var AssaultVehicleTurret		Turret;
var vector			TurretOffset;
*/

/*
// Shadow-casting projector
var AssaultVehicleShadow		Shadow;
var vector			ShadowOffset;
*/

// Used to prevent triggering sounds continuously
var float			UntilNextImpact;

/*
var AssaultVehicleDust		Dust;
*/

/*
// Distance below centre of tire to place dust.
var float			DustDrop;
*/

/*
// Ratio between dust kicked up and amount wheels are slipping
var (AssaultVehicle) float	DustSlipRate;
var (AssaultVehicle) float   DustSlipThresh;
*/

// Maximum speed at which you can get in the vehicle.
//var (AssaultVehicle) float	TriggerSpeedThresh;
//var bool			TriggerState; // true for on, false for off.

// AssaultVehicle sound things
var (AssaultVehicle) float	EnginePitchScale;
var (AssaultVehicle) sound	AssaultVehicleStartSound;
var (AssaultVehicle) sound	AssaultVehicleIdleSound;
var (AssaultVehicle) float	HitSoundThreshold;
var (AssaultVehicle) sound	AssaultVehicleSquealSound;
var (AssaultVehicle) float	SquealVelThresh;
var (AssaultVehicle) sound	AssaultVehicleHitSound;

var int		MaxSparks;
var float	ChipsPerSpark;




function PostBeginPlay()
{
	local vector	rotX, rotY, rotZ;
    local int		i;
	local vector	lPos;
	local int		offset;


    Super.PostBeginPlay();

    GetAxes( Rotation, rotX, rotY, rotZ );

/*
	offset	= 75;
    for ( i = 0; i < kWheelLocationCount; i++ )
    {
		lPos	= WheelPos[ i ];

        shock[ i ].oppRot	= ( i & 1 ) == 1;

        if ( shock[ i ].oppRot )
		{
			lPos.X	-= offset;
		}
		else
		{
			lPos.X	+= offset;
		}
        shock[ i ]	= spawn( class'AssaultVehicleShock', self, , Location + ( lPos >> Rotation ) );
        shock[ i ].SetRotation( Rotation );
        shock[ i ].SetBase( self );
        if ( shock[ i ].oppRot )
        {
            shock[ i ].SetDrawScale3D( vect( -1, 1, 1 ) );
        }

	    shock[ i ].Joint = Wheel[ i ].WheelJoint;
    }
*/

/*
    // Create turret and turret-base
    Turret = spawn(class'AssaultVehicleTurret', self,, Location + (TurretOffset >> Rotation));
*/

	// trigger
	fOperatorTrigger	= Spawn( class'B9_VehicleTrigger', Self, , Location + fOperatorTriggerOffset.X * RotX + fOperatorTriggerOffset.Y * RotY + fOperatorTriggerOffset.Z * RotZ );
	fOperatorTrigger.SetBase( self );
	fOperatorTrigger.SetCollision( true, false, false );
	fOperatorTrigger.Set( 'nowpn_rover_enter', 'nowpn_rover_driving', 'nowpn_rover_exit', fOperatorTriggerOffset );
//	TriggerState	= true;

	// driver door
	fAssaultVehicleDriverDoor	= Spawn( class'AssaultVehicleDriverDoor', Self, , Location, Rotation );
	fAssaultVehicleDriverDoor.SetBase( Self );

/*
	// Create tail-lights
	TailLight[0] = spawn(class'AssaultVehicleTailLight', self,, Location + TaillightOffset.X * RotX + TaillightOffset.Y * RotY + TaillightOffset.Z * RotZ);
	TailLight[0].SetBase(self);

	TailLight[1] = spawn(class'AssaultVehicleTailLight', self,, Location - TaillightOffset.X * RotX + TaillightOffset.Y * RotY + TaillightOffset.Z * RotZ);
	TailLight[1].SetBase(self);
*/

/*
	Dust = spawn(class'AssaultVehicleDust', self,, Location);
	Dust.SetEmitterPositions(self);
	//Dust.SetBase(self);
*/

/*
	// Spawn AssaultVehicle shadow-projector.

	Shadow = spawn(class'AssaultVehicleShadow', self,, Location + (ShadowOffset >> Rotation) );
	Shadow.SetBase(self);
	Shadow.SetRelativeRotation(Rot(-16384,0,-16384));
*/

    // For KImpact event
    KSetImpactThreshold(HitSoundThreshold);
}

function Sparks( actor other, vector hitLocation, vector hitVelocity, vector hitNormal )
{
	local int	sparksCount;
	local int	i;
	local Actor	chip;


	sparksCount	= MaxSparks * FClamp( Abs( VSize( hitVelocity ) / 1000.0 ), 0.0, 1.0 );

	for ( i = 0; i < sparksCount; ++i )
	{
		if ( FRand() < ChipsPerSpark ) 
		{
			chip	= Spawn( class'B9_Chip',,, hitLocation + 8 * hitNormal );
			if ( chip != None )
			{
				chip.RemoteRole = ROLE_None;
			}
		}
		else
		{
			Spawn( class'B9_Spark',,, hitLocation + 8 * hitNormal );
		}
	}
}

function KImpact(actor other, vector pos, vector impactVel, vector impactNorm)
{
	local float impactVolume;

    if(other != None)
        return;


	impactVolume	= FClamp( Abs( VSize( impactVel ) / 1000.0 ), 0.0, 1.0 );

    if(UntilNextImpact < 0)
    {
        PlaySound( AssaultVehicleHitSound, , impactVolume );

        // hack to stop the sound repeating rapidly on impacts
        UntilNextImpact = GetSoundDuration(AssaultVehicleHitSound) / 2;

//		if ( Other.bWorldGeometry || ( Mover(Other) != None ) )
//		{
			Sparks( other, pos, impactVel, impactNorm );
//		}
    }
}

event DriverEnter( Pawn p )
{
	Super.DriverEnter( p );

	fAssaultVehicleDriverDoor.Toggle();

	PlaySound( AssaultVehicleStartSound );

	AmbientSound	= AssaultVehicleIdleSound;
}

event DriverLeave()
{
	Super.DriverLeave();

	fAssaultVehicleDriverDoor.Toggle();

	AmbientSound	= None;
}

function PreSequence( Pawn user )
{
	fAssaultVehicleDriverDoor.Toggle();
}

function PostSequence( Pawn user )
{
	fAssaultVehicleDriverDoor.Toggle();
}

function Tick(float Delta)
{
    local int i;
	local vector RotX, RotY, RotZ, worldPos;
    Local float TotalSlip, EnginePitch, VMag;

    Super.Tick(Delta);

	// If car is not actually being driven, assume brake is 'handbrake'
	if(Driver != None)
	{
/*
		// Update brake light colors.
		if(Gear == -1 && Brake == 0)
		{
			TailLight[0].LightSaturation = 255;
			TailLight[0].bCorona = True;
			TailLight[1].LightSaturation = 255;
			TailLight[1].bCorona = True;

		}
		else if(Gear == 0 && Brake == 1)
		{
			TailLight[0].LightSaturation = 0;
			TailLight[0].bCorona = True;
			TailLight[1].LightSaturation = 0;
			TailLight[1].bCorona = True;
		}
		else
		{
			TailLight[0].bCorona = False;
			TailLight[1].bCorona = False;
		}
*/
	}

    UntilNextImpact -= Delta;

	// This assume the sound is an idle-ing sound, and increases with pitch
	// as wheels speed up.
	EnginePitch = 64 + ((WheelSpinSpeed/EnginePitchScale) * (255-64));
    SoundPitch = FClamp(EnginePitch, 0, 254);
	//Log("Engine Pitch:"$SoundPitch);
    //SoundVolume = 255;

    // Currently, just use rear wheels for slipping noise
    TotalSlip = Wheel[ kRearLeft ].GroundSlipVel + Wheel[ kRearRight ].GroundSlipVel;
    //log("TotalSlip:"$TotalSlip);
	if(TotalSlip > SquealVelThresh)
	{
		Wheel[ kRearLeft ].AmbientSound = AssaultVehicleSquealSound;
	}
	else
	{
		Wheel[ kRearLeft ].AmbientSound = None;
	}

/*
	// Update dust kicked up by wheels.
	Dust.UpdateDust(self);
*/

/*
	// If vehicle is moving, disable collision for trigger.
	VMag = VSize(Velocity);
	if(VMag > TriggerSpeedThresh && TriggerState == true)
	{
		fOperatorTrigger.SetCollision(False, False, False);
		TriggerState = false;
	}
	else if(VMag < TriggerSpeedThresh && TriggerState == false)
	{
		fOperatorTrigger.SetCollision(True, False, False);
		TriggerState = true;
	}
*/
}

defaultproperties
{
	ShockOffset[0]=(X=-24,Y=-132,Z=24)
	ShockOffset[1]=(X=24,Y=-132,Z=24)
	ShockOffset[2]=(X=-24,Y=144,Z=24)
	ShockOffset[3]=(X=24,Y=144,Z=24)
	ShockOffset[4]=(X=-24,Y=144,Z=24)
	ShockOffset[5]=(X=24,Y=144,Z=24)
	EnginePitchScale=655350
	AssaultVehicleStartSound=Sound'BuggySounds.Engine.AWBuggyStart2'
	AssaultVehicleIdleSound=Sound'BuggySounds.Engine.AWBuggyIdle2'
	HitSoundThreshold=30
	AssaultVehicleSquealSound=Sound'BuggySounds.Tires.AWBuggySqueal'
	SquealVelThresh=15
	AssaultVehicleHitSound=Sound'BuggySounds.Impact.AWBuggyHit'
	MaxSparks=100
	ChipsPerSpark=0.5
	WheelPos[0]=(X=240,Y=-175,Z=20)
	WheelPos[1]=(X=240,Y=175,Z=20)
	WheelPos[2]=(X=-150,Y=-200,Z=20)
	WheelPos[3]=(X=-150,Y=200,Z=20)
	WheelPos[4]=(X=-280,Y=-200,Z=20)
	WheelPos[5]=(X=-280,Y=200,Z=20)
	TireClass=Class'AssaultVehicleTire'
	MaxSteerAngle=2900
	MaxBrakeTorque=55
	SteerPropGap=500
	SteerTorque=15000
	SteerSpeed=20000
	SuspStiffness=300
	SuspDamping=12
	TireRollFriction=0.7
	TireLateralFriction=1.4
	TireRollSlip=0.006
	TireLateralSlip=0.04
	TireSlipRate=0.005
	TireSoftness=0
	TireHandbrakeSlip=0.2
	TireHandbrakeFriction=-0.9
	ChassisMass=10
	StopThreshold=40
	TorqueCurve=(Points=/* Array type was not detected. */,InVal=0,OutVal=250)
	Brake=1
	fOperatorTriggerOffset=(X=60,Y=-240,Z=0)
	CamPos=(W=0,X=0,Y=0,Z=130)
	AirSpeed=5000
	DrawType=8
	StaticMesh=StaticMesh'B9_Vehicle_meshes.Assault_Vehicle.AV_chassis'
	SoundRadius=255
	begin object name=KParams0 class=KarmaParamsRBFull
	// Object Offset:0x0000F060
	KInertiaTensor[0]=10
	KInertiaTensor[3]=7
	KInertiaTensor[5]=14.5
	KCOMOffset=(X=0,Y=0.4,Z=-0.6)
	KLinearDamping=0
	KAngularDamping=0
	KStartEnabled=true
object end
// Reference: KarmaParamsRBFull'AssaultVehicle.KParams0'
KParams=KParams0
}