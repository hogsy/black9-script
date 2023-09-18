class B9_PDA_Loading extends B9_MenuPDA_Menu;

var localized string fLoadingLabel;

function Setup( B9_PDABase pdaBase )
{
	local displayItem newItem;
	
	//Restart
	newItem = new(None)class'displayItem';
	newItem.fLabel = fLoadingLabel;
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
	fLoadingLabel="Loading..."
}