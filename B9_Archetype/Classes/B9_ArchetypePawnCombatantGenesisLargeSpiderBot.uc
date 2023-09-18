//////////////////////////////////////////////////////////////////////////
//
// Black 9 Combatant Archetype Genesis large spider bot.
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnCombatantGenesisLargeSpiderBot extends B9_ArchetypePawnCombatant;

// Load the animations package for the civilian archetype
#exec OBJ LOAD FILE=..\animations\B9_Genesis_Characters PACKAGE=B9_Genesis_Characters


///////////////////////////////////
// AnimateXXX()
// Sets up the movement anims in response to movement type / physics changes
//
simulated function AnimateWalking()
{
	MovementAnims[0]	= 'nowpn_walk_f';
	MovementAnims[1]	= 'nowpn_walk_b';
	MovementAnims[2]	= 'nowpn_walk_step_l';
	MovementAnims[3]	= 'nowpn_walk_step_r';
	TurnLeftAnim		= 'nowpn_walk_step_l';
	TurnRightAnim		= 'nowpn_walk_step_r';
}

simulated function AnimateRunning()
{
	MovementAnims[0]	= 'nowpn_run_f';
	MovementAnims[1]	= 'nowpn_run_b';
	MovementAnims[2]	= 'nowpn_run_step_l';
	MovementAnims[3]	= 'nowpn_run_step_r';
	TurnLeftAnim		= 'nowpn_run_step_l';
	TurnRightAnim		= 'nowpn_run_step_r';
}

simulated function AnimateCrouchWalking()
{
	MovementAnims[0]	= 'nowpn_walk_f';
	MovementAnims[1]	= 'nowpn_walk_b';
	MovementAnims[2]	= 'nowpn_walk_step_l';
	MovementAnims[3]	= 'nowpn_walk_step_r';
	TurnLeftAnim		= 'nowpn_walk_step_l';
	TurnRightAnim		= 'nowpn_walk_step_r';
}

simulated function AnimateSwimming()
{
	MovementAnims[0]	= 'nowpn_walk_f';
	MovementAnims[1]	= 'nowpn_walk_b';
	MovementAnims[2]	= 'nowpn_walk_step_l';
	MovementAnims[3]	= 'nowpn_walk_step_r';
	TurnLeftAnim		= 'nowpn_walk_step_l';
	TurnRightAnim		= 'nowpn_walk_step_r';
}

simulated function AnimateFlying()
{
	MovementAnims[0]	= 'nowpn_walk_f';
	MovementAnims[1]	= 'nowpn_walk_b';
	MovementAnims[2]	= 'nowpn_walk_step_l';
	MovementAnims[3]	= 'nowpn_walk_step_r';
	TurnLeftAnim		= 'nowpn_walk_step_l';
	TurnRightAnim		= 'nowpn_walk_step_r';
}

simulated function AnimateHovering()
{
	LoopIfNeeded( 'nowpn_idle', 1.0, 0.0 );
}

simulated function AnimateClimbing()
{
	MovementAnims[0]	= 'nowpn_walk_f';
	MovementAnims[1]	= 'nowpn_walk_b';
	MovementAnims[2]	= 'nowpn_walk_step_l';
	MovementAnims[3]	= 'nowpn_walk_step_r';
	TurnLeftAnim		= 'nowpn_walk_step_l';
	TurnRightAnim		= 'nowpn_walk_step_r';

  	ChangeAnimation();
}

simulated function AnimateStoppedOnLadder()
{
	LoopIfNeeded( 'nowpn_idle', 1.0, 0.0 );
}

simulated function AnimateTreading()
{
	LoopIfNeeded( 'nowpn_idle', 1.0, 0.0 );
}

simulated function AnimateCrouching()
{
	LoopIfNeeded( 'nowpn_idle', 1.0, 0.0 );
}

simulated function AnimateStanding()
{
	LoopIfNeeded( 'nowpn_idle', 1.0, 0.0 );
}

simulated function name GetFiringAnim()
{
	return 'nowpn_fire';
}
simulated function name GetJumpAnim()
{
	if ( (Acceleration.X != 0) || (Acceleration.Y != 0) )
	{
		return 'nowpn_jump_f';
	}
	else
	{
		return 'nowpn_jump_u';
	}
}
simulated function name GetFallingAnim()
{
	return 'nowpn_land_flailing';
}
simulated function name GetLandingAnim()
{
	return 'nowpn_landing';
}
simulated function name GetKnockdownAnim( bool fromBehind )
{
	return 'nowpn_knockdown_b';
}
simulated function name GetStandupAnim( bool fromBehind )
{
	return 'nowpn_standup_b';
}
simulated function name GetDyingAnim( vector HitLoc )
{
	local vector X, Y, Z, Dir;

	GetAxes( Rotation, X, Y, Z );
	Dir = Normal( HitLoc - Location );

	if( ( Dir Dot X ) > 0  )
	{
		return 'nowpn_knockdown_f';
	}
	else
	{
		return 'nowpn_knockdown_b';
	}
}

defaultproperties
{
	fRetreatToCoverRatio=0
	bIsBig=true
	fCharacterMaxHealth=500
	GroundSpeed=350
	WaterSpeed=350
	WalkingPct=0.25
	CrouchedPct=0.25
	Health=500
	MenuName="B9_CombatantLargeSpiderBot"
	Mesh=SkeletalMesh'B9_Genesis_characters.large_spider_bot_mesh'
	CollisionRadius=150
	Buoyancy=100
}