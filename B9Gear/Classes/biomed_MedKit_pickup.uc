//=============================================================================
// biomed_MedKit_pickup
//=============================================================================
class biomed_MedKit_pickup extends B9_AccumulativeItemPickup;

#exec OBJ LOAD FILE=..\animations\B9Pickups_models.ukx PACKAGE=B9Pickups_models


defaultproperties
{
	Amount=1
	InventoryType=Class'biomed_MedKit'
	PickupMessage="Acquired MedKit."
	Mesh=SkeletalMesh'B9Items_models.MedKit_mesh'
	AmbientGlow=16
	CollisionHeight=14
}