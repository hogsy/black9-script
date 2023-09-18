//=============================================================================
// TeamGame.
//=============================================================================
class TeamGame extends DeathMatch
	config;
	
var	UnrealTeamInfo Teams[2];
var string BlueTeamName, RedTeamName;		// when specific pre-designed teams are specified on the URL

var 				bool	bScoreTeamKills;
var globalconfig	bool	bBalanceTeams;	// bots balance teams
var globalconfig	bool	bPlayersBalanceTeams;	// players balance teams
var bool bSpawnInTeamArea;	// players spawn in marked team playerstarts
var bool			bScoreVictimsTarget;	// Should we check a victims target for bonuses

var config int		MaxTeamSize;
var config float	FriendlyFireScale; //scale friendly fire damage by this value
var class<TeamAI> TeamAIType[2];
var localized string NearString;

var sound CaptureSound[2];
var sound TakeLead[2];
var sound IncreaseLead[2];
var sound HatTrickSound;

// localized PlayInfo descriptions & extra info
var private localized string TGPropsDisplayText[4];

var() float ADR_Goal;
var() float ADR_Return;
var() float ADR_Control;

var texture TempSymbols[2];

function PostBeginPlay()
{
	local int i;

	if ( InitialBots > 0 )
	{
	    Teams[0] = GetRedTeam(0.5 * InitialBots + 1);
	    Teams[1] = GetBlueTeam(0.5 * InitialBots + 1);
	}
	else
	{
		Teams[0] = GetRedTeam(0);
		Teams[1] = GetBlueTeam(0);
	}
	for (i=0;i<2;i++)
	{
		Teams[i].TeamIndex = i;
		Teams[i].AI = Spawn(TeamAIType[i]);
		Teams[i].AI.Team = Teams[i];
		GameReplicationInfo.Teams[i] = Teams[i];
		log(Teams[i].TeamName$" AI is "$Teams[i].AI);
	}
	Teams[0].AI.EnemyTeam = Teams[1];
	Teams[1].AI.EnemyTeam = Teams[0];
	Teams[0].AI.SetObjectiveLists();
	Teams[1].AI.SetObjectiveLists();
	Super.PostBeginPlay();
}

function RegisterVehicle(Vehicle V)
{
	if ( V.Team < 2 )
		Teams[V.Team].AI.RegisterVehicle(V);
	else
	{
		Teams[0].AI.RegisterVehicle(V);
		Teams[1].AI.RegisterVehicle(V);
	}
}

// check if all other players are out
function bool CheckMaxLives(PlayerReplicationInfo Scorer)
{
    local Controller C;
    local PlayerReplicationInfo Living;
    local bool bNoneLeft;

    if ( MaxLives > 0 )
    {
		if ( (Scorer != None) && !Scorer.bOutOfLives )
			Living = Scorer;
        bNoneLeft = true;
        for ( C=Level.ControllerList; C!=None; C=C.NextController )
            if ( (C.PlayerReplicationInfo != None) && C.bIsPlayer
                && !C.PlayerReplicationInfo.bOutOfLives )
            {
				if ( Living == None )
					Living = C.PlayerReplicationInfo;
				else if ( (C.PlayerReplicationInfo != Living) && (C.PlayerReplicationInfo.Team != Living.Team) ) 
			   	{
    	        	bNoneLeft = false;
	            	break;
				}
            } 
        if ( bNoneLeft )
        {
			if ( Living != None )
				EndGame(Living,"LastMan");
			else
				EndGame(Scorer,"LastMan");
			return true;
		}
    }   
    return false;
}

function TeamInfo OtherTeam(TeamInfo Requester)
{
	if ( Requester == Teams[0] )
		return Teams[1];
	return Teams[0];
}

function OverrideInitialBots()
{
	InitialBots = Teams[0].OverrideInitialBots(InitialBots,Teams[1]);
}

