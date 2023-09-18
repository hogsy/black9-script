//=============================================================================
// B9_AdvancedPawn
//
// Special pawn for the Black 9 game with RPG elements
//
// 
//=============================================================================

class B9_AdvancedPawn extends B9_Pawn
	config;

// Intrinsic Attributes

var travel public int	fCharacterBaseStrength; 
var travel public int	fCharacterBaseAgility; 
var travel public int	fCharacterBaseDexterity; 
var travel public int	fCharacterBaseConstitution;

// These don't travel because they're derived from the base attributes above
var public int	fCharacterStrength; 
var public int	fCharacterAgility; 
var public int	fCharacterDexterity; 
var public int	fCharacterConstitution;
var public float	fCharacterFocus;

// Intrinsic Skills

var public float	fCharacterMaxFocus;


// Computed from Strength and Agility
var public int	fCharacterMeleeCombat;

// Computed from Agility
var public int  fCharacterJumping;
var public int  fUrbanTracking;

// Computed from Agility
var public int	fCharacterSpeed;
//Computed from Constitution
var travel public int  fCharacterMaxHealth;
// Computed from Agility and Dexterity
var public int  fCharacterTargetingFireArms;
// Computed from Agility and Dexterity and Strength
var public int  fCharacterTargetingHeavyWeapons;

var public int	fHackingNanoPoints;

// Multiplier for Constitution, which determines fCharacterMaxHealth.
var config float fCharacterMaxHealthModifier;

enum eBodyType { kBodyType_Small, kBodyType_Medium, kBodyType_Large };
var travel public eBodyType kBodyType; 

var travel B9_Skill	fSelectedSkill;

var public bool	bWeaponUsesAmmo;
var public bool	fUsingConstantSkill;
var float		fPercentRateofFocusIncrease;

var int PendingApplyModifications;
var bool bDoApplyModifications;

var bool bInventoryToFront;



enum EFaction
{
	kGreyFaction,		// Neutral
	kRedFaction,	
	kGreenFaction,
	kBlueFaction,
	kBlackFaction
};

// Enum Variables
var(AI) EFaction	fFaction;


var bool		bPerformingExclusiveAction;
var name		fControllerLastState;

////////////////////////////
// Animation stuff
//
const MAINCHANNEL			= 0;
const TAKEHITCHANNEL		= 14;
const FIRINGCHANNEL			= 15;
const FALLINGCHANNEL		= 16;

const FIRINGBLENDBONE			= 'Bip01 R Clavicle'; // deprecated
const Bone_Fire_Pistol_Left		= 'Bip01 L Clavicle';
const Bone_Fire_Pistol_Right	= 'Bip01 R Clavicle';
const Bone_Fire_Rifle_Left		= 'Bip01 Spine1';
const Bone_Fire_Rifle_Right		= 'Bip01 Spine1';
const Bone_Fire_Melee_Left		= 'Bip01 Spine1';
const Bone_Fire_Melee_Right		= 'Bip01 Spine1';
const Bone_NanoLeftHand			= 'Bip01 Spine1';
const Bone_NanoRightHand		= 'Bip01 Spine1';
const Bone_UseLeftHand			= 'Bip01 Spine1';
const Bone_UseRightHand			= 'Bip01 Spine1';
const Bone_TakeHit				= 'Bip01 Spine1';
const Bone_Root					= 'Bip01';

var bool		fIsLeftHanded;

var EPhysics	fLastPhysics;
var bool		fJustFellHard;
var bool		fJustFellModerate;
var bool		fJustFellSoft;
var bool		fJustPlayedRunningJump;
var bool		fGettingUp;


const			kLongFallAccel			= -1500.0;
const			kNormalLandingThreshold	= -800.0;

const			kDamageThresholdForKnockdown = 30;
const			kKnockdownDelay	= 30.0;
var bool		fCanBeKnockedDownAgain;
var float		fKnockdownTimer;
//
////////////////////////////


const	kMaxFallVelocity = -2000.0;

replication
{
	reliable if (ROLE==ROLE_Authority)
		ClientKickView, ClientApplyModifications;
	
	reliable if (bNetDirty && ROLE==ROLE_Authority)
		fSelectedSkill;

	reliable if (bNetDirty && bNetOwner && ROLE==ROLE_Authority)
		fCharacterStrength, fCharacterAgility, fCharacterDexterity, fCharacterConstitution,
		fCharacterFocus;
}



