class B9_PDA_MissionHistory extends B9_MenuPDA_Menu;

var localized string fMissionLabel;
var localized string fCreditsLabel;
var localized string fMoneyLabel;


function Setup( B9_PDABase pdaBase )
{
	local displayItem newItem;
	
	newItem = new(None)class'displayItem';
	newItem.fLabel = B9_BasicPlayerPawn( fPDABase.RootController.Pawn ).fCharacterConcludedMissionString;
	newItem.fCanAcceptFocus = false;
	newItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newItem );
	
	newItem = new(None)class'displayItem';
	newItem.fLabel = fCreditsLabel;
	newItem.fCanAcceptFocus = false;
	newItem.fDrawNextItemTotheRight = true;
	AddDisplayItem( newItem );
	
	newItem = new(None)class'displayItem';
	newItem.fLabel = String( B9_BasicPlayerPawn( fPDABase.RootController.Pawn ).fAcquiredCash );
	newItem.fCanAcceptFocus = false;
	newItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newItem );
	
	newItem = new(None)class'displayItem';
	newItem.fLabel = fMoneyLabel;
	newItem.fCanAcceptFocus = false;
	newItem.fDrawNextItemTotheRight = true;
	AddDisplayItem( newItem );
	
	newItem = new(None)class'displayItem';
	newItem.fLabel = String( B9_BasicPlayerPawn( fPDABase.RootController.Pawn ).fAcquiredSkillPoints );
	newItem.fCanAcceptFocus = false;
	newItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newItem );
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
	fMissionLabel="Mission Completed: "
	fCreditsLabel="Credits Earned: "
	fMoneyLabel="Money Made: "
}