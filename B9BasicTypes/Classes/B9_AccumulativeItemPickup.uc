//=============================================================================
// B9_AccumulativeItemPickup
//
// 
//	Used as pickups for B9_AccumulativeItem
// 
//=============================================================================
class B9_AccumulativeItemPickup extends B9_Ammo
	abstract;

var() int Amount;

function float BotDesireability(Pawn Bot)
{
	local B9_AccumulativeItem AlreadyHas;

	AlreadyHas = B9_AccumulativeItem(Bot.FindInventoryType(InventoryType));
	if ( AlreadyHas == None )
		return (0.35 * MaxDesireability);
	if ( AlreadyHas.Amount == 0 )
		return MaxDesireability;
	if (AlreadyHas.Amount >= AlreadyHas.MaxAmount) 
		return -1;

	return ( MaxDesireability * FMin(1, 0.15 * Amount/AlreadyHas.Amount) );
}

function inventory SpawnCopy( Pawn Other )
{
	local Inventory Copy;

	Copy = Super.SpawnCopy(Other);
	B9_AccumulativeItem(Copy).Amount = Amount;
	return Copy;
}

defaultproperties
{
	PickupMessage="You picked up some stuff."
}