///////////////////////////////////////////////////
// Functions
//
function name GetWeaponBoneFor(Inventory I)
{
	return 'weaponbone';
}

simulated event Tick( float deltaTime )
{
	Super.Tick( deltaTime );

	// Animation tick stuff
	//
	if( Physics == PHYS_Falling )
	{
		if( Velocity.Z <= kNormalLandingThreshold )
		{
			PlayFalling();
		}
	}

	fLastPhysics = Physics;

	if( !fCanBeKnockedDownAgain )
	{
		fKnockdownTimer -= deltaTime;
		if( fKnockdownTimer <= 0.0 )
		{
			fCanBeKnockedDownAgain = true;
		}
	}
	//
	/////////////

	if(fCharacterFocus < fCharacterMaxFocus)
	{
		fCharacterFocus = fCharacterFocus+(deltaTime*fCharacterMaxFocus*fPercentRateofFocusIncrease);
		if( fCharacterFocus > fCharacterMaxFocus)
		{
			fCharacterFocus = fCharacterMaxFocus;
		}
	}

	if (PendingApplyModifications > 0)
	{
		if (--PendingApplyModifications == 0)
			ApplyModifications();
	}
}

//////////////////////////////////////////////
// Firing, using inventory, and using nano skills are exclusive.
// Currently applies only to human players so as not to interfere with the AI
//
simulated function bool IsPerformingExclusiveAction()
{
	if( !IsHumanControlled() )
	{
		return false;
	}

	return bPerformingExclusiveAction;
}

simulated function ActExclusively( bool exclusive )
{
	if( !IsHumanControlled() )
	{
		return;
	}

	bPerformingExclusiveAction = exclusive;
}


///////////////////////////////////////////
// Animation helpers
//
simulated function name GetFiringAnim();
simulated function name GetJumpAnim();
simulated function name GetFallingAnim();
simulated function name GetLandingAnim();
simulated function name GetKnockdownAnim( bool fromBehind );
simulated function name GetStandupAnim( bool fromBehind );
simulated function name GetDyingAnim( vector HitLoc );


simulated function name GetBoneForShooting()
{
	local WeaponAttachment.eWeaponAnimKind weapKind;
	
	weapKind = GetWeaponKind();

	if( weapKind == wepAnimKind_Pistol_1H )
	{
		if( fIsLeftHanded )
		{
			return Bone_Fire_Pistol_Left;
		}

		return Bone_Fire_Pistol_Right;
	}

	else if( weapKind == wepAnimKind_Rifle )
	{
		if( fIsLeftHanded )
		{
			return Bone_Fire_Rifle_Left;
		}

		return Bone_Fire_Rifle_Right;
	}

	else if( weapKind == wepAnimKind_Melee_1H )
	{
		if( fIsLeftHanded )
		{
			return Bone_Fire_Melee_Left;
		}

		return Bone_Fire_Melee_Right;
	}

	else
	{
		if( fIsLeftHanded )
		{
			return Bone_Fire_Melee_Left;
		}

		return Bone_Fire_Melee_Right;
	}	
}

simulated function name GetBoneForNano()
{
	if( fIsLeftHanded )
	{
		return Bone_NanoRightHand;
	}

	return Bone_NanoLeftHand;
}

simulated function name GetBoneForUsing()
{
	if( fIsLeftHanded )
	{
		return Bone_NanoRightHand;
	}

	return Bone_NanoLeftHand;
}

simulated function name GetBoneForTakeHit()
{
	return	Bone_TakeHit;
}

simulated function name GetBoneForReloading()
{
	return Bone_TakeHit;
}

simulated function name GetRootBone()
{
	return Bone_Root;
}

simulated final function BlendOutAllUserChannels()
{
	AnimBlendToAlpha( FIRINGCHANNEL,  0, 0.01 );
	AnimBlendToAlpha( TAKEHITCHANNEL, 0, 0.01 );
}

simulated final function WeaponAttachment.eWeaponAnimKind GetWeaponKind()
{
	local int i;
	local WeaponAttachment wa;

	for (i=0;i<Attached.Length;i++)
	{
		wa = WeaponAttachment(Attached[i]);
		if (wa != None)
		{
			return wa.fAnimKind;
		}
	}

/*
	Log("Weapon="$Weapon$" TPA="$Weapon.ThirdPersonActor$" AK="$WeaponAttachment( Weapon.ThirdPersonActor ).fAnimKind);

	if( Weapon != None && WeaponAttachment( Weapon.ThirdPersonActor ) != None )
	{
		return WeaponAttachment( Weapon.ThirdPersonActor ).fAnimKind;
	}
*/
	return wepAnimKind_NoWpn;
}

