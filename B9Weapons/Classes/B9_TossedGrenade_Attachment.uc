//=============================================================================
// B9_TossedGrenade_Attachment.uc
//
// 
//=============================================================================


class B9_TossedGrenade_Attachment extends B9_WeaponAttachment;


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
	DrawType=8
}