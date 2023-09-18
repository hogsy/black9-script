//////////////////////////////////////////////////////////////////////////
//
// Black 9 Combatant Archetype Zubrin Tiburon bot.
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnCombatantZubrinTiburon extends B9_ArchetypePawnCombatant;

// Load the animations package for the civilian archetype
#exec OBJ LOAD FILE=..\animations\B9_Zubrin_Characters PACKAGE=B9_Zubrin_Characters

var(movement) Sound	ImpactSound;
var bool			fCocked;
var bool			fFiringDone;
var	Sound			GunMovement1;
var Sound			GunMovement2;

var protected Sound fAlert[6];
var protected Sound fSpeech[4];
var protected float fLastSpoke;


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
	MovementAnims[0]	= 'walk_f';
	MovementAnims[1]	= 'walk_b';
	MovementAnims[2]	= 'walk_step_l';
	MovementAnims[3]	= 'walk_step_r';
	TurnLeftAnim		= 'walk_step_l';
	TurnRightAnim		= 'walk_step_r';
}

simulated function AnimateRunning()
{
	MovementAnims[0]	= 'run_f';
	MovementAnims[1]	= 'run_b';
	MovementAnims[2]	= 'run_step_l';
	MovementAnims[3]	= 'run_step_r';
	TurnLeftAnim		= 'run_step_l';
	TurnRightAnim		= 'run_step_r';
}

simulated function AnimateCrouchWalking()
{
	MovementAnims[0]	= 'walk_f';
	MovementAnims[1]	= 'walk_b';
	MovementAnims[2]	= 'walk_step_l';
	MovementAnims[3]	= 'walk_step_r';
	TurnLeftAnim		= 'walk_step_l';
	TurnRightAnim		= 'walk_step_r';
}

simulated function AnimateSwimming()
{
	MovementAnims[0]	= 'walk_f';
	MovementAnims[1]	= 'walk_b';
	MovementAnims[2]	= 'walk_step_l';
	MovementAnims[3]	= 'walk_step_r';
	TurnLeftAnim		= 'walk_step_l';
	TurnRightAnim		= 'walk_step_r';
}

simulated function AnimateFlying()
{
	MovementAnims[0]	= 'walk_f';
	MovementAnims[1]	= 'walk_b';
	MovementAnims[2]	= 'walk_step_l';
	MovementAnims[3]	= 'walk_step_r';
	TurnLeftAnim		= 'walk_step_l';
	TurnRightAnim		= 'walk_step_r';
}

simulated function AnimateHovering()
{
	LoopIfNeeded( 'idle', 1.0, 0.0 );
}

simulated function AnimateClimbing()
{
	MovementAnims[0]	= 'walk_f';
	MovementAnims[1]	= 'walk_b';
	MovementAnims[2]	= 'walk_step_l';
	MovementAnims[3]	= 'walk_step_r';
	TurnLeftAnim		= 'walk_step_l';
	TurnRightAnim		= 'walk_step_r';

  	ChangeAnimation();
}

simulated function AnimateStoppedOnLadder()
{
	LoopIfNeeded( 'idle', 1.0, 0.0 );
}

simulated function AnimateTreading()
{
	LoopIfNeeded( 'idle', 1.0, 0.0 );
}

simulated function AnimateCrouching()
{
	LoopIfNeeded( 'idle', 1.0, 0.0 );
}

simulated function AnimateStanding()
{
	LoopIfNeeded( 'idle', 1.0, 0.0 );
}

simulated function name GetFiringAnim()
{
	return 'fire_lazers2';
}
simulated function name GetJumpAnim()
{
	if ( (Acceleration.X != 0) || (Acceleration.Y != 0) )
	{
		return 'jump_f_begin';
	}
	else
	{
		return 'jump_b_begin';
	}
}
simulated function name GetFallingAnim()
{
	return 'Idle';
}
simulated function name GetLandingAnim()
{
	return 'jump_up_end';
}
simulated function name GetKnockdownAnim( bool fromBehind )
{
	if (fromBehind)
		return 'knockdown_b';
	else
		return 'knockdown_f';
}
simulated function name GetStandupAnim( bool fromBehind )
{
	if (fromBehind)
		return 'standup_b';
	else
		return 'standup_b';
}
simulated function name GetDyingAnim( vector HitLoc )
{
	local vector X, Y, Z, Dir;

	GetAxes( Rotation, X, Y, Z );
	Dir = Normal( HitLoc - Location );

	if( ( Dir Dot X ) > 0  )
	{
		return 'knockdown_f';
	}
	else
	{
		return 'knockdown_b';
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

	PlayAnim('fire_dock',,,FIRINGCHANNEL);
}

function PlayShoot()
{
	AnimBlendParams(FIRINGCHANNEL,0.5);
	bSteadyFiring = true;
	fCocked = true;

	LoopAnim('fire_lazers2',,,FIRINGCHANNEL);
}

function PlayPostFire()
{
	AnimBlendParams(FIRINGCHANNEL,0.5);
	bSteadyFiring = false;
	fCocked = false;

	Log("fire_undock");
	
}

function bool IsInFiringState()
{
	return IsInState( 'Firing' ) || IsInState( 'Firing_Shoot' ) || IsInState( 'Firing_End' );
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
	MenuName="B9_CombatantZubrinTiburon"
	ControllerClass=Class'B9_AI_ControllerCombatantZubrinTiburon'
	Mesh=SkeletalMesh'B9_Zubrin_characters.Tiburon_mesh'
	CollisionRadius=70
	CollisionHeight=70
	Buoyancy=100
}