class ACTION_SetPawnAsEnemy extends ScriptedAction;

var(Action)	name fAITag;
var(Action) name fTargetTag;

function bool InitActionFor(ScriptedController C)
{
	local Pawn		AI;
	local Pawn		target;

//	log( "Alex: In InitActionFor" );

	// First, find the appropriate AI
	ForEach C.AllActors( class 'Pawn', AI, fAITag )
		break;

	if( AI == None )
	{
		C.bBroken = true;
//		log( "ALEX: ACTION_SetPlayerAsEnemy could not find the AI" );
		return false;
	}

	// Now, look for the player
	ForEach C.AllActors( class 'Pawn', target, fTargetTag )
		break;

	if( target == None )
	{	
		C.bBroken = true;
	//	log( "ALEX: ACTION_SetPlayerAsEnemy could not find the player" );
		return false;
	}
	else
	{
	//	log( "Alex: ACTION_SetPawnAsEnemy, seting target, target: " $target );

		// Sick'um.
		AI.Controller.SetEnemy( target );
		//AI.Controller.GotoState( 'AttackAndHunting' );
	}

	//log( "ALEX: AI, in state: " $AI.Controller.GetStateName() $" Enemy: " $AI.Controller.Enemy );
	//log( "Alex: returning with no errors" );

	return false;
}