function PreLoadNamedBot(string BotName)
{
	local int first, second;

	second = 1;
	// always imbalance teams in favor of bot team in single player
	if ( (StandalonePlayer != None ) && (StandalonePlayer.PlayerReplicationInfo.Team.TeamIndex == 1) )
	{
		first = 1;
		second = 0;
	}
	if ( 1 + Teams[first].Roster.Length < Teams[second].Roster.Length )
		Teams[first].AddNamedBot(BotName);
	else
		Teams[second].AddNamedBot(BotName);
}

function PreLoadBot()
{
	if ( Teams[0].Roster.Length < 0.5 * InitialBots + 1 )
		Teams[0].AddRandomPlayer();
	if ( Teams[1].Roster.Length < 0.5 * InitialBots + 1 )
		Teams[1].AddRandomPlayer();
}

/* create a player team, and fill from the team roster
*/
function UnrealTeamInfo GetBlueTeam(int TeamBots)
{
	local class<UnrealTeamInfo> RosterClass;
	local UnrealTeamInfo Roster;
	
/* FIXME SINGLEPLAYER    if ( SinglePlayerGameProfile != None )
	{
		RosterClass = class<UnrealTeamInfo>(DynamicLoadObject(DefaultEnemyRosterClass,class'Class'));
		Roster = Spawn(RosterClass);
		Roster.FillPlayerTeam(SinglePlayerGameProfile);
		return Roster;
	}
	else */
	if ( BlueTeamName != "" )
		RosterClass = class<UnrealTeamInfo>(DynamicLoadObject(BlueTeamName,class'Class'));
	else
		RosterClass = class<UnrealTeamInfo>(DynamicLoadObject(DefaultEnemyRosterClass,class'Class'));
	Roster = spawn(RosterClass);
	Roster.Initialize(TeamBots);
	return Roster;
}

function UnrealTeamInfo GetRedTeam(int TeamBots)
{
	EnemyRosterName = RedTeamName;
	return Super.GetBotTeam(TeamBots);
}

// Parse options for this game...
event InitGame( string Options, out string Error )
{
	local string InOpt;
	local class<TeamAI> InType;
	local string RedSymbolName,BlueSymbolName;
	local texture NewSymbol;
	
	Super.InitGame(Options, Error);
	MaxTeamSize = Max(MaxTeamSize, 1 + MaxPlayers/2);
	InOpt = ParseOption( Options, "RedTeamAI");
	if ( InOpt != "" )
	{
		log("RedTeamAI: "$InOpt);
		InType = class<TeamAI>(DynamicLoadObject(InOpt, class'Class'));
		if ( InType != None )
			TeamAIType[0] = InType;  
	}

	InOpt = ParseOption( Options, "BlueTeamAI");
	if ( InOpt != "" )
	{
		log("BlueTeamAI: "$InOpt);
		InType = class<TeamAI>(DynamicLoadObject(InOpt, class'Class'));
		if ( InType != None )
			TeamAIType[1] = InType;  
	}
	
	// get passed in teams
	RedTeamName = ParseOption( Options, "RedTeam");
	BlueTeamName = ParseOption( Options, "BlueTeam");
	
	if ( RedTeamName != "" )
	{
		bCustomBots = true;
		if ( BlueTeamName == "" )
			BlueTeamName = "xGame.TeamBlueConfigured";
	}
	else if ( BlueTeamName != "" )
	{
		bCustomBots = true;
		RedTeamName = "xGame.TeamRedConfigured";
	}
	
	// set teamsymbols (optional)
	RedSymbolName = ParseOption( Options, "RedTeamSymbol");
	BlueSymbolName = ParseOption( Options, "BlueTeamSymbol"); 
	if ( RedSymbolName != "" )
	{
		NewSymbol = Texture(DynamicLoadObject(RedSymbolName,class'Texture'));
		if ( NewSymbol != None )
			TempSymbols[0] = NewSymbol;
	}
	if ( BlueSymbolName != "" )
	{
		NewSymbol = Texture(DynamicLoadObject(BlueSymbolName,class'Texture'));
		if ( NewSymbol != None )
			TempSymbols[1] = NewSymbol;
	}
	InOpt = ParseOption( Options, "FF");
	if ( InOpt != "" )
		FriendlyFireScale = float(InOpt);
	
	InOpt = ParseOption(Options, "BalanceTeams");
	if ( InOpt != "")
	{
		bBalanceTeams = bool(InOpt);
		bPlayersBalanceTeams = bBalanceTeams;
	}	
	log("TeamGame::InitGame : bBalanceTeams"@bBalanceTeams);
	
	
}

