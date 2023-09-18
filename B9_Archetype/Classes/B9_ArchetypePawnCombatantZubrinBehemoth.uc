//////////////////////////////////////////////////////////////////////////
//
// Black 9 Combatant Archetype Zubrin Behemoth.
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnCombatantZubrinBehemoth extends B9_ArchetypePawnCombatant;

// Load the animations package for the civilian archetype
#exec OBJ LOAD FILE=..\animations\B9_Zubrin_Characters PACKAGE=B9_Zubrin_Characters


///////////////////////////////////
// AnimateXXX()
// Sets up the movement anims in response to movement type / physics changes
//
simulated function AnimateWalking()
{
	MovementAnims[0]	= 'Walk';
	MovementAnims[1]	= 'Walk';
	MovementAnims[2]	= 'Walk';
	MovementAnims[3]	= 'Walk';
	TurnLeftAnim		= 'Walk';
	TurnRightAnim		= 'Walk';
}

simulated function AnimateRunning()
{
	MovementAnims[0]	= 'Run';
	MovementAnims[1]	= 'Run';
	MovementAnims[2]	= 'Run';
	MovementAnims[3]	= 'Run';
	TurnLeftAnim		= 'Run';
	TurnRightAnim		= 'Run';
}

simulated function AnimateCrouchWalking()
{
	AnimateWalking();
}

simulated function AnimateSwimming()
{
	AnimateWalking();
}

simulated function AnimateFlying()
{
	AnimateWalking();
}

simulated function AnimateHovering()
{
	LoopIfNeeded( 'Idle', 1.0, 0.0 );
}

simulated function AnimateClimbing()
{
	AnimateWalking();
  	ChangeAnimation();
}

simulated function AnimateStoppedOnLadder()
{
	LoopIfNeeded( 'Idle', 1.0, 0.0 );
}

simulated function AnimateTreading()
{
	LoopIfNeeded( 'Idle', 1.0, 0.0 );
}

simulated function AnimateCrouching()
{
	LoopIfNeeded( 'Idle', 1.0, 0.0 );
}

simulated function AnimateStanding()
{
	LoopIfNeeded( 'Idle', 1.0, 0.0 );
}

simulated function name GetFiringAnim()
{
	return 'Idle';
}
simulated function name GetJumpAnim()
{
	return 'Run';
}
simulated function name GetFallingAnim()
{
	return 'Idle';
}
simulated function name GetLandingAnim()
{
	return 'Idle';
}
simulated function name GetKnockdownAnim( bool fromBehind )
{
	return 'Idle';
}
simulated function name GetStandupAnim( bool fromBehind )
{
	return 'Idle';
}
simulated function name GetDyingAnim( vector HitLoc )
{
	return 'Idle';
}

defaultproperties
{
	fRetreatOnTakingFireRatio=0.25
	fRetreatToCoverRatio=0
	bIsBig=true
	fCharacterMaxHealth=800
	GroundSpeed=350
	WaterSpeed=350
	WalkingPct=0.25
	CrouchedPct=0.25
	BaseEyeHeight=-60
	EyeHeight=-60
	Health=800
	MenuName="B9_Combatant_Zubrin_Behemoth"
	Mesh=SkeletalMesh'B9_Zubrin_characters.behemoth_test_mesh_2'
	CollisionRadius=130
	CollisionHeight=250
	Buoyancy=100
}