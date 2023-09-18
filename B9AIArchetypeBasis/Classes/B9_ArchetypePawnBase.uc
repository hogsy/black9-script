//////////////////////////////////////////////////////////////////////////
//
// Black 9 Base Class for Archetype Pawns
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnBase extends B9_AdvancedPawn; // B9_AIPawnBot_Base;

// Types
enum eWaitingAnimations
{
	kAnimIdle,
	kAnimCower,
};

// Variables
var(AIMovement) bool		fAlwaysRun;
var(AIMovement) bool		fTryToRun;
var(AIDeprecated) bool		bAllowHunting;
var(AI) bool				fAlarmGuard;
var(AIDeprecated) eWaitingAnimations	fWaitingAnimationState;
var(AIDeprecated) name		fInvalidAnimationName;
var(AIDeprecated) name		fDefaultIdleAnimationName;
var(AIDeprecated) name		fDyingAnimationName;
var(AIDeprecated) name		fActivateDeviceAnimationName;
var(AIDeprecated) float		fHuntingTimeLimit;
var(AIDeprecated) bool		fStopShortOfHuntTarget;
var(AIMovement) float		fBaseGroundSpeed;
var(AIMovement) float		fWalkingSpeedRatio;
var(AIDeprecated) bool		fSearchForWeapons;
var(AIMovement) name		fPatrolName;
var(AI) bool				fCheatAlwaysSeesEnemy;

var(AIDamage) class<DamageType> fDamageImmunity1; 
var(AIDamage) class<DamageType> fDamageImmunity2; 
var(AIDamage) class<DamageType> fDamageImmunity3; 
var(AIDamage) class<DamageType> fDamageImmunity4; 
var(AIDamage) class<DamageType> fDamageImmunity5; 

// Hiding variables
var(AIDeprecated) class	fHidingFromPawnClass;

var(AI) float				fPainMessageRadius;
var(AIDeprecated) float			fStandOffRange;

var(Inventory) class<Pickup>		fItemToDropOne;
var(Inventory) class<Pickup>		fItemToDropTwo;
var(Inventory) class<Pickup>		fItemToDropThree;

var inventory				fInventoryItemToGive;

var(AIDeprecated)	float	fSideStepAmount;

var(AIMovement) bool		fSentry;			// Won't move from placement spot
var(AIMovement) bool		fReturnToOrigPos;	// Will return to sentry position after it loses sight of the enmey. // NYI: Broken with Bot controller.

var float					fLastTimeScreamed;
var(Alarm) array< int >		fAlarmList;
enum EStartupStates
{
	kDefault,
	kPatrolling,
	kWandering,
	kFollowLeader,
	kHunt
};

var(AI) EStartupStates		fStartupState;

var(AI) name		RescueScriptTag;

var bool		bIsBig;	// Is this a big bot.


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



//
// Function required by the Bot controller.
//

simulated function Rescued()
{
	local AIScript A;

	if ( (RescueScriptTag != 'None') && (RescueScriptTag != '') )
		{
			ForEach AllActors(class'AIScript',A,RescueScriptTag)
				break;
			// let the AIScript spawn and init my controller
			if ( A != None )
			{
				SetOwner(None);
				Controller = None;
				A.SpawnControllerFor(self);
			}
		}
}

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist;

	log( "------ CalcBehindView" );
	Dist += 150.0;

	CameraRotation = Rotation;
	View = vect(1,0,0) >> CameraRotation;
	if( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
		ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
	else
		ViewDist = Dist;
	CameraLocation -= (ViewDist - 30) * View; 
}


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

// Global functions

function SetDropItems( class<Pickup> item1, class<Pickup> item2, class<Pickup> item3 )
{
	fItemToDropOne = item1;
	fItemToDropTwo = item2;
	fItemToDropThree = item3;
}

function PostBeginPlay()
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
	
	///////////////////////////////
	// Christian - This little section of code adds meaning to the 
	// fBaseGroundSpeed that is exposed to unrealed.  Basically 
	// the speed entered in that field will change the default 
	// ground running speed.
	//
	if( fBaseGroundSpeed > 0 )
	{	
		GroundSpeed = fBaseGroundSpeed;
	}
}


// Functions
function PutAwayWeapon()
{
	if ( Weapon.IsInState('DownWeapon') ) 
		Weapon.GotoState('Idle');
	PendingWeapon = None;
	ServerChangedWeapon(Weapon, None);
	Weapon = None;
	PendingWeapon = None;
}


function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	// Let his buddies know he's being hurt.
	EmitPainMessage( instigatedBy );
	
	if( damageType != fDamageImmunity1 &&
		damageType != fDamageImmunity2 &&
		damageType != fDamageImmunity3 &&
		damageType != fDamageImmunity4 &&
		damageType != fDamageImmunity5 )
	{
		Super.TakeDamage( Damage, instigatedBy, hitlocation, momentum, damageType );
	}
}

