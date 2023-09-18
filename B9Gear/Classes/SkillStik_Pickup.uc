//=============================================================================
// SkillStik_Pickup
//=============================================================================
class SkillStik_Pickup extends InfoStik_Pickup;

#exec OBJ LOAD FILE=..\animations\B9Pickups_models.ukx PACKAGE=B9Pickups_models

defaultproperties
{
	InfoEntry="HealKick"
	InventoryType=Class'SkillStik'
	StaticMesh=StaticMesh'B9_items_mesh.data_stiks.data_stik_key'
}