#exec OBJ LOAD FILE=..\staticmeshes\ATV_Meshes.usx
#exec OBJ LOAD FILE=..\sounds\WeaponSounds.uax
#exec OBJ LOAD FILE=..\textures\BulldogSkin.utx

class Bulldog extends KCar
    placeable;

// triggers used to get into the Bulldog
var const vector	FrontTriggerOffset;
var BulldogTrigger	FLTrigger, FRTrigger, FlipTrigger;


// headlight projector
var const vector		HeadlightOffset;
var BulldogHeadlight	Headlight;
var bool				HeadlightOn;

// Light materials
var Material			ReverseMaterial;
var Material			BrakeMaterial;
var Material			TailOffMaterial;

var Material			HeadlightOnMaterial;
var Material			HeadlightOffMaterial;

var BulldogHeadlightCorona HeadlightCorona[8];
var (Bulldog) vector	HeadlightCoronaOffset[8];

// Used to prevent triggering sounds continuously
var float			UntilNextImpact;

// Wheel dirt emitter
var BulldogDust		Dust[4]; // FL, FR, RL, RR

// Distance below centre of tire to place dust.
var float			DustDrop;

// Ratio between dust kicked up and amount wheels are slipping
var (Bulldog) float	DustSlipRate;
var (Bulldog) float DustSlipThresh;

// Maximum speed at which you can get in the vehicle.
var (Bulldog) float	TriggerSpeedThresh;
var bool			TriggerState; // true for on, false for off.
var bool			FlipTriggerState;

// Destroyed Buggy
var (Bulldog) class<Actor>	DestroyedEffect;
var (Bulldog) sound			DestroyedSound;

// Weapon
var			  float	FireCountdown;
var			  float SinceLastTargetting;
var			  Pawn  CurrentTarget;

var (Bulldog) float		FireInterval;
var (Bulldog) float		TargettingInterval;
var (Bulldog) vector	RocketFireOffset; // Position (car ref frame) that rockets are launched from
var (Bulldog) float     TargettingRange;
var (Bulldog) Material	TargetMaterial;


// Bulldog sound things
var (Bulldog) float	EnginePitchScale;
var (Bulldog) sound	BulldogStartSound;
var (Bulldog) sound	BulldogIdleSound;
var (Bulldog) float	HitSoundThreshold;
var (Bulldog) sound	BulldogSquealSound;
var (Bulldog) float	SquealVelThresh;
var (Bulldog) sound	BulldogHitSound;

var (Bulldog) String BulldogStartForce;
var (Bulldog) String BulldogIdleForce;
var (Bulldog) String BulldogSquealForce;
var (Bulldog) String BulldogHitForce;

replication
{
	reliable if(Role == ROLE_Authority)
		HeadlightOn, CurrentTarget;
}

function PreBeginPlay()
{
	Super.PreBeginPlay();
	if ( Level.IsDemoBuild() )
		Destroy();
}

