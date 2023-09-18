//=============================================================================
// Wing_Pack_Pickup
//=============================================================================
class Wing_Pack_Pickup extends B9_Pickup;

#exec OBJ LOAD FILE=..\staticmeshes\B9_Vehicle_meshes.usx Package=B9_Vehicle_meshes




defaultproperties
{
	InventoryType=Class'Wing_Pack'
	PickupMessage="Acquired Wing Pack."
	DrawType=8
	StaticMesh=StaticMesh'B9_Vehicle_meshes.Wing_Pack.wingpack'
	AmbientGlow=16
	CollisionHeight=14
}