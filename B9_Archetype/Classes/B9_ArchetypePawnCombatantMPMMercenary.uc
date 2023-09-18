//////////////////////////////////////////////////////////////////////////
//
// Black 9 Combatant Archetype Pawn MPM Mercenary Class
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnCombatantMPMMercenary extends B9_ArchetypePawnCombatant placeable;

#exec OBJ LOAD FILE=..\animations\B9_MPM_DGP_Characters PACKAGE=B9_MPM_DGP_Characters


simulated function name GetBoneForShooting()
{
	return 'Object01';
}

///////////////////////////////////
// AnimateXXX()
// Sets up the movement anims in response to movement type / physics changes
//
simulated function AnimateWalking()
{
	MovementAnims[0]	= 'nowpn_Walk_F';
	MovementAnims[1]	= 'nowpn_Walk_B';
	MovementAnims[2]	= 'nowpn_Walk_Step_Left';
	MovementAnims[3]	= 'nowpn_Walk_Step_Right';
	TurnLeftAnim		= 'mpmMerc_hoover_left';
	TurnRightAnim		= 'mpmMerc_hoover_right';
}

simulated function AnimateRunning()
{
	MovementAnims[0]	= 'nowpn_Run_F';
	MovementAnims[1]	= 'nowpn_Walk_B';
	MovementAnims[2]	= 'nowpn_Run_Step_Left';
	MovementAnims[3]	= 'nowpn_Run_Step_Right';
	TurnLeftAnim		= 'mpmMerc_hoover_left';
	TurnRightAnim		= 'mpmMerc_hoover_right';
}

simulated function AnimateCrouchWalking()
{
	MovementAnims[0]	= 'mpmMerc_hoover_f';
	MovementAnims[1]	= 'mpmMerc_hoover_b';
	MovementAnims[2]	= 'mpmMerc_hoover_left';
	MovementAnims[3]	= 'mpmMerc_hoover_right';
	TurnLeftAnim		= 'mpmMerc_hoover_left';
	TurnRightAnim		= 'mpmMerc_hoover_right';
}

simulated function AnimateSwimming()
{
	MovementAnims[0]	= 'mpmMerc_hoover_f';
	MovementAnims[1]	= 'mpmMerc_hoover_b';
	MovementAnims[2]	= 'mpmMerc_hoover_left';
	MovementAnims[3]	= 'mpmMerc_hoover_right';
	TurnLeftAnim		= 'mpmMerc_hoover_left';
	TurnRightAnim		= 'mpmMerc_hoover_right';
}

simulated function AnimateFlying()
{
	MovementAnims[0]	= 'nowpn_flying_idle';
	MovementAnims[1]	= 'nowpn_flying_idle';
	MovementAnims[2]	= 'nowpn_fly_left';
	MovementAnims[3]	= 'nowpn_wingpack_right';
	TurnLeftAnim		= 'mpmMerc_hoover_left';
	TurnRightAnim		= 'mpmMerc_hoover_right';
}

simulated function AnimateHovering()
{
	LoopIfNeeded( 'mpmMerc_hoover_idel', 1.0, 0.0 );
}

simulated function AnimateClimbing()
{
	MovementAnims[0]	= 'mpmMerc_hoover_f';
	MovementAnims[1]	= 'mpmMerc_hoover_b';
	MovementAnims[2]	= 'mpmMerc_hoover_left';
	MovementAnims[3]	= 'mpmMerc_hoover_right';
	TurnLeftAnim		= 'mpmMerc_hoover_left';
	TurnRightAnim		= 'mpmMerc_hoover_right';

  	ChangeAnimation();
}

simulated function AnimateStoppedOnLadder()
{
	LoopIfNeeded( 'nowpn_flying_idle', 1.0, 0.0 );
}

simulated function AnimateTreading()
{
	LoopIfNeeded( 'mpmMerc_hoover_idel', 1.0, 0.0 );
}

simulated function AnimateCrouching()
{
	LoopIfNeeded( 'mpmMerc_hoover_idel', 1.0, 0.0 );
}

simulated function AnimateStanding()
{
	LoopIfNeeded( 'rifle_idle', 1.0, 0.0 );
}

simulated function name GetFiringAnim()
{
	return 'nowpn_fire';
}
simulated function name GetJumpAnim()
{
	if ( (Acceleration.X != 0) || (Acceleration.Y != 0) )
	{
		return 'no_wpn_take_off';
	}
	else
	{
		return 'no_wpn_take_off';
	}
}
simulated function name GetFallingAnim()
{
	return 'mpmMerc_hoover_f';
}
simulated function name GetLandingAnim()
{
	return 'mpmMerc_hoover_f';
}
simulated function name GetKnockdownAnim( bool fromBehind )
{
	return 'nowpn_knockdown_f';
}
simulated function name GetStandupAnim( bool fromBehind )
{
	return 'nowpn_standup_f';
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
	MenuName="B9_CombatantMPM_mercenary"
	Mesh=SkeletalMesh'B9_MPM_DGP_Characters.mpm_mercenary'
}