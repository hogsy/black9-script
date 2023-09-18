/*=============================================================================

 //EscortBugs
 //Controller for groups of little crawling critters 
=============================================================================*/
class EscortBugs extends Bugs;

function SetEscortSize(int N)
{
	NumSlaves = N;
}

function float MaxHiddenTime()
{
	return 3;
}

function vector PickDestination(TransientAmbientPawn P)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, Destination, LookDir;

	LookDir = vector(MyManager.LocalPlayer.Rotation);
	if ( MyManager.InSpawnRange() )
	{
		// fly around player
		if ( (MyManager.LocalPlayer.ViewTarget.Location - P.Location) Dot LookDir > 300 )
		{
			// spawn in front
			Destination.X = 400 * FRand() - 200;
			Destination.Y = 400 * FRand() - 200;
			Destination.Z = 0;
			Destination = Destination + MyManager.LocalPlayer.ViewTarget.Location + 850 * LookDir + vect(0,0,100);
			HitActor = Trace(HitLocation, HitNormal, Destination, MyManager.LocalPlayer.Viewtarget.Location, false);
			if ( HitActor != None )
			{
				Destination = HitLocation;
				if ( VSize(  MyManager.LocalPlayer.Viewtarget.Location - Destination) < 500 )
					Destination = HitLocation + vect(0,0,300);
			} 
			P.SetLocation(Destination);
		}
		Destination = MyManager.LocalPlayer.ViewTarget.Location + 400 * VRand() + MyManager.LocalPlayer.ViewTarget.Velocity;
	}
	else
	{
		// fly behind player so can be destroyed
		Destination = MyManager.LocalPlayer.ViewTarget.Location - 400 * LookDir;
	}
	Destination.Z = 0.5 * (Destination.Z + P.Location.Z);

	HitActor = Trace(HitLocation, HitNormal, Destination, P.Location, false);
	if ( HitActor != None )
		Destination = HitLocation;

	HitActor = Trace(HitLocation, HitNormal, Destination - vect(0,0,100), Destination, false);
	if ( HitActor == None )
		Destination = Destination - vect(0,0,50);

	P.Acceleration = P.AccelRate * Normal(Destination - P.Location);
	P.DesiredRotation = Rotator(P.Acceleration);
	return Destination;
}	

// bugs start behind player
function vector InitialLocation(vector CurrentLocation)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, Dest, NewStart;
	
	Dest = MyManager.LocalPlayer.ViewTarget.Location;
	Dest = Dest + 120 * (VRand() - 1.1 * vector(MyManager.LocalPlayer.Rotation));

	NewStart = CurrentLocation + vect(0,0,50);
	HitActor = Trace(HitLocation, HitNormal, NewStart, CurrentLocation, false);
	if ( HitActor != None )
		NewStart = HitLocation;

	HitActor = Trace(HitLocation, HitNormal, Dest, NewStart, false);
	if ( HitActor != None )
		Dest = HitLocation;

	HitActor = Trace(HitLocation, HitNormal, Dest - vect(0,0,300), Dest, false);
	if ( HitActor == None )
		Dest = CurrentLocation;
	else
		Dest = HitLocation;

	return Dest;
}

function PickSlaveDestination(TransientAmbientPawn P)
{
	PickDestination(P);
}

function Possess(Pawn aPawn)
{
	aPawn.PossessedBy(self);
	Pawn = aPawn;
}

defaultproperties
{
	PawnTypes=Class'FlyingBug'
}