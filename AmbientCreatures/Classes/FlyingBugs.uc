/*=============================================================================

 //FlyingBugs
 //Controller for groups of little crawling critters 
=============================================================================*/
class FlyingBugs extends Bugs;

function vector PickDestination(TransientAmbientPawn P)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, Destination;

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
	if ( FRand() < SwarmTightness )
		P.Acceleration = P.AccelRate * Normal(Pawn.Location - P.Location);
	else if ( FRand() < 0.5 )
		P.Acceleration = P.AccelRate * VRand();
	else
		P.Acceleration = P.AccelRate * Normal(P.Velocity);
	P.DesiredRotation = Rotator(P.Acceleration);
}

defaultproperties
{
	PawnTypes=Class'FlyingBug'
}