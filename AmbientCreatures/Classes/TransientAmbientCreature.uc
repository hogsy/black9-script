/*=============================================================================

 //TransientAmbientCreature
 //The base class of controllers for ambient creatures which are created an destroyed
 //on the client as the player walks around (small stuff like bugs, birds, etc.)

=============================================================================*/
class TransientAmbientCreature extends AIController;

var AmbientCreatureManager MyManager;
var TransientAmbientCreature NextCreature;	// transient ambient creature list managed by AmbientCreatureManager
var class<Pawn> PawnTypes[8];			// pawns which can be controlled by this controller on land - pick one when spawning
var class<TransientAmbientCreature> PredatorType;	// who eats my pawns (optional)
var class<TransientAmbientCreature> AltPredatorType;	// who eats my pawns (optional)
var class<TransientAmbientCreature> UnderWaterType;	// who to replace me with underwater (optional)
var float MinSpawnDist;						// minimum distance for spawning in player's line of sight
var float MaxSpawnDist;						// maximum distance for spawning in player's line of sight
var bool  bOffCameraSpawns;					// if true, use off camera spawns
var bool  bUnderWaterCreatures;				// if true, my pawns are meant for underwater
var class<Pawn> PickedClass;
var TransientAmbientCreature Prey;			// if hunter, what I'm hunting
var float FlockRadius;				// radius in which to spawn slaves
var int NumSlaves;					// number of slave pawns
var TransientAmbientCreature Replacement;	// replacement if destroyed because of wrong zone


function PostBeginPlay()
{
	Super.PostBeginPlay();

	MyManager = AmbientCreatureManager(Owner);
	Prey = MyManager.Prey;

	// make sure in an appropriate zone
	if ( PhysicsVolume.bPainCausing )
	{
		Destroy();
		return;
	}
	if ( PhysicsVolume.bWaterVolume != bUnderWaterCreatures )
	{
		// try to replace me with underwater alternative
		if ( UnderWaterType != None )
			Replacement = spawn(UnderWaterType, Owner);

		Destroy();
		return;
	}

	AddPawn();
}

function AddSlaves(TransientAmbientPawn Last, int SpawnNum)
{
	while (SpawnNum > 0)
	{
		SpawnNum--;
		Last.NextSlave = SpawnSlave();
		if ( Last.NextSlave != None )
		{
			NumSlaves--;
			Last.NextSlave.Controller = self;
			Last = Last.NextSlave;
		}
	}
}

function TransientAmbientPawn SpawnSlave()
{
	local vector V, HitNormal, HitLocation;
	local actor HitActor;
	
	V = InitialLocation(Pawn.Location);
	// check trace
	HitActor = Trace(HitLocation, HitNormal, V, Pawn.Location, false);
	if ( HitActor != None )
		V = HitLocation - (2 + Pawn.CollisionRadius) * Normal(V - Pawn.Location);
	return TransientAmbientPawn(spawn(Pawn.Class,self,,V));
}

function vector InitialLocation(vector CurrentLocation)
{
	return (CurrentLocation + VRand() * FlockRadius);
}

function AddPawn()
{
	local int NumClasses;
	local Pawn P;

	// add an appropriate pawn
	// note that I've been spawned at ground level
	if ( PickedClass == None )
	{
		While ( NumClasses < ArrayCount(PawnTypes) )
		{
			if ( PawnTypes[NumClasses] != None )
				NumClasses++;
			else 
				break;
		}
		if ( NumClasses == 0 )
			return;
		PickedClass = PawnTypes[Rand(NumClasses)];
	}
	P =	Spawn(PickedClass,self,,Location + (PickedClass.Default.CollisionHeight + 2) * Vect(0,0,1), SpawnRotation()); 
	if ( P != None )
		Possess(P);
	if ( Pawn == None )
		Destroy();
	else
	{
		Pawn.LastRenderTime = Level.TimeSeconds;
		if ( NumSlaves > 0 )
			Pawn.SetTimer(0.2, true);
	}
}

function Rotator SpawnRotation()
{
	local Rotator SpawnRot;

	SpawnRot.Yaw = 2 * Rand(32767);
	return SpawnRot;
}

function Destroyed()
{
	if ( MyManager != None )
		MyManager.RemoveCreature(self);
	Super.Destroyed();
}

