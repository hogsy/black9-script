//=============================================================================
// B9_UnrealMPGameInfo.
//
//
//=============================================================================
class B9_UnrealMPGameInfo extends B9_GameInfo
	config;

var config int	GoalScore; 
var globalconfig int  MinPlayers;		// bots fill in to guarantee this level in net game 
var config bool bTeamScoreRounds;
var bool	bSoaking;
var config int MaxLives;					// max number of lives for match, unless overruled by level's GameDetails
var int RemainingRounds;
var float EndTime;
var B9_LevelGameRules LevelRules;

var B9MP_Server fBeacon;

function InitHandlers()
{	
	local class<B9MP_Server> fServerClass;
	local String className;
	local String onlinePkgNameSuffix;
	
	if ( IsPlatformXBox() )
	{
		onlinePkgNameSuffix = "XBox";
	}
	else
	{
		onlinePkgNameSuffix = "GameSpy";
	}
	
	KillAnyBeacon();

	className = "B9MP_" $ onlinePkgNameSuffix $ ".B9MP_Server_" $ onlinePkgNameSuffix;
	fServerClass = class<B9MP_Server>(DynamicLoadObject( className, class'Class' ) );

	Log( "KMY: Spawn " $ fServerClass );
	Log( "KMY: Name " $ className );

	fBeacon = Spawn( fServerClass );
}


function KillAnyBeacon()
{
	local B9MP_Server B;

	if ( fBeacon != None )
	{
		fBeacon.Destroy();
		fBeacon = None;
	}

	// Bug fix for Beacon
	foreach AllActors( class 'B9MP_Server', B )
	{
		Log( "B9_UnrealMPGameInfo: Destroying beacon:" $ B );
		B.Destroy();
	}
}


event PreBeginPlay()
{
	Super.PreBeginPlay();

	InitHandlers();
}


event PostBeginPlay()
{
	if ( fBeacon == None )
	{
		Log( "MPGame: Failed to create server beacon!" );
		return;
	}

/*
	// The server name, i.e.: Bob's Server
	ResultSet = "\\hostname\\"$Level.Game.GameReplicationInfo.ServerName;

	// The short server name
	//ResultSet = ResultSet$"\\shortname\\"$Level.Game.GameReplicationInfo.ShortName;

	// The server port.
	ResultSet = ResultSet$"\\hostport\\"$Level.Game.GetServerPort();

	// The map/level title
	ResultSet = ResultSet$"\\maptitle\\"$Level.Title;

	// Map name
	ResultSet = ResultSet$"\\mapname\\"$Left(string(Level), InStr(string(Level), "."));

	// The mod or game type
	ResultSet = ResultSet$"\\gametype\\"$GetItemName(string(Level.Game.Class));

	// The number of players
	ResultSet = ResultSet$"\\numplayers\\"$Level.Game.NumPlayers;

	// The maximum number of players
	ResultSet = ResultSet$"\\maxplayers\\"$Level.Game.MaxPlayers;

	// The game mode: openplaying
	ResultSet = ResultSet$"\\gamemode\\openplaying";

	// The version of this game.
	ResultSet = ResultSet$"\\gamever\\"$Level.EngineVersion;

	// The most recent network compatible version.
	if( MinNetVer >= Int(Level.MinNetVersion) && 
		MinNetVer <= Int(Level.EngineVersion) )
		ResultSet = ResultSet$"\\minnetver\\"$string(MinNetVer);
	else
		ResultSet = ResultSet$"\\minnetver\\"$Level.MinNetVersion;

	ResultSet = ResultSet$Level.Game.GetInfo();

*/

//	fBeacon.fServerDescription.fInfo.fName				  = Level.Game.GameReplicationInfo.ServerName;
	fBeacon.fServerDescription.fInfo.fName				  = Level.Game.GetBeaconText();
	fBeacon.fServerDescription.fInfo.fIPAddress			  = Left( Level.GetAddressURL(), InStr( Level.GetAddressURL(), ":" ) );
	fBeacon.fServerDescription.fInfo.fMapName			  = Left(string(Level), InStr(string(Level), "."));

	Log( "KMY: Reported IP: " $ fBeacon.fServerDescription.fInfo.fIPAddress $ " whole addr [" $ Level.GetAddressURL() $ "]" );
	Log( "KMY: Reported Name: " $ fBeacon.fServerDescription.fInfo.fName $ " map: " $ fBeacon.fServerDescription.fInfo.fMapName );

	fBeacon.fServerDescription.fInfo.fGameType			  = kGameType_CaptureHold;
	fBeacon.fServerDescription.fInfo.fVisible			  = true;
	fBeacon.fServerDescription.fInfo.fDedicated			  = false;
	fBeacon.fServerDescription.fInfo.fRanked			  = true;
	fBeacon.fServerDescription.fInfo.fPrivate			  = false;
//	fBeacon.fServerDescription.fInfo.fStatus			  = 0;
	fBeacon.fServerDescription.fInfo.fCurrentPlayers	  = Level.Game.NumPlayers;
	fBeacon.fServerDescription.fInfo.fMinPlayers		  = 1;
	fBeacon.fServerDescription.fInfo.fMaxPlayers		  = Level.Game.MaxPlayers;
	fBeacon.fServerDescription.fInfo.fMinCharacterLevel	  = 0;
	fBeacon.fServerDescription.fInfo.fMaxCharacterLevel	  = 64;	// fBeacon.kMaxCharacterLevel;
	fBeacon.fServerDescription.fInfo.fPing				  = 0;
	fBeacon.fServerDescription.fInfo.fAveragePlayerSkill  = 100;
//	fBeacon.fServerDescription.fInfo.fWinningTeam		  = fBeacon.kSociety_Unknown;
//	fBeacon.fServerDescription.fInfo.fLosingTeam		  = fBeacon.kSociety_Unknown;
	fBeacon.fServerDescription.fInfo.fPlayerSkillsEncoded = "";
	
	fBeacon.Publish();
}


