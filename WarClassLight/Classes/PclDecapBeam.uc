// ====================================================================
//  Class:  WarClassLight.PclDecapBeam
//  Parent: Engine.Emitter
//
//  <Enter a description here>
// ====================================================================

class PclDecapBeam extends Emitter;

function Activate(int team, int Dist)
{
	BeamEmitter(Emitters[Team]).BeamEndPoints[0].Offset.X.Min = Dist;
	BeamEmitter(Emitters[Team]).BeamEndPoints[0].Offset.X.Max = Dist;
	Emitters[Team].Disabled=false;
}

defaultproperties
{
	Emitters=/* Array type was not detected. */
	bNoDelete=false
	bDynamicLight=true
	RemoteRole=1
}