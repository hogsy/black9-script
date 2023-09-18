//=============================================================================
// B9_Pawn
//
// Generic Pawn for Black9 
//
//=============================================================================


class B9_Pawn extends Pawn abstract;

// Variables
var string	fPawnName; 

var public int fMeleeAttackRadius;
var public int fMeleeAttackDamage;
var public int fMeleeAttackMomentum;

// Melee Attack
var public bool bMeleeAttack;
var public bool fInHeadquarters;

// Cached values for where the Pawn is.  The idea is that if a pawn goes off the path
// grid, we only once search through all of the pathnodes to find it, then cache that result
// here.  If the pawn stays fairly close to that pathnode, then we just use the cached value.
// if it moves away, we can search only the ones in a reasonable proximity.  These values
// are currently only maintained by the AI, and are not necessarily updated by anyone, so
// don't update or use them unless you really, really need it.
var PathNode	fCachedClosestPathNode;
var float		fDistanceFromCachedClosestPathNode;
var float		fTimeCacheLastCalculated;


// Sound stuff
//
var int VoiceTimer;

var sound fStepWater1;
var sound fStepWater2;

var float FootstepVolume; 
var Sound DeathSound;
var float DeathVolume;

//Not Working yet
var Sound AttackingScreamSound;
var float AttackingScreamVolume;


var Sound HurtSound1;
var Sound HurtSound2;
var Sound HurtSound3;
var float HurtVolume;

// Types
enum ESpecialAnimation
{
	kSuddenStop
};

var Sound fCurrentSound[ 8 ]; 


var(Sounds) Sound   SoundFootsteps[12]; // Indexed by ESurfaceTypes (sorry about the literal). 3 Surfaces times 4 effects
enum EMovementMode
{
	MOVE_Stand,
	MOVE_Walk,              
	MOVE_Run,		
	MOVE_Crouch,
	MOVE_Climb,
	MOVE_Swim,
	MOVE_Fire
};
var EMovementMode fMovementMode;	

var bool	fNoTargetLock;
var FX_Dummy_Position	fTargetDummy;

///////////

simulated function vector GetTargetLocation()
{
	if( fTargetDummy != None )
	{
		return fTargetDummy.Location;
	}
	return Location;
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType )
{
	local int actualDamage;
	local bool bAlreadyDead;
	local Controller Killer;

	bAlreadyDead = (Health <= 0);

	if (Physics == PHYS_None)
		SetMovementPhysics();
	if (Physics == PHYS_Walking)
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	if ( instigatedBy == self )
		momentum *= 0.6;

	if( Mass != 0 )
	{
        momentum = momentum/Mass;
	}

	actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);

	Health -= actualDamage;
	
	//log( "----- Health:"$Health$" actualDamage:"$actualDamage );

	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	/*
	if ( bAlreadyDead )
	{
		Warn(self$" took regular damage "$damagetype$" from "$instigatedby$" while already dead at "$Level.TimeSeconds);
		ChunkUp(-1 * Health);
		return;
	}
	*/
	
	//CR adding hurt sounds
	
		
	switch (Rand(3))
	{
	case 1:
		VoiceSoundDelay( 10, HurtSound1, SLOT_None, HurtVolume,400);
		break;
	case 2:
		VoiceSoundDelay( 10, HurtSound2, SLOT_None, HurtVolume,400);
		break;
	case 3:
		VoiceSoundDelay( 10, HurtSound3, SLOT_None, HurtVolume,400);
		break;
	}
	
	PlayHit(actualDamage, instigatedBy, hitLocation, damageType, Momentum);
	
	//Log(self$" Health="$Health);
	if ( Health <= 0 )
	{
		// pawn died
		if ( instigatedBy != None )
			Killer = instigatedBy.Controller; //FIXME what if killer died before killing you
		if ( bPhysicsAnimUpdate )
			TearOffMomentum = momentum;
		
		VoiceSoundDelay(50, DeathSound, SLOT_None, DeathVolume, 400);
		Died(Killer, damageType, HitLocation);
	//	Log(self$" killed by "$Killer);
		SavepointDeadActor(); // Added by JP/Taldren 2/18/03

		SetCollision( false, false, false );
	}
	else
	{
//		AddVelocity( momentum ); 
		if ( Controller != None )
			Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);
	}
	MakeNoise(1.0); 
}


