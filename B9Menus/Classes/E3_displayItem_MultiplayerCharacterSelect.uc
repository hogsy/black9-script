class  E3_displayitem_MultiplayerCharacterSelect extends displayItem;

var int	fItemToChange;
var Pawn pawn;
var float DisplayFOV;

var B9_CharacterManager fCharacterManager;
var B9MP_Client	fClient;

function bool handleKeyEvent( Interactions.EInputKey KeyIn, out Interactions.EInputAction Action, float Delta)
{
// Default handler handles nothing overload this to add functionality
	return false;
}
function ClickItem(optional B9_MenuPDA_Menu menu)
{
	Super.ClickItem( menu );
}
// This is the function that is called when the displayitem is selected only if fbStartByeByeTImerOnClick is true
function ActOnClick(out B9_PDABase PDA,optional class<B9_MenuPDA_Menu> returnMenuClass)
{
	local Inventory Inv;

	if ( fCharacterManager == None )
	{
		ForEach PDA.RootController.AllActors( class'B9_CharacterManager', fCharacterManager )
		{
			break;
		}

		if ( fCharacterManager == None )
		{
			fCharacterManager = PDA.RootController.Spawn( class'B9_CharacterManager' );
		}
	}

	if ( fItemToChange == 6 )
	{
		fCharacterManager.SetSelection( 3 );
		CreateGame( PDA );
	}
	else
	{
		fCharacterManager.SetSelection( fItemToChange );

		PDA.AddMenu( class'E3_JoinServer', returnMenuClass );
	}

	return;
}

// Temporary code. Already in B9_MMInteraction (also temporary)
// and  B9_MenuPDA_Menu
function string MapSpecialChars(string URN)
{
	local int nIndex;
	local string Result;

	while(true)
	{
		nIndex = InStr(URN, " ");
		if(nIndex < 0)
		{
			break;
		}

		Result = Result $ Left(URN, nIndex) $ "%20";
		URN = Right(URN, Len(URN) - nIndex - 1);
	}

	if(Result == "")
	{
		Result = URN;
	}

	return Result;
}

function CreateGame( B9_PDABase PDA )
{
	local Pawn pawn;
	local Pawn oldPawn;
	local Actor A;
	local vector loc;
	local String URL;
	local String onlinePkgNameSuffix;
	local class<B9MP_Client> fClientClass;

	//Creating Game
	ForEach PDA.RootController.AllActors(class'Actor', A)
	{
		if ( A.Name == 'LookTarget0' )
		{
			loc = A.location;
			break;
		}
	}

////
	pawn = PDA.RootController.spawn( class<Pawn>(DynamicLoadObject( fCharacterManager.GetSelectedClass(), class'Class' ) ), , , loc );
	if ( pawn != None )
	{
		log( "MP: Creating server: (spawned pawn)" );

		if ( PDA.RootController.pawn != None )
		{
			Log( "MP: Creating server: (unpossess)" );

			oldPawn = PDA.RootController.pawn;
			PDA.RootController.UnPossess();
			oldPawn.Destroy();
		}

		Log( "MP: Creating server: (possess)" );

		PDA.RootController.Possess(pawn);
	}

	// Load player settings
	fCharacterManager.GetSelectedCharacter( PDA.RootController.Player );
	pawn = PDA.RootController.Player.Actor.Pawn;

	B9_PlayerPawn(pawn).SetMultiplayer();
////

	URL = "MP_M09A02" $ "?Listen" $ "?Class=" $ fCharacterManager.GetSelectedClass();

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
		ForEach PDA.RootController.AllActors( class'B9MP_Client', fClient )
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
			else
			{
				fClient = PDA.RootController.Spawn( fClientClass );
				if( fClient == None )
				{
					Log( "Failed to create fClient" );
				}
			}
		}
	}

	URL = URL $ "?NAME=" $ MapSpecialChars(fClient.fClientDescription.fInfo.fName);

	Log( "MP: SERVER OPEN [[" $ URL $ "]]" );

	PDA.RootController.ClientTravel( URL, TRAVEL_Absolute, true );
}


