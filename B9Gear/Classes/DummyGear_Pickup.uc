//=============================================================================
// DummyGear_Pickup
//=============================================================================
class DummyGear_Pickup extends Pickup;

#exec OBJ LOAD FILE=..\animations\B9Pickups_models.ukx PACKAGE=B9Pickups_models


defaultproperties
{
	InventoryType=Class'DummyGear'
	PickupMessage="You found a duffel bag."
	Mesh=SkeletalMesh'B9Pickups_models.Duffel_Bag'
	AmbientGlow=16
	CollisionHeight=14
}