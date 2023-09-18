/*=============================================================================

 // MigratingBirds
 // Controller for single or groups of flying creatures
 // - migrating (one or group)= state migrating - spawn to side/above
=============================================================================*/
class MigratingBirds extends Birds;

var bool bWing;
var bool bUneven;
var int WingOffset;

auto State Migrating
{
	function vector InitialLocation(vector CurrentLocation)
	{
		local vector LookDir, WingDir;
		local int CurrentOffset;

		CurrentOffset = WingOffset;
		if ( !bUneven )
			bWing = !bWing;
		LookDir = Vector(Pawn.Rotation);
		WingDir = Normal(LookDir cross vect(0,0,1));

		if ( bUneven )
			Wingoffset++;
		else if ( bWing )
		{
			WingDir *= -1;
			WingOffset++;
		}
		else
		{
			bUneven = (FRand() < 0.25);
			if ( bUneven )
				WingOffset++;
		}
		return ( Pawn.Location + CurrentOffset * (WingDir * 8 * Pawn.CollisionRadius - LookDir * 8 * Pawn.CollisionRadius) );
	}

	function vector PickDestination(TransientAmbientPawn P)
	{
		if ( FRand() < 0.5 )
			Bird(P).PlayCall();
		P.LoopAnim('Flight');
		P.Acceleration = Normal(Destination - P.Location);
		P.Velocity = P.AirSpeed * P.Acceleration;
		P.Acceleration *= P.AccelRate;
		return Destination;
	}

	function PickSlaveDestination(TransientAmbientPawn P)
	{
		if ( FRand() < 0.5 )
			Bird(P).PlayCall();
		Bird(P).GlideOrFly(Destination);

		P.AirSpeed = P.Default.AirSpeed;
		P.Acceleration = Pawn.Acceleration;
		P.SleepTime = 2 + 2 * FRand();
		P.DesiredRotation = Rotator(P.Acceleration);
	}

	function float MaxHiddenTime()
	{
		return ( 5 + 5 * FRand() );
	}

	function BeginState()
	{
		local actor HitActor;
		local vector HitLocation, HitNormal, LookDir, OffDir, NewPos;
		local TransientAmbientPawn P;

		// pick direction
		LookDir = vector(MyManager.LocalPlayer.Rotation);
		OffDir = Normal(LookDir cross vect(0,0,1));
		if ( (OffDir dot (Pawn.Location - MyManager.LocalPlayer.ViewTarget.Location)) > 0 )
			OffDir *= -1;

		// move pawn to acceptable position for initial state
		// first up
		NewPos = Pawn.Location + (1 + 2 * FRand()) * vect(0,0,1000);
		HitActor = Trace(HitLocation, HitNormal, NewPos + Pawn.CollisionHeight * vect(0,0,1), Pawn.Location, false);
		if ( HitActor != None )
			NewPos = HitLocation - Pawn.CollisionHeight * vect(0,0,1);

		// now back
		HitActor = Trace(HitLocation, HitNormal, NewPos - 1000 * Offdir, NewPos, false);
		if ( HitActor != None )
			NewPos = HitLocation + Pawn.CollisionRadius * Offdir;
		else
			NewPos = NewPos - 1000 * Offdir;

		Pawn.SetLocation(NewPos);
		OffDir = Normal(OffDir + (FRand() - 0.4) * LookDir);
		Pawn.SetRotation(Rotator(OffDir));
		// Pick Destination
		Destination = Pawn.Location + 50000 * Offdir;
		FocalPoint = Destination;
		PickDestination(TransientAmbientPawn(Pawn));
		if ( NumSlaves > 0 )
			AddSlaves(TransientAmbientPawn(Pawn),NumSlaves);

		P = TransientAmbientPawn(Pawn);

		While ( P != None )
		{
			Bird(P).bDestroyIfHitWall = true;
			P.Velocity = Pawn.Velocity;
			P.Acceleration = Pawn.Acceleration;
			P = P.NextSlave;
		}
	}

Begin:
	Sleep(2 + 2 * FRand());
	PickDestination(TransientAmbientPawn(Pawn));
	Goto('Begin');
}

defaultproperties
{
	bWing=true
	WingOffset=1
	MinFlockSize=5
	MaxFlockSize=20
	PawnTypes[0]=Class'Bird'
	PawnTypes[1]=Class'SmallBird'
	PawnTypes[2]=Class'Bird'
}