//=============================
// Jumppad - bounces players/bots up
// not directly placeable.  Make a subclass with appropriate sound effect etc.
//
class JumpPad extends NavigationPoint
	native;

var vector JumpVelocity;
var Actor JumpTarget;
var() float JumpZModifier;	// for tweaking Jump, if needed
var() sound JumpSound;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function PostBeginPlay()
{
	local NavigationPoint N;
	
	Super.PostBeginPlay();
	ForEach AllActors(class'NavigationPoint', N)
		if ( (N != self) && NearSpot(N.Location) )
			N.ExtraCost += 1000;
}

event Touch(Actor Other)
{
	if ( Pawn(Other) == None )
		return;

	PendingTouch = Other.PendingTouch;
	Other.PendingTouch = self;
}

event PostTouch(Actor Other)
{
	local Pawn P;

	P = Pawn(Other);
	if ( P == None )
		return;

	if ( AIController(P.Controller) != None )
	{
		P.Controller.Movetarget = JumpTarget;
		P.Controller.Focus = JumpTarget;
		if ( P.Physics != PHYS_Flying )
			P.Controller.MoveTimer = 2.0;
		P.DestinationOffset = JumpTarget.CollisionRadius;
	}
	if ( P.Physics == PHYS_Walking )
		P.SetPhysics(PHYS_Falling);
	P.Velocity =  JumpVelocity;
	P.Acceleration = vect(0,0,0);
	if ( JumpSound != None )
		P.PlaySound(JumpSound);
}

defaultproperties
{
	JumpVelocity=(X=0,Y=0,Z=1200)
	JumpZModifier=1
	bDestinationOnly=true
	bCollideActors=true
}