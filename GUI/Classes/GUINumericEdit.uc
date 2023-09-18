// ====================================================================
//	Class: GUI. UT2NumericEdit
//
//  A Combination of an EditBox and 2 spinners
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUINumericEdit extends GUIMultiComponent
	Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var Automated GUIEditBox MyEditBox;
var Automated GUISpinnerButton MyPlus;
var Automated GUISpinnerButton MyMinus;

var(Menu)	string				Value;
var(Menu)	bool				bLeftJustified;
var(Menu)	int					MinValue;
var(Menu)	int					MaxValue;
var(Menu)	int					Step;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

	Super.Initcomponent(MyController, MyOwner);

	MyEditBox.OnChange = EditOnChange;
	MyEditBox.SetText(Value);
	MyEditBox.OnKeyEvent = EditKeyEvent;

	CalcMaxLen();

	MyPlus.OnClick = SpinnerPlusClick;
	MyPlus.FocusInstead = MyEditBox;
	MyMinus.OnClick = SpinnerMinusClick;
	MyMinus.FocusInstead = MyEditBox;

    SetHint(Hint);

}

function CalcMaxLen()
{
	local int digitcount,x;

	digitcount=1;
	x=10;
	while (x<MaxValue)
	{
		digitcount++;
		x*=10;
	}

	MyEditBox.MaxWidth = DigitCount;
}
function SetValue(int V)
{
	if (v<MinValue)
		v=MinValue;

	if (v>MaxValue)
		v=MaxValue;

	MyEditBox.SetText(""$v);
}

function bool SpinnerPlusClick(GUIComponent Sender)
{
	local int v;

	v = int(Value) + Step;
	if (v>MaxValue)
	  v = MaxValue;

	MyEditBox.SetText(""$v);
	return true;
}

function bool SpinnerMinusClick(GUIComponent Sender)
{
	local int v;

	v = int(Value) - Step;
	if (v<MinValue)
		v=MinValue;

	MyEditBox.SetText(""$v);
	return true;
}

function bool EditKeyEvent(out byte Key, out byte State, float delta)
{
	if ( (key==0xEC) && (State==3) )
	{
		SpinnerPlusClick(none);
		return true;
	}

	if ( (key==0xED) && (State==3) )
	{
		SpinnerMinusClick(none);
		return true;
	}

	return MyEditBox.InternalOnKeyEvent(Key,State,Delta);
}

function EditOnChange(GUIComponent Sender)
{
	Value = MyEditBox.TextStr;
    OnChange(Sender);
}

function SetHint(string NewHint)
{
	local int i;
	Super.SetHint(NewHint);

    for (i=0;i<Controls.Length;i++)
    	Controls[i].SetHint(NewHint);
}


defaultproperties
{
	begin object name=cMyEditBox class=GUIEditBox
	// Object Offset:0x00045C82
	bIntOnly=true
object end
// Reference: GUIEditBox'GUINumericEdit.cMyEditBox'
MyEditBox=cMyEditBox
	begin object name=cMyPlus class=GUISpinnerButton
	// Object Offset:0x00045C87
	PlusButton=true
object end
// Reference: GUISpinnerButton'GUINumericEdit.cMyPlus'
MyPlus=cMyPlus
	MyMinus=GUISpinnerButton'GUINumericEdit.cMyMinus'
	Value="0"
	Step=1
	PropagateVisibility=true
	bAcceptsInput=true
	WinHeight=0.06
}