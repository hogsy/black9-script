//////////////////////////////////////////////////////////////////////////
//
// Black 9 Combatant Archetype Genesis light guard.
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnCombatantGenesisLightGuard extends B9_ArchetypePawnCombatant;

// Load the animations package for the genesis archetype
#exec OBJ LOAD FILE=..\animations\B9_Genesis_Characters PACKAGE=B9_Genesis_Characters


///////////////////////////////////
// AnimateXXX()
// Sets up the movement anims in response to movement type / physics changes
//
simulated function AnimateWalking()
{
	MovementAnims[0]	= 'pistol_walk_f';
	MovementAnims[1]	= 'pistol_walk_b';
	MovementAnims[2]	= 'pistol_walk_step_L';
	MovementAnims[3]	= 'pistol_walk_step_r';
	TurnLeftAnim		= 'pistol_walk_step_L';
	TurnRightAnim		= 'pistol_walk_step_r';
}

simulated function AnimateRunning()
{
	MovementAnims[0]	= 'pistol_run_f';
	MovementAnims[1]	= 'pistol_run_b';
	MovementAnims[2]	= 'pistol_run_step_L';
	MovementAnims[3]	= 'pistol_run_step_r';
	TurnLeftAnim		= 'pistol_run_step_L';
	TurnRightAnim		= 'pistol_run_step_r';
}

simulated function AnimateCrouchWalking()
{
	MovementAnims[0]	= 'pistol_walk_f';
	MovementAnims[1]	= 'pistol_walk_b';
	MovementAnims[2]	= 'pistol_walk_step_L';
	MovementAnims[3]	= 'pistol_walk_step_r';
	TurnLeftAnim		= 'pistol_walk_step_L';
	TurnRightAnim		= 'pistol_walk_step_r';
}

simulated function AnimateSwimming()
{
	MovementAnims[0]	= 'pistol_swim';
	MovementAnims[1]	= 'pistol_swim';
	MovementAnims[2]	= 'pistol_swim';
	MovementAnims[3]	= 'pistol_swim';
	TurnLeftAnim		= 'pistol_swim';
	TurnRightAnim		= 'pistol_swim';
}

simulated function AnimateFlying()
{
	MovementAnims[0]	= 'pistol_walk_f';
	MovementAnims[1]	= 'pistol_walk_b';
	MovementAnims[2]	= 'pistol_walk_step_L';
	MovementAnims[3]	= 'pistol_walk_step_r';
	TurnLeftAnim		= 'pistol_walk_step_L';
	TurnRightAnim		= 'pistol_walk_step_r';
}

simulated function AnimateHovering()
{
	LoopIfNeeded( 'pistol_idle', 1.0, 0.0 );
}

simulated function AnimateClimbing()
{
	MovementAnims[0]	= 'pistol_walk_f';
	MovementAnims[1]	= 'pistol_walk_b';
	MovementAnims[2]	= 'pistol_walk_step_L';
	MovementAnims[3]	= 'pistol_walk_step_r';
	TurnLeftAnim		= 'pistol_walk_step_L';
	TurnRightAnim		= 'pistol_walk_step_r';

  	ChangeAnimation();
}

simulated function AnimateStoppedOnLadder()
{
	LoopIfNeeded( 'pistol_idle', 1.0, 0.0 );
}

simulated function AnimateTreading()
{
	LoopIfNeeded( 'pistol_idle', 1.0, 0.0 );
}

simulated function AnimateCrouching()
{
	LoopIfNeeded( 'pistol_idle', 1.0, 0.0 );
}

simulated function AnimateStanding()
{
	LoopIfNeeded( 'pistol_idle', 1.0, 0.0 );
}

simulated function name GetFiringAnim()
{
	return 'pistol_fire';
}
simulated function name GetJumpAnim()
{
	if ( (Acceleration.X != 0) || (Acceleration.Y != 0) )
	{
		return 'pistol_jump_f';
	}
	else
	{
		return 'pistol_jump_u';
	}
}
simulated function name GetFallingAnim()
{
	return 'pistol_land_falling';
}
simulated function name GetLandingAnim()
{
	return 'pistol_landing';
}
simulated function name GetKnockdownAnim( bool fromBehind )
{
	return 'pistol_knockdown_b';
}
simulated function name GetStandupAnim( bool fromBehind )
{
	return 'pistol_standup_b';
}
simulated function name GetDyingAnim( vector HitLoc )
{
	local vector X, Y, Z, Dir;

	GetAxes( Rotation, X, Y, Z );
	Dir = Normal( HitLoc - Location );

	if( ( Dir Dot X ) > 0  )
	{
		return 'pistol_knockdown_f';
	}
	else
	{
		return 'pistol_knockdown_b';
	}
}

defaultproperties
{
	fCharacterMaxHealth=100
	GroundSpeed=300
	WaterSpeed=350
	WalkingPct=0.25
	CrouchedPct=0.25
	Health=100
	MenuName="B9_Combatant"
	Mesh=SkeletalMesh'B9_Genesis_characters.light_guard_mesh'
	Buoyancy=100
}