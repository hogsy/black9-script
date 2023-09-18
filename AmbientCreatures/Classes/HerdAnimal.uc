class HerdAnimal extends AmbientCreature;

var HerdAnimal NextHerdAnimal;		// list of animals in this herd
var HerdAnimal PrevHerdAnimal;
var float HerdDist;
var HerdAnimal Child;
var HerdAnimal Parent;

function Destroyed()
{
	Super.Destroyed();

	if ( PrevHerdAnimal != None )
	{
		PrevHerdAnimal.NextHerdAnimal = NextHerdAnimal;
		if ( NextHerdAnimal != None )
			NextHerdAnimal.PrevHerdAnimal = PrevHerdAnimal;
	}
	if ( Child != None )
	{
		Child.Parent = Parent;
		Parent.Child = Child;
	}
}		

function PawnDied(Pawn P)
{
	Super.PawnDied(P);
	HerdLeader().WarnHerd(Enemy);
}

function Possess(Pawn aPawn)
{
	Local Controller C;
	Local HerdAnimal Best;
	local int NumKids, NumMoms, NumDads;

	Super.Possess(aPawn);

	// add self to herd
	for ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( (C != self) && (HerdAnimal(C) != None)
			&& (C.Pawn != None)
			&& (C.Pawn.Tag == Pawn.Tag) )
		{
			if ( AmbientPawn(C.Pawn).IsFemale() )
				NumMoms++;
			else if ( AmbientPawn(C.Pawn).IsInfant() )
				NumKids++;
			else 
				NumDads++;
			if ( (Best == None) || (VSize(C.Pawn.Location - Pawn.Location) < HerdDist) )
			{
				Best = HerdAnimal(C);
				HerdDist = VSize(Best.Pawn.Location - Pawn.Location);
			}
		}

	if ( Best != None )
	{
		PrevHerdAnimal = Best;
		NextHerdAnimal = PrevHerdAnimal.NextHerdAnimal;
		PrevHerdAnimal.NextHerdAnimal = self;
	}

	// scale pawn randomly
	if ( Pawn.DrawScale == Pawn.Default.DrawScale )
	{
		AmbientPawn(Pawn).PickSize(NumKids, NumMoms, NumDads);
		if ( AmbientPawn(Pawn).IsInfant() )
			HerdLeader().FindMomFor(self);
	}
}

event bool NotifyHitWall(vector HitNormal, actor Wall)
{
	// get pawn moving along wall
	Pawn.Velocity = Pawn.Velocity + HitNormal * (HitNormal Dot Pawn.Velocity);
	Pawn.Acceleration = Pawn.AccelRate * Normal(Pawn.Velocity);
	Destination = Pawn.Location + 6 * Pawn.GroundSpeed * Pawn.Acceleration;
	FocalPoint = Destination;
	return true;
}

event bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
{
	Pawn.Velocity = vect(0,0,0);
	Pawn.Acceleration = -1 * Pawn.Acceleration;
	Destination = Pawn.Location + 6 * Pawn.GroundSpeed * Pawn.Acceleration;
	FocalPoint = Destination;
	return false;
}

function HerdAnimal HerdLeader()
{
	local HerdAnimal L;

	L = self;

	While ( L.PrevHerdAnimal != None )
	{
		L = L.PrevHerdAnimal;
	}

	return L;
}

function FindMomFor(HerdAnimal Infant)
{
	local HerdAnimal H, Best;
	local Float Dist, BestDist;

	H = self;

	while ( H != None )
	{
		if ( AmbientPawn(H.Pawn).IsFemale() )
		{
			Dist = VSize(H.Pawn.Location - Infant.Pawn.Location);
			if ( H.Child != None )
				Dist += 1000;
			if ( (Best == None) || (Dist < BestDist) )
			{
				BestDist = Dist;
				Best = H;
			}
		}
		H = H.NextHerdAnimal;
	}

	if ( Best == None )
		return;

	// add to child list

	H = Best;

	While ( H.Child != None )
		H = H.Child;

	H.Child = Infant;
	Infant.Parent = H;
}

function WarnHerd(Pawn Other)
{
	local HerdAnimal H;

	H = self;

	while ( H != None )
	{
		H.Stampede(Other);
		H = H.NextHerdAnimal;
	}
}

function Stampede(Pawn Other)
{
	Enemy = Other;
	GotoState('Stampeding');
}

function FollowParent()
{
	if ( AmbientPawn(Pawn).AnimIsInGroup(0,'Walking') )
		GotoState('Grazing','Moving');
	else
		GotoState('Grazing','StartMoving');

	if ( Child != None )
		Child.FollowParent();
}

