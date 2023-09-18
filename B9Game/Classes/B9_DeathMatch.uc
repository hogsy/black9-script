//=============================================================================
// B9_DeathMatch
//=============================================================================
class B9_DeathMatch extends B9_UnrealMPGameInfo
	config;

var int	TimeLimit;			// time limit in minutes
var int NumRounds;
var globalconfig int NetWait;		// time to wait for players in netgames w/ bNetReady (typically team games)
var globalconfig int MinNetPlayers;	// how many players must join before net game will start
var globalconfig int RestartWait;

var globalconfig bool bTournament;	// number of players must equal maxplayers for game to start
var config bool bPlayersMustBeReady;// players must confirm ready for game to start
var config bool	bForceRespawn;
var config bool	bAdjustSkill;
var bool	bWaitForNetPlayers;		// wait until more than MinNetPlayers players have joined before starting match
var bool	bMustJoinBeforeStart;	// players can only spectate if they join after the game starts

var byte StartupStage;				// what startup message to display
var	int RemainingTime, ElapsedTime;
var int CountDown;
var float AdjustedDifficulty;
var int PlayerKills, PlayerDeaths;
//var class<B9_SquadAI> DMSquadClass;	// squad class to use for bots in DM games (no team)
var class<B9_LevelGameRules> B9_LevelRulesClass;

// Bot related info
var		int			RemainingBots;
var		int			InitialBots;

var NavigationPoint LastPlayerStartSpot;	// last place player looking for start spot started from
var NavigationPoint LastStartSpot;			// last place any player started from

var		int			NameNumber;				// append to ensure unique name if duplicate player name change requested

function PostBeginPlay()
{
	if ( bAlternateMode )
		GoreLevel = 2;

	Super.PostBeginPlay();
	GameReplicationInfo.RemainingTime = RemainingTime;
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	ElapsedTime = NetWait - 3;
	bWaitForNetPlayers = ( Level.NetMode != NM_StandAlone );
	StartupStage = 0;
	CountDown = Default.Countdown;
	RemainingTime = 60 * TimeLimit;
	GotoState('PendingMatch');
}

/* CheckReady()
If tournament game, make sure that there is a valid game winning criterion
*/
function CheckReady()
{
	if ( (GoalScore == 0) && (TimeLimit == 0) )
	{
		TimeLimit = 20;
		RemainingTime = 60 * TimeLimit;
	}
}

// Parse options for this game...
event InitGame( string Options, out string Error )
{
	local string InOpt;

	// find Level's LevelGameRules actor if it exists
	ForEach AllActors(class'B9_LevelGameRules', LevelRules)
		break;
	if ( LevelRules == None )
		LevelRules = spawn(B9_LevelRulesClass);

	RemainingRounds = LevelRules.GetNumRounds(NumRounds);
	GoalScore = LevelRules.GetGoalScore(GoalScore); 
	TimeLimit = LevelRules.GetTimeLimit(TimeLimit);
	MaxLives = LevelRules.GetMaxLives(MaxLives);
	if ( Level.NetMode == NM_Standalone )
		InitialBots = LevelRules.RecommendedNumPlayers[0] + LevelRules.RecommendedNumPlayers[1] - 1;
	Super.InitGame(Options, Error);

	SetGameSpeed(GameSpeed);
	MinPlayers = GetIntOption( Options, "MinPlayers", MinPlayers );
	RemainingRounds = GetIntOption( Options, "RemainingRounds", RemainingRounds );
	MaxLives = GetIntOption( Options, "MaxLives", MaxLives );
	GoalScore = GetIntOption( Options, "GoalScore", GoalScore );
	TimeLimit = GetIntOption( Options, "TimeLimit", TimeLimit );
	InitialBots = GetIntOption( Options, "NumBots", InitialBots );
	RemainingTime = 60 * TimeLimit;

/*	InOpt = ParseOption( Options, "CoopWeaponMode");
	if ( InOpt != "" )
	{
		log("CoopWeaponMode: "$bool(InOpt));
		bCoopWeaponMode = bool(InOpt);
	}
*/
	bTournament = (GetIntOption( Options, "Tournament", 0 ) > 0);
	if ( bTournament ) 
		CheckReady();
	bWaitForNetPlayers = ( Level.NetMode != NM_StandAlone );
}

