//=============================================================================
// heavy_GrenadeLauncher_Attachment.uc
//
// Attachment for Assault Rifle weapon
//
// 
//=============================================================================


class heavy_GrenadeLauncher_Attachment extends B9_WeaponAttachment;


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
	Mesh=SkeletalMesh'B9Weapons_models.GrenadeLauncher_mesh'
}