/*=============================================================================

 //Birds
 //Controller for single or groups of flying creatures
 // modes
 // wandering implemented in base class as a fall back behavior
 // - circling (one or group) = state circle - spawn only out front & distant
 // - swooping (one or group) = state wandering - spawn only out front
 // - hunting (one) = state hunting, with prey
=============================================================================*/
class Birds extends TransientAmbientCreature
	abstract;

var int MinFlockSize;	// number of slave birds
var int MaxFlockSize;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Pawn == None )
		return;

	NumSlaves = MinFlockSize + Rand(MaxFlockSize-MinFlockSize);
}

auto State Wandering
{
	function vector PickDestination(TransientAmbientPawn P)
	{
		local vector Dest;
		local Bird B;

		if ( P.bDestroySoon && (P.LastRenderTime > 1) )
		{
			Dest = P.Location;
			P.Destroy();
			return Dest;
		}
		B = Bird(P);
		if ( FRand() < 0.5 )
			B.PlayCall();
		Dest = Location + vect(0,0,100) + FRand() * B.CircleRadius * VRand();
		if ( VSize(MyManager.LocalPlayer.Pawn.Location - B.Location) < FlockRadius )
			Dest.Z = FMax(Dest.Z,Location.Z) + 300;
		if ( Location.Z - Dest.Z > 200 )
			Dest.Z = Location.Z;
		B.GlideOrFly(Dest);

		return Dest;
	}

	function PickSlaveDestination(TransientAmbientPawn P)
	{
		local vector Dest;

		Dest = PickDestination(P);
		
		if ( P.bDeleteMe )
			return;		

		P.Acceleration = P.AccelRate * Normal(Dest - P.Location);
		P.SleepTime = VSize(Dest - P.Location)/P.AirSpeed;
		P.DesiredRotation = Rotator(P.Acceleration);
	}

	function BeginState()
	{
		if ( NumSlaves > 0 )
			AddSlaves(TransientAmbientPawn(Pawn),NumSlaves);
	}
}

defaultproperties
{
	MinSpawnDist=1500
	MaxSpawnDist=15000
	SoundRadius=32
	SoundVolume=32
	CollisionRadius=80
	CollisionHeight=60
	bCollideWorld=true
}