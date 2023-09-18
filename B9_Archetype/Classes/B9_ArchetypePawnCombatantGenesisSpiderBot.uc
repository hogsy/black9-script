//////////////////////////////////////////////////////////////////////////
//
// Black 9 Combatant Archetype Genesis spider bot.
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnCombatantGenesisSpiderBot extends B9_ArchetypePawnCombatant;

// Load the animations package for the civilian archetype
#exec OBJ LOAD FILE=..\animations\B9_Genesis_Characters PACKAGE=B9_Genesis_Characters

var float			BounceDamping;
var(movement) Sound	ImpactSound;
var vector			fBounceVector;
var vector			fBounceVelocity;
var bool			fBounced;
var int				fBounces;
var bool			fCocked;
var bool			fFiringDone;
var	Sound			GunMovement1;
var Sound			GunMovement2;

var protected Sound fAlert[6];
var protected Sound fSpeech[4];
var protected float fLastSpoke;



simulated function vector GetTargetLocation()
{
	return Location;
}

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
	MovementAnims[0]	= 'nowpn_walk_f';
	MovementAnims[1]	= 'nowpn_walk_b';
	MovementAnims[2]	= 'nowpn_walk_step_l';
	MovementAnims[3]	= 'nowpn_walk_step_r';
	TurnLeftAnim		= 'nowpn_walk_step_l';
	TurnRightAnim		= 'nowpn_walk_step_r';
}

simulated function AnimateRunning()
{
	MovementAnims[0]	= 'nowpn_run_f';
	MovementAnims[1]	= 'nowpn_run_b';
	MovementAnims[2]	= 'nowpn_run_step_l';
	MovementAnims[3]	= 'nowpn_run_step_r';
	TurnLeftAnim		= 'nowpn_run_step_l';
	TurnRightAnim		= 'nowpn_run_step_r';
}

simulated function AnimateCrouchWalking()
{
	MovementAnims[0]	= 'nowpn_walk_f';
	MovementAnims[1]	= 'nowpn_walk_b';
	MovementAnims[2]	= 'nowpn_walk_step_l';
	MovementAnims[3]	= 'nowpn_walk_step_r';
	TurnLeftAnim		= 'nowpn_walk_step_l';
	TurnRightAnim		= 'nowpn_walk_step_r';
}

simulated function AnimateSwimming()
{
	MovementAnims[0]	= 'nowpn_walk_f';
	MovementAnims[1]	= 'nowpn_walk_b';
	MovementAnims[2]	= 'nowpn_walk_step_l';
	MovementAnims[3]	= 'nowpn_walk_step_r';
	TurnLeftAnim		= 'nowpn_walk_step_l';
	TurnRightAnim		= 'nowpn_walk_step_r';
}

simulated function AnimateFlying()
{
	MovementAnims[0]	= 'nowpn_walk_f';
	MovementAnims[1]	= 'nowpn_walk_b';
	MovementAnims[2]	= 'nowpn_walk_step_l';
	MovementAnims[3]	= 'nowpn_walk_step_r';
	TurnLeftAnim		= 'nowpn_walk_step_l';
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
	TurnLeftAnim		= 'nowpn_walk_step_l';
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
	LoopIfNeeded( 'nowpn_idle', 1.0, 0.0 );
}

simulated function AnimateStanding()
{
	LoopIfNeeded( 'nowpn_idle', 1.0, 0.0 );
}

