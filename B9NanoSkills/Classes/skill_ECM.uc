//=============================================================================
// skill_ECM
//
// Character Modification
// Jams cameras within 5m for up to 60s depending on user's skill level.
// 
//=============================================================================

Class skill_ECM extends B9_Skill;
//    Native
//    NativeReplication;
 

// Functions 

function PawnTick( Pawn pawn, float deltaTime )
{
}

defaultproperties
{
	fSkillName="ECM"
	fPriority=1
	fStrength=10
	Icon=Texture'B9HUD_textures.Browser_skills.ECM_bricon'
}