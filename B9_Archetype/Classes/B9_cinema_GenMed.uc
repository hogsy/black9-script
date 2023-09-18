//===============================================================================
//  [B9_Cinema_GenMed] 
//  clone of B9_ArchetypePawnCombatantGenesisMediumGuard just for cinematics. - DP
//===============================================================================

class B9_cinema_GenMed extends B9_ArchetypePawnCombatant;

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
	MenuName="cinematic pawn GenMed"
	Mesh=SkeletalMesh'B9_Cinema_Chars.B9_cinema_GenMed_mesh'
	Buoyancy=100
}