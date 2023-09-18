//////////////////////////////////////////////////////////////////////////
//
// Black 9 Combatant Archetype Genesis Intimidator Droid.
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnCombatantGenesisIntimidator extends B9_ArchetypePawnCombatant;

// Load the animations package for the civilian archetype
#exec OBJ LOAD FILE=..\animations\B9_Genesis_Characters PACKAGE=B9_Genesis_Characters



simulated function name GetBoneForShooting()
{
	return 'Box13';
}

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
	return '';
}
simulated function name GetKnockdownAnim( bool fromBehind )
{
	return 'pistol_knockdown_f';
}
simulated function name GetStandupAnim( bool fromBehind )
{
	return 'pistol_standup_f';
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
	fWeaponIdentifierName="B9Weapons.AI_Intimidator_Gun"
	fRetreatOnTakingFireRatio=0.25
	fRetreatToCoverRatio=0
	bIsBig=true
	fCharacterMaxHealth=800
	FootstepVolume=0.5
	DeathSound=Sound'B9GenesisCharacters_sounds.Intimidator.intimidator_death1'
	SoundFootsteps[0]=Sound'B9AllCharacters_sounds.Footsteps.foot_intimidator_dirt1'
	SoundFootsteps[1]=Sound'B9AllCharacters_sounds.Footsteps.foot_intimidator_dirt2'
	SoundFootsteps[2]=Sound'B9AllCharacters_sounds.Footsteps.foot_intimidator_dirt1'
	SoundFootsteps[3]=Sound'B9AllCharacters_sounds.Footsteps.foot_intimidator_dirt2'
	SoundFootsteps[4]=Sound'B9AllCharacters_sounds.Footsteps.foot_intimidator_grass1'
	SoundFootsteps[5]=Sound'B9AllCharacters_sounds.Footsteps.foot_intimidator_grass2'
	SoundFootsteps[6]=Sound'B9AllCharacters_sounds.Footsteps.foot_intimidator_grass1'
	SoundFootsteps[7]=Sound'B9AllCharacters_sounds.Footsteps.foot_intimidator_grass2'
	SoundFootsteps[8]=Sound'B9AllCharacters_sounds.Footsteps.foot_intimidator_metfloor1'
	SoundFootsteps[9]=Sound'B9AllCharacters_sounds.Footsteps.foot_intimidator_metfloor2'
	SoundFootsteps[10]=Sound'B9AllCharacters_sounds.Footsteps.foot_intimidator_metfloor1'
	SoundFootsteps[11]=Sound'B9AllCharacters_sounds.Footsteps.foot_intimidator_metfloor2'
	GroundSpeed=350
	WaterSpeed=350
	WalkingPct=0.25
	CrouchedPct=0.25
	BaseEyeHeight=-60
	EyeHeight=-60
	Health=800
	MenuName="B9_CombatantIntimidator"
	Mesh=SkeletalMesh'B9_Genesis_characters.intimidator_mesh'
	CollisionRadius=130
	CollisionHeight=250
	Buoyancy=100
}