event Tick( float DeltaTime )
{
	if ( fBeacon != None )
	{
		fBeacon.Tick( DeltaTime );
	}

	Super.Tick( DeltaTime );
}


function ProcessServerTravel( string URL, bool bItems )
{
	if ( fBeacon != None )
		fBeacon.UnPublish( false );

	KillAnyBeacon();

	Super.ProcessServerTravel( URL, bItems );
}


function bool ShouldRespawn(Pickup Other)
{
	return false;
}


function float SpawnWait(AIController B)
{
	if ( B.PlayerReplicationInfo.bOutOfLives )
		return 999;
	return ( NumBots * FRand() );
}


function bool TooManyBots(Controller botToRemove)
{
	return ( (Level.NetMode != NM_Standalone) && (NumBots + NumPlayers > MinPlayers) );
}


//
// Log a player in.
// Fails login if you set the Error string.
// PreLogin is called before Login, but significant game time may pass before
// Login is called, especially if content is downloaded.
//
event PlayerController Login
(
	string Portal,
	string Options,
	out string Error
)
{
	local PlayerController NewPlayer;

	NewPlayer = Super.Login(Portal, Options, Error);
	if(NewPlayer != None)
	{
		fBeacon.fServerDescription.fInfo.fCurrentPlayers = NumPlayers;
		fBeacon.Refresh();
	}

	return NewPlayer;
}

function LogOut( Controller Exiting )
{
	local PlayerController playerC;
	local bool serverGoingDown;

// Not sure what to do here //UNDONE SCD$$$
//	if ( UnrealPawn(Exiting.Pawn) != None )
//		UnrealPawn(Exiting.Pawn).Logout();

	Super.LogOut(Exiting);

	// If server's leaving, stop beacon
	serverGoingDown = false;
	if ( Level.NetMode == NM_DedicatedServer )
	{
	}
	else
		if ( Level.NetMode == NM_ListenServer )
		{
			playerC = PlayerController( Exiting );

			if ( ( playerC != None ) && playerC.bIsLocallyControlled )
			{
				serverGoingDown = true;
			}
		}

	if ( serverGoingDown )
	{
		Log( "B9_UnrealMPGameInfo: Host is logging out (server shutdown)" );

		if ( fBeacon != None )
			fBeacon.UnPublish( true );

		KillAnyBeacon();
	}
	else
	{
		fBeacon.fServerDescription.fInfo.fCurrentPlayers = NumPlayers;
		fBeacon.Refresh();
	}
}

// This overwrites the default Restart as this intentionally allows the players to travel with their stuff
function RestartGame()
{
	local string NextMap;
	local MapList myList;
	local class<MapList> ML;

	if ( (GameRulesModifiers != None) && GameRulesModifiers.HandleRestartGame() )
		return;

	// these server travels should all be relative to the current URL
	if ( bChangeLevels && !bAlreadyChanged && (MapListType != "") )
	{
		// open a the nextmap actor for this game type and get the next map
		bAlreadyChanged = true;
		ML = class<MapList>(DynamicLoadObject(MapListType, class'Class'));
		myList = spawn(ML);
		NextMap = myList.GetNextMap();
		myList.Destroy();
		if ( NextMap == "" )
			NextMap = GetMapName(MapPrefix, NextMap,1);

		if ( NextMap != "" )
		{
			Level.ServerTravel(NextMap, true);
			return;
		}
	}

	Level.ServerTravel( "?Restart", true );
}

function ChangeLoadOut(PlayerController P, string LoadoutName);
function ForceAddBot();

function ApplyTravelInfo(pawn PlayerPawn, String playerName )
{
	local PlayerController player;

	player = PlayerController( PlayerPawn.Controller );

	if ( player == None )
	{
		return;
	}

	RestoreFromTravelInfo( playerName, player );
}


// Tan: Needed because the original Unreal base class version
//      no longer works!!!
// Instead of defaults, use the information they travelled in with
function AddDefaultInventory( pawn PlayerPawn )
{
	local PlayerController player;

	player = PlayerController( PlayerPawn.Controller );

	if ( player == None )
	{
  		Log( "KMY: pawn.controller is NOT PlayerController" );
   		return;
	}

  	Super.SetPlayerDefaults( PlayerPawn );
}


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
	bTeamScoreRounds=true
}