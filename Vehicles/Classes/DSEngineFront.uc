class DSEngineFront extends DropShipVehiclePart;

var EngineFlame FlameLeft, FlameRight;
var bool bAfterBurner;
var vector EngineOffsetRight, EngineOffsetLeft;
var EngineWash EngineWashLeft, EngineWashRight;

function Start()
{
	PlaySound(sound'DSStartup');
	SpawnFlames();
}

function SpawnFlames()
{
	if ( FlameLeft == None )
		FlameLeft = Spawn(class'EngineFlame', self);
	if ( FlameRight == None )
		FlameRight = Spawn(class'EngineFlame', self);
	FlameLeft.SetBase(self);
	FlameRight.SetBase(self);
	FlameLeft.SetRelativeLocation(EngineOffsetLeft);
	FlameRight.SetRelativeLocation(EngineOffsetRight);
}

function Activate(bool bActive)
{
	if ( bActive )
		GotoState('Firing');
//	else
//		GotoState('');
}

function SetAfterBurner(bool bActive)
{
	bAfterBurner = DropShip(Owner).bAfterBurner;
	FlameLeft.afterburner(bAfterBurner);
	FlameRight.afterburner(bAfterBurner);
	if ( bAfterBurner )
		AmbientSound = sound'DSafterburner';
	else
		AmbientSound = sound'DSjetengine';
}

function EngineWash CheckEngineWash(EngineWash Current, vector StartLoc)
{
	local actor HitActor;
	local vector HitNormal, HitLocation;
	local float TraceDist;

	if ( Current == None )
		TraceDist = 1500;
	else
		TraceDist = 2000;

	HitActor = Trace(HitLocation, HitNormal, StartLoc - TraceDist*vect(0,0,1), StartLoc, false);
	if ( HitActor == None )
	{
		if ( Current != None )
			Current.Destroy();
		return None;
	}
	else
	{
		if ( Current == None )
			Current = spawn(class'EngineWash', self);

		Current.SetStrength(VSize(StartLoc - HitLocation));
		Current.SetLocation(HitLocation);
		return Current;
	}
}	

State Firing
{
	function Update(float DeltaTime)
	{
		// change pitch smoothly
		SetRelativeRotation(DropShip(Owner).EngineRot);
		if ( bAfterBurner != DropShip(Owner).bAfterBurner )
			SetAfterBurner(DropShip(Owner).bAfterBurner);
	
		// if pointed down, check if close to ground
		if ( ((Rotation.Pitch & 65535) < 12000) || ((Rotation.Pitch & 65535) > 53535) )
		{
			EngineWashLeft = CheckEngineWash(EngineWashLeft, FlameLeft.Location);
			EngineWashRight = CheckEngineWash(EngineWashRight, FlameRight.Location);
		}
		else
		{
			if ( EngineWashLeft != None )
			{
				EngineWashLeft.Destroy();
				EngineWashLeft = None;
			}
			if ( EngineWashRight != None )
			{
				EngineWashRight.Destroy();
				EngineWashRight = None;
			}
		}
	}

	function BeginState()
	{
		SetAfterBurner(DropShip(Owner).bAfterBurner);
		bUpdating = true;
		SpawnFlames();
	}

	function EndState()
	{
		AmbientSound = None;
		bUpdating = false;
		if ( FlameLeft != None )
			FlameLeft.Destroy();
		if ( FlameRight != None )
			FlameRight.Destroy();
	}
}
defaultproperties
{
	EngineOffsetRight=(X=-10,Y=-635,Z=-100)
	EngineOffsetLeft=(X=-10,Y=635,Z=-100)
	DrawType=8
	StaticMesh=StaticMesh'VehicleStaticMeshes.DropShip.DropShipEngineFront'
	DrawScale=2.5
	SoundVolume=255
}