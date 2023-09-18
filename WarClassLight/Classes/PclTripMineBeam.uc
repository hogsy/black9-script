// ====================================================================
//  Class:  WarClassLight.PclTripMineBeam
//  Parent: Engine.Emitter
//
//  <Enter a description here>
// ====================================================================

class PclTripMineBeam extends Emitter;

function Activate(int team, int Dist)
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	
	GetAxes(Owner.Rotation,X,Y,Z);
	StartTrace = Location + X + Y +Z; 
	EndTrace = StartTrace + (Dist * X); 
	Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);

	if (Other==None)
	{
		return;
	}
	
	BeamEmitter(Emitters[Team]).BeamEndPoints[0].Offset.X.Min = vSize(HitLocation-Owner.Location);
	BeamEmitter(Emitters[Team]).BeamEndPoints[0].Offset.X.Max = vSize(HitLocation-Owner.Location);
	Emitters[Team].Disabled=false;
}

defaultproperties
{
	Emitters=/* Array type was not detected. */
	bNoDelete=false
	bDynamicLight=true
	RemoteRole=1
}