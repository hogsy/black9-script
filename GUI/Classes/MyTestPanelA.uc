// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class MyTestPanelA extends GUITabPanel;

var Automated moCheckBox CheckTest;
var Automated moEditBox EditTest;
var Automated moFloatEdit FloatTest;
var Automated moNumericEdit NumEditTest;
var Automated GUILabel lbSliderTest;
var Automated GUISlider SliderTest;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

	CheckTest.SetLinkOverrides(CheckTest,EditTest,CheckTest,CheckTest);
    EditTest.SetLinkOverrides( CheckTest,FloatTest,EditTest,EditTest);
    FloatTest.SetLinkOverrides(EditTest,NumEditTest,FloatTest,FloatTest);
    NumEditTest.SetLinkOverrides(FloatTest,SliderTest,NumEditTest,NumEditTest);
    SliderTest.SetLinkOverrides(NumEditTest,SliderTest,SliderTest,SliderTest);

	Super.InitComponent(MyController,MyOwner);
    SliderTest.SetFriendlyLabel(lbSliderTest);
}

defaultproperties
{
	begin object name=cTwo class=moCheckBox
	// Object Offset:0x00045A90
	Caption="moCheckBox Test"
	CaptionWidth=0.9
	ComponentJustification=0
	bSquare=true
	Hint="This is a check Box"
	WinTop=0.2
	WinLeft=0.25
	WinHeight=0.05
	TabOrder=1
object end
// Reference: moCheckBox'MyTestPanelA.cTwo'
CheckTest=cTwo
	begin object name=cThree class=moEditBox
	// Object Offset:0x00045AE3
	Caption="moEditBox Test"
	CaptionWidth=0.4
	Hint="This is an Edit Box"
	WinTop=0.3
	WinLeft=0.25
	WinHeight=0.05
	TabOrder=2
object end
// Reference: moEditBox'MyTestPanelA.cThree'
EditTest=cThree
	begin object name=cFour class=moFloatEdit
	// Object Offset:0x00045B94
	MaxValue=1
	Step=0.05
	Caption="moFloatEdit Test"
	CaptionWidth=0.725
	ComponentJustification=0
	Hint="This is a FLOAT numeric Edit Box"
	WinTop=0.5
	WinLeft=0.25
	WinHeight=0.05
	TabOrder=3
object end
// Reference: moFloatEdit'MyTestPanelA.cFour'
FloatTest=cFour
	begin object name=cFive class=moNumericEdit
	// Object Offset:0x00045B2C
	MinValue=1
	MaxValue=16
	Caption="moNumericEdit Test"
	CaptionWidth=0.6
	Hint="This is an INT numeric Edit box"
	WinTop=0.4
	WinLeft=0.25
	WinHeight=0.05
	TabOrder=4
object end
// Reference: moNumericEdit'MyTestPanelA.cFive'
NumEditTest=cFive
	begin object name=laSix class=GUILabel
	// Object Offset:0x00045BFF
	Caption="Slider Test"
	TextAlign=1
	WinTop=0.654545
	WinLeft=0.375
	WinWidth=0.226563
	WinHeight=0.05
object end
// Reference: GUILabel'MyTestPanelA.laSix'
lbSliderTest=laSix
	begin object name=cSix class=GUISlider
	// Object Offset:0x00045C2C
	MaxValue=1
	Hint="This is a Slider Test."
	WinTop=0.713997
	WinLeft=0.367188
	WinWidth=0.25
	TabOrder=5
object end
// Reference: GUISlider'MyTestPanelA.cSix'
SliderTest=cSix
	Background=Texture'GUIContent.Menu.EpicLogo'
	WinTop=55.9805
	WinHeight=0.807813
}