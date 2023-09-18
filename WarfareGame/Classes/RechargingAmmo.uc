// ====================================================================
//  Class:  WarfareGame.RechargingAmmo
//  Parent: WarfareGame.WarfareAmmo
//
//  <Enter a description here>
// ====================================================================

class RechargingAmmo extends WarfareAmmo;

var	  float Charge;			// The Current charge
var() float InitialCharge; 	// How much to start with
var() float MaxCharge;		// How far can it go
var() float RechargeRate;	// How fast does a weapon Recharge

replication
{
	// Things the server should send to the client.
	reliable if( bNetOwner && bNetDirty && (Role==ROLE_Authority) )
		Charge;
}

event PostBeginPlay()
{
	Charge = MaxCharge;
	Super.PostBeginPlay();
}

event Tick(float Delta)	// Restore the charge
{
	super.Tick(Delta);
	Charge = fclamp(Charge+(RechargeRate*Delta),0,MaxCharge);	
}

function float UseCharge(float Amount)
{
	local float NewCharge,result;

	NewCharge = fClamp(Charge-Amount,0,MaxCharge);
	result = Charge - NewCharge;
	Charge = NewCharge;

	return Result;	
}

simulated function bool HasAmmo()
{
	return ( Charge > 0 );
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Canvas.DrawText("Ammunition "$GetItemName(string(self))$" Charge "$Charge$" Max "$MaxCharge);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

function bool HandlePickupQuery( pickup Item )
{
	local float MaxCharge;
	if ( class == item.InventoryType ) 
	{
		if (Charge==MaxCharge) 
			return true;
		item.AnnouncePickup(Pawn(Owner));
		
		AddAmmo(MaxCharge);
		return true;				
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

function bool AddAmmo(int AmmoToAdd)
{
	Charge = Min(MaxCharge, Charge+AmmoToAdd);
	return true;
}


defaultproperties
{
	InitialCharge=100
	MaxCharge=100
	RechargeRate=15
	MaxAmmo=100
}