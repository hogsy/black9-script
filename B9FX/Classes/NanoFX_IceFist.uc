//=============================================================================
// NanoFX_IceFist.uc
//
//
//=============================================================================


class NanoFX_IceFist extends Actor
	notplaceable;




simulated function SpawnIceDust()
{
	Spawn( class'HitFX_Icefist_Dust',,, Location, Rotation );
}





defaultproperties
{
	DrawType=8
	StaticMesh=StaticMesh'B9_Effects_meshes.nanoFist.iceFist'
}