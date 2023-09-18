//=============================================================================
// B9_TossedCan_Attachment.uc
//
// 
//=============================================================================


class B9_TossedCan_Attachment extends B9_WeaponAttachment;


//////////////////////////////////
// Functions
//

function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}

//////////////////////////////////
// Initialization
//

defaultproperties
{
	fWeaponPose=4
	FiringMode=MODE_Overhand
	Mesh=SkeletalMesh'B9AmbientCreatures_models.ScrubberBot'
	DrawScale=0.25
}