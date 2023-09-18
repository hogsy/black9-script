// B9_DMRoster
// Holds list of pawns to use in this DM battle

class B9_DMRoster extends B9_UnrealTeamInfo;

var int Position;

function bool AddToTeam(Controller Other)
{
	// Squad Logic Not yet implemented
/*	local B9_SquadAI DMSquad;

	if ( Bot(Other) != None )
	{
		DMSquad = spawn(B9_DeathMatch(Level.Game).DMSquadClass);
		DMSquad.AddBot(Bot(Other));
	}
	Other.PlayerReplicationInfo.Team = None;
	*/
	return true;
}

function SetBotOrders(Bot NewBot, RosterEntry R) {}

