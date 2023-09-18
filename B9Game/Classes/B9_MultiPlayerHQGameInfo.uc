//=============================================================================
// B9_MultiPlayerHQGameInfo.
//=============================================================================
class B9_MultiPlayerHQGameInfo extends B9_TeamGame;


var bool bPlayersBalanceTeams;
var (GameProperties) int fCountDownTimer;
var (GameProperties) int fCountDownTimerDuration;

var bool fCanCountDown;
replication
{
	reliable if( Role==ROLE_Authority )
		fCountDownTimer;

}


function PreBeginPlay()
{
	BeaconName = "";
	Level.Title = "Black 9 HQ";
	Super.PreBeginPlay();
}


/* Called when pawn has a chance to pick Item up (i.e. when 
   the pawn touches a weapon pickup). Should return true if 
   he wants to pick it up, false if he does not want it.
*/
function bool PickupQuery( Pawn Other, Pickup item )
{
	local B9_PlayerPawn PP;

	PP = B9_PlayerPawn(Other);
	Log("IT="$item.Tag$" IC="$item.Class.Name$" SN="$PP.fServerName);
	if (PP != None && item.Tag != item.Class.Name && item.Tag != PP.fServerName)
		return false;
	return Super.PickupQuery( Other, item );
}
function Tick( float deltaTime )
{
	B9_HQGameReplicationInfo(GameReplicationInfo).fCountDown = fCountDownTimer;
	if( GameReplicationInfo.Teams[0].Size + GameReplicationInfo.Teams[1].Size > 1)
	{
		fCanCountDown = true;
	}else
	{
		fCanCountDown = false;
	}
	B9_HQGameReplicationInfo(GameReplicationInfo).fCanCountDown = fCanCountDown;
}

function PostBeginPlay()
{
	local int i;
    
	for (i=0;i<2;i++)
	{
		Teams[i] = LevelRules.GetRoster(i);
	}
	Super.PostBeginPlay();
	fCountDownTimer = fCountDownTimerDuration;
}
/* Return a picked team number if none was specified
*/
function byte PickTeam(byte num, Controller C)
{
	local B9_UnrealTeamInfo SmallTeam, BigTeam, NewTeam;

	log ("Picking Team!");
	SmallTeam = Teams[0];
	BigTeam = Teams[1];

	if ( SmallTeam.Size > BigTeam.Size )
	{
		SmallTeam = Teams[1];
		BigTeam = Teams[0];
	}

	if ( num < 2 )
		NewTeam = Teams[num];

	if ( bPlayersBalanceTeams && (SmallTeam.Size < BigTeam.Size) )
	{
		NewTeam = SmallTeam;
	}

	if ( (NewTeam == None)  )
	{
		NewTeam = SmallTeam;
	}
	log("Given Team:"$NewTeam.TeamIndex);
	return NewTeam.TeamIndex;
}
/* ChangeTeam()
*/
function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
	local B9_UnrealTeamInfo NewTeam;

	if ( Other.IsA('PlayerController') && Other.PlayerReplicationInfo.bOnlySpectator )
	{
		Other.PlayerReplicationInfo.Team = None;
/*		if (StatLog != None)
			StatLog.LogTeamChange(Other);*/
		return true;
	}

	NewTeam = Teams[PickTeam(num, Other)];

	if ( NewTeam.Size >= MaxTeamSize )
		return false;	// no room on either team

	// check if already on this team
	if ( Other.PlayerReplicationInfo.Team == NewTeam )
		return false;

	Other.StartSpot = None;

	if ( Other.PlayerReplicationInfo.Team != None )
		Other.PlayerReplicationInfo.Team.RemoveFromTeam(Other);

	if ( NewTeam.AddToTeam(Other) )
		BroadcastLocalizedMessage( GameMessageClass, 3, Other.PlayerReplicationInfo, None, NewTeam );
	return true;
}

/* Rate whether player should choose this NavigationPoint as its start
*/
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
	local PlayerStart P;

	P = PlayerStart(N);
	if ( P == None )
		return 0;
	if ( Team != P.TeamNumber )
		return 1;

	return Super.RatePlayerStart(N,Team,Player);
}

function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	// No Damage on this Level!
	return 0;
}
defaultproperties
{
	fCountDownTimer=6000
	fCountDownTimerDuration=60
	B9_LevelRulesClass=Class'B9_LevelGamePlay'
	GoalScore=100
	bTeamScoreRounds=false
	MaxLives=0
	HUDType="B9Game.B9_MPHQ_HUD"
	MapListType="B9Game.MPHQmaplist"
	MapPrefix="HQ"
	BeaconName="HQ"
	GameName="MPHQ"
	DeathMessageClass=Class'WarfareGame.WarfareDeathMessage'
	GameReplicationInfoClass=Class'B9_HQGameReplicationInfo'
}