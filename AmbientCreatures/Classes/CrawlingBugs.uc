/*=============================================================================

 //CrawlingBugs
 //Controller for groups of little crawling critters 
=============================================================================*/
class CrawlingBugs extends Bugs;

function vector InitialLocation(vector CurrentLocation)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, Dest, NewStart;
	
	Dest = Location;
	Dest.X += 200 * FRand() - 100;
	Dest.Y += 200 * FRand() - 100;

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

function Scatter(TransientAmbientPawn P)
{
	if ( VSize(MyManager.LocalPlayer.ViewTarget.Location - P.Location) < 100 )
		P.Acceleration = P.AccelRate * Normal(P.Location - MyManager.LocalPlayer.ViewTarget.Location);
	if ( P.NextSlave != None )
		Scatter(CrawlingBug(P.NextSlave));
}

function vector PickDestination(TransientAmbientPawn P)
{
	local vector Dest;

	if ( VSize(MyManager.LocalPlayer.ViewTarget.Location - P.Location) < 100 )
	{
		Dest = Normal(P.Location - MyManager.LocalPlayer.ViewTarget.Location);
		Dest.Z = 0;
		Dest = P.Location + 100 * Dest;
		if ( P.NextSlave != None )
			Scatter(CrawlingBug(P.NextSlave));
	}
	else
		Dest = InitialLocation(P.Location);

	P.Velocity = Normal( Dest - P.Location);
	P.Velocity.Z = -0.7;
	P.Acceleration = P.AccelRate * P.Velocity;
	P.DesiredRotation = Rotator(P.Velocity);

	return Dest;
}		

function PickSlaveDestination(TransientAmbientPawn P)
{
	if ( VSize(MyManager.LocalPlayer.ViewTarget.Location - P.Location) < 100 )
		P.Acceleration = P.AccelRate * Normal(P.Location - MyManager.LocalPlayer.ViewTarget.Location);
	else if ( FRand() < 0.8 * SwarmTightness )
		P.Acceleration = P.AccelRate * Normal(Pawn.Location - P.Location);
	else if ( FRand() < 0.5 )
		P.Acceleration = P.AccelRate * VRand();
	else
		P.Acceleration = P.AccelRate * Normal(P.Velocity);

	P.DesiredRotation = Rotator(P.Acceleration);
	P.Acceleration.Z = -0.7 * P.AccelRate;
}

defaultproperties
{
	PawnTypes=Class'CrawlingBug'
}