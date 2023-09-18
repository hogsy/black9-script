//===============================================================================
//  [B9_AngryDustBot] 
//===============================================================================

class B9_AngryDustBot extends B9_Pawn;

#exec OBJ LOAD FILE=..\animations\B9AmbientCreatures_models PACKAGE=B9AmbientCreatures_models

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
	bCrawler=true
	GroundSpeed=100
	MenuName="Custodial Bot"
	ControllerClass=Class'B9_MonsterControllerNoGun'
	CollisionRadius=64
	CollisionHeight=48
}