/* AcceptInventory()
Examine the passed player's inventory, and accept or discard each item
* AcceptInventory needs to gracefully handle the case of some inventory
being accepted but other inventory not being accepted (such as the default
weapon).  There are several things that can go wrong: A weapon's
AmmoType not being accepted but the weapon being accepted -- the weapon
should be killed off. Or the player's selected inventory item, active
weapon, etc. not being accepted, leaving the player weaponless or leaving
the HUD inventory rendering messed up (AcceptInventory should pick another
applicable weapon/item as current).
*/
/*
function AcceptInventory(pawn PlayerPawn)
{
	local inventory Inv,next;

	Inv = PlayerPawn.Inventory;
	while ( Inv != None )
	{
		next = Inv.Inventory;
		Inv.Destroy();
		Inv = Next;
	}

	PlayerPawn.Weapon = None;
	PlayerPawn.SelectedItem = None;
	AddDefaultInventory( PlayerPawn );
}
*/

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local Controller P;
	local PlayerController Player;

	if ( (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
		return false;

	// check for tie
	for ( P=Level.ControllerList; P!=None; P=P.nextController )
		if ( P.bIsPlayer && (Winner != P) && (P.PlayerReplicationInfo.Score == Winner.Score) 
			&& !P.PlayerReplicationInfo.bOutOfLives )
		{
			log("DeathMatch Tie!");
			BroadcastLocalizedMessage( GameMessageClass, 0 );
			return false;
		}		

	EndTime = Level.TimeSeconds + 3.0;
	GameReplicationInfo.Winner = Winner;
	log( "Game ended at "$EndTime);
	for ( P=Level.ControllerList; P!=None; P=P.nextController )
	{
		Player = PlayerController(P);
		if ( Player != None )
		{
//			PlayWinMessage(Player, (Player.PlayerReplicationInfo == Winner));
//			Player.ClientSetBehindView(true);
//			if ( Controller(Winner.Owner).Pawn != None )
//				Player.SetViewTarget(Controller(Winner.Owner).Pawn);
//			Player.ClientGameEnded();
		}
		P.GotoState('GameEnded');
	}
	return true;
}

function PlayWinMessage(PlayerController Player, bool bWinner)
{
	UnrealPlayer(Player).PlayWinMessage(bWinner);
}

event PlayerController Login
(
	string Portal,
	string Options,
	out string Error
)
{
	local PlayerController NewPlayer;

	NewPlayer = Super.Login(Portal,Options,Error);
	if ( bMustJoinBeforeStart && !bWaitingToStartMatch )
		UnrealPlayer(NewPlayer).bLatecomer = true;

	return NewPlayer;
}

event PostLogin( playercontroller NewPlayer )
{
	Log("B9_DeathMatch.PostLogin start");
	Super.PostLogin(NewPlayer);
	
	if (B9_PlayerController(NewPlayer) != None && NewPlayer.PlayerReplicationInfo.Team != None)
	{
		Log("B9_DeathMatch.PostLogin call TeamChanged: "$NewPlayer.PlayerReplicationInfo.Team.TeamIndex);
		B9_PlayerController(NewPlayer).TeamChanged();
	}

	//if ( UnrealPlayer(NewPlayer) != None )
	//	UnrealPlayer(NewPlayer).PlayStartUpMessage(StartupStage);
}

function ChangeLoadOut(PlayerController P, string LoadoutName)
{
	local class<UnrealPawn> NewLoadout;

	NewLoadout = class<UnrealPawn>(DynamicLoadObject(LoadoutName,class'Class'));
	if ( (NewLoadout != None) 
		&& ((B9_UnrealTeamInfo(P.PlayerReplicationInfo.Team) == None) || B9_UnrealTeamInfo(P.PlayerReplicationInfo.Team).BelongsOnTeam(NewLoadout)) )
	{
		P.PawnClass = NewLoadout;
		if (P.Pawn!=None)
			P.ClientMessage("Your next class is "$P.PawnClass.Default.MenuName);
	}
}

function RestartPlayer( Controller aPlayer, bool IsFromDeath )	
{
	if ( bMustJoinBeforeStart && (UnrealPlayer(aPlayer) != None)
		&& UnrealPlayer(aPlayer).bLatecomer )
		return;

	if ( aPlayer.PlayerReplicationInfo.bOutOfLives )
		return;

	if ( aPlayer.IsA('Bot')
		&& TooManyBots(aPlayer) )
	{
		aPlayer.Destroy();
		return;
	} 

	Super.RestartPlayer(aPlayer, IsFromDeath);
}

function SendStartMessage(PlayerController P)
{
	UnrealPlayer(P).PlayStartupMessage(2);
}

function ForceAddBot()
{
	// add bot during gameplay
	if ( Level.NetMode != NM_Standalone )
		MinPlayers = Max(MinPlayers+1, NumPlayers + NumBots + 1);
	AddBot();
}

function bool AddBot()
{
	local Bot NewBot;

	NewBot = SpawnBot();
	if ( NewBot == None )
	{
		warn("Failed to spawn bot.");
		return false;
	}
	// broadcast a welcome message.
	BroadcastLocalizedMessage(GameMessageClass, 1, NewBot.PlayerReplicationInfo);

	NewBot.PlayerReplicationInfo.PlayerID = CurrentID++;
	NumBots++;
	RestartPlayer(NewBot, false);
		
	// Log it.
/*	if (StatLog != None)
	{
		StatLog.LogPlayerConnect(NewBot);
		StatLog.FlushLog();
	}*/
	return true;
}
/*
function AddDefaultInventory( pawn PlayerPawn )
{
	if ( UnrealPawn(PlayerPawn) != None )
		UnrealPawn(PlayerPawn).AddDefaultInventory();
	SetPlayerDefaults(PlayerPawn);
}
*/
function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
	if ( ViewTarget.IsA('Controller') )
		return false;
	return ( (Level.NetMode == NM_Standalone) || bOnlySpectator );
}

