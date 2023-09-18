// B9_RandomEventProducer.uc

class B9_RandomEventProducer extends Actor
	placeable;

var(RandomEventProducer) array<name> RandomEvents;

function Trigger(Actor Other, Pawn Instigator)
{
	if (RandomEvents.Length > 0)
		TriggerEvent(RandomEvents[Rand(RandomEvents.Length)], Other, Instigator);
}

defaultproperties
{
	bHidden=true
}