simulated function name GetFiringAnim()
{
	return 'nowpn_fire';
}
simulated function name GetJumpAnim()
{
	if ( (Acceleration.X != 0) || (Acceleration.Y != 0) )
	{
		return 'nowpn_jump_forward_begin';
	}
	else
	{
		return 'nowpn_jump_up_begin';
	}
}
simulated function name GetFallingAnim()
{
	return 'nowpn_land_flailing';
}
simulated function name GetLandingAnim()
{
	return 'nowpn_jump_up_end';
}
simulated function name GetKnockdownAnim( bool fromBehind )
{
	if (fromBehind)
		return 'nowpn_knockdown_b';
	else
		return 'nowpn_knockdown_f';
}
simulated function name GetStandupAnim( bool fromBehind )
{
	if (fromBehind)
		return 'nowpn_standup_b';
	else
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

/////
///////////////////////////////
function name GetWeaponBoneFor(Inventory I)
{
	local Weapon W;

	W = Weapon(I);
	if (W != None && (W.ReloadCount % 2) == 0)
		return 'gun mount right';
	return 'gun mount left';
}

function PlayPreFire()
{
	//PlaySound(GunMovement1 ,SLOT_None, 1.0,, 200);
	AnimBlendParams(FIRINGCHANNEL,0.5);
	bSteadyFiring = false;

	Log("spider_small_open_fire");
	PlayAnim('nowpn_open_fire',,,FIRINGCHANNEL);
}

function PlayShoot()
{
	AnimBlendParams(FIRINGCHANNEL,0.5);
	bSteadyFiring = true;
	fCocked = true;

	Log("spider_small_shoot");
	LoopAnim('nopwn_fire',,,FIRINGCHANNEL);
}

function PlayPostFire()
{
	AnimBlendParams(FIRINGCHANNEL,0.5);
	bSteadyFiring = false;
	fCocked = false;

	Log("spider_small_cease_fire");
	
}

function bool IsInFiringState()
{
	return IsInState( 'Firing' ) || IsInState( 'Firing_Shoot' ) || IsInState( 'Firing_End' );
}


simulated function Landed( vector HitNormal )
{
	//Log("MikeT: Landed, fBounces: " $fBounces $" Dormant: " $res);
	if ( (fBounces > 1) || ( (Controller != None) && !Controller.IsInState('Dormant') ) )
	{
		bPhysicsAnimUpdate = true;
		Super.Landed(HitNormal);
		return;
	}

	fBounceVector = HitNormal;
	fBounceVelocity = Velocity;
	fBounced = true;
	//Log("MikeT: The Eagle has landed!, fBounceVector: " $fBounceVector $" fBounceVelocity: " $fBounceVelocity);
}

function Tick( float timeDelta )
{
	if (fBounced)
	{
		Velocity = fBounceVelocity;
		HitWall(fBounceVector, None);
		fBounced = false;
	}
}


simulated function HitWall( vector HitNormal, actor Wall )
{
	local int speed;
	local Vector vel;

	fBounces++;
	if (fBounces > 1)
	{
		//fBounces = 0;	// We only can bounce once, at the start.
		return;
	}

	vel		= BounceDamping * ( ( fBounceVelocity dot HitNormal ) * HitNormal * (-2.0) + fBounceVelocity );   // Reflect off Wall w/damping
	if (vel.Z > 800)
		vel.Z = 800;
	speed	= VSize( vel );
	if ( Level.NetMode != NM_DedicatedServer )
		PlaySound( ImpactSound, SLOT_Misc, 1.5, , 150, , true );
	if ( vel.Z > 200 )
	{
		SetPhysics( PHYS_Falling );
		vel.Z	= 0.5 * ( 400 + vel.Z );
		Falling();
	}
	else if ( speed < 20 ) 
	{
		SetRotation( Rotator( HitNormal ) );
		SetPhysics( PHYS_None );
	}
	
	Velocity = vel;
	SetPhysics( PHYS_Falling );
	bPhysicsAnimUpdate = false;
	//log("MikeT: HitWall End Velocity.Z: " $Velocity.Z);
}

simulated event PlayLandingAnimation(float ImpactVel)
{}

function AnimEnd( int Channel )
{
	if (Controller != None && Controller.GetStateName() == 'Dormant')
	{
		// Do nothing
	}
	else
	{
		Super.AnimEnd(Channel);
	}
}


function TakeFallingDamage()
{
	// No falling damage for little spider...
}

state Firing
{
	function BeginState()
	{
		Acceleration = vect( 0, 0, 0 );
		fShotsFiredInBurst = 0;
	}

	function AnimEnd( int Channel )
	{
//		Super.AnimEnd( Channel );

		if (Channel == FIRINGCHANNEL)
			GotoState('Firing_Shoot');
	}
Begin:
	if (fCocked)
		GotoState('Firing_Shoot');
	else
		PlayPreFire();
}

state Firing_Shoot
{
	function AnimEnd( int Channel )
	{
//		Super.AnimEnd( Channel );
		if (Channel == FIRINGCHANNEL)
			fFiringDone = true;
	}

	function bool Shoot()
	{
		local vector	fireDirection;
		local rotator	fireDirectionRot;
		local B9_AI_ControllerCombatant	C;
		
		C = B9_AI_ControllerCombatant(Controller);
		if (C == None)
			return false;
		
		switch (C.HasCombatItem())
		{
			case kWeapon:
				C.FireWeaponAt( C.Enemy );
				fShotsFiredInBurst++;
				return (B9WeaponBase(Weapon).fROF < fFiringInterval) && (fShotsFiredInBurst < fNumShotsInBurst);
			break;

			case kNanoTech:
				// Generate a fire direction vector
				fireDirection = C.Enemy.Location - Location;

				// Generate a fire direction rotator
				fireDirectionRot = rotator( fireDirection );

				// AFSNOTE: This will 'fire' the nano-weaponry in the direction that the enity is facing.
				fSelectedSkill.AIActivate( fireDirectionRot );
			break;
		}
		
		return false;
	}
Begin:
	PlaySound(GunMovement1 ,SLOT_None, 1.0,, 200);

	PlayShoot();
	while(Shoot())
	{
		fFiredFromCover = true;
		fFiringDone = false;
		if (B9WeaponBase(Weapon).fROF > 0.1)
			Sleep(B9WeaponBase(Weapon).fROF);
		else
			Sleep(0.1);
			
		//while (!fFiringDone)
		//	Sleep(0.1);
	}

	//log("MikeT: Refire rate: " $B9WeaponBase(Weapon).fROF);

	if (fFiringInterval > B9WeaponBase(Weapon).fROF)
		Sleep( fFiringInterval - B9WeaponBase(Weapon).fROF );
	GotoState('Firing_End');
}

state Firing_End
{
	function AnimEnd( int Channel )
	{
//		Super.AnimEnd( Channel );

		if (Channel == FIRINGCHANNEL)
		{
			//AnimBlendToAlpha(FIRINGCHANNEL,0,0.05);
			GotoState('Idle');
		}
	}
Begin:
	// Cease fire
	Controller.StopFiring();
	fShotsFiredInBurst = 0;
	//PlayPostFire();
}


function PlayEnemySpottedSound()
{
	PlaySound(fAlert[FRand() * 6], SLOT_Talk,,, 150, 0.85+FRand()*0.3,true );
}

function PlayIdleSpeech()
{
	if ( Controller.Level.TimeSeconds - fLastSpoke > FRand() * 4 + 5.0 )
	{
		fLastSpoke = Controller.Level.TimeSeconds;

		PlaySound(fSpeech[FRand() * 4], SLOT_Talk,,, 100, 0.85+FRand()*0.3,true );		
	}
}



defaultproperties
{
	BounceDamping=0.65
	GunMovement1=Sound'B9GenesisCharacters_sounds.SmallSpiderBot.recluse_gun_servo1'
	GunMovement2=Sound'B9GenesisCharacters_sounds.SmallSpiderBot.recluse_gun_servo2'
	fAlert[0]=Sound'B9GenesisCharacters_sounds.SmallSpiderBot.recluse_attack1'
	fAlert[1]=Sound'B9GenesisCharacters_sounds.SmallSpiderBot.recluse_attack2'
	fAlert[2]=Sound'B9GenesisCharacters_sounds.SmallSpiderBot.recluse_attack3'
	fAlert[3]=Sound'B9GenesisCharacters_sounds.SmallSpiderBot.recluse_attack4'
	fAlert[4]=Sound'B9GenesisCharacters_sounds.SmallSpiderBot.recluse_attack5'
	fSpeech[0]=Sound'B9GenesisCharacters_sounds.SmallSpiderBot.recluse_battle_cry1'
	fSpeech[1]=Sound'B9GenesisCharacters_sounds.SmallSpiderBot.recluse_battle_cry2'
	fSpeech[2]=Sound'B9GenesisCharacters_sounds.SmallSpiderBot.recluse_battle_cry3'
	fSpeech[3]=Sound'B9GenesisCharacters_sounds.SmallSpiderBot.recluse_battle_cry4'
	fWeaponIdentifierName="B9Weapons.AI_SmallSpider_Gun"
	bWeaponHidden=true
	fJumpAtEnemy=true
	fDamageImmunity5=Class'B9BasicTypes.damage_SpiderBotGun'
	fStartupState=0
	fCharacterMaxHealth=80
	FootstepVolume=0.25
	DeathSound=Sound'B9GenesisCharacters_sounds.SmallSpiderBot.recluse_death1'
	SoundFootsteps[0]=Sound'B9AllCharacters_sounds.Footsteps.foot_recluse_dirt1'
	SoundFootsteps[1]=Sound'B9AllCharacters_sounds.Footsteps.foot_recluse_dirt2'
	SoundFootsteps[2]=Sound'B9AllCharacters_sounds.Footsteps.foot_recluse_dirt3'
	SoundFootsteps[3]=Sound'B9AllCharacters_sounds.Footsteps.foot_recluse_dirt4'
	SoundFootsteps[4]=Sound'B9AllCharacters_sounds.Footsteps.foot_recluse_grass1'
	SoundFootsteps[5]=Sound'B9AllCharacters_sounds.Footsteps.foot_recluse_grass2'
	SoundFootsteps[6]=Sound'B9AllCharacters_sounds.Footsteps.foot_recluse_grass3'
	SoundFootsteps[7]=Sound'B9AllCharacters_sounds.Footsteps.foot_recluse_grass4'
	SoundFootsteps[8]=Sound'B9AllCharacters_sounds.Footsteps.foot_recluse_metfloor1'
	SoundFootsteps[9]=Sound'B9AllCharacters_sounds.Footsteps.foot_recluse_metfloor2'
	SoundFootsteps[10]=Sound'B9AllCharacters_sounds.Footsteps.foot_recluse_metfloor3'
	SoundFootsteps[11]=Sound'B9AllCharacters_sounds.Footsteps.foot_recluse_metfloor4'
	GroundSpeed=500
	WaterSpeed=350
	JumpZ=630
	BaseEyeHeight=5
	EyeHeight=5
	Health=80
	MenuName="B9_CombatantSpiderBot"
	ControllerClass=Class'B9_AI_ControllerCombatantGenesisSpider'
	Mesh=SkeletalMesh'B9_Genesis_characters.spider_bot_mesh'
	CollisionRadius=50
	CollisionHeight=25
	bBounce=true
	Buoyancy=100
}