// ====================================================================
//	GUITabButton - A Tab Button has an associated Tab Control, and
//  TabPanel.
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUITabButton extends GUIButton
		Native;

var				bool			bForceFlash;		// Lets you get a tab to flash even if its not focused
var				bool			bActive;			// Is this the active tab
var				GUITabPanel		MyPanel;			// This is the panel I control

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{

	Super.Initcomponent(MyController, MyOwner);
}

event SetFocus(GUIComponent Who)
{
	return;
}

function ChangeActiveState(bool IsActive, bool bFocusPanel)
{
	bActive = IsActive;

	if (MyPanel==None) return;

	MyPanel.ShowPanel(IsActive);

	if (IsActive)
	{
		if (bFocusPanel)
			MyPanel.FocusFirst(None);

	}
}

function bool CanShowPanel()
{
	if (MyPanel != None)
		return MyPanel.CanShowPanel();

	return false;
}

defaultproperties
{
	StyleName="TabButton"
	bBoundToParent=true
	bNeverFocus=true
	WinHeight=0.075
	OnClickSound=2
}