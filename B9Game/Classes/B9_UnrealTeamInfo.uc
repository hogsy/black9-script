//=============================================================================
// B9_UnrealTeamInfo.
// includes list of bots on team for multiplayer games
// 
//=============================================================================

class B9_UnrealTeamInfo extends TeamInfo
	placeable;

var() RosterEntry DefaultRosterEntry;
var() export editinline array<RosterEntry> Roster;
var() class<B9_Pawn> AllowedTeamMembers[32];
var() byte TeamAlliance;
var int DesiredTeamSize;
// Not Yet Implemented
//var B9_TeamAI AI;
var Color HudTeamColor;

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	if ( !UnrealMPGameInfo(Level.Game).bTeamScoreRounds )
		Score = 0;
}

simulated function class<Pawn> NextLoadOut(class<Pawn> CurrentLoadout)
{
	local int i;
	local class<Pawn> Result;

	Result = AllowedTeamMembers[0];

	for ( i=0; i<ArrayCount(AllowedTeamMembers) - 1; i++ )
	{
		if ( AllowedTeamMembers[i] == CurrentLoadout )
		{
			if ( AllowedTeamMembers[i+1] != None )
				Result = AllowedTeamMembers[i+1];
			break;
		}
		else if ( AllowedTeamMembers[i] == None )
			break;
	}

	return Result;
}

function bool NeedsBotMoreThan(B9_UnrealTeamInfo T)
{
	return ( (DesiredTeamSize - Size) > (T.DesiredTeamSize - T.Size) );
}

function RosterEntry ChooseBotClass()
{
	local int i;

	// FIXME - mark first roster entry of human player's class as taken
				
	for ( i=0; i<Roster.Length; i++ )
		if ( !Roster[i].bTaken )
		{
			Roster[i].bTaken = true;
			return Roster[i];
		}

	return DefaultRosterEntry;
}

function bool AddToTeam( Controller Other )
{
	local bool bResult;

	bResult = Super.AddToTeam(Other);

	if ( bResult && (Other.PawnClass != None) && !BelongsOnTeam(Other.PawnClass) )
		Other.PawnClass = DefaultPlayerClass;

	return bResult;
}

/* BelongsOnTeam()
returns true if PawnClass is allowed to be on this team
*/
function bool BelongsOnTeam(class<Pawn> PawnClass)
{
	local int i;

	for ( i=0; i<ArrayCount(AllowedTeamMembers); i++ )
		if ( PawnClass == AllowedTeamMembers[i] )
			return true;

	return false;
}

function SetBotOrders(Bot NewBot, RosterEntry R) 
{
	// Not Yet Implemented
	//AI.SetBotOrders(NewBot,R);
}



defaultproperties
{
	DesiredTeamSize=8
	HudTeamColor=(B=255,G=255,R=255,A=255)
}