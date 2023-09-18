//=============================================================================
// B9_Automation
//
// 
//	Base class for automated weapons (sentry turrets, etc)
// 
//=============================================================================

class B9_Automation extends B9_ArchetypePawnBase abstract;

//////////////////////////////////////////////////
// Variables
//

var ScriptedSequence				fTrigger;
var class<ScriptedSequence>			fTriggerClass;

var B9_AutomationPart				fShaftPart;
var class<B9_AutomationPart>		fShaftPartClass;

var B9_AutomationPart				fGunPart;
var class<B9_AutomationPart>		fGunPartClass;

var Vector							fFireStart[2];
var Vector							fCameraOffset;

var float							fRateOfFire;
var byte							fNumberOfBarrels;
var byte							fBarrelToUse;




simulated function vector GetTargetLocation()
{
	if( fGunPart != None )
	{
		return fGunPart.Location;
	}
	return Location;
}

//////////////////////////////////////////////////
// Creation
//


simulated function PostBeginPlay()
{
	local vector StartPos, X, Y, Z;
	local vector startPosOffset;
	
    Super.PostBeginPlay();

	// Create the parts of the turret
	//

	SetCollision( false, false, false );
	
	if( fShaftPartClass != none )
	{
		fShaftPart = spawn( fShaftPartClass, self );
		if( fShaftPart == none )
		{
			log("SentryGun: Failed to create fShaftPart, class: " $fShaftPartClass $" self: " $Self $"startpos: " $StartPos );
		}

		AttachToBone( fShaftPart, 'shaftsocket' );
		fShaftPart.fParent = self;
		fShaftPart.SetCollision( false, false, false );
	}
	else
	{
		log("SentryGun: No fShaftPartClass" );
	}
	
	if( fGunPartClass != none )
	{
		fGunPart = spawn( fGunPartClass, self );
		if( fGunPart == none )
		{
			log("SentryGun: Failed to create fGunPart");
		}

		fShaftPart.AttachToBone( fGunPart, 'gunsocket' );
		fGunPart.fParent = self;
		fGunPart.SetCollision( true, false, true );
	}

	if (fShaftPart != None)
		fShaftPart.SetCollision( true, false, true );
	SetCollision( true, false, true );
}


event Destroyed()
{
	if( fShaftPart != none )
	{
		fShaftPart.Destroy();
		fShaftPart = none;
	}

	if( fGunPart != none )
	{
		fGunPart.Destroy();
		fGunPart = none;
	}

	Super.Destroyed();
}

//////////////////////////////////////////////////
// Movement 
//

// AFSNOTE: this works but sorta sucks: a bad rotation for the ceiling mounted turrets will result 
// in a turret with poor accuracy.  It would be better to auto-correct rotation based on the turrets actual rotaion.
// This would require some work, but would result in a turret placable anywhere, in any orientation with predictable 
// (correct) accuracy.
//
simulated function Orient( rotator r, optional float Delta )
{
	OrientV( vector(r), Delta );
}

simulated function OrientV( vector v, optional float Delta )
{
	local rotator newRot;
	local rotator partRot;
	local rotator curRot, deltaRot;
	local int deltaAmount;

	newRot = rotator(v << Rotation);
	if (Delta != 0.0f)
	{
		curRot.Yaw = fShaftPart.RelativeRotation.Yaw;
		curRot.Pitch = fGunPart.RelativeRotation.Pitch;
		deltaRot = newRot - curRot;

		while (true)
		{
			if (deltaRot.Yaw > 32768)
				deltaRot.Yaw -= 65536;
			else if (deltaRot.Yaw < -32768)
				deltaRot.Yaw += 65536;
			else break;
		}

		deltaAmount = RotationRate.Yaw * Delta;
		if (deltaAmount == 0) deltaAmount = 1; 
		if (Abs(deltaRot.Yaw) > deltaAmount)
			deltaRot.Yaw = deltaAmount * (deltaRot.Yaw / Abs(deltaRot.Yaw));

		deltaAmount = RotationRate.Pitch * Delta;
		if (deltaAmount == 0) deltaAmount = 1; 
		if (Abs(deltaRot.Pitch) > deltaAmount)
			deltaRot.Pitch = deltaAmount * (deltaRot.Pitch / Abs(deltaRot.Pitch));

		newRot = curRot + deltaRot;
	}

	// The Shaft can yaw
	partRot.Yaw		= newrot.Yaw;
	partRot.Pitch	= 0;
	partRot.Roll	= 0;
	fShaftPart.SetRelativeRotation( partRot );

	// The gun can yaw and pitch
	partRot.Yaw		= 0;
	partRot.Pitch	= newrot.Pitch;
	partRot.Roll	= 0;
	fGunPart.SetRelativeRotation( partRot );
}

simulated function RotateShaft( float yaw )
{
	local rotator shaftPartRot;

	shaftPartRot = fShaftPart.RelativeRotation;
	shaftPartRot.Yaw += yaw;
	fShaftPart.SetRelativeRotation(shaftPartRot);
}

//////////////////////////////////////////////////
// Firing logic
//

simulated function Fire( float value )
{}



//////////////////////////////////
// Initialization
//
defaultproperties
{
	fRateOfFire=1
	fNumberOfBarrels=1
	Physics=0
	CollisionRadius=1
	CollisionHeight=1
	bRotateToDesired=false
	RotationRate=(Pitch=4096,Yaw=20000,Roll=0)
}