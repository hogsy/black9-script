class  displayitem_RefreshServerListItem extends displayItem;

var class<B9_MenuPDA_Menu> fNextMenuName;
var B9MP_Client	fClient;

function bool handleKeyEvent( Interactions.EInputKey KeyIn, out Interactions.EInputAction Action, float Delta)
{
// Default handler handles nothing overload this to add functionality
	return false;
}

function ClickItem(optional B9_MenuPDA_Menu menu)
{
	Super.ClickItem( menu );
}

// This is the function that is called when the displayitem is selected
function ActOnClick(out B9_PDABase PDA,optional class<B9_MenuPDA_Menu> returnMenuClass)
{
	PDA.AddMenu( class'B9_PDA_MultiplayerCreateBrowseList', returnMenuClass );
	return;
}
