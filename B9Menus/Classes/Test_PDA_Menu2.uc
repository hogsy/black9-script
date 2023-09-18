class Test_PDA_Menu2 extends B9_MenuPDA_Menu;

function Initialize()
{
	local displayItem Item;
	// No default behavior
	Item = AddGenericMenu("XXX 1");
	Item.fDrawNextItemTotheRight = true;

	AddGenericMenu("XXX 2");
	AddGenericMenu("XX 3");
	Item = AddGenericMenu("X 4");
	Item.fDrawNextItemTotheRight = true;
	AddGenericMenu("X 5");
	AddGenericMenu("X 6");
}

