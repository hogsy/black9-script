//===============================================================================
//  [Flappy] 
//===============================================================================

class Flappy extends AmbientPawn;

#exec MESH  MODELIMPORT MESH=FlappyMesh MODELFILE=Models\Flappy.PSK LODSTYLE=10
#exec MESH  ORIGIN MESH=FlappyMesh X=0 Y=100 Z=0 YAW=192 PITCH=00 ROLL=64
#exec ANIM  IMPORT ANIM=FlappyAnims ANIMFILE=Models\Flappy.PSA COMPRESS=1 MAXKEYS=999999 IMPORTSEQS=1
#exec MESHMAP SCALE MESHMAP=FlappyMesh X=1.0 Y=1.0 Z=1.0
#exec ANIM  SEQUENCE ANIM=FlappyAnims SEQ=idle STARTFRAME=0 NUMFRAMES=37 RATE=30.0000 GROUP=Idle 
#exec ANIM  SEQUENCE ANIM=FlappyAnims SEQ=fighter STARTFRAME=0 NUMFRAMES=37 RATE=30.0000 GROUP=Idle 
#exec ANIM  SEQUENCE ANIM=FlappyAnims SEQ=walk STARTFRAME=37 NUMFRAMES=58 RATE=36.0000 GROUP=Walking 
#exec ANIM  SEQUENCE ANIM=FlappyAnims SEQ=dig STARTFRAME=95  NUMFRAMES=58 RATE=30.0000 GROUP=Idle 
#exec ANIM  SEQUENCE ANIM=FlappyAnims SEQ=run STARTFRAME=153 NUMFRAMES=29 RATE=36.0000 GROUP=None 
#exec ANIM  SEQUENCE ANIM=FlappyAnims SEQ=move STARTFRAME=182 NUMFRAMES=69 RATE=30.0000 GROUP=None 
#exec ANIM  SEQUENCE ANIM=FlappyAnims SEQ=look STARTFRAME=251 NUMFRAMES=61 RATE=24.0000 GROUP=Look
#exec ANIM  SEQUENCE ANIM=FlappyAnims SEQ=death1 STARTFRAME=312 NUMFRAMES=68 RATE=24.0000 GROUP=None
#exec MESH  DEFAULTANIM MESH=FlappyMesh ANIM=FlappyAnims

// Digest and compress the animation data. Must come after the sequence declarations.
// 'VERBOSE' gives more debugging info in UCC.log 
#exec ANIM DIGEST  ANIM=FlappyAnims VERBOSE

#exec OBJ LOAD FILE=..\textures\flappyskin.utx PACKAGE=FlappySkin
#EXEC MESHMAP SETTEXTURE MESHMAP=FlappyMesh NUM=0 TEXTURE=FlappySkin.FlappyFemale

#exec AUDIO IMPORT FILE="Sounds\flappy\injurc1a.WAV" NAME="flappycall1" GROUP="Flappy"
#exec AUDIO IMPORT FILE="Sounds\flappy\injurc2.WAV" NAME="flappycall2" GROUP="Flappy"
#exec AUDIO IMPORT FILE="Sounds\flappy\walknc.WAV" NAME="flappyfoot" GROUP="Flappy"


#exec ANIM NOTIFY ANIM=FlappyAnims SEQ=run TIME=0.25 FUNCTION=PlayFootStep
#exec ANIM NOTIFY ANIM=FlappyAnims SEQ=run TIME=0.75 FUNCTION=PlayFootStep

var StampedeDust MyDust;

function Destroyed()
{
	Super.Destroyed();
	if ( MyDust != None )
		MyDust.Destroy();
}

///////////////////////////////////
// MH,Taldren,
// 
//
function PlayFootStep( int Side )
//
// Mh, end changes
//////////////////////
{
	local vector NewLoc;

	PlaySound(sound'flappyfoot', SLOT_Interact, 4, false, 1000.0, 1.0);
	NewLoc = Location - vect(0,0,0.8) * CollisionHeight;

	if ( MyDust == None )
		MyDust = Spawn(class'StampedeDust',,,NewLoc);
	else
	{
		MyDust.LifeSpan = 4.0;
		MyDust.SetLocation(NewLoc);
	}
//	MyDust.EMStartVelocity = vect(0,0,140) - 0.5 * Velocity;
}

function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	PlayAnim('death1',, 0.1);
}

function PickSize(int NumKids, int NumMoms, int NumDads)
{
	if ( NumDads < (NumKids + NumMoms) * 0.167 )
		Skins[0] = texture'FlappySkin.FlappyMale';	// male
	else //if ( NumMoms <= 1.5 * NumKids )
		SetDrawScale(1.0);	// female
	//else
	//	SetDrawScale(0.6);	// infant

	SetCollisionSize(DrawScale * Default.CollisionRadius, DrawScale * Default.CollisionHeight);
}

function bool IsFemale()
{
	return ( DrawScale == 0.8 );
}

function bool IsInfant()
{
	return ( DrawScale == 0.6 );
}

function PlayCall()
{
	if ( FRand() < 0.5 )
		PlaySound(sound'flappycall1',,DrawScale,,, DrawScale);
	else
		PlaySound(sound'flappycall2',,DrawScale,,, DrawScale);
}
		
function PlayMoving()
{
	local name OldAnim;
	local float OldFrame,OldRate;

	GetAnimParams( 0, OldAnim, OldFrame, OldRate );

	if ( Physics == PHYS_Walking )
	{
		if ( bIsWalking )
		{
			if ( OldAnim != 'Walk' )
				LoopAnim('Walk', 1.2/DrawScale,0.1);
			else
				LoopAnim('Walk', 1.2/DrawScale);
		}
		else
		{
			if ( OldAnim != 'Run' )
				LoopAnim('Run', 1.2/DrawScale,0.1);
			else
				LoopAnim('Run', 1.2/DrawScale);
		}
	}
}

function PlayLanded(float impactVel)
{
	Super.PlayLanded(impactVel);
	TweenAnim('Walk',0.1);
}

function PlayWaiting()
{
	local float rate,frame,oldrate;
	local name Anim;

	rate = 0.5 + 0.5 * FRand();
	if ( (FRand() < 0.4) || !AnimIsInGroup(0,'Idle') )
	{
		if ( AnimIsInGroup(0,'look') )
			PlayAnim('Idle', rate, 0.4);
		else if ( FRand() < 0.2 )
			PlayAnim('look', 0.8 * rate, 0.4);
		else if ( FRand() < 0.65 )
			PlayAnim('Dig', rate, 0.4);
		
		else
			PlayAnim('Idle', rate, 0.4);
	}
	else if ( AnimIsInGroup(0,'Idle') )
	{
		GetAnimParams(0,Anim,frame,oldrate);
		LoopAnim(Anim, rate);
	}
	else
		PlayAnim('Idle',rate, 0.4);
}

defaultproperties
{
	bCrawler=true
	GroundSpeed=800
	ControllerClass=Class'HerdAnimal'
	Physics=2
	Mesh=SkeletalMesh'FlappyMesh'
	Skins=/* Array type was not detected. */
	CollisionRadius=64
	CollisionHeight=96
}