//=============================================================================
// skill_HeavyWeaponsTargeting
//
// 
//=============================================================================

class skill_HeavyWeaponsTargeting extends B9_Skill;

function CacheSkillStrength( B9_AdvancedPawn pawn )
{
	pawn.SetHeavyWeaponsSkill(fStrength);
}

defaultproperties
{
	fSkillName="HeavyWpn"
	fPriority=1
}