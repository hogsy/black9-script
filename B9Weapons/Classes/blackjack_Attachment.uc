//=============================================================================
// blackjack_Attachment.uc
//
// Attachment for blackjack weapon
//
// 
//=============================================================================


class blackjack_Attachment extends B9_WeaponAttachment;


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
	fAnimKind=4
	DrawType=8
}