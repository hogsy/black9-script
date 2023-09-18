// ====================================================================
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class MyNetworkStatusMsg extends GUIPage;


var automated GUIButton NetStatBackground;
var automated GUIButton NetStatOk;
var automated GUILabel 	NetStatLabel;

var bool bIgnoreEsc;

var		localized string LeaveMPButtonText;
var		localized string LeaveSPButtonText;

var		float ButtonWidth;
var		float ButtonHeight;
var		float ButtonHGap;
var		float ButtonVGap;
var		float BarHeight;
var		float BarVPos;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(Mycontroller, MyOwner);
	PlayerOwner().ClearProgressMessages();
}


function bool InternalOnClick(GUIComponent Sender)
{
	if(Sender==NetStatOk) // OK
	{
		Controller.ReplaceMenu("GUI.MyMainMenu");
	}

	return true;
}

event HandleParameters(string Param1, string Param2)
{
	NetStatLabel.Caption = Param1$"|"$Param2;
	PlayerOwner().ClearProgressMessages();
}

defaultproperties
{
	begin object name=cNetStatBackground class=GUIButton
	// Object Offset:0x00045D77
	StyleName="SquareBar"
	bAcceptsInput=false
	bNeverFocus=true
	WinTop=0.375
	WinHeight=0.25
object end
// Reference: GUIButton'MyNetworkStatusMsg.cNetStatBackground'
NetStatBackground=cNetStatBackground
	begin object name=cNetStatOk class=GUIButton
	// Object Offset:0x00045D98
	Caption="OK"
	bBoundToParent=true
	WinTop=0.675
	WinLeft=0.375
	WinWidth=0.25
	WinHeight=0.05
	OnClick=InternalOnClick
object end
// Reference: GUIButton'MyNetworkStatusMsg.cNetStatOk'
NetStatOk=cNetStatOk
	begin object name=cNetStatLabel class=GUILabel
	// Object Offset:0x00045DC2
	TextAlign=1
	TextFont="HeaderFont"
	bMultiLine=true
	bBoundToParent=true
	WinTop=0.125
	WinHeight=0.5
object end
// Reference: GUILabel'MyNetworkStatusMsg.cNetStatLabel'
NetStatLabel=cNetStatLabel
	bIgnoreEsc=true
	bRequire640x480=false
	WinTop=0.375
	WinHeight=0.25
}