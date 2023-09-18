//===============================================================================
//  [B9_Cinema_Charles] 
//  clone of B9_ArchetypePawnCombatantGenesisMediumGuard just for cinematics. - DP
//===============================================================================

class B9_cinema_Charles extends B9_ArchetypePawnCombatant;

defaultproperties
{
	fCombatantIdleAnimationName=Idle
	fWalkAnim=walk_forward
	fRunAnim=walk_forward
	bCanDodge=true
	fWeaponIdentifierName=""
	fCharacterMaxHealth=1000
	GroundSpeed=300
	WaterSpeed=350
	WalkingPct=0.28
	Health=1000
	MenuName="cinematic pawn Charles"
	Mesh=SkeletalMesh'B9_Cinema_Chars.B9_cinema_Charles_mesh'
	Buoyancy=100
}