/////////////////////////////////////////////////////////////
// B9_MM_MultiPlayer_GamesMenu
//
// 
// 
// This is CURRENTLY a debug menu.

class B9_MM_MultiPlayer_GamesMenu extends B9_MM_SimpleListMenu;

var localized string fCreateGameLabel;

var int fCreateItem;

var B9MP_ServerBrowser fServerBrowser;

var B9MP_Client		   fClient;

	 
function InitHandlers( PlayerController controller )
{
	local class<B9MP_ServerBrowser> fServerBrowserClass;
	local String onlinePkgNameSuffix;
	
	if ( IsPlatformXBox() )
	{
		onlinePkgNameSuffix = "XBox";
	}
	else
	{
		onlinePkgNameSuffix = "GameSpy";
	}

	// Beacon for LAN games
	if ( fServerBrowser == None )
	{
		ForEach controller.AllActors( class'B9MP_ServerBrowser', fServerBrowser )
		{
			break;
		}

		if ( fServerBrowser == None )
		{
			fServerBrowserClass = class<B9MP_ServerBrowser>(DynamicLoadObject("B9MP_" $ onlinePkgNameSuffix $ ".B9MP_ServerBrowser_" $ onlinePkgNameSuffix, class'Class'));

			fServerBrowser = controller.Spawn( fServerBrowserClass );
		}
	}

	// Characters
	if ( fCharacterManager == None )
	{
		ForEach controller.AllActors( class'B9_CharacterManager', fCharacterManager )
		{
			break;
		}

		if ( fCharacterManager == None )
		{
			fCharacterManager = controller.Spawn( class'B9_CharacterManager' );
		}
	}
	
	if(fClient == None)
	{
		ForEach controller.AllActors( class'B9MP_Client', fClient )
		{
			break;
		}
	}
}


// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentController. You don't have to implement MenuInit(),
// but you should call super.MenuInit().
function Initialized()
{
	log(self@"I'm alive");

	fHasGoBack = true;
}


function DeInitialize()
{
	if ( fServerBrowser != None )
	{
		fServerBrowser.Destroy();
		fServerBrowser = None;
	}
}


function RefreshMenus()
{
	local SimpleItemInfo info;
	local SimpleImageInfo img;
	local int x;
	local int y;
	local int yOffset;
	local int yImageOffset;
	local int i;
	local int nGameCount;
	
	local B9MP_ServerDescription ServerDesc;
	local LinkedListElement element;

	nGameCount = fServerBrowser.fServers.GetCount();
	
	x = 43;
	y = 281;
	yOffset = 40;
	yImageOffset = 60;

	fItemArray.Length = 1 + nGameCount;

	element = fServerBrowser.fServers.GetTop();

	i = 0;
	while( element != None )
	{
		ServerDesc = B9MP_ServerDescription(element.fObject);
		
		fItemArray[ i ].X = x;
		fItemArray[ i ].Y = y;
		fItemArray[ i ].Label = ServerDesc.fInfo.fName;
		Log("Server name" $ i $ "=" $(fItemArray[ i ].Label));

		y += yOffset;
		element = element.fNext;
		ServerDesc = None;

		i++;
	}

	fServerBrowser.fServersDirty = false;

	fItemArray[ i ].X = x;
	fItemArray[ i ].Y = y;
	fItemArray[ i ].Label = fCreateGameLabel;

	y += yImageOffset;


	fImageArray.Length = 4;

	img.X = 64;
	img.Y = 203;
	img.Image = texture'B9Menu_Tex_std.mp_title_left';
	fImageArray[0] = img;

	img.X = 320;
	img.Y = 203;
	img.Image = texture'B9Menu_Tex_std.mp_title_right';
	fImageArray[1] = img;

	img.X = 64;
	img.Y = y;
	img.Image = texture'B9MenuHelp_Textures.choice_select';
	fImageArray[2] = img;

	img.X = 320;
	img.Y = y;
	img.Image = texture'B9MenuHelp_Textures.choice_back';
	fImageArray[3] = img;

	Super.Initialized();
}


function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	Super.MenuInit( interaction, controller, parent );

	InitHandlers( controller );

	RefreshMenus();
}


function ClickItem()
{
	if ( fKeyDown == IK_Backspace )
	{
		Super.ClickItem();
		return;
	}

	if(fSelItem == fServerBrowser.fServers.GetCount())
	{
		CreateGame();
		fKeyDown = IK_None;
		return;
	}

	Join( fSelItem );
	fKeyDown = IK_None;
}

