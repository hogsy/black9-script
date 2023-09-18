Class DSCanopy extends DropShipVehiclePart;

// if added to vehicle, start off opened
event BaseChange()
{
	local rotator NewRot;

	if ( Vehicle(Base) != None )
	{
		NewRot = Rotation;
		NewRot.Pitch += 6000;
		SetRotation(NewRot);
	}
}

function InFlightModel()
{
	local Rotator NewRot;

	NewRot = Rotation;
	NewRot.Pitch = Owner.Rotation.Pitch;
	SetRotation(NewRot);
	bHidden = true;
}

State Closing
{
	function Update(float DeltaTime)
	{
		local Rotator NewRot;
		local int TestPitch;

		NewRot = Rotation;
		NewRot.Pitch = Rotation.Pitch - 8192 * DeltaTime;
		TestPitch = Owner.Rotation.Pitch;
		if ( TestPitch > 32768 )
			TestPitch -= 65536;
		if ( NewRot.Pitch > 32768 )
			NewRot.Pitch -= 65536;
		if ( NewRot.Pitch < TestPitch )
		{
			NewRot.Pitch = Owner.Rotation.Pitch;
			GotoState('');
		}
		SetRotation(NewRot);	
	}

	function BeginState()
	{
		bUpdating = true;
	}

	function EndState()
	{
		bUpdating = false;
	}
}

State Opening
{
	function Update(float DeltaTime)
	{
		local Rotator NewRot;
		local int TestPitch;

		NewRot = Rotation;
		NewRot.Pitch = Rotation.Pitch + 8192 * DeltaTime;
		TestPitch = Owner.Rotation.Pitch + 6000;
		if ( TestPitch > 32768 )
			TestPitch -= 65536;
		if ( NewRot.Pitch > 32768 )
			NewRot.Pitch -= 65536;
		if ( NewRot.Pitch > TestPitch )
		{
			NewRot.Pitch = Owner.Rotation.Pitch + 6000;
			GotoState('');
		}
		SetRotation(NewRot);	
	}

	function BeginState()
	{
		bUpdating = true;
	}

	function EndState()
	{
		bUpdating = false;
	}
}

defaultproperties
{
	DrawType=8
	StaticMesh=StaticMesh'VehicleStaticMeshes.DropShip.DSCanopyMesh'
	DrawScale=2.5
}