class GUIMultiColumnListBox extends GUIListBoxBase
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var Automated GUIMultiColumnListHeader 	Header;

var GUIMultiColumnList	List;
var string				DefaultListClass;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

    if (DefaultListClass!="")
    {
    	List = GUIMultiColumnList(AddComponent(DefaultListClass));
        if (List==None)
        {
        	log("GUIMultiColumnListBox::InitComponent - Could not create default list ["$DefaultListClass$"]");
            return;
        }
    }

	Header.MyList = List;
    InitBaseList(List);
}

defaultproperties
{
	Header=GUIMultiColumnListHeader'GUIMultiColumnListBox.MyHeader'
}