class InventoryAttachment extends Actor
	native
	nativereplication;

function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}
		
defaultproperties
{
	DrawType=2
	bOnlyDrawIfAttached=true
	bOnlyDirtyReplication=true
	RemoteRole=2
	NetUpdateFrequency=10
	bUseLightingFromBase=true
}