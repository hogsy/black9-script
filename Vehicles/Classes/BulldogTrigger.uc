class BulldogTrigger extends ScriptedSequence
	notplaceable;

var float BTReTriggerDelay;
var	float TriggerTime;
var bool  bCarFlipTrigger;

function Touch( Actor Other )
{
	local WarfarePawn User;

	if( Other.Instigator != None )
	{
		User = WarfarePawn(Other);

		if(User == None)
			return;

		if ( BTReTriggerDelay > 0 )
		{
			if ( Level.TimeSeconds - TriggerTime < BTReTriggerDelay )
				return;
			TriggerTime = Level.TimeSeconds;
		}

		// Send a string message to the toucher.
		if(!bCarFlipTrigger)
			User.ReceiveLocalizedMessage(class'Vehicles.BulldogMessage', 0);
		else
			User.ReceiveLocalizedMessage(class'Vehicles.BulldogMessage', 3);
	}
}

function UsedBy( Pawn user )
{
	if(bCarFlipTrigger)
	{
		Bulldog(Owner).StartFlip(User);
	}
	else
	{
		// Enter vehicle code
		Bulldog(Owner).TryToDrive(User);
	}
}

defaultproperties
{
	BTReTriggerDelay=0.1
	bStatic=false
	bOnlyAffectPawns=true
	RemoteRole=0
	bHardAttach=true
	bCollideWhenPlacing=false
	CollisionRadius=80
	CollisionHeight=400
}