function InitTeamSymbols()
{
	if ( (TempSymbols[0] == None) && (Teams[0].TeamSymbolName != "") )
		TempSymbols[0] = Texture(DynamicLoadObject(Teams[0].TeamSymbolName,class'Texture'));
	if ( (TempSymbols[1] == None) && (Teams[1].TeamSymbolName != "") )
		TempSymbols[1] = Texture(DynamicLoadObject(Teams[1].TeamSymbolName,class'Texture'));
	
	GameReplicationInfo.Teams[0].TeamIcon = TempSymbols[0];
	GameReplicationInfo.Teams[1].TeamIcon = TempSymbols[1];
	Super.InitTeamSymbols();
}

function bool CanShowPathTo(PlayerController P, int TeamNum)
{
	return true;
}

function RestartPlayer( Controller aPlayer, bool IsFromDeath )    
{
	local TeamInfo BotTeam, OtherTeam;
	
	if ( bBalanceTeams && (Bot(aPlayer) != None) && (!bCustomBots || (Level.NetMode != NM_Standalone)) )
	{
		BotTeam = aPlayer.PlayerReplicationInfo.Team;
		if ( BotTeam == Teams[0] )
			OtherTeam = Teams[1];
		else
			OtherTeam = Teams[0];
			
		if ( OtherTeam.Size < BotTeam.Size - 1 )
		{
			aPlayer.Destroy();
			return;
		}
	}
	Super.RestartPlayer( aPlayer, IsFromDeath );
}

/* For TeamGame, tell teams about kills rather than each individual bot
*/
function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn)
{
	Teams[0].AI.NotifyKilled(Killer,Killed,KilledPawn);
	Teams[1].AI.NotifyKilled(Killer,Killed,KilledPawn);
}

/* 
function class<Pawn> GetDefaultPlayerClass(Controller C)
{
	return UnrealTeamInfo(C.PlayerReplicationInfo.Team).DefaultPlayerClass;
}
*/

