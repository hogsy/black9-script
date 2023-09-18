// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class GUIFloatEdit extends GUIMultiComponent
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
var(Menu)	float				MinValue;
var(Menu)	float				MaxValue;
var(Menu)	float				Step;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

	Super.Initcomponent(MyController, MyOwner);

	MyEditBox.OnChange = EditOnChange;
	MyEditBox.SetText(Value);
	MyEditBox.OnKeyEvent = EditKeyEvent;

	MyEditBox.INIOption  = INIOption;
	MyEditBox.INIDefault = INIDefault;

	CalcMaxLen();

	MyPlus.OnClick = SpinnerPlusClick;
	MyPlus.FocusInstead = MyEditBox;
	MyMinus.OnClick = SpinnerMinusClick;
	MyMinus.FocusInstead = MyEditBox;

    SetHint(Hint);

}

function SetHint(string NewHint)
{
	local int i;
	Super.SetHint(NewHint);

    for (i=0;i<Controls.Length;i++)
    	Controls[i].SetHint(NewHint);
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

	MyEditBox.MaxWidth = DigitCount+4;
}
function SetValue(float V)
{
	if (v<MinValue)
		v=MinValue;

	if (v>MaxValue)
		v=MaxValue;

	MyEditBox.SetText(""$v);
}

function bool SpinnerPlusClick(GUIComponent Sender)
{
	local float v;

	v = float(Value) + Step;
    SetValue(v);
	return true;
}

function bool SpinnerMinusClick(GUIComponent Sender)
{
	local float v;

	v = float(Value) - Step;
	SetValue(v);
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

defaultproperties
{
	begin object name=cMyEditBox class=GUIEditBox
	// Object Offset:0x00045C77
	bFloatOnly=true
object end
// Reference: GUIEditBox'GUIFloatEdit.cMyEditBox'
MyEditBox=cMyEditBox
	begin object name=cMyPlus class=GUISpinnerButton
	// Object Offset:0x00045C7C
	PlusButton=true
object end
// Reference: GUISpinnerButton'GUIFloatEdit.cMyPlus'
MyPlus=cMyPlus
	MyMinus=GUISpinnerButton'GUIFloatEdit.cMyMinus'
	Value="0.0"
	Step=1
	PropagateVisibility=true
	bAcceptsInput=true
	WinHeight=0.06
}