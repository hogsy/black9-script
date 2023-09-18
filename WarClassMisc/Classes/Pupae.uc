// Test class for spider physics

class Pupae extends Pawn;

#exec MESH IMPORT MESH=Pupae1 ANIVFILE=..\WarClassContent\MODELS\pupae_a.3D DATAFILE=..\WarClassContent\MODELS\pupae_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Pupae1 X=0 Y=0 Z=-90 YAW=64 PITCH=0 ROLL=-64

#exec MESH SEQUENCE MESH=pupae1 SEQ=All		 STARTFRAME=0	 NUMFRAMES=171
#exec MESH SEQUENCE MESH=pupae1 SEQ=Bite     STARTFRAME=0    NUMFRAMES=15  RATE=15  Group=Attack
#exec MESH SEQUENCE MESH=pupae1 SEQ=Crawl    STARTFRAME=15   NUMFRAMES=20  RATE=20	Group=Crawl
#exec MESH SEQUENCE MESH=pupae1 SEQ=Dead     STARTFRAME=35   NUMFRAMES=18  RATE=15
#exec MESH SEQUENCE MESH=pupae1 SEQ=TakeHit  STARTFRAME=36   NUMFRAMES=1
#exec MESH SEQUENCE MESH=pupae1 SEQ=Fighter  STARTFRAME=53   NUMFRAMES=6   RATE=6
#exec MESH SEQUENCE MESH=pupae1 SEQ=Lunge    STARTFRAME=59   NUMFRAMES=15  RATE=15  Group=Attack
#exec MESH SEQUENCE MESH=pupae1 SEQ=Munch    STARTFRAME=74   NUMFRAMES=8   RATE=15  Group=Waiting
#exec MESH SEQUENCE MESH=pupae1 SEQ=Pick     STARTFRAME=82   NUMFRAMES=10  RATE=15  Group=Waiting
#exec MESH SEQUENCE MESH=pupae1 SEQ=Stab     STARTFRAME=92   NUMFRAMES=10  RATE=15  Group=Attack
#exec MESH SEQUENCE MESH=pupae1 SEQ=Tear     STARTFRAME=102  NUMFRAMES=28  RATE=15  Group=Waiting
#exec MESH SEQUENCE MESH=pupae1 SEQ=Dead2    STARTFRAME=130  NUMFRAMES=18  RATE=15
#exec MESH SEQUENCE MESH=pupae1 SEQ=Dead3    STARTFRAME=148  NUMFRAMES=23  RATE=15

#exec TEXTURE IMPORT NAME=JPupae1 FILE=..\WarClassContent\MODELS\pupae.PCX GROUP=Skins 
#exec MESHMAP SCALE MESHMAP=pupae1 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=pupae1 NUM=1 TEXTURE=Jpupae1

#exec MESH NOTIFY MESH=Pupae1 SEQ=Dead TIME=0.52 FUNCTION=LandThump

#exec AUDIO IMPORT FILE="..\WarClassContent\Sounds\Pupae\scuttle1.WAV" NAME="scuttle1pp" GROUP="Pupae"
#exec AUDIO IMPORT FILE="..\WarClassContent\Sounds\Pupae\injur1.WAV" NAME="injur1pp" GROUP="Pupae"
#exec AUDIO IMPORT FILE="..\WarClassContent\Sounds\Pupae\injur2.WAV" NAME="injur2pp" GROUP="Pupae"
#exec AUDIO IMPORT FILE="..\WarClassContent\Sounds\Pupae\roam1.WAV" NAME="roam1pp" GROUP="Pupae"
#exec AUDIO IMPORT FILE="..\WarClassContent\Sounds\Pupae\hiss1.WAV" NAME="hiss1pp" GROUP="Pupae"
#exec AUDIO IMPORT FILE="..\WarClassContent\Sounds\Pupae\hiss2.WAV" NAME="hiss2pp" GROUP="Pupae"
#exec AUDIO IMPORT FILE="..\WarClassContent\Sounds\Pupae\hiss3.WAV" NAME="hiss3pp" GROUP="Pupae"
#exec AUDIO IMPORT FILE="..\WarClassContent\Sounds\Pupae\bite1pp.WAV" NAME="bite1pp" GROUP="Pupae"
#exec AUDIO IMPORT FILE="..\WarClassContent\Sounds\Pupae\tear1b.WAV" NAME="tear1pp" GROUP="Pupae"
#exec AUDIO IMPORT FILE="..\WarClassContent\Sounds\Pupae\munch1pp.WAV" NAME="munch1p" GROUP="Pupae"
#exec AUDIO IMPORT FILE="..\WarClassContent\Sounds\Pupae\death1b.WAV" NAME="death1pp" GROUP="Pupae"

var(Sounds) sound bite;
var(Sounds) sound stab;
var(Sounds) sound lunge;
var(Sounds) sound chew;
var(Sounds) sound tear;
var sound die;
 
//-----------------------------------------------------------------------------
// Pupae functions.

function JumpOffPawn()
{
	Super.JumpOffPawn();
	PlayAnim('crawl', 1.0, 0.2);
}

function SetMovementPhysics()
{
	if (Physics == PHYS_Falling)
		return;
	SetPhysics(PHYS_Spider); 
}

function PlayWaiting()
{
	local float decision;
	local float animspeed;
	local name NextAnim;

	animspeed = 0.4 + 0.6 * FRand(); 
	decision = FRand();
	if ( decision < 0.4 ) //pick first waiting animation
	{
		PlaySound(Chew, SLOT_Talk, 0.7,,80);
		NextAnim = 'Munch';
	}
	else if (decision < 0.55)
		NextAnim = 'Pick';
	else if (decision < 0.7)
	{
		PlaySound(Stab, SLOT_Talk, 0.7,,80);
		NextAnim = 'Stab';
	}
	else if (decision < 0.7)
		NextAnim = 'Bite';
	else 
		NextAnim = 'Tear';
		
	if ( !AnimIsInGroup(0,'Waiting') )
		LoopAnim(NextAnim, animspeed, 0.1);
	else
		LoopAnim(NextAnim, animspeed);
}

function PlayMoving()
{
	PlaySound(sound'scuttle1pp', SLOT_Interact);
	if ( !AnimIsInGroup(0,'Crawl') )
		LoopAnim('Crawl', -4.0/GroundSpeed,0.1);
	else
		LoopAnim('Crawl', -4.0/GroundSpeed);
}

function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	PlaySound(Die, SLOT_Talk, 3.5 * TransientSoundVolume);
	if ( FRand() < 0.35 )
		PlayAnim('Dead', 0.7, 0.1);
	else if ( FRand() < 0.5 )
		PlayAnim('Dead2', 0.7, 0.1);
	else
		PlayAnim('Dead3', 0.7, 0.1);
}

function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType)
{
	PlayAnim('TakeHit');
}

defaultproperties
{
	Bite=Sound'Pupae.bite1pp'
	Stab=Sound'Pupae.hiss1pp'
	Lunge=Sound'Pupae.hiss2pp'
	chew=Sound'Pupae.munch1p'
	Tear=Sound'Pupae.tear1pp'
	die=Sound'Pupae.death1pp'
	bCanStrafe=true
	Visibility=100
	GroundSpeed=260
	WaterSpeed=100
	JumpZ=340
	Health=65
	LandMovementState=PlayerSpidering
	WaterMovementState=PlayerSpidering
	Mesh=VertMesh'Pupae1'
	CollisionRadius=28
	CollisionHeight=9
	Mass=80
	RotationRate=(Pitch=3072,Yaw=65000,Roll=0)
}