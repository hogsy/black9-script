//=============================================================================
// BlitSword.uc
//
// melee weapon
//
// 
//=============================================================================


class BlitSword extends B9MeleeWeapon;


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
	fUniqueID=5
	fUsesAmmo=false
	fUsesClips=false
	fMeleeWeapon=true
	fMeleeDamage=10
	fIniLookupName="BlitSword"
	AmmoName=Class'BlitSword_Ammunition'
	TraceDist=100
	MaxRange=100
	FireSound=Sound'B9Weapons_sounds.melee.sword_swing2'
	PickupClass=Class'BlitSword_Pickup'
	AttachmentClass=Class'BlitSword_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.blit_sword_bricon'
	ItemName="BlitSword"
	Mesh=SkeletalMesh'B9Weapons_models.Blit_Sword_mesh'
}