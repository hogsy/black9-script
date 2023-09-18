class E3_JoinServer extends B9_MenuPDA_Menu
	config;

var B9MP_ServerBrowser fServerBrowser;
var localized string fPleaseWaitLabel;
var localized string fCreateGameLabel;
var localized string fLoadingLabel;
var localized string fCreatingServerLabel;
var localized string fTryingAgainLabel;
var bool fRanOnce;
var bool fReallyRanOnlyOnce;

var B9_CharacterManager fCharacterManager;
var B9MP_Client	fClient;

var string fServerGameName;
var	string fServerGameAddress;
var String fSelectedClass;
var Pawn fPawn;
var Pawn fMyPawn;
var B9MP_ServerDescription ServerDesc;
var globalconfig int fNumberOfTicksToWaitBeforeStartingServer;
var int fNumberOfTicksAlreadyWaited;
var globalconfig string fMapName;
var bool fFoundAServer;

var config String fDesiredServerPartialName;

var localized font fMSA24Font;

function bool handleKeyEvent(Interactions.EInputKey KeyIn,out Interactions.EInputAction Action, float Delta)
{
	local Interaction.EInputKey Key;
	Key = fPDABase.ConvertJoystick(KeyIn);

	if (fByeByeTicks == 0.0f)
	{
		if ( Key == IK_Joy3 )
		{
			// Must be filled out in the custom menu
		}else if (Key == IK_Joy4 )
		{
			// Must be filled out in the custom menu
		}else
		{
			return Super.handleKeyEvent( KeyIn , Action , Delta );
		}
	}
	return false;

}

function Init()
{
	local int indexpoint;
	local class<B9MP_ServerBrowser> fServerBrowserClass;
	local String onlinePkgNameSuffix;
	local class<B9MP_Client> fClientClass;

	// Loading
	indexpoint = 0;
	fDisplayItems.Insert(indexpoint,1);
	fDisplayItems[indexpoint]				= new(None)class'displayitem_GenericMenuItem';
	fDisplayItems[indexpoint].fLabel		= fLoadingLabel;
	fDisplayItems[indexpoint].fCanAcceptFocus = false;
	fDisplayItems[indexpoint].fItemFont=fMSA24Font;
	indexpoint = fDisplayItems.length;

	fFoundAServer = false;

	if ( IsPlatformXBox() )
	{
		onlinePkgNameSuffix = "XBox";
	}
	else
	{
		onlinePkgNameSuffix = "GameSpy";
	}

	if ( fClient == None )
	{
		ForEach fPDABase.RootController.AllActors( class'B9MP_Client', fClient )
		{
			break;
		}
		
		if ( fClient == None )
		{
			fClientClass = class<B9MP_Client>(DynamicLoadObject("B9MP_" $ onlinePkgNameSuffix $ ".B9MP_Client_" $ onlinePkgNameSuffix, class'Class'));
			if(fClientClass == None)
			{
				Log( "Failed to create fClientClass" );
			}
			fClient = fPDABase.RootController.Spawn( fClientClass );
			if( fClient == None )
			{
			
			}
		}
	}

log("inside init for E3_JoinServer");
	// Beacon for LAN games
	if ( fServerBrowser == None )
	{
			ForEach fPDABase.RootController.AllActors( class'B9MP_ServerBrowser', fServerBrowser )
		{
			break;
		}

		if ( fServerBrowser != None )
		{
			fServerBrowser.Destroy();
			fServerBrowser = None;
		}

		fServerBrowserClass = class<B9MP_ServerBrowser>(DynamicLoadObject("B9MP_" $ onlinePkgNameSuffix $ ".B9MP_ServerBrowser_" $ onlinePkgNameSuffix, class'Class'));

		fServerBrowser = fPDABase.RootController.Spawn( fServerBrowserClass );
	}


Log( "serverbrowser=" $ fServerBrowser $ " and serverbrowser dirty = " $ fServerBrowser.fServersDirty );

	if ( fServerBrowser == None )
	{
		// KMYNF: What?
	}
	else
	{
		fServerBrowser.fLAN = true;//B9_MMInteraction( parent ).fLAN;

		if ( fServerBrowser.fLAN )
			Log( "KMY PDA: Wait Menu asking for LAN servers" );
		else
			Log( "KMY: Wait Menu asking for Internet servers" );

		fServerBrowser.Refresh();
	}
	
		// Characters
	if ( fCharacterManager == None )
	{
		ForEach fPDABase.RootController.AllActors( class'B9_CharacterManager', fCharacterManager )
		{
			break;
		}

		if ( fCharacterManager == None )
		{
			fCharacterManager = fPDABase.RootController.Spawn( class'B9_CharacterManager' );
		}
	}	

	AddSimpleDisplayItem(fPleaseWaitLabel);
}


