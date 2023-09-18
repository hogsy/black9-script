//=============================================================================
// B9_AmbientPawn
//
// Generic AmbientPawn for Black9 game
//
// 
//=============================================================================

class B9_AmbientPawn extends AmbientPawn
	abstract;

var string PawnName;
var public bool fInHeadquarters;

enum ESpecialAnimation
{
	kSuddenStop
};

enum EMovementDirection
{
	kMoveForward,
	kMoveLeft,
	kMoveRight,
	kMoveBack
};

event PostBeginPlay()
{
	local B9_CalibrationMaster CalMaster;

	Super.PostBeginPlay();
	
	ForEach AllActors(class'B9_CalibrationMaster', CalMaster, 'HQListener')
	{
		break;
	}

	fInHeadquarters = (CalMaster != None && CalMaster.GameInHeadquarters());
}

// no telefrag in HQ
event EncroachedBy( actor Other )
{
	if ( !fInHeadquarters && Pawn(Other) != None )
		gibbedBy(Other);
}

function PlaySpecialAnimation( ESpecialAnimation animation )
{
}

function EMovementDirection GetMovementDirection()
{
	local int Facing;

	if ( VSize(Acceleration) == 0 )
	{
		return kMoveForward;
	}

	// determine facing direction
	Facing = Controller.GetFacingDirection();
	if ( (Facing < 8192) || (Facing > 57344) )
	{
		return kMoveForward;
	}
	else if ( Facing < 24576 )
	{
		return kMoveLeft;
	}
	else if ( Facing > 40960 )
	{
		return kMoveRight;
	}
	else
	{
		return kMoveBack;
	}
}

defaultproperties
{
	PawnName="Unknown"
}