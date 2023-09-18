//////////////////////////////////////////////////////////////////////////
//
// Black 9 Combatant Archetype Genesis Clockwork Charles.
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnCombatantGenesisClockworkCharles extends B9_ArchetypePawnCombatant;

// Load the animations package for the civilian archetype
#exec OBJ LOAD FILE=..\animations\B9_Genesis_Characters PACKAGE=B9_Genesis_Characters



function name GetWeaponBoneFor(Inventory I)
{
	return '';
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
	return '';
}
simulated function name GetJumpAnim()
{
	if ( (Acceleration.X != 0) || (Acceleration.Y != 0) )
	{
		return 'nowpn_jump_f';
	}
	else
	{
		return 'nowpn_jump_u';
	}
}
simulated function name GetFallingAnim()
{
	return 'Falling';
}
simulated function name GetLandingAnim()
{
	return 'Landing';
}
simulated function name GetKnockdownAnim( bool fromBehind )
{
	return 'nowpn_knockdown_b';
}
simulated function name GetStandupAnim( bool fromBehind )
{
	return 'nowpn_standup_b';
}
simulated function name GetDyingAnim( vector HitLoc )
{
	local vector X, Y, Z, Dir;

	GetAxes( Rotation, X, Y, Z );
	Dir = Normal( HitLoc - Location );

	if( ( Dir Dot X ) > 0  )
		return 'nowpn_knockdown_f';
	else
		return 'nowpn_knockdown_b';
}


///////////////////////////////////
// Nano Attack
//
simulated function name GetNanoAnim()
{
	// NYI: This is just temp.
	return 'hit_back';
}

simulated function PlayNanoAttack()
{
	local name	AnimName;

	bSteadyFiring = true;
	AnimName = GetNanoAnim();

	AnimBlendParams( FIRINGCHANNEL, 1.0, 0.0, 0.0, GetBoneForNano(), true );
	LoopAnim( AnimName, 1.0, 0.25, FIRINGCHANNEL );
}



function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
					 Vector momentum, class<DamageType> damageType)
{
	// Immune to nano.
	if ( (damageType == class'damage_Fireball') ||
		 (damageType == class'damage_FireFist') ||
		 (damageType == class'damage_HeavenBlast') ||
		 (damageType == class'damage_HydroShock') ||
		 (damageType == class'damage_IceFist') ||
		 (damageType == class'damage_IceShards') ||
		 (damageType == class'damage_RockFist') ||
		 (damageType == class'damage_RockShards') )
	{
		return;
	}
	
	// Vulnerable to explosives.
	if ( (damageType == class'damage_Explosive_Gren_Frag') ||
		 (damageType == class'damage_HeavyRocket') ||
		 (damageType == class'damage_RockGrenade') )
	{
		Damage += Damage / 2;
	}
	
	Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}



defaultproperties
{
	fRetreatToCoverRatio=0
	bIsBig=true
	fCharacterMaxHealth=500
	GroundSpeed=350
	WaterSpeed=350
	WalkingPct=0.25
	CrouchedPct=0.25
	BaseEyeHeight=-30
	EyeHeight=-30
	Health=500
	MenuName="B9_CombatantClockworkCharles"
	ControllerClass=Class'B9_AI_ControllerCombatantGenesisClockworkCharles'
	Mesh=SkeletalMesh'B9_Genesis_characters.clockwork_mesh'
	CollisionRadius=130
	CollisionHeight=250
	Buoyancy=100
}