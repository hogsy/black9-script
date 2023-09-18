class InfoStik extends B9_AutomaticItem;

var travel string InfoIni;
var travel string InfoEntry;

var string Title;
var string Contents;
var string OnceOnly;

function PerformReadAction()
{
	if (GetOnceOnly())
		Destroy();
}

function string GetTitle()
{
	if (Title == "")
		Title = Localize( InfoEntry, "Title", InfoIni$"Info" );
	return Title;
}

function string GetContents()
{
	if (Contents == "")
		Contents = Localize( InfoEntry, "Contents", InfoIni$"Info" );
	return Contents;
}

function bool GetOnceOnly()
{
	if (OnceOnly == "")
		OnceOnly = Localize( InfoEntry, "OnceOnly", InfoIni$"Info" );
	return (OnceOnly != "" && int(OnceOnly) != 0);
}

event Trigger( Actor Other, Pawn EventInstigator )
{
	if (Other == self)
		Log("STIK ["$GetTitle()$"] "$GetContents());
}

defaultproperties
{
	PickupClass=Class'InfoStik_Pickup'
	ItemName="InfoStik"
	RemoteRole=1
}