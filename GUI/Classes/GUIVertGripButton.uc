// ====================================================================
//  Class:  GUI.GUIVertGripButton
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIVertGripButton extends GUIGFXButton
		Native;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
//	Graphic = Material'GUIContent.Menu.ButGrip';
}


defaultproperties
{
	Position=4
	bNeverFocus=true
	OnClickSound=0
}