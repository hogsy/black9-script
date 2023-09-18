//=============================================================================
// B9_BasicPlayerPawn
//
// BasicPlayerPawns are the base class for the physical body of B9_PlayerControllers
//
//=============================================================================

class B9_BasicPlayerPawn extends B9_AdvancedPawn;	


//////////////////////////////////////////////////
// Variables
//
var public transient B9InventoryBrowser fInventoryBrowser;
var array<B9MissionObjective> fMissionObjectives;
var B9MissionObjective fCurrentMissionObjective;

var name UpperBodyAnim;
var name LastHitAnim;
var name LastPunchAnim;
var bool bNoChangeAnimation;

var byte		fWeaponCount; // Cap to 3 weapons
const			kMaxPlayerWeapons = 3;

var B9_Pawn	fGuidedTarget;
var int	  fKeyRingIndexMax;
var travel int	  fKeyRingIndex;
var travel string fKeyRing[15];
var	string	 fUserInputKey;

var Sound JumpSound;
var(Sounds) float JumpVolume;
var Sound FallingSound;
var(Sounds) float FallingVolume;

// Types
var const int kMultiplayerMissionType;


// RPG Stats
var travel public string fCharacterName;
var travel public string fCharacterOccupation;
var travel public string fCharacterCompany;

var travel public int	fCharacterCash;
var travel public int	fCharacterSkillPoints;		// unspent skill points
var travel public int	fCharacterConcludedMission;	// last mission completed
var travel public string	fCharacterConcludedMissionString; // String representation
var travel public int	fAcquiredCash;
var travel public int	fAcquiredSkillPoints;

replication
{
	// Variables the server should send to the client.

	reliable if( bNetDirty && bNetOwner && Role==ROLE_Authority )
		 fCharacterCash, fCharacterSkillPoints, fCharacterConcludedMission,
		fKeyRing,fKeyRingIndex;
	
	reliable if( Role<ROLE_Authority )
		fUserInputKey;

}

//////////////////////////////////////////////////
// Functions
//

