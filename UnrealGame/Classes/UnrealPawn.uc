class UnrealPawn extends Pawn
	abstract
	config(User);

var	() bool		bNoDefaultInventory;	// don't spawn default inventory for this guy
var bool		bAcceptAllInventory;	// can pick up anything
var(AI) bool	bIsSquadLeader;			// only used as startup property
var bool		bSoakDebug;				// use less verbose version of debug display
var bool		bKeepTaunting;
var config bool bPlayOwnFootsteps;
var byte		LoadOut;		

var config byte SelectedEquipment[16];	// what player has selected (replicate using function)
var()	string	RequiredEquipment[16];	// allow L.D. to modify for single player
var		string	OptionalEquipment[16];	// player can optionally incorporate into loadout

var		float	AttackSuitability;		// range 0 to 1, 0 = pure defender, 1 = pure attacker
var		float	LastFootStepTime;

var eDoubleClickDir CurrentDir;
var vector			GameObjOffset;
var rotator			GameObjRot;
var(AI) name		SquadName;			// only used as startup property

var(Karma) float RagdollLifeSpan; // MAXIMUM time the ragdoll will be around. De-res's early if it comes to rest.
var(Karma) float RagInvInertia; // Use to work out how much 'spin' ragdoll gets on death.
var(Karma) float RagDeathVel; // How fast ragdoll moves upon death
var(Karma) float RagShootStrength; // How much effect shooting ragdolls has. Be careful!
var(Karma) float RagSpinScale; // Increase propensity to spin around Z (up).
var(Karma) float RagDeathUpKick; // Amount of upwards kick ragdolls get when they die

var(Karma) material RagConvulseMaterial;

// Ragdoll impact sounds.
var(Karma) array<sound>		RagImpactSounds;
var(Karma) float			RagImpactSoundInterval;
var(Karma) float			RagImpactVolume;
var transient float			RagLastSoundTime;

var string RagdollOverride;

// allowed voices
var string VoiceType;

var globalconfig bool bPlayerShadows;
var globalconfig bool bBlobShadow;

var int spree;

var array<name> TauntAnims; // Array of names of taunt anim that can be played by this character. First 4 assumed to be orders.
var localized string TauntAnimNames[8]; // Text description

simulated function bool CheckTauntValid( name Sequence ) 
{
	local int i;

	for(i=0; i<TauntAnims.Length; i++)
	{
		if(Sequence == TauntAnims[i])
			return true;
	}
	return false;
}

