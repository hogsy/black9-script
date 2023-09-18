class DropShipLoadTrigger extends AIScript
	notplaceable;
/*
function Touch( actor Other )
{
	if ( (Pawn(Other) != None) && Pawn(Other).IsPlayerPawn() )
		Dropship(Owner).LoadPlayer(Pawn(Other));
}
*/

defaultproperties
{
	bStatic=false
	CollisionRadius=80
	CollisionHeight=30
	bCollideActors=true
}