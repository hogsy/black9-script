
class B9_AIPawnBot_Base extends B9_AdvancedPawn;



//////////////////////////////////////
// Epic Code
//
var byte		LoadOut;		// FIXME - HACK
var() bool		bNoDefaultInventory;	// don't spawn default inventory for this guy

// allowed voices
var string VoiceType;

var() string RequiredEquipment[16];		// allow L.D. to modify for single player
var	  string OptionalEquipment[16];		// player can optionally incorporate into loadout
var config byte SelectedEquipment[16];	// what player has selected (replicate using function)

var		float	AttackSuitability;		// range 0 to 1, 0 = pure defender, 1 = pure attacker
var eDoubleClickDir CurrentDir;
var name FlagBone;
var vector FlagOffset;
var rotator FlagRotation;
var(AI) name SquadName;					// only used as startup property
var(AI) bool bIsSquadLeader;			// only used as startup property

function HoldFlag(CTFFlag F)
{
	AttachToBone(F,FlagBone);
	F.SetRelativeRotation(FlagRotation);
	F.SetRelativeLocation(FlagOffset);
}

function EndJump();	// Called when stop jumping

simulated function ShouldUnCrouch();	

simulated event SetAnimAction(name NewAction)
{
    AnimAction = NewAction;
	PlayAnim(AnimAction);
}

function String GetDebugName()
{
	if ( (Bot(Controller) != None) && Bot(Controller).bSoaking && (Level.Pauser != None) )
		return GetItemName(string(self))@Bot(Controller).SoakString;
	return GetItemName(string(self));
}

function LogOut();

function name GetWeaponBoneFor(Inventory I)
{
	return 'weaponbone';
}

function CheckBob(float DeltaTime, vector Y)
{
	local float OldBobTime;
	local int m,n;

	OldBobTime = BobTime;
	Super.CheckBob(DeltaTime,Y);

	if ( (Physics != PHYS_Walking) || (VSize(Velocity) < 10)
		|| ((PlayerController(Controller) != None) && PlayerController(Controller).bBehindView) )
		return;

	m = int(0.5 * Pi + 9.0 * OldBobTime/Pi);
	n = int(0.5 * Pi + 9.0 * BobTime/Pi);

	if ( (m != n) && !bIsWalking && !bIsCrouched )
		FootStepping(0);
}

/* IsInLoadout()
return true if InventoryClass is part of required or optional equipment
*/
function bool IsInLoadout(class<Inventory> InventoryClass)
{
	local int i;
	local string invstring;

	// FIXME - for now, pretend all non-weapons are in loadout
	if ( class<Weapon>(InventoryClass) == None )
		return true;

	invstring = string(InventoryClass);

	for ( i=0; i<16; i++ )
	{
		if ( RequiredEquipment[i] ~= invstring )
			return true;
		else if ( RequiredEquipment[i] == "" )
			break;
	}

	for ( i=0; i<16; i++ )
	{
		if ( OptionalEquipment[i] ~= invstring )
			return true;
		else if ( OptionalEquipment[i] == "" )
			break;
	}
	return false;
}

function AddDefaultInventory()
{
	local int i;

	for ( i=0; i<16; i++ )
		if ( RequiredEquipment[i] != "" )
			CreateInventory(RequiredEquipment[i]);


	for ( i=0; i<16; i++ )
		if ( (SelectedEquipment[i] == 1) && (OptionalEquipment[i] != "") )
			CreateInventory(OptionalEquipment[i]);

	// HACK FIXME
	if ( inventory != None )
		inventory.OwnerEvent('LoadOut');

	Controller.SwitchToBestWeapon();
}