function bool Gibbed(class<DamageType> damageType)
{
	return false;
}

simulated event PostBeginPlay()
{
	local B9_CalibrationMaster CalMaster;

	Super.PostBeginPlay();
	
	ForEach AllActors(class'B9_CalibrationMaster', CalMaster, 'HQListener')
	{
		break;
	}

	fInHeadquarters = (CalMaster != None && CalMaster.GameInHeadquarters());

	if( !fNoTargetLock )
	{
		if( GetBoneCoords( 'Target' ).Origin == vect( 0, 0, 0 ) )
		{
			return;
		}
		fTargetDummy = spawn( class'FX_Dummy_Position', self );
		AttachToBone( fTargetDummy, 'Target' );	
	}
}

// no telefrag in HQ
event EncroachedBy( actor Other )
{
	if ( !fInHeadquarters && Pawn(Other) != None )
		gibbedBy(Other);
}

//-----------------------------------------------------------------------------
// Audio Functions

simulated function PlaySFX( Sound sound, ESoundSlot slot, optional float volume )
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

	PlaySound( sound, slot, volume,noOverride ); 	
}


// Operations

simulated function PlayPrefire()
{}

simulated function PlaySpecialAnimation( ESpecialAnimation animation )
{}

simulated function WeaponHit()
{
}

simulated function WeaponIn()
{
}

simulated function AnimateTreading()
{
}

simulated function AnimateFlying()
{
}

simulated function AnimateHovering()
{
}

simulated function AnimateStoppedOnLadder()
{
}

simulated function AnimateCrouching()
{
}

simulated function AnimateStanding()
{
}

simulated function AnimateCrouchWalking()
{
}

simulated function AnimateWalking()
{
}

simulated function AnimateRunning()
{
}

simulated function AnimateSwimming()
{
}

simulated function AnimateClimbing()
{
}

//////////////////////////////////////////////////////////////
// Movement Section
//////////////////////////////////////////////////////////////
//

//////////////////////////////////////////////////////////////
// NewVelocityEvent
//
//

simulated function NewVelocityEvent()
{
	local bool walking;
	local float accelSize, velSize, animRate;
	local EMovementMode newMoveMode;
	local bool bPressedJump;
	local float maxSpeed;
	local float ladderRate;
	if ( Controller != None && PlayerController(Controller) != None && PlayerController(Controller).bPressedJump )
	{
		bPressedJump = true;
	}
	else
	{
		bPressedJump = false;
	}
	
	if( Physics == PHYS_Walking && bPressedJump == false )
	{
		accelSize = VSize( Acceleration );
		velSize = VSize( PreClippedVelocity );
		if( velSize <= 0.0 )
		{
			newMoveMode = MOVE_Stand;	
		}
		else if ( bIsCrouched )
		{
			newMoveMode = MOVE_Crouch;
		}
		else if ( bIsWalking )
		{
			newMoveMode = MOVE_Walk;
		}
		else
		{
			newMoveMode = MOVE_Run;
		}
	}
	else if ( Physics == PHYS_Ladder )
	{
		newMoveMode = MOVE_Climb;
	}
	else if ( Physics == PHYS_Swimming )
	{
		newMoveMode = MOVE_Swim;
	}

	if( newMoveMode != fMovementMode )
	{
		fMovementMode = newMoveMode;
		ChangeAnimation();
	}

	if ( fMovementMode == MOVE_Climb )
	{
		// Climb Code does not set PreClippedVelocity
		ladderRate = 1.55;
		velSize = VSize( Velocity );
		velSize = velSize*ladderRate;
		maxSpeed = LadderSpeed;
	}else
	{
		velSize = VSize( PreClippedVelocity );
		maxSpeed = GroundSpeed;
	}
	if ( fMovementMode == MOVE_Run  || fMovementMode == MOVE_Climb  || fMovementMode == MOVE_Swim )
	{
		animRate = velSize / maxSpeed;
	}
	else if ( fMovementMode == MOVE_Walk )
	{
		animRate = velSize / ( maxSpeed * WalkingPct ) ;
	}
	else if ( fMovementMode == MOVE_Crouch )
	{
		animRate = velSize / ( maxSpeed * CrouchedPct );
	}
	else
	{
		animRate = 1.0;
	}

	MovementAnimRate[0] = animRate;
	MovementAnimRate[1] = animRate;
	MovementAnimRate[2] = animRate;
	MovementAnimRate[3] = animRate;
}




