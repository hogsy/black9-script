//////////////////////////////////////////////////////////////////////////
//
// Black 9 Sets the enemy of a combatant.
//
//////////////////////////////////////////////////////////////////////////
class ACTION_SetEnemy extends ScriptedAction;

var(Action) bool fSetPlayerAsEnemy;
var(Action) bool fSetThisPawnsEnemy;

var(Action) name fAITag;
var(Action) name fTargetTag;


function bool InitActionFor(ScriptedController C)
{
	local Pawn		AI;
	local Pawn		target;
	local B9_PlayerPawn N;
	local int dist;

	if (fSetThisPawnsEnemy)
		AI = C.Pawn;
	else
	{
		// First, find the appropriate AI
		ForEach C.AllActors( class 'Pawn', AI, fAITag )
			break;
	}
	
	if( AI == None )
	{
		C.bBroken = true;
		log( "MikeT: ACTION_SetEnemy could not find the AI" );
		return false;
	}
	
	if (fSetPlayerAsEnemy)
	{
		// Find closest player.
		dist = 0;
		target = None;
		ForEach C.Pawn.AllActors(class'B9_PlayerPawn', N)
		{
			if (N.IsPlayer())
			{
				if ( (target == None) || (dist > VSize(N.Location - AI.Location)) )
				{
					target = N;
					dist = VSize(N.Location - AI.Location);
				}
			}
		}
	}
	else
	{
		ForEach C.AllActors( class 'Pawn', target, fTargetTag )
			break;
	}
	
	if (target == None)
	{
		C.bBroken = true;
		log( "MikeT: ACTION_SetEnemy could not find the target" );
		return false;
	}
	
	AI.Controller.SetEnemy(target);
	if (B9_ArchetypePawnCombatant(AI) != None)
		B9_ArchetypePawnCombatant(AI).fCheatAlwaysSeesEnemy = true;
		
	return false;
}