function CreateInventory(string InventoryClassName)
{
	local Inventory Inv;
	local class<Inventory> InventoryClass;

	InventoryClass = Level.Game.BaseMutator.GetInventoryClass(InventoryClassName);
	if( (InventoryClass!=None) && (FindInventoryType(InventoryClass)==None) )
	{
		Inv = Spawn(InventoryClass);
		if( Inv != None )
		{
			Inv.GiveTo(self);
			Inv.PickupFunction(self);
		}
	}
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	local vector X,Y,Z;

	if ( bIsCrouched || bWantsToCrouch || (Physics != PHYS_Walking) )
		return false;

	GetAxes(Rotation,X,Y,Z);
	if (DoubleClickMove == DCLICK_Forward)
		Velocity = 1.5*GroundSpeed*X + (Velocity Dot Y)*Y;
	else if (DoubleClickMove == DCLICK_Back)
		Velocity = -1.5*GroundSpeed*X + (Velocity Dot Y)*Y; 
	else if (DoubleClickMove == DCLICK_Left)
		Velocity = 1.5*GroundSpeed*Y + (Velocity Dot X)*X; 
	else if (DoubleClickMove == DCLICK_Right)
		Velocity = -1.5*GroundSpeed*Y + (Velocity Dot X)*X; 

	Velocity.Z = 210;
	CurrentDir = DoubleClickMove;
	SetPhysics(PHYS_Falling);
	return true;
}

simulated function PostBeginPlay()
{
	local SquadAI S;

	Super.PostBeginPlay();
//	if ( Level.NetMode != NM_DedicatedServer )
//		Shadow = Spawn(class'PlayerShadow',self);
	if ( Level.bStartup && !bNoDefaultInventory )
		AddDefaultInventory();
	if ( Level.bStartup )
	{
		if ( UnrealMPGameInfo(Level.Game) == None )
		{
			if ( Bot(Controller) != None )
			{
				ForEach DynamicActors(class'SquadAI',S,SquadName)
					break;
				if ( S == None )
					S = spawn(class'SquadAI');
				S.Tag = SquadName;
				if ( bIsSquadLeader || (S.SquadLeader == None) )
					S.SetLeader(Controller);
				S.AddBot(Bot(Controller));
			}
		}
		else
		{
			UnrealMPGameInfo(Level.Game).InitPlacedBot(Controller,None);
		}
	}
}
	
function SetMovementPhysics()
{
	if (Physics == PHYS_Falling)
		return;
	if ( PhysicsVolume.bWaterVolume )
		SetPhysics(PHYS_Swimming);
	else
		SetPhysics(PHYS_Walking); 
}

function TakeDrowningDamage()	
{	
	TakeDamage(5, None, Location + CollisionHeight * vect(0,0,0.5)+ 0.7 * CollisionRadius * vector(Controller.Rotation), vect(0,0,0), class'Drowned'); 
}


//-----------------------------------------------------------------------------

/* 
Pawn was killed - detach any controller, and die
*/
simulated function ChunkUp( Rotator HitRotation, class<DamageType> D ) 
{
	if ( (Level.NetMode != NM_Client) && (Controller != None) )
	{
		if ( Controller.bIsPlayer )
			Controller.PawnDied(self);
		else
			Controller.Destroy();
	}

	bTearOff = true;
	HitDamageType = class'Gibbed'; // make sure clients gib also
	if ( (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer) )
		GotoState('TimingOut');
	if ( Level.NetMode == NM_DedicatedServer ) 
		return;
	if ( class'GameInfo'.Default.GoreLevel > 0 )
	{
		Destroy();
		return;
	}
	SpawnGibs(HitRotation,D);
	
	if ( Level.NetMode != NM_ListenServer )
		Destroy();
}

// spawn gibs (local, not replicated)
function SpawnGibs(Rotator HitRotation, class<DamageType> D);

function PlayFeignDeath();
function PlayRising();

/* TimingOut - where gibbed pawns go to die (delay so they can get replicated)
*/
State TimingOut
{
ignores BaseChange, Landed, AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
	{
	}

	function BeginState()
	{
		SetPhysics(PHYS_None);
		SetCollision(false,false,false);
		LifeSpan = 1.0;
	}
}

