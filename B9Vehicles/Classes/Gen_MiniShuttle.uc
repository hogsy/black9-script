//===============================================================================
//  [Gen_MiniShuttle] 
//===============================================================================

class Gen_MiniShuttle extends B9_Decoration;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('static');
}

defaultproperties
{
	bStatic=false
	Mesh=SkeletalMesh'B9Vehicles_models.genesis_mini_shuttle'
	CollisionRadius=30
	CollisionHeight=75
	bCollideActors=true
	bCollideWorld=true
	bBlockActors=true
	bBlockPlayers=true
}