simulated function PostNetBeginPlay()
{
	local vector RotX, RotY, RotZ;
	local int i;

    Super.PostNetBeginPlay();

    GetAxes(Rotation,RotX,RotY,RotZ);

	// Only have triggers on server
	if(Level.NetMode != NM_Client)
	{
		// Create triggers for gettting into the Bulldog
		FLTrigger = spawn(class'BulldogTrigger', self,, Location + FrontTriggerOffset.X * RotX + FrontTriggerOffset.Y * RotY + FrontTriggerOffset.Z * RotZ);
		FLTrigger.SetBase(self);
		FLTrigger.SetCollision(true, false, false);

		FRTrigger = spawn(class'BulldogTrigger', self,, Location + FrontTriggerOffset.X * RotX - FrontTriggerOffset.Y * RotY + FrontTriggerOffset.Z * RotZ);
		FRTrigger.SetBase(self);
		FRTrigger.SetCollision(true, false, false);

		TriggerState = true;

		// Create trigger for flipping the bulldog back over.
		FlipTrigger = spawn(class'BulldogTrigger', self,, Location);
		Fliptrigger.bCarFlipTrigger = true;
		FlipTrigger.SetBase(self);
		FlipTrigger.SetCollisionSize(350, 200);
		FlipTrigger.SetCollision(false, false, false);

		FlipTriggerState = false;
	}

	// Dont bother making emitters etc. on dedicated server
	if(Level.NetMode != NM_DedicatedServer)
	{
		// Create headlight projector. We make sure it doesn't project on the vehicle itself.
		Headlight = spawn(class'BulldogHeadlight', self,, Location + HeadlightOffset.X * RotX + HeadlightOffset.Y * RotY + HeadlightOffset.Z * RotZ);
		Headlight.SetBase(self);
		Headlight.SetRelativeRotation(rot(-2000, 32768, 0));

		// Create wheel dust emitters.
		Dust[0] = spawn(class'BulldogDust', self,, Location + WheelFrontAlong*RotX + WheelFrontAcross*RotY + (WheelVert-DustDrop)*RotZ);
		Dust[0].SetBase(self);

		Dust[1] = spawn(class'BulldogDust', self,, Location + WheelFrontAlong*RotX - WheelFrontAcross*RotY + (WheelVert-DustDrop)*RotZ);
		Dust[1].SetBase(self);	

		Dust[2] = spawn(class'BulldogDust', self,, Location + WheelRearAlong*RotX + WheelRearAcross*RotY + (WheelVert-DustDrop)*RotZ);
		Dust[2].SetBase(self);

		Dust[3] = spawn(class'BulldogDust', self,, Location + WheelRearAlong*RotX - WheelRearAcross*RotY + (WheelVert-DustDrop)*RotZ);
		Dust[3].SetBase(self);

		// Set light materials
		Skins[1]=BrakeMaterial;
		Skins[2]=HeadlightOffMaterial;

		// Spawn headlight coronas
		for(i=0; i<8; i++)
		{
			HeadlightCorona[i] = spawn(class'BulldogHeadlightCorona', self,, Location + (HeadlightCoronaOffset[i] >> Rotation) );
			HeadlightCorona[i].SetBase(self);
		}
	}

    // For KImpact event
    KSetImpactThreshold(HitSoundThreshold);

	// If this is not 'authority' version - don't destroy it if there is a problem. 
	// The network should sort things out.
	if(Role != ROLE_Authority)
	{
		KarmaParams(KParams).bDestroyOnSimError = False;
		KarmaParams(frontLeft.KParams).bDestroyOnSimError = False;
		KarmaParams(frontRight.KParams).bDestroyOnSimError = False;
		KarmaParams(rearLeft.KParams).bDestroyOnSimError = False;
		KarmaParams(rearRight.KParams).bDestroyOnSimError = False;
	}
}

simulated event Destroyed()
{
	local int i;

	//Log("Bulldog Destroyed");

	// Clean up random stuff attached to the car
	if(Level.NetMode != NM_Client)
	{

		FLTrigger.Destroy();
		FRTrigger.Destroy();
		FlipTrigger.Destroy();
	}

	if(Level.NetMode != NM_DedicatedServer)
	{
		Headlight.Destroy();

		for(i=0; i<4; i++)
			Dust[i].Destroy();

		for(i=0; i<8; i++)
			HeadlightCorona[i].Destroy();
	}

	// This will destroy wheels & joints
	Super.Destroyed();

	// Trigger destroyed sound and effect
	if(Level.NetMode != NM_DedicatedServer)
	{
		if(DestroyedEffect != None)
			spawn(DestroyedEffect, self, , Location );

		if(DestroyedSound != None)
			PlaySound(DestroyedSound);
	}
}

function KImpact(actor other, vector pos, vector impactVel, vector impactNorm)
{
    /* Only make noises for Bulldog-world impacts */
    if(other != None)
        return;

    if(UntilNextImpact < 0)
    {
        //PlaySound(BulldogHitSound);

        // hack to stop the sound repeating rapidly on impacts
        //UntilNextImpact = GetSoundDuration(BulldogHitSound);
        
        
    }
}

simulated function ClientKDriverEnter(PlayerController pc)
{
	//Log("Bulldog ClientKDriverEnter");

	Super.ClientKDriverEnter(pc);
}

function KDriverEnter(Pawn p)
{
	//Log("Bulldog KDriverEnter");

	Super.KDriverEnter(p);

	//PlaySound(BulldogStartSound);

	//AmbientSound=BulldogIdleSound;

	p.bHidden = True;
	ReceiveLocalizedMessage(class'Vehicles.BulldogMessage', 1);
}

