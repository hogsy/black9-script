//=============================================================================
// Trigger attached to a civilian so that the player can use them.
//=============================================================================
class B9_CivilianTrigger extends UseTrigger
	notplaceable;


function UsedBy( Pawn user )
{
	if ( Pawn(Base) != None )
	{
		if ( B9_AI_ControllerCivilian( Pawn(Base).Controller) != None )
		{
			B9_AI_ControllerCivilian( Pawn(Base).Controller).fWaitHere =
									!B9_AI_ControllerCivilian( Pawn(Base).Controller).fWaitHere;
		}
	}
}
