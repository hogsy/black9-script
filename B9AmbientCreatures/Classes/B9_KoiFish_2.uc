class B9_KoiFish_2 extends B9_AmbientCreature;

#exec OBJ LOAD FILE=..\animations\B9AmbientCreatures_models.ukx PACKAGE=B9AmbientCreatures_models

var float AirTime;

function Landed(vector HitNormal)
{
	local rotator newRotation;

	newRotation = Rotation;
	newRotation.Pitch = 0;
	newRotation.Roll = 16384;
	SetRotation(newRotation);
	GotoState('Flopping');
}

/*
function PreSetMovement()
{
	bCanSwim = true;
	if ( PhysicsVolume.bWaterVolume )
		SetPhysics(PHYS_Swimming);
	else
		SetPhysics(PHYS_Falling);
}

function PhysicsVolumeChange( PhysicsVolume NewVolume )
{
	local float splashSize;
	local actor splash;

	if ( NewVolume.bWaterVolume )
		AirTime = 0;
	else if (Physics != PHYS_Falling)
		SetPhysics(PHYS_Falling);
}
*/

function Destroyed()
{
	Super.Destroyed();
	/*
	if ( MyDust != None )
		MyDust.Destroy();
	*/
}

function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	PlayAnim('death1',, 0.1);
}

function bool IsWalking()
{
	return false; //(AnimSequence == "Swim");
}
		
function PlayMoving()
{
	LoopAnim('Swim');
}


function PlayLanded(float impactVel)
{
	Super.PlayLanded(impactVel);
	PlayMoving();
}

function PlayWaiting()
{
/*
	local float rate;

	rate = 0.5 + 0.5 * FRand();
	if ( (FRand() < 0.4) || !AnimIsInGroup(0,'Idle') )
	{
		if ( AnimSequence == "look" )
			PlayAnim('idle');
		else if ( FRand() < 0.2 )
			PlayAnim('idle');
		else if ( FRand() < 0.65 )
			PlayAnim('idle');
		
		else
			PlayAnim('idle');
	}
	else
		LoopAnim(AnimSequence);
*/
}
	

defaultproperties
{
	PawnName="Koi"
	bCanSwim=true
	GroundSpeed=1600
	WaterSpeed=1600
	ControllerClass=Class'AmbientCreatures.HerdAnimal'
	Physics=3
	Mesh=SkeletalMesh'B9AmbientCreatures_models.KoiFish2'
	CollisionRadius=64
	CollisionHeight=96
}