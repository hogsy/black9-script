//////////////////////////////////////////////////////////////////////////
//
// Black 9 Combatant Archetype Genesis Light Droid.
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnCombatantGenesisLightDroid extends B9_ArchetypePawnCombatant;

// Load the animations package for the civilian archetype
#exec OBJ LOAD FILE=..\animations\B9_Genesis_Characters PACKAGE=B9_Genesis_Characters

var protected Sound fAlert[6];
var protected Sound fSpeech[5];
var protected float fLastSpoke;

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
	MovementAnims[2]	= 'pistol_walk_step_L';
	MovementAnims[3]	= 'pistol_walk_step_r';
	TurnLeftAnim		= 'pistol_walk_step_L';
	TurnRightAnim		= 'pistol_walk_step_r';
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
	MovementAnims[0]	= 'pistol_walk_f';
	MovementAnims[1]	= 'pistol_walk_b';
	MovementAnims[2]	= 'pistol_walk_step_L';
	MovementAnims[3]	= 'pistol_walk_step_r';
	TurnLeftAnim		= 'pistol_walk_step_L';
	TurnRightAnim		= 'pistol_walk_step_r';
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
		return 'pistol_jump_f';
	}
}
simulated function name GetFallingAnim()
{
	return 'pistol_land_flailing';
}
simulated function name GetLandingAnim()
{
	return 'pistol_landing';
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

function PlayEnemySpottedSound()
{
	PlaySound(fAlert[FRand() * 6], SLOT_Talk,,, 100, 0.85+FRand()*0.3,true );
}

function PlayIdleSpeech()
{
	if ( Controller.Level.TimeSeconds - fLastSpoke > FRand() * 12 + 10.0 )
	{
		fLastSpoke = Controller.Level.TimeSeconds;

		PlaySound(fSpeech[FRand() * 5], SLOT_Talk,,, 100, 0.85+FRand()*0.3,true );		
	}
}

defaultproperties
{
	fAlert[0]=Sound'B9GenesisCharacters_sounds.SecurityDroid.secdroid1_alert01'
	fAlert[1]=Sound'B9GenesisCharacters_sounds.SecurityDroid.secdroid1_alert01'
	fAlert[2]=Sound'B9GenesisCharacters_sounds.SecurityDroid.secdroid1_alert03'
	fAlert[3]=Sound'B9GenesisCharacters_sounds.SecurityDroid.secdroid2_alert01'
	fAlert[4]=Sound'B9GenesisCharacters_sounds.SecurityDroid.secdroid2_alert02'
	fAlert[5]=Sound'B9GenesisCharacters_sounds.SecurityDroid.secdroid2_alert03'
	fSpeech[0]=Sound'B9GenesisCharacters_sounds.SecurityDroid.secdroid1_searching01'
	fSpeech[1]=Sound'B9GenesisCharacters_sounds.SecurityDroid.secdroid1_searching02'
	fSpeech[2]=Sound'B9GenesisCharacters_sounds.SecurityDroid.secdroid1_searching03'
	fSpeech[3]=Sound'B9GenesisCharacters_sounds.SecurityDroid.secdroid2_searching01'
	fSpeech[4]=Sound'B9GenesisCharacters_sounds.SecurityDroid.secdroid2_searching02'
	fWeaponIdentifierName="B9Weapons.AI_SentryDroid_Gun"
	fCharacterMaxHealth=100
	FootstepVolume=0.25
	SoundFootsteps[0]=Sound'B9AllCharacters_sounds.Footsteps.foot_secdroid_dirt1'
	SoundFootsteps[1]=Sound'B9AllCharacters_sounds.Footsteps.foot_secdroid_dirt2'
	SoundFootsteps[2]=Sound'B9AllCharacters_sounds.Footsteps.foot_secdroid_dirt3'
	SoundFootsteps[3]=Sound'B9AllCharacters_sounds.Footsteps.foot_secdroid_dirt4'
	SoundFootsteps[4]=Sound'B9AllCharacters_sounds.Footsteps.foot_secdroid_grass1'
	SoundFootsteps[5]=Sound'B9AllCharacters_sounds.Footsteps.foot_secdroid_grass2'
	SoundFootsteps[6]=Sound'B9AllCharacters_sounds.Footsteps.foot_secdroid_grass3'
	SoundFootsteps[7]=Sound'B9AllCharacters_sounds.Footsteps.foot_secdroid_grass4'
	SoundFootsteps[8]=Sound'B9AllCharacters_sounds.Footsteps.foot_secdroid_metfloor1'
	SoundFootsteps[9]=Sound'B9AllCharacters_sounds.Footsteps.foot_secdroid_metfloor2'
	SoundFootsteps[10]=Sound'B9AllCharacters_sounds.Footsteps.foot_secdroid_metfloor3'
	SoundFootsteps[11]=Sound'B9AllCharacters_sounds.Footsteps.foot_secdroid_metfloor4'
	bCanCrouch=false
	bCanSwim=false
	bCanClimbLadders=false
	GroundSpeed=350
	WalkingPct=0.25
	CrouchedPct=0.25
	Health=100
	MenuName="B9_CombatantLightDroid"
	Mesh=SkeletalMesh'B9_Genesis_characters.light_droid_mesh'
}