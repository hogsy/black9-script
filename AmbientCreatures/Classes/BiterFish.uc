class BiterFish extends TransientAmbientPawn;

#exec MESH IMPORT MESH=AmbientFish ANIVFILE=MODELS\fish1_a.3D DATAFILE=MODELS\fish1_d.3D ZEROTEX=1
#exec MESH ORIGIN MESH=AmbientFish X=00 Y=-20 Z=00 YAW=-64

#exec MESH SEQUENCE MESH=AmbientFish SEQ=All    STARTFRAME=0   NUMFRAMES=11
#exec MESH SEQUENCE MESH=AmbientFish SEQ=Swim1  STARTFRAME=0   NUMFRAMES=8
#exec MESH SEQUENCE MESH=AmbientFish SEQ=Bite   STARTFRAME=8   NUMFRAMES=3

#exec TEXTURE IMPORT NAME=Jfish21  FILE=MODELS\fish1.PCX GROUP=Skins 
#exec MESHMAP SCALE MESHMAP=AmbientFish X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=AmbientFish NUM=0 TEXTURE=Jfish21 TLOD=200 

var float AirTime;

function float GetSleepTime()
{
	if ( Controller.Pawn == self )
		return 3 + 3 * FRand();
	return (FRand() * SleepTime);
}

function Landed(vector HitNormal)
{
	local rotator newRotation;

	newRotation = Rotation;
	newRotation.Pitch = 0;
	newRotation.Roll = 16384;
	SetRotation(newRotation);
	GotoState('Flopping');
}

function PhysicsVolumeChange( PhysicsVolume NewVolume )
{
	if ( NewVolume.bWaterVolume )
		AirTime = 0;
	else if (Physics != PHYS_Falling)
		SetPhysics(PHYS_Falling);
}

State Flopping
{
	function PhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		local rotator newRotation;

		Super.PhysicsVolumeChange(NewVolume);
		newRotation = Rotation;
		newRotation.Roll = 0;
		SetRotation(newRotation);
		SetPhysics(PHYS_Swimming);
		GotoState('Swimming');
	}

	function Landed(vector HitNormal)
	{
		local rotator newRotation;

		SetPhysics(PHYS_None);
		SetTimer(0.3 + 0.3 * AirTime * FRand(), false);
		newRotation = Rotation;
		newRotation.Pitch = 0;
		newRotation.Roll = 16384;
		SetRotation(newRotation);
	}
		
	function Timer()
	{
		AirTime += 1;
		if (AirTime > 25 + 20 * FRand())
			GotoState('Dying');
		else
		{
			SetPhysics(PHYS_Falling);
			Velocity = 200 * VRand();
			Velocity.Z = 60 + 160 * FRand();
			DesiredRotation.Pitch = Rand(8192) - 4096;
			DesiredRotation.Yaw = 2 * Rand(32767);
		}		
	}

	function AnimEnd(int Channel)
	{
		if (FRand() < 0.5)
			PlayAnim('Swim1', 0.1 * FRand());
		else
			PlayAnim('Bite', 0.1 * FRand());
	}

	function BeginState()
	{
		SetPhysics(PHYS_None);
		SetTimer(0.2 + FRand(), false);
		SetPhysics(PHYS_Falling);
	}
}
		
defaultproperties
{
	bCanSwim=true
	WaterSpeed=180
	AccelRate=1700
	UnderWaterTime=-1
	Physics=3
	Mesh=VertMesh'AmbientFish'
	Mass=5
	Buoyancy=5
	RotationRate=(Pitch=8192,Yaw=128000,Roll=16384)
}