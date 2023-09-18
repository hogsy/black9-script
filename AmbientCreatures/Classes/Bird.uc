//=============================================================================
// Bird.
//=============================================================================
class Bird extends TransientAmbientPawn;

#exec MESH  MODELIMPORT MESH=SmallBird MODELFILE=Models\BatFish.PSK LODSTYLE=10
#exec MESH  ORIGIN MESH=SmallBird X=0 Y=195 Z=0 YAW=64 PITCH=0 ROLL=192
#exec ANIM  IMPORT ANIM=BirdAnims ANIMFILE=Models\BatFish.PSA COMPRESS=1 MAXKEYS=999999 IMPORTSEQS=1
#exec MESHMAP SCALE MESHMAP=SmallBird X=0.3 Y=0.3 Z=0.3
#exec ANIM  SEQUENCE ANIM=BirdAnims SEQ=glide STARTFRAME=0 NUMFRAMES=30 RATE=30.0000 GROUP=Idle 
#exec ANIM  SEQUENCE ANIM=BirdAnims SEQ=flight STARTFRAME=30 NUMFRAMES=31 RATE=30.0000 GROUP=Idle 
#exec ANIM  SEQUENCE ANIM=BirdAnims SEQ=dive STARTFRAME=61 NUMFRAMES=31 RATE=30.0000 GROUP=Idle 
#exec MESH  DEFAULTANIM MESH=SmallBird ANIM=BirdAnims

// Digest and compress the animation data. Must come after the sequence declarations.
// 'VERBOSE' gives more debugging info in UCC.log 
#exec ANIM DIGEST  ANIM=BirdAnims VERBOSE

#EXEC TEXTURE IMPORT NAME=BatFishTex1 FILE=Models\flyingfish2.dds GROUP=Skins
#EXEC MESHMAP SETTEXTURE MESHMAP=SmallBird NUM=0 TEXTURE=BatFishTex1

#exec AUDIO IMPORT FILE="Sounds\Bird\injur1a.WAV" NAME="injur1m" GROUP="Manta"
#exec AUDIO IMPORT FILE="Sounds\Bird\call1a.WAV" NAME="call1m" GROUP="Manta"
#exec AUDIO IMPORT FILE="Sounds\Bird\call2bd.WAV" NAME="call2b" GROUP="Bird"

var float Angle;			
var bool bDirection;
var bool bDestroyIfHitWall;
var float CircleRadius;
var float HeightOffset;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('Flight');
	CircleRadius = 400 + 500 * FRand();
	bDirection = ( FRand() < 0.5 );
	HeightOffset = 500 * FRand() - 200;
}

function GlideOrFly(vector Dest)
{
	if ( (Dest.Z > Location.Z + 5) || (FRand() < 0.5) )
		LoopAnim('Flight');
	else
		LoopAnim('Glide');
}

function PlayMoving()
{
	LoopAnim('Flight');
}

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Super.DisplayDebug(Canvas, YL, YPos);

	Canvas.SetDrawColor(255,255,255);
	Canvas.DrawText("Controller Location "$Controller.Location);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("Master Pawn "$(Controller.Pawn == self));
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

function float GetSleepTime()
{
	return SleepTime;
}

function PlayCall()
{
	PlaySound(sound'call2b',,0.5 + 0.5 * FRand(),,, 0.8 + 0.4 * FRand());
}

function HitWall(vector HitNormal, actor HitWall)
{
	Acceleration *= -1;
	DesiredRotation = Rotator(Acceleration);
	if ( bDestroyIfHitWall )
	{
		if ( LastRenderTime > 1 )
			Destroy();
		else
		{
			bDestroySoon = true;
			GotoState('Wandering');
		}
	}
}

State Dying
{
	ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	function BeginState()
	{
		PlaySound(sound'injur1m');
		if ( FRand() < 0.5 )
			TweenAnim('Dead1', 0.2);
		else
			TweenAnim('Dead2', 0.2);	
	}
}

defaultproperties
{
	CircleRadius=600
	AirSpeed=500
	AccelRate=800
	Health=1
	LandMovementState=PlayerFlying
	Physics=4
	Mesh=SkeletalMesh'SmallBird'
	CollisionRadius=28
	CollisionHeight=16
	bCollideActors=true
	bBlockActors=true
	bBlockPlayers=true
	bProjTarget=true
	RotationRate=(Pitch=12000,Yaw=20000,Roll=12000)
}