simulated function ClientKDriverLeave(PlayerController pc)
{
	//Log("Bulldog ClientKDriverLeave");

	Super.ClientKDriverLeave(pc);
}

function bool KDriverLeave(bool bForceLeave)
{
	local Pawn OldDriver;

	//Log("Bulldog KDriverLeave");

	OldDriver = Driver;

	// If we succesfully got out of the car, make driver visible again.
	if( Super.KDriverLeave(bForceLeave) )
	{
		OldDriver.bHidden = false;
		AmbientSound = None;	
		return true;
	}
	else
		return false;
}

simulated function Tick(float Delta)
{
    Local float TotalSlip, EnginePitch, VMag;
	local int i;

    Super.Tick(Delta);

	if(Role == ROLE_Authority)
	{
		// Only put headlights on when driver is in. Save batteries!
		if(Driver != None)
			HeadlightOn=true;
		else
			HeadlightOn=false;
	}

	// Dont bother doing effects on dedicated server.
	if(Level.NetMode != NM_DedicatedServer)
	{
		// Update brake light colors.
		if(Gear == -1 && OutputBrake == false)
		{
			// REVERSE
			Skins[1] = ReverseMaterial;
		}
		else if(Gear == 0 && OutputBrake == true)
		{
			// BRAKE
			Skins[1] = BrakeMaterial;
		}
		else
		{
			// OFF
			Skins[1] = TailOffMaterial;
		}

		// Set headlight projector state.
		Headlight.DetachProjector();
		if(HeadlightOn)
		{
			Headlight.AttachProjector();
			Skins[2] = HeadlightOnMaterial;
			for(i=0; i<8; i++)
				HeadlightCorona[i].bHidden = false;
		}
		else
		{
			Skins[2] = HeadlightOffMaterial;
			for(i=0; i<8; i++)
				HeadlightCorona[i].bHidden = true;
		}

		// Update dust kicked up by wheels.
		Dust[0].UpdateDust(frontLeft, DustSlipRate, DustSlipThresh);
		Dust[1].UpdateDust(frontRight, DustSlipRate, DustSlipThresh);
		Dust[2].UpdateDust(rearLeft, DustSlipRate, DustSlipThresh);
		Dust[3].UpdateDust(rearRight, DustSlipRate, DustSlipThresh);
	}

    UntilNextImpact -= Delta;

	// This assume the sound is an idle-ing sound, and increases with pitch
	// as wheels speed up.
	EnginePitch = 64 + ((WheelSpinSpeed/EnginePitchScale) * (255-64));
    SoundPitch = FClamp(EnginePitch, 0, 254);
	//Log("Engine Pitch:"$SoundPitch);
    //SoundVolume = 255;

    // Currently, just use rear wheels for slipping noise
    TotalSlip = rearLeft.GroundSlipVel + rearRight.GroundSlipVel;
    //log("TotalSlip:"$TotalSlip);
	if(TotalSlip > SquealVelThresh)
	{
		rearLeft.AmbientSound = BulldogSquealSound;
	}
	else
	{
		rearLeft.AmbientSound = None;
	}

	// Dont have triggers on network clients.
	if(Level.NetMode != NM_Client)
	{
		// If vehicle is moving, disable collision for trigger.
		VMag = VSize(Velocity);

		if(!bIsInverted && VMag < TriggerSpeedThresh && TriggerState == false)
		{
			FLTrigger.SetCollision(true, false, false);
			FRTrigger.SetCollision(true, false, false);
			TriggerState = true;
		}
		else if((bIsInverted || VMag > TriggerSpeedThresh) && TriggerState == true)
		{
			FLTrigger.SetCollision(false, false, false);
			FRTrigger.SetCollision(false, false, false);
			TriggerState = false;
		}

		// If vehicle is inverted, and slow, turn on big 'flip vehicle' trigger.
		if(bIsInverted && VMag < TriggerSpeedThresh && FlipTriggerState == false)
		{
			FlipTrigger.SetCollision(true, false, false);
			FlipTriggerState = true;	
		}
		else if((!bIsInverted || VMag > TriggerSpeedThresh) && FlipTriggerState == true)
		{
			FlipTrigger.SetCollision(false, false, false);
			FlipTriggerState = false;
		}
	}
}

