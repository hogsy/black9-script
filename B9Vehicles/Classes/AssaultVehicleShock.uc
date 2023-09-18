class AssaultVehicleShock extends VehiclePart;

var KCarWheelJoint  Joint;
var rotator         SuspRot;
var bool            oppRot; // invert rotation direction (for opposite sides)


var float susAngle;
var float oldsusAngle;



function Tick(float Delta)
{
    
    if ( oppRot )
	{
        susAngle = -655360 / 6.283 * ACos( vect( 0, 0, 0 ) Dot Normal( Joint.KConstraintActor2.Location ) );
	}
    else
	{
        susAngle = 655360 / 6.283 * ACos( vect( 0, 0, 0 ) Dot Normal( Joint.KConstraintActor2.Location ) );
	}

    susAngle *= -1;


    if ( susAngle != oldsusAngle )
	{
		log("Wheel Angle:"$susAngle);
	}
    oldsusAngle = susAngle;


    SuspRot =  rot( 0, 0, 1 ) * susAngle;
    SetRelativeRotation( SuspRot );
}

defaultproperties
{
	DrawType=8
	StaticMesh=StaticMesh'VehicleStaticMeshes.Buggy.Shock'
	DrawScale=0.8
}