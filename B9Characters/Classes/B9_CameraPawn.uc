//=============================================================================
// B9_CameraPawn
//
// CameraPawn Special 3rd person camera pawn
//
// 
//=============================================================================

class B9_CameraPawn extends B9_Pawn;


function PreSetMovement()
{
//	Super.PreSetMovement();

	bCanJump = false;
	bCanWalk = false;
	bCanSwim = true;
	bCanFly = true;
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	// Camera should not be damaged
}


defaultproperties
{
	fNoTargetLock=true
	bCanStrafe=true
	SightRadius=12000
	AirSpeed=800
	AccelRate=25
	MenuName="Black 9 Film Crew"
	ControllerClass=Class'B9_CameraController2'
	Physics=4
	bHidden=true
	CollisionRadius=8
	CollisionHeight=16
	bCollideActors=false
	bBlockActors=false
	bBlockPlayers=false
}