function UpdateMenu( float Delta )
{
	local displayitem_GenericMenuItem Item;

	Super.UpdateMenu( Delta );

	// This sets up the server browser when the fuction is first run.
	if ( ! fRanOnce )
	{
		fRanOnce = true;

		fMyPawn = fPDABase.RootController.Pawn;

		Init();
	}

	if ( fServerBrowser != none && fFoundAServer == false )
	{
		if ( fServerBrowser.fBrowseResult == kFailure )
		{
			log( "SB failed" );
			//TODO : Should clear list of the "please wait" msg
			AddSimpleDisplayItem( fServerBrowser.fErrorMessage ); 
			fServerBrowser.fServersDirty = false;
			fServerBrowser.fBrowseResult = kSuccess;
		}

		if ( fServerBrowser.fServersDirty )
		{
			log("Server list is now dirty");
			fFoundAServer = true;
			fNumberOfTicksAlreadyWaited = 0;
			ServerListIsDirty();
		}
		else 
			{
				++fNumberOfTicksAlreadyWaited;
				
				if( fNumberOfTicksAlreadyWaited > fNumberOfTicksToWaitBeforeStartingServer )
				{
					NoServerFound();
				}
			}
	}	
}
function CreateGame()
{
	local Pawn pawn;
	local Pawn oldPawn;
	local Actor A;
	local vector loc;
	local String URL;

	local string temp;

	//Creating Game
	fDisplayItems[0].fLabel		= fCreatingServerLabel;

	ForEach fPDABase.RootController.AllActors(class'Actor', A)
	{
		if ( A.Name == 'LookTarget0' )
		{
			loc = A.location;
			break;
		}
	}

	pawn = fPDABase.RootController.spawn( class<Pawn>(DynamicLoadObject( fCharacterManager.GetSelectedClass(), class'Class' ) ), , , loc );
	if ( pawn != None )
	{
		log( "MP: Joining server: (spawned pawn)" );

		if ( fPDABase.RootController.pawn != None )
		{
			Log( "MP: Joining server: (unpossess)" );

			oldPawn = fPDABase.RootController.pawn;
			fPDABase.RootController.UnPossess();
			oldPawn.Destroy();
		}

		Log( "MP: Joining server: (possess)" );

		fPDABase.RootController.Possess(pawn);
	}

	// Load player settings
	fCharacterManager.GetSelectedCharacter( fPDABase.RootController.Player );
	pawn = fPDABase.RootController.Player.Actor.Pawn;

	B9_PlayerPawn(pawn).SetMultiplayer();

	fSelectedClass = fCharacterManager.GetSelectedClass();

	URL = fMapName $ "?Listen" $ "?Class=" $ fSelectedClass;

	URL = URL $ "?NAME=" $ MapSpecialChars(fClient.fClientDescription.fInfo.fName);

	Log( "MP: CREATE SERVER [[" $ URL $ "]]" );

	fPDABase.RootController.ClientTravel( URL, TRAVEL_Absolute, true );
}


