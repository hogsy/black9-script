//=============================================================================
// skill_UrbanTracking
//
// 
//=============================================================================

class skill_UrbanTracking extends B9_Skill;

function CacheSkillStrength( B9_AdvancedPawn pawn )
{
	pawn.SetUrbanTracking( fStrength );
}

defaultproperties
{
	fSkillName="UrbanTracking"
	fPriority=1
}