simulated function LoopIfNeeded( name NewAnim, float NewRate, float BlendIn )
{
	local name	OldAnim;
	local float frame,rate;

	GetAnimParams( MAINCHANNEL, OldAnim, frame,rate );

	if( ( NewAnim != OldAnim ) || ( NewRate != Rate ) || ( !IsAnimating( MAINCHANNEL ) ) )
	{
		LoopAnim(NewAnim, NewRate, BlendIn);
	}
	else
	{
		LoopAnim(NewAnim, NewRate);
	}
}

//
////////


///////////////////////////////////
// AnimateXXX()
// Sets up the movement anims in response to movement type / physics changes
//
simulated function AnimateWalking()
{
}

simulated function AnimateRunning()
{
}

simulated function AnimateCrouchWalking()
{
}

simulated function AnimateSwimming()
{
}

simulated function AnimateFlying()
{
}

simulated function AnimateHovering()
{
}

simulated function AnimateClimbing()
{
}

simulated function AnimateStoppedOnLadder()
{
}

simulated function AnimateTreading()
{
}

simulated function AnimateCrouching()
{
}

simulated function AnimateStanding()
{
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
			AnimBlendToAlpha( FALLINGCHANNEL, 0, 0.01 );
			PlayWaiting();
		}
	}
}

simulated event ChangeAnimation()
{
	PlayNext();
}

simulated function PlayNext()
{
	if( Physics == PHYS_None 
		|| (( Role == ROLE_Authority ) && (Controller == None)) )
	{
		return;
	}

	else if ( Physics == PHYS_Walking )
	{
		if( Acceleration.X == 0 && Acceleration.Y == 0 )
		{
			if ( bIsCrouched )
			{
				AnimateCrouching();
			}
			else
			{
				AnimateStanding();
			}
		}

		if ( bIsCrouched )
		{
			AnimateCrouchWalking();
		}
		else if ( bIsWalking )
		{
			AnimateWalking();
		}
		else
		{
			AnimateRunning();
		}
	}
	else if ( Physics == PHYS_Swimming)
	{
		AnimateSwimming();
	}
	else if ( Physics == PHYS_Ladder )
	{
		AnimateClimbing();
	}
	else if ( Physics == PHYS_Flying )
	{
		AnimateFlying();
	}
	else
	{
		if ( bIsCrouched )
		{
			AnimateCrouchWalking();
		}
		else if ( bIsWalking )
		{
			AnimateWalking();
		}
		else
		{
			AnimateRunning();
		}
	}
}

simulated function PlayWaiting()
{
	PlayNext();
}

simulated function PlayMoving()
{
	PlayNext();
}

//
/////////////

///////////////////////////////////
// Getting shot
//
function PlayTakeHit( vector HitLoc, int Damage, class<DamageType> damageType )
{
	local vector X, Y, Z, Dir;
	local name HitAnim;
	local float MyPitch;

	Super.PlayTakeHit( HitLoc, Damage, damageType );

	if( IsAnimating( TAKEHITCHANNEL ) )
	{
		return;
	}

	GetAxes( Rotation, X, Y, Z );

	Dir = Normal( HitLoc - Location );
	
	if ( ( Dir Dot X ) < 0 )
	{
		HitAnim = 'hit_back';
	}
	else if ( ( ( Dir Dot X ) > 0.9 ) || ( HitLoc.Z < Location.Z ) )
	{
		HitAnim = 'hit_front';
	}
	else if( ( Dir Dot Y ) > 0.5 )
	{
		HitAnim = 'hit_left';
	}
	else
	{
		HitAnim = 'hit_right';
	}
	
	if( HasAnim( HitAnim ) ) 
	{
		AnimBlendParams( TAKEHITCHANNEL, 0.75, 0.0, 0.0, GetBoneForTakeHit(), false );
		PlayAnim( HitAnim, 1.0, 0.0, TAKEHITCHANNEL );
		Controller.fTakingAHit = true;
	}
}

