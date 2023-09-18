class ACTION_TurnTowardPlayer extends LatentScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	C.ScriptedFocus = C.GetMyPlayer();
	C.CurrentAction = self;

///////////////////////////////////
// MT,Taldren,
// 
//
	C.SetTimer(3.0, false);	// NYI: Cheat; wait a few seconds then return.  How do I know when the bot has turned towards the player otherwise?
//
// MT, end changes
//////////////////////

	return true;	
}


///////////////////////////////////
// MT,Taldren,
// 
//
function bool CompleteWhenTriggered()
{
	return true;
}

function bool CompleteWhenTimer()
{
	return true;
}
//
// MT, end changes
//////////////////////


function bool TurnToGoal()
{
	return true;
}

function Actor GetMoveTargetFor(ScriptedController C)
{
	return C.GetMyPlayer();
}

defaultproperties
{
	ActionString="Turn toward player"
	bValidForTrigger=false
}