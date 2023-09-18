//////////////////////////////////////////////////////
// ACTION_TriggerConversation
//////////////////////////////////////////////////////
// Christian Rickeby - 6-5-03
// This Action is different from triggerevent since it 
// finds the player pawn and sets it to the eventInstigaor
// instead of a scripted sequence for example. It will NOT
// work properly for COOP.  I will need to find some info
// on how this should work.

class ACTION_TriggerConversation extends ScriptedAction;

var(Action) name Event;

function bool InitActionFor(ScriptedController C)
{
	local B9_PlayerPawn playerPawn;
	//find pawn

	//ForEach C.RadiusActors( class'B9_PlayerPawn', playerPawn, 1000 )
	ForEach C.AllActors( class 'B9_PlayerPawn', playerPawn)
	{
		if( playerPawn != None )
		{
			C.TriggerEvent(Event,C.SequenceScript,playerPawn);
			break;
		}
	}
	// trigger event associated with action
	return false;	
}

function string GetActionString()
{
	return ActionString@Event;
}

defaultproperties
{
	ActionString="trigger event"
}