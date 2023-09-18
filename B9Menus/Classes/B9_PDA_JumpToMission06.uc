class B9_PDA_JumpToMission06 extends B9_MenuPDA_Menu;

var localized string fJumpToM06A01Label;
var localized string fJumpToM06A02Label;
var localized string fJumpToM06A03Label;
var localized string fJumpToM06A08Label;
var localized string fJumpToM06A10Label;
var localized string fJumpToM06A11Label;
var localized string fJumpToM06A13Label;
var localized string fJumpToM06A14Label;

// Event IDs
const kJumpToM06A01	= 0;
const kJumpToM06A02	= 1;
const kJumpToM06A03	= 2;
const kJumpToM06A08	= 3;
const kJumpToM06A10	= 4;
const kJumpToM06A11	= 5;
const kJumpToM06A13	= 6;
const kJumpToM06A14	= 7;


function Setup( B9_PDABase pdaBase )
{
	local displayItem newItem;

	fReturnMenu = class'B9_PDA_JumpToLevelMenu';
	
	//Jump to 6-1
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM06A01Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM06A01;
	AddDisplayItem( newItem );

	//Jump to 6-2
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM06A02Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM06A02;
	AddDisplayItem( newItem );

	//Jump to 6-3
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM06A03Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM06A03;
	AddDisplayItem( newItem );

	//Jump to 6-8
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM06A08Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM06A08;
	AddDisplayItem( newItem );

	//Jump to 6-10
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM06A10Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM06A10;
	AddDisplayItem( newItem );

	//Jump to 6-11
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM06A11Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM06A11;
	AddDisplayItem( newItem );

		//Jump to 6-13
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM06A13Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM06A13;
	AddDisplayItem( newItem );

	//Jump to 6-14
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM06A14Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM06A14;
	AddDisplayItem( newItem );


}

function ChildEvent( displayItem item, int id )
{
	switch( id )
	{
		//Mission 6
		case kJumpToM06A01:
			On_JumpToLevel( "m06a01" );
		break;

		case kJumpToM06A02:
			On_JumpToLevel( "m06a02" );
		break;

		case kJumpToM06A03:
			On_JumpToLevel( "m06a03" );
		break;

		case kJumpToM06A08:
			On_JumpToLevel( "m06a08" );
		break;

		case kJumpToM06A10:
			On_JumpToLevel( "m06a10" );
		break;

		case kJumpToM06A11:
			On_JumpToLevel( "m06a11" );
		break;

		case kJumpToM06A13:
			On_JumpToLevel( "m06a13" );
		break;

		case kJumpToM06A14:
			On_JumpToLevel( "m06a14" );
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
	fJumpToM06A01Label="M06A01 : "
	fJumpToM06A02Label="M06A02 : "
	fJumpToM06A03Label="M06A03 : "
	fJumpToM06A08Label="M06A08 : "
	fJumpToM06A10Label="M06A10 : "
	fJumpToM06A11Label="M06A11 : "
	fJumpToM06A13Label="M06A13 : "
	fJumpToM06A14Label="M06A14 : "
}