function Tick(float Delta)
{
	if ( fServerBrowser != none )
	{
		if ( fServerBrowser.fServersDirty )
		{
			// QuickMatch
			if ( fClient.fUseQuickMatch )
			{
				if(fServerBrowser.fServers.GetCount() != 0)
				{
					Join(0);
				}
				else
				{
					CreateGame();
				}
				GotoState('');
				return;
			}

			RefreshMenus();
		}
	}

	Super.Tick( Delta );
}


function Join( int choice )
{
	local string gameName;
	local string address;
	local Pawn pawn;
	local Pawn oldPawn;
	local Actor A;
	local vector loc;
	local String URL;

	local int i;
	local B9MP_ServerDescription ServerDesc;
	local LinkedListElement element;
	
	element = fServerBrowser.fServers.GetTop();

	i = 0;
	while( element != None )
	{
		ServerDesc = B9MP_ServerDescription(element.fObject);
			
		if( i  == choice )
		{
			break;
		}
		
		ServerDesc = None;
		element = element.fNext;

		i++;
	}
	
	if ( ( ServerDesc == None ) || ( fServerBrowser.PreJoinGame(ServerDesc) == kFailure ) )
	{
		Log("Failed to join game");
	}

	gameName = ServerDesc.fInfo.fName;
	address = ServerDesc.fInfo.fIPAddress;

	fServerBrowser.fServers.Clear();

	Log( "MP: Join server [" $ gameName $ "] Addr [" $ address $ "]" );

	PopInteraction( RootController, RootController.Player );

	ForEach RootController.AllActors(class'Actor', A)
	{
		if ( A.Name == 'LookTarget8' )
		{
			loc = A.location;
			break;
		}
	}

	URL = address $ "?Class=" $ fCharacterManager.GetSelectedClass();

	pawn = RootController.spawn( class<Pawn>(DynamicLoadObject( fCharacterManager.GetSelectedClass(), class'Class' ) ), , , loc );
	if ( pawn != None )
	{
		log( "MP: Joining server: (spawned pawn)" );

		if ( RootController.pawn != None )
		{
			Log( "MP: Joining server: (unpossess)" );

			oldPawn = RootController.pawn;
			RootController.UnPossess();
			oldPawn.Destroy();
		}

		Log( "MP: Joining server: (possess)" );

		RootController.Possess(pawn);
	}

	// Load player settings
	fCharacterManager.GetSelectedCharacter( RootController.Player );
	pawn = RootController.Player.Actor.Pawn;

	B9_PlayerPawn(pawn).SetMultiplayer();

	URL = URL $ "?NAME=" $ MapSpecialChars(fClient.fClientDescription.fInfo.fName);
	URL = URL $ "?CharacterData=" $ fCharacterManager.StorePlayerToEncodedString( pawn );

	Log( "MP: SERVER OPEN [[" $ URL $ "]]" );

	RootController.ClientTravel( URL, TRAVEL_Absolute, true );

}

function CreateGame( )
{
	local Pawn pawn;
	local Pawn oldPawn;
	local Actor A;
	local vector loc;
	local String URL;

	PopInteraction( RootController, RootController.Player );

	ForEach RootController.AllActors(class'Actor', A)
	{
		if ( A.Name == 'LookTarget8' )
		{
			loc = A.location;
			break;
		}
	}

	URL = "MPHQ?Listen" $ "?Class=" $ fCharacterManager.GetSelectedClass();
	URL = URL $ "?NAME=" $ MapSpecialChars(fClient.fClientDescription.fInfo.fName);

	pawn = RootController.spawn( class<Pawn>(DynamicLoadObject( fCharacterManager.GetSelectedClass(), class'Class' ) ), , , loc );
	if ( pawn != None )
	{
		if ( RootController.pawn != None )
		{
			oldPawn = RootController.pawn;
			RootController.UnPossess();
			oldPawn.Destroy();
		}

		RootController.Possess(pawn);
	}

	// Load player settings
	fCharacterManager.GetSelectedCharacter( RootController.Player );
	pawn = RootController.Player.Actor.Pawn;

	B9_PlayerPawn(pawn).SetMultiplayer();

	Log( "MP: SERVER OPEN [[" $ URL $ "]]" );

	RootController.ClientTravel( URL, TRAVEL_Absolute, true );
}

defaultproperties
{
	fCreateGameLabel="Create Game"
}