simulated event RenderOverlays( canvas Canvas );

simulated function PlayFootStep(int Side)
{
	if ( (Role==ROLE_SimulatedProxy) || (PlayerController(Controller) == None) || PlayerController(Controller).bBehindView )
	{
		FootStepping(Side);
		return;
	}

}
simulated function PlayFootStepLeft()
{
    PlayFootStep(-1);
}

simulated function PlayFootStepRight()
{
    PlayFootStep(1);
}
simulated function FootStepping(int Side)
{
    local int i;
	local actor A;
	local material FloorMat;
	local vector HL,HN,Start,End;
	local int soundNdx;
	local ESurfaceTypes surf;
	
	if( TouchingWaterVolume() )
	{
		if ( FRand() < 0.5 )
		{
			PlaySound( fStepWater1 ,SLOT_Interact, FootstepVolume );
		}
		else
		{
			PlaySound( fStepWater2 , SLOT_Interact, FootstepVolume );
		}
		return;
	}

	if( Base != None && !Base.IsA( 'LevelInfo' ) )
	{
		surf = Base.SurfaceType;
	}
	else
	{
		surf = EST_Default;
	}

	const NumEffects = 4;	
	
	switch( surf )
	{
	case EST_Default:
	case EST_Dirt:
	case EST_Rock:
	case EST_Wood:
	case EST_Ice:
	case EST_Snow:
	case EST_Glass:
	case EST_Moon:
		soundNdx = Rand(4);
		break;

	case EST_Plant:
		soundNdx = Rand(4) + 4;
		break;

	case EST_Metal:
		soundNdx = Rand(4) + 8;
		break;

	case EST_Flesh:
	case EST_Water:	
		soundNdx = Rand(4);
		break;

	default:
		soundNdx = Rand(4);
	}
	
	PlaySound( SoundFootsteps[soundNdx], SLOT_Interact, 1.0, false, 300.0, 1.0, false );
	MakeNoise( FRand() );
}

event Tick( float DeltaTime )
{
	VoiceTimer=VoiceTimer-DeltaTime;
	NewVelocityEvent();
	Super.Tick(DeltaTime);
	
}

function ServerChangedWeapon(Weapon OldWeapon, Weapon W)
{
	Super.ServerChangedWeapon(OldWeapon, W);
	if (W == None)
		PlayWeaponSwitch(W);
}


// Finds the closest path node to this pawn by iterating through all of the pathnodes on
// this level.  This function is slow, and should only be called as a last resort.
function bool CacheClosestPathNode()
{
	local PathNode	best;
	local float		bestDist;
	local bool		bestVisible;
	local float		curDist;
	local bool		curVisible;
	local PathNode	node;
	
	best = none;
	foreach AllActors(class'PathNode', node)
	{
		if (best == None)
		{
			best = node;
			bestDist = VSize(Location - best.location);
			bestVisible = LineOfSightTo(best);
		}
		else
		{
			curDist = VSize(Location-node.location);
			curVisible = LineOfSightTo(node);
			
			if ( (!bestVisible && curVisible) ||
				 ((curDist < bestDist) && curVisible) ||
				 (!bestVisible && (curDist < bestDist)) )
			{
				best = node;
				bestDist = curDist;
				bestVisible = curVisible;
			}
		}
	}
	
	if (best != None)
	{
		fCachedClosestPathNode = best;
		fDistanceFromCachedClosestPathNode = bestDist;
		fTimeCacheLastCalculated = Level.TimeSeconds;
		return true;
	}

	log("MikeT: Could not find a pathnode clost to pawn " $self);
	return false;
}


