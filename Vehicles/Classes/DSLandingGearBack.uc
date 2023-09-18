Class DSLandingGearBack extends DropShipVehiclePart;

/*
function InFlightModel()
{
	bUpdating = false;
	bHidden = true;
	DropShip(Owner).PartOffset[10].Z = -107;
	SetRelativeLocation(DropShip(Owner).PartOffset[10]);
}
*/

defaultproperties
{
	DrawType=8
	StaticMesh=StaticMesh'VehicleStaticMeshes.DropShip.DSBackLegMesh'
	DrawScale=2.5
}