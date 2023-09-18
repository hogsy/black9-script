//=============================================================================
// MapList.
//
// contains a list of maps to cycle through
//
//=============================================================================
class MapList extends Info
	abstract;

var(Maps) config array<string> Maps;
var config int MapNum;
var string MapExt; // Added by JP/Taldren.

function string GetNextMap()
{
	local string CurrentMap;
	local int i;

	CurrentMap = GetURLMap();
	if ( CurrentMap != "" )
	{
		if ( Right(CurrentMap, Len(MapExt)) ~= MapExt ) // Changed by JP/Taldren.
			CurrentMap = CurrentMap;
		else
			CurrentMap = CurrentMap$MapExt;

		for ( i=0; i<Maps.Length; i++ )
		{
			if ( CurrentMap ~= Maps[i] )
			{
				MapNum = i;
				break;
			}
		}
	}

	// search vs. w/ or w/out .unr extension

	MapNum++;
	if ( MapNum > Maps.Length - 1 )
		MapNum = 0;
	if ( Maps[MapNum] == "" )
		MapNum = 0;

	SaveConfig();
	return Maps[MapNum];
}

defaultproperties
{
	MapExt=".b9"
}