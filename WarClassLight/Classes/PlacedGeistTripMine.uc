// ====================================================================
//  Class:  WarClassLight.PlacedGeistTripMine
//  Parent: WarClassLight.TripMines
//
//  <Enter a description here>
// ====================================================================

class PlacedGeistTripMine extends TripMines
	placeable;

auto state Warmup
{
	function BeginState()
	{
		GotoState('Online');
	}
}
	
	
defaultproperties
{
	bRespawnOnRestart=true
	TeamIndex=1
	StaticMesh=StaticMesh'gst_trip_mine.trip_mines.G_tripmine_M02_JM'
}