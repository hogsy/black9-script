//===============================================================================
//  [B9_AssassinBodyTest] 
//===============================================================================

class B9_AssassinBodyTest extends B9_AmbientCreature;

#exec OBJ LOAD FILE=..\animations\B9AmbientCreatures_models.ukx PACKAGE=B9AmbientCreatures_models

#exec AUDIO IMPORT FILE="Sounds\Flappy\injurc1a.WAV" NAME="B9_AssassinBodyTestcall1" GROUP="B9_AssassinBodyTest"
#exec AUDIO IMPORT FILE="Sounds\Flappy\injurc2.WAV" NAME="B9_AssassinBodyTestcall2" GROUP="B9_AssassinBodyTest"
#exec AUDIO IMPORT FILE="Sounds\Flappy\walknc.WAV" NAME="B9_AssassinBodyTestfoot" GROUP="B9_AssassinBodyTest"

//#exec ANIM NOTIFY ANIM=B9_AssassinBodyTestAnims SEQ=run TIME=0.25 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=B9_AssassinBodyTestAnims SEQ=run TIME=0.75 FUNCTION=PlayFootStep

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

function PlayFootStep()
{
	local vector NewLoc;

	PlaySound(sound'B9_AssassinBodyTestfoot', SLOT_Interact, 4, false, 1000.0, 1.0);
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
	PlayAnim('nowpn_death_slump',, 0.1);
}

function bool IsWalking()
{
	local name curAnim;
	local float frame, rate;

	GetAnimParams(0,curAnim,frame,rate);

	return (curAnim == 'nowpn_walk_forward');

	Log( "IsWalking()" );
}
		
function PlayMoving()
{
	if ( bIsWalking )
	{
		LoopAnim('nowpn_walk_forward', 1.2/DrawScale);
	}
	else
	{
		LoopAnim('nowpn_run_forward', 1.2/DrawScale);
	}

	Log( "PlayMoving()" );
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
		{
			PlayAnim('nowpn_walk_idle_3', rate, 0.8);
		}
		if ( FRand() < 0.2 )
		{
			PlayAnim('nowpn_walk_idle_5', rate, 1.2);
		}
		else if ( FRand() < 0.65 )
		{
			PlayAnim('nowpn_walk_idle_6', rate, 1.5);
		}		
		else
		{
			PlayAnim('nowpn_walk_idle_1', rate, 1);
		}
	}
	else
	{
		LoopAnim(curAnim, rate);
	}		
}
/*	
function TweenToFighter(float tweentime)
{
	PlayAnim('nowpn_walk_idle_7', 0.6 + 0.3 * FRand(), tweentime);
}

function TweenToWaiting(float tweentime)
{
	TweenAnim('nowpn_walk_idle_1', tweentime);
}

function TweenToRunning(float tweentime)
{
	TweenToWalking(tweentime);
}

function TweenToWalking(float tweentime)
{
	TweenAnim('nowpn_walk_forward',tweentime);
}
*/

defaultproperties
{
	PawnName="Medium-res Test Body"
	GroundSpeed=700
	ControllerClass=Class'AmbientCreatures.HerdAnimal'
	Mesh=SkeletalMesh'B9AmbientCreatures_models.assassin_body_test'
}