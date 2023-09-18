//=============================================================================
// skill_FireArmsTargeting
//
// 
//=============================================================================

class skill_FireArmsTargeting extends B9_Skill;

function CacheSkillStrength( B9_AdvancedPawn pawn )
{
	pawn.SetFireArmsSkill(fStrength);
}

defaultproperties
{
	fSkillName="Firearms"
	fPriority=1
}