//=============================================================================
// B9_DepotTrigger
//=============================================================================
class B9_DepotTrigger extends UseTrigger;

var(DepotTrigger) int ResourceAmount;
var int CurrentAmount;
var int Basis;

event PostBeginPlay()
{
	CurrentAmount = ResourceAmount;
}

function int GetKind()
{
	return Basis;
}

function Touch( Actor Other )
{
	//Log( "B9_DepotTrigger.Touch:"$Other );
	if ( IsRelevant( Other ) )
	{
		Other.Trigger(self, Other.Instigator);

		if( (Message != "") && (Other.Instigator != None) )
			// Send a string message to the toucher.
			Other.Instigator.ClientMessage( Message );
	}
}

//
// When something untouches the trigger.
//
function UnTouch( actor Other )
{
	//Log( "B9_DepotTrigger.UnTouch:"$Other );
	if( IsRelevant( Other ) )
		Other.Untrigger(self, Other.Instigator);
}

//
// See whether the other actor is relevant to this trigger.
//
function bool IsRelevant( actor Other )
{
	return (Pawn(Other) != None) && Pawn(Other).IsPlayerPawn();
}

//
// Savepoint awareness
//
event SerializeSavepointData(Actor saver, byte yourDead)
{
	saver.SavepointVariable(self, "CurrentAmount");
}

defaultproperties
{
	SavepointAwareness=3
}