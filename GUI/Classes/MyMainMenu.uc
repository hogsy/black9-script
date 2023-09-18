// ====================================================================
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class MyMainMenu extends GUIPage;

#exec OBJ LOAD FILE=GUIContent.utx

var automated 	GUIButton	TestButton1;
var automated 	GUIButton	TestButton2;
var automated 	GUIButton	QuitButton;

var bool	AllowClose;

function bool MyKeyEvent(out byte Key,out byte State,float delta)
{
	if(Key == 0x1B && State == 1)	// Escape pressed
	{
		AllowClose = true;
		return true;
	}
	else
		return false;
}

function bool CanClose(optional Bool bCancelled)
{
	if(AllowClose)
		Controller.OpenMenu("GUI.MyQuitPage");

	return false;
}


function bool ButtonClick(GUIComponent Sender)
{
	local GUIButton Selected;

	if (GUIButton(Sender) != None)
		Selected = GUIButton(Sender);

	if (Selected == None) return false;

	switch (Selected)
	{
		case TestButton1:
			return Controller.OpenMenu("GUI.MyTest2Page"); break;
		case TestButton2:
			return Controller.OpenMenu("GUI.MyTestPage"); break;
		case QuitButton:
			return Controller.OpenMenu("GUI.MyQuitPage"); break;
	}
	return false;
}

defaultproperties
{
	begin object name=cTestButton1 class=GUIButton
	// Object Offset:0x00045C8D
	Caption="Test 1"
	StyleName="TextButton"
	Hint="The First Test"
	WinTop=0.334635
	WinLeft=0.25
	WinWidth=0.5
	WinHeight=0.075
	bFocusOnWatch=true
	OnClick=ButtonClick
object end
// Reference: GUIButton'MyMainMenu.cTestButton1'
TestButton1=cTestButton1
	begin object name=cTestButton2 class=GUIButton
	// Object Offset:0x00045CDC
	Caption="Test 2"
	StyleName="TextButton"
	Hint="More Tests"
	WinTop=0.506251
	WinLeft=0.25
	WinWidth=0.5
	WinHeight=0.075
	TabOrder=1
	bFocusOnWatch=true
	OnClick=ButtonClick
object end
// Reference: GUIButton'MyMainMenu.cTestButton2'
TestButton2=cTestButton2
	begin object name=cQuitButton class=GUIButton
	// Object Offset:0x00045D2D
	Caption="QUIT"
	StyleName="TextButton"
	Hint="Exit"
	WinTop=0.905725
	WinLeft=0.391602
	WinWidth=0.205078
	WinHeight=0.042773
	TabOrder=5
	bFocusOnWatch=true
	OnClick=ButtonClick
object end
// Reference: GUIButton'MyMainMenu.cQuitButton'
QuitButton=cQuitButton
	Background=Texture'GUIContent.Menu.EpicLogo'
	bAllowedAsLast=true
	bDisconnectOnOpen=true
	OnCanClose=CanClose
	WinHeight=1
	OnKeyEvent=MyKeyEvent
}