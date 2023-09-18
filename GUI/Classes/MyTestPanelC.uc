// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class MyTestPanelC extends GUITabPanel;

var Automated GUISplitter MainSplitter;

function ShowPanel(bool bShow)	// Show Panel should be subclassed if any special processing is needed
{
	Super.ShowPanel(bShow);
   	Controller.MouseEmulation(bShow);
}

defaultproperties
{
	begin object name=Cone class=GUISplitter
	// Object Offset:0x00045928
	DefaultPanels[0]="GUI.MySubTestPanelA"
	DefaultPanels[1]="GUI.MySubTestPanelB"
	MaxPercentage=0.8
	WinHeight=1
object end
// Reference: GUISplitter'MyTestPanelC.Cone'
MainSplitter=Cone
	Background=Texture'GUIContent.Menu.EpicLogo'
	WinTop=55.9805
	WinHeight=0.807813
}