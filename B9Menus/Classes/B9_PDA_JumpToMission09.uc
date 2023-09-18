class B9_PDA_JumpToMission09 extends B9_MenuPDA_Menu;

var localized string fJumpToM09A01Label;
var localized string fJumpToM09A02Label;
var localized string fJumpToM09A03Label;
var localized string fJumpToM09A04Label;
var localized string fJumpToM09A05Label;

// Event IDs
const kJumpToM09A01	= 0;
const kJumpToM09A02	= 1;
const kJumpToM09A03	= 2;
const kJumpToM09A04	= 3;
const kJumpToM09A05	= 4;


function Setup( B9_PDABase pdaBase )
{
	local displayItem newItem;

	fReturnMenu = class'B9_PDA_JumpToLevelMenu';
			
	//Jump to 9-1
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM09A01Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM09A01;
	AddDisplayItem( newItem );
	
	//Jump to 9-2
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM09A02Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM09A02;
	AddDisplayItem( newItem );
	
	//Jump to 9-3
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM09A03Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM09A03;
	AddDisplayItem( newItem );
	
	//Jump to 9-4
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM09A04Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM09A04;
	AddDisplayItem( newItem );
	
	//Jump to 9-5
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToM09A05Label;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToM09A05;
	AddDisplayItem( newItem );

}

function ChildEvent( displayItem item, int id )
{
	switch( id )
	{
		// Mission 9
		case kJumpToM09A01:
			On_JumpToLevel( "m09a01" );
		break;
		
		case kJumpToM09A02:
			On_JumpToLevel( "m09a02" );
		break;
		
		case kJumpToM09A03:
			On_JumpToLevel( "m09a03" );
		break;
		
		case kJumpToM09A04:
			On_JumpToLevel( "m09a04" );
		break;
		
		case kJumpToM09A05:
			On_JumpToLevel( "m09a05" );
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
	fJumpToM09A01Label="M09A01 : Moon Base"
	fJumpToM09A02Label="M09A02 : Auxiliary Hangar"
	fJumpToM09A03Label="M09A03 : Breeding Grounds"
	fJumpToM09A04Label="M09A04 : Luna Park"
	fJumpToM09A05Label="M09A05 : "
}