function IncrementGoalsScored(PlayerReplicationInfo PRI)
{
	PRI.GoalsScored += 1;
	if ( (PRI.GoalsScored == 3) && (UnrealPlayer(PRI.Owner) != None) )
		UnrealPlayer(PRI.Owner).ClientDelayedAnnouncement(HatTrickSound,30);
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local Controller P;
	local PlayerController player;
    local bool bLastMan;
	
	if ( bOverTime )
	{
		if ( Numbots + NumPlayers == 0 )
			return true;
		bLastMan = true;
		for ( P=Level.ControllerList; P!=None; P=P.nextController )
			if ( (P.PlayerReplicationInfo != None) && !P.PlayerReplicationInfo.bOutOfLives )
			{
				bLastMan = false;
				break;
			}
		if ( bLastMan )
			return true;
	}			

    bLastMan = ( Reason ~= "LastMan" );

	if ( !bLastMan && (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
		return false;

	if ( bTeamScoreRounds )
	{
		if ( Winner != None )
			Winner.Team.Score += 1;
	}
	else if ( !bLastMan && (Teams[1].Score == Teams[0].Score) )
	{
		// tie
		if ( !bOverTimeBroadcast )
		{
			StartupStage = 7;
			PlayStartupMessage();
			bOverTimeBroadcast = true;
		}
		return false;
	}		
	if ( bLastMan )
		GameReplicationInfo.Winner = Winner.Team;
	else if ( Teams[1].Score > Teams[0].Score )
		GameReplicationInfo.Winner = Teams[1];
	else
		GameReplicationInfo.Winner = Teams[0];

	if ( Winner == None )
	{
		for ( P=Level.ControllerList; P!=None; P=P.nextController )
			if ( (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == GameReplicationInfo.Winner) 
				&& ((Winner == None) || (P.PlayerReplicationInfo.Score > Winner.Score)) )
			{
				Winner = P.PlayerReplicationInfo;
			}
	}
			
	EndTime = Level.TimeSeconds + EndTimeDelay;
	
	if ( Winner != None )
		EndGameFocus = Controller(Winner.Owner).Pawn;
	if ( EndGameFocus != None )
		EndGameFocus.bAlwaysRelevant = true;
	
	for ( P=Level.ControllerList; P!=None; P=P.nextController )
	{
		player = PlayerController(P);
		if ( Player != None )
		{
			PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == GameReplicationInfo.Winner));
			player.ClientSetBehindView(true);
			if ( EndGameFocus != None )
            {
				Player.ClientSetViewTarget(EndGameFocus);
                Player.SetViewTarget(EndGameFocus);
            }
			player.ClientGameEnded();
		}
		P.GameHasEnded();
	}
	return true;
}
				
//-------------------------------------------------------------------------------------
// Level gameplay modification


function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
	if ( ViewTarget == None )
		return false;
	if ( bOnlySpectator )
	{
		if ( Controller(ViewTarget) != None )
			return ( (Controller(ViewTarget).PlayerReplicationInfo != None)
				&& !Controller(ViewTarget).PlayerReplicationInfo.bOnlySpectator );
		return true;
	}
	if ( Controller(ViewTarget) != None )
		return ( (Controller(ViewTarget).PlayerReplicationInfo != None)
				&& !Controller(ViewTarget).PlayerReplicationInfo.bOnlySpectator
				&& (Controller(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team) );
	return ( (Pawn(ViewTarget) != None) && Pawn(ViewTarget).IsPlayerPawn() 
		&& (Pawn(ViewTarget).PlayerReplicationInfo.Team == Viewer.PlayerReplicationInfo.Team) );
}

//------------------------------------------------------------------------------
// Game Querying.
function GetServerDetails( out ServerResponseLine ServerState )
{
	local int i;

	Super.GetServerDetails( ServerState );

	i = ServerState.ServerInfo.Length;

	// balance teams
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "balanceteams";
	if( bBalanceTeams )
		ServerState.ServerInfo[i++].Value = "True";
	else
		ServerState.ServerInfo[i++].Value = "False";

	// playersbalanceteams
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "playersbalanceteams";
	if( bPlayersBalanceTeams )
		ServerState.ServerInfo[i++].Value = "True";
	else
		ServerState.ServerInfo[i++].Value = "False";

	// friendly fire
	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "friendlyfire";
	ServerState.ServerInfo[i++].Value = string(int(FriendlyFireScale*100))$"%";
}


//------------------------------------------------------------------------------
function UnrealTeamInfo GetBotTeam(optional int TeamBots)
{
	local int first, second;
	
	if ( (Level.NetMode == NM_Standalone) || !bBalanceTeams )
	{
	    if ( Teams[0].AllBotsSpawned() )
	    {
			bBalanceTeams = false;
		    if ( !Teams[1].AllBotsSpawned() )
			    return Teams[1];
	    }
	    else if ( Teams[1].AllBotsSpawned() )
	    {
			bBalanceTeams = false;
		    return Teams[0];
		}
	}
		
	second = 1;
	
	// always imbalance teams in favor of bot team in single player
	if ( (StandalonePlayer != None ) && (StandalonePlayer.PlayerReplicationInfo.Team.TeamIndex == 1) )
	{
		first = 1;
		second = 0;
	}
	if ( Teams[first].Size < Teams[second].Size )
		return Teams[first];
	else
		return Teams[second];
}

