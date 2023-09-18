/*
TestMoCapPawn
Allows minimal animation set pawns to work, with new anims being added.
Must have at least Stand_Rdy and Run animations
Also allows animator to play around with tween/blend values
*/
class TestMoCapPawn extends WarfarePawn;

var(AnimTweaks) float JumpBlendInTime;			// tween into jump time
var(AnimTweaks) float LandingBlendOutStart;		// point in landing animation were blend with next anim starts
var(AnimTweaks) float LandingTweenInTime;		// blend into landing animation time
var(AnimTweaks) float FiringBlendTime;

simulated function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc)
{
	if ( (FRand() < 0.8) && HasAnim('death_neck') )
		PlayAnim('death_neck',1.0,0.15);
	else if ( HasAnim('death_fire') )
		PlayAnim('death_fire',1.0,0.15);
}
	
/*	
simulated function PlayFiring(float Rate, name FiringMode)
{
	if ( bIgnorePlayFiring )
		return;
	if ( !HasAnim('Shoot_Single') )
		return;

	AnimBlendParams(FIRINGCHANNEL,1.0,0,0,FIRINGBLENDBONE);

	// choose anim based on weapon's mode
	// play full anim in the 0 (standing) channel
	// fixme - not using shoot_burst
	if ( bSteadyFiring && HasAnim('Shoot_Auto') )
	{
		if ( (Physics == PHYS_Walking) && !bIsCrouched )
			LoopAnim('shoot_auto',Rate,FiringBlendTime);
		LoopAnim('shoot_auto',Rate,FiringBlendTime,FIRINGCHANNEL);
	}
	else if ( (FiringMode == 'MODE_Grenade') && HasAnim('Shoot_Gernade') )
	{
		if ( (Physics == PHYS_Walking) && !bIsCrouched )
			PlayAnim('shoot_gernade',Rate,FiringBlendTime);
		PlayAnim('shoot_gernade',Rate,FiringBlendTime,FIRINGCHANNEL);
	}
	else
	{
		if ( (Physics == PHYS_Walking) && !bIsCrouched )
			PlayAnim('shoot_single',Rate,FiringBlendTime);
		PlayAnim('shoot_single',Rate,FiringBlendTime,FIRINGCHANNEL);
	}
}
*/
simulated function SetMovementAnim(int i, name Desired, name Fallback)
{
	if ( HasAnim(Desired) )
		MovementAnims[i] = Desired;
	else 
		MovementAnims[i] = Fallback;
}

simulated function AnimateTurning()
{
	if ( !HasAnim('Turn_Left') )
	{
		TurnLeftAnim = 'Stand_Rdy';
		TurnRightAnim = 'Stand_Rdy';
		return;
	}
	TurnLeftAnim = 'Turn_Left';
	TurnRightAnim = 'Turn_Right';
}

simulated function AnimateCrouching()
{
	if ( !HasAnim('Crouch') )
	{
		AnimateStanding();
		return;
	}
	Super.AnimateCrouching();
}

simulated function AnimateRunning()
{
	if ( !HasAnim('Run_Relaxed') )
		MovementAnims[0] = 'Run';
	else if ( Weapon == None )
		MovementAnims[0] = 'Run_relaxed';
	else if ( Weapon.bPointing )
		MovementAnims[0] = 'Run';
	else
		MovementAnims[0] = 'Run';
	AnimateTurning();

	SetMovementAnim(2,'Run_Left','Run');
	SetMovementAnim(1,'Run_Back','Run');
	SetMovementAnim(3,'Run_Right','Run');
}

simulated function AnimateCrouchWalking()
{
	if ( !HasAnim('Crouch_Walk') )
	{
		AnimateRunning();
		return;
	}
	TurnLeftAnim = 'crouch_backpeddle';
	TurnRightAnim = 'crouch_backpeddle';

	MovementAnims[0] = 'Crouch_Walk';
	SetMovementAnim(2,'Crouch_Walk_left','Crouch_Walk');
	SetMovementAnim(1,'crouch_backpeddle','Crouch_Walk');
	SetMovementAnim(3,'Crouch_Walk_right','Crouch_Walk');
}


simulated function AnimateWalking()
{
	if ( !HasAnim('Walk') )
	{
		AnimateRunning();
		return;
	}
	AnimateTurning();

	MovementAnims[0] = 'Walk';
	SetMovementAnim(2,'Walk_Strafe_left','Walk');
	SetMovementAnim(1,'walk_backpeddle','Walk');
	SetMovementAnim(3,'walk_strafe_right','Walk');
}

defaultproperties
{
	JumpBlendInTime=0.05
	LandingBlendOutStart=0.2
	LandingTweenInTime=0.02
	FiringBlendTime=0.05
}