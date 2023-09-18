//=============================================================================
// CollisionMesh
//=============================================================================

class CollisionMesh extends Actor;

function Bump( actor Other )
{
	if ( Owner != None )
	{
		Owner.Bump( Other );
	}
}

defaultproperties
{
	Physics=8
	DrawType=8
	CollisionRadius=1
	CollisionHeight=1
	bCollideActors=true
	bBlockActors=true
	bBlockPlayers=true
}