/* DisplayDebug()
list important actor variable on canvas.  Also show the pawn's controller and weapon info
*/
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string T;
	local float XL;

	if ( !bSoakDebug )
	{
		Super.DisplayDebug(Canvas, YL, YPos);
		return;
	}

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.StrLen("TEST", XL, YL);
	YPos = YPos + 8*YL;
	Canvas.SetPos(4,YPos);
	Canvas.SetDrawColor(255,255,0);
	T = GetDebugName();
	if ( bDeleteMe )
		T = T$" DELETED (bDeleteMe == true)";
	Canvas.DrawText(T, false);
	YPos += 3 * YL;
	Canvas.SetPos(4,YPos);

	if ( Controller == None )
	{
		Canvas.SetDrawColor(255,0,0);
		Canvas.DrawText("NO CONTROLLER");
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	else
		Controller.DisplayDebug(Canvas,YL,YPos);

	YPos += 2*YL;
	Canvas.SetPos(4,YPos);
	Canvas.SetDrawColor(0,255,255);
	Canvas.DrawText("Anchor "$Anchor$" Serpentine Dist "$SerpentineDist$" Time "$SerpentineTime);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	T = "Floor "$Floor$" DesiredSpeed "$DesiredSpeed$" Crouched "$bIsCrouched$" Try to uncrouch "$UncrouchTime;
	if ( (OnLadder != None) || (Physics == PHYS_Ladder) )
		T=T$" on ladder "$OnLadder;
	Canvas.DrawText(T);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

/* BotDodge()
returns appropriate vector for dodge in direction Dir (which should be normalized)
*/
function vector BotDodge(Vector Dir)
{
	local vector Vel;
	
	Vel = GroundSpeed*Dir;
	Vel.Z = JumpZ;
	return Vel;
}

function HoldCarriedObject(CarriedObject O, name AttachmentBone)
{
	if ( AttachmentBone == 'None' )
	{
		O.SetPhysics(PHYS_Rotating);
		O.SetLocation(Location);
		O.SetBase(self);
		O.SetRelativeLocation(vect(0,0,0));
	}	
	else
	{
		AttachToBone(O,AttachmentBone);
		O.SetRelativeRotation(GameObjRot);
		O.SetRelativeLocation(GameObjOffset);
	}
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
		return GetHumanReadableName()@Bot(Controller).SoakString;
	if ( PlayerReplicationInfo != None )
		return PlayerReplicationInfo.PlayerName;
	return GetItemName(string(self));
}

function FootStepping(int side);

function name GetWeaponBoneFor(Inventory I)
{
	return 'weapon_bone';
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
	else if ( !bWeaponBob && bPlayOwnFootSteps && !bIsWalking && !bIsCrouched && (Level.TimeSeconds - LastFootStepTime > 0.35) )
	{
		LastFootStepTime = Level.TimeSeconds; 
		FootStepping(0);
	}
}

/* IsInLoadout()
return true if InventoryClass is part of required or optional equipment
*/
function bool IsInLoadout(class<Inventory> InventoryClass)
{
	local int i;
	local string invstring;

	if ( bAcceptAllInventory )
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

	if ( IsLocallyControlled() )
	{
		for ( i=0; i<16; i++ )
			if ( RequiredEquipment[i] != "" )
				CreateInventory(RequiredEquipment[i]);

		for ( i=0; i<16; i++ )
			if ( (SelectedEquipment[i] == 1) && (OptionalEquipment[i] != "") )
				CreateInventory(OptionalEquipment[i]);

	    Level.Game.AddGameSpecificInventory(self);
	}
	else
	{
	    Level.Game.AddGameSpecificInventory(self);

		for ( i=15; i>=0; i-- )
			if ( (SelectedEquipment[i] == 1) && (OptionalEquipment[i] != "") )
				CreateInventory(OptionalEquipment[i]);

		for ( i=15; i>=0; i-- )
			if ( RequiredEquipment[i] != "" )
				CreateInventory(RequiredEquipment[i]);
	}

	// HACK FIXME
	if ( inventory != None )
		inventory.OwnerEvent('LoadOut');

	Controller.ClientSwitchToBestWeapon();
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
			if ( Inv != None )
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
	Super.PostBeginPlay();

	if ( Level.bStartup && !bNoDefaultInventory )
		AddDefaultInventory();
}

function PostNetBeginPlay()
{
	local SquadAI S;
	local RosterEntry R;
	
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
			R = GetPlacedRoster();
			UnrealMPGameInfo(Level.Game).InitPlacedBot(Controller,R);
		}
	}
}

