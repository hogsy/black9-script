//=============================================================================
// InfoStik_Pickup
//=============================================================================
class InfoStik_Pickup extends B9_PickUp;

#exec OBJ LOAD FILE=..\staticmesh\B9_items_mesh.ukx PACKAGE=B9_items_mesh

var(InfoStik) string InfoIni;
var(InfoStik) string InfoEntry;

function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;
	local string Ini, Entry;

	Ini = InfoIni;
	Entry = InfoEntry;

	Copy = Super.SpawnCopy( Other );
	if (Copy != None)
	{
		Log("Copy to STIK:"$Ini$" "$Entry);
		InfoStik(Copy).InfoIni = Ini;
		InfoStik(Copy).InfoEntry = Entry;
	}
	return Copy;
}

defaultproperties
{
	InfoIni="Test"
	InfoEntry="Black9"
	InventoryType=Class'InfoStik'
	PickupMessage="You picked up an info stik."
	DrawType=8
	StaticMesh=StaticMesh'B9_items_mesh.data_stiks.data_stik_info'
	AmbientGlow=64
	CollisionHeight=8
	Mass=10
}