//=============================================================================
// B9SentryGunWeapon.uc
//
// Modified version of B9BaseWeapon, for use with Sentry Guns
//
// 
//=============================================================================


class B9SentryGunWeapon extends B9WeaponBase;


//////////////////////////////////
// Variables
//

// Instead of GetViewRotation() we use fReferenceActor.Rotation
// The object is most likely a dummy actor attached to a socket in the muzzle
//
var	Actor		fReferenceActor;	



//////////////////////////////////
// Functions
//

function CalcKick()
{
	fKickback = 0.0f;
}

function SetReferenceActor( Actor A )
{
	fReferenceActor = A;
}

simulated function Fire( float Value )
{
	log( "B9SentryGunWeapon::Fire()" );
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

	GotoState('NormalFire');
		
	if ( AmmoType.bInstantHit )
	{
		TraceFire( TraceAccuracy, 0, 0 );
	}
	else
	{
		ProjectileFire();
	}

	LocalFire();
}

function TraceFire( float Accuracy, float YOffset, float ZOffset )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;

	GetAxes( fReferenceActor.Rotation, X, Y, Z );
	StartTrace = GetFireStart( X, Y, Z ); 
	AdjustedAim = Instigator.AdjustAim( AmmoType, StartTrace, 0 );	
	EndTrace = StartTrace + 10000 * vector( AdjustedAim ); 
	Other = Trace( HitLocation, HitNormal, EndTrace, StartTrace, True );

//	Log("TraceFire Rot:"$fReferenceActor.Rotation$" ST:"$StartTrace$" AA:"$AdjustedAim$" Hit:"$Other$" Inst="$Instigator$" InstLoc="$Instigator.Location);

	if( Other == None )
	{
		HitLocation = EndTrace;
	}
	if( ThirdPersonActor != None )
	{
		B9_WeaponAttachment(ThirdPersonActor).HitLoc=HitLocation;
	}

	AmmoType.ProcessTraceHit(self, Other, HitLocation, HitNormal, X,Y,Z);
}

function ProjectileFire()
{
	local Vector Start, X,Y,Z;
	local Rotator rot;

	Owner.MakeNoise( GetNoiseLevel() );
	GetAxes( fReferenceActor.Rotation, X, Y, Z );
	B9_SentryWeaponAttachment( ThirdPersonActor ).GetEffectStart(Start, rot);
	AdjustedAim = Instigator.AdjustAim(AmmoType, Start, AimError);	
	AmmoType.SpawnProjectile(Start,AdjustedAim);	
}

//////////////////////////////////
// States
//



//////////////////////////////////
// Initialization
//




defaultproperties
{
	FireOffset=(X=40,Y=0,Z=0)
}