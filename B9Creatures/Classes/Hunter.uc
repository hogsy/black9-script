//=============================================================================
// Black9 Hunter Robot for Unreal Warfare -- version 2
//=============================================================================
class Hunter extends B9_Pawn;

//-----------------------------------------------------------------------------
// B9_Hunter variables.

var float	TimeBetweenSpeech;
var bool	bSpokeYet;
var float	LastSpeech;
var Sound	fCurrentSound[ 8 ]; 

//-----------------------------------------------------------------------------
// B9_Hunter animation and sound data.
//

#exec OBJ LOAD FILE=..\Sounds\B9SoundFX.uax PACKAGE=B9SoundFX


// Functions

function PreBeginPlay()
{
	Super.PreBeginPlay();

	bSpokeYet = false;
	LastSpeech = 0;
}

//static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum)
//{
//}

////////////////
// Sound
//
function SaySomething( Sound dialogue, bool force )
{
	if ( force || !bSpokeYet || Level.TimeSeconds - LastSpeech > TimeBetweenSpeech )
	{		
		PlaySound( dialogue, SLOT_Interact );
		LastSpeech = Level.TimeSeconds;
		bSpokeYet = true;
	}
}

function SayTaunt()
{
	local int selection;
	selection = int(FRand() * 6);

	if ( selection < 1 )
	{
//		SaySomething( sound'HunterAlive', false );
	}
	else if ( selection < 2 )
	{
//		SaySomething( sound'HunterDead', false );
	}
	else if ( selection < 3 )
	{
//		SaySomething( sound'HunterHere', false );
	}
	else if ( selection < 4 )
	{	
//		SaySomething( sound'HunterPay', false );
	}
	else if ( selection < 5 )
	{
//		SaySomething( sound'HunterPunk', false );
	}
	else
	{
//		SaySomething( sound'HunterThere', false );
	}
}

function SayHurt()
{
	local int selection;
	selection = int(FRand() * 3);

	if ( selection < 1 )
	{
//		SaySomething( sound'HunterGrowl', false );
	}
	else if ( selection < 2 )
	{
//		SaySomething( sound'HunterGrowl2', false );
	}
	else
	{
//		SaySomething( sound'HunterPrimate', false );
	}
}

function SayIdle()
{
//	SaySomething( sound'HunterOut', false );
}

function PlaySFX( Sound sound, ESoundSlot slot, optional float volume )
{
	local bool noOverride;
	if( slot != SLOT_None && sound == fCurrentSound[ slot ] )
	{
		noOverride = true;
	}
	else
	{
		fCurrentSound[ slot ] = sound;
		noOverride = false;
	}

	PlaySound( sound, slot, volume ,noOverride ); 	
	
}

//=============================================================================
// Animation playing 
//

function PlayMoving()
{
	if ( bIsWalking )
	{
	//	LoopAnim('walk_forward', -1.1/GroundSpeed,,0.4);
		LoopAnim('walk_forward');
		log( "Hunter: Walking" );
		PlaySFX( sound'mech_walking', SLOT_Misc, 0.25 ); 
	}
	else
	{
	//	LoopAnim('run_forward', -1.1/GroundSpeed,,0.4);
		LoopAnim('run_forward');
		log( "Hunter: Running" );
		PlaySFX( sound'mech_running', SLOT_Misc, 0.25 );
	}
}

function PlayLanded(float impactVel)
{
	Super.PlayLanded(impactVel);
	PlayMoving();
}

function PlayWaiting()
{
	local name curAnim;
	local float frame, rate;

	GetAnimParams(0,curAnim,frame,rate);

	Log( "Hunter: PlayWaiting" );
	PlaySFX( sound'mech_head_move', SLOT_Misc, 0.25 ); 	

	rate = 0.5 + 0.5 * FRand();
	if ( (FRand() < 0.4) || !AnimIsInGroup(0,'Run_Idle_Brief') )
	{
		if ( curAnim == 'run_idle' )
			PlayAnim('run_idle', rate, 0.4);
		else if ( FRand() < 0.4 )
			PlayAnim('run_idle', 0.8 * rate, 0.4);
		else
			PlayAnim('run_idle', rate, 0.4);
	}
	else
	LoopAnim(curAnim, rate);
}

function PlayMovingAttack()
{
//	LoopAnim('run_forward_fire', -1.1/GroundSpeed,,0.4);
	LoopAnim('run_forward_fire');
	SayTaunt();
	Log( "Hunter: PlayMovingAttack" );
	PlaySFX( sound'mech_running', SLOT_Misc, 0.25 ); 	
}

