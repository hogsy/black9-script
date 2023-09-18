class IHVBot extends AIController;

auto State Wandering
{
Begin:
	WaitForLanding();
	RouteGoal = FindRandomDest();
	if ( RouteGoal == None )
		warn(self$" no RouteGoal");
	else
	{
Moving:	
		MoveTarget = FindPathToward(RouteGoal);
		if ( MoveTarget == None )
		{
			Acceleration = vect(0,0,0);
			Sleep(3);
			Goto('Begin');
		}
		else
		{
			MoveToward(MoveTarget);
			if ( MoveTarget == RouteGoal )
				Goto('Begin');
			Goto('Moving');
		}
	}
}

defaultproperties
{
	bIsPlayer=true
}