State FeigningDeath
{
ignores Bump, HitWall;

	event PlayDying(class<DamageType> DamageType, vector HitLocation)
	{
		BaseEyeHeight = Default.BaseEyeHeight;
		if ( IsAnimating(0) )
			Global.PlayDying(DamageType, HitLocation);
	}
	
	function ChangedWeapon()
	{
		ServerChangedWeapon(Weapon,None);
		Weapon = None;
	}
} 
State Dying
{
ignores AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	function Landed(vector HitNormal)
	{
		LandBob = FMin(50, 0.055 * Velocity.Z); 
		if ( Level.NetMode == NM_DedicatedServer )
			return;
		if ( Shadow != None )
			Shadow.Destroy();

		// FIXME
		//if ( UTBloodPool2(Shadow) == None )
		//	Shadow = Spawn(class'UTBloodPool2',,,Location, rotator(HitNormal));
	}

	singular function BaseChange()
	{
		Super.BaseChange();
		// fixme - wake up karma
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType)
	{
		if ( bInvulnerableBody )
			return;
		Damage *= DamageType.Default.GibModifier;
		Health -=Damage;
		if ( (Damage > 40) && (Health < -60) )
		{
			ChunkUp(Rotation,damageType);
			return;
		}
		/* UWRAGDOLL
		if ( (Level.NetMode != NM_DedicatedServer) && (KPhysics != '') )
		{
			SetPhysics(PHYS_KarmaRagDoll);
			KAddImpulse(momentum, hitlocation);
		}
		*/
	}

	function BeginState()
	{
		SetCollision(true,false,false);
		if ( Level.NetMode == NM_DedicatedServer )
			LifeSpan = 1.0;
		else
			SetTimer(18.0, false);

		bInvulnerableBody = true;
		if ( Controller != None )
		{
			if ( Controller.bIsPlayer )
				Controller.PawnDied(self);
			else
				Controller.Destroy();
		}
	}
}




//////////////////////////////////////////////////
// Taldren Code
//

///////////////////////////////////
// AnimateXXX()
// Sets up the movement anims in response to movement type / physics changes
//
simulated function AnimateWalking()
{
	MovementAnims[0]	= 'nowpn_Walk_F';
	MovementAnims[1]	= 'nowpn_Walk_B';
	MovementAnims[2]	= 'nowpn_Walk_Sidestep_L';
	MovementAnims[3]	= 'nowpn_Walk_Sidestep_R';
	TurnLeftAnim		= 'nowpn_Walk_F';
	TurnRightAnim		= 'nowpn_Walk_F';
}

simulated function AnimateRunning()
{
	MovementAnims[0]	= 'nowpn_Run_F';
	MovementAnims[1]	= 'nowpn_Run_B';
	MovementAnims[2]	= 'nowpn_Run_Step_L';
	MovementAnims[3]	= 'nowpn_Run_Step_R';
	TurnLeftAnim		= 'nowpn_Run_F';
	TurnRightAnim		= 'nowpn_Run_F';
}

