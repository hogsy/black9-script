//=============================================================================
// skill_UVCloak
//
// Character Modification
// Jams cameras within 5m for up to 60s depending on user's skill level.
// 
//=============================================================================

Class skill_UVCloak extends B9_Skill;
//    Native
//    NativeReplication;
 

// Functions 

function PawnTick( Pawn pawn, float deltaTime )
{
}

defaultproperties
{
	fSkillName="UVCloak"
	fPriority=1
	fStrength=10
	Icon=Texture'B9HUD_textures.Browser_skills.Optic_cloak_bricon'
}