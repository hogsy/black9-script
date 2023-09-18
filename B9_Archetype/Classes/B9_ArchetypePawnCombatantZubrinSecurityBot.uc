//////////////////////////////////////////////////////////////////////////
//
// Black 9 Combatant Archetype Zubrin security bot.
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnCombatantZubrinSecurityBot extends B9_ArchetypePawnCombatant;

// Load the animations package for the civilian archetype
#exec OBJ LOAD FILE=..\animations\B9_BlackDragons_Characters PACKAGE=B9_BlackDragons_Characters

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
	return 'weaponbone';
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
	return 'nowpn_knockdown_f';
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
		return 'weaponbone';
	return 'weaponbone2';
}

function bool IsInFiringState()
{
	return IsInState( 'Firing' );
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
	bWeaponHidden=true
	fStartupState=0
	fCharacterMaxHealth=80
	FootstepVolume=0.25
	GroundSpeed=500
	WaterSpeed=350
	JumpZ=630
	BaseEyeHeight=5
	EyeHeight=5
	Health=80
	MenuName="B9_CombatantZubrinSecurityBox"
	Mesh=SkeletalMesh'B9_BlackDragons_Characters.security_bot_mesh'
	DrawScale=3
	CollisionRadius=50
	CollisionHeight=25
	Buoyancy=100
}