function RosterEntry GetPlacedRoster()
{
	return None;
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

simulated function PlayFootStep()
{
	if ( (Role==ROLE_SimulatedProxy) || (PlayerController(Controller) == None) || PlayerController(Controller).bBehindView )
	{
		FootStepping(0);
		return;
	}
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
	if ( class'GameInfo'.static.UseLowGore() )
	{
		Destroy();
		return;
	}
	SpawnGibs(HitRotation,D);

	if ( Level.NetMode != NM_ListenServer )
		Destroy();
}

// spawn gibs (local, not replicated)
simulated function SpawnGibs(Rotator HitRotation, class<DamageType> D);

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local vector shotDir, hitLocRel, deathAngVel, shotStrength;
	local float maxDim;
	local string RagSkelName;
	local KarmaParamsSkel skelParams;
	
	AmbientSound = None;
    bCanTeleport = false; 
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;
		
	HitDamageType = DamageType; // these are replicated to other clients
    TakeHitLocation = HitLoc;

    // stop shooting
    AnimBlendParams(1, 0.0);
	LifeSpan = RagdollLifeSpan;

    GotoState('Dying');

	if ( Level.NetMode != NM_DedicatedServer )
	{
		// In low physics detail, if we were not just controlling this pawn, 
		// and it has not been rendered in 3 seconds, just destroy it.
		if(Level.PhysicsDetailLevel == PDL_Low && (Level.TimeSeconds - LastRenderTime > 3) )
		{
			Destroy();
			return;
		}

		// Try and obtain a rag-doll setup.
		if( RagdollOverride != "")
			RagSkelName = RagdollOverride;
		else
			Log("UnrealPawn.PlayDying: No RagdollOverride");

		// If we managed to find a name, try and make a rag-doll slot availbale.
		if( RagSkelName != "" )
		{
			KMakeRagdollAvailable();
		}
		
		if( KIsRagdollAvailable() && RagSkelName != "" )
		{  
			skelParams = KarmaParamsSkel(KParams);
			skelParams.KSkeleton = RagSkelName;
			//KParams = skelParams;
			
			//Log("RAGDOLL");
			
			// Stop animation playing.
			StopAnimating(true);
			
			// DEBUG
			//TearOffMomentum = vect(0, 0, 0);
			//if(VSize(TearOffMomentum) < 0.01)
			//	Log("TearOffMomentum magnitude of Zero");
			// END DEBUG
			
			if(DamageType != None && DamageType.default.bKUseOwnDeathVel)
			{
				RagDeathVel = DamageType.default.KDeathVel;
				RagDeathUpKick = DamageType.default.KDeathUpKick;
			}

			// Set the dude moving in direction he was shot in general
			shotDir = Normal(TearOffMomentum);
			shotStrength = RagDeathVel * shotDir;
    		
		    // Calculate angular velocity to impart, based on shot location.
		    hitLocRel = TakeHitLocation - Location;
    		
		    // We scale the hit location out sideways a bit, to get more spin around Z.
		    hitLocRel.X *= RagSpinScale;
		    hitLocRel.Y *= RagSpinScale;

			// If the tear off momentum was very small for some reason, make up some angular velocity for the pawn
			if( VSize(TearOffMomentum) < 0.01 )
			{
				//Log("TearOffMomentum magnitude of Zero");
				deathAngVel = VRand() * 18000.0;
			}
			else
			{
				deathAngVel = RagInvInertia * (hitLocRel Cross shotStrength);
			}
    		
    		// Set initial angular and linear velocity for ragdoll.
			// Scale horizontal velocity for characters - they run really fast!
			skelParams.KStartLinVel.X = 0.6 * Velocity.X;
			skelParams.KStartLinVel.Y = 0.6 * Velocity.Y;
			skelParams.KStartLinVel.Z = 1.0 * Velocity.Z;
    		skelParams.KStartLinVel += shotStrength;

			// If not moving downwards - give extra upward kick
			if(Velocity.Z > -10)
				skelParams.KStartLinVel.Z += RagDeathUpKick;
    		
    		skelParams.KStartAngVel = deathAngVel;

    		// Set up deferred shot-bone impulse
			maxDim = Max(CollisionRadius, CollisionHeight);
    		
    		skelParams.KShotStart = TakeHitLocation - (1 * shotDir);
    		skelParams.KShotEnd = TakeHitLocation + (2*maxDim*shotDir);
    		skelParams.KShotStrength = RagShootStrength;
    		    		
    		// Turn on Karma collision for ragdoll.
			KSetBlockKarma(true);
			
			// Set physics mode to ragdoll. 
			// This doesn't actaully start it straight away, it's deferred to the first tick.
			SetPhysics(PHYS_KarmaRagdoll);

			return;
		}
		// jag
	}
		
	// non-ragdoll death fallback
	Velocity += TearOffMomentum;
    BaseEyeHeight = Default.BaseEyeHeight;
	//PlayDyingAnim(DamageType, HitLoc);
    //PlayDirectionalDeath(HitLoc);
    SetPhysics(PHYS_Falling);
}