function UnrealTeamInfo FindTeamFor(Controller C)
{
	if ( Teams[0].BelongsOnTeam(C.Pawn.Class) )
		return Teams[0];
	if ( Teams[1].BelongsOnTeam(C.Pawn.Class) )
		return Teams[1];
	return GetBotTeam();
}

/* Return a picked team number if none was specified
*/
function byte PickTeam(byte num, Controller C)
{
	local UnrealTeamInfo SmallTeam, BigTeam, NewTeam;
	local Controller B;
	local bool bForceSmall;

	SmallTeam = Teams[0];
	BigTeam = Teams[1];

	if ( SmallTeam.Size > BigTeam.Size )
	{
		SmallTeam = Teams[1];
		BigTeam = Teams[0];
	}

	if ( num < 2 )
		NewTeam = Teams[num];

	if ( bPlayersBalanceTeams && (SmallTeam.Size < BigTeam.Size) && ((Level.NetMode != NM_Standalone) || (PlayerController(C) == None)) )
	{
		bForceSmall = true;
		// if any bots on big team, no need to go on small team
		for ( B=Level.ControllerList; B!=None; B=B.NextController )
		{
			if ( (B.PlayerReplicationInfo != None) && B.PlayerReplicationInfo.bBot && (B.PlayerReplicationInfo.Team == BigTeam) )
			{
				bForceSmall = false;
				break;
			}
		}
		if ( bForceSmall )
		NewTeam = SmallTeam;
	}

	if ( (NewTeam == None) || (NewTeam.Size >= MaxTeamSize) )
		NewTeam = SmallTeam;

	return NewTeam.TeamIndex;
}

/* ChangeTeam()
*/
function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
	local UnrealTeamInfo NewTeam;

	if ( bMustJoinBeforeStart && GameReplicationInfo.bMatchHasBegun )
		return false;	// only allow team changes before match starts

	if ( Other.IsA('PlayerController') && Other.PlayerReplicationInfo.bOnlySpectator )
	{
		Other.PlayerReplicationInfo.Team = None;
		return true;
	}

	NewTeam = Teams[PickTeam(num,Other)];

	if ( NewTeam.Size >= MaxTeamSize )
		return false;	// no room on either team

	// check if already on this team
	if ( Other.PlayerReplicationInfo.Team == NewTeam )
		return false;

	Other.StartSpot = None;

	if ( Other.PlayerReplicationInfo.Team != None )
		Other.PlayerReplicationInfo.Team.RemoveFromTeam(Other);
	
	if ( NewTeam.AddToTeam(Other) )
	{
		BroadcastLocalizedMessage( GameMessageClass, 3, Other.PlayerReplicationInfo, None, NewTeam );
		
		if ( bNewTeam && PlayerController(Other)!=None )
			GameEvent("TeamChange",""$num,Other.PlayerReplicationInfo);
	}		
	return true;
}

/* Rate whether player should choose this NavigationPoint as its start
*/
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
	local PlayerStart P;

	P = PlayerStart(N);
	if ( P == None )
		return -10000000;
	if ( bSpawnInTeamArea && (Team != P.TeamNumber) )
		return -9000000;

	return Super.RatePlayerStart(N,Team,Player);
}

/* CheckScore()
see if this score means the game ends
*/
function CheckScore(PlayerReplicationInfo Scorer)
{
	if ( CheckMaxLives(Scorer) )
		return;

    if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
		return;

    if (  !bOverTime && (GoalScore == 0) )
		return;	
    if ( (Scorer != None) && (Scorer.Team != None) && (Scorer.Team.Score >= GoalScore) )	
		EndGame(Scorer,"teamscorelimit");
    
    if ( (Scorer != None) && bOverTime )
		EndGame(Scorer,"timelimit");
}