function bool ShouldRespawn(Pickup Other)
{
	return ( Other.ReSpawnTime!=0.0 );
}

function ChangeName(Controller Other, string S, bool bNameChange)
{
	local Controller APlayer;

	if ( S == "" )
		return;

	if (Other.PlayerReplicationInfo.playername~=S)
		return;
	
	for( APlayer=Level.ControllerList; APlayer!=None; APlayer=APlayer.nextController )
		if ( APlayer.bIsPlayer && (APlayer.PlayerReplicationInfo.playername~=S) )
		{
			if ( Other.IsA('PlayerController') )
			{
				PlayerController(Other).ReceiveLocalizedMessage( GameMessageClass, 8 );
				return;
			}
			else
			{
				S = S$"_"$NameNumber;
				NameNumber++;
			}
		}

	Other.PlayerReplicationInfo.SetPlayerName(S);
	if ( bNameChange )
		BroadcastLocalizedMessage( GameMessageClass, 2, Other.PlayerReplicationInfo );			

/*	if (StatLog != None)
		StatLog.LogNameChange(Other);*/
}

function Logout(controller Exiting)
{
	Super.Logout(Exiting);
	if ( Exiting.IsA('Bot') )
		NumBots--;
	if ( (Level.NetMode != NM_Standalone) && NeedPlayers() && !AddBot() )
		RemainingBots++;
}

function bool NeedPlayers()
{
	if ( Level.NetMode == NM_Standalone )
		return ( RemainingBots > 0 );
	if ( bMustJoinBeforeStart )
		return false;
	return (NumPlayers + NumBots < MinPlayers);
}

function LogGameParameters()
{
//	Super.LogGameParameters();

/*	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GoalScore"$Chr(9)$GoalScore);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"TimeLimit"$Chr(9)$TimeLimit);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MultiPlayerBots"$Chr(9)$(MinPlayers > 0));
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"TournamentMode"$Chr(9)$bTournament);
	if (Level.NetMode == NM_DedicatedServer)
		StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"NetMode"$Chr(9)$"DedicatedServer");
	else if (Level.NetMode == NM_ListenServer)
		StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"NetMode"$Chr(9)$"ListenServer");
	else if (Level.NetMode == NM_Standalone)
		StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"NetMode"$Chr(9)$"PracticeMatch");
*/}

//------------------------------------------------------------------------------
// Game Querying.

function string GetRules()
{
	local string ResultSet;
//	ResultSet = Super.GetRules();

	ResultSet = ResultSet$"\\timelimit\\"$TimeLimit;
	ResultSet = ResultSet$"\\goalscore\\"$GoalScore;
	Resultset = ResultSet$"\\minplayers\\"$MinPlayers;
	Resultset = ResultSet$"\\tournament\\"$bTournament;
	return ResultSet;
}

