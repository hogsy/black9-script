/////////////////////////////////////////////////////////////
// B9_GearMiscKiosk
//

class B9_GearMiscKiosk extends B9_BuyPhysicalKiosk;

// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentInteraction. You don't have to implement MenuInit(),
// but you should call super.MenuInit() if you do.
function Initialized()
{
	log(self@"I'm alive");
}

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	Super.MenuInit(interaction, controller, parent);

	if (RootInteraction == self)
	{
		StockItems(Listener.intermission.MiscGearKioskStock);
	}
}

defaultproperties
{
	PickupDropTagName=GearKioskDropLocation
	fStrCategoryName="MISCELLANEOUS"
	TriggerTagName=GearMiscKioskTrigger
}