function ServerListIsDirty()
{
	local LinkedListElement element;
	local bool foundServer;

	foundServer = false;

	element = fServerBrowser.fServers.GetTop();

	if ( fDesiredServerPartialName != "" )
		Log( "Looking for server " $ fDesiredServerPartialName );
	else
		Log( "Looking for the first server" );

	while( element != None )
	{
		ServerDesc = B9MP_ServerDescription(element.fObject);

		if ( ( ServerDesc != None )
			&& ( fServerBrowser.PreJoinGame(ServerDesc) != kFailure ) 
			&& ( ( InStr( ServerDesc.fInfo.fName, fDesiredServerPartialName ) != -1 ) || ( fDesiredServerPartialName == "" ) )  )
		{
			fServerGameName = ServerDesc.fInfo.fName;
			fServerGameAddress = ServerDesc.fInfo.fIPAddress;
			foundServer = true;
			break;
		}

		element = element.fNext;
	}

	//Clear the lists dirty status
	fServerBrowser.fServersDirty = false;
	fServerBrowser.fServers.Clear();

	if ( foundServer )
	{
		log( "Decided to join server " $ fServerGameName );
		Join();
	}
	else
		NoServerFound();
}


function NoServerFound()
{
	fNumberOfTicksAlreadyWaited = 0;

	log( "Failed to find server " $ fDesiredServerPartialName $ " ...creating one" );
	CreateGame();
/*
	if ( IsPlatformXBox() )
	{
		log( "Failed to find server " $ fDesiredServerPartialName $ " ...creating one" );
		CreateGame();
	}
	else
	{
		log( "Failed to find any server, trying again" );

		fDisplayItems[0].fLabel		= fTryingAgainLabel;

		fFoundAServer = false;
		fServerBrowser.Refresh();
	}
*/
}


function Join()
{
	local Pawn oldPawn;
	local Actor A;
	local vector loc;
	local String URL;
	local Pawn pawn;

	Log( "MP: Join server [" $ fServerGameName $ "] Addr [" $ fServerGameAddress $ "]" );

//	PopInteraction( fPDABase.RootController, fPDABase.RootController.Player ); dferrellNF !!

	ForEach fPDABase.RootController.AllActors(class'Actor', A)
	{
		if ( A.Name == 'LookTarget0' )
		{
			loc = A.location;
			break;
		}
	}

	fSelectedClass = fCharacterManager.GetSelectedClass();

	URL = fServerGameAddress $ "?Class=" $ fCharacterManager.GetSelectedClass();

////
	pawn = fPDABase.RootController.spawn( class<Pawn>(DynamicLoadObject( fCharacterManager.GetSelectedClass(), class'Class' ) ), , , loc );
	log("Tried to spawn pawn:=" $ pawn );

	if ( pawn != None )
	{
		log( "MP: Joining server: (spawned pawn)" );

		if ( fPDABase.RootController.pawn != None )
		{
			Log( "MP: Joining server: (unpossess)" );

			oldPawn = fPDABase.RootController.pawn;
			fPDABase.RootController.UnPossess();
			oldPawn.Destroy();
		}

		Log( "MP: Joining server: (possess)" );

		fPDABase.RootController.Possess(pawn);
	}

	// Load player settings
	fCharacterManager.GetSelectedCharacter( fPDABase.RootController.Player );
	pawn = fPDABase.RootController.Player.Actor.Pawn;

	B9_PlayerPawn(pawn).SetMultiplayer();
////

	URL = URL $ "?NAME=" $ MapSpecialChars(fClient.fClientDescription.fInfo.fName);
	URL = URL $ "?CharacterData=" $ fCharacterManager.StorePlayerToEncodedString( pawn );

	Log( "MP: JOIN SERVER [[" $ URL $ "]]" );

	fPDABase.RootController.ClientTravel( URL, TRAVEL_Absolute, false );
}
function Initialize()
{
	//Don't do anything requiring controllers here!
	// Initialized() must be implemented in any subclass, but it can do nothing.
	// It is called before MenuInit() and can't refer to RootInteraction,
	// RootController or ParentInteraction. You don't have to implement MenuInit(),
	// but you should call super.MenuInit() if you do.	
}

defaultproperties
{
	fLoadingLabel="Loading..."
	fCreatingServerLabel="Creating Game..."
	fTryingAgainLabel="Server not found. Trying again."
	fNumberOfTicksToWaitBeforeStartingServer=3000
	fMapName="mp0x"
	fMSA24Font=Font'B9_Fonts.MicroscanA24'
}