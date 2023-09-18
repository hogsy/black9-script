//=============================================================================
// B9_TeamGame.
//=============================================================================
class B9_TeamGame extends B9_DeathMatch
	config;
	
var	B9_UnrealTeamInfo Teams[2];

var 				bool	bScoreTeamKills;
var globalconfig	bool	bBalanceTeams;	// bots balance teams
var globalconfig	bool	bPlayersBalanceTeams;	// players balance teams

var config int		MaxTeamSize;
var config float	FriendlyFireScale; //scale friendly fire damage by this value

//var class<B9_TeamAI> TeamAIType[2];

function PostBeginPlay()
{
	local int i;
    
	for (i=0;i<2;i++)
	{
		Teams[i] = LevelRules.GetRoster(i);
		log("Team"$i$Teams[i]);
//		Teams[i].AI = Spawn(TeamAIType[i]);
//		Teams[i].AI.Team = Teams[i];
		GameReplicationInfo.Teams[i] = Teams[i];
	}
///	Teams[0].AI.EnemyTeam = Teams[1];
//	Teams[1].AI.EnemyTeam = Teams[0];
//	Teams[0].AI.SetObjectiveLists();
//	Teams[1].AI.SetObjectiveLists();
	Super.PostBeginPlay();
}

// Parse options for this game...
event InitGame( string Options, out string Error )
{
	local string InOpt;
//	local class<B9_TeamAI> InType;

	Super.InitGame(Options, Error);
/*
	InOpt = ParseOption( Options, "RedTeamAI");
	if ( InOpt != "" )
	{
		log("RedTeamAI: "$InOpt);
		InType = class<B9_TeamAI>(DynamicLoadObject(InOpt, class'Class'));
		if ( InType != None )
			TeamAIType[0] = InType;  //FIXME - need const for red and blue
	}

	InOpt = ParseOption( Options, "BlueTeamAI");
	if ( InOpt != "" )
	{
		log("BlueTeamAI: "$InOpt);
		InType = class<B9_TeamAI>(DynamicLoadObject(InOpt, class'Class'));
		if ( InType != None )
			TeamAIType[1] = InType;  //FIXME - need const for red and blue
	}
	*/
}

function bool CanShowPathTo(PlayerController P, int TeamNum)
{
	return true;
}

/* For B9_TeamGame, tell teams about kills rather than each individual bot
*/
function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn)
{
//	Teams[0].AI.NotifyKilled(Killer,Killed,KilledPawn);
//	Teams[1].AI.NotifyKilled(Killer,Killed,KilledPawn);
}

