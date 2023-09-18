class ACTION_ClientTravel extends ScriptedAction;

var(Action) string URL;
var(Action) bool bShowLoadingMessage;

function bool InitActionFor(ScriptedController C)
{
	local B9_PlayerController	PC;
	local B9_PlayerPawn			fPlayer;

	ForEach C.AllActors(class'B9_PlayerPawn', fPlayer)
	{
		if(fPlayer.IsA('B9_PlayerPawn'))
		{
			break;
		}
	}
	
	if(fPlayer != None)
	{
		PC = B9_PlayerController( fPlayer.Controller );
	
		if( bShowLoadingMessage )
		{
			PC.ClientTravel(URL, TRAVEL_Absolute, true);
		}
		else
		{
			PC.ClientTravel(URL, TRAVEL_Absolute, true);
		}
	}
		
	return true;	
}

function string GetActionString()
{
	return ActionString;
}


defaultproperties
{
	ActionString="Change level"
}