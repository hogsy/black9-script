//===============================================================================
//  [B9_ScrubberBot] 
//===============================================================================

class B9_ScrubberBot extends B9_AmbientCreature;

#exec OBJ LOAD FILE=..\animations\B9AmbientCreatures_models.ukx PACKAGE=B9AmbientCreatures_models

#exec AUDIO IMPORT FILE="Sounds\Flappy\injurc1a.WAV" NAME="B9_ScrubberBotcall1" GROUP="B9_ScrubberBot"
#exec AUDIO IMPORT FILE="Sounds\Flappy\injurc2.WAV" NAME="B9_ScrubberBotcall2" GROUP="B9_ScrubberBot"
#exec AUDIO IMPORT FILE="Sounds\Flappy\walknc.WAV" NAME="B9_ScrubberBotfoot" GROUP="B9_ScrubberBot"


//#exec ANIM NOTIFY ANIM=B9_ScrubberBotAnims SEQ=run TIME=0.25 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=B9_ScrubberBotAnims SEQ=run TIME=0.75 FUNCTION=PlayFootStep

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

	PlaySound(sound'B9_ScrubberBotfoot', SLOT_Interact, 4, false, 1000.0, 1.0);
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

	return (curAnim == 'Scrub');
}
		
function PlayMoving()
{
	LoopAnim('Scrub');
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
			PlayAnim('Scrub');
		else if ( FRand() < 0.2 )
			PlayAnim('Scrub');
		else if ( FRand() < 0.65 )
			PlayAnim('Scrub');
		
		else
			PlayAnim('Scrub');
	}
	else
		LoopAnim(curAnim);

}
	

defaultproperties
{
	PawnName="Scrubber Bot"
	bCrawler=true
	GroundSpeed=800
	ControllerClass=Class'AmbientCreatures.HerdAnimal'
	Physics=9
	Mesh=SkeletalMesh'B9AmbientCreatures_models.ScrubberBot'
	CollisionRadius=64
	CollisionHeight=96
}