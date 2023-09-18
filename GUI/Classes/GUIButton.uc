// ====================================================================
//  Class:  GUI.GUIButton
//
//	GUIButton - The basic button class
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIButton extends GUIComponent
		Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
		
var		localized	string			Caption;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	OnKeyEvent=InternalOnKeyEvent;
    OnXControllerEvent=InternalOnXControllerEvent;

}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	if (key==0x0D && State==3)	// ENTER Pressed
	{
		OnClick(self);
		return true;
	}
	
	if (key==0x026 && State==1)
	{
		PrevControl(none);
		return true;
	}
			
	if (key==0x028 && State==1)
	{
		NextControl(none);
		return true;
	}
	
	return false;
}

function bool InternalOnXControllerEvent(byte Id, eXControllerCodes iCode)
{
	if (iCode==XC_Start)
    {
    	OnClick(Self);
        return true;
    }
    return false;
}



event ButtonPressed();		// Called when the button is pressed;
event ButtonReleased();		// Called when the button is released;

defaultproperties
{
	StyleName="RoundButton"
	bAcceptsInput=true
	bCaptureMouse=true
	WinHeight=0.04
	bTabStop=true
	bMouseOverSound=true
	OnClickSound=1
}