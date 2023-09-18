// ====================================================================
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class MyQuitPage extends GUIPage;

var automated GUIButton QuitBackground;
var automated GUIButton YesButton;
var automated GUIButton NoButton;
var automated GUILabel 	QuitDesc;

function bool InternalOnClick(GUIComponent Sender)
{
	if (Sender==YesButton)
	{
		if(PlayerOwner().Level.IsDemoBuild())
			Controller.ReplaceMenu("GUI.UT2DemoQuitPage");
		else
			PlayerOwner().ConsoleCommand("exit");
	}
	else
		Controller.CloseMenu(false);

	return true;
}

defaultproperties
{
	begin object name=cQuitBackground class=GUIButton
	// Object Offset:0x00045DEA
	StyleName="SquareBar"
	bBoundToParent=true
	bScaleToParent=true
	bAcceptsInput=false
	bNeverFocus=true
	WinHeight=1
object end
// Reference: GUIButton'MyQuitPage.cQuitBackground'
QuitBackground=cQuitBackground
	begin object name=cYesButton class=GUIButton
	// Object Offset:0x00045E0D
	Caption="YES"
	bBoundToParent=true
	WinTop=0.75
	WinLeft=0.125
	WinWidth=0.2
	OnClick=InternalOnClick
object end
// Reference: GUIButton'MyQuitPage.cYesButton'
YesButton=cYesButton
	begin object name=cNoButton class=GUIButton
	// Object Offset:0x00045E33
	Caption="NO"
	bBoundToParent=true
	WinTop=0.75
	WinLeft=0.65
	WinWidth=0.2
	TabOrder=1
	OnClick=InternalOnClick
object end
// Reference: GUIButton'MyQuitPage.cNoButton'
NoButton=cNoButton
	begin object name=cQuitDesc class=GUILabel
	// Object Offset:0x00045E5D
	Caption="Are you sure you wish to quit?"
	TextAlign=1
	TextColor=(B=0,G=180,R=220,A=255)
	TextFont="HeaderFont"
	WinTop=0.4
	WinHeight=32
object end
// Reference: GUILabel'MyQuitPage.cQuitDesc'
QuitDesc=cQuitDesc
	bRequire640x480=false
	WinTop=0.375
	WinHeight=0.25
}