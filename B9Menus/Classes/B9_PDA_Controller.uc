class B9_PDA_Controller extends B9_MenuPDA_Menu;

var localized string fJumpToLevelLabel;
var localized string fRestartLevelLabel;
var localized string fCheatsLabel;
var localized string fControllerLabel;
var localized string fGraphicsLabel;
var localized string fQuitLabel;

// Event IDs
const kEvent_RestartLevel	= 0;
const kEvent_Quit			= 1;


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

function Setup( B9_PDABase pdaBase )
{
	local displayItem newItem;
	log("DO we have a RootController?"$fPDABase.RootController);
	
	//Jump to level
	newItem = new(None)class'displayitem_GenericMenuItem';
	newItem.fLabel = fJumpToLevelLabel;
	AddDisplayItem( newItem );
	
	//Restart
	newItem = new(None)class'displayItem';
	newItem.fLabel = fRestartLevelLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_RestartLevel;
	AddDisplayItem( newItem );
	
	//Cheats
	newItem = new(None)class'displayitem_GenericMenuItem';
	newItem.fLabel = fCheatsLabel;
	AddDisplayItem( newItem );
	
	//Controller
	newItem = new(None)class'displayitem_GenericMenuItem';
	newItem.fLabel = fControllerLabel;
	AddDisplayItem( newItem );
	
	//Grpahics
	newItem = new(None)class'displayitem_GenericMenuItem';
	newItem.fLabel = fGraphicsLabel;
	AddDisplayItem( newItem );
	
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
	Log( "Restart Level TODO" );
}

function On_Quit()
{
	Log( "Quit TODO" );
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