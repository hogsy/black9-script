// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class MyTestPage extends GUIPage;

#exec OBJ LOAD FILE=GUIContent.utx

var Automated GUITitleBar TabHeader;
var Automated GUITabControl TabC;
var Automated GUITitleBar TabFooter;
var Automated GUIButton BackButton;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

	Super.Initcomponent(MyController, MyOwner);

	TabHeader.DockedTabs = TabC;
    TabC.AddTab("Component Test","GUI.MyTestPanelA",,"Test of many non-list components");
    TabC.AddTab("List Tests","GUI.MyTestPanelB",,"Test of list components");
    TabC.AddTab("Splitter","GUI.MyTestPanelC",,"Test of the Splitter component");

}

event Closed(GUIComponent Sender, bool bCancelled)
{
	Super.Closed(Sender,bCancelled);
    Controller.MouseEmulation(false);
}

function TabChange(GUIComponent Sender)
{
	if (GUITabButton(Sender)==none)
		return;

	TabHeader.Caption = "Testing : "$GUITabButton(Sender).Caption;
}

event ChangeHint(string NewHint)
{
	TabFooter.Caption = NewHint;
}


function bool ButtonClicked(GUIComponent Sender)
{
	Controller.CloseMenu(true);
	return true;
}

event NotifyLevelChange()
{
	Controller.CloseMenu(true);
}

defaultproperties
{
	begin object name=MyHeader class=GUITitleBar
	// Object Offset:0x00045EA8
	Caption="Settings"
	Effect=Texture'GUIContent.Menu.BorderBoxF'
	StyleName="Header"
	WinTop=0.005414
	WinHeight=36
object end
// Reference: GUITitleBar'MyTestPage.MyHeader'
TabHeader=MyHeader
	begin object name=MyTabs class=GUITabControl
	// Object Offset:0x00045ED2
	bDockPanels=true
	TabHeight=0.04
	bAcceptsInput=true
	WinTop=0.25
	WinHeight=48
	OnChange=TabChange
object end
// Reference: GUITabControl'MyTestPage.MyTabs'
TabC=MyTabs
	begin object name=MyFooter class=GUITitleBar
	// Object Offset:0x00045EF4
	Justification=1
	bUseTextHeight=false
	StyleName="Footer"
	WinTop=0.942397
	WinLeft=0.12
	WinWidth=0.88
	WinHeight=0.055
object end
// Reference: GUITitleBar'MyTestPage.MyFooter'
TabFooter=MyFooter
	begin object name=MyBackButton class=GUIButton
	// Object Offset:0x00045F20
	Caption="BACK"
	StyleName="SquareMenuButton"
	Hint="Return to Previous Menu"
	WinTop=0.942397
	WinWidth=0.12
	WinHeight=0.055
	OnClick=ButtonClicked
object end
// Reference: GUIButton'MyTestPage.MyBackButton'
BackButton=MyBackButton
	Background=Texture'GUIContent.Menu.EpicLogo'
	WinHeight=1
}