///////////////////////////////////
// Firing
//
simulated function PlayFiring(float Rate, name FiringMode)
{
	local name animName;

	animName = GetFiringAnim();
	if( animName == '' )
	{
		//log( "No Firing animation found for "$self );
		return;
	}
	AnimBlendParams( FIRINGCHANNEL, 1.0, 0.0, 0.0, GetBoneForShooting(), true );
	PlayAnim( animName, 1.0, 0.0, FIRINGCHANNEL);	
}

simulated function StopPlayFiring()
{
	if( bSteadyFiring )
	{
		bSteadyFiring = false;
		AnimBlendToAlpha( FIRINGCHANNEL, 0.0, 0.25 );
		PlayWaiting();
	}
}

///////////////////////////////////
// Nano Attack
//
simulated function name GetNanoAnim()
{
	local WeaponAttachment.eWeaponAnimKind Kind;

	Kind = GetWeaponKind();

	if (Kind == wepAnimKind_Rifle)
		return 'rifle_nano';
	else if (Kind == wepAnimKind_NoWpn)
		return 'melee_nano';
	else if( Kind == wepAnimKind_Launcher )
		return 'launcher_nano';
	else if( Kind == wepAnimKind_Armature )
		return 'armature_nano';
	else
		return 'pistol_1h_nano';
}

simulated function PlayNanoAttack()
{
	local name	AnimName;

	bSteadyFiring = false;
	AnimName = GetNanoAnim();

	AnimBlendParams( FIRINGCHANNEL, 1.0, 0.0, 0.0, GetBoneForNano(), true );
	PlayAnim( AnimName, 1.0, 0.25, FIRINGCHANNEL );
}

///////////////////////////////////
// Hacking
//
simulated function PlayHacking()
{
	local WeaponAttachment.eWeaponAnimKind Kind;
	local name	AnimName;

	Kind = GetWeaponKind();
	bSteadyFiring = true;

	if (Kind == wepAnimKind_Rifle)
	{
		AnimName = 'rifle_hack';
	}
	else if (Kind == wepAnimKind_NoWpn)
	{
		AnimName = 'melee_1H_hack';
	}
	else if( Kind == wepAnimKind_Launcher )
	{
		AnimName = 'launcher_hack';
	}
	else if( Kind == wepAnimKind_Armature )
	{
		AnimName = 'armature_hack';
	}
	else
	{
		AnimName = 'pistol_1h_hack';
	}

	AnimBlendParams( FIRINGCHANNEL, 1.0, 0, 0, GetBoneForNano(), true );
	PlayAnim( AnimName, 1.0, 0.25, FIRINGCHANNEL );
}
simulated function StopPlayHacking()
{
	bSteadyFiring	= false;
	AnimBlendToAlpha( FIRINGCHANNEL, 0, 0.1 );
	PlayWaiting();
}

///////////////////////////////////
// Use world switch
//
simulated function PlayUseSwitch() 
{
	local WeaponAttachment.eWeaponAnimKind Kind;
	local name	AnimName;

	Kind = GetWeaponKind();
	bSteadyFiring = false;

	if (Kind == wepAnimKind_Rifle)
	{
		AnimName = 'rifle_useswitch';
	}
	else if (Kind == wepAnimKind_Melee_1H)
	{
		AnimName = 'melee_1h_useswitch';
	}
	else if( Kind == wepAnimKind_Launcher )
	{
		AnimName = 'launcher_useswitch';
	}
	else if( Kind == wepAnimKind_Armature )
	{
		AnimName = 'armature_useswitch';
	}
	else if (Kind == wepAnimKind_NoWpn)
	{
		AnimName = 'nowpn_useswitch';
	}
	else
	{
		AnimName = 'pistol_1h_useswitch';
	}

	AnimBlendParams( FIRINGCHANNEL, 1.0, 0, 0, GetBoneForUsing(), false );
	PlayAnim( AnimName, 1.0, 0.25, FIRINGCHANNEL );

	ActExclusively( true );
}

function FireUseSwitch()
{
	local Actor A;

	ActExclusively( false );

	PlayerController( Controller ).ServerUse();
}