auto state grazing
{
	ignores SeePlayer, Bump;

	function Trigger( actor Other, pawn EventInstigator )
	{
		if ( EventInstigator != None )
			HerdLeader().WarnHerd(EventInstigator);
	}

	function damageAttitudeTo(pawn Other, float Damage)
	{
		if ( (Other.Controller != None) && (AmbientCreature(Other.Controller) == None) )
		{
			// warn herd
			HerdLeader().WarnHerd(Other);
		}
	}

	function Wander()
	{
		local vector Dir;
		local float dist;

		// wander, but not too far from neighbor
		Dir = VRand();
		if ( PrevHerdAnimal != None )
		{
			Dist = VSize(PrevHerdAnimal.Pawn.Location - Pawn.Location);
			if ( Parent != None )
			{
				if ( Parent.Pawn.Acceleration != vect(0,0,0) )
					Dir = Parent.Pawn.Acceleration + 0.2 * Normal(Parent.Pawn.Location - Pawn.Location);
				else if ( Dist > 30 * Pawn.CollisionRadius )
					Dir = Normal(Parent.Pawn.Location - Pawn.Location);
				else if ( Dist > 10 * Pawn.CollisionRadius )
					Dir += Normal(Parent.Pawn.Location - Pawn.Location);
			}
			else if ( Dist > HerdDist + 40 * Pawn.CollisionRadius )
				Dir = Normal(PrevHerdAnimal.Pawn.Location - Pawn.Location);
			else if ( Dist > 2 * HerdDist )
				Dir += Normal(PrevHerdAnimal.Pawn.Location - Pawn.Location);
		}
		Dir.Z = 0;
		Dir = Normal(Dir);
		Pawn.Acceleration = Pawn.AccelRate * Dir;
		Destination = Pawn.Location + 6 * Pawn.GroundSpeed * Pawn.Acceleration;
		FocalPoint = Destination;

		if ( Child != None )
			Child.FollowParent();
	}
		
	function bool NotifyLanded(vector HitNormal)
	{
		if ( Pawn.Acceleration == vect(0,0,0) )
			Pawn.SetPhysics(PHYS_None);
		return false;
	}

	event HearNoise(float Loudness, Actor NoiseMaker)
	{
		if ( (Loudness >= 1.0) && (AmbientPawn(NoiseMaker.Instigator) == None) )
			damageAttitudeTo(NoiseMaker.Instigator, 0);
	}

	event bool NotifyBump(Actor Other)
	{
		local vector Dir;
		
		Dir = Other.Location - Pawn.Location;
		Dir.Z = 0;
		Dir = Normal(Dir);
		Dir = Pawn.Acceleration - Dir * (Pawn.Acceleration Dot Dir);
		Pawn.Acceleration = Pawn.AccelRate * Normal(Dir);
		Destination = Pawn.Location + 6 * Pawn.GroundSpeed * Pawn.Acceleration;
		FocalPoint = Destination;

		if ( (Dir Dot Normal(Pawn.Velocity)) > 0.9 )
			GotoState('Grazing', 'StopWalking');
		else
			Disable('NotifyBump');	
		return false;
	}

	function BeginState()
	{
		Disable('NotifyBump');
		if ( (PrevHerdAnimal != None) && (FRand() > 0.2) )
			Disable('HearNoise');
	}
Begin:
	Pawn.DesiredSpeed = 0.25;
Graze:
	if ( FRand() < 0.3 )
		AmbientPawn(Pawn).PlayCall();
	if ( FRand() < 0.25 )
	{
StartMoving:
Moving:
		Enable('NotifyBump');
		Pawn.SetPhysics(PHYS_Walking);
		Wander();
		Sleep(2+4*FRand());
		FinishAnim();
		Disable('NotifyBump');
		Pawn.Acceleration = vect(0,0,0);
		Pawn.Velocity = vect(0,0,0);
	}
HangOut:
	WaitForLanding();
	Pawn.SetPhysics(PHYS_None);
	Sleep(3+5*FRand());
	Goto('Graze');

StopWalking:
	Disable('NotifyBump');
	Pawn.Acceleration = vect(0,0,0);
	Pawn.Velocity = vect(0,0,0);
	Goto('HangOut');
}

// run away from enemies
// disappear when no longer visible for a while
state stampeding
{
	ignores Trigger, SeePlayer, Bump, HearNoise;

	function Stampede(Pawn Other)
	{
	}

	function PickDestination()
	{
		// pick acceleration and focalpoint
		// combination of stay close to neighbor, run away from enemy, and some randomness
		local vector Dir;

		// stampede, but not too far from neighbor
		Dir = Normal(Pawn.Location - Enemy.Location) + 0.2 * VRand();
		if ( (PrevHerdAnimal != None)
			&& (VSize(PrevHerdAnimal.Pawn.Location - Pawn.Location) > 2 * HerdDist) )
			Dir += 0.7 * Normal(PrevHerdAnimal.Pawn.Location - Pawn.Location);
		Dir.Z = 0;
		Dir = Normal(Dir);
		Pawn.Acceleration = Pawn.AccelRate * Dir;
		Destination = Pawn.Location + 6 * Pawn.GroundSpeed * Pawn.Acceleration;
		FocalPoint = Destination;
	}

	event bool NotifyHitWall(vector HitNormal, actor Wall)
	{
		if ( Level.TimeSeconds - Pawn.LastRenderTime > 3 )
			GotoState('Stampeding','WipeOut');
		else
			return Super.NotifyHitWall(HitNormal, Wall);
		return true;
	}

Begin:
	Sleep(0.3 * FRand());
	Pawn.SetAnimStatus('Alert');
	Pawn.SetPhysics(PHYS_Walking);
	Sleep(FRand());
	Pawn.DesiredSpeed = 1.0;
KeepRunning:
	if ( FRand() < 0.5 )
		AmbientPawn(Pawn).PlayCall();
	PickDestination();
	Sleep(2 + 2 * FRand());
	if ( Level.TimeSeconds - Pawn.LastRenderTime > 5 )
		Pawn.Destroy();
	Goto('KeepRunning');
WipeOut:
	Pawn.Destroy();
}

