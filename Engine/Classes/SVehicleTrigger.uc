class SVehicleTrigger extends AIScript
	notplaceable;

function UsedBy( Pawn user )
{
	// Enter vehicle code
	SVehicle(Owner).TryToDrive(User);
}

defaultproperties
{
	bStatic=false
	bHidden=false
	bOnlyAffectPawns=true
	RemoteRole=0
	bHardAttach=true
	CollisionRadius=80
	CollisionHeight=400
}