function class<Pawn> GetDefaultPlayerClass(Controller C)
{
	return class<Pawn>(DynamicLoadObject(DefaultPlayerClassName,class'Class'));
	//return B9_UnrealTeamInfo(C.PlayerReplicationInfo.Team).DefaultPlayerClass;
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local Controller P;
	local PlayerController player;

	if ( (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
		return false;

	if ( bTeamScoreRounds )
	{
		if ( Winner != None )
			Winner.Team.Score += 1;
	}
	else if ( Teams[1].Score == Teams[0].Score )
	{
		log ("BroadCast Tie!");
		// tie
		BroadcastLocalizedMessage( GameMessageClass, 0 );
		return false;
	}		

	if ( Winner == None )
	{
		log ("BroadCast Tie!");
		GameReplicationInfo.Winner = self;
	}
	else
		GameReplicationInfo.Winner = Winner.Team;

	EndTime = Level.TimeSeconds + 3.0;

	for ( P=Level.ControllerList; P!=None; P=P.nextController )
	{
		player = PlayerController(P);
		if ( Player != None )
		{
//			PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == Winner.Team));
//			player.ClientSetBehindView(true);
//			if ( Controller(Winner.Owner).Pawn != None )
//				Player.SetViewTarget(Controller(Winner.Owner).Pawn);
//			player.ClientGameEnded();
		}
		P.GotoState('GameEnded');
	}
	return true;
}

//------------------------------------------------------------------------------
// Player start functions

function Logout(Controller Exiting)
{
	Super.Logout(Exiting);
	if ( Exiting.IsA('PlayerController') && Exiting.PlayerReplicationInfo.bOnlySpectator )
		return;
    if ( Exiting.PlayerReplicationInfo.Team != None )
		Exiting.PlayerReplicationInfo.Team.RemoveFromTeam(Exiting);
	ClearOrders(Exiting);
}
				
//-------------------------------------------------------------------------------------
// Level gameplay modification


function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
	if ( ViewTarget.IsA('Controller') )
		return false;
	if ( bOnlySpectator )
		return true;
	return ( (Pawn(ViewTarget) != None) && Pawn(ViewTarget).IsPlayerPawn() 
		&& (Pawn(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team) );
}

function ClearOrders(Controller Leaving)
{
//	Teams[0].AI.ClearOrders(Leaving);
//	Teams[1].AI.ClearOrders(Leaving);
}

//------------------------------------------------------------------------------
// Game Querying.

function string GetRules()
{
	local string ResultSet;
//	ResultSet = Super(UnrealMPGameInfo).GetRules();

	ResultSet = ResultSet$"\\balanceteams\\"$bBalanceTeams;
	ResultSet = ResultSet$"\\playersbalanceteams\\"$bPlayersBalanceTeams;
	ResultSet = ResultSet$"\\friendlyfire\\"$int(FriendlyFireScale*100)$"%";

	return ResultSet;
}

//------------------------------------------------------------------------------

function B9_UnrealTeamInfo GetBotTeam()
{
	if ( Teams[0].NeedsBotMoreThan(Teams[1]) )
		return Teams[0];
	else
		return Teams[1];
}		

function B9_UnrealTeamInfo FindTeamFor(Controller B)
{
	if ( Teams[0].BelongsOnTeam(B.Pawn.Class) )
		return Teams[0];
	if ( Teams[1].BelongsOnTeam(B.Pawn.Class) )
		return Teams[1];
	return LevelRules.GetDMRoster();
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
		NewTeam = SmallTeam;

	if ( (NewTeam == None) || (NewTeam.Size >= MaxTeamSize) )
		NewTeam = SmallTeam;

	return NewTeam.TeamIndex;
}

/* ChangeTeam()
*/
function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
	local B9_UnrealTeamInfo NewTeam;

	if ( bMustJoinBeforeStart && !bWaitingToStartMatch )
		return false;	// only allow team changes before match starts

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
	if ( LevelRules.bSpawnInTeamArea && (Team != P.TeamNumber) )
		return 1;

	return Super.RatePlayerStart(N,Team,Player);
}

/* CheckScore()
see if this score means the game ends
*/
function CheckScore(PlayerReplicationInfo Scorer)
{
	local Controller C;
	local PlayerReplicationInfo Leader[2];

	if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
		return;

	// check if all other players are out
	if ( MaxLives > 0 )
	{
		if ( !Scorer.bOutOfLives )
			Leader[Scorer.Team.TeamIndex] = Scorer;

		for ( C=Level.ControllerList; C!=None; C=C.NextController )
			if ( !C.PlayerReplicationInfo.bOutOfLives )
			{
				if ( Leader[C.PlayerReplicationInfo.Team.TeamIndex] == None )
					Leader[C.PlayerReplicationInfo.Team.TeamIndex] = C.PlayerReplicationInfo;	
				if ( (Leader[0] != None) && (Leader[1] != None ) )
					break;
			} 
		if ( Leader[0] == None )
		{
			EndGame(Leader[1],"LastMan");
			return;
		}
		else if ( Leader[1] == None )
		{
			EndGame(Leader[0],"LastMan");
			return;
		}
	}	

	if ( LevelRules.bOnlyObjectivesWin )
		return;

	if (  !bOverTime && (GoalScore == 0) )
		return;
	if ( (Scorer != None) && (Scorer.Team != None) && (Scorer.Team.Score >= GoalScore) )	
		EndGame(Scorer,"teamscorelimit");
}

function ScoreKill(Controller Killer, Controller Other)
{
	if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreKill(Killer, Other);

	if ( (Killer == None) || (Killer == Other) || !Other.bIsPlayer || !Killer.bIsPlayer 
		|| (Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team) )
		Super.ScoreKill(Killer, Other);

	if ( !bScoreTeamKills )
		return;
	if ( Other.bIsPlayer && ((Killer == None) || Killer.bIsPlayer) )
	{
		if ( (Killer == Other) || (Killer == None) )
			Other.PlayerReplicationInfo.Team.Score -= 1;
		else if ( Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team )
			Killer.PlayerReplicationInfo.Team.Score += 1;
		else if ( FriendlyFireScale > 0 )
		{
			Other.PlayerReplicationInfo.Team.Score -= 1;
			Killer.PlayerReplicationInfo.Score -= 1;
		}
	}

	// check score again to see if team won
	CheckScore(Killer.PlayerReplicationInfo);
}

function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	if ( instigatedBy == None )
		return Damage;

	if ( (instigatedBy != injured) && injured.IsPlayerPawn() && instigatedBy.IsPlayerPawn() 
		&& (injured.PlayerReplicationInfo.Team == instigatedBy.PlayerReplicationInfo.Team) )
	{
		if ( injured.Controller.IsA('Bot') )
			Bot(Injured.Controller).YellAt(instigatedBy);
		
		if (FriendlyFireScale==0.0)
			return 0;
	
		Damage *= FriendlyFireScale;
	}
	
	Damage = Super.ReduceDamage( Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
	return Damage;
}
defaultproperties
{
	bBalanceTeams=true
	MaxTeamSize=16
	InitialBots=7
	MaxLives=999
	bCanChangeSkin=false
	bTeamGame=true
	BeaconName="Team"
	GameName="Team Deathmatch"
}