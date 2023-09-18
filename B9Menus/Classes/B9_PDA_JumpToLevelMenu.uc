class B9_PDA_JumpToLevelMenu extends B9_MenuPDA_Menu;

var localized string fMission01Label;
var localized string fMission02Label;
var localized string fMission03Label;
var localized string fMission04Label;
var localized string fMission05Label;
var localized string fMission06Label;
var localized string fMission07Label;
var localized string fMission08Label;
var localized string fMission09Label;
var localized string fMission10Label;
var localized string fMission11Label;
var localized string fMission12Label;
var localized string fMission13Label;
var localized string fMission14Label;
var localized string fMission15Label;

var localized string fJumpToHQLabel;

// Event IDs
const kJumpToHQ		= 0;


function Setup( B9_PDABase pdaBase )
{

	//log("DO we have a RootController?"$fPDABase.RootController);
	
	local displayitem_GenericMenuItem newMenuItem;
	local displayItem newItem;

	fReturnMenu = class'B9_PDA_Pause_OptionsMenu';
	
	//Mission 01
	newMenuItem 						= new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel	    			= fMission01Label;				
	newMenuItem.fMenuClass				= class'B9_PDA_JumpToMission06';
	newMenuItem.fCanAcceptFocus			= false;
	newMenuItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newMenuItem );

	//Mission 02
	newMenuItem 						= new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel					= fMission02Label;				
	newMenuItem.fMenuClass				= class'B9_PDA_JumpToMission06';
	newMenuItem.fCanAcceptFocus			= false;
	newMenuItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newMenuItem );

	//Mission 03
	newMenuItem 						= new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel					= fMission03Label;				
	newMenuItem.fMenuClass				= class'B9_PDA_JumpToMission06';
	newMenuItem.fCanAcceptFocus			= false;
	newMenuItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newMenuItem );

	//Mission 04
	newMenuItem 						= new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel					= fMission04Label;				
	newMenuItem.fMenuClass				= class'B9_PDA_JumpToMission06';
	newMenuItem.fCanAcceptFocus			= false;
	newMenuItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newMenuItem );

	//Mission 05
	newMenuItem 						= new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel					= fMission05Label;				
	newMenuItem.fMenuClass				= class'B9_PDA_JumpToMission06';
	newMenuItem.fCanAcceptFocus			= false;
	newMenuItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newMenuItem );

	//Mission 06
	newMenuItem 						= new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel					= fMission06Label;				
	newMenuItem.fMenuClass				= class'B9_PDA_JumpToMission06';
	newMenuItem.fCanAcceptFocus			= true;
	newMenuItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newMenuItem );

	//Mission 07
	newMenuItem 						= new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel					= fMission07Label;				
	newMenuItem.fMenuClass				= class'B9_PDA_JumpToMission06';
	newMenuItem.fCanAcceptFocus			= false;
	newMenuItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newMenuItem );

	//Mission 08
	newMenuItem 						= new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel					= fMission08Label;				
	newMenuItem.fMenuClass				= class'B9_PDA_JumpToMission08';
	newMenuItem.fCanAcceptFocus			= true;
	newMenuItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newMenuItem );

	//Mission 09
	newMenuItem 						= new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel					= fMission09Label;				
	newMenuItem.fMenuClass				= class'B9_PDA_JumpToMission09';
	newMenuItem.fCanAcceptFocus			= true;
	newMenuItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newMenuItem );

	//Mission 10
	newMenuItem 						= new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel					= fMission10Label;				
	newMenuItem.fMenuClass				= class'B9_PDA_JumpToMission06';
	newMenuItem.fCanAcceptFocus			= false;
	newMenuItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newMenuItem );

	//Mission 11
	newMenuItem 						= new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel					= fMission11Label;				
	newMenuItem.fMenuClass				= class'B9_PDA_JumpToMission06';
	newMenuItem.fCanAcceptFocus			= false;
	newMenuItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newMenuItem );

	//Mission 12
	newMenuItem 						= new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel					= fMission12Label;				
	newMenuItem.fMenuClass				= class'B9_PDA_JumpToMission06';
	newMenuItem.fCanAcceptFocus			= false;
	newMenuItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newMenuItem );

	//Mission 13
	newMenuItem 						= new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel					= fMission13Label;				
	newMenuItem.fMenuClass				= class'B9_PDA_JumpToMission13';
	newMenuItem.fCanAcceptFocus			= true;
	newMenuItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newMenuItem );

	//Mission 14
	newMenuItem 						= new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel					= fMission14Label;				
	newMenuItem.fMenuClass				= class'B9_PDA_JumpToMission06';
	newMenuItem.fCanAcceptFocus			= false;
	newMenuItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newMenuItem );

	//Mission 15
	newMenuItem 						= new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel					= fMission15Label;				
	newMenuItem.fMenuClass				= class'B9_PDA_JumpToMission06';
	newMenuItem.fCanAcceptFocus			= false;
	newMenuItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newMenuItem );
	
	//Jump to HQ
	newItem = new(None)class'displayItem';
	newItem.fLabel = fJumpToHQLabel;
	newItem.fEventParent = self;
	newItem.fEventID = kJumpToHQ;
	AddDisplayItem( newItem );
}

function ChildEvent( displayItem item, int id )
{
	switch( id )
	{
		//HQ
		case kJumpToHQ:
			On_JumpToLevel( "e1hq" );
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
	fMission01Label="Mission 1"
	fMission02Label="Mission 2"
	fMission03Label="Mission 3"
	fMission04Label="Mission 4"
	fMission05Label="Mission 5"
	fMission06Label="Mission 6"
	fMission07Label="Mission 7"
	fMission08Label="Mission 8"
	fMission09Label="Mission 9"
	fMission10Label="Mission 10"
	fMission11Label="Mission 11"
	fMission12Label="Mission 12"
	fMission13Label="Mission 13"
	fMission14Label="Mission 14"
	fMission15Label="Mission 15"
	fJumpToHQLabel="E1HQ   : Head Quarters"
}