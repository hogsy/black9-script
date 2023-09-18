// ====================================================================
//  Class:  WarfareGame.TeamStartToggleTrigger
//
//  When touched, this trigger will transform all PlayerStarts with Tags
//  that match this event to the team of the player touching it.
//
//  Set the NavTag of this actor to the TAG of all PlayerStarts to be affected

// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class TeamStartToggleTrigger extends Triggers;

var() name NavTag;
var() localized string Message;

function Touch( Actor Other )
{
	local NavigationPoint N;
	local Pawn User;

	User=Pawn(Other);
	if (User==None)
		return;
	
	// Send a string message to the toucher.

	if ( (Message != "") && (Other.Instigator != None) )
		Other.Instigator.ClientMessage( Message );
		
	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
	{
		if ( (PlayerStart(N)!=None) && (N.Tag == NavTag) )
		{
			PlayerStart(N).TeamNumber = User.PlayerReplicationInfo.Team.TeamIndex; 
		}
	}

	// Trigger any events
	
	TriggerEvent(Event,self,User);
}

