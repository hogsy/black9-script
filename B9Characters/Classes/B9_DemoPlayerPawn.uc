//=============================================================================
// B9_DemoPlayerPawn
//
//
// 
//=============================================================================


class B9_DemoPlayerPawn extends Pawn;


function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist;

	log( "------ CalcBehindView" );
	Dist += 150.0;

	CameraRotation = Rotation;
	View = vect(1,0,0) >> CameraRotation;
	if( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
		ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
	else
		ViewDist = Dist;
	CameraLocation -= (ViewDist - 30) * View; 
}

defaultproperties
{
	ControllerClass=none
}