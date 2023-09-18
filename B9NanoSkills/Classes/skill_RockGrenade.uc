//=============================================================================
// skill_RockGrenade.uc
//
//	RockGrenade skill
//
//=============================================================================


class skill_RockGrenade extends BaseAttackSkill;


//////////////////////////////////
// Resource imports
//

//////////////////////////////////
// Definitions
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
	fActivatable=true
	fSkillName="Rock Grenade"
	fUniqueID=9
	fFocusUsePerActivation=10
	fPriority=1
	fStrength=10
	Icon=Texture'B9HUD_textures.Browser_skills.Earthquake_bricon'
}