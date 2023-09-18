/////////////////////////////////////////////////////////////
// B9_GearSellKiosk
//

class B9_GearSellKiosk extends B9_SellPhysicalKiosk;

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
	local array<class> SellClasses;
	local array<string> SellPackages;

	Super.MenuInit(interaction, controller, parent);

	if (RootInteraction == self)
	{
		SellClasses.Length = 1;
		SellPackages.Length = 1;
		SellClasses[0] = class'Powerups';
		SellPackages[0] = "B9Headquarters";
		StockFromInventory(SellClasses, SellPackages, false);
	}
}

defaultproperties
{
	TriggerTagName=GearSellKioskTrigger
}