///////////////////////////////////
// Throwing
//
simulated function PlayThrowOverhand()
{
	local WeaponAttachment.eWeaponAnimKind Kind;
	local name AnimName;

	Kind = GetWeaponKind();
	bSteadyFiring = false;

	if (Kind == wepAnimKind_Rifle)
	{
		AnimName = 'rifle_throwgrenade';
	}
	else if (Kind == wepAnimKind_NoWpn)
	{
		AnimName = 'nowpn_throwgrenade';
	}
	else if( Kind == wepAnimKind_Launcher )
	{
		AnimName = 'launcher_throwgrenade';
	}
	else if( Kind == wepAnimKind_Armature )
	{
		AnimName = 'armature_throwgrenade';
	}
	else
	{
		AnimName = 'pistol_1h_throwgrenade';
	}

	AnimBlendParams( FIRINGCHANNEL, 1.0, 0, 0, GetBoneForUsing(), true );
	PlayAnim( AnimName, 1.0, 0.25, FIRINGCHANNEL );

	ActExclusively( true );
}

function FireThrowItem()
{
	if (B9_TossibleItem(SelectedItem) != None)
		B9_TossibleItem(SelectedItem).Fire(0);

	ActExclusively( false );
}

///////////////////////////////////
// Use inventory item
//
simulated function PlayUseItem()
{
	local WeaponAttachment.eWeaponAnimKind Kind;
	local name AnimName;

	Kind = GetWeaponKind();
	bSteadyFiring = false;

	if (Kind == wepAnimKind_Rifle)
	{
		AnimName = 'rifle_useitem';
	}
	else if (Kind == wepAnimKind_Melee_1H)
	{
		AnimName = 'melee_1h_useitem';
	}
	else if (Kind == wepAnimKind_NoWpn)
	{
		AnimName = 'nowpn_useitem';
	}
	else if( Kind == wepAnimKind_Launcher )
	{
		AnimName = 'launcher_useitem';
	}
	else if( Kind == wepAnimKind_Armature )
	{
		AnimName = 'armature_useitem';
	}
	else
	{
		AnimName = 'pistol_1h_useitem';
	}

	AnimBlendParams( FIRINGCHANNEL, 1.0, 0, 0, GetBoneForUsing(), true );
	PlayAnim( AnimName, 1.0, 0.25, FIRINGCHANNEL );
}

function FireUseItem()
{
	if (B9_Powerups(SelectedItem) != None)
		SelectedItem.Use(0);

	ActExclusively( false );
}

///////////////////////////////////
// Jumping
//
simulated event PlayJump()
{
	local name animName;

	animName = GetJumpAnim();
	if( animName == '' )
	{
		log( "No jump animation found for "$self );
		return;
	}

	PlayAnim( animName );
}

///////////////////////////////////
// Falling
//
simulated event PlayFalling()
{
	local name animName;

	animName = GetFallingAnim();
	if( animName == '' )
	{
		log( "No falling animation found for "$self );
		return;
	}

	if( Velocity.Z <= kLongFallAccel )
	{
		LoopIfNeeded( animName, 1.0, 0.35 );
	}
}

///////////////////////////////////
// Landing
//
simulated event PlayLandingAnimation(float ImpactVel)
{
	local name animName;

	animName = GetLandingAnim();
	if( animName == '' )
	{
		log( "No landing animation found for "$self );
		return;
	}

	if( ImpactVel == 0 || Health <= 0 )
	{
		return;
	}

	if( fJustFellHard || fJustFellModerate || fGettingUp )
	{
		return;
	}

	else
	{
		fJustFellSoft = true;

		AnimBlendParams( FALLINGCHANNEL, 1.0, 0.0, 0.0, GetRootBone(), true );

		PlayAnim( animName,1.0, 0.0, FALLINGCHANNEL );
	}
}

///////////////////////////////////
// Dying
//
simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local name animName;

	animName = GetDyingAnim( HitLoc );
	if( animName == '' )
	{
		log( "No Dying animation found for "$self );
	}
	else
	{
		BlendOutAllUserChannels();
		PlayAnim( animName );
	}
	
	Super.PlayDying( DamageType, HitLoc );
}