function NotVisible()
{
	if ( Pawn == None )
	{
		PawnDied(None);
		return;
	}
	TransientAmbientPawn(Pawn).VerifyLastRenderTime();
	if ( Level.TimeSeconds - Pawn.LastRenderTime > MaxHiddenTime() )
		TransientAmbientPawn(Pawn).DestroyAll();
}

function float MaxHiddenTime()
{
	return ( 10 + 5 * FRand() );
}

function SlavePawnDied(Pawn P)
{
	if ( P == Pawn )
		PawnDied(P);
}

function PawnDied(Pawn P)
{
	if ( TransientAmbientPawn(Pawn).NextSlave != None )
		Possess(TransientAmbientPawn(Pawn).NextSlave);
	else
		Destroy();
}

/* FindSpawnLocation()
Find a suitable spawn location for the ambient creature (far enough away from the player)
if none can be found, returns vect(0,0,0)
*/
static function vector FindSpawnLocation(float Dist, vector SpawnDir, PlayerController Viewer)
{
	local rotator SpawnRot;
	local actor HitActor;
	local vector HitLocation, HitNormal, SpawnLoc, StartLoc;
	// FIXME - some creatures may look for fixed spawn points (e.g. bat cave)

	// if off camera spawning, then modify spawndir
	// FIXME - don't always if beyond max visible distance (where thing is less than one pixel)
	if ( Default.bOffCameraSpawns && (!Viewer.Region.Zone.bDistanceFog || (Viewer.Region.Zone.DistanceFogEnd > Dist))  )
	{
		SpawnRot = Rotator(SpawnDir);
		if ( FRand() < 0.5 )
			SpawnRot.Yaw += Viewer.FOVAngle * 182; // 65536/360
		else
			SpawnRot.Yaw -= Viewer.FOVAngle * 182; // 65536/360

		SpawnDir = Vector(SpawnRot);
	}
	SpawnLoc = Viewer.ViewTarget.Location + Dist * SpawnDir; 
	// find ground
	HitActor = Viewer.Trace(HitLocation, HitNormal, SpawnLoc, Viewer.ViewTarget.Location + Viewer.ViewTarget.CollisionRadius * Vect(0,0,1), false);

	if ( HitActor == None )
		return FindGround(Viewer, SpawnLoc);

	//  OK - try to go over obstacle
	HitActor = Viewer.Trace(HitLocation, HitNormal, HitLocation - 50 * HitNormal, HitLocation, false);

	if ( HitActor != None )
	{
		// give up?
		if ( (HitNormal.Z < 0.8)
			|| (VSize(HitLocation - Viewer.ViewTarget.Location) < Default.MinSpawnDist) )
			return vect(0,0,0);

		return HitLocation;
	}

	// ok- go up
	StartLoc = HitLocation - 100 * HitNormal + vect(0,0,500);
	HitActor = Viewer.Trace(HitLocation, HitNormal, StartLoc, HitLocation - 100 * HitNormal, false);

	if ( HitActor != None )
		StartLoc = HitLocation;
	Dist = VSize(HitLocation - SpawnLoc);
	HitActor = Viewer.Trace(HitLocation, HitNormal, StartLoc + Dist * SpawnDir, StartLoc, false);
	
	if ( HitActor == None )
		return FindGround(Viewer, SpawnLoc);
	else if ( HitNormal.Z >= 0.8 )
		return HitLocation;		

	return vect(0,0,0);
}

static function vector FindGround(PlayerController Viewer, vector StartLoc)
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	// find ground
	HitActor = Viewer.Trace(HitLocation, HitNormal, StartLoc - vect(0,0,10000), StartLoc, false);
	if ( (HitActor == None) || (HitNormal.Z < 0.8) )
		return Vect(0,0,0); 

	return HitLocation;
}

function vector PickDestination(TransientAmbientPawn P)
{
	return Pawn.Location;
}

function PickSlaveDestination(TransientAmbientPawn P);

auto State Wandering
{
Begin:
	Destination = PickDestination(TransientAmbientPawn(Pawn));
	FocalPoint = Destination;
	Sleep(TransientAmbientPawn(Pawn).MoveTimeTo(Destination));
	if ( AmbientSound != None )
		SetLocation(Pawn.Location);
	Goto('Begin');
}
	
defaultproperties
{
	UnderWaterType=Class'FishSchool'
	MinSpawnDist=500
	MaxSpawnDist=3000
	bOffCameraSpawns=true
	FlockRadius=200
	RemoteRole=0
}