//=============================================================================
// MedKit_Gear_Pickup
//=============================================================================
class MedKit_Gear_Pickup extends Pickup;

#exec OBJ LOAD FILE=..\animations\B9Pickups_models.ukx PACKAGE=B9Pickups_models


defaultproperties
{
	InventoryType=Class'MedKit_Gear'
	PickupMessage="Acquired MedKit."
	Mesh=SkeletalMesh'B9Items_models.MedKit_mesh'
	AmbientGlow=16
	CollisionHeight=14
}