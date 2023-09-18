/////////////////////////////////////////////////////////////
// B9_WeaponHeavyKiosk
//

class B9_WeaponHeavyKiosk extends B9_BuyPhysicalKiosk;

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
		StockItems(Listener.intermission.HeavyWeaponsKioskStock);
	}
}

defaultproperties
{
	PickupDropTagName=WeaponKioskDropLocation
	fIsWeaponKiosk=true
	fStrCategoryName="HEAVY WEAPONS"
	TriggerTagName=WeaponHeavyKioskTrigger
}