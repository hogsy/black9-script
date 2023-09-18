class B9_PDA_JumpToMission13 extends B9_MenuPDA_Menu;

var localized string fJumpToM13A01Label;
var localized string fJumpToM13A02Label;
var localized string fJumpToM13A03Label;

// Event IDs
const kJumpToM13A01	= 0;
const kJumpToM13A02	= 1;
const kJumpToM13A03	= 2;

function Setup( B9_PDABase pdaBase )
{
	local displayItem newItem;

	fReturnMenu = class'B9_PDA_JumpToLevelMenu';

	//Mission 13
	//Jump to 13-1
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM13A01Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM13A01;
	AddDisplayItem( newItem );

	//Jump to 13-2
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM13A02Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM13A02;
	AddDisplayItem( newItem );

	//Jump to 13-3
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM13A03Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM13A03;
	AddDisplayItem( newItem );

}

function ChildEvent( displayItem item, int id )
{
	switch( id )
	{
		//Mission 13
		case kJumpToM13A01:
			On_JumpToLevel( "m13a01" );
		break;

		case kJumpToM13A02:
			On_JumpToLevel( "m13a02" );
		break;

		case kJumpToM13A03:
			On_JumpToLevel( "m13a03" );
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
	fJumpToM13A01Label="M13A01 : "
	fJumpToM13A02Label="M13A02 : "
	fJumpToM13A03Label="M13A03 : "
}