/*=============================================================================

 // CirclingBirds
 // - circling (one or group) = state circle - spawn only out front & distant
 // - hunting (one) = state hunting, with prey
=============================================================================*/
class CirclingBirds extends Birds;

auto State Circling
{
	function vector PickDestination(TransientAmbientPawn P)
	{
		local vector Dest;
		local Bird B;

		B = Bird(P);
		if ( FRand() < 0.3 )
			B.PlayCall();
		if ( B.bDirection )
			B.Angle -= 1.0484; //2*3.1415/6;	
		else
			B.Angle += 1.0484; //2*3.1415/6;	
		Dest.X = Location.X - B.CircleRadius * Sin(B.Angle);
		Dest.Y = Location.Y + B.CircleRadius * Cos(B.Angle);
		Dest.Z = Location.Z + 80 * FRand() - 40 + B.HeightOffset;
		Destination = Dest;
		B.GlideOrFly(Dest);
		B.SleepTime = VSize(Dest - B.Location)/B.AirSpeed;
		return Dest;
	}

	function PickSlaveDestination(TransientAmbientPawn P)
	{
		local vector Dest;

		Dest = PickDestination(P);
		P.Acceleration = P.AccelRate * Normal(Dest - P.Location);
		P.DesiredRotation = Rotator(P.Acceleration);
	}

	function float MaxHiddenTime()
	{
		return ( 15 + 5 * FRand() );
	}

	function BeginState()
	{
		local actor HitActor;
		local vector HitLocation, HitNormal, NewPos;


		// move pawn to acceptable position for initial state
		// first up
		NewPos = Pawn.Location + (0.6 + 2 * FRand()) * vect(0,0,1000);
		HitActor = Trace(HitLocation, HitNormal, NewPos + Pawn.CollisionHeight * vect(0,0,1), Pawn.Location, false);
		if ( HitActor != None )
			NewPos = HitLocation - Pawn.CollisionHeight * vect(0,0,1);

		SetLocation(NewPos);
		Pawn.SetLocation(NewPos);
		Destination = PickDestination(TransientAmbientPawn(Pawn));
		FocalPoint = Destination;
		if ( NumSlaves > 0 )
			AddSlaves(TransientAmbientPawn(Pawn),NumSlaves);
	}

	// FIXME - single circling birds sometimes switch to hunting
Begin:
	Sleep(TransientAmbientPawn(Pawn).SleepTime);
	Destination = PickDestination(TransientAmbientPawn(Pawn));
	FocalPoint = Destination;
	Goto('Begin');
}

defaultproperties
{
	MaxFlockSize=3
	PawnTypes=Class'Bird'
}