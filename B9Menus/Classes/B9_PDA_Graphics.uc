class B9_PDA_Graphics extends B9_MenuPDA_Menu;

var localized string fTurnOffShadowsLabel;

// Event IDs
const kEvent_TurnOffShadows	= 0;


function Setup( B9_PDABase pdaBase )
{
	local displayItem newItem;
	
	fReturnMenu = class'B9_PDA_Pause_OptionsMenu';

	//Turn Shadows Off
	newItem = new(None)class'displayItem';
	newItem.fLabel = fTurnOffShadowsLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kEvent_TurnOffShadows;
	AddDisplayItem( newItem );
}

function ChildEvent( displayItem item, int id )
{
	switch( id )
	{
		case kEvent_TurnOffShadows:
			On_TurnOffShadows();
		break;
	}
}

function On_TurnOffShadows()
{
	fPDABase.AddMenu( None, None );
	fPDABase.RootController.ConsoleCommand( "killshadows" );
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
	fTurnOffShadowsLabel="Turn Off Shadows"
}