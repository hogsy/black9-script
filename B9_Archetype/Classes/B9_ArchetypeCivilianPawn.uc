//////////////////////////////////////////////////////////////////////////
//
// Black 9 Civilian Archetype Pawn Base Class
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypeCivilianPawn extends B9_ArchetypePawnBase placeable;

// Load the animations package for the civilian archetype
#exec OBJ LOAD FILE=..\animations\B9_Civilian_Characters.ukx PACKAGE=B9_Civilian_Characters

// Load the sound package for the civilian archetype	 
//#exec OBJ LOAD FILE=..\Sounds\B9_ArchetypeCivilian.uax PACKAGE=B9_ArchetypeCivilian

// Variables
var(AI) name	fCowerAnimationName;
var(AI) bool	fIsAggressive;		// defaults to false
var(AI) bool	fCanTeleport;
//var(AI) class	fHidingFromPawnClass;
var(AI) bool	fFollowWhenBumpedByPlayer;
var(AI) name	fDropOffPoint;
var(AI) float	fDropOffRadius;
var protected Sound		fIdle[2];
var protected Sound		fTouched[2];
var protected float		fLastSpoke;

var B9_CivilianTrigger	fUseTrigger;		// The trigger to help us use a civilian.

function PhysicsVolumeChange( PhysicsVolume NewVolume )
{
//Log("MikeT: PhysicsVolumeChange: " $Physics);
	if( NewVolume.bWaterVolume )
	{
		SetPhysics( PHYS_Swimming );
		AnimateSwimming();
	}
	else
	{
		SetPhysics( PHYS_Falling );
		AnimateWalking();
	}
}

// Overridden functions
event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Add the trigger so we can use the civilian.
	fUseTrigger = Spawn( class 'B9_CivilianTrigger', self, , Location);
	if (fUseTrigger != None)
	{
		fUseTrigger.SetBase( Self );
		fUseTrigger.SetCollision( true, false, false );
	}

	if (fIsAggressive)
	{
		GiveWeapon("B9Weapons.pistol_9mm");

		Weapon.AmmoType.AmmoAmount = 12;
		Weapon.ReloadCount = 3;
	}
	
	PhysicsVolumeChange(PhysicsVolume);
}


function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if ( bDeleteMe )
		return; //already destroyed

/*
	// mutator hook to prevent deaths
	// WARNING - don't prevent bot suicides - they suicide when really needed
	if ( Level.Game.PreventDeath(self, Killer, damageType, HitLocation) )
	{
		Health = max(Health, 1); //mutator should set this higher
		return;
	}
*/
	Health = Min(0, Health);
	Level.Game.Killed(Killer, Controller, self, damageType);

	if ( Killer != None )
		TriggerEvent(Event, self, Killer.Pawn);
	else
		TriggerEvent(Event, self, None);

	Velocity.Z *= 1.3;
/*
	if ( IsHumanControlled() )
		PlayerController(Controller).ForceDeathUpdate();
	if ( (DamageType != None) && (DamageType.default.GibModifier >= 100) )
		ChunkUp(-1 * Health);
	else
	{
*/
		PlayDying(DamageType, HitLocation);
		if ( Level.Game.bGameEnded )
			return;
		if ( !bPhysicsAnimUpdate && !IsLocallyControlled() )
			ClientDying(DamageType, HitLocation);
/*
	}
*/
}

// Operations
function PlayWalkingSound()
{
	if ( Controller.Level.TimeSeconds - fLastSpoke > FRand() * 12 + 10.0 )
	{
		fLastSpoke = Controller.Level.TimeSeconds;		
		PlaySound(fIdle[Rand(2)], SLOT_Talk, 0.3,, 50);		
	}
}


function PlayBumpedSound()
{
	if ( Controller.Level.TimeSeconds - fLastSpoke > FRand() * 4 + 2.0 )
	{
		fLastSpoke = Controller.Level.TimeSeconds;
		PlaySound(fTouched[1], SLOT_Talk, 1.0,, 50);		
	}
}

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
	TurnLeftAnim		= 'nowpn_walk_step_L';
	TurnRightAnim		= 'nowpn_walk_step_r';
}

simulated function AnimateRunning()
{
	MovementAnims[0]	= 'nowpn_run_f';
	MovementAnims[1]	= 'nowpn_run_b';
	MovementAnims[2]	= 'nowpn_run_step_l';
	MovementAnims[3]	= 'nowpn_run_step_r';
	TurnLeftAnim		= 'nowpn_run_step_L';
	TurnRightAnim		= 'nowpn_run_step_r';
}

simulated function AnimateCrouchWalking()
{
	MovementAnims[0]	= 'nowpn_crouch_f';
	MovementAnims[1]	= 'nowpn_crouch_b';
	MovementAnims[2]	= 'nowpn_crouch_step_l';
	MovementAnims[3]	= 'nowpn_crouch_step_r';
	TurnLeftAnim		= 'nowpn_crouch_step_L';
	TurnRightAnim		= 'nowpn_crouch_step_r';
}

