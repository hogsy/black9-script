//=============================================================================
// scorch
// base class of Warfare damage decals
//=============================================================================
class Scorch extends Projector;

var float Lifetime;

function PostBeginPlay()
{
	AttachProjector();
	AbandonProjector(Lifetime);
	Destroy();
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Destroy();
}

defaultproperties
{
	Lifetime=60
	MaxTraceDistance=32
	bProjectTerrain=false
	bProjectStaticMesh=false
	bProjectActor=false
	bClipBSP=true
}