function InitGameReplicationInfo()
{
	Super.InitGameReplicationInfo();
	GameReplicationInfo.GoalScore = GoalScore;
	GameReplicationInfo.TimeLimit = TimeLimit;
}

//------------------------------------------------------------------------------

function B9_UnrealTeamInfo GetBotTeam()
{
	return LevelRules.GetDMRoster();
}

/* Spawn and initialize a bot
*/
function Bot SpawnBot()
{
	local Bot NewBot;
	local RosterEntry Chosen;
	local B9_UnrealTeamInfo BotTeam;

	BotTeam = GetBotTeam();
	if( BotTeam != None )
	{
		Chosen = BotTeam.ChooseBotClass();
		if( Chosen != None )
		{
			if( Chosen.PawnClass == None )
			{
				log("PawnClass Invalid!");
			}
			/*if( Chosen.PawnClass.Default == None )
			{
					log("PawnClass.Default Invalid!");
			}*/
			NewBot = Bot(Spawn(Chosen.PawnClass.Default.ControllerClass));
			if ( NewBot != None )
				InitializeBot(NewBot,BotTeam,Chosen);
			return NewBot;
		}else
		{
			log("Bot Chose Invalid!");
		}
	}else
	{
		log("Bot Team Invalid");
		return NewBot;
	}
}

/* Initialize bot
*/
function InitializeBot(Bot NewBot, B9_UnrealTeamInfo BotTeam, RosterEntry Chosen)
{
	NewBot.InitializeSkill(GameDifficulty);
	NewBot.PawnClass = Chosen.PawnClass;
	BotTeam.AddToTeam(NewBot);
	ChangeName(NewBot, Chosen.PlayerName, false);
	Chosen.InitBot(NewBot);
//	BotTeam.SetBotOrders(NewBot,Chosen);
}

/* initialize a bot which is associated with a pawn placed in the level
*/
function InitPlacedBot(Controller C, RosterEntry R)
{
	local B9_UnrealTeamInfo BotTeam;

	if ( C.Pawn == None )
		warn("Placed bot with no pawn???");
	
	BotTeam = FindTeamFor(C);
	InitializeBot(Bot(C),BotTeam,None);
}

function B9_UnrealTeamInfo FindTeamFor(Controller B)
{
	return GetBotTeam();
}
//------------------------------------------------------------------------------
// Game States

function StartMatch()
{
	local bool bTemp;

	GotoState('MatchInProgress');
	if ( Level.NetMode == NM_Standalone )
		RemainingBots = InitialBots;
	else
		RemainingBots = 0;
	GameReplicationInfo.RemainingMinute = RemainingTime;
	Super.StartMatch();
	bTemp = bMustJoinBeforeStart;
	bMustJoinBeforeStart = false;
	while ( NeedPlayers() && AddBot() )
		RemainingBots--;
	bMustJoinBeforeStart = bTemp;

}

function EndGame(PlayerReplicationInfo Winner, string Reason )
{
	if ( LevelRules.bOnlyObjectivesWin && (Reason != "triggered") && (Reason != "LastMan") && (Reason != "TimeLimit") )
		return;
	Super.EndGame(Winner,Reason);
	if ( bGameEnded )
		GotoState('MatchOver');
}

/* FindPlayerStart()
returns the 'best' player start for this player to start from.
*/
function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string incomingName)
{
	local NavigationPoint Best;

	if ( (Player != None) && (Player.StartSpot != None) )
		LastPlayerStartSpot = Player.StartSpot;

	Best = Super.FindPlayerStart(Player, InTeam, incomingName );
	if ( Best != None )
		LastStartSpot = Best;
	return Best;
}

