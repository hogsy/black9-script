// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class MySubTestPanelB extends GUITabPanel;

var Automated GUIListBox ListBoxTest;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i,c;

	Super.Initcomponent(MyController, MyOwner);

    c = rand(75)+25;
    for (i=0;i<c;i++)
    	ListBoxTest.List.Add("All Work & No Play Makes Me Sad");

}
defaultproperties
{
	begin object name=Cone class=GUIListBox
	// Object Offset:0x00045FA6
	bVisibleWhenEmpty=true
	WinHeight=1
object end
// Reference: GUIListBox'MySubTestPanelB.Cone'
ListBoxTest=Cone
	Background=Texture'GUIContent.Menu.EpicLogo'
	WinTop=55.9805
	WinHeight=0.807813
}