// ====================================================================
//  Class:  WarClassLight.PlacedCogTripMine
//  Parent: WarClassLight.TripMines
//
//  <Enter a description here>
// ====================================================================

class PlacedCogTripMine extends TripMines
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
}