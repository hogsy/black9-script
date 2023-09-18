//===============================================================================
//  [B9_DustBot] 
//===============================================================================

class B9_DustBot extends B9_AmbientCreature;

#exec OBJ LOAD FILE=..\animations\B9AmbientCreatures_models.ukx PACKAGE=B9AmbientCreatures_models

#exec AUDIO IMPORT FILE="Sounds\Flappy\injurc1a.WAV" NAME="B9_DustBotcall1" GROUP="B9_DustBot"
#exec AUDIO IMPORT FILE="Sounds\Flappy\injurc2.WAV" NAME="B9_DustBotcall2" GROUP="B9_DustBot"
#exec AUDIO IMPORT FILE="Sounds\Flappy\walknc.WAV" NAME="B9_DustBotfoot" GROUP="B9_DustBot"


//#exec ANIM NOTIFY ANIM=B9_DustBotAnims SEQ=run TIME=0.25 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=B9_DustBotAnims SEQ=run TIME=0.75 FUNCTION=PlayFootStep

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

	PlaySound(sound'B9_DustBotfoot', SLOT_Interact, 4, false, 1000.0, 1.0);
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
	local name curAnim;
	local float frame, rate;

	GetAnimParams(0,curAnim,frame,rate);

	return (curAnim == 'Walk');
}
		
function PlayMoving()
{
	LoopAnim('walk_forward', 1.2/DrawScale);
}

function PlayLanded(float impactVel)
{
	Super.PlayLanded(impactVel);
	PlayMoving();
}

function PlayWaiting()
{
	local name curAnim;
	local float frame, rate;

	GetAnimParams(0,curAnim,frame,rate);

	rate = 0.5 + 0.5 * FRand();
	if ( (FRand() < 0.4) || !AnimIsInGroup(0,'Idle') )
	{
		if ( curAnim == 'look' )
			PlayAnim('Idle', rate, 0.8);
		if ( FRand() < 0.2 )
			PlayAnim('idle', rate, 1.2);
		else if ( FRand() < 0.65 )
			PlayAnim('idle', rate, 1.5);
		
		else
			PlayAnim('idle', rate, 1);
	}
	else
		LoopAnim(curAnim, rate);
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
	PawnName="Custodial Bot"
	bCrawler=true
	GroundSpeed=400
	ControllerClass=Class'AmbientCreatures.HerdAnimal'
	Mesh=SkeletalMesh'B9AmbientCreatures_models.DustBot'
	CollisionRadius=64
	CollisionHeight=30
}