simulated function AnimateCrouchWalking()
{
	MovementAnims[0]	= 'nowpn_crouch_f';
	MovementAnims[1]	= 'nowpn_crouch_b';
	MovementAnims[2]	= 'nowpn_crouch_Step_L';
	MovementAnims[3]	= 'nowpn_crouch_Step_R';
	TurnLeftAnim		= 'nowpn_crouch_f';
	TurnRightAnim		= 'nowpn_crouch_f';
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
	MovementAnims[1]	= 'nowpn_wingpack_back';
	MovementAnims[2]	= 'nowpn_wingpack_slide_left';
	MovementAnims[3]	= 'nowpn_wingpack_slide_right';
	TurnLeftAnim		= 'nowpn_wingpack_forward';
	TurnRightAnim		= 'nowpn_wingpack_forward';
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

	ChangeAnimation();
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
	local int						which_idle;
	local name						idleAnimName;
	local WeaponAttachment.eWeaponAnimKind	weapKind;

	if ( (PlayerController(Controller) != None) && PlayerController(Controller).bIsTyping )
	{
		// FIXME - play chatting animation
		return;
	}

	if( fGettingUp || fJustFellHard )
	{
		return;
	}

	if( IsAnimating( FALLINGCHANNEL ) && ( Velocity.X != 0 || Velocity.Y != 0 ) )
	{
		if( fJustFellHard || fJustFellModerate )
		{
			return;
		}
		else if( fJustFellSoft )
		{
            fJustFellSoft = false;
		}

		AnimBlendToAlpha( FALLINGCHANNEL, 0, 0.01 );
	}

	weapKind = GetWeaponKind();

	if( weapKind == wepAnimKind_Rifle )
	{
		LoopIfNeeded('rifle_idle', 1.0, 0.0 );
	}
	else if( weapKind == wepAnimKind_Pistol_1H )
	{
		LoopIfNeeded( 'pistol_1H_fire_idle', 1.0, 0.0 );
	}
	else if( weapKind == wepAnimKind_Melee_1H )
	{
		LoopIfNeeded('melee_idle', 1.0, 0.0 );
	}
	else
	{		
		which_idle = Rand(100);
		// Idle and Idle1 are the more subtle thus the most often used idle routine.
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

		LoopIfNeeded( idleAnimName, 1.0, 0.0 );
	}
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
			AnimBlendToAlpha( FALLINGCHANNEL, 0, 0.01 );
			PlayWaiting();
		}
	}
}

simulated event ChangeAnimation()
{
	if ( (Controller != None) && Controller.bControlAnimations )
		return;

	PlayWaiting();
	PlayMoving();
}

simulated function PlayWaiting()
{
	if( Physics == PHYS_Swimming )
	{
		AnimateTreading();
	}
	else if( Physics == PHYS_Flying )
	{
		AnimateHovering();
	}
	else if( Physics == PHYS_Ladder )
	{
		AnimateStoppedOnLadder();
	}
	else if( Physics == PHYS_Falling )
	{
		PlayFalling();
	}
	else if( bIsCrouched )
	{
		AnimateCrouching();
	}
	else
	{
		AnimateStanding();
	}
}

