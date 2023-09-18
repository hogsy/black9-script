//=============================================================================
// BaseAttackSkill.uc
//
//	Base class for nano skills that are attacks
//
//=============================================================================


class BaseAttackSkill extends B9_Skill; 

var	Rotator					AdjustedAim;
var Vector					FireOffset;
var float					AimError;
var class<NanoProjectile>	ProjectileClass;
var class<Emitter>			fWarmupFXClass;
var Emitter					fWarmupFX;

var int						fDamage;
var int						fDamageRadius;

var Rotator				SavedAimRotation;


simulated function int GetDamageAmount()
{
	return 0;
}

simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
	local Pawn		P;
	local coords	C;
	local vector	V;
	
	P = Pawn( Owner );
	C = P.GetBoneCoords( 'NanoBone' );
	V = C.Origin;

	return (V + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z); 
}


function ServerActivate()
{
	local B9_AdvancedPawn	P;	
	local Controller		C;

	P = B9_AdvancedPawn( Owner );
	C = P.Controller;

    Owner.MakeNoise(1.0);
	P.PlayNanoAttack();


	if( fWarmupFXClass != None )
	{
		if( fWarmupFX != None )
		{
			fWarmupFX.Destroy();
			fWarmupFX = None;
		}

		fWarmupFX = Spawn( fWarmupFXClass, P, , P.Location, P.Rotation );
		P.AttachToBone( fWarmupFX, 'NanoBone' );
	}
}

simulated function Activate()
{
	local B9_AdvancedPawn P;

	P = B9_AdvancedPawn( Owner );
	if( Owner == None )
	{
		return;
	}

	if( !CanActivate() )
	{
		return;
	}	
	
	SetActionExclusivity( true );
	ServerActivate();


	// Client 
	//
	if( Role < ROLE_Authority )
	{
		P.PlayNanoAttack();

		if( fWarmupFXClass != None )
		{
			if( fWarmupFX != None )
			{
				fWarmupFX.Destroy();
				fWarmupFX = None;
			}

			fWarmupFX = Spawn( fWarmupFXClass, P, , P.Location, P.Rotation );
			P.AttachToBone( fWarmupFX, 'NanoBone' );
		}
	}
}

 // called after 'melee_nano' animation ends 
simulated function FireNano()
{
	local Vector Start, X,Y,Z;
	local B9_AdvancedPawn	P;
	local Controller		C;
	local B9_BasicPlayerPawn PP;
	local NanoProjectile	proj;

	SetActionExclusivity( false );

	if( fWarmupFX != None )
	{
		fWarmupFX.Destroy();
		fWarmupFX = None;
	}

	if( Role < Role_Authority )
	{
		return;
	}

	P = B9_AdvancedPawn( Owner );
	C = P.Controller;

	GetAxes( C.GetViewRotation(),X,Y,Z);
	Start = GetFireStart(X,Y,Z);
	AdjustedAim = C.AdjustAim(None, Start, AimError);	

	if( ProjectileClass != none )
	{
      proj = Spawn(ProjectileClass, Owner, , Start, AdjustedAim);
	  if( proj != None )
	  {
		  proj.SetDamageLevels( fDamage, fDamageRadius );
	  }
	}

	UseFocus();
}

function AIActivate( Rotator aimRotation )
{
	local B9_AdvancedPawn	P;	
	local Controller		C;
	

	if( !CheckFocus() )
	{
		return;
	}

	P = B9_AdvancedPawn( Owner );
	C = P.Controller;

	SavedAimRotation = aimRotation;
	Owner.MakeNoise(1.0);
	P.PlayNanoAttack();
}


defaultproperties
{
	FireOffset=(X=20,Y=0,Z=0)
	fDamage=1
	fDamageRadius=1
}