///////////////////////////////////
// Various other PlayXXX() calls
//
simulated function PlayRunning()
{
	PlayWaiting();
}
simulated function PlayFlying()
{
	PlayWaiting();
}
simulated function PlayMovingAttack()
{
	PlayWaiting();
}
simulated function PlayWaitingAmbush()
{
	PlayWaiting();
}
simulated function PlayThreatening()
{
	PlayWaiting();
}
simulated function PlayPatrolStop()
{
	PlayWaiting();
}
simulated function PlayTurning(bool bTurningLeft)
{
	PlayWaiting();
}
simulated function PlayGutHit(float tweentime)
{
	if ( Weapon == None )
	{
		PlayAnim('nowpn_hit_gut');
	}
	else
	{
		PlayAnim('nowpn_hit_gut');
	}
}
simulated function PlayHeadHit(float tweentime)
{
	PlayGutHit(tweentime);
}
simulated function PlayLeftHit(float tweentime)
{
	PlayGutHit(tweentime);
}
simulated function PlayRightHit(float tweentime)
{
	PlayGutHit(tweentime);
}
simulated function PlayVictoryDance()
{
	PlayWaiting();
}
simulated function PlayOutOfWater()
{
	PlayFalling();
}
simulated function PlayDive()
{
	PlayAnim( 'overhand' );
}
simulated function PlayDuck()
{
	PlayAnim('nowpn_idle');
}
simulated function PlayCrawling()
{
	if ( Weapon == None )
	{
		LoopAnim('nowpn_crouch_f');
	}
	else
	{
		LoopAnim('pistol_1H_crouch_f');
	}
}
simulated function PlayWeaponSwitch(Weapon NewWeapon)
{
	// Ensure the proper animation state is set when changing weapons.
	ChangeAnimation();
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	TriggerEvent('StockOMatic', self, self); // debugging help

	if (Role == ROLE_Authority)
		ApplyModifications(); // need for debugging

	ActExclusively( false );
}

event TravelPreAccept()
{
	bInventoryToFront = true;
}

event TravelPostAccept()
{
	// Traveling of variables and items only occurs
	// just before TravelPostAccept called.

	bInventoryToFront = false;
	Super.TravelPostAccept();
	if (Role == ROLE_Authority)
		ApplyModifications();
}

simulated event PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	if (Role != ROLE_Authority)
		ApplyModifications();
}


// Add Item to this pawn's inventory, sorting body mods/skills to front. 
// Returns true if successfully added, false if not.
function bool AddInventory( inventory NewItem )
{
	// Skip if already in the inventory.
	local inventory Inv;
	local actor Last;
	local B9_CharMod ModItem;
	local B9_CharMod ModInv;

	// If not a body mod/skill, let parent class deal with it.
	ModItem = B9_CharMod(NewItem);
	if (ModItem == None)
	{
		if (bInventoryToFront)
		{
			for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
			{
				if( Inv == NewItem )
					return false;
				Last = Inv;
			}

			NewItem.SetOwner(Self);
			NewItem.Inventory = Inventory;
			Inventory = NewItem;
			if ( Controller != None )
				Controller.NotifyAddInventory(NewItem);
			return true;
		}

		return Super.AddInventory( NewItem );
	}

	Last = self;
	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		// Can't have duplicate body mods/skills.
		if( Inv.Class == NewItem.Class )
			return false;
		ModInv = B9_CharMod(Inv);
		if (ModInv == None || ModInv.fPriority < ModItem.fPriority)
			break;
		Last = Inv;
	}

	NewItem.SetOwner(Self);
	if (bInventoryToFront)
	{
		NewItem.Inventory = Inventory;
		Inventory = NewItem;
	}
	else
	{
		NewItem.Inventory = Inv;
		Last.Inventory = NewItem;
	}

	if ( Controller != None )
		Controller.NotifyAddInventory(NewItem);
	return true;
}

function SetCharacterSpeed()
{
	fCharacterSpeed = GetCrossSection() * ( fCharacterAgility * +0.8);
}

function SetCharacterHealth()
{
	fCharacterMaxHealth = fCharacterConstitution * fCharacterMaxHealthModifier;
}

function SetCharacterFocus()
{
	local int Difference;
	local int LastMax;
	LastMax = fCharacterMaxFocus;
	fCharacterMaxFocus = fCharacterDexterity * +3;
	Difference = fCharacterMaxFocus - LastMax;
	fCharacterFocus = fCharacterFocus + Difference; // Adjust the current health up because we got more hit points (Or Lost maybe if we have a way to loose Constitution)
}


function SetFireArmsSkill(int skill_strength)
{
	fCharacterTargetingFireArms = ( fCharacterAgility / +2.0 ) + (fCharacterDexterity / +2.0) + skill_strength;
}

function SetHeavyWeaponsSkill(int skill_strength )
{
	fCharacterTargetingHeavyWeapons = (fCharacterDexterity / +4.0) + (fCharacterAgility/ +4.0) + (fCharacterStrength / +2.0) + skill_strength;
}

