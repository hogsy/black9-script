// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class MySubTestPanelA extends GUITabPanel;

var Automated GUIMultiColumnListBox MultiColumnListBoxTest;

defaultproperties
{
	begin object name=Cone class=GUIMultiColumnListBox
	// Object Offset:0x00045F7C
	DefaultListClass="GUI.MyTestMultiColumnList"
	bVisibleWhenEmpty=true
	WinHeight=1
object end
// Reference: GUIMultiColumnListBox'MySubTestPanelA.Cone'
MultiColumnListBoxTest=Cone
	Background=Texture'GUIContent.Menu.EpicLogo'
	WinTop=55.9805
	WinHeight=0.807813
}