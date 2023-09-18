// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class MyTestPanelB extends GUITabPanel;

var Automated moComboBox ComboTest;
var Automated GUILabel lbListBoxTest;
var Automated GUIListBox ListBoxTest;
var Automated GUILabel lbScrollTextBox;
var Automated GUIScrollTextBox ScrollTextBoxTest;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i,c;
    local string t;

	Super.Initcomponent(MyController, MyOwner);

    c = rand(30)+5;
    for (i=0;i<c;i++)
    	ComboTest.AddItem("Test "$Rand(100));


    c = rand(75)+25;
    for (i=0;i<c;i++)
    	ListBoxTest.List.Add("Testing "$Rand(100));

	ListBoxTest.SetFriendlyLabel(lbListBoxTest);


    c = rand(75)+25;
    for (i=0;i<c;i++)
    {
    	if (t!="")
        	t = T $"|";

    	t = t$"All Work & No Play Makes Me Sad";
    }

    ScrollTextBoxTest.SetContent(t);
	ScrollTextBoxTest.SetFriendlyLabel(lbScrollTextBox);

}
defaultproperties
{
	begin object name=caOne class=moComboBox
	// Object Offset:0x00045FB1
	Caption="moComboBox Test"
	ComponentJustification=0
	Hint="This is a combo box"
	WinTop=0.079339
	WinLeft=0.03125
object end
// Reference: moComboBox'MyTestPanelB.caOne'
ComboTest=caOne
	begin object name=laTwo class=GUILabel
	// Object Offset:0x00045FEE
	Caption="ListBox Test"
	WinTop=0.2
	WinLeft=0.03125
	WinWidth=0.15625
	WinHeight=0.05
object end
// Reference: GUILabel'MyTestPanelB.laTwo'
lbListBoxTest=laTwo
	begin object name=caTwo class=GUIListBox
	// Object Offset:0x00046018
	bVisibleWhenEmpty=true
	WinTop=0.251653
	WinLeft=0.03125
	WinWidth=0.445313
	WinHeight=0.70625
	TabOrder=1
object end
// Reference: GUIListBox'MyTestPanelB.caTwo'
ListBoxTest=caTwo
	begin object name=laThree class=GUILabel
	// Object Offset:0x0004603B
	Caption="Scrolling Text Test"
	WinTop=0.2
	WinLeft=0.515625
	WinWidth=0.257813
	WinHeight=0.05
object end
// Reference: GUILabel'MyTestPanelB.laThree'
lbScrollTextBox=laThree
	begin object name=caThree class=GUIScrollTextBox
	// Object Offset:0x0004606C
	CharDelay=0.05
	bVisibleWhenEmpty=true
	WinTop=0.251653
	WinLeft=0.515625
	WinWidth=0.445313
	WinHeight=0.70625
	TabOrder=2
object end
// Reference: GUIScrollTextBox'MyTestPanelB.caThree'
ScrollTextBoxTest=caThree
	Background=Texture'GUIContent.Menu.EpicLogo'
	WinTop=55.9805
	WinHeight=0.807813
}