// Called when in Ragdoll when we hit something over a certain threshold velocity
// Used to play impact sounds.
event KImpact(actor other, vector pos, vector impactVel, vector impactNorm)
{
	local int numSounds, soundNum;
	numSounds = RagImpactSounds.Length;

	//log("ouch! iv:"$VSize(impactVel));

	if(numSounds > 0 && Level.TimeSeconds > RagLastSoundTime + RagImpactSoundInterval)
	{
		soundNum = Rand(numSounds);
		//Log("Play Sound:"$soundNum);
		PlaySound(RagImpactSounds[soundNum], SLOT_Pain, RagImpactVolume);
		RagLastSoundTime = Level.TimeSeconds;
	}
}

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
		if ( Controller != None )
		{
			if ( Controller.bIsPlayer )
				Controller.PawnDied(self);
			else
				Controller.Destroy();
		}
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
	}

	singular function BaseChange()
	{
		Super.BaseChange();
		// fixme - wake up karma
	}

	// If a ragdoll, add an impulse when shot
    simulated function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType)
    {
        local Vector PushLinVel;

		//log("Take Damage");

		if(bPlayedDeath && Physics == PHYS_KarmaRagdoll)
		{
			//log("HIT RAGDOLL. M:"$Momentum);

			PushLinVel = RagShootStrength*Normal(Momentum);
			KAddImpulse(PushLinVel, HitLocation);
			
			return;
		}

		Super.TakeDamage(Damage, InstigatedBy, Hitlocation, Momentum, damageType);
	}

	function BeginState()
	{
		if ( (LastStartSpot != None) && (Level.TimeSeconds - LastStartTime < 7) )
			LastStartSpot.LastSpawnCampTime = Level.TimeSeconds;
		SetCollision(true,false,false);
        if ( bTearOff && (Level.NetMode == NM_DedicatedServer) )
			LifeSpan = 1.0;
		else
			SetTimer(2.0, false);
        SetPhysics(PHYS_Falling);
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

defaultproperties
{
	bAcceptAllInventory=true
	bPlayOwnFootsteps=true
	LoadOut=255
	AttackSuitability=0.5
	SquadName=Squad
	RagdollLifeSpan=13
	RagInvInertia=4
	RagDeathVel=200
	RagShootStrength=8000
	RagSpinScale=2.5
	RagDeathUpKick=150
	RagImpactSoundInterval=0.5
	RagImpactVolume=2.5
	VoiceType="UnrealGame.TempVoice"
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
	WalkingPct=0.3
	BaseEyeHeight=60
	EyeHeight=60
	CrouchHeight=39
	UnderWaterTime=20
	ControllerClass=Class'Bot'
	LightBrightness=70
	LightRadius=6
	LightHue=40
	LightSaturation=128
	bStasis=false
	AmbientGlow=30
	Buoyancy=99
	RotationRate=(Pitch=0,Yaw=20000,Roll=2048)
	begin object name=PawnKParams class=KarmaParamsSkel
	// Object Offset:0x000A5B77
	KConvulseSpacing=(Min=0.5,Max=2.2)
	KLinearDamping=0.15
	KAngularDamping=0.05
	KBuoyancy=1
	KStartEnabled=true
	KVelDropBelowThreshold=50
	bHighDetailOnly=false
	KFriction=0.6
	KRestitution=0.3
	KImpactThreshold=500
object end
// Reference: KarmaParamsSkel'UnrealPawn.PawnKParams'
KParams=PawnKParams
	ForceType=1
	ForceRadius=100
	ForceScale=2.5
}