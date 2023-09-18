class B9_PDA_JumpToMission08 extends B9_MenuPDA_Menu;

var localized string fJumpToM08A01Label;
var localized string fJumpToM08A02Label;
var localized string fJumpToM08A03Label;

// Event IDs
const kJumpToM08A01	= 0;
const kJumpToM08A02	= 1;
const kJumpToM08A03	= 2;

function Setup( B9_PDABase pdaBase )
{
	local displayItem newItem;

	fReturnMenu = class'B9_PDA_JumpToLevelMenu';

	//Mission 08
	//Jump to 08-1
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM08A01Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM08A01;
	AddDisplayItem( newItem );

	//Jump to 08-2
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM08A02Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM08A02;
	AddDisplayItem( newItem );

	//Jump to 08-3
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM08A03Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM08A03;
	AddDisplayItem( newItem );

}

function ChildEvent( displayItem item, int id )
{
	switch( id )
	{
		//Mission 08
		case kJumpToM08A01:
			On_JumpToLevel( "m08a01" );
		break;

		case kJumpToM08A02:
			On_JumpToLevel( "m08a02" );
		break;

		case kJumpToM08A03:
			On_JumpToLevel( "m08a03" );
		break;
	}
}

function On_JumpToLevel( String level )
{
	fPDABase.AddMenu( None, None );
	fPDABase.RootController.ClientTravel( level, TRAVEL_Absolute, true );
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
	fJumpToM08A01Label="M08A01 : "
	fJumpToM08A02Label="M08A02 : "
	fJumpToM08A03Label="M08A03 : "
}