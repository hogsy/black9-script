// B9_MultiPieceItemPickup.uc

class B9_MultiPieceItemPickup extends B9_Pickup
	placeable;

var(MultiPieceItemPickup) class<Inventory> FinalItemClass;
var(MultiPieceItemPickup) int PiecesNeeded;

function inventory SpawnCopy(Pawn Other)
{
	local Controller P;
	local Inventory Copy;
	local B9_MultiPieceItem Item;

	Copy = Super.SpawnCopy(Other);
	if (Copy != None)
	{
		Item = B9_MultiPieceItem(Copy);
		Item.FinalItemClass = FinalItemClass;
		Item.PiecesNeeded = PiecesNeeded - 1;
	}
	return Copy;
}

function SetRespawn()
{
	Destroy();
}

defaultproperties
{
	PiecesNeeded=2
	InventoryType=Class'B9_MultiPieceItem'
	PickupMessage="You picked up a piece of something."
	DrawType=8
	StaticMesh=StaticMesh'B9_items_mesh.data_stiks.data_stik_info'
}