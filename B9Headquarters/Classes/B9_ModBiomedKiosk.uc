/////////////////////////////////////////////////////////////
// B9_ModBiomedKiosk
//

class B9_ModBiomedKiosk extends B9_BuyModKiosk;

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
		StockMods(Listener.intermission.BiomedModKioskStock);
	}
}

defaultproperties
{
	fStrCategoryName="BIO-MED"
	TriggerTagName=ModBiomedKioskTrigger
}