function PlayWaitingAmbush()
{
	PlayWaiting();
}
/*
function TweenToFighter(float tweentime)
{
	TweenAnim('Fighter', tweentime);
	log( "TweenToFighter" );
}

function TweenToRunning(float tweentime)
{
	TweenAnim('run_forward', tweentime);
	log( "TweenToRunning" );
}

function TweenToWalking(float tweentime)
{
	TweenAnim('walk_forward', tweentime);
	log( "TweenToWalking " $ tweentime );
}

function TweenToPatrolStop(float tweentime)
{
	TweenToFighter(tweentime);
	log( "TweenToPatrolStop" );
}

function TweenToWaiting(float tweentime)
{
	TweenAnim('run_idle_brief', tweentime);
	log( "TweenToWaiting" );
	PlaySFX( sound'robot_waist_move', SLOT_Misc, 0.25 ); 	
}
*/
function PlayThreatening()
{
	PlayWaiting();
	SayTaunt();
	log( "Hunter: PlayThreatening" );
}

function PlayPatrolStop()
{
	PlayWaiting();
	log( "Hunter: PlayPatrolStop" );
}

function PlayTurning(bool bTurningLeft)
{
	PlayWaiting();
	log( "Hunter: PlayTurning" );
}

function PlayBigDeath(class<DamageType> DamageType)
{
	PlayAnim('death_fall_backwards');
//	SaySomething(sound'HunterSysMalfunction', true);
	log( "Hunter: PlayBigDeath" );
}

function PlayHeadDeath(class<DamageType> DamageType)
{
	PlayAnim('death_fall_backwards');
//	SaySomething(sound'HunterSysMalfunction', true);
	log( "Hunter: PlayHeadDeath" );
}

function PlayLeftDeath(class<DamageType> DamageType)
{
	PlayAnim('death_fall_backwards');
//	SaySomething(sound'HunterSysMalfunction', true);
	log( "Hunter: PlayLeftDeath" );
}

function PlayRightDeath(class<DamageType> DamageType)
{
	PlayAnim('death_fall_backwards');
//	SaySomething(sound'HunterSysMalfunction', true);
	log( "Hunter: PlayRightDeath" );
}

function PlayGutDeath(class<DamageType> DamageType)
{
	PlayAnim('death_fall_backwards');
//	SaySomething(sound'HunterSysMalfunction', true);
	log( "Hunter: PlayGutDeath" );
}


function PlayGutHit(float tweentime)
{
	local name curAnim;
	local float frame, rate;

	GetAnimParams(0,curAnim,frame,rate);

	if ( curAnim == 'hit_gut' )
	{
		if (FRand() < 0.5)
			TweenAnim('hit_gut', tweentime);
		else
			TweenAnim('hit_gut', tweentime);
	}
	else
		TweenAnim('hit_gut', tweentime);
	SayHurt();
	

	TweenAnim('hit_gut', tweentime);

	log( "Hunter: hit_gut" );
}

/*
function TweenToRunning(float tweentime)
{
	local vector X,Y,Z, Dir;
	local name newAnim;

	if ( Physics == PHYS_Swimming )
	{
		if ( (vector(Rotation) Dot Acceleration) > 0 )
			TweenToSwimming(tweentime);
		else
			TweenToWaiting(tweentime);
		return;
	}

	BaseEyeHeight = Default.BaseEyeHeight;
	if (bIsWalking)
	{
		TweenToWalking(0.1);
		return;
	}

	NewAnim = PickRunSequence();
	if ( (newAnim == AnimSequence) && (Acceleration != vect(0,0,0)) && IsAnimating() )
		return;

	PlayAnim(NewAnim, 0.9, tweentime);
}
*/

function PlayHeadHit(float tweentime)
{
	local name curAnim;
	local float frame, rate;

	GetAnimParams(0,curAnim,frame,rate);
	
	if ( curAnim == 'hit_chest' )
		TweenAnim('hit_gut', tweentime);
	else
		TweenAnim('hit_chest', tweentime);
	SayHurt();
	

	log( "Hunter: hit_head" );
}

function PlayLeftHit(float tweentime)
{
	local name curAnim;
	local float frame, rate;

	GetAnimParams(0,curAnim,frame,rate);

	if ( curAnim == 'hit_left' )
		TweenAnim('hit_gut', tweentime);
	else
		TweenAnim('hit_left', tweentime);
	SayHurt();
	
	log( "Hunter: hit_left" );
}

function PlayRightHit(float tweentime)
{
	local name curAnim;
	local float frame, rate;

	GetAnimParams(0,curAnim,frame,rate);

	if ( curAnim == 'hit_right' )
		TweenAnim('hit_gut', tweentime);
	else
		TweenAnim('hit_right', tweentime);
	SayHurt();
	
	log( "hit_right" );
}

function PlayVictoryDance()
{
	PlayAnim( 'run_idle' );
	log( "Hunter: PlayVictoryDance" );
}

function PlayOutOfWater()
{
	PlayFalling();
	log( "Hunter: PlayOutOfWater" );
}

