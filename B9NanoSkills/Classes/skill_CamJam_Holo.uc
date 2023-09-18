//=============================================================================
// skill_CamJam_Holo
//
// 
//
// 
//=============================================================================

class skill_CamJam_Holo extends B9_HoloItem;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	Description="The CamJam nanotech can be activated in the field to temporarily disable any cameras within a 5 meter radius. Increasing your skill level will disable cameras from greater distances, up to 20m, and for slightly longer periods of time, up to 60 seconds."
	DisplayName="CamJam"
	InventoryName="B9NanoSkills.skill_CamJam"
	LongDisplayName="CamJam nanotech"
	DrawType=8
	StaticMesh=StaticMesh'B9_Skills_meshes.nano_thieftools.skill_icon_camjam'
}