//=============================================================================
// B9_ArchetypePawnCombatantDemoProtag
//
// AI version of the female protagonist, for demo mode purposes
//
//=============================================================================

class B9_ArchetypePawnCombatantDemoProtag extends B9_ArchetypePawnCombatant
	placeable;


var EPhysics	fLastPhysics;
var bool		fJustFellHard;
var bool		fJustFellModerate;
var bool		fJustFellSoft;
var bool		fGettingUp;
var name		fControllerLastState;
var bool		bPerformingExclusiveAction;

var bool		fCanBeKnockedDownAgain;
var float		fKnockdownTimer;

var byte		fWeaponCount; // Cap to 3 weapons
const			kMaxPlayerWeapons = 3;

var Sound JumpSound;
var(Sounds) float JumpVolume;
var Sound FallingSound;
var(Sounds) float FallingVolume;


//////////////////////////////////////////////////
// Functions
//

function PostBeginPlay()
{
	Super.PostBeginPlay();

	Bot(Controller).CombatStyle = fCombatStyle;
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{}

///////////////////////////////////
// AnimateXXX()
// Sets up the movement anims in response to movement type / physics changes
//
simulated function AnimateWalking()
{
	MovementAnims[0]	= 'nowpn_Walk_F';
	MovementAnims[1]	= 'nowpn_Walk_B';
	MovementAnims[2]	= 'nowpn_Walk_Step_L';
	MovementAnims[3]	= 'nowpn_Walk_Step_R';
	TurnLeftAnim		= 'nowpn_turn_l';
	TurnRightAnim		= 'nowpn_turn_r';
}

simulated function AnimateRunning()
{
	local WeaponAttachment.eWeaponAnimKind	weapKind;

	weapKind = GetWeaponKind();

	if( weapKind == wepAnimKind_Rifle || weapKind == wepAnimKind_Launcher || weapKind == wepAnimKind_Armature )
	{
		MovementAnims[0]	= 'rifle_Run_F';
		MovementAnims[1]	= 'rifle_Run_B';
		MovementAnims[2]	= 'rifle_Run_Step_L';
		MovementAnims[3]	= 'rifle_Run_Step_R';
	}
	else if( weapKind == wepAnimKind_Melee_1H )
	{
		MovementAnims[0]	= 'melee_1h_Run_F';
		MovementAnims[1]	= 'melee_1h_Run_B';
		MovementAnims[2]	= 'melee_1h_Run_Step_L';
		MovementAnims[3]	= 'melee_1h_Run_Step_R';
	}
	else if( weapKind == wepAnimKind_Pistol_1H )
	{
		MovementAnims[0]	= 'pistol_1h_Run_F';
		MovementAnims[1]	= 'pistol_1h_Run_B';
		MovementAnims[2]	= 'pistol_1h_Run_Step_L';
		MovementAnims[3]	= 'pistol_1h_Run_Step_R';
	}
	else
	{
		MovementAnims[0]	= 'nowpn_run_F';
		MovementAnims[1]	= 'nowpn_run_B';
		MovementAnims[2]	= 'nowpn_run_Step_L';
		MovementAnims[3]	= 'nowpn_run_Step_R';
	}

	TurnLeftAnim		= 'nowpn_turn_l';
	TurnRightAnim		= 'nowpn_turn_r';
}

simulated function AnimateCrouchWalking()
{
	MovementAnims[0]	= 'nowpn_crouch_f';
	MovementAnims[1]	= 'nowpn_crouch_b';
	MovementAnims[2]	= 'nowpn_crouch_Step_L';
	MovementAnims[3]	= 'nowpn_crouch_Step_R';
	TurnLeftAnim		= 'nowpn_crouch_Step_L';
	TurnRightAnim		= 'nowpn_crouch_Step_R';
}

simulated function AnimateSwimming()
{
	MovementAnims[0]	= 'nowpn_swim_f';
	MovementAnims[1]	= 'nowpn_swim_f';
	MovementAnims[2]	= 'nowpn_swim_f';
	MovementAnims[3]	= 'nowpn_swim_f';
	TurnLeftAnim		= 'nowpn_swim_f';
	TurnRightAnim		= 'nowpn_swim_f';
}

simulated function AnimateFlying()
{
	MovementAnims[0]	= 'nowpn_wingpack_forward';
	MovementAnims[1]	= 'nowpn_wingpack_backward';
	MovementAnims[2]	= 'nowpn_wingpack_slide_left';
	MovementAnims[3]	= 'nowpn_wingpack_slide_right';
	TurnLeftAnim		= 'nowpn_wingpack_slide_left';
	TurnRightAnim		= 'nowpn_wingpack_slide_right';
}

simulated function AnimateHovering()
{
	LoopIfNeeded('nowpn_wingpack_hover', 1.0, 0.0 );
}

simulated function AnimateClimbing()
{
	Weapon.ThirdPersonActor.bHidden = true;
	MovementAnims[0]	= 'nowpn_ladder_u';
	MovementAnims[1]	= 'nowpn_ladder_d';
	MovementAnims[2]	= 'nowpn_ladder_idle';
	MovementAnims[3]	= 'nowpn_ladder_idle';
	TurnLeftAnim		= '';
	TurnRightAnim		= '';
}

simulated function AnimateStoppedOnLadder()
{
	PlayAnim( 'nowpn_ladder_idle', 0.0 );
}

simulated function AnimateTreading()
{
	LoopIfNeeded('nowpn_swim_treadwater', 1.0, 0.0 ); 
}

simulated function AnimateCrouching()
{
	LoopIfNeeded('nowpn_crouch_idle', 1.0, 0.0 );
}

simulated function AnimateStanding()
{
	local name						idleAnimName;

	if ( (PlayerController(Controller) != None) && PlayerController(Controller).bIsTyping )
	{
		// FIXME - play chatting animation
		return;
	}

	if( fGettingUp || fJustFellHard )
	{
		return;
	}

	
	if( IsAnimating( FALLINGCHANNEL ) && ! ( fJustFellHard || fJustFellModerate ) )
	{
		if( ( Acceleration.X != 0 || Acceleration.Y != 0 ) && !fJustPlayedRunningJump )
		{
			AnimBlendToAlpha( FALLINGCHANNEL, 0, 0.01 );
			fJustFellSoft = false;
		}
	}

	idleAnimName	= GetIdleAnimName();

	LoopIfNeeded( idleAnimName, 1.0, 0.0 );
}

simulated function Name GetIdleAnimName()
{
	local int						which_idle;
	local name						idleAnimName;
	local WeaponAttachment.eWeaponAnimKind	weapKind;


	weapKind = GetWeaponKind();

	if( weapKind == wepAnimKind_Rifle || weapKind == wepAnimKind_Launcher || weapKind == wepAnimKind_Armature )
	{
		LoopIfNeeded('rifle_idle', 1.0, 0.0 );
	}
	else if( weapKind == wepAnimKind_Pistol_1H )
	{
		LoopIfNeeded( 'pistol_1H_fire_idle', 1.0, 0.0 );
	}
	else if( weapKind == wepAnimKind_Melee_1H )
	{
		LoopIfNeeded('melee_1h_idle', 1.0, 0.0 );
	}
	else
	{		
		which_idle = Rand(100);

		if( which_Idle < 30 ) 
		{
			idleAnimName = 'nowpn_idle';
		}
		else if( which_Idle < 60 ) 
		{
			idleAnimName = 'nowpn_idle_1';
		}
		else if( which_Idle < 70 ) 
		{
			idleAnimName = 'nowpn_idle_2';
		}
		else if( which_Idle < 80 ) 
		{
			idleAnimName = 'nowpn_idle_3';
		}
		else if( which_Idle < 90 ) 
		{
			idleAnimName = 'nowpn_idle_4';
		}
		else
		{
			idleAnimName = 'nowpn_idle_5';
		}
	}

	return idleAnimName;
}

///////////////////////////////////
// Firing
//
simulated function PlayFiring(float Rate, name FiringMode)
{
	local WeaponAttachment.eWeaponAnimKind weapKind;

	AnimBlendParams( FIRINGCHANNEL, 1.0, 0.0, 0.0, GetBoneForShooting(), true );

	weapKind = GetWeaponKind();

	if( weapKind == wepAnimKind_Pistol_1H )
	{
		if( fMovementMode == MOVE_Run )
		{
			PlayAnim( 'pistol_1H_run_f_fire', 1.0, 0.0, FIRINGCHANNEL );
		}
		else
		{
			PlayAnim( 'pistol_1H_fire', 1.0, 0.0, FIRINGCHANNEL );
		}
	}
	else if( weapKind == wepAnimKind_Rifle || weapKind == wepAnimKind_Launcher || weapKind == wepAnimKind_Launcher )
	{
		PlayAnim( 'rifle_fire', 1.0 , 0.0, FIRINGCHANNEL );
	}
	else if( weapKind == wepAnimKind_Melee_1H )
	{
		PlayAnim( 'melee_1H_run_f_swing', 1.0 , 0.0, FIRINGCHANNEL );
	}
	else
	{
		PlayAnim( 'melee_punch_right_hook', 1.0, 0.0, FIRINGCHANNEL);
	}
}


///////////////////////////////////
// Jumping
//
simulated event PlayJump()
{
	local name animName;

	if ( (Acceleration.X != 0) || (Acceleration.Y != 0) )
	{
		fJustPlayedRunningJump = true;
		if ( Weapon == None )
		{
			animName = 'nowpn_jump_run_f_begin';
		}
		else
		{
			animName = 'nowpn_jump_run_f_begin';
		}
	}
	else
	{
		if ( Weapon == None )
		{
			animName = 'nowpn_jump_u_begin';
		}
		else
		{
			animName = 'nowpn_jump_u_begin';
		}
	}

	//log ("CR - b9basicplayerpawn.uc - jumping sounds");
	VoiceSoundDelay( 0.5, JumpSound, SLOT_None, JumpVolume,400);

	PlayAnim( animName );
}

///////////////////////////////////
// Falling
//
simulated event PlayFalling()
{
	if( Velocity.Z <= kLongFallAccel )
	{
		LoopIfNeeded( 'nowpn_land_flailing', 1.0, 0.35 );
		VoiceSoundDelay( 100,FallingSound, SLOT_None, FallingVolume,400);
	}
	else if( Velocity.Z <= kNormalLandingThreshold )
	{
		LoopIfNeeded( 'nowpn_land_falling', 1.0, 0.35 );
	}
}

///////////////////////////////////
// Landing
//
simulated event PlayLandingAnimation(float ImpactVel)
{
	if( ImpactVel == 0 || Health <= 0 )
	{
		return;
	}

	if( fJustFellHard || fJustFellModerate || fGettingUp )
	{
		return;
	}

	// Looooooong fall
	//
	if( ImpactVel < kLongFallAccel  )
	{
		fJustFellHard = true;

		Velocity = vect( 0.0, 0.0, 0.0 );

		fControllerLastState = Controller.GetStateName();
		Controller.GotoState( 'SuspendPlayerInput' );
		
		AnimBlendParams( FALLINGCHANNEL, 1.0, 0.0, 0.0, GetRootBone(), true );
		PlayAnim( 'nowpn_knockdown_b', 1.0, 0.0, FALLINGCHANNEL );
	}

	// Moderate fall
	//
	else if( ImpactVel < kNormalLandingThreshold )
	{
		fJustFellModerate = true;

		Velocity = vect( 0.0, 0.0, 0.0 );

		fControllerLastState = Controller.GetStateName();
		Controller.GotoState( 'SuspendPlayerInput' );
		
		AnimBlendParams( FALLINGCHANNEL, 1.0, 0.0, 0.0, GetRootBone(), true );
		PlayAnim( 'nowpn_jump_u_end', 1.0, 0.0, FALLINGCHANNEL );
	}

	// Not really a fall; just jumped
	//
	else
	{
		fJustFellSoft = true;

		if( (Acceleration.X != 0) || (Acceleration.Y != 0) )
		{
			AnimBlendParams( FALLINGCHANNEL, 1.0, 0.0, 0.45, GetRootBone(), true );
			PlayAnim( 'nowpn_jump_run_f_end',1.0, 0.0, FALLINGCHANNEL );
		}
		else
		{
			AnimBlendParams( FALLINGCHANNEL, 1.0, 0.0, 0.0, GetRootBone(), true );
			PlayAnim( 'nowpn_jump_u_end', 1.0, 0.0, FALLINGCHANNEL );
		}
	}
}

///////////////////////////////////
// Knocked down from damage
//
simulated function KnockDown( bool fromBehind )
{
	AnimBlendParams( FALLINGCHANNEL, 1.0, 0.0, 0.0, GetRootBone(), true );

	fCanBeKnockedDownAgain	= false;
	fKnockdownTimer			= kKnockdownDelay;

	Velocity = vect( 0.0, 0.0, 0.0 );


	if( fromBehind )
	{
		fJustFellHard = true;

		fControllerLastState = Controller.GetStateName();
		Controller.GotoState( 'SuspendPlayerInput' );
		
		AnimBlendParams( FALLINGCHANNEL, 1.0, 0.0, 0.0, GetRootBone(), true );
		PlayAnim( 'nowpn_knockdown_b', 1.0, 0.0, FALLINGCHANNEL );
	}
	else
	{
		fJustFellHard = true;

		fControllerLastState = Controller.GetStateName();
		Controller.GotoState( 'SuspendPlayerInput' );
		
		AnimBlendParams( FALLINGCHANNEL, 1.0, 0.0, 0.0, GetRootBone(), true );
		PlayAnim( 'nowpn_knockdown_b', 1.0, 0.0, FALLINGCHANNEL );
	}
}

///////////////////////////////////
// Getting up after a hard fall
//
simulated function PlayGettingUp()
{
	AnimBlendParams( FALLINGCHANNEL, 1.0, 0.0, 0.0, GetRootBone(), true );
	PlayAnim( 'nowpn_standup_b',1.0, 0.0, FALLINGCHANNEL );
}

///////////////////////////////////
// Reloading
//
simulated function PlayReloadingAnim()
{
	local WeaponAttachment.eWeaponAnimKind weapKind;
	local name AnimName;

	weapKind = GetWeaponKind();

	if( weapKind == wepAnimKind_Rifle || weapKind == wepAnimKind_Launcher || weapKind == wepAnimKind_Armature )
	{
		AnimName = 'pistol_1h_reload';
	}
	else
	{
		AnimName = 'pistol_1h_reload';
	}
	
	AnimBlendParams( FIRINGCHANNEL, 1.0, 0.0, 0.0, GetBoneForReloading(), true );
	PlayAnim( AnimName, 1.0, 0.0, FIRINGCHANNEL );
}



///////////////////////////////////
// Lower-level calls to update animation state
//
simulated event AnimEnd(int Channel)
{
	
	if( Channel == 0 )
	{
		PlayWaiting();
  	}
	
	else if ( Channel == FIRINGCHANNEL )
	{
		if ( !bSteadyFiring )
		{
			AnimBlendToAlpha( FIRINGCHANNEL, 0, 0.1 );
		}
	}

	else if ( Channel == TAKEHITCHANNEL )
	{
		AnimBlendToAlpha( TAKEHITCHANNEL, 0, 0.1 );
		Controller.fTakingAHit = false;
	}

	else if ( Channel == FALLINGCHANNEL )
	{
		if( Physics == PHYS_Falling )
		{
			PlayFalling();
		}
		else
		{
			if( fJustFellHard )
			{
				fJustFellHard	= false;
				fGettingUp		= true;
				PlayGettingUp();
				return;
			}
			else if( fJustFellModerate )
			{
				fJustFellModerate = false;
				if( Controller.GetStateName() == 'SuspendPlayerInput' )
				{
                    Controller.GotoState( fControllerLastState );
				}
			}
			else if( fJustFellSoft )
			{
				fJustFellSoft = false;
			}
			else if( fGettingUp )
			{
				fGettingUp = false;

				if( Controller.GetStateName() == 'SuspendPlayerInput' )
				{
                    Controller.GotoState( fControllerLastState );
				}
			}
			
			if( fJustPlayedRunningJump )
			{
				fJustPlayedRunningJump = false;
			}

			AnimBlendToAlpha( FALLINGCHANNEL, 0, 0.01 );
			PlayWaiting();
		}
	}
}

/////////////////////////////////////////
/// GetXXXAnim() calls
//
simulated function name GetDyingAnim( vector HitLoc )
{
	local vector X, Y, Z, Dir;

	GetAxes( Rotation, X, Y, Z );
	Dir = Normal( HitLoc - Location );

	if( ( Dir Dot X ) > 0  )
	{
		return 'nowpn_knockdown_b';
	}
	else
	{
		return 'nowpn_knockdown_f';
	}
}

function bool IsDemoProtagPawn()
{
	return true;
}

defaultproperties
{
	fCanBeKnockedDownAgain=true
	JumpSound=Sound'B9PlayerCharacters_sounds.NormalFemale.sahara_jump1'
	JumpVolume=1
	FallingSound=Sound'B9PlayerCharacters_sounds.NormalFemale.sahara_falling1'
	FallingVolume=0.2
	fCharacterBaseAgility=40
	fCharacterBaseDexterity=35
	fCharacterBaseConstitution=45
	fCharacterMaxHealth=160
	fIsLeftHanded=true
	FootstepVolume=0.15
	DeathSound=Sound'B9PlayerCharacters_sounds.NormalFemale.sahara_death1'
	HurtSound1=Sound'B9PlayerCharacters_sounds.NormalFemale.sahara_shot1'
	HurtSound2=Sound'B9PlayerCharacters_sounds.NormalFemale.sahara_shot2'
	HurtSound3=Sound'B9PlayerCharacters_sounds.NormalFemale.sahara_shot3'
	SoundFootsteps[0]=Sound'B9AllCharacters_sounds.Footsteps.foot_shoe_metal1'
	SoundFootsteps[1]=Sound'B9SoundFX.Protagonist.prot_walking_loopable'
	SoundFootsteps[2]=Sound'B9AllCharacters_sounds.Footsteps.foot_shoe_dirt1'
	SoundFootsteps[3]=Sound'B9AllCharacters_sounds.Footsteps.foot_shoe_metal1'
	SoundFootsteps[4]=Sound'B9SoundFX.Protagonist.prot_walking_loopable'
	SoundFootsteps[5]=Sound'B9SoundFX.Protagonist.prot_walking_loopable'
	SoundFootsteps[6]=Sound'B9SoundFX.Protagonist.prot_walking_loopable'
	SoundFootsteps[7]=Sound'B9SoundFX.Protagonist.prot_walking_loopable'
	SoundFootsteps[8]=Sound'B9SoundFX.Protagonist.prot_walking_loopable'
	SoundFootsteps[9]=Sound'B9SoundFX.Protagonist.prot_walking_loopable'
	SoundFootsteps[10]=Sound'B9AllCharacters_sounds.Footsteps.foot_shoe_grass1'
	SoundFootsteps[11]=Sound'B9SoundFX.Protagonist.prot_walking_loopable'
	bCanCrouch=false
	bCanSwim=false
	bCanClimbLadders=false
	AirSpeed=1000
	WalkingPct=0.35
	CrouchedPct=0.25
	BaseEyeHeight=144
	Health=160
	MenuName="B9_DemoProtag_Pawn"
	MovementAnims[0]=nowpn_Run_F
	MovementAnims[1]=nowpn_Run_B
	MovementAnims[2]=nowpn_Run_Step_L
	MovementAnims[3]=nowpn_Run_Step_R
	Mesh=SkeletalMesh'B9_Player_Characters.Normal_Female_mesh'
}