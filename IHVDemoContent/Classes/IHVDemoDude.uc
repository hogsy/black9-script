class IHVDemoDude extends Pawn;

#exec OBJ LOAD FILE=..\animations\COGStandardSoldiers.ukx PACKAGE=COGStandardSoldiers

const RESTINGPOSECHANNEL = 0;
const FALLINGCHANNEL = 1;

var sound Land, JumpSound, LandGrunt, LandSound; //FIXME - fill in sounds

simulated function PostBeginPlay()
{
	local InventoryAttachment W;

	Super.PostBeginPlay();

	W = Spawn(class'IHVWeapon',self);
	AttachToBone(W,'weapon_bone');

	W.SetRelativeLocation(W.Default.RelativeLocation);
	W.SetRelativeRotation(W.Default.RelativeRotation);
}

// Notify called when ready to land (should loop)
function CheckLanding()
{
	if ( Physics == PHYS_Falling )
	{
		// stop animating, haven't landed yet
		TweenAnim('Land', 9000.0);
	}
}

//-----------------------------------------------------------------------------
// Animation functions

simulated event AnimEnd(int Channel)
{
	if ( Channel == 0 )
		PlayWaiting();
	else if ( Channel == FALLINGCHANNEL )
	{
		if ( Physics != PHYS_Falling )
		{
			AnimBlendToAlpha(FALLINGCHANNEL,0,0.1);
			PlayWaiting();
		}
		else
			PlayFalling();
	}
}

simulated event ChangeAnimation()
{
	if ( (Controller != None) && Controller.bControlAnimations )
		return;
	// player animation - set up new idle and moving animations
	PlayWaiting();
	PlayMoving();
}

//-----------------------------------------------------------------------------
// Player Animation functions

simulated function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc)
{
	if ( FRand() < 0.8 )
		PlayAnim('death_neck',1.0,0.15);
	else
		PlayAnim('death_fire',1.0,0.15);
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	bPlayedDeath = true;
	if ( bPhysicsAnimUpdate )
	{
		bTearOff = true;
		bReplicateMovement = false;
		HitDamageType = DamageType;
		TakeHitLocation = HitLoc;
		if ( (HitDamageType != None) && (HitDamageType.default.GibModifier >= 100) )
			ChunkUp(Rotation, DamageType);
	}
	Velocity += TearOffMomentum;
	SetPhysics(PHYS_Falling);

	AnimBlendToAlpha(FALLINGCHANNEL,0,0.1);
	PlayDyingAnim(DamageType,HitLoc);
	GotoState('Dying');
}
			
function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType)
{
	local vector X,Y,Z,Dir;

	GetAxes(Rotation,X,Y,Z);
	Dir = Normal(HitLoc - Location);
	Super.PlayTakeHit(HitLoc,Damage,damageType);
}

simulated event PlayFalling()
{
	PlayJump();
}

simulated event PlayJump()
{
	PlayOwnedSound(JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );
	BaseEyeHeight =  0.7 * Default.BaseEyeHeight;
	if ( (Acceleration.X != 0) || (Acceleration.Y != 0) )
		PlayAnim('Jump_run');
	else
		PlayAnim('Jump_stand'); 
}

function PlayLanded(float impactVel)
{	
	impactVel = impactVel/JumpZ;
	impactVel = 0.1 * impactVel * impactVel;
	BaseEyeHeight = Default.BaseEyeHeight;

	if ( impactVel > 0.17 )
		PlayOwnedSound(LandGrunt, SLOT_Talk, FMin(5, 5 * impactVel),false,1200,FRand()*0.4+0.8);
	if ( (impactVel > 0.01) && !TouchingWaterVolume() )
		PlayOwnedSound(Land, SLOT_Interact, FClamp(4 * impactVel,0.5,5), false,1000, 1.0);
}

simulated event PlayLandingAnimation(float ImpactVel)
{
	if ( (impactVel > 0.06) || IsAnimating(FALLINGCHANNEL) ) 
	{
		PlayWaiting();
	}
	else if ( !IsAnimating(0) )
		PlayWaiting();
}

simulated function PlayWaiting()
{
	if ( Physics == PHYS_Swimming )
		AnimateTreading();
	else if ( Physics == PHYS_Flying )
		AnimateFlying();
	else if ( Physics == PHYS_Ladder )
		AnimateStoppedOnLadder();
	else if ( Physics == PHYS_Falling )
	{
		if ( !IsAnimating(FALLINGCHANNEL) )
			PlayFalling();
	}
	else if ( bIsCrouched )
		AnimateCrouching();
	else if ( bSteadyFiring )
		PlayFiring(1.0,'');
	else
		AnimateStanding();
}

simulated function PlayMoving()
{
	if ( (Physics == PHYS_None) 
		|| ((Controller != None) && Controller.bPreparingMove) )
	{
		// bot is preparing move - not really moving 
		PlayWaiting();
		return;
	}
	if ( Physics == PHYS_Walking )
	{
		if ( bIsCrouched )
			AnimateCrouchWalking();
		else if ( bIsWalking )
			AnimateWalking();
		else
			AnimateRunning();
	}
	else if ( (Physics == PHYS_Swimming)
		|| ((Physics == PHYS_Falling) && IsPlayingSwimming() && TouchingWaterVolume()) )
		AnimateSwimming();
	else if ( Physics == PHYS_Ladder )
		AnimateClimbing();
	else if ( Physics == PHYS_Flying )
		AnimateFlying();
	else
	{
		if ( bIsCrouched )
			AnimateCrouchWalking();
		else if ( bIsWalking )
			AnimateWalking();
		else
			AnimateRunning();
	}
}

