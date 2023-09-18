/*=============================================================================

 //FishSchool
 //Controller for groups of little critters (flying, crawling, and/or swimming)

=============================================================================*/
class FishSchool extends TransientAmbientCreature
	abstract;

function vector InitialLocation(vector CurrentLocation)
{
	local vector R;

	R = VRand() * FlockRadius;
	if ( R.Z > 0 )
		R.Z = 0;
	return (CurrentLocation + R);
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

function vector PickDestination(TransientAmbientPawn P)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, Destination;

	if ( FRand() < 0.5 )
	{
		P.Acceleration = vect(0,0,0);
		Destination = P.Location;
		return Destination;
	}
	Destination = P.Location + VRand() * 400;
	Destination.Z = 0.5 * (Destination.Z + P.Location.Z);

	HitActor = Trace(HitLocation, HitNormal, Destination, P.Location, false);
	if ( HitActor != None )
		Destination = HitLocation;

	HitActor = Trace(HitLocation, HitNormal, Destination - vect(0,0,100), Destination, false);
	if ( HitActor == None )
		Destination = Destination - vect(0,0,50);

	P.DesiredRotation = Rotator(P.Velocity);
	return Destination;
}	

function PickSlaveDestination(TransientAmbientPawn P)
{
	local vector Dest;

	if ( !Pawn.PhysicsVolume.bWaterVolume )
		Dest = Pawn.Location;
	else
		Dest = Location;

	if ( FRand() < 0.5 )
		P.Acceleration = P.AccelRate * Normal(Dest - P.Location);
	else if ( FRand() < 0.5 )
	{
		P.Acceleration = vect(0,0,0);
		return;
	}
	P.DesiredRotation = Rotator(P.Acceleration);
}

defaultproperties
{
	PawnTypes=Class'BiterFish'
	bOffCameraSpawns=false
	bUnderWaterCreatures=true
	NumSlaves=19
	SoundRadius=32
	SoundVolume=32
	CollisionRadius=50
	CollisionHeight=40
	bCollideWorld=true
}