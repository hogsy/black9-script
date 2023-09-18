// ====================================================================
//  Class:  GUI.GUIHorzScrollZone
//  Parent: GUI.GUIComponent
//
//  <Enter a description here>
// ====================================================================

class GUIHorzScrollZone extends GUIComponent
		Native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

	OnClick = InternalOnClick;
}

function bool InternalOnClick(GUIComponent Sender)
{
	local float perc;

	if (!IsInBounds())
		return false;

	perc = ( Controller.MouseX - ActualLeft() ) / ActualWidth();
	OnScrollZoneClick(perc);

	return true;

}


delegate OnScrollZoneClick(float Delta)		// Should be overridden
{
}

defaultproperties
{
	StyleName="ScrollZone"
	bAcceptsInput=true
	bCaptureMouse=true
	bNeverFocus=true
	bRepeatClick=true
}