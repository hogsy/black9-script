//=============================================================================
// StaticMeshActor.
// An actor that is drawn using a static mesh(a mesh that never changes, and
// can be cached in video memory, resulting in a speed boost).
//=============================================================================

class StaticMeshActor extends Actor
	native
	placeable;

var() bool bExactProjectileCollision;		// nonzero extent projectiles should shrink to zero when hitting this actor

defaultproperties
{
	bExactProjectileCollision=true
	DrawType=8
	bStatic=true
	bWorldGeometry=true
	bShadowCast=true
	bStaticLighting=true
	CollisionRadius=1
	CollisionHeight=1
	bCollideActors=true
	bBlockActors=true
	bBlockPlayers=true
	bBlockKarma=true
	bEdShouldSnap=true
}