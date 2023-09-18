//=============================================================================
// skill_MeleeCombat
//
// 
//=============================================================================

class skill_MeleeCombat extends B9_Skill;

function CacheSkillStrength( B9_AdvancedPawn pawn )
{
	pawn.SetMeleeCombat( fStrength );
}

defaultproperties
{
	fSkillName="MeleeCombat"
	fPriority=1
}