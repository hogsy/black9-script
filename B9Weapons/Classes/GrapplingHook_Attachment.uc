//=============================================================================
// GrapplingHook_Attachment.uc
//
// Attachment for GrapplingHook weapon
//
// 
//=============================================================================


class GrapplingHook_Attachment extends B9_WeaponAttachment;


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
	FiringMode=MODE_Grenade
	fAnimKind=3
	Mesh=SkeletalMesh'B9Weapons_models.GrapplingHook_mesh'
}