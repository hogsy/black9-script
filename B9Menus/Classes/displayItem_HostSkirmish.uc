class  displayitem_HostSkirmish extends displayItem;

var class<B9_MenuPDA_Menu> fNextMenuName;
var B9MP_ServerDescription fCurrentServerDescription;
var bool fIncrementValue;
var int	fValueToChange;
var string fServerGameName;
var	string fServerGameAddress;
var B9MP_Client	fClient;
var B9_CharacterManager fCharacterManager;

/*
	fValueToChange & fValueToDisplay values
	0	kMyServersMinNumberofPlayers,
	1	kMyServersMaxNumberofPlayers,
	2	kMyServersMinCharacterLevel,
	3	kMyServersMaxCharacterLevel,
	4	kMyServersCombatantGroup1,
	5	kMyServersCombatantGroup2,
	6	kMyServersIsAPrivateGame,
	7	kMyServersIsARankedGame,
	8	kMyServersGameType,
	9	kMyServersDetailedMapList,
	10	kMyServersCreateGame
*/

function bool handleKeyEvent( Interactions.EInputKey KeyIn, out Interactions.EInputAction Action, float Delta)
{
// Default handler handles nothing overload this to add functionality
	return false;
}
/*
function Draw(canvas Canvas, int focus, int beginPoint_X, int beginPoint_Y,int endPoint_X, int endPoint_Y, out B9_PDABase PDA)
{
	fLabel = ""$fCurrentServerDescription.fInfo.fMaxPlayers;
	Super.Draw(Canvas, focus, beginPoint_X, beginPoint_Y,endPoint_X, endPoint_Y, B9_PDABase PDA);
}
*/
function ClickItem(optional B9_MenuPDA_Menu menu)
{
	Super.ClickItem( menu );
	// Since fbStartByeByeTImerOnClick is set to false, actOnClick will not be called thus we act on the click instantly.

	if( fValueToChange == 0 )
	{
		if( fIncrementValue && fCurrentServerDescription.fInfo.fMinPlayers < fCurrentServerDescription.kMaxCharactersInGame )
		{
			fCurrentServerDescription.fInfo.fMinPlayers = 	fCurrentServerDescription.fInfo.fMinPlayers + 1;
		}
		else if( fCurrentServerDescription.fInfo.fMinPlayers > 1 )
		{
			fCurrentServerDescription.fInfo.fMinPlayers = 	fCurrentServerDescription.fInfo.fMinPlayers - 1;	
		}	
	}
	else if( fValueToChange == 1 )
	{
		if( fIncrementValue && fCurrentServerDescription.fInfo.fMaxPlayers < fCurrentServerDescription.kMaxCharactersInGame )
		{
			fCurrentServerDescription.fInfo.fMaxPlayers = 	fCurrentServerDescription.fInfo.fMaxPlayers + 1;
		}
		else if( fCurrentServerDescription.fInfo.fMaxPlayers > 1 )
		{
			fCurrentServerDescription.fInfo.fMaxPlayers = 	fCurrentServerDescription.fInfo.fMaxPlayers - 1;	
		}
	}
	else if( fValueToChange == 2 )
	{
		if( fIncrementValue && fCurrentServerDescription.fInfo.fMinCharacterLevel < fCurrentServerDescription.kMaxCharacterLevel )
		{
			fCurrentServerDescription.fInfo.fMinCharacterLevel = 	fCurrentServerDescription.fInfo.fMinCharacterLevel + 1;
		}
		else if( fCurrentServerDescription.fInfo.fMinCharacterLevel > 1 )
		{
			fCurrentServerDescription.fInfo.fMinCharacterLevel = 	fCurrentServerDescription.fInfo.fMinCharacterLevel - 1;	
		}	
	}
	else if( fValueToChange == 3 )
	{
		if( fIncrementValue && fCurrentServerDescription.fInfo.fMaxCharacterLevel < fCurrentServerDescription.kMaxCharacterLevel )
		{
			fCurrentServerDescription.fInfo.fMaxCharacterLevel = 	fCurrentServerDescription.fInfo.fMaxCharacterLevel + 1;
		}
		else if( fCurrentServerDescription.fInfo.fMaxCharacterLevel > 1 )
		{
			fCurrentServerDescription.fInfo.fMaxCharacterLevel = 	fCurrentServerDescription.fInfo.fMaxCharacterLevel - 1;	
		}
	}
	else if( fValueToChange == 6 )
	{
		if( fCurrentServerDescription.fInfo.fPrivate == false )
		{
			fCurrentServerDescription.fInfo.fPrivate = true;
		}
		else
		{
			fCurrentServerDescription.fInfo.fPrivate = false;	
		}
	}
	else if( fValueToChange == 7 )
	{
		if( fCurrentServerDescription.fInfo.fRanked == false )
		{
			fCurrentServerDescription.fInfo.fRanked = true;
		}
		else
		{
			fCurrentServerDescription.fInfo.fRanked = false;	
		}
	}
		
}

// This is the function that is called when the displayitem is selected only if fbStartByeByeTImerOnClick is true
function ActOnClick(out B9_PDABase PDA,optional class<B9_MenuPDA_Menu> returnMenuClass)
{
log("Inside Act On Click");
	if( fValueToChange == 10 )
	{
		PDA.AddMenu( None );
		
		CreateGame( PDA );	
	}		
	
	return;
}
function CreateGame( B9_PDABase PDA )
{
	local Pawn pawn;
	local Pawn oldPawn;
	local Actor A;
	local vector loc;
	local String URL;


	ForEach PDA.RootController.AllActors(class'Actor', A)
	{
		if ( A.Name == 'LookTarget8' )
		{
			loc = A.location;
			break;
		}
	}

	URL = "MPHQ?Listen" $ "?Class=" $ fCharacterManager.GetSelectedClass();
	URL = URL $ "?NAME=" $ fClient.fClientDescription.fInfo.fName;

	pawn = PDA.RootController.spawn( class<Pawn>(DynamicLoadObject( fCharacterManager.GetSelectedClass(), class'Class' ) ), , , loc );
	if ( pawn != None )
	{
		if ( PDA.RootController.pawn != None )
		{
			oldPawn = PDA.RootController.pawn;
			PDA.RootController.UnPossess();
			oldPawn.Destroy();
		}

		PDA.RootController.Possess(pawn);
	}

	// Load player settings
	fCharacterManager.GetSelectedCharacter( PDA.RootController.Player );
	pawn = PDA.RootController.Player.Actor.Pawn;

	B9_PlayerPawn(pawn).SetMultiplayer();

	Log( "MP: SERVER OPEN [[" $ URL $ "]]" );

	PDA.RootController.ClientTravel( URL, TRAVEL_Absolute, true );
}
defaultproperties
{
	fbStartByeByeTImerOnClick=false
}