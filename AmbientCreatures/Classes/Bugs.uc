/*=============================================================================

 //Bugs
 //Controller for groups of little critters (flying, crawling, and/or swimming)

=============================================================================*/
class Bugs extends TransientAmbientCreature
	abstract;

var float SwarmTightness;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Pawn == None )
		return;
	SetSwarmTightness();
	SetTimer(2, false);
}

function SetSwarmTightness()
{
	SwarmTightness = 0.3 + 0.9 * FRand();
}

function float GetSwarmTightness()
{
	return SwarmTightness;
}

function float MaxHiddenTime()
{
	return ( 5 + 5 * FRand() );
}

function Possess(Pawn aPawn)
{
	aPawn.PossessedBy(self);
	Pawn = aPawn;
	AmbientSound = Pawn.AmbientSound;
	Pawn.DesiredSpeed = 0.5;

	if ( TransientAmbientPawn(Pawn).bCrawler && (CollisionHeight > 0) )
	{
		SetCollisionSize(0,0);
		SetLocation(Location - Default.CollisionHeight * vect(0,0,1));
		Pawn.SetCollisionSize(0,0);
	}
	else
		Pawn.SetCollisionSize(CollisionRadius,CollisionHeight);

	Pawn.SetLocation(Location);
}

function Timer()
{
	SetSwarmTightness();
	SetTimer(2 + 12 * FRand(), false);
	return;
}

defaultproperties
{
	SwarmTightness=0.8
	PredatorType=Class'WanderingBirds'
	bOffCameraSpawns=false
	NumSlaves=19
	SoundRadius=32
	SoundVolume=32
	CollisionRadius=50
	CollisionHeight=20
	bCollideWorld=true
}