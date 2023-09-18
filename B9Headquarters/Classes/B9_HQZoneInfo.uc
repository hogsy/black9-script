//=============================================================================
// B9_HQZoneInfo
//=============================================================================
class B9_HQZoneInfo extends ZoneInfo
	placeable;

var(HQZoneInfo) string CancelMessage;
var(HQZoneInfo) bool CheckOnExit;
var(HQZoneInfo) bool CheckMultipleOccupants;
var(HQZoneInfo) string EntryMessage;

var transient B9_PlayerPawn CurrentOccupant;

// When an actor enters this zone.
event ActorEntered( actor Other )
{
	local B9_HQListener L;

	if (B9_PlayerPawn(Other) != None)
	{
		Log( "Entered zone: " $ Other.Name $ " -> " $ ZoneTag );

		ForEach AllActors(class'B9_HQListener', L)
		{
			L.Trigger(self, Pawn(Other));
			break;
		}
	}
}

// When an actor leaves this zone.
event ActorLeaving( actor Other )
{
	local B9_HQListener L;

	if (B9_PlayerPawn(Other) != None)
	{
		Log( "Leaving zone: " $ Other.Name $ " -> " $ ZoneTag );

		ForEach AllActors(class'B9_HQListener', L)
		{
			L.Untrigger(self, Pawn(Other));
			break;
		}
	}
}

defaultproperties
{
	CancelMessage="Cancel purchases?"
	CheckOnExit=true
}