// Really simple at the moment!
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	// Avoid damage healing the car!
	if(Damage < 0)
		return;

	Health -= 0.5 * Damage; // Weapons do less damage

	// The vehicle is dead!
	if(Health <= 0)
	{
		if ( Controller != None )
		{
			if( Controller.bIsPlayer )
			{
				ClientKDriverLeave(PlayerController(Controller)); // Just to reset HUD etc.
				Controller.PawnDied(self); // This should unpossess the controller and let the player respawn
			}
			else
				Controller.Destroy();
		}

		Destroy(); // Destroy the vehicle itself (see Destroyed below)
	}

    //KAddImpulse(momentum, hitlocation);
}

defaultproperties
{
	FrontTriggerOffset=(X=0,Y=165,Z=10)
	HeadlightOffset=(X=-200,Y=0,Z=50)
	ReverseMaterial=Shader'BulldogSkin.Lights.Unlit_Reverselight'
	BrakeMaterial=Shader'BulldogSkin.Lights.Unlit_Brakelight'
	TailOffMaterial=Texture'BulldogSkin.Lights.TailLight'
	HeadlightOnMaterial=Shader'BulldogSkin.Lights.Unlit_Headlight'
	HeadlightOffMaterial=Texture'BulldogSkin.Lights.Headlights'
	HeadlightCoronaOffset[0]=(X=-199,Y=51,Z=57)
	HeadlightCoronaOffset[1]=(X=-199,Y=-51,Z=57)
	HeadlightCoronaOffset[2]=(X=-128,Y=38,Z=125)
	HeadlightCoronaOffset[3]=(X=-189,Y=93,Z=28)
	HeadlightCoronaOffset[4]=(X=-183,Y=-93,Z=26)
	HeadlightCoronaOffset[5]=(X=-190,Y=-51,Z=77)
	HeadlightCoronaOffset[6]=(X=-128,Y=63,Z=123)
	HeadlightCoronaOffset[7]=(X=-185,Y=85,Z=10)
	UntilNextImpact=500
	DustDrop=30
	DustSlipRate=2.8
	DustSlipThresh=0.1
	TriggerSpeedThresh=40
	FireInterval=0.9
	TargettingInterval=0.5
	RocketFireOffset=(X=0,Y=0,Z=180)
	TargettingRange=5000
	EnginePitchScale=655350
	HitSoundThreshold=30
	SquealVelThresh=15
	FrontTireClass=Class'BulldogTire'
	RearTireClass=Class'BulldogTire'
	WheelFrontAlong=-100
	WheelFrontAcross=110
	WheelRearAlong=115
	WheelRearAcross=110
	WheelVert=-15
	MaxSteerAngle=3400
	MaxBrakeTorque=55
	TorqueSplit=1
	SteerPropGap=500
	SteerTorque=15000
	SteerSpeed=20000
	SuspStiffness=150
	SuspDamping=14.5
	SuspHighLimit=0.5
	SuspLowLimit=-0.5
	TireRollFriction=1.5
	TireLateralFriction=1.5
	TireRollSlip=0.06
	TireLateralSlip=0.04
	TireSlipRate=0.007
	TireSoftness=0
	TireHandbrakeSlip=0.2
	TireHandbrakeFriction=-1.2
	ChassisMass=8
	StopThreshold=40
	TorqueCurve=(Points=/* Array type was not detected. */,InVal=0,OutVal=270)
	OutputBrake=true
	ExitPositions=/* Array type was not detected. */
	DrivePos=(X=-165,Y=0,Z=-100)
	AirSpeed=5000
	Health=800
	DrawType=8
	StaticMesh=StaticMesh'ATV_Meshes.Bulldog.S_Chassis'
	DrawScale=0.4
	SoundRadius=255
	begin object name=KParams0 class=KarmaParamsRBFull
	// Object Offset:0x00072935
	KInertiaTensor[0]=20
	KInertiaTensor[3]=30
	KInertiaTensor[5]=48
	KCOMOffset=(X=0.8,Y=0,Z=-0.7)
	KLinearDamping=0
	KAngularDamping=0
	KStartEnabled=true
	bHighDetailOnly=false
	bClientOnly=false
	bKDoubleTickRate=true
	KFriction=1.6
object end
// Reference: KarmaParamsRBFull'Bulldog.KParams0'
KParams=KParams0
}