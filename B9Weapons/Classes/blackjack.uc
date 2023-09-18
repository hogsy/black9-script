//=============================================================================
// blackjack.uc
//
// melee weapon
//
// 
//=============================================================================


class blackjack extends B9MeleeWeapon;


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
	fMomentumTransfer=100
	fUniqueID=3
	fUsesAmmo=false
	fUsesClips=false
	fMeleeWeapon=true
	fMeleeDamage=10
	fIniLookupName="Blackjack"
	AmmoName=Class'blackjack_Ammunition'
	TraceDist=100
	MaxRange=100
	PickupClass=Class'blackjack_Pickup'
	AttachmentClass=Class'blackjack_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.gen_blade_bricon'
	ItemName="blackjack"
	DrawType=8
}