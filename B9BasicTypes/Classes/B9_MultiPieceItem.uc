// B9_MultiPieceItem.uc

class B9_MultiPieceItem extends Inventory;

var travel int PiecesNeeded;
var travel class<Inventory> FinalItemClass;

function bool HandlePickupQuery( pickup Item )
{
	local B9_MultiPieceItemPickup MPIP;
	local Inventory Inv;

	if ( class == Item.InventoryType ) 
	{
		MPIP = B9_MultiPieceItemPickup(Item);
		if ( MPIP.FinalItemClass == FinalItemClass )
		{
			Item.AnnouncePickup(Pawn(Owner));

			if (--PiecesNeeded == 0)
			{
				Inv = Spawn(FinalItemClass);
				Inv.GiveTo(Pawn(Owner));
				
				Destroy();
			}

			return true;
		}
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}