// Returns the cached B9_PathNode for this pawn, if any.  Will calculate a new one if the current is
// out of date.
function PathNode GetCachedClosestPathNode()
{
	// Only calculate a new closest pathnode to this pawn every second or so.
	if ( (fCachedClosestPathNode == None) ||
		 ((Level.TimeSeconds - fTimeCacheLastCalculated) > 1.0) )
	{
		if ( (fCachedClosestPathNode == None) || (VSize(Location-fCachedClosestPathNode.location) > (fDistanceFromCachedClosestPathNode*2)) )
			CacheClosestPathNode();
	}

	return fCachedClosestPathNode;
}



//CR - Function to delay the playing of voice sounds until prev sound is over.  
function VoiceSoundDelay(float TimeDelay, sound	PlayThisSound, ESoundSlot SoundSlot, float Volume, float Radius)
{
	
	
	if (VoiceTimer <= 0)
	{
		//log ( "CR - Playing voice sound" );
		VoiceTimer = TimeDelay;
		PlaySound( PlayThisSound, SoundSlot, Volume,, Radius);
	}
	else
	{
		//log ( "CR - No Voice sound ");
		return;
	}
}



// Properites
defaultproperties
{
	fPawnName="Unknown"
	fMeleeAttackRadius=100
	fMeleeAttackDamage=4
	fMeleeAttackMomentum=30000
	fStepWater1=Sound'B9SoundFX.Protagonist.prot_walking_loopable'
	fStepWater2=Sound'B9SoundFX.Protagonist.prot_walking_loopable'
	FootstepVolume=5
	DeathSound=Sound'B9PlayerCharacters_sounds.MutantMale.gruber_death1'
	DeathVolume=0.2
	AttackingScreamSound=Sound'B9PlayerCharacters_sounds.NormalFemale.sahara_battle_cry2'
	AttackingScreamVolume=1
	HurtVolume=1
	SoundFootsteps[0]=Sound'B9AllCharacters_sounds.Footsteps.foot_boot_dirt1'
	SoundFootsteps[1]=Sound'B9AllCharacters_sounds.Footsteps.foot_boot_dirt2'
	SoundFootsteps[2]=Sound'B9AllCharacters_sounds.Footsteps.foot_boot_dirt3'
	SoundFootsteps[3]=Sound'B9AllCharacters_sounds.Footsteps.foot_boot_dirt4'
	SoundFootsteps[4]=Sound'B9AllCharacters_sounds.Footsteps.foot_boot_grass1'
	SoundFootsteps[5]=Sound'B9AllCharacters_sounds.Footsteps.foot_boot_grass2'
	SoundFootsteps[6]=Sound'B9AllCharacters_sounds.Footsteps.foot_boot_grass3'
	SoundFootsteps[7]=Sound'B9AllCharacters_sounds.Footsteps.foot_boot_grass4'
	SoundFootsteps[8]=Sound'B9AllCharacters_sounds.Footsteps.foot_boot_metal1'
	SoundFootsteps[9]=Sound'B9AllCharacters_sounds.Footsteps.foot_boot_metal2'
	SoundFootsteps[10]=Sound'B9AllCharacters_sounds.Footsteps.foot_boot_metal3'
	SoundFootsteps[11]=Sound'B9AllCharacters_sounds.Footsteps.foot_boot_metal4'
	bActorShadows=false
}