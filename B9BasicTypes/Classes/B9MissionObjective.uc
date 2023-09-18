//=============================================================================
// B9MissionObjective.uc
//
// Placeable Object
//
// Triggered mission objective.
//
//=============================================================================


class B9MissionObjective extends B9MissionGoals
		placeable;


var(MissionObjective) public localized string	Description;
var(MissionObjective) public int				Priority;
var(MissionObjective) public name				WaypointTag;

var public B9MissionWaypoint					fWaypoint;

var bool	fActive;
var bool	fComplete;


function Trigger( Actor Other, Pawn EventInstigator )
{
	local B9_BasicPlayerPawn			P;
	local B9Trigger_ObjectiveAssign		trgAssign;
	local B9Trigger_ObjectiveComplete	trgComplete;

	if( !fActive )
	{
		trgAssign = B9Trigger_ObjectiveAssign( Other );
		if( trgAssign != None )
		{
			P = B9_BasicPlayerPawn( EventInstigator );
			if( P != None )
			{
				FindWaypoint();
				fActive = true;
				P.AddMissionObjective( Self );
			}
		}
	}

	else if( fActive && !fComplete )
	{
		trgComplete = B9Trigger_ObjectiveComplete( Other );
		if( trgComplete != None )
		{
			fActive		= false;
			fComplete	= true;

			P = B9_BasicPlayerPawn( EventInstigator );
			if( P != None )
			{
				P.CompleteMissionObjective( Self );
			}
		}
	}
}


simulated function FindWaypoint()
{
	local B9MissionWaypoint waypoint;

	if( WaypointTag != '' && WaypointTag != 'None' )
	{
		ForEach AllActors( class'B9MissionWaypoint', waypoint, WaypointTag )
		{
			fWaypoint = waypoint;
			return;
		}
	}
}

simulated function vector GetWaypointLocation()
{
	if( fWaypoint != None )
	{
		return fWaypoint.Location;
	}
	else
	{
		return vect(0,0,0);
	}
}

simulated function bool HasWaypoint()
{
	return( fWaypoint != None );
}


defaultproperties
{
	bHidden=true
}