function bool CriticalPlayer(Controller Other)
{
	if ( (GameRulesModifiers != None) && (GameRulesModifiers.CriticalPlayer(Other)) )
		return true;
	if ( Other.PlayerReplicationInfo.HasFlag != None )
		return true;
		
	return false;
}

// ==========================================================================
// FindVictimsTarget - Tries to determine who the victim was aiming at
// ==========================================================================

function Pawn FindVictimsTarget(Controller Other)
{

	local Vector Start,X,Y,Z;
	local float Dist,Aim;
	local Actor Target;

	if (Other==None || Other.Pawn==None || Other.Pawn.Weapon==None)	// If they have no weapon, they can't be targetting someone
		return None;		

	GetAxes(Other.Pawn.GetViewRotation(),X,Y,Z);
	Start = Other.Pawn.Location + Other.Pawn.CalcDrawOffset(Other.Pawn.Weapon); 
	Aim = 0.97;
	Target = Other.PickTarget(aim,dist,X,Start,4000.f); //amb
	
	return Pawn(Target);

} 

function ScoreKill(Controller Killer, Controller Other)
{
	local Pawn Target;

	if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreKill(Killer, Other);

	if ( (Killer == None) || (Killer == Other) || !Other.bIsPlayer || !Killer.bIsPlayer 
		|| (Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team) )
	{
		if ( (Killer!=None) && (Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team) )
		{
			// Kill Bonuses work as follows (in additional to the default 1 point			
			//	+1 Point for killing an enemy targetting an important player on your team
			//	+2 Points for killing an enemy important player
		
			if ( CriticalPlayer(Other) )
			{
				Killer.PlayerReplicationInfo.Score+= 1;
				ScoreEvent(Killer.PlayerReplicationInfo,1,"critical_frag");
			}

			if (bScoreVictimsTarget)
			{
				Target = FindVictimsTarget(Other);
				if ( (Target!=None) && (Target.PlayerReplicationInfo!=None) && 
				       (Target.PlayerReplicationInfo.Team == Killer.PlayerReplicationInfo.Team) && CriticalPlayer(Other) )
				{
					Killer.PlayerReplicationInfo.Score+=1;
					ScoreEvent(Killer.PlayerReplicationInfo,1,"team_protect_frag");
				}
			} 
										
		} 
		Super.ScoreKill(Killer, Other);
	}

	if ( !bScoreTeamKills )
	{
		if ( Other.bIsPlayer && (Killer != None) && Killer.bIsPlayer && (Killer != Other)
			&& (Killer.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team) )
		{
			Killer.PlayerReplicationInfo.Score -= 1;
			ScoreEvent(Killer.PlayerReplicationInfo, -1, "team_frag");
		}
		if ( MaxLives > 0 )
			CheckScore(Killer.PlayerReplicationInfo);
		return;
	}
	if ( Other.bIsPlayer )
	{
		if ( (Killer == None) || (Killer == Other) )
		{
			Other.PlayerReplicationInfo.Team.Score -= 1;
			TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "team_frag");
		}	
		else if ( Killer.PlayerReplicationInfo.Team != Other.PlayerReplicationInfo.Team )
		{
			Killer.PlayerReplicationInfo.Team.Score += 1;
			TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "tdm_frag");
		}
		else if ( FriendlyFireScale > 0 )
		{
			Killer.PlayerReplicationInfo.Score -= 1;
			Killer.PlayerReplicationInfo.Team.Score -= 1;
			TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "team_frag");
		}
	}

	// check score again to see if team won
    if ( (Killer != None) && bScoreTeamKills ) 
		CheckScore(Killer.PlayerReplicationInfo);
}

