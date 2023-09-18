//=============================================================================
// HandToHand_Attachment.uc
//
// Attachment for HandToHand weapon (not really needed, is just character's fists)
//
// 
//=============================================================================


class HandToHand_Attachment extends B9_WeaponAttachment;


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
	fWeaponPose=2
	FiringMode=MODE_Slash
	DrawType=0
}