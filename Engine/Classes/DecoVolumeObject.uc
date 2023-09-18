//=============================================================================
// DecoVolumeObject.
//
// A class that allows staticmesh actors to get spawned inside of
// deco volumes.  These are the actors that you actually see in the level.
//=============================================================================
class DecoVolumeObject extends Actor
	native;

defaultproperties
{
	DrawType=8
	CollisionRadius=0
	CollisionHeight=0
}