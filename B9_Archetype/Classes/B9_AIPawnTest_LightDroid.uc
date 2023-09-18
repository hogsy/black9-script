

class B9_AIPawnTest_LightDroid extends B9_AIPawnBot_Base
	placeable;


simulated function AnimateWalking()
{
	MovementAnims[0]	= 'pistol_walk_F';
	MovementAnims[1]	= 'pistol_walk_B';
	MovementAnims[2]	= 'pistol_walk_step_L';
	MovementAnims[3]	= 'pistol_walk_step_r';
	TurnLeftAnim		= 'pistol_turn_r';
	TurnRightAnim		= 'pistol_turn_r';
}

simulated function AnimateRunning()
{
	MovementAnims[0]	= 'pistol_run_f';
	MovementAnims[1]	= 'pistol_run_b';
	MovementAnims[2]	= 'pistol_walk_step_L';
	MovementAnims[3]	= 'pistol_walk_step_L';
	TurnLeftAnim		= 'pistol_turn_r';
	TurnRightAnim		= 'pistol_turn_r';
}

simulated function AnimateStanding()
{

	if( fGettingUp || fJustFellHard )
	{
		return;
	}

	if( IsAnimating( FALLINGCHANNEL ) && ( Velocity.X != 0 || Velocity.Y != 0 ) )
	{
		if( fJustFellHard || fJustFellModerate )
		{
			return;
		}
		else if( fJustFellSoft )
		{
            fJustFellSoft = false;
		}

		AnimBlendToAlpha( FALLINGCHANNEL, 0, 0.01 );
	}

	LoopIfNeeded('pistol_idle', 1.0, 0.0 );
}

simulated function PlayFiring(float Rate, name FiringMode)
{
	AnimBlendParams( FIRINGCHANNEL, 1.0, 0.0, 0.0, GetBoneForShooting(), true );

	PlayAnim( 'pistol_fire', 1.0 , 0.0, FIRINGCHANNEL );
}

simulated event PlayJump()
{
	PlayAnim( 'pistol_jump_f' );
}

simulated event PlayFalling()
{
	LoopIfNeeded( 'pistol_land_flailing', 1.0, 0.35 );
}

simulated event PlayLandingAnimation(float ImpactVel)
{
	AnimBlendParams( FALLINGCHANNEL, 1.0, 0.0, 0.0, GetRootBone(), true );
	PlayAnim( 'pistol_landing',1.0, 0.0, FALLINGCHANNEL );
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	PlayAnim('pistol_knockdown_f');
	Super.PlayDying( DamageType, HitLoc );
}

defaultproperties
{
	fCharacterMaxHealth=160
	bCanCrouch=false
	bCanSwim=false
	bCanClimbLadders=false
	Health=160
	MenuName="B9_AIPawnTest_LightDroid"
	bPhysicsAnimUpdate=true
	Physics=1
	Mesh=SkeletalMesh'B9_Genesis_characters.light_droid_mesh'
}