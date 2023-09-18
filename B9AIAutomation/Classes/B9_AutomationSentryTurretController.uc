//////////////////////////////////////////////////////////////////////////
//
// Black 9 Automation Sentry Turret Controller
//
//////////////////////////////////////////////////////////////////////////

class B9_AutomationSentryTurretController extends B9_AI_ControllerBase;

//////////////////////////////////
// Variables
//

var			float fThinkTimerInterval;
var			float fLastFireTime;
var float	fWarmupTimer;
const		kWarmupTime = 1.5;
var Sound	fAmbSound;


//////////////////////////////////
// Functions
//

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	fLastFireTime = Level.TimeSeconds;
	
	SetTimer( fThinkTimerInterval, true );
}

simulated function Timer()
{
	AcquireTarget();
}

function AcquireTarget()
{
	local B9_BasicPlayerPawn assailPawn;
	local float rangeToTarget, closestTarget;
	
	// Set closest target to an impossibly large value.
	closestTarget	= 9999999.0;
	assailPawn		= None;

	// Attack just the player
	ForEach Pawn.VisibleActors( class'B9_BasicPlayerPawn', assailPawn, B9_AutomationSentryGun( Pawn ).fMaxRange )
	{
		if( assailPawn != B9_AdvancedPawn( Pawn ) && assailPawn.Health > 0 )
		{
			rangeToTarget = VSize( Pawn.Location - assailPawn.Location );
			if( rangeToTarget < B9_AutomationSentryGun( Pawn ).fMaxRange && rangeToTarget < closestTarget )
			{
				closestTarget	= rangeToTarget;
				Enemy			= assailPawn;
			}
		}
	}

	// If a new target has been aquired, attempt to attack immediately
  	if( closestTarget < B9_AutomationSentryGun( Pawn ).fMaxRange )
  	{
		if( !IsInState( 'Attack' ) )
		{
            GotoState( 'Attack' );
		}
  	}
	else
	{
		Enemy = None;
		if( !IsInState( 'Idle' ) )
		{
            GotoState( 'Idle' );
		}
	}
}

// Gets the direction to the enemy in the form of a rotator (yaw,pitch,roll)
function rotator GetRotatorToEnemy(optional float Delta)
{
	return rotator(GetVectorToEnemy(Delta));
}

function vector GetVectorToEnemy(optional float Delta)
{
	// let's consider the Enemy's velocity (note that Delta == 0 is OK)
	return Enemy.Location + Enemy.Velocity * Delta - B9_Automation( Pawn ).fGunPart.Location;
}

function float GetIdleScanYaw()
{
	return 20.0f;
}

function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
	return B9_Automation( Pawn ).fGunPart.Rotation;
}

//////////////////////////////////
// States
//

auto state Idle
{
ignores SeePlayer;

	simulated function BeginState()
	{
		fWarmupTimer = kWarmupTime;
	}

	simulated function Tick( float Delta )
	{
		if( fWarmupTimer > 0 )
		{
			fWarmupTimer -= Delta;
			return;
		}

		B9_Automation( Pawn ).RotateShaft( GetIdleScanYaw() );
		B9_Automation( Pawn ).AmbientSound	= fAmbSound;
	}
}

state Attack
{
ignores SeePlayer;

	simulated function BeginState()
	{
		B9_Automation( Pawn ).AmbientSound = None;
		PlayOwnedSound( sound'B9SoundFX.Mech.mech_head_move', SLOT_Talk, 1.0, false, 250 );
		fWarmupTimer = kWarmupTime;
	}


	simulated function Tick( float Delta )
	{
		if( Enemy == None )
		{
			GotoState( '' );
			return;
		}

		B9_Automation( Pawn ).OrientV( GetVectorToEnemy(Delta), Delta );

		if( fWarmupTimer > 0 )
		{
			fWarmupTimer -= Delta;
			return;
		}

		if( Level.TimeSeconds - fLastFireTime > B9_AutomationSentryGun( Pawn ).fFiringInterval )
		{
			fLastFireTime = Level.TimeSeconds;
			B9_AutomationSentryGun( Pawn ).Fire(1);
		}
	}
}






defaultproperties
{
	fThinkTimerInterval=0.25
	fAmbSound=Sound'B9Fixtures_sounds.SecurityCameras.camera_pan_loop3'
	AttitudeToPlayer=1
}