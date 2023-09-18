// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class MyTest2Page extends GUIPage;

var Automated moComboBox ComboTest;
var Automated moCheckBox CheckTest;
var Automated moEditBox EditTest;
var Automated moFloatEdit FloatTest;
var Automated moNumericEdit NumEditTest;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
    ComboTest.AddItem("Test1");
    ComboTest.AddItem("Test2");
    ComboTest.AddItem("Test3");
    ComboTest.AddItem("Test4");
    ComboTest.AddItem("Test5");
}

defaultproperties
{
	begin object name=Cone class=moComboBox
	// Object Offset:0x00045969
	Caption="moComboBox Test"
	ComponentJustification=0
	WinTop=0.1
	WinLeft=0.25
	WinHeight=0.05
object end
// Reference: moComboBox'MyTest2Page.Cone'
ComboTest=Cone
	begin object name=cTwo class=moCheckBox
	// Object Offset:0x00045994
	Caption="moCheckBox Test"
	CaptionWidth=0.9
	ComponentJustification=0
	bSquare=true
	WinTop=0.2
	WinLeft=0.25
	WinHeight=0.05
	TabOrder=1
object end
// Reference: moCheckBox'MyTest2Page.cTwo'
CheckTest=cTwo
	begin object name=cThree class=moEditBox
	// Object Offset:0x000459CF
	Caption="moEditBox Test"
	CaptionWidth=0.4
	WinTop=0.3
	WinLeft=0.25
	WinHeight=0.05
	TabOrder=2
object end
// Reference: moEditBox'MyTest2Page.cThree'
EditTest=cThree
	begin object name=cFour class=moFloatEdit
	// Object Offset:0x00045A44
	MaxValue=1
	Step=0.05
	Caption="moFloatEdit Test"
	CaptionWidth=0.725
	ComponentJustification=0
	WinTop=0.4
	WinLeft=0.25
	WinHeight=0.05
	TabOrder=3
object end
// Reference: moFloatEdit'MyTest2Page.cFour'
FloatTest=cFour
	begin object name=cFive class=moNumericEdit
	// Object Offset:0x00045A00
	MinValue=1
	MaxValue=16
	Caption="moNumericEdit Test"
	CaptionWidth=0.6
	WinTop=0.5
	WinLeft=0.25
	WinHeight=0.05
	TabOrder=4
object end
// Reference: moNumericEdit'MyTest2Page.cFive'
NumEditTest=cFive
	Background=Texture'GUIContent.Menu.EpicLogo'
	WinHeight=1
}