function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
	local TeamInfo InjuredTeam, InstigatorTeam;
	
	if ( instigatedBy == None )
		return Super.ReduceDamage( Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );

	InjuredTeam = Injured.GetTeam();
	InstigatorTeam = InstigatedBy.GetTeam();
	if ( instigatedBy != injured )
	{
		if ( (InjuredTeam != None) && (InstigatorTeam != None) )
		{
			if ( InjuredTeam == InstigatorTeam )
			{
				Momentum *= 0.3;
				if ( Bot(injured.Controller) != None )
					Bot(Injured.Controller).YellAt(instigatedBy);
				if ( FriendlyFireScale==0.0 )
				{
					if ( GameRulesModifiers != None )
						return GameRulesModifiers.NetDamage( Damage, 0,injured,instigatedBy,HitLocation,Momentum,DamageType );
					else
					return 0;
				}
				Damage *= FriendlyFireScale;
			}
			else if ( !injured.IsHumanControlled() && (injured.Controller != None) 
					&& (injured.PlayerReplicationInfo != None) && (injured.PlayerReplicationInfo.HasFlag != None) )
				injured.Controller.SendMessage(None, 'OTHER', injured.Controller.GetMessageIndex('INJURED'), 15, 'TEAM');
		}
	}
	return Super.ReduceDamage( Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
}

function bool SameTeam(Controller a, Controller b)
{
    if(( a == None ) || ( b == None ))
        return( false );

    return (a.PlayerReplicationInfo.Team.TeamIndex == b.PlayerReplicationInfo.Team.TeamIndex);
}

function bool TooManyBots(Controller botToRemove)
{ 
	if ( (botToRemove.PlayerReplicationInfo != None)
		&& (botToRemove.PlayerReplicationInfo.Team != None) )
	{
		if ( botToRemove.PlayerReplicationInfo.Team == Teams[0] )
		{
			if ( Teams[0].Size < Teams[1].Size )
				return false;
		}
		else if ( Teams[1].Size < Teams[0].Size )
			return false;
	}
    return Super.TooManyBots(botToRemove);
}

function PlayEndOfMatchMessage()
{
	local controller C;
	
    if ( ((Teams[0].Score == 0) || (Teams[1].Score == 0))
		&& (Teams[0].Score + Teams[1].Score >= 3) )
	{
		for ( C = Level.ControllerList; C != None; C = C.NextController )
		{
			if ( C.IsA('PlayerController') )
			{
				if ( Teams[0].Score > Teams[1].Score )
				{
					if ( (C.PlayerReplicationInfo.Team == Teams[0]) || C.PlayerReplicationInfo.bOnlySpectator )
						PlayerController(C).PlayAnnouncement(AltEndGameSound[0],1,true);
					else
						PlayerController(C).PlayAnnouncement(AltEndGameSound[1],1,true);
				}
				else
				{
					if ( (C.PlayerReplicationInfo.Team == Teams[1]) || C.PlayerReplicationInfo.bOnlySpectator )
						PlayerController(C).PlayAnnouncement(AltEndGameSound[0],1,true);
					else
						PlayerController(C).PlayAnnouncement(AltEndGameSound[1],1,true);
				}
			}
		}
	}
    else
    {    
		for ( C = Level.ControllerList; C != None; C = C.NextController )
		{
			if ( C.IsA('PlayerController') )
			{
				if (Teams[0].Score > Teams[1].Score)
					PlayerController(C).PlayAnnouncement(EndGameSound[0],1,true);
				else
					PlayerController(C).PlayAnnouncement(EndGameSound[1],1,true);
			}
		}
	}
}

static function string FindTeamDesignation(GameReplicationInfo GRI, actor A)	
{
	if ( (GRI == None) || (GRI.Teams[0].HomeBase == None) || (GRI.Teams[1].HomeBase == None) )
		return "";
	
	if (vsize(A.location - GRI.Teams[0].HomeBase.Location) < vsize(A.location - GRI.Teams[1].HomeBase.Location))
		return GRI.Teams[0].GetHumanReadableName()$" ";
	else
		return GRI.Teams[1].GetHumanReadableName()$" ";
}

