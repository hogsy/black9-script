

class B9_AIPawnTest_MediumGuard extends B9_AIPawnBot_Base
	placeable;


simulated function AnimateWalking()
{
	MovementAnims[0]	= 'rifle_walk_F';
	MovementAnims[1]	= 'rifle_walk_B';
	MovementAnims[2]	= 'rifle_walk_step_L';
	MovementAnims[3]	= 'rifle_walk_step_r';
	TurnLeftAnim		= 'rifle_turn_r';
	TurnRightAnim		= 'rifle_turn_r';
}

simulated function AnimateRunning()
{
	MovementAnims[0]	= 'rifle_run_f';
	MovementAnims[1]	= 'rifle_run_b';
	MovementAnims[2]	= 'rifle_walk_step_L';
	MovementAnims[3]	= 'rifle_walk_step_L';
	TurnLeftAnim		= 'rifle_turn_r';
	TurnRightAnim		= 'rifle_turn_r';
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

	LoopIfNeeded('rifle_idle', 1.0, 0.0 );
}

simulated function PlayFiring(float Rate, name FiringMode)
{
	AnimBlendParams( FIRINGCHANNEL, 1.0, 0.0, 0.0, GetBoneForShooting(), true );

	PlayAnim( 'rifle_idle_fire', 1.0 , 0.0, FIRINGCHANNEL );
}

simulated event PlayJump()
{
	PlayAnim( 'rifle_jump_f' );
}

simulated event PlayFalling()
{
	LoopIfNeeded( 'rifle_land_flailing', 1.0, 0.35 );
}

simulated event PlayLandingAnimation(float ImpactVel)
{
	AnimBlendParams( FALLINGCHANNEL, 1.0, 0.0, 0.0, GetRootBone(), true );
	PlayAnim( 'rifle_landing',1.0, 0.0, FALLINGCHANNEL );
}

simulated function KnockDown( bool fromBehind )
{
	return;
}

simulated function PlayGettingUp()
{
	return;
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	PlayAnim('rifle_knockdown_f');
	Super.PlayDying( DamageType, HitLoc );
}

defaultproperties
{
	fCharacterMaxHealth=160
	bCanCrouch=false
	bCanSwim=false
	bCanClimbLadders=false
	GroundSpeed=244
	Health=160
	MenuName="B9_AIPawnTest_MediumGuard"
	bPhysicsAnimUpdate=true
	Physics=1
	Mesh=SkeletalMesh'B9_Genesis_characters.Genesis_medium_mesh'
}