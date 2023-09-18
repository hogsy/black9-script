class Bug extends TransientAmbientPawn
	abstract;

function float MoveTimeTo(vector Destination)
{
	return VSize(Destination - Location)/AirSpeed;
}


			
defaultproperties
{
	bFlyer=true
	AirSpeed=200
	AccelRate=900
	Physics=4
	RotationRate=(Pitch=4096,Yaw=70000,Roll=0)
}