auto State PendingMatch
{
	function bool AddBot()
	{
		if ( Level.NetMode == NM_Standalone )
			InitialBots++;
		return true;
	}
	
	function Timer()
	{
		local Controller P;
		local bool bReady;
		Super.Timer();

		// first check if there are enough net players, and enough time has elapsed to give people
		// a chance to join
		if ( bWaitForNetPlayers )
		{
			if ( NumPlayers > 0 )
			{
//				log("NumPlayers > 0");
				ElapsedTime++;
//				log(ElapsedTime$":"$NetWait$"NimPlayers"$MinNetPlayers);
			}
			else
				ElapsedTime = 0;
			if ( (NumPlayers == MaxPlayers) 
				|| ((ElapsedTime > NetWait) && (NumPlayers >= MinNetPlayers)) )
			{
				bWaitForNetPlayers = false;
				CountDown = 3;
			}
		}

		// keep message displayed for waiting players
		for (P=Level.ControllerList; P!=None; P=P.NextController )
			if ( UnrealPlayer(P) != None )
				UnrealPlayer(P).PlayStartUpMessage(StartupStage);

		if ( bWaitForNetPlayers || (bTournament && (NumPlayers < MaxPlayers)) )
			return;

		// check if players are ready
		bReady = true;
		StartupStage = 1;
		if ( bTournament || bPlayersMustBeReady || (Level.NetMode == NM_Standalone) )
		{
			for (P=Level.ControllerList; P!=None; P=P.NextController )
				if ( P.IsA('PlayerController') && (P.PlayerReplicationInfo != None)
					&& P.PlayerReplicationInfo.bWaitingPlayer
					&& !P.PlayerReplicationInfo.bReadyToPlay )
					bReady = false;
		}
		if ( bReady )
		{	
			CountDown--;
			if ( CountDown <= 0 )
				StartMatch();
			else
			{
				StartupStage = 2;
/*				for ( P = Level.ControllerList; P!=None; P=P.nextController )
					if ( UnrealPlayer(P) != None )
						UnrealPlayer(P).TimeMessage(CountDown);	*/	//UNDONE SCD$$$
			}
		}
	}
}

State MatchInProgress
{
	function Timer()
	{
//		local Controller P;

		Super.Timer();
/*
		if ( bForceRespawn )
			For ( P=Level.ControllerList; P!=None; P=P.NextController )
			{
				if ( (P.Pawn == None) && P.IsA('PlayerController') && !PlayerController(P).bOnlySpectator )
					PlayerController(P).ServerReStartPlayer();
			}
		if ( NeedPlayers() )
			AddBot();
		if ( !bOverTime && (TimeLimit > 0) )
		{
			GameReplicationInfo.bStopCountDown = false;
			RemainingTime--;
			GameReplicationInfo.RemainingTime = RemainingTime;
			if ( RemainingTime % 60 == 0 )
				GameReplicationInfo.RemainingMinute = RemainingTime;
			if ( RemainingTime <= 0 )
				EndGame(None,"TimeLimit");
		}
		else
		{
			ElapsedTime++;
			GameReplicationInfo.ElapsedTime = ElapsedTime;
		}
*/
	}

	function beginstate()
	{
		StartupStage = 3;	// if players join during gameplay
	}
}

State MatchOver
{
	function Timer()
	{
		Super.Timer();

		if ( Level.TimeSeconds > EndTime + RestartWait )
			RestartGame();
	}
	
	function bool NeedPlayers()
	{
		return false;
	}
}

/* Rate whether player should choose this NavigationPoint as its start
*/
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
	local PlayerStart P;
	local float Score, NextDist;
	local Controller OtherPlayer;

	P = PlayerStart(N);

	if ( (P == None) || !P.bEnabled || P.PhysicsVolume.bWaterVolume )
		return 1;

	//assess candidate
	Score = 10000000;
	if ( (N == LastStartSpot) || (N == LastPlayerStartSpot) )
		Score -= 10000.0;
	else
		Score += 3000 * FRand(); //randomize

	for ( OtherPlayer=Level.ControllerList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextController)	
		if ( OtherPlayer.bIsPlayer && (OtherPlayer.Pawn != None) )
		{
			if ( OtherPlayer.Pawn.Region.Zone == N.Region.Zone )
			{
				Score -= 1500;
				NextDist = VSize(OtherPlayer.Pawn.Location - N.Location);
				if ( NextDist < OtherPlayer.Pawn.CollisionRadius + OtherPlayer.Pawn.CollisionHeight )
					Score -= 1000000.0;
				else if ( (NextDist < 3000) && FastTrace(N.Location, OtherPlayer.Pawn.Location) )
					Score -= (10000.0 - NextDist);
			}
			else if ( NumPlayers + NumBots == 2 )
			{
				Score += 2 * VSize(OtherPlayer.Pawn.Location - N.Location);
				if ( FastTrace(N.Location, OtherPlayer.Pawn.Location) )
					Score -= 10000;
			}
		}
	return Score;
}

