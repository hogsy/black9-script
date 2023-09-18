class B9_PDA_HostSkirmishOptionsMenu extends B9_MenuPDA_Menu;

var B9MP_ServerBrowser fServerBrowser;
var localized string fMinNumberOfPlayersLabel;
var localized string fMaxNumberOfPlayersLabel;
var localized string fMinCharacterLevelLabel;
var localized string fMaxCharacterLevelLabel;
var localized string fPrivateGameLabel;
var localized string fRankedGameLabel;
var localized string fLessLabel;
var localized string fMoreLabel;
var localized string fCreateGameLabel;
var bool fRanOnce;
var B9MP_ServerDescription		fMyServerDescription;

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
function UpdateMenu( float Delta )
{
	local int indexpoint;
	
	Super.UpdateMenu( Delta );
		
	if( fRanOnce == false )
	{
		fRanOnce = true;

		//Initialize server settings.
		fMyServerDescription = fPDABase.RootController.Spawn( class 'B9MP_ServerDescription' );
		fMyServerDescription.fInfo.fMinPlayers = 1;
		fMyServerDescription.fInfo.fMaxPlayers	= 16;
		fMyServerDescription.fInfo.fMinCharacterLevel = 1;
		fMyServerDescription.fInfo.fMaxCharacterLevel = fMyServerDescription.kMaxCharacterLevel;
		fMyServerDescription.fInfo.fPrivate = false;
		fMyServerDescription.fInfo.fRanked = false;
		fMyServerDescription.fInfo.fName = "E3 B9 Server";

//	dferrelNF
		//Min Number of Players label
		indexpoint = 0;
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_GenericMenuItem';
		fDisplayItems[indexpoint].fLabel		= fMinNumberOfPlayersLabel;	
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fCanAcceptFocus = false;		
		indexpoint = fDisplayItems.length;
		//Less Min Players
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_HostSkirmish';
		fDisplayItems[indexpoint].fLabel		= fLessLabel;	
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fValueToChange = 0;
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fIncrementValue = false;					
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;			
		indexpoint = fDisplayItems.length;
		//Current Min Number of Players
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_DisplayHostSkirmishOptions';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		displayitem_DisplayHostSkirmishOptions(fDisplayItems[indexpoint]).fValueToDisplay = 0;		
		displayitem_DisplayHostSkirmishOptions(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;			
		fDisplayItems[indexpoint].fCanAcceptFocus = false;				
		indexpoint = fDisplayItems.length;
		//More Min Players
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_HostSkirmish';
		fDisplayItems[indexpoint].fLabel		= fMoreLabel;
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fValueToChange = 0;		
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fIncrementValue = true;					
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;			
		indexpoint = fDisplayItems.length;		
		
		//Max Number of Players label
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_GenericMenuItem';
		fDisplayItems[indexpoint].fLabel		= fMaxNumberOfPlayersLabel;	
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fCanAcceptFocus = false;		
		indexpoint = fDisplayItems.length;
		//Less Max Players
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_HostSkirmish';
		fDisplayItems[indexpoint].fLabel		= fLessLabel;	
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fValueToChange = 1;		
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fIncrementValue = false;					
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;			
		indexpoint = fDisplayItems.length;
		//Current Max Number of Players
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_DisplayHostSkirmishOptions';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		displayitem_DisplayHostSkirmishOptions(fDisplayItems[indexpoint]).fValueToDisplay = 1;				
		displayitem_DisplayHostSkirmishOptions(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;			
		fDisplayItems[indexpoint].fCanAcceptFocus = false;						
		indexpoint = fDisplayItems.length;
		//More Max Players
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_HostSkirmish';
		fDisplayItems[indexpoint].fLabel		= fMoreLabel;
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fValueToChange = 1;		
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fIncrementValue = true;					
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;
		indexpoint = fDisplayItems.length;
		
		//Min Character Level label
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_GenericMenuItem';
		fDisplayItems[indexpoint].fLabel		= fMinCharacterLevelLabel;	
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fCanAcceptFocus = false;		
		indexpoint = fDisplayItems.length;
		//Less Min Character Level
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_HostSkirmish';
		fDisplayItems[indexpoint].fLabel		= fLessLabel;	
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fValueToChange = 2;		
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fIncrementValue = false;					
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;			
		indexpoint = fDisplayItems.length;
		//Current Min Character Level
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_DisplayHostSkirmishOptions';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		displayitem_DisplayHostSkirmishOptions(fDisplayItems[indexpoint]).fValueToDisplay = 2;				
		displayitem_DisplayHostSkirmishOptions(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;			
		fDisplayItems[indexpoint].fCanAcceptFocus = false;						
		indexpoint = fDisplayItems.length;
		//More Min Character Level
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_HostSkirmish';
		fDisplayItems[indexpoint].fLabel		= fMoreLabel;
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fValueToChange = 2;		
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fIncrementValue = true;					
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;
		indexpoint = fDisplayItems.length;		
		
		//Max Character Level label
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_GenericMenuItem';
		fDisplayItems[indexpoint].fLabel		= fMaxCharacterLevelLabel;	
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fCanAcceptFocus = false;		
		indexpoint = fDisplayItems.length;
		//Less Max Character Level
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_HostSkirmish';
		fDisplayItems[indexpoint].fLabel		= fLessLabel;	
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fValueToChange = 3;		
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fIncrementValue = false;					
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;			
		indexpoint = fDisplayItems.length;
		//Current Max Character Level
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_DisplayHostSkirmishOptions';
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		displayitem_DisplayHostSkirmishOptions(fDisplayItems[indexpoint]).fValueToDisplay = 3;				
		displayitem_DisplayHostSkirmishOptions(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;			
		fDisplayItems[indexpoint].fCanAcceptFocus = false;						
		indexpoint = fDisplayItems.length;
		//More Max Character Level
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_HostSkirmish';
		fDisplayItems[indexpoint].fLabel		= fMoreLabel;
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fValueToChange = 3;		
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fIncrementValue = true;					
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;
		indexpoint = fDisplayItems.length;	
		
		//Private Game label
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_HostSkirmish';
		fDisplayItems[indexpoint].fLabel		= fPrivateGameLabel;	
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fCanAcceptFocus = false;
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fValueToChange = 6;				
		indexpoint = fDisplayItems.length;
		//Change Private Game Status
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_DisplayHostSkirmishOptions';
		fDisplayItems[indexpoint].fLabel		= fLessLabel;	
		displayitem_DisplayHostSkirmishOptions(fDisplayItems[indexpoint]).fValueToDisplay = 6;	
		displayitem_DisplayHostSkirmishOptions(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;			
		indexpoint = fDisplayItems.length;
		
		//Ranked Game label
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_HostSkirmish';
		fDisplayItems[indexpoint].fLabel		= fRankedGameLabel;	
		fDisplayItems[indexpoint].fDrawNextItemTotheRight = true;
		fDisplayItems[indexpoint].fCanAcceptFocus = false;
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_HostSkirmish(fDisplayItems[indexpoint]).fValueToChange = 7;
		indexpoint = fDisplayItems.length;
		//Changed Ranked Game Status
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_DisplayHostSkirmishOptions';
		fDisplayItems[indexpoint].fLabel		= fLessLabel;	
		displayitem_DisplayHostSkirmishOptions(fDisplayItems[indexpoint]).fValueToDisplay = 7;	
		displayitem_DisplayHostSkirmishOptions(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;
		indexpoint = fDisplayItems.length;	

		
		//Create Game (start server)
		fDisplayItems.Insert(indexpoint,1);
		fDisplayItems[indexpoint]				= new(None)class'displayitem_DisplayHostSkirmishOptions';
		fDisplayItems[indexpoint].fLabel		= fCreateGameLabel;	
		fDisplayItems[indexpoint].fCanAcceptFocus = true;
		fDisplayItems[indexpoint].fbStartByeByeTImerOnClick = true;
		displayitem_DisplayHostSkirmishOptions(fDisplayItems[indexpoint]).fCurrentServerDescription = fMyServerDescription;				
		displayitem_DisplayHostSkirmishOptions(fDisplayItems[indexpoint]).fValueToDisplay = 10;										
	}
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
	fMinNumberOfPlayersLabel="Min Number of Players: "
	fMaxNumberOfPlayersLabel="Max Number of Players: "
	fMinCharacterLevelLabel="Min Character Level:   "
	fMaxCharacterLevelLabel="Max Character Level:   "
	fPrivateGameLabel="Ranked Game            "
	fRankedGameLabel="Ranked Game            "
	fLessLabel=" Less "
	fMoreLabel=" More "
	fCreateGameLabel="           Create Game            "
}