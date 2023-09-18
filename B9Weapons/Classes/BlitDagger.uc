//=============================================================================
// BlitDagger.uc
//
// melee weapon
//
// 
//=============================================================================


class BlitDagger extends B9MeleeWeapon;


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
	fUniqueID=6
	fUsesAmmo=false
	fUsesClips=false
	fMeleeWeapon=true
	fMeleeDamage=10
	fIniLookupName="BlitDagger"
	AmmoName=Class'BlitDagger_Ammunition'
	TraceDist=100
	MaxRange=100
	FireSound=Sound'B9Weapons_sounds.melee.sword_swing1'
	PickupClass=Class'BlitDagger_Pickup'
	AttachmentClass=Class'BlitDagger_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.gen_blade_bricon'
	ItemName="BlitDagger"
	Mesh=SkeletalMesh'B9Weapons_models.BlitDagger_mesh'
}