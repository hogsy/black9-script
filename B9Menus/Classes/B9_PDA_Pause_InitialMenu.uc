class B9_PDA_Pause_InitialMenu extends B9_MenuPDA_Menu;

var localized string fObjectiveLabel;
var localized string fOptionsLabel;
var localized string fInfoStiksLabel;
var localized string fMissionHistoryLabel;
var bool bUnPauseOnce;

function Setup( B9_PDABase pdaBase )
{
	local displayitem_GenericMenuItem newMenuItem;
	
	//Options
	newMenuItem 			= new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel		= fOptionsLabel;				
	newMenuItem.fMenuClass	= class'B9_PDA_Pause_OptionsMenu';
	AddDisplayItem( newMenuItem );

	// Objectives
	newMenuItem				= new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel		= fObjectiveLabel;
	newMenuItem.fMenuClass	= class'B9_PDA_MissionObjectives';
	AddDisplayItem( newMenuItem );

	//   Info Sticks
	if (fPDABase.RootController.Pawn.FindInventoryType(class'InfoStik') != None)
	{
		newMenuItem					= new(None)class'displayitem_GenericMenuItem';
		newMenuItem.fLabel			= fInfoStiksLabel;
		newMenuItem.fMenuClass = class'B9_PDA_InfoStiks';
		AddDisplayItem( newMenuItem );
	}
	
	// How do I check if we are in HQ
	newMenuItem					= new(None)class'displayitem_GenericMenuItem';
	newMenuItem.fLabel			= fMissionHistoryLabel;
	newMenuItem.fMenuClass = class'B9_PDA_MissionHistory';
	AddDisplayItem( newMenuItem );
	
	fReturnMenu = None;
}

function UpdateMenu( float Delta )
{
	
	if( fByeByeTicks > 0.0f && (fByeByeTicks - Delta) <= 0.0 && bUnPauseOnce == false)
	{
		log("Calling UnPause");
		bUnPauseOnce = true;
		//fPDABase.RootController.Pause();
	}

	Super.UpdateMenu( Delta );
}

function Initialize()
{
	//Don't do anything requiring controllers here!

}

defaultproperties
{
	fObjectiveLabel="Mission Objectives"
	fOptionsLabel="Options"
	fInfoStiksLabel="Info Stiks"
	fMissionHistoryLabel="Mission History"
}