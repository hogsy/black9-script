/*=============================================================================

 AmbientCreatureManager

 The AmbientCreatureManager is responsible for spawning creatures at appropriate 
 locations and managing their creation and destruction based on whether players
 can see them, system performance, and whether combat has started.

 Big ambient creatures (herds, big predators and herbivores) are placed by the LD and
 managed separately

=============================================================================*/
class AmbientCreatureManager extends Info
	abstract
	placeable;

#exec Texture Import File=..\engine\Textures\Ambientcreatures.pcx Name=S_AmbCreature Mips=Off MASKED=1

var TransientAmbientCreature MyCreatures;					// Ambient creature list
var int NumCreatures;										// Number of creatures controlled
var() int MaxCreatures;
var() class<TransientAmbientCreature> TransientCreatures[8];	// allowable TransientAmbientCreature classes
var int NumClasses;											// number of TransientAmbientCreature classes (determined in postbeginplay)
var PlayerController LocalPlayer;
var() int SpawnRadius;										// radius of area to spawn creatures
var() int TriggerRadius;									// radius of area to be triggered by player
var TransientAmbientCreature Prey;	// last spawned creature - could be prey for next spawn

function PostBeginPlay()
{
	local int i;

	log(self$" starting up!!!");
	Super.PostBeginPlay();

	if (Level.NetMode == NM_DedicatedServer )
	{
		Destroy();
		return;
	}

	For ( i=0; i<ArrayCount(TransientCreatures); i++ )
		if ( TransientCreatures[NumClasses] != None )
			NumClasses++;

	SetTimer(1.0,true);
}

function TransientAmbientCreature AddCreature(Class<TransientAmbientCreature> SpawnClass, vector SpawnLoc)
{
	local TransientAmbientCreature A;

	A = spawn(SpawnClass,self,,SpawnLoc+SpawnClass.Default.CollisionHeight*vect(0,0,1));

	if ( (A != None) && A.bDeleteMe )
		A = A.Replacement;
	if ( (A != None) && !A.bDeleteMe )
	{
		A.NextCreature = MyCreatures;
		MyCreatures = A;
		NumCreatures++;
		return A;
	}				
	return none;
}

function RemoveCreature(TransientAmbientCreature Remove)
{
	local TransientAmbientCreature A;

	// check if A is in my list
	if ( Remove == MyCreatures )
		MyCreatures = Remove.NextCreature;
	else
	{
		for ( A=MyCreatures; A!=None; A=A.NextCreature )
			if ( A.NextCreature == Remove )
			{
				A.NextCreature = Remove.NextCreature;
				break;
			}
	}

	NumCreatures--;
}

function bool InSpawnRange()
{
	return ( VSize(Location - LocalPlayer.Location) < SpawnRadius  );
}

// check if should spawn or destroy temporary ambient creatures
function Timer()
{
	local TransientAmbientCreature A;
	local Controller C;
	local class<TransientAmbientCreature> SpawnClass;
	local float Dist;
	local vector SpawnLoc, SpawnDir;

	// make sure I know who my player is
	if ( LocalPlayer == None )
	{
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
			if ( C.IsA('PlayerController')
				&& (Viewport(PlayerController(C).Player) != None) )
			{
				LocalPlayer = PlayerController(C);
				break;
			}
	}
	
	for ( A=MyCreatures; A!=None; A=A.NextCreature )
		if ( Level.TimeSeconds - A.Pawn.LastRenderTime > 1 )
			A.NotVisible(); // after a few seconds, destroy

	// Add transient creature
	// Note - pawns will also inform me when they die, so I can spawn appropriate carrion feeders (after a little while)
	// and herd animals will ask for bugs
	// only add optional creatures if frame rate is high enough and there aren't too many
	// FIXME - add more initially, reduce maxcreatures if combat (how do you determine that?)
	//log("Almost add creature, last render "$Region.Zone.LastRenderTime$" for "$Region.Zone);
	if ( Level.bDropDetail || (NumCreatures >= MaxCreatures) 
		|| (Level.TimeSeconds - Region.Zone.LastRenderTime > 0.5)
		|| (VSize(LocalPlayer.ViewTarget.Location - Location) > TriggerRadius) )
	{
		return;
	}

	// maybe wait a bit
	if ( VSize(LocalPlayer.ViewTarget.Velocity) < 200 )
	{
		if ( FRand() < 0.5 )
			return;
	}

	// pick what type of creature to spawn
	SpawnClass = TransientCreatures[Rand(NumClasses)];
	// add new creatures? - either beyond fog dist (if close) or far enough to be not visible (bugs)
	// or just off screen with AI to come on screen
	// bugs are added to their group one at a time
	// find a spot to spawn the creature 
	//log("try to spawn a "$SpawnClass);
	
	// pick spawn location
	Dist = SpawnClass.Default.MinSpawnDist + FRand() * (SpawnClass.Default.MaxSpawnDist - SpawnClass.Default.MinSpawnDist);
	SpawnDir = vector(LocalPlayer.Rotation);
	SpawnDir.Z = 0;
	SpawnLoc = LocalPlayer.ViewTarget.Location + Dist * Normal(SpawnDir);

	// make sure spawnlocation is within SpawnRadius
	if ( VSize(SpawnLoc - Location) > SpawnRadius )
		SpawnLoc = Location + SpawnRadius * Normal(SpawnLoc - Location);

	// check if now too close to player
	Dist = VSize(LocalPlayer.ViewTarget.Location - SpawnLoc);
	if ( Dist < SpawnClass.Default.MinSpawnDist )
		return;

	SpawnLoc = SpawnClass.Static.FindSpawnLocation(Dist,SpawnDir,LocalPlayer);
	//log("try to spawn a "$SpawnClass$" at "$SpawnLoc);
	if ( SpawnLoc == vect(0,0,0) )
		return;

	Prey = AddCreature(SpawnClass, SpawnLoc);
	if ( (Prey != None) 
		&& (FRand() < 0.3) 
		&& (Prey.PredatorType != None) 
		&& (Prey.PredatorType.Default.MinSpawnDist < Dist) )
	{
		// sometimes spawn predator in conjunction with prey
		A = AddCreature(Prey.PredatorType, SpawnLoc);
	}
	Prey = None;
}

defaultproperties
{
	MaxCreatures=10
	SpawnRadius=6000
	TriggerRadius=8000
	Texture=Texture'S_AmbCreature'
}