simulated function AnimateSwimming()
{
	MovementAnims[0]	= 'nowpn_walk_f';
	MovementAnims[1]	= 'nowpn_walk_b';
	MovementAnims[2]	= 'nowpn_walk_step_l';
	MovementAnims[3]	= 'nowpn_walk_step_r';
	TurnLeftAnim		= 'nowpn_walk_step_L';
	TurnRightAnim		= 'nowpn_walk_step_r';
}

simulated function AnimateFlying()
{
	MovementAnims[0]	= 'nowpn_walk_f';
	MovementAnims[1]	= 'nowpn_walk_b';
	MovementAnims[2]	= 'nowpn_walk_step_l';
	MovementAnims[3]	= 'nowpn_walk_step_r';
	TurnLeftAnim		= 'nowpn_walk_step_L';
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
	TurnLeftAnim		= 'nowpn_walk_step_L';
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
	LoopIfNeeded( 'nowpn_crouch_idle', 1.0, 0.0 );
}

simulated function AnimateStanding()
{
	if( bPhysicsAnimUpdate==true )
	{
		LoopIfNeeded( 'nowpn_bob_head', 1.0, 0.0 );
	}
}

simulated function name GetFiringAnim()
{
	return '';
}
simulated function name GetJumpAnim()
{
	if ( (Acceleration.X != 0) || (Acceleration.Y != 0) )
	{
		return '';
	}
	else
	{
		return '';
	}
}
simulated function name GetFallingAnim()
{
	return '';
}
simulated function name GetLandingAnim()
{
	return '';
}
simulated function name GetKnockdownAnim( bool fromBehind )
{
	return '';
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

	log( "------ HitDir: "$Dir Dot X );

	return '';
}

// Properites
defaultproperties
{
	fCowerAnimationName=Cower
	fDropOffRadius=100
	fIdle[0]=Sound'B9_ArchetypeCivilian.Idle.MildHum'
	fIdle[1]=Sound'B9_ArchetypeCivilian.Idle.WhereAmIMumble'
	fTouched[0]=Sound'B9_ArchetypeCivilian.Idle.ClearingThroat'
	fTouched[1]=Sound'B9_ArchetypeCivilian.Idle.TouchedExcuseme'
	fDefaultIdleAnimationName=ambient1
	FootstepVolume=0.15
	HurtSound1=Sound'B9Weapons_sounds.Firearms.bullet_flesh1'
	HurtSound2=Sound'B9Weapons_sounds.Firearms.bullet_flesh2'
	HurtSound3=Sound'B9Weapons_sounds.Firearms.bullet_flesh3'
	HurtVolume=0.25
	SoundFootsteps[0]=Sound'B9AllCharacters_sounds.Footsteps.foot_shoe_dirt1'
	SoundFootsteps[1]=Sound'B9AllCharacters_sounds.Footsteps.foot_shoe_dirt2'
	SoundFootsteps[2]=Sound'B9AllCharacters_sounds.Footsteps.foot_shoe_dirt3'
	SoundFootsteps[3]=Sound'B9AllCharacters_sounds.Footsteps.foot_shoe_dirt4'
	SoundFootsteps[4]=Sound'B9AllCharacters_sounds.Footsteps.foot_shoe_grass1'
	SoundFootsteps[5]=Sound'B9AllCharacters_sounds.Footsteps.foot_shoe_grass2'
	SoundFootsteps[6]=Sound'B9AllCharacters_sounds.Footsteps.foot_shoe_grass3'
	SoundFootsteps[7]=Sound'B9AllCharacters_sounds.Footsteps.foot_shoe_grass4'
	SoundFootsteps[8]=Sound'B9AllCharacters_sounds.Footsteps.foot_shoe_metal1'
	SoundFootsteps[9]=Sound'B9AllCharacters_sounds.Footsteps.foot_shoe_metal2'
	SoundFootsteps[10]=Sound'B9AllCharacters_sounds.Footsteps.foot_shoe_metal3'
	SoundFootsteps[11]=Sound'B9AllCharacters_sounds.Footsteps.foot_shoe_metal4'
	GroundSpeed=215
	WaterSpeed=350
	WalkingPct=0.25
	CrouchedPct=0.25
	MenuName="B9_Civilian"
	ControllerClass=Class'B9_AI_ControllerCivilian'
	MovementAnims[0]=ambient1
	MovementAnims[1]=ambient1
	MovementAnims[2]=ambient1
	MovementAnims[3]=ambient1
	Mesh=SkeletalMesh'B9_Civilian_Characters.Civilian_variant_d_mesh'
	Buoyancy=100
}