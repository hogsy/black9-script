class Test_PDA_Menu extends B9_MenuPDA_Menu;

function bool handleKeyEvent(Interactions.EInputKey KeyIn,out Interactions.EInputAction Action, float Delta)
{
	local Interaction.EInputKey Key;
	Key = fPDABase.ConvertJoystick(KeyIn);

	if (fByeByeTicks == 0.0f)
	{
		if ( Key == IK_Joy3 )
		{
			// Must be filled out in the custom menu
		}else if (Key == IK_Joy4 )
		{
			// Must be filled out in the custom menu
		}else
		{
			return Super.handleKeyEvent( KeyIn , Action , Delta );
		}
	}
	return false;

}
function UpdateMenu( float Delta )
{
	Super.UpdateMenu( Delta );
	// Add or Maniuplate Dynanic Items
}
function Initialize()
{
	local displayitem_GenericMenuItem Item;
	// No default behavior
	Item = displayitem_GenericMenuItem( AddGenericMenu("Test 1"));
	Item.fDrawNextItemTotheRight = true;
	Item.fMenuClass = class'Test_PDA_Menu2';
	AddGenericMenu("Test 2");
	AddGenericMenu("Test 3");
	AddGenericMenu("Test 4");
	AddGenericMenu("Test 5");
	AddGenericMenu("Test 6");
	AddSimpleDisplayItem("Title");
}

