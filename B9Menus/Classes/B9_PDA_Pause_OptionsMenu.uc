class B9_PDA_Pause_OptionsMenu extends B9_MenuPDA_Menu;

var localized string fJumpToLevelLabel;
var localized string fRestartLevelLabel;
var localized string fCheatsLabel;
var localized string fControllerLabel;
var localized string fGraphicsLabel;
var localized string fQuitLabel;

// Event IDs
const kEvent_RestartLevel	= 0;
const kEvent_Quit			= 1;


function Setup( B9_PDABase pdaBase )
{
	local displayItem newItem;
	local displayitem_GenericMenuItem newMenuItem;
	local bool IsNetClient;
	local B9MP_Server TheServer;
	local B9_PlayerController ThePlayerController;

	fReturnMenu = class'B9_PDA_Pause_InitialMenu';

	// Determine if we are a network client
	IsNetClient = false;

	ThePlayerController = B9_PlayerController( fPDABase.RootController );

	// Check if we are networked
	if(ThePlayerController != None && ThePlayerController.fClient !=  None)
	{
		IsNetClient = true;
		// If we are not hosting, we are really a client
		foreach ThePlayerController.AllActors( class 'B9MP_Server', TheServer )
		{
			IsNetClient = false;
			break;
		}
	}

	if(!IsNetClient)
	{
		Log("XT: Use client menu ");

		//if( TheServer != None)
		//{
			//Cheats
			newMenuItem = new(None)class'displayitem_GenericMenuItem';
			newMenuItem.fLabel = fCheatsLabel;
			newMenuItem.fMenuClass = class'B9_PDA_Cheats';
			AddDisplayItem( newMenuItem );
			
			//Jump to level
			newMenuItem = new(None)class'displayitem_GenericMenuItem';
			newMenuItem.fLabel = fJumpToLevelLabel;
			newMenuItem.fMenuClass = class'B9_PDA_JumpToLevelMenu';
			AddDisplayItem( newMenuItem );
		//}

		//Restart
		newItem = new(None)class'displayItem';
		newItem.fLabel = fRestartLevelLabel;
		newItem.fEventParent = self;
		newItem.fEventID = kEvent_RestartLevel;
		AddDisplayItem( newItem );

		//Controller
		/*newItem = new(None)class'displayitem_GenericMenuItem';
		newItem.fLabel = fControllerLabel;
		AddDisplayItem( newItem );
		*/
		
		//Grpahics
		newMenuItem = new(None)class'displayitem_GenericMenuItem';
		newMenuItem.fLabel = fGraphicsLabel;
		newMenuItem.fMenuClass = class'B9_PDA_Graphics';
		AddDisplayItem( newMenuItem );
	}
		
	//Quit
	newItem = new(None)class'displayItem';
	newItem.fLabel = fQuitLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_Quit;
	AddDisplayItem( newItem );
}

function ChildEvent( displayItem item, int id )
{
	switch( id )
	{
		case kEvent_RestartLevel:
			On_RestartLevel();
		break;
		
		case kEvent_Quit:
			On_Quit();
		break;
	}
}

function On_RestartLevel()
{
	fPDABase.AddMenu( None, None );
	fPDABase.RootController.RestartLevel();
}

function On_Quit()
{
	fPDABase.AddMenu( None, None );
	fPDABase.RootController.ClientTravel( "b9menu_main", TRAVEL_Absolute, true );
}

function UpdateMenu( float Delta )
{
	Super.UpdateMenu( Delta );
}

function Initialize()
{
	//Don't do anything requiring controllers here!
}

defaultproperties
{
	fJumpToLevelLabel="Jump to Level"
	fRestartLevelLabel="Restart Level"
	fCheatsLabel="Cheats"
	fControllerLabel="Controller"
	fGraphicsLabel="Graphics"
	fQuitLabel="Quit"
}