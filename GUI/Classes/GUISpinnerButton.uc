// ====================================================================
//  Class:  GUI.UT2SpinnerButton
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUISpinnerButton extends GUIGFXButton
	Native;

var(Menu)	bool	PlusButton;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	
	if (PlusButton)
		Graphic = Material'GUIContent.Menu.NumButPlus';
	else
		Graphic = Material'GUIContent.Menu.NumButMinus';
}


defaultproperties
{
	Position=2
	StyleName="RoundScaledButton"
	bNeverFocus=true
}