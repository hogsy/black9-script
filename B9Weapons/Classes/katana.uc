//=============================================================================
// katana.uc
//
// melee weapon
//
// 
//=============================================================================


class katana extends B9MeleeWeapon;


//////////////////////////////////
// Resource imports
//



//////////////////////////////////
// Variables
//

//////////////////////////////////
// Functions
//

//////////////////////////////////
// States
//



//////////////////////////////////
// Initialization
//

defaultproperties
{
	fDamageRadius=100
	fMomentumTransfer=100
	fUniqueID=1
	fUsesAmmo=false
	fUsesClips=false
	fMeleeWeapon=true
	fMeleeDamage=10
	fIniLookupName="Katana"
	AmmoName=Class'Katana_Ammunition'
	TraceDist=100
	MaxRange=100
	FireSound=Sound'B9Weapons_sounds.melee.sword_swing2'
	PickupClass=Class'katana_Pickup'
	AttachmentClass=Class'katana_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.katana_bricon'
	ItemName="Katana"
	Mesh=SkeletalMesh'B9Weapons_models.Katana_mesh'
}