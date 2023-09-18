//
// B9_HoloItem

class B9_HoloItem extends Actor;

var() localized string Description;
var() localized string DisplayName;
var() string InventoryName;
var() string AmmoName;
var() int RequiredStrength;
var() localized string LongDisplayName;	// used to display pending body mod info
var() bool CanAggregate;				// For cases where AmmoName == None, indicates if item appears in kiosk
										// even if player already has one. Defaults to false.

var int Price;
var int FullPrice;				// only used when selling items
var bool Restricted;
var bool Bought;				// used by skill kiosks
var bool IsWeapon;				// set by kiosk, subclasses don't need to set
var Inventory RealItem;			// used when selling items
var string KioskData;
var int UnitsPerPurchase;

function bool RemoveFromStock(Pawn pawn, Class solid, B9_CalibrationMaster master)
{
	// If returns true, item is removed from stock.
	// If returns false, item is kept in stock.

	// Price has been initialized from B9_Intermission data before call,
	// so the Price can be modified before returning false.
	
	return false;
}

defaultproperties
{
	Description="No description entered."
	DisplayName="Unnamed"
	RequiredStrength=5
	Price=1
	UnitsPerPurchase=1
	DrawType=2
	bHidden=true
	RemoteRole=0
	Texture=Texture'Engine.S_Inventory'
}