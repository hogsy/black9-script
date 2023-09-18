//=============================================================================
// B9_AutomationSentryTurret
//
// The orignal sentry gun class, changed over so that the level designers
// don't have to place them all over again.
//=============================================================================

class B9_AutomationSentryTurret extends B9_AutomationSentryGun
	placeable;


var float	fFireTimer;
var int		fShotsFired;
const		kShotsToFire	= 6;
const		kDelayPerShot	= 0.25;


simulated function Fire( float value )
{
	GotoState( 'FireSequence' );
}


state FireSequence
{
	simulated function Fire( float value ) {}

	simulated function BeginState()
	{
		fFireTimer	= 0.0;
		fShotsFired	= 0;
	}

	simulated function Tick( float Delta )
	{
		if( fShotsFired < kShotsToFire )
		{
			fFireTimer += Delta;
			if( fFireTimer >= kDelayPerShot )
			{
				fFireTimer = 0.0;
				Shoot();
			}
		}
		else
		{
			GotoState( '' );
		}
	}

	simulated function Shoot()
	{
		log( "B9_AutomationSentryTurret::FireSequence::Shoot()" );

		fShotsFired++;

		if( fBarrelToUse == 0 )
		{
		//	Log("Turret "$int(Location.Z)$" Wpn A:"$fWeaponA.ThirdPersonActor.Rotation$" "$fWeaponA.ThirdPersonActor.Location);
			fBarrelToUse = 1;
            fWeaponA.Fire( 0.0 );
		}
		else
		{
		//	Log("Turret "$int(Location.Z)$" Wpn B:"$fWeaponB.ThirdPersonActor.Rotation$" "$fWeaponB.ThirdPersonActor.Location);
			fBarrelToUse = 0;
            fWeaponB.Fire( 0.0 );
		}
	}

Begin:

	Shoot();
}


//////////////////////////////////
// Initialization
//


defaultproperties
{
	fWeaponClass=Class'Sentry_Machinegun_Weapon'
	fMaxRange=4000
	fStartingHealth=100
	fFiringInterval=3
	fRateOfFire=3
	fCharacterMaxHealth=100
	Health=100
	AmbientSound=Sound'B9Fixtures_sounds.SecurityCameras.camera_pan_loop4'
	SoundRadius=250
	SoundVolume=100
}