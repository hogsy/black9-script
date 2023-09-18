// SavepointTrigger.uc

class SavepointTrigger extends Trigger;

var bool bInactive;
 
function Touch( actor Other )
{
	local PlayerController PC;
	
	Super.Touch(Other);
	if (!bCollideActors)
	{
		bInactive = true;
		if (Pawn(Other) != None)
		{
			PC = PlayerController(Pawn(Other).Controller);
			if (PC != None)
				PC.SavepointLevel(self);
		}
	}
}

event SerializeSavepointData(Actor saver, byte yourDead)
{
	saver.SavepointVariable(self, "bInactive");
}

event PostRestoreSavepointData()
{
	if (bInactive)
		SetCollision(false);
}

defaultproperties
{
	TriggerType=5
	bTriggerOnceOnly=true
	SavepointAwareness=3
}