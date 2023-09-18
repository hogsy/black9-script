//=============================================================================
// B9_PlayerControllerBase
//
// PlayerControllers are used by human players to control pawns.
//
// 
//=============================================================================

class B9_PlayerControllerBase extends PlayerController;




// returns the B9_AdvancedPawn, or searches for it in the "vehicles"
function B9_AdvancedPawn GetAdvancedPawn()
{
	if ( Pawn != None )
	{
		if ( B9_AdvancedPawn( Pawn ) != None )
		{
			return B9_AdvancedPawn( Pawn );
		}

		if ( B9_Vehicle( Pawn ) != None )
		{
			if ( B9_AdvancedPawn( B9_Vehicle( Pawn ).Driver ) != None )
			{
				return B9_AdvancedPawn( B9_Vehicle( Pawn ).Driver );
			}
		}

		if ( B9_KVehicle( Pawn ) != None )
		{
			if ( B9_AdvancedPawn( B9_KVehicle( Pawn ).Driver ) != None )
			{
				return B9_AdvancedPawn( B9_KVehicle( Pawn ).Driver );
			}
		}
	}

	return None;
}

// returns a PAWN if it is NOT a B9_AdvancedPawn
// otherwise returns None
function Pawn GetVehiclePawn()
{
	if ( B9_AdvancedPawn( Pawn ) == None )
	{
		return Pawn;
	}

	return None;
}

function B9_Vehicle GetVehicle()
{
	if ( Pawn != None )
	{
		if ( B9_Vehicle( Pawn ) != None )
		{
			return B9_Vehicle( Pawn );
		}
	}

	return None;
}

function B9_KVehicle GetKVehicle()
{
	if ( Pawn != None )
	{
		if ( B9_KVehicle( Pawn ) != None )
		{
			return B9_KVehicle( Pawn );
		}
	}

	return None;
}

function float GetTurnResponseRate()
{
	local float				turnResponseRate;
	local B9_AdvancedPawn	advancedPawn;


	turnResponseRate	= 2;

	advancedPawn	= GetAdvancedPawn();
	if ( advancedPawn != None )
	{
		turnResponseRate	+= 6 * advancedPawn.GetTargetingSkill() / 100.0;
	}

	return turnResponseRate;
}

function float GetTurningAngle( float currentAngle, float targetAngle, float DeltaTime )
{
	local float	angleDiff;
	local float	turningAngle;


	angleDiff	= ( targetAngle & 65535 ) - ( currentAngle & 65535 );
	if ( angleDiff > 32768 )
	{
		angleDiff = -( 65535 - angleDiff );
	}
	else
	{
		if ( angleDiff < -32768 )
		{
			angleDiff = 65535 + angleDiff;
		}
	}

	turningAngle	= currentAngle + angleDiff * DeltaTime * GetTurnResponseRate();

	return turningAngle;
}
