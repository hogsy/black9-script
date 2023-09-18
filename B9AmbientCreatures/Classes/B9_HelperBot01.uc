//===============================================================================
//  [B9_HelperBot01] 
//===============================================================================

class B9_HelperBot01 extends B9_AmbientCreature;

#exec OBJ LOAD FILE=..\animations\B9AmbientCreatures_models.ukx PACKAGE=B9AmbientCreatures_models

#exec AUDIO IMPORT FILE="Sounds\Flappy\injurc1a.WAV" NAME="B9_HelperBot01call1" GROUP="B9_HelperBot01"
#exec AUDIO IMPORT FILE="Sounds\Flappy\injurc2.WAV" NAME="B9_HelperBot01call2" GROUP="B9_HelperBot01"
#exec AUDIO IMPORT FILE="Sounds\Flappy\walknc.WAV" NAME="B9_HelperBot01foot" GROUP="B9_HelperBot01"


//#exec ANIM NOTIFY ANIM=B9_HelperBot01Anims SEQ=run TIME=0.25 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=B9_HelperBot01Anims SEQ=run TIME=0.75 FUNCTION=PlayFootStep

/*
var StampedeDust MyDust;
*/

function Destroyed()
{
	Super.Destroyed();
	/*
	if ( MyDust != None )
		MyDust.Destroy();
	*/
}

function PlayFootStep(int Side)
{
	local vector NewLoc;

	PlaySound(sound'B9_HelperBot01foot', SLOT_Interact, 4, false, 1000.0, 1.0);
	NewLoc = Location - vect(0,0,0.8) * CollisionHeight;

	/*
	if ( MyDust == None )
		MyDust = Spawn(class'StampedeDust',,,NewLoc);
	else
	{
		MyDust.LifeSpan = 4.0;
		MyDust.SetLocation(NewLoc);
	}
	MyDust.EMStartVelocity = vect(0,0,140) - 0.5 * Velocity;
	*/
}

function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	PlayAnim('death1',, 0.1);
}

function bool IsWalking()
{
	return false; //(AnimSequence == "Walk");
}
		
function PlayMoving()
{
	if ( bIsWalking )
	{
		LoopAnim('Walk', 1.2/DrawScale);
	}
	else
	{
		LoopAnim('Run', 1.2/DrawScale);
	}
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
			PlayAnim('Idle', rate, 0.4);
		if ( FRand() < 0.2 )
			PlayAnim('look', 0.8 * rate, 0.4);
		else if ( FRand() < 0.65 )
			PlayAnim('Hula', rate, 0.4);
		
		else
			PlayAnim('Idle', rate, 0.4);
	}
	else
		LoopAnim(AnimSequence, rate);
*/
}
/*	
function TweenToFighter(float tweentime)
{
	PlayAnim('look', 0.6 + 0.3 * FRand(), tweentime);
}

function TweenToWaiting(float tweentime)
{
	TweenAnim('Idle', tweentime);
}

function TweenToRunning(float tweentime)
{
	TweenToWalking(tweentime);
}

function TweenToWalking(float tweentime)
{
	TweenAnim('Walk',tweentime);
}
*/

defaultproperties
{
	PawnName="Maintenance Bot"
	GroundSpeed=800
	ControllerClass=Class'AmbientCreatures.HerdAnimal'
	Physics=4
	Mesh=SkeletalMesh'B9AmbientCreatures_models.HelperBot'
	CollisionRadius=64
	CollisionHeight=96
}