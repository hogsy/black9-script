/////////////////////////////////////////////////
// Triggerable_Gravity_Volume
// Christian
//

class Triggerable_Gravity_Volume extends PhysicsVolume
	placeable;

var(Volume)bool bStartOn;


function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (bStartOn)
	{
		setCollision(true, false, false);	
	}
	else
	{
		setCollision(false, false, false);
	}
}


function Trigger( actor Other, pawn EventInstigator )
{
	if (bStartOn)
	{
		setCollision(false, false, false);
		bStartOn = false;
	}
	else
	{
		setCollision(true, false, false);
		bStartOn = true;
	}
}

defaultproperties
{
	bStatic=false
}