function PlayDive();
/*
function TweenToFalling()
{
	PlayAnim('JumpLgFr');
}
*/
function PlayInAir();
function PlayDuck();
function PlayCrawling();

function PlayFiring(float Rate, name FiringMode)
{
	PlayRangedAttack();
}

function PlayWeaponSwitch(Weapon NewWeapon);
//function TweenToSwimming(float tweentime);

function PlayRangedAttack()
{
	PlayAnim( 'run_idle_fire' );
	SayTaunt();
}

function PlayMeleeAttack()
{
	PlayRangedAttack();
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;
	local Controller Killer;

	log( "Hunter: Taking damage" );

	if ( Role < ROLE_Authority )
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

	bAlreadyDead = ( Health <= 0 );
	actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);
	
	//
	/*
	AddVelocity( momentum ); 

	if( Physics == PHYS_None )
	{
		SetMovementPhysics();
	}
	else if( Physics == PHYS_Walking )
	{
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	}
	
	if ( instigatedBy == self )
	{
		momentum *= 0.6;
	}

	momentum = momentum/Mass;
	Health -= actualDamage;

	if ( HitLocation == vect(0,0,0) )
	{
		HitLocation = Location;
	}
	*/

	Health -= actualDamage;
	//

	if ( HitLocation == vect(0,0,0) )
	{
		HitLocation = Location;
	}

	if( Health > 0 )
	{
		//PlayHit(actualDamage, instigatedBy, hitLocation, damageType, Momentum);
		if ( (instigatedBy != None) && (instigatedBy != Self) && (Controller != None) )
		{
			Controller.damageAttitudeTo(instigatedBy, actualDamage);
		}
	}
	else if ( !bAlreadyDead )
	{
		//log(self$" died");
		if ( Controller != None )
		{
//			Controller.NextState = '';
			Controller.Enemy = instigatedBy;
		}
//		PlayDeathHit(actualDamage, hitLocation, damageType, Momentum);	??? $$$SCD
		if ( actualDamage > mass )
		{
			Health = -1 * actualDamage;
		}
		
		if ( instigatedBy != None )
		{
				Killer = instigatedBy.Controller; //fixme, what if killer died before killing you FIXME
		}

		Died( Killer, damageType, HitLocation );
	}
	else
	{
		//Warn(self$" took regular damage "$damagetype$" from "$instigator$" while already dead");
//		ChunkUp(-1 * Health);
		ChunkUp(Rotation,damageType);
	}
	MakeNoise(1.0); 
	

	/*
	if ( Role < ROLE_Authority )
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}
	
	bAlreadyDead = ( Health <= 0 );
	actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);
	actualDamage = 1.0;

	AddVelocity( momentum ); 

	if( Physics == PHYS_None )
	{
		SetMovementPhysics();
	}
	else if( Physics == PHYS_Walking )
	{
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	}
	
	if ( instigatedBy == self )
	{
		momentum *= 0.6;
	}

	momentum = momentum/Mass;
	Health -= actualDamage;

	if ( HitLocation == vect(0,0,0) )
	{
		HitLocation = Location;
	}

	if( Health > 0 )
	{
		PlayHit(actualDamage, instigatedBy, hitLocation, damageType, Momentum);
		
		if ( (instigatedBy != None) && (instigatedBy != Self) && (Controller != None) )
		{
			Controller.damageAttitudeTo(instigatedBy, actualDamage, damageType);
		}

		log( "Taking damage" );
	}
	else if ( !bAlreadyDead )
	{
		//log(self$" died");
		if ( Controller != None )
		{
			Controller.NextState = '';
			Controller.Enemy = instigatedBy;
		}
		PlayDeathHit(actualDamage, hitLocation, damageType, Momentum);
		if ( actualDamage > mass )
		{
			Health = -1 * actualDamage;
		}
		
		if ( instigatedBy != None )
		{
				Killer = instigatedBy.Controller; //fixme, what if killer died before killing you FIXME
		}

		Died( Killer, damageType, HitLocation );
	}
	else
	{
		//Warn(self$" took regular damage "$damagetype$" from "$instigator$" while already dead");
//		ChunkUp(-1 * Health);
		ChunkUp(Rotation,damageType);
	}
	MakeNoise(1.0); 

	*/
}

function PlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum)
{
	local vector BloodOffset, Mo;
	local class<Effects> DesiredEffect;

	log( "Hunter: I was hit" );
	
	
	if ( (Damage <= 0) && !Controller.bGodMode )
		return;
		
		PlayTakeHit(hitLocation, Damage, damageType);
		
	SayHurt();
}


defaultproperties
{
	TimeBetweenSpeech=5
	GroundSpeed=450
	AccelRate=400
	JumpZ=325
	Health=500
	MenuName="Black 9 Hunter"
	ControllerClass=Class'B9_MonsterController'
	Physics=1
	CollisionRadius=88
	CollisionHeight=80
	Mass=500
}