//=============================================================================
// dagger.uc
//
// melee weapon
//
// 
//=============================================================================


class dagger extends B9MeleeWeapon;


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
	fUniqueID=2
	fUsesAmmo=false
	fUsesClips=false
	fMeleeWeapon=true
	fMeleeDamage=10
	fIniLookupName="Dagger"
	AmmoName=Class'dagger_Ammunition'
	TraceDist=100
	MaxRange=100
	PickupClass=Class'dagger_Pickup'
	AttachmentClass=Class'dagger_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.gen_blade_bricon'
	ItemName="dagger"
	DrawType=8
}