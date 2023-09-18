//=============================================================================
// B9MeleeWeapon.uc
//
// Base class for melee weapons
// Only real use is for type-checking when you need to tell
// a heavy weapon from a light weapon
// 
//=============================================================================


class B9MeleeWeapon extends B9WeaponBase
	abstract;

var	  float	   fDamageRadius;        
var   float	   fMomentumTransfer; // Momentum magnitude imparted by impacting projectile.

simulated function Fire( float Value )
{
	if( !CanFire() )
	{
		return;
	}

	SetActionExclusivity( true );

	ServerFire();

	if( Role < ROLE_Authority )
	{
		LocalFire();
		GotoState('ClientFiring');
	}
}

function ServerFire()
{
	if ( AmmoType == None )
	{
		GiveAmmo(Pawn(Owner));
	}
	
	LocalFire();
	GotoState('NormalFire');
}

simulated function ClientFinish()
{
	SetActionExclusivity( false );

	if ( (Instigator == None) || (Instigator.Controller == None) )
	{
		ClientStoppedPressingFire();
		GotoState('');
		return;
	}

	if ( Instigator.PressingFire() && !bChangeWeapon )
	{
		Global.Fire(0);
	}

	else
	{
		ClientStoppedPressingFire();

		if ( bChangeWeapon )
		{
			GotoState('DownWeapon');
		}
		else
		{
			GotoState('');
		}
	}
}

simulated state Reloading
{
	function ServerForceReload() {}
	function ClientForceReload() {}
	function Fire( float Value ) {}
	function AltFire( float Value ) {}
	function ServerFire() {}
	function ServerAltFire() {}
	simulated function bool PutDown() { return false; }
	simulated function AnimEnd(int Channel) {}
	function CheckAnimating() {}
	
	simulated function ClientFinish()
	{
		Global.ClientFinish();
	}

	simulated function BeginState()
	{
		bForceReload = false;
	}

	simulated function LoadGun() {}


Begin:
	
	if( Role == ROLE_Authority )
	{
		Finish();
	}
	else
	{
		ClientFinish();
	}
}


state NormalFire
{
	function Fire(float F) {}
	function AltFire(float F) {} 

	function FindTargetAndDamage(int dmgAmount, float momentumTransfer, class<DamageType> dmgClass)
	{
		local Pawn					targetPawn;
		local vector				targetDir, X;
		local bool					hitPawn;
		local bool					hitWall;

		// Search for B9_Pawn
		foreach RadiusActors( class'Pawn', targetPawn, fDamageRadius, Instigator.Location )
		{
			if ( targetPawn != Instigator )
			{
				// Need to check if the target is infront of us
				targetDir = targetPawn.Location - Instigator.Location;
				X = vector(Instigator.Rotation); // Returns normalized vector

				if ( X Dot targetDir > 0 )	// Smack him!
				{
					// Be back --> Need damage and momentum
					targetPawn.TakeDamage( dmgAmount, Instigator, targetPawn.Location, 
						momentumTransfer * X, dmgClass );
					hitPawn = true;
				}
			}
		}

		if (hitPawn)
		{
			//PlaySound( fHitActorSound, SLOT_None, 1.0 );
		}
		else if (hitWall)
		{
			//PlaySound( fHitWallSound, SLOT_None, 1.0 );
		}
	}

	function MeleeFire()
	{
		local B9_AdvancedPawn		P;
		local class <DamageType>	meleeDamageType;
		local int					meleeDamageAmount;


		P = B9_AdvancedPawn( Owner );
		if( P == None )
			return;

		P.bMeleeAttack = true;
		FindTargetAndDamage(fMeleeDamage, fMomentumTransfer, class'Impact');
	}

Begin:
	MeleeFire();
	Sleep( GetROF() );
	Finish();
}


