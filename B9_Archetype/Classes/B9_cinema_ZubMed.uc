//===============================================================================
//  [B9_Cinema_ZubMed] 
//  clone of B9_ArchetypePawnCombatantGenesisMediumGuard just for cinematics. - DP
//===============================================================================

class B9_cinema_ZubMed extends B9_ArchetypePawnCombatant;

defaultproperties
{
	fCombatantIdleAnimationName=rifle_idle_surveillance
	fWalkAnim=rifle_walk_forward
	fRunAnim=rifle_run_forward
	fDodgeLeftAnim=rifle_dodge_left
	fDodgeRightAnim=rifle_dodge_right
	bCanDodge=true
	fCharacterMaxHealth=1000
	GroundSpeed=300
	WaterSpeed=350
	WalkingPct=0.28
	Health=1000
	MenuName="cinematic pawn ZubMed"
	Mesh=SkeletalMesh'B9_Cinema_Chars.B9_cinema_ZubMed_mesh'
	Buoyancy=100
}