static function string ParseMessageString(Mutator BaseMutator, Controller Who, String Message)
{
	local string OutMsg;
	local string cmd;
	local int pos,i;

	OutMsg = "";
	pos = InStr(Message,"%");
	while (pos>-1) 
	{
		if (pos>0)
		{
		  OutMsg = OutMsg$Left(Message,pos);
		  Message = Mid(Message,pos);
		  pos = 0;
	    }

		i = len(Message);
		cmd = mid(Message,pos,2);
		if (i-2 > 0)
			Message = right(Message,i-2);
		else
			Message = "";

		// FIXME_MERGE OutMsg = OutMsg$ParseChatPercVar(BaseMutator, Who,Cmd);
		pos = InStr(Message,"%");
	}

	if (Message!="")
		OutMsg=OutMsg$Message;
	
	return OutMsg;
}

function FindNewObjectives(GameObjective DisabledObjective)
{
	Teams[0].AI.FindNewObjectives(DisabledObjective);
	Teams[1].AI.FindNewObjectives(DisabledObjective);
}

function AnnounceScore(int ScoringTeam)
{
	local Controller C;
	local sound ScoreSound;
	local int OtherTeam;
	
	if ( ScoringTeam == 1 )
		OtherTeam = 0;
	else
		OtherTeam = 1;
		
	if ( Teams[ScoringTeam].Score == Teams[OtherTeam].Score + 1 )
		ScoreSound = TakeLead[ScoringTeam];
	else if ( Teams[ScoringTeam].Score == Teams[OtherTeam].Score + 2 ) 
		ScoreSound = IncreaseLead[ScoringTeam];
	else
		ScoreSound = CaptureSound[ScoringTeam];
		
	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( C.IsA('PlayerController') )
			PlayerController(C).PlayAnnouncement(ScoreSound,1,true);
	}
}

event PostLogin( PlayerController NewPlayer )
{
	Super.PostLogin( NewPlayer );
	if ( NewPlayer.PlayerReplicationInfo.Team != None )
		GameEvent("TeamChange",""$NewPlayer.PlayerReplicationInfo.Team.TeamIndex,NewPlayer.PlayerReplicationInfo);
}

defaultproperties
{
	bScoreTeamKills=true
	bBalanceTeams=true
	bPlayersBalanceTeams=true
	MaxTeamSize=16
	TeamAIType[0]=Class'TeamAI'
	TeamAIType[1]=Class'TeamAI'
	NearString="Near the"
	CaptureSound[0]=Sound'AnnouncerMain.red_team_scores'
	CaptureSound[1]=Sound'AnnouncerMain.blue_team_scores'
	TakeLead[0]=Sound'AnnouncerMain.red_team_takes_the_lead'
	TakeLead[1]=Sound'AnnouncerMain.blue_team_takes_the_lead'
	IncreaseLead[0]=Sound'AnnouncerMain.red_team_increases_their_lead'
	IncreaseLead[1]=Sound'AnnouncerMain.blue_team_increases_their_lead'
	HatTrickSound=Sound'AnnouncerMain.Hattrick'
	TGPropsDisplayText[0]="Bots Balance Teams"
	TGPropsDisplayText[1]="Players Balance Teams"
	TGPropsDisplayText[2]="Max Team Size"
	TGPropsDisplayText[3]="Friendly Fire Scale"
	ADR_Goal=25
	ADR_Return=5
	ADR_Control=2
	NumRounds=5
	EndMessageWait=3
	EndGameSound[0]=Sound'AnnouncerMain.red_team_is_the_winner'
	EndGameSound[1]=Sound'AnnouncerMain.blue_team_is_the_winner'
	SinglePlayerWait=2
	bWeaponStay=true
	bCanChangeSkin=false
	bTeamGame=true
	ScoreBoardType="WarfareGame.TeamScoreboard"
	BeaconName="Team"
	GameName="Team Deathmatch"
	GoalScore=60
}