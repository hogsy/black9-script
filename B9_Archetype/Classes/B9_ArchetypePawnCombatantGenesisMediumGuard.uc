
//
// Black 9 Combatant Archetype Genesis light guard.
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnCombatantGenesisMediumGuard extends B9_ArchetypePawnCombatant;

// Load the animations package for the civilian archetype
#exec OBJ LOAD FILE=..\animations\B9_Genesis_Characters PACKAGE=B9_Genesis_Characters

///////////////////////////////////
// AnimateXXX()
// Sets up the movement anims in response to movement type / physics changes
//
simulated function AnimateWalking()
{
	MovementAnims[0]	= 'rifle_walk_f';
	MovementAnims[1]	= 'rifle_walk_b';
	MovementAnims[2]	= 'rifle_walk_step_l';
	MovementAnims[3]	= 'rifle_walk_step_r';
	TurnLeftAnim		= 'rifle_walk_step_l';
	TurnRightAnim		= 'rifle_walk_step_r';
}

simulated function AnimateRunning()
{
	MovementAnims[0]	= 'rifle_run_f';
	MovementAnims[1]	= 'rifle_run_b';
	MovementAnims[2]	= 'rifle_walk_step_L';
	MovementAnims[3]	= 'rifle_walk_step_r';
	TurnLeftAnim		= 'rifle_walk_step_l';
	TurnRightAnim		= 'rifle_walk_step_r';
}

simulated function AnimateCrouchWalking()
{
	MovementAnims[0]	= 'rifle_run_f';
	MovementAnims[1]	= 'rifle_run_b';
	MovementAnims[2]	= 'rifle_walk_step_L';
	MovementAnims[3]	= 'rifle_walk_step_r';
	TurnLeftAnim		= 'rifle_walk_step_l';
	TurnRightAnim		= 'rifle_walk_step_r';
}

simulated function AnimateSwimming()
{
	MovementAnims[0]	= 'rifle_run_f';
	MovementAnims[1]	= 'rifle_run_b';
	MovementAnims[2]	= 'rifle_walk_step_L';
	MovementAnims[3]	= 'rifle_walk_step_r';
	TurnLeftAnim		= 'rifle_walk_step_l';
	TurnRightAnim		= 'rifle_walk_step_r';
}

simulated function AnimateFlying()
{
	MovementAnims[0]	= 'rifle_run_f';
	MovementAnims[1]	= 'rifle_run_b';
	MovementAnims[2]	= 'rifle_walk_step_L';
	MovementAnims[3]	= 'rifle_walk_step_r';
	TurnLeftAnim		= 'rifle_walk_step_l';
	TurnRightAnim		= 'rifle_walk_step_r';
}

simulated function AnimateHovering()
{
	LoopIfNeeded( 'rifle_idle', 1.0, 0.0 );
}

simulated function AnimateClimbing()
{
	MovementAnims[0]	= 'rifle_run_f';
	MovementAnims[1]	= 'rifle_run_b';
	MovementAnims[2]	= 'rifle_walk_step_L';
	MovementAnims[3]	= 'rifle_walk_step_r';
	TurnLeftAnim		= 'rifle_walk_step_l';
	TurnRightAnim		= 'rifle_walk_step_r';

  	ChangeAnimation();
}

simulated function AnimateStoppedOnLadder()
{
	LoopIfNeeded( 'rifle_idle', 1.0, 0.0 );
}

simulated function AnimateTreading()
{
	LoopIfNeeded( 'rifle_idle', 1.0, 0.0 );
}

simulated function AnimateCrouching()
{
	LoopIfNeeded( 'rifle_idle', 1.0, 0.0 );
}

simulated function AnimateStanding()
{
	LoopIfNeeded( 'rifle_idle', 1.0, 0.0 );
}

simulated function name GetFiringAnim()
{
	return 'rifle_fire';
}
simulated function name GetJumpAnim()
{
	if ( (Acceleration.X != 0) || (Acceleration.Y != 0) )
	{
		return 'rifle_jump_f';
	}
	else
	{
		return 'rifle_jump_up';
	}
}
simulated function name GetFallingAnim()
{
	return 'rifle_land_flailing';
}
simulated function name GetLandingAnim()
{
	return 'rifle_landing';
}
simulated function name GetKnockdownAnim( bool fromBehind )
{
	return 'rifle_knockdown_f';
}
simulated function name GetStandupAnim( bool fromBehind )
{
	return 'rifle_standup_f';
}
simulated function name GetDyingAnim( vector HitLoc )
{
	local vector X, Y, Z, Dir;

	GetAxes( Rotation, X, Y, Z );
	Dir = Normal( HitLoc - Location );

	if( ( Dir Dot X ) > 0  )
	{
		return 'rifle_knockdown_f';
	}
	else
	{
		return 'rifle_knockdown_b';
	}
}

simulated function name GetBoneForShooting()
{
	return 'Gupperspine';
}

defaultproperties
{
	fCharacterMaxHealth=1000
	FootstepVolume=0.25
	bCanCrouch=false
	bCanSwim=false
	bCanClimbLadders=false
	GroundSpeed=350
	WalkingPct=0.25
	CrouchedPct=0.25
	Health=1000
	MenuName="Genesis heavy soldier"
	Mesh=SkeletalMesh'B9_Genesis_characters.Genesis_medium_mesh'
}