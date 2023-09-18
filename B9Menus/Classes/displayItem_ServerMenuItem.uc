class  displayitem_ServerMenuItem extends displayItem;

var B9MP_ServerDescription fServerDescription;
var B9MP_Client	fClient;
var B9MP_ServerBrowser fServerBrowser;
var B9_CharacterManager fCharacterManager;

function bool handleKeyEvent( Interactions.EInputKey KeyIn, out Interactions.EInputAction Action, float Delta)
{
// Default handler handles nothing overload this to add functionality
	return false;
}

function ClickItem(optional B9_MenuPDA_Menu menu)
{
	Super.ClickItem( menu );
}

// This is the function that is called when the displayitem is selected
function ActOnClick(out B9_PDABase PDA,optional class<B9_MenuPDA_Menu> returnMenuClass)
{
	PDA.AddMenu( None );
	
	JoinGame( PDA );
}
function JoinGame( B9_PDABase PDA )
{
	local Pawn pawn;
	local Pawn oldPawn;
	local Actor A;
	local vector loc;
	local String URL;

	if ( ( fServerDescription == None ) || ( fServerBrowser.PreJoinGame(fServerDescription) == kFailure ) )
	{
		Log("Failed to join game");
	}
	
	Log( "MP: Join server [" $ fServerDescription.fInfo.fName $ "] Addr [" $ fServerDescription.fInfo.fIPAddress $ "]" );

	ForEach PDA.RootController.AllActors(class'Actor', A)
	{
		if ( A.Name == 'LookTarget8' )
		{
			loc = A.location;
			break;
		}
	}

	URL = fServerDescription.fInfo.fIPAddress $ "?Class=" $ fCharacterManager.GetSelectedClass();

	pawn = PDA.RootController.spawn( class<Pawn>(DynamicLoadObject( fCharacterManager.GetSelectedClass(), class'Class' ) ), , , loc );
	if ( pawn != None )
	{
		log( "MP: Joining server: (spawned pawn)" );

		if ( PDA.RootController.pawn != None )
		{
			Log( "MP: Joining server: (unpossess)" );

			oldPawn = PDA.RootController.pawn;
			PDA.RootController.UnPossess();
			oldPawn.Destroy();
		}

		Log( "MP: Joining server: (possess)" );

		PDA.RootController.Possess(pawn);
	}

	// Load player settings
	fCharacterManager.GetSelectedCharacter( PDA.RootController.Player );
	pawn = PDA.RootController.Player.Actor.Pawn;

	B9_PlayerPawn(pawn).SetMultiplayer();

	URL = URL $ "?NAME=" $ fClient.fClientDescription.fInfo.fName;
	URL = URL $ "?CharacterData=" $ fCharacterManager.StorePlayerToEncodedString( pawn );

	Log( "MP: SERVER OPEN [[" $ URL $ "]]" );

	PDA.RootController.ClientTravel( URL, TRAVEL_Absolute, true );
}
