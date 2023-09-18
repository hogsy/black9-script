//=============================================================================
// NightScope_Pickup.uc
//
// Night vision goggles
//
//=============================================================================


class NightScope_Pickup extends Pickup;



defaultproperties
{
	InventoryType=Class'NightScope'
	PickupMessage="Acquired Nightscope"
	Mesh=SkeletalMesh'B9Items_models.NVgoggles_mesh'
	CollisionRadius=5
	CollisionHeight=5
}