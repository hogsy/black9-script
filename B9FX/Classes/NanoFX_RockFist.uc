//=============================================================================
// NanoFX_RockFist.uc
//
//
//=============================================================================


class NanoFX_RockFist extends Actor
	notplaceable;


simulated function SpawnRocks()
{
	//Spawn( class'HitFX_Rockfist_Rocks',,, Location, Rotation );
}



defaultproperties
{
	DrawType=8
	StaticMesh=StaticMesh'B9_Effects_meshes.nanoFist.rockFist'
}