function SetJumping(int skill_strength)
{
	fCharacterJumping = fCharacterAgility + skill_strength;
}
function SetUrbanTracking(int skill_strength)
{
	fUrbanTracking = fCharacterAgility + skill_strength;
}

function SetMeleeCombat(int skill_strength)
{
	fCharacterMeleeCombat = ( fCharacterAgility / +2.0 ) + (fCharacterStrength / +2.0) + skill_strength;
}



function ApplyModifications()
{
	local Inventory inv;
	local B9_SKill skill;
	local float CrossSection;
	local int Difference;
	local int LastMax;

	if (!bDoApplyModifications)
		return;

//	log("Applying Mods");
	// copy base attributes to working attributes
	fCharacterStrength = fCharacterBaseStrength; 
	fCharacterAgility = fCharacterBaseAgility; 
	fCharacterDexterity = fCharacterBaseDexterity; 
	fCharacterConstitution = fCharacterBaseConstitution;


	// Set intrinsic Skills
	SetCharacterSpeed();
	SetCharacterHealth();
	SetCharacterFocus();
	// After the basics are computed then cache the passive skills
	for (inv=Inventory;inv!=None;inv=inv.Inventory)
	{
		skill = B9_SKill(inv);
		if (skill != None)
		{
			skill.CacheSkillStrength(self);
			skill.UpdateSkillForStrength();
		}
	}

	if (Role==ROLE_Authority)
		ClientApplyModifications();
	
}

function ClientApplyModifications()
{
	if (Role<ROLE_Authority)
	{
		PendingApplyModifications = 2;
		//ApplyModifications();
	}
}

//
// Methods that communicate dialogue information

function int DialogueInit(out int bFaceToFace);
function DialogueResult(int Result, int Index);

//
// B9 Combat logic that affects Pawns

function bool ImmuneToDamage( Pawn instigatedBy, Vector hitlocation, class<DamageType> damageType )
{
	return false;
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	if (!ImmuneToDamage( instigatedBy, hitlocation, damageType ))
		Super.TakeDamage( Damage, instigatedBy, hitlocation, momentum, damageType );
}

function TakeFallingDamage()
{
	if( Velocity.Z < kMaxFallVelocity )
	{
		TakeDamage( 5000, None, Location, Velocity, class'Impact' );
	}
	
	Super.TakeFallingDamage();
}




simulated function ClientKickView(float Kick)
{
	// Weapon kickback

	// !!!! TODO: make this more random
	local vector X, Y, Z;

	GetAxes(Rotation, X, Y, Z);
	AddVelocity( -Kick * X );
}

function float GetCrossSection()
{
	local int crossSection;
	switch( kBodyType )
	{
	case kBodyType_Small:
			crossSection =+0.75;
		break;
	case kBodyType_Medium:
			crossSection =+1.0;
		break;
	case kBodyType_Large:
			crossSection =+1.25;
		break;
	}
	return crossSection;
}

function float GetTargetingSkill()
{
	if ( B9MeleeWeapon( Weapon ) != None )
	{
		return fCharacterMeleeCombat;
	}
	else
	if ( B9LightWeapon( Weapon ) != None )
	{
		return fCharacterTargetingFireArms;
	}
	else
	if ( B9HeavyWeapon( Weapon ) != None )
	{
		return fCharacterTargetingHeavyWeapons;
	}

	// error; don't recognize the type, or type is not handled
	Log( Class.Name $ "::GetTargetingSkill() - unknown weapon type!" );

	return 0.0f;
}

function bool UsingConstantSkill()
{
	return fUsingConstantSkill;
}

function FireNanoAttack()
{
	if ( fSelectedSkill != None )
		fSelectedSkill.FireNano();
}


//
// default properties


defaultproperties
{
	fCharacterBaseStrength=30
	fCharacterBaseAgility=30
	fCharacterBaseDexterity=30
	fCharacterBaseConstitution=30
	fCharacterFocus=10
	fCharacterMaxFocus=10
	fCharacterMeleeCombat=5
	fCharacterJumping=5
	fUrbanTracking=5
	fCharacterMaxHealth=10
	fCharacterTargetingFireArms=5
	fCharacterTargetingHeavyWeapons=5
	fCharacterMaxHealthModifier=3
	kBodyType=1
	fPercentRateofFocusIncrease=0.01
	fCanBeKnockedDownAgain=true
	WalkingPct=1
	Health=10
	Mass=200
}