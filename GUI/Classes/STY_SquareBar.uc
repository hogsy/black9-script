// ====================================================================
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
//
//	Generic bar used to display most popup dialogs / menus
//	Background...  (Mid-Game Menu, for example)
// ====================================================================

class STY_SquareBar extends STY_RoundButton;

defaultproperties
{
	KeyName="SquareBar"
	Images[0]=Texture'GUIContent.Menu.SquareBoxA'
	Images[4]=Texture'GUIContent.Menu.SquareBoxA'
	FontColors[0]=(B=160,G=160,R=160,A=255)
	FontColors[1]=(B=160,G=160,R=160,A=255)
	FontColors[2]=(B=160,G=160,R=160,A=255)
	FontColors[3]=(B=160,G=160,R=160,A=255)
	FontColors[4]=(B=160,G=160,R=160,A=255)
}