// ====================================================================
//  Class:  GUI.GUIListBoxBase
//
//  The GUIListBoxBase is a wrapper for a GUIList and it's ScrollBar
//
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class GUIListBoxBase extends GUIMultiComponent
		Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var Automated	GUIVertScrollBar	MyScrollBar;
var 			GUIListBase			MyList;
var				bool				bVisibleWhenEmpty;		// List box is visible when empty.


function InitBaseList(GUIListBase LocalList)
{
	local int i;

    MyList = LocalList;

	LocalList.StyleName = StyleName;
	LocalList.bVisibleWhenEmpty = bVisibleWhenEmpty;
	LocalList.MyScrollBar = MyScrollBar;
	MyScrollBar.MyList = LocalList;

	MyScrollBar.FocusInstead = LocalList;

	for (i=0;i<MyScrollBar.Controls.Length;i++)
		MyScrollBar.Controls[i].FocusInstead = LocalList;

	SetVisibility(bVisible);
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
	begin object name=TheScrollbar class=GUIVertScrollBar
	// Object Offset:0x00045F74
	bVisible=false
object end
// Reference: GUIVertScrollBar'GUIListBoxBase.TheScrollbar'
MyScrollBar=TheScrollbar
	PropagateVisibility=true
	StyleName="ListBox"
	bAcceptsInput=true
}