simulated function SetGuidedTarget( B9_Pawn tgt )
{
	fGuidedTarget = tgt;
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	Super.TakeDamage( Damage, instigatedBy, hitlocation, momentum, damageType );

	if( Level.Netmode==NM_Standalone )
	{ 
		if( Damage > kDamageThresholdForKnockdown 
			&& fCanBeKnockedDownAgain
			&& ( !fJustFellHard || !fGettingUp )
			&& FRand() > 0.75 )
		{
			KnockDown( false );
		}
	}
}

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
	TurnLeftAnim		= 'nowpn_ladder_u';
	TurnRightAnim		= 'nowpn_ladder_u';

	if (bNoChangeAnimation)
  	{
  		bNoChangeAnimation = false;
  		ChangeAnimation();
  	}
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
		idleAnimName = 'rifle_idle';	
	}
	else if( weapKind == wepAnimKind_Pistol_1H )
	{
		idleAnimName = 'pistol_1H_fire_idle';
	}
	else if( weapKind == wepAnimKind_Melee_1H )
	{
		idleAnimName = 'melee_1h_idle';
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

simulated event ChangeAnimation()
{
	if( Level.Netmode==NM_Standalone )
	{
		if( IsAnimating( FALLINGCHANNEL ) && ! ( fJustFellHard || fJustFellModerate ) )
		{
			if( ( Acceleration.X != 0 || Acceleration.Y != 0 ) && !fJustPlayedRunningJump )
			{
				AnimBlendToAlpha( FALLINGCHANNEL, 0, 0.01 );
				fJustFellSoft = false;
			}
		}
	}

	PlayNext();
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
	local name fallingAnim;

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

	if( Level.Netmode==NM_Standalone )
	{
		if( fJustFellHard || fJustFellModerate || fGettingUp )
		{
			return;
		}

		// ImpactVel should take gravity & jumping skill into account
		//
		ImpactVel += ( fCharacterJumping * 5 ); // total guesswork on formula. Make better later.

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
	else
	{
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
	local name	animName;

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
			if( Level.Netmode==NM_Standalone )
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
				else if( Physics == PHYS_Walking && Controller.GetStateName() == 'SuspendPlayerInput' )
				{
					Controller.GotoState( fControllerLastState );
				}

				if( fJustPlayedRunningJump )
				{
					fJustPlayedRunningJump = false;
				}
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

///////////////////////////////////
// Character stuff
//
// Moved from B9_AdvancedPawn.  Will probably need to mnove a whole lot more in time.
function SetCharacterSpeed()
{

	//Super.SetCharacterSpeed();
	//GroundSpeed = 2000 * (fCharacterSpeed / +100.0);
}

function SetJumping(int skill_strength)
{
	Super.SetJumping( skill_strength );
	JumpZ=+01400.000000*( fCharacterJumping / 100.0 );
}

function SetCharacterHealth()
{
	local int Difference;
	local int LastMax;
	LastMax = fCharacterMaxHealth;
	Super.SetCharacterHealth();
	Difference = fCharacterMaxHealth - LastMax;
	Health = Health + Difference; // Adjust the current health up because we got more hit points (Or Lost maybe if we have a way to loose Constitution)
	if(Health > fCharacterMaxHealth)
	{
		Health = fCharacterMaxHealth;
	}
}


///////////////////////////////////
// Mission objectives
//
simulated function AddMissionObjective( B9MissionObjective objective )
{}

simulated function CompleteMissionObjective( B9MissionObjective objective )
{}

simulated function int GetNumMissionObjectives()
{
	return fMissionObjectives.Length;
}

simulated function string GetMissionObjectiveString( int index )
{
	local string Msg;

	if( index < fMissionObjectives.Length && fMissionObjectives[index] != none )
	{
		Msg = fMissionObjectives[index].Description;
	}
	else
	{
		Msg = "Bad Index";
	}

	return Msg;
}

simulated function bool IsMissionObjectiveComplete( int index )
{
	if( index < fMissionObjectives.Length && fMissionObjectives[index] != none )
	{
		return fMissionObjectives[index].fComplete;
	}
}

simulated function B9MissionObjective GetActiveObjective()
{
	local int index;

	for( index = 0; index < fMissionObjectives.Length; index++ )
	{
		if( fMissionObjectives[ index ] != None && !fMissionObjectives[ index ].fComplete )
		{
			return fMissionObjectives[ index ];
		}
	}

	return None;
}

// Totally temp function. Remove when the real PDA is in.
function TogglePDA()
{}

//////////////////////////////////////////////
//	Sounds - CR Note:  To make Players able to sneak but not NPCs
//
/*
simulated function FootStepping(int Side)
{
    local int SurfaceType, i;
	local actor A;
	local material FloorMat;
	local vector HL,HN,Start,End;
	
    SurfaceType = 0;
		
    for ( i=0; i<Touching.Length; i++ )
		if ( ((PhysicsVolume(Touching[i]) != None) && PhysicsVolume(Touching[i]).bWaterVolume)
			|| (FluidSurfaceInfo(Touching[i]) != None) )
		{
			// Was named something like this
			
			if ( FRand() < 0.5 )
				PlaySound( fStepWater1 ,SLOT_Interact, FootstepVolume );
			else
				PlaySound( fStepWater2 , SLOT_Interact, FootstepVolume );
			return;
		}

	if ( bIsCrouched || bIsWalking )
		return;
		
	if ( (Base!=None) && (!Base.IsA('LevelInfo')) && (Base.SurfaceType!=0) )
	{
		SurfaceType = Base.SurfaceType;
	}
	else
	{
		Start = Location - Vect(0,0,1)*CollisionHeight;
		End = Start - Vect(0,0,16);
		A = Trace(hl,hn,End,Start,false,,FloorMat);
		if ( A.IsA('TerrainInfo') )
		{
			SurfaceType = 2;
		}
		else if (FloorMat !=None)
		{
			SurfaceType = FloorMat.SurfaceType;
		}
	}
	
	PlaySound(SoundFootsteps[SurfaceType], SLOT_Interact, FootstepVolume,, 300, 0.85+FRand()*0.3,true );
}
*/

// fKeyRingIndexMax should be the same as the size of the KeyRingArray

defaultproperties
{
	fKeyRingIndexMax=15
	JumpSound=Sound'B9PlayerCharacters_sounds.NormalFemale.sahara_jump1'
	JumpVolume=1
	FallingSound=Sound'B9PlayerCharacters_sounds.NormalFemale.sahara_falling1'
	FallingVolume=0.2
}