function EmitPainMessage( Pawn instigatedBy )
{
	local B9_ArchetypePawnBase buddyPawn;
	
	if ( (Controller.Level.TimeSeconds - fLastTimeScreamed) > 5 )
	{
		fLastTimeScreamed = Controller.Level.TimeSeconds;

		//log( "ALEX: AI: " $self $"Emiting pain message" );

		ForEach RadiusActors( class'B9_ArchetypePawnBase', buddyPawn, fPainMessageRadius )
		{
			if( buddyPawn.fFaction == fFaction )
			{
				//log( "ALEX: AI: " $self $"Emiting pain message to: " $buddyPawn );
				buddyPawn.HearPainMessageAbout( instigatedBy );
			}
		}
	}
}

function PlayEnemySpottedSound()
{
}

function PlayIdleSpeech()
{
}

function EmitEnemySpottedMessage( Pawn instigatedBy )
{
	local B9_ArchetypePawnBase buddyPawn;

	//log( "ALEX: AI: " $self $"Emiting Enemy spotted message" );
	
	if ( (Controller.Level.TimeSeconds - fLastTimeScreamed) > 5 )
	{
		fLastTimeScreamed = Controller.Level.TimeSeconds;
		PlayEnemySpottedSound();
		ForEach RadiusActors( class'B9_ArchetypePawnBase', buddyPawn, fPainMessageRadius )
		{
			if( buddyPawn.fFaction == fFaction )
			{
				//log( "ALEX: AI: " $self $"Emiting spotted message to: " $buddyPawn );
				buddyPawn.HearEnemySpotted( instigatedBy );
			}
		}
	}
}

function HearPainMessageAbout( Pawn instigatedBy );

function HearEnemySpotted( Pawn seen );


// Start Inventory

function GiveInventoryItemToPawn( Pawn p )
{
	// Give the item to the target pawn
	p.AddInventory( fInventoryItemToGive );

	// Remove this item from ourselves
	DeleteInventory( fInventoryItemToGive );
}	

// End Inventory



function vector GetItemDropLocation()
{
	// ANF@@@ Calculate a spot directly in front of pawn?
	local vector dropLocation;
	dropLocation = Location;
	dropLocation.z -= 70;

	return dropLocation;
}

function float GetIntimidationValue()
{
	return 1.0;
}

function float GetIntimidationRange()
{
	return 200.0;
}

function IntimidatedBy( B9_ArchetypePawnBase pawn )
{
	if( B9_AI_ControllerBase( Controller ) != None )
	{
		B9_AI_ControllerBase( Controller ).IntimidatedBy( pawn );
	}
}

function int DialogueInit(out int bFaceToFace)
{
	if( B9_AI_ControllerBase( Controller ) != None )
		return B9_AI_ControllerBase( Controller ).DialogueInit( bFaceToFace );
	return 0;
}

function DialogueResult(int Result, int Index)
{
	if( B9_AI_ControllerBase( Controller ) != None )
		B9_AI_ControllerBase( Controller ).DialogueResult( Result, Index );
}


function bool IsDemoProtagPawn()
{
	return false;
}



defaultproperties
{
	fTryToRun=true
	bAllowHunting=true
	fDefaultIdleAnimationName=Idle
	fDyingAnimationName=nowpn_knockdown_b
	fHuntingTimeLimit=600
	fStopShortOfHuntTarget=true
	fWalkingSpeedRatio=0.6
	fPatrolName=DefaultPatrol
	fHidingFromPawnClass=Class'B9BasicTypes.B9_BasicPlayerPawn'
	fPainMessageRadius=500
	fStandOffRange=500
	fSideStepAmount=100
	fStartupState=2
	LoadOut=255
	AttackSuitability=0.5
	SquadName=Squad
	bCanCrouch=true
	bCanSwim=true
	bCanClimbLadders=true
	bCanStrafe=true
	bCanPickupInventory=true
	bMuffledHearing=true
	bAroundCornerHearing=true
	SightRadius=12000
	MeleeRange=20
	JumpZ=540
	AirControl=0.35
	BaseEyeHeight=60
	EyeHeight=60
	CrouchHeight=39
	UnderWaterTime=20
	ControllerClass=Class'UnrealGame.Bot'
	bPhysicsAnimUpdate=true
	LightBrightness=70
	LightRadius=6
	LightHue=40
	LightSaturation=128
	Physics=1
	bStasis=false
	AmbientGlow=17
	TransientSoundRadius=100
	Buoyancy=99
	RotationRate=(Pitch=0,Yaw=20000,Roll=2048)
	ForceType=1
	ForceRadius=100
	ForceScale=1
}