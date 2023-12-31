// ====================================================================
//  Class:  GUI.GUIHorzScrollBar
//  Parent: GUI.GUIMultiComponent
//
//  <Enter a description here>
// ====================================================================

class GUIHorzScrollBar extends GUIScrollBarBase
		Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var Automated GUIHorzScrollZone MyScrollZone;
var Automated GUIHorzScrollButton MyLeftButton;
var Automated GUIHorzScrollButton MyRightButton;
var Automated GUIHorzGripButton MyGripButton;

var		float			GripLeft;		// Where in the ScrollZone is the grip	- Set Natively
var		float			GripWidth;		// How big is the grip - Set Natively

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	MyScrollZone.OnScrollZoneClick = ZoneClick;
	MyLeftButton.OnClick = LeftTickClick;
	MyRightButton.OnClick = RightTickClick;
	MyGripButton.OnCapturedMouseMove = GripMouseMove;

    Refocus(MyList);

}

function UpdateGripPosition(float NewPos)
{
	MyList.MakeVisible(NewPos);
	GripLeft = NewPos;
}

function bool GripMouseMove(float deltaX, float deltaY)
{
	local float NewPerc,NewLeft;

	if (deltaX==0)	// Don't care about horz movement
		return true;


	deltaX*=-1;

	// Calculate the new Grip Left using the mouse cursor location.

	NewPerc = abs(deltaX) / (MyScrollZone.ActualWidth()-GripWidth);

	if (deltaX<0)
		NewPerc*=-1;

	NewLeft = FClamp(GripLeft+NewPerc,0.0,1.0);

	UpdateGripPosition(NewLeft);

	return true;
}

function ZoneClick(float Delta)
{
	if ( Controller.MouseX < MyGripButton.Bounds[0] )
		MoveGripBy(-MyList.ItemsPerPage);
	else if ( Controller.MouseX > MyGripButton.Bounds[2] )
		MoveGripBy(MyList.ItemsPerPage);

	return;
}

function MoveGripBy(int items)
{
	local int LeftItem;

	LeftItem = MyList.Top + items;
	if (MyList.ItemCount > 0)
	{
		MyList.SetTopItem(LeftItem);
		AlignThumb();
	}
}

function bool LeftTickClick(GUIComponent Sender)
{
	WheelUp();
	return true;
}

function bool RightTickClick(GUIComponent Sender)
{
	WheelDown();
	return true;
}

function WheelUp()
{
	if (!Controller.CtrlPressed)
		MoveGripBy(-1);
	else
		MoveGripBy(-MyList.ItemsPerPage);
}

function WheelDown()
{
	if (!Controller.CtrlPressed)
		MoveGripBy(1);
	else
		MoveGripBy(MyList.ItemsPerPage);
}

function AlignThumb()
{
	local float NewLeft;

	if (MyList.ItemCount==0)
		NewLeft = 0;
	else
	{
		NewLeft = Float(MyList.Top) / Float(MyList.ItemCount-MyList.ItemsPerPage );
		NewLeft = FClamp(NewLeft,0.0,1.0);
	}

	GripLeft = NewLeft;
}


// NOTE:  Add graphics for no-man's land about and below the scrollzone, and the Scroll nub.

defaultproperties
{
	MyScrollZone=GUIHorzScrollZone'GUIHorzScrollBar.HScrollZone'
	begin object name=HLeftBut class=GUIHorzScrollButton
	// Object Offset:0x00045C68
	LeftButton=true
object end
// Reference: GUIHorzScrollButton'GUIHorzScrollBar.HLeftBut'
MyLeftButton=HLeftBut
	MyRightButton=GUIHorzScrollButton'GUIHorzScrollBar.HRightBut'
	MyGripButton=GUIHorzGripButton'GUIHorzScrollBar.HGrip'
	bAcceptsInput=true
	WinWidth=0.0375
}