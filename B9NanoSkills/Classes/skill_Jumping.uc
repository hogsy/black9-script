//=============================================================================
// skill_Jumping
//
// 
//=============================================================================

class skill_Jumping extends B9_Skill;

function CacheSkillStrength( B9_AdvancedPawn pawn )
{
	pawn.SetJumping(fStrength);
}

defaultproperties
{
	fSkillName="Jumping"
	fPriority=1
}