simulated function PlayMoving()
{
	if( Physics == PHYS_None || (( Role == ROLE_Authority ) && (Controller == None)) )
	{
		return;
	}

	else if ( Physics == PHYS_Walking )
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
	else if( weapKind == wepAnimKind_Rifle )
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
simulated function PlayNanoAttack()
{
	local WeaponAttachment.eWeaponAnimKind Kind;
	local name	AnimName;

	Kind = GetWeaponKind();
	bSteadyFiring = false;

	if (Kind == wepAnimKind_Rifle)
	{
		AnimName = 'rifle_nano';
	}
	else if (Kind == wepAnimKind_NoWpn)
	{
		AnimName = 'melee_nano';
	}
	else
	{
		AnimName = 'pistol_1h_nano';
	}

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
}

function FireUseSwitch()
{
	local Actor A;

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
	else
	{
		AnimName = 'pistol_1h_throwgrenade';
	}

	AnimBlendParams( FIRINGCHANNEL, 1.0, 0, 0, GetBoneForUsing(), true );
	PlayAnim( AnimName, 1.0, 0.25, FIRINGCHANNEL );
}

function FireThrowItem()
{
	if (B9_TossibleItem(SelectedItem) != None)
		B9_TossibleItem(SelectedItem).Fire(0);
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
}

///////////////////////////////////
// Jumping
//
simulated event PlayJump()
{
	local name animName;

	if ( (Acceleration.X != 0) || (Acceleration.Y != 0) )
	{
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
		//PlayAnim( 'nowpn_land_flailing', 1.0, 0.35 );
		LoopIfNeeded( 'nowpn_land_flailing', 1.0, 0.35 );
	}
	else if( Velocity.Z <= kNormalLandingThreshold )
	{
		//PlayAnim( 'nowpn_land_falling', 1.0, 0.35 );
		LoopIfNeeded( 'nowpn_land_falling', 1.0, 0.35 );
	}
}

///////////////////////////////////
// Landing
//
simulated event PlayLandingAnimation(float ImpactVel)
{
	log( "PlayLandingAnimation() - ImpactVel="$ImpactVel );

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
		log( "PlayLandingAnimation - Hard landing" );

		fJustFellHard = true;

		fControllerLastState = Controller.GetStateName();
		Controller.GotoState( 'SuspendPlayerInput' );
		
		AnimBlendParams( FALLINGCHANNEL, 1.0, 0.0, 0.0, GetRootBone(), true );
		PlayAnim( 'nowpn_knockdown_b', 1.0, 0.0, FALLINGCHANNEL );
	}

	// Moderate fall
	//
	else if( ImpactVel < kNormalLandingThreshold )
	{
		log( "PlayLandingAnimation - Moderate landing" );

		fJustFellModerate = true;

		fControllerLastState = Controller.GetStateName();
		Controller.GotoState( 'SuspendPlayerInput' );
		
		AnimBlendParams( FALLINGCHANNEL, 1.0, 0.0, 0.0, GetRootBone(), true );
		PlayAnim( 'nowpn_jump_u_end', 1.0, 0.0, FALLINGCHANNEL );
	}

	// Not really a fall; just jumped
	//
	else
	{
		log( "PlayLandingAnimation - Normal landing" );

		fJustFellSoft = true;

		AnimBlendParams( FALLINGCHANNEL, 1.0, 0.0, 0.0, GetRootBone(), true );

		if ( (Acceleration.X != 0) || (Acceleration.Y != 0) )
		{
			PlayAnim( 'nowpn_jump_run_f_end',1.0, 0.0, FALLINGCHANNEL );
		}
		else
		{
			PlayAnim( 'nowpn_jump_u_end', 1.0, 0.0, FALLINGCHANNEL );
		}
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
// Dying
//
simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	BlendOutAllUserChannels();

	if ( Weapon == None )
	{
		PlayAnim('nowpn_knockdown_f');
	}
	else
	{
		PlayAnim('nowpn_knockdown_f');
	}

	Super.PlayDying( DamageType, HitLoc );
}


///////////////////////////////////
// Various other PlayXXX() calls
//
simulated function PlayRunning()
{
	PlayMoving();
}
simulated function PlayFlying()
{
	PlayMoving();
}
simulated function PlayMovingAttack()
{
	PlayMoving();
}
simulated function PlayWaitingAmbush()
{
	PlayWaiting();
}
simulated function PlayThreatening()
{
	PlayMoving();
}
simulated function PlayPatrolStop()
{
	PlayWaiting();
}
simulated function PlayTurning(bool bTurningLeft)
{
	PlayMoving();
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
	PlayMoving();
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

//////////////////////////////////////
//


defaultproperties
{
	LoadOut=255
	AttackSuitability=0.5
	SquadName=Squad
	bCanCrouch=true
	bCanSwim=true
	bCanClimbLadders=true
	bCanStrafe=true
	bCanPickupInventory=true
	bMuffledHearing=true
	SightRadius=12000
	MeleeRange=20
	JumpZ=540
	AirControl=0.35
	BaseEyeHeight=60
	EyeHeight=60
	CrouchHeight=39
	UnderWaterTime=20
	ControllerClass=Class'UnrealGame.Bot'
	LightBrightness=70
	LightRadius=6
	LightHue=40
	LightSaturation=128
	bStasis=false
	AmbientGlow=17
	TransientSoundRadius=100
	Buoyancy=99
	RotationRate=(Pitch=0,Yaw=20000,Roll=2048)
	ForceType=1
	ForceRadius=100
	ForceScale=1
}