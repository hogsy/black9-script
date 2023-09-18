//=============================================================================
// UnrealMPGameInfo.
//
//
//=============================================================================
class UnrealMPGameInfo extends GameInfo
	config;

var globalconfig int  MinPlayers;		// bots fill in to guarantee this level in net game 

var config bool bTeamScoreRounds;
var bool	bSoaking;

var float EndTime;
var globalconfig float EndTimeDelay;
var TranslocatorBeacon BeaconList;
var class<Scoreboard> LocalStatsScreenClass;

// mc - localized PlayInfo descriptions & extra info
var private localized string MPGIPropsDisplayText[3];

function SpecialEvent(PlayerReplicationInfo Who, string Desc)
{
	if ( GameStats != None )
		GameStats.SpecialEvent(Who,Desc);
}

function KillEvent(string Killtype, PlayerReplicationInfo Killer, PlayerReplicationInfo Victim, class<DamageType> Damage)
{
	local TeamPlayerReplicationInfo TPRI;

	if ( (Killer == None) || (Killer == Victim) )
		TeamPlayerReplicationInfo(Victim).Suicides++;

	TPRI = TeamPlayerReplicationInfo(Killer);

	if ( TPRI != None )
	{
		if ( TPRI != Victim )
			TPRI.AddWeaponKill(Damage);
		TeamPlayerReplicationInfo(Victim).AddWeaponDeath(Damage);
	}

	if ( GameStats != None )
		GameStats.KillEvent(KillType, Killer, Victim, Damage);
}

function GameEvent(string GEvent, string Desc, PlayerReplicationInfo Who)
{
	local TeamPlayerReplicationInfo TPRI;

	if ( GameStats != None )
		GameStats.GameEvent(GEvent, Desc, Who);

	TPRI = TeamPlayerReplicationInfo(Who);

	if ( TPRI == None )
		return;

	if ( (GEvent ~= "flag_taken") || (GEvent ~= "flag_pickup")
		|| (GEvent ~= "bomb_taken") || (GEvent ~= "Bomb_pickup") )
	{
		TPRI.FlagTouches++;
		return;
	}

	if ( GEvent ~= "flag_returned" )
	{
		TPRI.FlagReturns++;
		return;
	}
}

function ScoreEvent(PlayerReplicationInfo Who, float Points, string Desc)
{
	if ( GameStats != None )
		GameStats.ScoreEvent(Who,Points,Desc);
}

function TeamScoreEvent(int Team, float Points, string Desc)
{
	if ( GameStats != None )
		GameStats.TeamScoreEvent(Team,Points,Desc);
}

function int GetNumPlayers()
{
	if ( NumPlayers > 0 )
		return (NumPlayers+NumBots);
	return Min(MinPlayers,MaxPlayers/2);
}

function bool ShouldRespawn(Pickup Other)
{
	return false;
}

function float SpawnWait(AIController B)
{
	if ( B.PlayerReplicationInfo.bOutOfLives )
		return 999;
	if ( Level.NetMode == NM_Standalone )
		return ( 0.5 * FMax(2,NumBots-4) * FRand() );
	return FRand();
}

function bool TooManyBots(Controller botToRemove)
{
	return ( (Level.NetMode != NM_Standalone) && (NumBots + NumPlayers > MinPlayers) );
}

function RestartGame()
{
	if ( EndTime > Level.TimeSeconds ) // still showing end screen
		return;
			
	Super.RestartGame();
}

function ChangeLoadOut(PlayerController P, string LoadoutName);
function ForceAddBot();

/* only allow pickups if they are in the pawns loadout
*/
function bool PickupQuery(Pawn Other, Pickup item)
{
	local byte bAllowPickup;

	if ( (GameRulesModifiers != None) && GameRulesModifiers.OverridePickupQuery(Other, item, bAllowPickup) )
		return (bAllowPickup == 1);

	if ( (UnrealPawn(Other) != None) && !UnrealPawn(Other).IsInLoadout(item.inventorytype) )
		return false;

	if ( Other.Inventory == None )
		return true;
	else
		return !Other.Inventory.HandlePickupQuery(Item);
}

function InitPlacedBot(Controller C, RosterEntry R);

defaultproperties
{
	EndTimeDelay=4
	LocalStatsScreenClass=Class'DMStatsScreen'
	MPGIPropsDisplayText[0]="Min Players"
	MPGIPropsDisplayText[1]="Team Score Rounds"
	MPGIPropsDisplayText[2]="Delay at End of Game"
	PlayerControllerClassName="UnrealGame.UnrealPlayer"
}