/* LoopIfNeeded()
play looping idle animation only if not already animating
*/
simulated function LoopIfNeeded(name NewAnim, float NewRate, float BlendIn)
{
	local name OldAnim;
	local float frame,rate;

	GetAnimParams(0,OldAnim,frame,rate);

	// FIXME - get tween time from anim
	if ( (NewAnim != OldAnim) || (NewRate != Rate) || !IsAnimating(0) )
		LoopAnim(NewAnim, NewRate, BlendIn);
	else
		LoopAnim(NewAnim, NewRate);
}
//************************************************************************************
// Private animation functions

// Current assumptions
// 
// all swimming and treading water anims should belong to the group SWIMMING
// all running anims should belong to the group RUNNING

simulated function bool IsPlayingSwimming()
{
	return AnimIsInGroup(0,'SWIMMING');
}

/* AnimateSwimming()
Moving through water - check acceleration for direction
*/
simulated function AnimateSwimming()
{
	MovementAnims[0] = 'Swim';
	MovementAnims[1] = 'Swim';
	MovementAnims[2] = 'Swim';
	MovementAnims[3] = 'Swim';
}

/* AnimateTreading()
Still in water
*/
simulated function AnimateTreading()
{
	MovementAnims[0] = 'Swim';
	MovementAnims[1] = 'Swim';
	MovementAnims[2] = 'Swim';
	MovementAnims[3] = 'Swim';
}

/* AnimateCrouchWalking()
crouching and walking
*/
simulated function AnimateCrouchWalking()
{
	TurnLeftAnim = 'crouch_backpeddle';
	TurnRightAnim = 'crouch_backpeddle';
	MovementAnims[0] = 'Crouch_Walk';
	MovementAnims[2] = 'Crouch_Walk_left';
	MovementAnims[1] = 'crouch_backpeddle';
	MovementAnims[3] = 'Crouch_Walk_right';
}

simulated function AnimateWalking()
{
	TurnLeftAnim = 'turn_left';
	TurnRightAnim = 'turn_right';
	MovementAnims[0] = 'Walk';
	MovementAnims[2] = 'walk_strafe_left';
	MovementAnims[1] = 'walk_backpeddle';
	MovementAnims[3] = 'walk_strafe_right';
}

/* AnimateClimbing()
climbing
*/
simulated function AnimateClimbing()
{
	local name NewAnim;
	local int i;

	if ( (OnLadder == None) || (OnLadder.ClimbingAnimation == '') )
		NewAnim = 'Ladder_Climb'; 
	else
		NewAnim = OnLadder.ClimbingAnimation;
	for ( i=0; i<4; i++ )
		MovementAnims[i] = NewAnim;
	TurnLeftAnim = NewAnim;
	TurnRightAnim = NewAnim;
}

simulated function AnimateStoppedOnLadder()
{
	local name NewAnim;

	if ( (OnLadder == None) || (OnLadder.ClimbingAnimation == '') )
		NewAnim = 'Ladder_Climb'; 
	else
		NewAnim = OnLadder.ClimbingAnimation;
	TweenAnim(NewAnim, 1.0); // FIXME TEMP - need paused on ladder animation
}

/* AnimateFlying()
flying - not used in Warfare, so don't need real animation
*/
simulated function AnimateFlying()
{
	AnimateSwimming();
}

simulated function AnimateStanding()
{
	if ( (PlayerController(Controller) != None) && PlayerController(Controller).bIsTyping )
	{
		// FIXME - play chatting animation
		return;
	}

	LoopIfNeeded('Stand_Rdy',1.0,0.1);
}

simulated function AnimateCrouching()
{
	LoopIfNeeded('Crouch',1.0,0.25);
}
	
simulated function AnimateRunning()
{
	if ( Weapon == None )
		MovementAnims[0] = 'Run_relaxed';
	else if ( Weapon.bPointing )
		MovementAnims[0] = 'Run';
	else
		MovementAnims[0] = 'Run';
	TurnLeftAnim = 'turn_left';
	TurnRightAnim = 'turn_right';
	MovementAnims[2] = 'Run_Left';
	MovementAnims[1] = 'Run_Back';
	MovementAnims[3] = 'Run_Right';
}

defaultproperties
{
	bCanCrouch=true
	bCanClimbLadders=true
	bCanStrafe=true
	bCanPickupInventory=true
	JumpZ=540
	WalkingPct=0.3
	BaseEyeHeight=60
	EyeHeight=60
	CrouchHeight=39
	ControllerClass=Class'IHVBot'
	bPhysicsAnimUpdate=true
	LightBrightness=70
	LightRadius=6
	LightHue=40
	LightSaturation=128
	Physics=2
	bStasis=false
	ForceType=1
	ForceRadius=100
	ForceScale=1
}