/* CheckScore()
see if this score means the game ends
*/
function CheckScore(PlayerReplicationInfo Scorer)
{
	local Controller C;
	local bool bNoneLeft;

	if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
		return;

	if ( (Scorer != None) && (bOverTime || (GoalScore > 0)) && (Scorer.Score >= GoalScore) )
		EndGame(Scorer,"fraglimit");

	// check if all other players are out
	if ( MaxLives > 0 )
	{
		bNoneLeft = true;
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
			if ( (C.PlayerReplicationInfo != None)
				&& !C.PlayerReplicationInfo.bOutOfLives )
			{
				bNoneLeft = false;
				break;
			} 
		if ( bNoneLeft )
			EndGame(Scorer,"LastMan");
	}	
}

function ScoreObjective(PlayerReplicationInfo Scorer, Int Score)
{
	if ( Scorer != None )
	{
		Scorer.Score += Score;
		if ( !bTeamScoreRounds && (Scorer.Team != None) )
			Scorer.Team.Score += Score;
	}

	if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreObjective(Scorer,Score);
	CheckScore(Scorer);
}

function ScoreKill(Controller Killer, Controller Other)
{
	if ( Other.PlayerReplicationInfo != None )
	{
		Other.PlayerReplicationInfo.NumLives++;
		if ( (MaxLives > 0)	&& (Other.PlayerReplicationInfo.NumLives >=MaxLives) )
			Other.PlayerReplicationInfo.bOutOfLives = true;
	}

	Super.ScoreKill(Killer,Other);

	if ( (killer == None) || (Other == None) )
		return;
		
	if ( bAdjustSkill && (killer.IsA('PlayerController') || Other.IsA('PlayerController')) )
	{
		if ( killer.IsA('AIController') )
			AdjustSkill(AIController(killer),true);
		if ( Other.IsA('AIController') )
			AdjustSkill(AIController(Other),false);
	}
}

function AdjustSkill(AIController B, bool bWinner)
{
	local float BotSkill;

	BotSkill = B.Skill;

	if ( bWinner )
	{
		PlayerKills += 1;
		AdjustedDifficulty = FMax(0, AdjustedDifficulty - 2/Min(PlayerKills, 10));
		if ( BotSkill > AdjustedDifficulty )
			B.Skill = AdjustedDifficulty;
	}
	else
	{
		PlayerDeaths += 1;
		AdjustedDifficulty += FMin(7,2/Min(PlayerDeaths, 10));
		if ( BotSkill < AdjustedDifficulty )
			B.Skill = AdjustedDifficulty;
	}
	if ( abs(AdjustedDifficulty - GameDifficulty) >= 1 )
	{
		GameDifficulty = AdjustedDifficulty;
		SaveConfig();
	}
}

function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	local float InstigatorSkill;

	Damage = Super.ReduceDamage( Damage, injured, InstigatedBy, HitLocation, Momentum, DamageType );

	if ( instigatedBy == None)
		return Damage;

	if ( Level.Game.GameDifficulty <= 3 )	// Shouldnt this just be GameDifficulty?  //UNDONE	SCD$$$
	{
		if ( injured.IsPlayerPawn() && (injured == instigatedby) && (Level.NetMode == NM_Standalone) )
			Damage *= 0.5;

		//skill level modification
		if ( AIController(instigatedBy.Controller) != None )
		{
			InstigatorSkill = AIController(instigatedBy.Controller).Skill;
			if ( (InstigatorSkill <= 3) && injured.IsHumanControlled() )
			{
				if ( ((instigatedBy.Weapon != None) && instigatedBy.Weapon.bMeleeWeapon) 
					|| ((injured.Weapon != None) && injured.Weapon.bMeleeWeapon && (VSize(injured.location - instigatedBy.Location) < 600)) )
					Damage = Damage * (0.76 + 0.08 * InstigatorSkill);
				else
					Damage = Damage * (0.25 + 0.15 * InstigatorSkill);
			}
		}
	} 
	return (Damage * instigatedBy.DamageScaling);
}

defaultproperties
{
	NumRounds=1
	NetWait=1
	MinNetPlayers=1
	RestartWait=1
	CountDown=1
	B9_LevelRulesClass=Class'B9_LevelGameRules'
	InitialBots=4
	GoalScore=30
	bRestartLevel=false
	bPauseable=false
	bLoggingGame=true
	AutoAim=1
	MapPrefix="DM"
	BeaconName="DM"
	MaxPlayers=10
	GameName="B9_DeathMatch"
	MutatorClass="UnrealGame.DMMutator"
}