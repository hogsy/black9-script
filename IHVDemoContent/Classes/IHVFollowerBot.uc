class IHVFollowerBot extends AIController;

var Pawn Leader;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	ForEach DynamicActors(class'Pawn',Leader)
		break;
}

auto State Wandering
{
Begin:
	Sleep(0.2);
Start:
	WaitForLanding();
	if ( Leader != None )
		RouteGoal = Leader.Controller.RouteGoal;
	if ( RouteGoal == None )
		warn(self$" no RouteGoal");
	else
	{
Moving:	
		MoveTarget = FindPathToward(RouteGoal);
		MoveToward(MoveTarget);
		if ( MoveTarget == RouteGoal )
			Goto('Start');
		Goto('Moving');
	}
}

defaultproperties
{
	bIsPlayer=true
}