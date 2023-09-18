//=============================================================================
// Bot.
//=============================================================================
class Bot extends ScriptedController;

///////////////////////////////////
// ?,Taldren,
// 
//

// MikeT: The changes I've made here are far too extensive to just automatically
// edit in...

// AI Magic numbers - distance based, so scale to bot speed/weapon range
const MAXSTAKEOUTDIST = 2000;
const ENEMYLOCATIONFUZZ = 1200;
const TACTICALHEIGHTADVANTAGE = 320;
const MINSTRAFEDIST = 200;
const MINVIEWDIST = 200;

//AI flags
var		bool		bCanFire;			// used by TacticalMove and Charging states
var		bool		bStrafeDir;
var		bool		bLeadTarget;		// lead target with projectile attack
var		bool		bChangeDir;			// tactical move boolean
var		bool		bFrustrated;
var		bool		bInitLifeMessage;
var		bool		bReachedGatherPoint;
var		bool		bFinalStretch;
var		bool		bJumpy;				// likes to jump around if true
var		bool		bHasTranslocator;
var		bool		bHasImpactHammer;
var		bool		bTacticalDoubleJump;
var		bool		bWasNearObjective;
var		bool		bPlannedShot;
var		bool		bHasFired;
var		bool		bForcedDirection;
var		bool		bFireSuccess;
var		bool		bEnemyIsVisible;
var		bool		bTranslocatorHop;
var		bool		bEnemyEngaged;
var		bool		bMustCharge;
var		bool		bPursuingFlag;
var		bool		bJustLanded;
var		bool		bSingleTestSection;		// used in ReviewJumpSpots;
var		bool		bRecommendFastMove;
var		bool		bJustDidRangedAttack;

var		actor		TranslocationTarget;
var		actor		RealTranslocationTarget;
var		actor		ImpactTarget;
var		float		TranslocFreq;

var name	OldMessageType;
var int		OldMessageID;

// Advanced AI attributes.
var	vector			HidingSpot;
var	float			Aggressiveness;		// 0.0 to 1.0 (typically)
var float			LastAttractCheck;
var NavigationPoint BlockedPath;
var	float			AcquireTime;		// time at which current enemy was acquired
var float			Aggression;
var float			LoseEnemyCheckTime;
var actor			StartleActor;
var	float			StartTacticalTime;

// modifiable AI attributes
var float			BaseAlertness;
var float			Accuracy;			// -1 to 1 (0 is default, higher is more accurate)
var	float		    BaseAggressiveness; // 0 to 1 (0.3 default, higher is more aggressive)
var	float			StrafingAbility;	// -1 to 1 (higher uses strafing more)
var	float			CombatStyle;		// -1 to 1 = low means tends to stay off and snipe, high means tends to charge and melee
var float			Tactics;
var float			TranslocUse;		// 0 to 1 - higher means more likely to use
var float			ReactionTime;
var class<Weapon>	FavoriteWeapon;

// Team AI attributes
var string			GoalString;			// for debugging - used to show what bot is thinking (with 'ShowDebug')
var string			SoakString;			// for debugging - shows problem when soaking
var SquadAI			Squad;
var Bot				NextSquadMember;	// linked list of members of this squad

var float			ReTaskTime;			// time when squad will retask bot (delayed to avoid hitches)

// Scripted Sequences
var UnrealScriptedSequence GoalScript;	// ScriptedSequence bot is moving toward (assigned by TeamAI)
var UnrealScriptedSequence EnemyAcquisitionScript;

enum EScriptFollow
{
	FOLLOWSCRIPT_IgnoreAllStimuli,
	FOLLOWSCRIPT_IgnoreEnemies,
	FOLLOWSCRIPT_StayOnScript,
	FOLLOWSCRIPT_LeaveScriptForCombat
};
var EScriptFollow ScriptedCombat;

var int FormationPosition;

// ChooseAttackMode() state
var	int			ChoosingAttackLevel;
var float		ChooseAttackTime;
var int			ChooseAttackCounter;
var float		EnemyVisibilityTime;
var	pawn		VisibleEnemy;
var pawn		OldEnemy;		//FIXME TEMP
var float		StopStartTime;
var float		LastRespawnTime;
var float		FailedHuntTime;
var Pawn		FailedHuntEnemy;

// inventory searh
var float		LastSearchTime;
var float		LastSearchWeight;
var float		CampTime;
var int LastTaunt;

var int		NumRandomJumps;			// attempts to free bot from being stuck
var string ComboNames[4];

// weapon check
var float LastFireAttempt;
var float GatherTime;

var() name OrderNames[16];

// 1vs1 Enemy location model
var vector LastKnownPosition;
var vector LastKillerPosition;

// for testing
var NavigationPoint TestStart;
var int TestPath;
var name TestLabel;

function Destroyed()
{
	Squad.RemoveBot(self);
	if ( GoalScript != None )
		GoalScript.FreeScript();
	Super.Destroyed();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetCombatTimer();
	Aggressiveness = BaseAggressiveness;
	//if ( UnrealMPGameInfo(Level.Game).bSoaking )
	//	bSoaking = true;
}

/* FIXME_MERGE - Implement
*/
function bool NeedAmmo()
{
	return false;
}

/* called before start of navigation network traversal to allow setup of transient navigation flags
*/
event SetupSpecialPathAbilities()
{
	bAllowedToTranslocate = CanUseTranslocator();
	bAllowedToImpactJump = CanImpactJump();
}
	
function bool CanDoubleJump(Pawn Other)
{
	return ( Pawn.bCanDoubleJump || (PhysicsVolume.Gravity.Z > PhysicsVolume.Default.Gravity.Z) );
}

function TryCombo(string ComboName)
{
/* FIXME_MERGE
	if ( !Pawn.InCurrentCombo() && !NeedsAdrenaline() )
	{
		if ( ComboName ~= "Random" )
			ComboName = ComboNames[Rand(ArrayCount(ComboNames))];
		else if ( ComboName ~= "DMRandom" )
			ComboName = ComboNames[1 + Rand(ArrayCount(ComboNames) - 1)];
		ComboName = Level.Game.RecommendCombo(ComboName);
		Pawn.DoComboName(ComboName);
		if ( !Pawn.InCurrentCombo() )
			log("WARNING - bot failed to start combo!");
	}
*/
}

function FearThisSpot(AvoidMarker aSpot)
{
	if ( Skill > 1 + 4.5 * FRand() )
		Super.FearThisSpot(aSpot);
}

function Startle(Actor Feared)
{
	GoalString = "STARTLED!";
	StartleActor = Feared;
	GotoState('Startled');
}

function SetCombatTimer()
{
	SetTimer(5.0 - 0.09 * FMin(10,Skill+ReactionTime), True);
}

function bool AutoTaunt()
{
	return true;
}

function bool DontReuseTaunt(int T)
{
	if ( T == LastTaunt )
		return true;

	LastTaunt = T;

	return false;
}

function InitPlayerReplicationInfo()
{
	Super.InitPlayerReplicationInfo();
	if ( VoiceType != "" )
		PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject(VoiceType,class'Class'));
}

function Pawn GetMyPlayer()
{
	if ( PlayerController(Squad.SquadLeader) != None )
		return Squad.SquadLeader.Pawn;
	return Super.GetMyPlayer();
}


// Function that is called at the start of most states.
function StartState()
{
}


//===========================================================================
// Weapon management functions

simulated function float RateWeapon(Weapon w)
{
	return (W.GetAIRating() + FRand() * 0.05);
}

function bool CanImpactJump()
{
	return ( bHasImpactHammer && (Pawn.Health >= 80) && (Skill >= 5) && Squad.AllowImpactJumpBy(self) );
}

function bool CanUseTranslocator()
{
	return ( bHasTranslocator && (skill >= 2) && Squad.AllowTranslocationBy(self) );
}

function ImpactJump()
{
	local vector RealDestination;

	// FIXME - charge up hack in here
	if (Pawn.Weapon != None)
		Pawn.Weapon.FireHack(0);
	// find correct initial velocity
	RealDestination = Destination;
	Destination = ImpactTarget.Location;
	Pawn.SetPhysics(PHYS_Falling);
	Pawn.Velocity = SuggestFallVelocity(Destination, Pawn.Location, Pawn.JumpZ+900, Pawn.GroundSpeed);
	if ( Pawn.Velocity.Z > 900 )
	{
		Pawn.Velocity.Z = Pawn.Velocity.Z - 0.5 * Pawn.JumpZ;
		bNotifyApex = true;
		bPendingDoubleJump = true;
	}
	Destination = RealDestination;
	ImpactTarget = None;
	bPreparingMove = false;
}

function WaitForMover(Mover M)
{
	Super.WaitForMover(M);
	StopStartTime = Level.TimeSeconds;
}

/* WeaponFireAgain()
Notification from weapon when it is ready to fire (either just finished firing,
or just finished coming up/reloading).
Returns true if weapon should fire.
If it returns false, can optionally set up a weapon change
*/
function bool WeaponFireAgain(float RefireRate, bool bFinishedFire)
{
	LastFireAttempt = Level.TimeSeconds;
	if ( Target == None )
		Target = Enemy;
	if ( Target != None )
	{
		if ( !Pawn.Weapon.IsFiring() )
		{
			if ( Pawn.Weapon.bMeleeWeapon || (!NeedToTurn(Target.Location) && CanAttack(Target)) )
			{
				Focus = Target;
				bCanFire = true;
				bFireSuccess = Pawn.Weapon.BotFire(bFinishedFire);
				return bFireSuccess;
			}
			else
			{
				bCanFire = false;
			}
		}
		else if ( bCanFire && (FRand() < RefireRate) )
		{
			if ( (Target != None) && (Focus == Target) && !Target.bDeleteMe )
			{
				bFireSuccess = Pawn.Weapon.BotFire(bFinishedFire);
				return bFireSuccess;
			}
		}
	}
	StopFiring();
	return false;
}

function TimedFireWeaponAtEnemy()
{
	if ( (Enemy == None) || FireWeaponAt(Enemy) )
		SetCombatTimer();
	else
		SetTimer(0.1, True);
}
 
function bool FireWeaponAt(Actor A)
{
	if ( A == None )
		A = Enemy;
	if ( (A == None) || (Focus != A) )
		return false;
	Target = A;
	if ( (Pawn.Weapon != None) && Pawn.Weapon.HasAmmo() )
		return WeaponFireAgain(Pawn.Weapon.RefireRate(),false);
	return false;
}

function bool CanAttack(Actor Other)
{
	// return true if in range of current weapon
	return Pawn.Weapon.CanAttack(Other);
}


function bool ShouldWalk()
{
	return false;
}

function StopFiring()
{
	bCanFire = false;
	bFire = 0;
	bAltFire = 0;
}

function ChangedWeapon()
{
	if ( Pawn.Weapon != None )
		Pawn.Weapon.SetHand(0);
}

function float WeaponPreference(Weapon W)
{
	if ( (GoalScript != None) && (GoalScript.WeaponPreference != None)
		&& ClassIsChildOf(W.class, GoalScript.WeaponPreference)
		&& Pawn.ReachedDestination(GoalScript.GetMoveTarget()) )
		return 0.3;
	
	if ( (FavoriteWeapon != None) && (ClassIsChildOf(W.class, FavoriteWeapon)) )
	{
		if ( W == Pawn.Weapon )
			return 0.3;
		return 0.15;
	}

	if ( W == Pawn.Weapon )
	{
		if ( (Pawn.Weapon.AIRating < 0.5) || (Enemy == None) )
			return 0.1;
		else if ( skill < 5 )
			return 0.6 - 0.1 * skill;
		else
			return 0.1;
	}
	return 0;
}

function bool ProficientWithWeapon()
{
	local float proficiency;

	proficiency = skill;
	if ( (FavoriteWeapon != None) && ClassIsChildOf(Pawn.Weapon.class, FavoriteWeapon) )
		proficiency += 2;

	return ( proficiency > 2 + FRand() * 4 );
}

function bool CanComboMoving()
{
	if ( (Skill > 5) && ClassIsChildOf(Pawn.Weapon.class, FavoriteWeapon) )
		return true;
	if ( Skill >= 7 )
		return (FRand() < 0.8);
	return ( Skill - 3 > 6 * FRand() );
}

function bool CanCombo()
{
	if ( Stopped() )
		return true;

	if ( Pawn.Physics == PHYS_Falling )
		return false;

	if ( (Pawn.Acceleration == vect(0,0,0)) || (MoveTarget == Enemy) )
		return true;

	return CanComboMoving();
}

//===========================================================================

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local weapon best[5], moving, temp;
	local bool bFound;
	local int i;
	local inventory inv;
	local string S;

	Super.DisplayDebug(Canvas,YL, YPos);

	Canvas.SetDrawColor(255,255,255);	
	Squad.DisplayDebug(Canvas,YL,YPos);
	if ( GoalScript != None )
		Canvas.DrawText("     "$GoalString$" goalscript "$GetItemName(string(GoalScript))$" Sniping "$IsSniping()$" ReTaskTime "$ReTaskTime, false);
	else
		Canvas.DrawText("     "$GoalString$" ReTaskTime "$ReTaskTime, false);

	YPos += 2*YL;
	Canvas.SetPos(4,YPos);

	if ( Enemy != None )
	{
		Canvas.DrawText("Enemy Dist "$VSize(Enemy.Location - Pawn.Location)$" Strength "$RelativeStrength(Enemy)$" Acquired "$bEnemyAcquired);
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}

	for ( inv=Pawn.Inventory; inv!=None; inv=inv.Inventory )
	{
		if ( Weapon(Inv) != None )
		{
			bFound = false;
			for ( i=0; i<5; i++ )
				if ( Best[i] == None )
				{
					bFound = true;
					Best[i] = Weapon(Inv);
					break;
				}
			if ( !bFound )
			{
				Moving = Weapon(Inv);
				for ( i=0; i<5; i++ )
					if ( Best[i].CurrentRating < Moving.CurrentRating )
					{
						Temp = Moving;
						Moving = Best[i];
						Best[i] = Temp;
					}
			}
		}
	}

	Canvas.DrawText("Weapons Fire last attempt at "$LastFireAttempt$" success "$bFireSuccess, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	for ( i=0; i<5; i++ )
		if ( Best[i] != None )
			S = S@GetItemName(string(Best[i]))@Best[i].CurrentRating;

	Canvas.DrawText("Weapons: "$S, false);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("PERSONALITY: Alertness "$BaseAlertness$" Accuracy "$Accuracy$" Favorite Weap "$FavoriteWeapon);
	YPos += YL;
	Canvas.SetPos(4,YPos);
	Canvas.DrawText("    Aggressiveness "$BaseAggressiveness$" CombatStyle "$CombatStyle$" Strafing "$StrafingAbility$" Tactics "$Tactics$" TranslocUse "$TranslocUse);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

function name GetOrders()
{
	if ( HoldSpot(GoalScript) != None )
		return 'Hold';
	if ( PlayerController(Squad.SquadLeader) != None )
		return 'Follow';
	return Squad.GetOrders();
}

function actor GetOrderObject()
{
	if ( PlayerController(Squad.SquadLeader) != None )
		return Squad.SquadLeader;
	return Squad.SquadObjective;
}
	
/* YellAt()
Tell idiot to stop shooting me
*/
function YellAt(Pawn Moron)
{
	local float Threshold;

	if ( Enemy == None )
		Threshold = 0.3;
	else
		Threshold = 0.7;
	if ( FRand() < Threshold )
		return;

	SendMessage(None, 'FRIENDLYFIRE', 0, 5, 'TEAM');
}	

function byte GetMessageIndex(name PhraseName)
{
	if ( PlayerReplicationInfo.VoiceType == None )
		return 0;
	return PlayerReplicationInfo.Voicetype.Static.GetMessageIndex(PhraseName);
}

function SendMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait, name BroadcastType)
{
	// limit frequency of same message
	if ( (MessageType == OldMessageType) && (MessageID == OldMessageID)
		&& (Level.TimeSeconds - OldMessageTime < Wait) )
		return;

	if ( Level.Game.bGameEnded || Level.Game.bWaitingToStartMatch )
		return;

	OldMessageID = MessageID;
	OldMessageType = MessageType;

	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, BroadcastType);
}

/* SetOrders()
Called when player gives orders to bot
*/
function SetOrders(name NewOrders, Controller OrderGiver)
{
	if ( PlayerReplicationInfo.Team != OrderGiver.PlayerReplicationInfo.Team )
		return;

	Aggressiveness = BaseAggressiveness;
	if ( (NewOrders == 'Hold') || (NewOrders == 'Follow') )
		Aggressiveness += 1;

	SendMessage(OrderGiver.PlayerReplicationInfo, 'ACK', 0, 5, 'TEAM');
	UnrealTeamInfo(PlayerReplicationInfo.Team).AI.SetOrders(self,NewOrders,OrderGiver);
	WhatToDoNext(1);
}


function bool SetEnemy(Pawn P)
{
	//Squad.SetEnemy(self,P);
	if (P == None)
		Enemy = None;
	else if (AttitudeTo(P) < ATTITUDE_Ignore)
	{
		Squad.SetEnemy(self,P);
		//Enemy = P;	// Note: The squad actually sets the enemy.
		return true;
	}
	
	return false;
}

function HearNoise(float Loudness, Actor NoiseMaker)
{
	if (Enemy == None)
	{
		if ( (AttitudeTo(Pawn(NoiseMaker)) < ATTITUDE_Ignore) &&
			((ChooseAttackCounter < 2) || (ChooseAttackTime != Level.TimeSeconds)) &&
			SetEnemy(NoiseMaker.instigator) )

		WhatToDoNext(2);
	}
}

event SeePlayer(Pawn SeenPlayer)
{
	if (Enemy == None)
	{
		if ( (AttitudeTo(SeenPlayer) < ATTITUDE_Ignore) &&
			((ChooseAttackCounter < 2) || (ChooseAttackTime != Level.TimeSeconds)) &&
			SetEnemy(SeenPlayer) )
			WhatToDoNext(3);
		if ( Enemy == SeenPlayer )
		{	
			VisibleEnemy = Enemy;
			EnemyVisibilityTime = Level.TimeSeconds;
			bEnemyIsVisible = true;
		}
	}
}

function SetAttractionState()
{
	if ( Enemy != None )
	{
		Focus = Enemy;
		GotoState('FallBack');
	}
	else
	{
		Focus = None;
		GotoState('Roaming');
	}
}


function eAttitude AttitudeToQuick(Pawn Other)
{
 	return AttitudeTo(Other);
}
 
function eAttitude AttitudeTo(Pawn Other)
{
 	if ( Squad.FriendlyToward(Other) )
 		return ATTITUDE_Friendly;
 	if ( bFrustrated )
 		return ATTITUDE_Hate;
 	if ( RelativeStrength(Other) > Aggressiveness + 0.44 - skill * 0.06 )
 		return ATTITUDE_Fear;
 	return ATTITUDE_Hate;
 }
 
 
 function bool IsEnemy(Pawn Other)
 {
 	return AttitudeTo(Other) < ATTITUDE_Ignore;
 }


function bool ClearShot(Vector TargetLoc, bool bImmediateFire)
{
	local bool bSeeTarget;

	if ( VSize(Enemy.Location - TargetLoc) > MAXSTAKEOUTDIST )
		return false;		
	
	bSeeTarget = FastTrace(TargetLoc, Pawn.Location + Pawn.EyeHeight * vect(0,0,1));
	// if pawn is crouched, check if standing would provide clear shot
	if ( !bImmediateFire && !bSeeTarget && Pawn.bIsCrouched )
		bSeeTarget = FastTrace(TargetLoc, Pawn.Location + (Pawn.Default.EyeHeight + Pawn.Default.CollisionHeight - Pawn.CollisionHeight) * vect(0,0,1));

	if ( !bSeeTarget || !FastTrace(TargetLoc , Enemy.Location + Enemy.BaseEyeHeight * vect(0,0,1)) );
		return false;
	if ( (Pawn.Weapon.SplashDamage() && (VSize(Pawn.Location - TargetLoc) < Pawn.Weapon.GetDamageRadius()))
		|| !FastTrace(TargetLoc + vect(0,0,0.9) * Enemy.CollisionHeight, Pawn.Location) )
	{
		StopFiring();
		return false;
	}
	return true;
}

function bool CanStakeOut()
{
	local float relstr;

	relstr = RelativeStrength(Enemy);

	if ( bFrustrated || !bEnemyInfoValid
		 || (VSize(Enemy.Location - Pawn.Location) > 0.5 * (MAXSTAKEOUTDIST + (FRand() * relstr - CombatStyle) * MAXSTAKEOUTDIST))
		 || (Level.TimeSeconds - FMax(LastSeenTime,AcquireTime) > 2.5 + FMax(-1, 3 * (FRand() + 2 * (relstr - CombatStyle))) ) 
		 || !ClearShot(LastSeenPos,false) )
		return false;
	return true;
}

/* CheckIfShouldCrouch()
returns true if target position still can be shot from crouched position,
or if couldn't hit it from standing position either
*/
function CheckIfShouldCrouch(vector StartPosition, vector TargetPosition, float probability)
{
	local actor HitActor;
	local vector HitNormal,HitLocation, X,Y,Z, projstart;
	
	if ( (Pawn == None) || (Pawn.Weapon == None) )
		return;

	if ( !Pawn.bCanCrouch || (!Pawn.bIsCrouched && (FRand() > probability))
		|| (Skill < 3 * FRand()) 
		|| Pawn.Weapon.RecommendSplashDamage() )
	{
		Pawn.bWantsToCrouch = false;
		return;
	}

	GetAxes(Rotation,X,Y,Z);
	projStart = Pawn.Weapon.GetFireStart(X,Y,Z);
	projStart = projStart + StartPosition - Pawn.Location;
	projStart.Z = projStart.Z - 1.8 * (Pawn.CollisionHeight - Pawn.CrouchHeight); 
	HitActor = 	Trace(HitLocation, HitNormal, TargetPosition , projStart, false);
	if ( HitActor == None )
	{
		Pawn.bWantsToCrouch = true;
		return;
	}

	projStart.Z = projStart.Z + 1.8 * (Pawn.Default.CollisionHeight - Pawn.CrouchHeight);
	HitActor = 	Trace(HitLocation, HitNormal, TargetPosition , projStart, false);
	if ( HitActor == None )
	{
		Pawn.bWantsToCrouch = false;
		return;
	}
	Pawn.bWantsToCrouch = true;
}

function bool IsSniping()
{
	return ( (GoalScript != None) && GoalScript.bSniping && Pawn.Weapon.bSniping 
			&& Pawn.ReachedDestination(GoalScript.GetMovetarget()) );
}

function FreeScript()
{
	if ( GoalScript != None )
	{
		GoalScript.FreeScript();
		GoalScript = None;
	}
}

function bool AssignSquadResponsibility()
{
	if ( LastAttractCheck == Level.TimeSeconds )
		return false;
	LastAttractCheck = Level.TimeSeconds;

	return Squad.AssignSquadResponsibility(self);
}

/* RelativeStrength()
returns a value indicating the relative strength of other
> 0 means other is stronger than controlled pawn

Since the result will be compared to the creature's aggressiveness, it should be
on the same order of magnitude (-1 to 1)
*/

function float RelativeStrength(Pawn Other)
{
	local float compare;
	local int adjustedOther;

	if ( Pawn == None )
	{
		warn("Relative strength with no pawn in state "$GetStateName());
		return 0;
	}
// Its pretty strong compared to the other pawn as the other pawn is DEAD.
	if (Other.Health <= 0)
		return -1;

	adjustedOther = 0.5 * (Other.health + Other.Default.Health);	
	compare = 0.01 * float(adjustedOther - Pawn.health);
	compare = compare - Pawn.AdjustedStrength() + Other.AdjustedStrength();
	
	if ( Pawn.Weapon != None )
	{
		compare -= 0.5 * Pawn.DamageScaling * Pawn.Weapon.CurrentRating;
		if ( Pawn.Weapon.AIRating < 0.5 )
		{
			compare += 0.3;
			if ( (Other.Weapon != None) && (Other.Weapon.AIRating > 0.5) )
				compare += 0.3;
		}
	}
	if ( Other.Weapon != None )
		compare += 0.5 * Other.DamageScaling * Other.Weapon.AIRating;

	if ( Other.Location.Z > Pawn.Location.Z + TACTICALHEIGHTADVANTAGE )
		compare += 0.2;
	else if ( Pawn.Location.Z > Other.Location.Z + TACTICALHEIGHTADVANTAGE )
		compare -= 0.15;
	return compare;
}

function Trigger( actor Other, pawn EventInstigator )
{
	if ( Super.TriggerScript(Other,EventInstigator) )
		return;
	if ( (Other == Pawn) || (Pawn.Health <= 0) )
		return;
	 if (AttitudeTo(EventInstigator) < ATTITUDE_Ignore)
		Squad.SetEnemy(self,EventInstigator);
}

function SetEnemyInfo(bool bNewEnemyVisible)
{
	bEnemyEngaged = true;
	AcquireTime = Level.TimeSeconds;
	if ( bNewEnemyVisible )
	{
		LastSeenTime = Level.TimeSeconds;
		LastSeenPos = Enemy.Location;
		LastSeeingPos = Pawn.Location;
		bEnemyInfoValid = true;
	}
	else
	{
		LastSeenTime = -1000;
		bEnemyInfoValid = false;
	}
}

// EnemyChanged() called by squad when current enemy changes
function EnemyChanged(bool bNewEnemyVisible)
{
	bEnemyAcquired = false;
	SetEnemyInfo(bNewEnemyVisible);
	//log(GetHumanReadableName()$" chooseattackmode from enemychanged at "$Level.TimeSeconds);
}

function BotVoiceMessage(name messagetype, byte MessageID, Controller Sender)
{
    if ( !Level.Game.bTeamGame || (Sender.PlayerReplicationInfo.Team != PlayerReplicationInfo.Team) )
		return;
	if ( messagetype == 'ORDER' )
		SetOrders(OrderNames[messageID], Sender);
}

function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest);

//**********************************************************************

function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
{
	local vector jumpDir;

	if ( newVolume.bWaterVolume )
	{
		if (!Pawn.bCanSwim)
			MoveTimer = -1.0;
		else if (Pawn.Physics != PHYS_Swimming)
			Pawn.setPhysics(PHYS_Swimming);
	}
	else if (Pawn.Physics == PHYS_Swimming)
	{
		if ( Pawn.bCanFly )
			 Pawn.SetPhysics(PHYS_Flying); 
		else
		{ 
			Pawn.SetPhysics(PHYS_Falling);
			if ( Pawn.bCanWalk && (Abs(Pawn.Acceleration.X) + Abs(Pawn.Acceleration.Y) > 0)
				&& (Destination.Z >= Pawn.Location.Z) 
				&& Pawn.CheckWaterJump(jumpDir) )
				Pawn.JumpOutOfWater(jumpDir);
		}
	}
	return false;
}

event NotifyMissedJump()
{
	local NavigationPoint N;
	local actor OldMoveTarget;
	local vector Loc2D, NavLoc2D;
	local float BestDist, NewDist;
	
	OldMoveTarget = MoveTarget;
	if ( !bHasTranslocator )
		MoveTarget = None;
	
	if ( MoveTarget == None )
	{
		// find an acceptable path
		if ( bHasTranslocator && (skill >= 2) )
		{
			for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
			{
				if ( (VSize(N.Location - Pawn.Location) < 1500)
					&& LineOfSightTo(N) )
				{
					MoveTarget = N;
					break;
				}
			}		
		}
		else
		{
			Loc2D = Pawn.Location;
			Loc2D.Z = 0;
			for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
			{
				if ( N.Location.Z < Pawn.Location.Z )
				{
					NavLoc2D = N.Location;
					NavLoc2D.Z = 0;
					NewDist = VSize(NavLoc2D - Loc2D);
					if ( (MoveTarget == None) || (BestDist > NewDist) )
					{
						MoveTarget = N;
						BestDist = NewDist;
					}
				}
			}
		}
		if ( MoveTarget == None )
		{
			MoveTarget = OldMoveTarget;
			return;		
		}
	}
	
	// pass the ball first
	if ( Pawn.Weapon.IsA('BallLauncher') )
	{
		if ( PlayerReplicationInfo.HasFlag != None )
		{
			Pawn.Weapon.SetAITarget(MoveTarget);
			bPlannedShot = true;
			Target = MoveTarget;
			Pawn.Weapon.BotFire(false);
		}
	}
	else if ( bHasTranslocator && (skill >= 2) )
	{
		if ( !bPreparingMove || (TranslocationTarget != MoveTarget) )
		{
			bPreparingMove = true;
			TranslocationTarget = MoveTarget;
			RealTranslocationTarget = MoveTarget;
			ImpactTarget = MoveTarget;
			Focus = MoveTarget;
			if ( Pawn.Weapon.IsA('TransLauncher') )
			{
				Pawn.PendingWeapon = None;
				Pawn.Weapon.SetTimer(0.2,false);
			}
			else
				SwitchToBestWeapon();
		}
	}
	MoveTimer = 1.0;
}

function Possess(Pawn aPawn)
{
	if ( UnrealPawn(aPawn) != None )
	{
		if ( UnrealPawn(aPawn).Default.VoiceType != "" )
			VoiceType = UnrealPawn(aPawn).Default.VoiceType;
		if ( VoiceType != "" )
			PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject(VoiceType,class'Class'));
	}
	Super.Possess(aPawn);
	ResetSkill();
	Pawn.MaxFallSpeed = 1.1 * Pawn.default.MaxFallSpeed; // so bots will accept a little falling damage for shorter routes
	Pawn.SetMovementPhysics(); 
	if (Pawn.Physics == PHYS_Walking)
		Pawn.SetPhysics(PHYS_Falling);
	enable('NotifyBump');
}

function InitializeSkill(float InSkill)
{
	Skill = FClamp(InSkill, 0, 7);
	ReSetSkill();
}

function ResetSkill()
{
	local float AdjustedYaw;
	Aggressiveness = BaseAggressiveness;
	if ( Pawn != None )
		Pawn.bCanDoubleJump = ( Skill >= 3 ); 
	bLeadTarget = ( Skill >= 4 );
	SetCombatTimer();
	SetPeripheralVision();
	if ( Skill + ReactionTime > 7 )
		RotationRate.Yaw = 90000;
	else if ( Skill + ReactionTime >= 4 )
		RotationRate.Yaw = 7000 + 10000 * (skill + ReactionTime);
	else
		RotationRate.Yaw = 30000 + 4000 * (skill + ReactionTime);
    AdjustedYaw = (0.75 + 0.05 * ReactionTime) * RotationRate.Yaw;
	AcquisitionYawRate = AdjustedYaw;
	SetMaxDesiredSpeed();
}

function SetMaxDesiredSpeed()
{
	if ( Pawn != None )
	{
		if ( Skill > 3 )
			Pawn.MaxDesiredSpeed = 1;
		else
			Pawn.MaxDesiredSpeed = 0.6 + 0.1 * Skill;
	}
}

function SetPeripheralVision()
{
	if ( Pawn == None )
		return;
	if ( Skill < 2 )
		Pawn.PeripheralVision = 0.7;
	else if ( Skill > 6 )
		Pawn.PeripheralVision = -0.2;
	else
		Pawn.PeripheralVision = 1.0 - 0.2 * skill;

	Pawn.PeripheralVision = FMin(Pawn.PeripheralVision - BaseAlertness, 0.8);
	Pawn.SightRadius = Pawn.Default.SightRadius;
}

/*
SetAlertness()
Change creature's alertness, and appropriately modify attributes used by engine for determining
seeing and hearing.
SeePlayer() is affected by PeripheralVision, and also by SightRadius and the target's visibility
HearNoise() is affected by HearingThreshold
*/
function SetAlertness(float NewAlertness)
{
	if ( Pawn.Alertness != NewAlertness )
	{
		Pawn.PeripheralVision += 0.707 * (Pawn.Alertness - NewAlertness); //Used by engine for SeePlayer()
		Pawn.Alertness = NewAlertness;
	}
}

function WasKilledBy(Controller Other)
{
	local Controller C;

	if ( Pawn.bUpdateEyeHeight )
	{
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
			if ( C.IsA('PlayerController') && (PlayerController(C).ViewTarget == Pawn) && (PlayerController(C).RealViewTarget == None) )
				PlayerController(C).ViewNextBot();
	}
	if ( (Other != None) && (Other.Pawn != None) )
		LastKillerPosition = Other.Pawn.Location;
}

//=============================================================================
function WhatToDoNext(byte CallingByte)
{
	if ( ChoosingAttackLevel > 0 )
		log("CHOOSEATTACKAGAIN in state "$GetStateName()$" enemy "$GetEnemyName()$" old enemy "$GetOldEnemyName()$" CALLING BYTE "$CallingByte);

	if ( ChooseAttackTime == Level.TimeSeconds )
	{		
		ChooseAttackCounter++;
		if ( ChooseAttackCounter > 3 )
			log("CHOOSEATTACKSERIAL in state "$GetStateName()$" enemy "$GetEnemyName()$" old enemy "$GetOldEnemyName()$" CALLING BYTE "$CallingByte);
	}
	else
	{
		ChooseAttackTime = Level.TimeSeconds;
		ChooseAttackCounter = 0;
	}	
	OldEnemy = Enemy;
	ChoosingAttackLevel++;
	ExecuteWhatToDoNext();
	ChoosingAttackLevel--;
	RetaskTime = 0;
}

function string GetOldEnemyName()
{
	if ( OldEnemy == None )
		return "NONE";
	else
		return OldEnemy.GetHumanReadableName();
}

function string GetEnemyName()
{
	if ( Enemy == None )
		return "NONE";
	else
		return Enemy.GetHumanReadableName();
}

function ExecuteWhatToDoNext()
{
	bHasFired = false;
	GoalString = "WhatToDoNext at "$Level.TimeSeconds;
	if ( Pawn == None )
	{
		warn(GetHumanReadableName()$" WhatToDoNext with no pawn");
		return;
	}
//	else if ( Pawn.Weapon == None )
//		warn(GetHumanReadableName()$" WhatToDoNext with no weapon, "$Pawn$" health "$Pawn.health);
	if ( Enemy == None )
	{
		if ( Level.Game.TooManyBots(self) )
		{
			if ( Pawn != None )
			{
				Pawn.Health = 0;
				Pawn.Died( self, class'Suicided', Pawn.Location );
			}
			Destroy();
			return;
		}
		BlockedPath = None;
		bFrustrated = false;
		StopFiring();
	}

	if (Pawn != None)
	{
		//Pawn.bIsWalkingLocked = false;
		Pawn.SetWalking(ShouldWalk());
		//Pawn.bIsWalkingLocked = true;
	}

	if ( ScriptingOverridesAI() && ShouldPerformScript() )
		return;
	if (Pawn.Physics == PHYS_None)
		Pawn.SetMovementPhysics(); 
	if ( (Pawn.Physics == PHYS_Falling) && DoWaitForLanding() )
		return;
	if ( (StartleActor != None) && !StartleActor.bDeleteMe && (VSize(StartleActor.Location - Pawn.Location) < StartleActor.CollisionRadius)  )
	{
		Startle(StartleActor);
		return;
	}
	if ( (Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None)) )
		LoseEnemy();
	if ( Enemy == None )
		Squad.FindNewEnemyFor(self,false);
	else if ( !Squad.MustKeepEnemy(Enemy) && !EnemyVisible() )
	{
		// decide if should lose enemy
		if ( Squad.IsDefending(self) )
		{
			if ( LostContact(4) )
				LoseEnemy();
		}
		else if ( LostContact(7) )
			LoseEnemy();
	}		
			
	if ( AssignSquadResponsibility() )
	{
		SwitchToBestWeapon();
		return;
	}
	if ( ShouldPerformScript() )
		return;
	if ( Enemy != None )
		ChooseAttackMode();
	else
	{
		GoalString = "WhatToDoNext Wander or Camp at "$Level.TimeSeconds;
		WanderOrCamp(true);
	}
	SwitchToBestWeapon();
}

function bool DoWaitForLanding()
{
	GotoState('WaitingForLanding');
	return true;
}

function bool EnemyVisible()
{
	if ( (EnemyVisibilityTime == Level.TimeSeconds) && (VisibleEnemy == Enemy) )
		return bEnemyIsVisible;
	VisibleEnemy = Enemy;
	EnemyVisibilityTime = Level.TimeSeconds;
	bEnemyIsVisible = LineOfSightTo(Enemy);
	return bEnemyIsVisible;
}

function FightEnemy(bool bCanCharge, float EnemyStrength)
{
	local vector X,Y,Z;
	local float enemyDist;
	local float AdjustedCombatStyle;
	local bool bFarAway, bOldForcedCharge;
	local bool snipe;
	
//	if ( (Squad == None) || (Enemy == None) || (Pawn == None) || (Pawn.Weapon == None) )
//		log("HERE 3 Squad "$Squad$" Enemy "$Enemy$" pawn "$Pawn$" weapon "$Pawn.Weapon);


	if ( (Enemy == FailedHuntEnemy) && (Level.TimeSeconds == FailedHuntTime) )
	{
		GoalString = "FAILED HUNT - HANG OUT";
		if ( EnemyVisible() )
			bCanCharge = false;
		else if ( FindInventoryGoal(0) )
		{
			SetAttractionState();
			return;
		}
		else
		{
			WanderOrCamp(true);
			return;
		}
	}

	if (Pawn.Weapon == None)
	{
		GoalString = "Charge";
		DoCharge();
		return;
	}

	bOldForcedCharge = bMustCharge;
	bMustCharge = false;
	enemyDist = VSize(Pawn.Location - Enemy.Location);
	AdjustedCombatStyle = CombatStyle + Pawn.Weapon.SuggestAttackStyle();
	Aggression = 1.5 * FRand() - 0.8 + 2 * AdjustedCombatStyle - 0.5 * EnemyStrength 
				+ FRand() * (Normal(Enemy.Velocity - Pawn.Velocity) Dot Normal(Enemy.Location - Pawn.Location));
	if ( Enemy.Weapon != None )
		Aggression += 2 * Enemy.Weapon.SuggestDefenseStyle();
	if ( enemyDist > MAXSTAKEOUTDIST )
		Aggression += 0.5;
	if ( (Pawn.Physics == PHYS_Walking) || (Pawn.Physics == PHYS_Falling) )
	{
		if (Pawn.Location.Z > Enemy.Location.Z + TACTICALHEIGHTADVANTAGE) 
			Aggression = FMax(0.0, Aggression - 1.0 + AdjustedCombatStyle);
		else if ( (Skill < 4) && (enemyDist > 0.65 * MAXSTAKEOUTDIST) )
		{
			bFarAway = true;
			Aggression += 0.5;
		}
		else if (Pawn.Location.Z < Enemy.Location.Z - Pawn.CollisionHeight) // below enemy
			Aggression += CombatStyle;
	}

	if ( !EnemyVisible() )
	{
		if ( Squad.MustKeepEnemy(Enemy) )
		{
			GoalString = "Hunt priority enemy";
			GotoState('Hunting');
			return;
		}
		GoalString = "Enemy not visible";
		if ( !bCanCharge || (Squad.IsDefending(self) && LostContact(4)) )
		{
			GoalString = "Stake Out";
			DoStakeOut(); 
		}
		else if ( ((Aggression < 1) && !LostContact(3+2*FRand()) || IsSniping()) && CanStakeOut() )
		{
			GoalString = "Stake Out2";
			DoStakeOut();
		}
		else if (IsHunting())
		{
			FindRoamDest();
		}
		else
		{
			GoalString = "Hunt";
			focus = None;
			GotoState('Hunting');
		}
		return;
	}
		
	// see enemy - decide whether to charge it or strafe around/stand and fire
	BlockedPath = None;
	Target = Enemy;
	if( Pawn.Weapon.bMeleeWeapon || (bCanCharge && bOldForcedCharge) )
	{
		GoalString = "Charge";
		DoCharge();
		return;
	}
	if ( bCanCharge && (Skill < 5) && bFarAway && (Aggression > 1) && (FRand() < 0.5) )
	{
		GoalString = "Charge closer";
		DoCharge();
		return;
	}

	// If we're out of range, move towards the enemy.  This is different than charging as it will advance
	// only one pathnode at a time towards the enemy until it is in range again.
	if (enemyDist > Pawn.Weapon.MaxRange)
	{
		Focus = Enemy;
		GotoState('MoveTowardsEnemy');
		return;
	}

	// We'll be cock suckers and stand and shoot when we're out of the enemy's range.	
	snipe = (Enemy.Weapon != None) && (enemyDist > Enemy.Weapon.MaxRange);

	if (	snipe || 
			( !bJustDidRangedAttack && 
			(Pawn.Weapon.RecommendRangedAttack() || IsSniping() || ((FRand() > 0.17 * (skill + Tactics - 1))) &&
			!DefendMelee(enemyDist)) )	)
	{
		GoalString = "Ranged Attack";
		bJustDidRangedAttack = true;
		Focus = Enemy;
		DoRangedAttackOn(Enemy);
		return;
	}

	bJustDidRangedAttack = false;
	if ( bCanCharge )
	{
		if ( (Aggression > 1) && (FRand() < 0.5) )
		{
			GoalString = "Charge 2";
			DoCharge();
			return;
		}
	}
	GoalString = "Do tactical move";
	if ( !Pawn.Weapon.RecommendSplashDamage() && (FRand() < 0.7) && (bJumpy || (FRand()*Skill > 3)) )
	{
		GetAxes(Rotation,X,Y,Z);
		GoalString = "Try to Duck ";
		if ( FRand() < 0.5 )
		{
			Y *= -1;
			TryToDuck(Y, true);
		}
		else 
			TryToDuck(Y, false);
	}
	DoTacticalMove();
}

function DoRangedAttackOn(Actor A)
{
	Target = A;
	GotoState('RangedAttack');
}

/* ChooseAttackMode()
Handles tactical attacking state selection - choose which type of attack to do from here
*/
function ChooseAttackMode()
{
	local float EnemyStrength, WeaponRating, RetreatThreshold;

	Focus = Enemy;
	GoalString = " ChooseAttackMode last seen "$(Level.TimeSeconds - LastSeenTime);	
	// should I run away?
	//if ( (Squad == None) || (Enemy == None) || (Pawn == None) || (Pawn.Weapon == None) )
	//	log("HERE 1 Squad "$Squad$" Enemy "$Enemy$" pawn "$Pawn$" weapon "$Pawn.Weapon);
	EnemyStrength = RelativeStrength(Enemy);
	if ( !bFrustrated && !Squad.MustKeepEnemy(Enemy) )
	{ 
		RetreatThreshold = Aggressiveness;
		if ( (Pawn.Weapon != None) && (Pawn.Weapon.CurrentRating > 0.5) )
			RetreatThreshold = RetreatThreshold + 0.35 - skill * 0.05;
		if ( EnemyStrength > RetreatThreshold )
		{
			GoalString = "Retreat";
			if ( (PlayerReplicationInfo.Team != None) && (FRand() < 0.05) )
				SendMessage(None, 'Other', GetMessageIndex('INJURED'), 15, 'TEAM');
			DoRetreat();
			return;
		}
	}
	if ( (Pawn.Weapon != None) && ((Squad.PriorityObjective(self) == 0) && (Skill + Tactics > 2) && ((EnemyStrength > -0.3) || (Pawn.Weapon.AIRating < 0.5))) )
	{
		if ( Pawn.Weapon.AIRating < 0.5 )
		{
			if ( EnemyStrength > 0.3 )
				WeaponRating = 0;
			else
				WeaponRating = Pawn.Weapon.CurrentRating/2000;
		}
		else if ( EnemyStrength > 0.3 )
			WeaponRating = Pawn.Weapon.CurrentRating/2000;
		else
			WeaponRating = Pawn.Weapon.CurrentRating/1000;

		// fallback to better pickup?
		if ( FindInventoryGoal(WeaponRating) )
		{
			if ( InventorySpot(RouteGoal) == None )
				GoalString = "fallback - inventory goal is not pickup but "$RouteGoal;
			else 
				GoalString = "Fallback to better pickup "$InventorySpot(RouteGoal).markedItem$" hidden "$InventorySpot(RouteGoal).markedItem.bHidden;
			GotoState('FallBack');
			return;
		}
	}
	GoalString = "ChooseAttackMode FightEnemy";	
	FightEnemy(true, EnemyStrength);
}

function bool FindInventoryGoal(float BestWeight)
{
	local actor BestPath;

	if (!Pawn.bCanPickupInventory)
		return false;

	if ( (LastSearchTime == Level.TimeSeconds) && (LastSearchWeight >= BestWeight) )
		return false;

	LastSearchTime = Level.TimeSeconds;
	LastSearchWeight = BestWeight;

	 // look for inventory 
	if ( (Skill > 3) && (Enemy == None) )
		RespawnPredictionTime = 4;
	else
		RespawnPredictionTime = 0;
	BestPath = FindBestInventoryPath(BestWeight);
	if ( BestPath != None )
	{
		MoveTarget = BestPath;
		return true;
	}
	return false;
}

function bool PickRetreatDestination()
{
	local actor BestPath;

	if ( FindInventoryGoal(0) )
		return true;

	if ( (RouteGoal == None) || (Pawn.Anchor == RouteGoal)
		|| Pawn.ReachedDestination(RouteGoal) )
	{
		RouteGoal = FindRandomDest();
		BestPath = RouteCache[0];
		if ( RouteGoal == None )
			return false;
	}
	
	if ( BestPath == None )
		BestPath = FindPathToActor(RouteGoal,true);

	if ( BestPath != None )
	{
		MoveTarget = BestPath;
		return true;
	}
	RouteGoal = None;
	return false;
}

event SoakStop(string problem)
{
	local UnrealPlayer PC;

	log(problem);
	SoakString = problem;
	GoalString = SoakString@GoalString;
	ForEach DynamicActors(class'UnrealPlayer',PC)
	{
		PC.SoakPause(Pawn);
		break;
	}
}

function bool FindRoamDest()
{
	local actor BestPath;

	if ( Pawn.FindAnchorFailedTime == Level.TimeSeconds )
	{
		// couldn't find an anchor.  
		GoalString = "No anchor "$Level.TimeSeconds;
		if ( Pawn.LastValidAnchorTime > 5 )
		{
			if ( bSoaking )
				SoakStop("NO PATH AVAILABLE!!!");
			else
			{
				if ( NumRandomJumps > 4 )
				{
					Pawn.Health = 0;
					Pawn.Died( self, class'Suicided', Pawn.Location );
					return true;
				}
				else
				{
					// jump
					NumRandomJumps++;
					if ( Physics != PHYS_Falling )
					{
						Pawn.SetPhysics(PHYS_Falling);
						Pawn.Velocity = 0.5 * Pawn.GroundSpeed * VRand();
						Pawn.Velocity.Z = Pawn.JumpZ;
					}
				}
			}			
		}
		//log(self$" Find Anchor failed!");
		return false;
	}
	NumRandomJumps = 0;
	GoalString = "Find roam dest "$Level.TimeSeconds;
	// find random NavigationPoint to roam to
	if ( (RouteGoal == None) || (Pawn.Anchor == RouteGoal)
		|| Pawn.ReachedDestination(RouteGoal) )
	{
		// first look for a scripted sequence
		Squad.SetFreelanceScriptFor(self);
		if ( GoalScript != None )
		{
			RouteGoal = GoalScript.GetMoveTarget();
			BestPath = None;
		}				
		else
		{
			RouteGoal = FindRandomDest();
			BestPath = RouteCache[0];
		}
		if ( RouteGoal == None )
		{
			if ( bSoaking && (Physics != PHYS_Falling) )
				SoakStop("COULDN'T FIND ROAM DESTINATION");
			return false;
		}
	}
	if ( BestPath == None )
		BestPath = FindPathToActor(RouteGoal,false);
	if ( BestPath != None )
	{
		MoveTarget = BestPath;
		SetAttractionState();
		return true;
	}
	if ( bSoaking && (Physics != PHYS_Falling) )
		SoakStop("COULDN'T FIND ROAM PATH TO "$RouteGoal);
	RouteGoal = None;
	FreeScript();
	return false;
}

function bool TestDirection(vector dir, out vector pick)
{	
	local vector HitLocation, HitNormal, dist;
	local actor HitActor;

	pick = dir * (MINSTRAFEDIST + 2 * MINSTRAFEDIST * FRand());

	HitActor = Trace(HitLocation, HitNormal, Pawn.Location + pick + 1.5 * Pawn.CollisionRadius * dir , Pawn.Location, false);
	if (HitActor != None)
	{
		pick = HitLocation + (HitNormal - dir) * 2 * Pawn.CollisionRadius;
		if ( !FastTrace(pick, Pawn.Location) )
			return false;
	}
	else
		pick = Pawn.Location + pick;
	 
	dist = pick - Pawn.Location;
	if (Pawn.Physics == PHYS_Walking)
		dist.Z = 0;
	
	return (VSize(dist) > MINSTRAFEDIST); 
}

function Restart()
{
	Super.Restart();
	ReSetSkill();
	Focus = None;
	GotoState('Roaming','DoneRoaming');
}

function bool CheckPathToGoalAround(Pawn P)
{
	return false;
}

function CancelCampFor(Controller C);

function ClearPathFor(Controller C)
{
	if ( AdjustAround(C.Pawn) )
		return;
	if ( Enemy != None )
	{
		if ( EnemyVisible() )
		{
			DoTacticalMove();
			return;
		}
	}
	else if ( Stopped() )
		DirectedWander(Normal(Pawn.Location - C.Pawn.Location));
}

function bool AdjustAround(Pawn Other)
{
	local float speed;
	local vector VelDir, OtherDir, SideDir;

	speed = VSize(Pawn.Acceleration);
	if ( speed < Pawn.WalkingPct * Pawn.GroundSpeed )
		return false;

	VelDir = Pawn.Acceleration/speed;
	VelDir.Z = 0;
	OtherDir = Other.Location - Pawn.Location;
	OtherDir.Z = 0;
	OtherDir = Normal(OtherDir);
	if ( (VelDir Dot OtherDir) > 0.8 )
	{
		bAdjusting = true;
		SideDir.X = VelDir.Y;
		SideDir.Y = -1 * VelDir.X;
		if ( (SideDir Dot OtherDir) > 0 )
			SideDir *= -1;
		AdjustLoc = Pawn.Location + 1.5 * Other.CollisionRadius * (0.5 * VelDir + SideDir);
	}
}

function DirectedWander(vector WanderDir)
{
	GoalString = "DIRECTED WANDER "$GoalString;
	Pawn.bWantsToCrouch = Pawn.bIsCrouched;
	if ( TestDirection(WanderDir,Destination) )
		GotoState('RestFormation', 'Moving');
	else
		GotoState('RestFormation', 'Begin');
}

event bool NotifyBump(actor Other)
{
	local Pawn P;

	Disable('NotifyBump');
	P = Pawn(Other);
	if ( (P == None) || (P.Controller == None) || (Enemy == P) )
		return false;
	if ( SetEnemy(P) )
	{
		WhatToDoNext(4);
		return false;
	}
	
	if ( Enemy == P )
		return false;

	if ( CheckPathToGoalAround(P) )
		return false;

	if ( !AdjustAround(P) )
		CancelCampFor(P.Controller);
	return false;
}
	
function bool PriorityObjective()
{
	return (Squad.PriorityObjective(self) > 0);
}

function SetFall()
{
	if (Pawn.bCanFly)
	{
		Pawn.SetPhysics(PHYS_Flying);
		return;
	}			
	if ( Pawn.bNoJumpAdjust )
	{
		Pawn.bNoJumpAdjust = false;
		return;
	}
	else
	{
		Pawn.Velocity = EAdjustJump(Pawn.Velocity.Z,Pawn.GroundSpeed);
		Pawn.Acceleration = vect(0,0,0);
	}
}

function bool NotifyLanded(vector HitNormal)
{
	local vector Vel2D;

	if ( MoveTarget != None )
	{
		Vel2D = Pawn.Velocity;
		Vel2D.Z = 0;
		if ( (Vel2D Dot (MoveTarget.Location - Pawn.Location)) < 0 )
		{
			Pawn.Acceleration = vect(0,0,0);
			if ( NavigationPoint(MoveTarget) != None )
				Pawn.Anchor = NavigationPoint(MoveTarget);
			MoveTimer = -1;
		}
	}
	return false;
}

function bool StartMoveToward(Actor O)
{
	if ( MoveTarget == None )
	{
		if ( (O == Enemy) && (O != None) )
		{
			FailedHuntTime = Level.TimeSeconds;
			FailedHuntEnemy = Enemy;
		}
		if ( bSoaking && (Pawn.Physics != PHYS_Falling) )
			SoakStop("COULDN'T FIND ROUTE TO "$O.GetHumanReadableName());
		GoalString = "No path to "$O.GetHumanReadableName();
	}
	else
		SetAttractionState();
	return ( MoveTarget != None );	
}

function bool SetRouteToGoal(Actor A)
{
	FindBestPathToward(A,false,true);
	return StartMoveToward(A);
}

event bool AllowDetourTo(NavigationPoint N)
{
	return Squad.AllowDetourTo(self,N);
}



// Overcomes some problems with FindPathToward.
function Actor FindPathToActor
(
	actor anActor,
	optional bool bClearPaths
)
{
	local Actor nextPath;
	
	if (ActorReachable(anActor))
		return anActor;
	
	nextPath = FindPathToward(anActor, bClearPaths);
	//log( "MikeT: Bestpath Pass 1 is: " $ nextPath );
	
	if (nextPath == None)
	{
		nextPath = FindPathTo(anActor.Location, bClearPaths);
		//log( "MikeT: Bestpath Pass 2 is: " $ nextPath );
	}

	return nextPath;
}


/* FindBestPathToward() 
Assumes the desired destination is not directly reachable. 
It tries to set Destination to the location of the best waypoint, and returns true if successful
*/
function bool FindBestPathToward(Actor A, bool bCheckedReach, bool bAllowDetour)
{
	if ( !bCheckedReach && ActorReachable(A) )
		MoveTarget = A;
	else
		MoveTarget = FindPathToActor(A,(bAllowDetour && (NavigationPoint(A) != None)));
	
	if ( MoveTarget != None )
		return true;
	else 
	{
		if ( (A == Enemy) && (A != None) )
		{
			FailedHuntTime = Level.TimeSeconds;
			FailedHuntEnemy = Enemy;
		}
		if ( bSoaking && (Physics != PHYS_Falling) )
		SoakStop("COULDN'T FIND BEST PATH TO "$A);
	}
	return false;
}	

function bool NeedToTurn(vector targ)
{
	local vector LookDir,AimDir;
	LookDir = Vector(Pawn.Rotation);
	LookDir.Z = 0;
	LookDir = Normal(LookDir);
	AimDir = targ - Pawn.Location;
	AimDir.Z = 0;
	AimDir = Normal(AimDir);

	return ((LookDir Dot AimDir) < 0.93);
}

/* NearWall() 
returns true if there is a nearby barrier at eyeheight, and
changes FocalPoint to a suggested place to look
*/
function bool NearWall(float walldist)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, ViewSpot, ViewDist, LookDir;

	LookDir = vector(Rotation);
	ViewSpot = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1);
	ViewDist = LookDir * walldist; 
	HitActor = Trace(HitLocation, HitNormal, ViewSpot + ViewDist, ViewSpot, false);
	if ( HitActor == None )
		return false;

	ViewDist = Normal(HitNormal Cross vect(0,0,1)) * walldist;
	if (FRand() < 0.5)
		ViewDist *= -1;

	Focus = None;
	if ( FastTrace(ViewSpot + ViewDist, ViewSpot) )
	{
		FocalPoint = Pawn.Location + ViewDist;
		return true;
	}

	if ( FastTrace(ViewSpot - ViewDist, ViewSpot) )
	{
		FocalPoint = Pawn.Location - ViewDist;
		return true;
	}

	FocalPoint = Pawn.Location - LookDir * 300;
	return true;
}

// check for line of sight to target deltatime from now.
function bool CheckFutureSight(float deltatime)
{
	local vector FutureLoc;

	if ( Target == None )
		Target = Enemy;
	if ( Target == None )
		return false;

	if ( Pawn.Acceleration == vect(0,0,0) )
		FutureLoc = Pawn.Location;
	else
		FutureLoc = Pawn.Location + Pawn.GroundSpeed * Normal(Pawn.Acceleration) * deltaTime;

	if ( Pawn.Base != None ) 
		FutureLoc += Pawn.Base.Velocity * deltaTime;
	//make sure won't run into something
	if ( !FastTrace(FutureLoc, Pawn.Location) && (Pawn.Physics != PHYS_Falling) )
		return false;

	//check if can still see target
	if ( FastTrace(Target.Location + Target.Velocity * deltatime, FutureLoc) )
		return true;

	return false;
}

function float AdjustAimError(float aimerror, float TargetDist, bool bDefendMelee, bool bInstantProj, bool bLeadTargetNow )
{
	if ( (Pawn(Target) != None) && (Pawn(Target).Visibility < 2) )
		aimerror *= 2.5;
		
	// figure out the relative motion of the target across the bots view, and adjust aim error
	// based on magnitude of relative motion
	aimerror = aimerror * FMin(5,(12 - 11 *  
		(Normal(Target.Location - Pawn.Location) Dot Normal((Target.Location + 1.2 * Target.Velocity) - (Pawn.Location + Pawn.Velocity))))); 

	// if enemy is charging straight at bot with a melee weapon, improve aim
	if ( bDefendMelee )
		aimerror *= 0.5;

	if ( Target.Velocity == vect(0,0,0) )
		aimerror *= 0.6;
		
	// aiming improves over time if stopped
	if ( Stopped() && (Level.TimeSeconds > StopStartTime) )
	{
		if ( (Skill+Accuracy) > 4 )
			aimerror *= 0.9;
		if ( Pawn.Weapon.bSniping )
			aimerror *= FClamp((1.5 - 0.08 * FMin(skill,7) - 0.8 * FRand())/(Level.TimeSeconds - StopStartTime + 0.4),0.3,1.0);
		else
			aimerror *= FClamp((2 - 0.08 * FMin(skill,7) - FRand())/(Level.TimeSeconds - StopStartTime + 0.4),0.7,1.0);
	}

	// adjust aim error based on skill
	if ( !bDefendMelee )
		aimerror *= (3.3 - 0.37 * (FClamp(skill+Accuracy,0,8.5) + 0.5 * FRand()));

	// Bots don't aim as well if recently hit, or if they or their target is flying through the air
	if ( ((skill < 7) || (FRand()<0.5)) && (Level.TimeSeconds - Pawn.LastPainTime < 0.2) )
		aimerror *= 1.3;
	if ( (Pawn.Physics == PHYS_Falling) || (Target.Physics == PHYS_Falling) )
		aimerror *= 1.6;
		
	// Bots don't aim as well at recently acquired targets (because they haven't had a chance to lock in to the target)
	if ( AcquireTime > Level.TimeSeconds - 0.5 - 0.6 * (7 - skill) )
	{
		aimerror *= 1.5;
		if ( bInstantProj )
			aimerror *= 1.5;
	}

	return (Rand(2 * aimerror) - aimerror);
}

/*
AdjustAim()
Returns a rotation which is the direction the bot should aim - after introducing the appropriate aiming error
*/
function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
	local rotator FireRotation, TargetLook;
	local float FireDist, TargetDist, ProjSpeed;
	local actor HitActor;
	local vector FireSpot, FireDir, TargetVel, HitLocation, HitNormal;
	local int realYaw;
	local bool bDefendMelee, bClean, bLeadTargetNow;

	if ( FiredAmmunition.ProjectileClass != None )
		projspeed = FiredAmmunition.ProjectileClass.default.speed;

	// make sure bot has a valid target
	if ( Target == None )
	{
		Target = Enemy;
		if ( Target == None )
			return Rotation;
	}
	FireSpot = Target.Location;
	TargetDist = VSize(Target.Location - Pawn.Location);

	// perfect aim at stationary objects
	if ( Pawn(Target) == None )
	{
		if ( !FiredAmmunition.bTossed )
			return rotator(Target.Location - projstart);
		else
		{
			FireDir = AdjustToss(projspeed,ProjStart,Target.Location,true);
			SetRotation(Rotator(FireDir));
			return Rotation;
		}					
	}

	bLeadTargetNow = FiredAmmunition.bLeadTarget && bLeadTarget;
	bDefendMelee = ( (Target == Enemy) && DefendMelee(TargetDist) );
	aimerror = AdjustAimError(aimerror,TargetDist,bDefendMelee,FiredAmmunition.bInstantHit, bLeadTargetNow);

	// lead target with non instant hit projectiles
	if ( bLeadTargetNow )
	{
		TargetVel = Target.Velocity;
		// hack guess at projecting falling velocity of target
		if ( Target.Physics == PHYS_Falling )
		{
			if ( Target.PhysicsVolume.Gravity.Z <= Target.PhysicsVolume.Default.Gravity.Z )
				TargetVel.Z = FMin(TargetVel.Z + FMax(-400, Target.PhysicsVolume.Gravity.Z * FMin(1,TargetDist/projSpeed)),0);
			else
				TargetVel.Z = FMin(0, TargetVel.Z);
		}
		// more or less lead target (with some random variation)
		FireSpot += FMin(1, 0.7 + 0.6 * FRand()) * TargetVel * TargetDist/projSpeed;
		FireSpot.Z = FMin(Target.Location.Z, FireSpot.Z);

		if ( (Target.Physics != PHYS_Falling) && (FRand() < 0.55) && (VSize(FireSpot - ProjStart) > 1000) )
		{
			// don't always lead far away targets, especially if they are moving sideways with respect to the bot
			TargetLook = Target.Rotation;
			if ( Target.Physics == PHYS_Walking )
				TargetLook.Pitch = 0;
			bClean = ( ((Vector(TargetLook) Dot Normal(Target.Velocity)) >= 0.71) && FastTrace(FireSpot, ProjStart) );
		}
		else // make sure that bot isn't leading into a wall
			bClean = FastTrace(FireSpot, ProjStart);
		if ( !bClean)
		{
			// reduce amount of leading
			if ( FRand() < 0.3 )
				FireSpot = Target.Location;
			else
				FireSpot = 0.5 * (FireSpot + Target.Location);
		}
	}

	bClean = false; //so will fail first check unless shooting at feet  
	if ( FiredAmmunition.bTrySplash && (Pawn(Target) != None) && ((Skill >=4) || bDefendMelee) 
		&& (((Target.Physics == PHYS_Falling) && (Pawn.Location.Z + 80 >= Target.Location.Z))
			|| ((Pawn.Location.Z + 19 >= Target.Location.Z) && (bDefendMelee || (skill > 6.5 * FRand() - 0.5)))) )
	{
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot - vect(0,0,1) * (Target.CollisionHeight + 6), FireSpot, false);
 		bClean = (HitActor == None);
		if ( !bClean )
		{
			FireSpot = HitLocation + vect(0,0,3);
			bClean = FastTrace(FireSpot, ProjStart);
		}
		else 
			bClean = ( (Target.Physics == PHYS_Falling) && FastTrace(FireSpot, ProjStart) );
	}
	if ( Pawn.Weapon.bSniping && Stopped() && (Skill > 5 + 6 * FRand()) )
	{
		// try head
 		FireSpot.Z = Target.Location.Z + 0.9 * Target.CollisionHeight;
 		bClean = FastTrace(FireSpot, ProjStart);
	}
	
	if ( !bClean )
	{
		//try middle
		FireSpot.Z = Target.Location.Z;
 		bClean = FastTrace(FireSpot, ProjStart);
	}
	if ( FiredAmmunition.bTossed && !bClean && bEnemyInfoValid )
	{
		FireSpot = LastSeenPos;
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if ( HitActor != None )
		{
			bCanFire = false;
			FireSpot += 2 * Target.CollisionHeight * HitNormal;
		}
		bClean = true;
	}

	if( !bClean ) 
	{
		// try head
 		FireSpot.Z = Target.Location.Z + 0.9 * Target.CollisionHeight;
 		bClean = FastTrace(FireSpot, ProjStart);
	}
	if ( !bClean && (Target == Enemy) && bEnemyInfoValid )
	{
		FireSpot = LastSeenPos;
		if ( Pawn.Location.Z >= LastSeenPos.Z )
			FireSpot.Z -= 0.4 * Enemy.CollisionHeight;
	 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if ( HitActor != None )
		{
			FireSpot = LastSeenPos + 2 * Enemy.CollisionHeight * HitNormal;
			if ( Pawn.Weapon.SplashDamage() && (Skill >= 4) )
			{
			 	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
				if ( HitActor != None )
					FireSpot += 2 * Enemy.CollisionHeight * HitNormal;
			}
			if ( Pawn.Weapon.RefireRate() < 0.99 )
				bCanFire = false;
		}
	}

	// adjust for toss distance
	if ( FiredAmmunition.bTossed )
		FireDir = AdjustToss(projspeed,ProjStart,FireSpot,true);
	else
		FireDir = FireSpot - ProjStart;
	
	FireRotation = Rotator(FireDir);
	realYaw = FireRotation.Yaw;
	FiredAmmunition.WarnTarget(Target,Pawn,vector(FireRotation));

	FireRotation.Yaw = SetFireYaw(FireRotation.Yaw + aimerror);
	FireDir = vector(FireRotation);
	// avoid shooting into wall
	FireDist = FMin(VSize(FireSpot-ProjStart), 400);
	FireSpot = ProjStart + FireDist * FireDir;
	HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false); 
	if ( HitActor != None )
	{
		if ( HitNormal.Z < 0.7 )
		{
			FireRotation.Yaw = SetFireYaw(realYaw - aimerror);
			FireDir = vector(FireRotation);
			FireSpot = ProjStart + FireDist * FireDir;
			HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false); 
		}
		if ( HitActor != None )
		{
			FireSpot += HitNormal * 2 * Target.CollisionHeight;
			if ( Skill >= 4 )
			{
				HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false); 
				if ( HitActor != None )
					FireSpot += Target.CollisionHeight * HitNormal; 
			}
			FireDir = Normal(FireSpot - ProjStart);
			FireRotation = rotator(FireDir);		
		}
	}

	SetRotation(FireRotation);			
	return FireRotation;
}

function ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir)
{
	local float enemyDist;
	local vector X,Y,Z, enemyDir;

	// AI controlled creatures may duck if not falling
	if ( (Pawn.health <= 0) || (Skill < 4) || (Enemy == None) 
		|| (Pawn.Physics == PHYS_Falling) || (Pawn.Physics == PHYS_Swimming) 
		|| (FRand() > 0.2 * skill - 0.4) )
		return;

	// and projectile time is long enough
	enemyDist = VSize(shooter.Location - Pawn.Location);
	if (enemyDist/projSpeed < 0.11 + 0.15 * FRand()) 
		return;
	// only if tight FOV
	GetAxes(Rotation,X,Y,Z);
	enemyDir = (shooter.Location - Pawn.Location)/enemyDist;
	if ((enemyDir Dot X) < 0.8)
		return;
	if ( (FireDir Dot Y) > 0 )
	{
		Y *= -1;
		TryToDuck(Y, true);
	}
	else
		TryToDuck(Y, false);
}

function bool TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent;
	local actor HitActor;
	local bool bSuccess, bDuckLeft;

	if ( Pawn.PhysicsVolume.bWaterVolume 
		|| (Pawn.PhysicsVolume.Gravity.Z > Pawn.PhysicsVolume.Default.Gravity.Z) )
		return false;

	duckDir.Z = 0;
	bDuckLeft = !bReversed;
	Extent = Pawn.GetCollisionExtent();
	HitActor = Trace(HitLocation, HitNormal, Pawn.Location + 240 * duckDir, Pawn.Location, false, Extent);
	bSuccess = ( (HitActor == None) || (VSize(HitLocation - Pawn.Location) > 150) );
	if ( !bSuccess )
	{
		bDuckLeft = !bDuckLeft;
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Pawn.Location + 240 * duckDir, Pawn.Location, false, Extent);
		bSuccess = ( (HitActor == None) || (VSize(HitLocation - Pawn.Location) > 150) );
	}
	if ( !bSuccess )
		return false;
	
	if ( HitActor == None )
		HitLocation = Pawn.Location + 240 * duckDir; 

	HitActor = Trace(HitLocation, HitNormal, HitLocation - MAXSTEPHEIGHT * vect(0,0,1), HitLocation, false, Extent);
	if (HitActor == None)
		return false;
		
 	if (UnrealPawn(Pawn) != None)
	{
		if ( bDuckLeft )
			UnrealPawn(Pawn).CurrentDir = DCLICK_Left;
		else	
			UnrealPawn(Pawn).CurrentDir = DCLICK_Right;
		UnrealPawn(Pawn).Dodge(UnrealPawn(Pawn).CurrentDir);
	}

	return true;
}

function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn)
{
	Squad.NotifyKilled(Killer,Killed,KilledPawn);
}	

function Actor FaceMoveTarget()
{
	if ( MoveTarget != Enemy )
		StopFiring();
	return MoveTarget;
}

function bool ShouldStrafeTo(Actor WayPoint)
{
	local NavigationPoint N;

	if ( Skill + StrafingAbility < 3 )
		return false;

	if ( WayPoint == Enemy )
	{
		if ( Pawn.Weapon.bMeleeWeapon )
			return false;
		return ( Skill + StrafingAbility < 5 * FRand() - 1 );
	}
	else if ( Pickup(WayPoint) == None )
	{
		N = NavigationPoint(WayPoint);
		if ( (N == None) || N.bNeverUseStrafing )
			return false;

		if ( N.FearCost > 200 )
			return true;
		if ( N.bAlwaysUseStrafing && (FRand() < 0.8) )
			return true;
	}
	if ( (Pawn(WayPoint) != None) || ((Squad.SquadLeader != None) && (WayPoint == Squad.SquadLeader.MoveTarget)) )
		return ( Skill + StrafingAbility < 5 * FRand() - 1 );

	if ( Skill + StrafingAbility < 7 * FRand() - 1 )
		return false;
		
	if ( !bFinalStretch && (Enemy == None) )
		return ( FRand() < 0.4 );
		
	if ( (Enemy != None) && EnemyVisible() )
		return ( FRand() < 0.85 ); 
	return ( FRand() < 0.6 );
}

function Actor AlternateTranslocDest()
{
	if ( (PathNode(MoveTarget) == None) || (MoveTarget != RouteCache[0]) || (RouteCache[0] == None) )
		return None;
	if ( (PathNode(RouteCache[1]) == None) && (InventorySpot(RouteCache[1]) == None) && GameObjective(RouteCache[1]) == None )
	{
		if ( (FRand() < 0.5) && (CarriedObject(RouteGoal) != None)
			&& (VSize(RouteGoal.Location - Pawn.Location) < 2000)
			&& LineOfSightTo(RouteGoal) )
			return RouteGoal;
		return None;
	}
	if ( (FRand() < 0.3)
		&& (GameObjective(RouteCache[1]) == None)
		&& ((PathNode(RouteCache[2]) != None) || (InventorySpot(RouteCache[2]) != None) || (GameObjective(RouteCache[2]) != None))
		&& LineOfSightTo(RouteCache[2]) )
		return RouteCache[2];
	if ( LineOfSightTo(RouteCache[1]) )
		return RouteCache[1];
	return None;
}

function Actor FaceActor(float StrafingModifier)
{
	local float RelativeDir, Dist, MinDist;
	local actor SquadFace, N;
	local bool bEnemyNotEngaged, bTranslocTactics, bCatchup;
	
	bTranslocatorHop = false;
	SquadFace = Squad.SetFacingActor(self);
	if ( SquadFace != None )
		return SquadFace;
	if ( (Pawn.Weapon != None) && Pawn.Weapon.FocusOnLeader(false) )
		return Squad.SquadLeader.Pawn;
	
	// translocator hopping
	
	bEnemyNotEngaged = (Enemy == None)||(Level.TimeSeconds - LastSeenTime > 1);
	bCatchup = ((Pawn(RouteGoal) != None) && !SameTeamAs(Pawn(RouteGoal).Controller)) || (CarriedObject(RouteGoal) != None);
	if ( bEnemyNotEngaged )
	{ 
		if ( bCatchup )
			bTranslocTactics = (Skill + Tactics > 2 + 2*FRand());
		else
			bTranslocTactics = (Skill + Tactics > 4);
	}
	bTranslocTactics = bTranslocTactics || (Skill + Tactics > 2.5 + 3 * FRand());
	if (  bTranslocTactics && (TranslocUse > FRand()) && (TranslocFreq < Level.TimeSeconds + 6 + 9 * FRand())
		&& ((NavigationPoint(Movetarget) != None) || (CarriedObject(MoveTarget) != None))
		&& (LiftCenter(MoveTarget) == None) 
		&& CanUseTranslocator() 
		&& (bEnemyNotEngaged || bRecommendFastMove || (CarriedObject(MoveTarget) != None) || (VSize(Enemy.Location - Pawn.Location) > ENEMYLOCATIONFUZZ * (1 + FRand()))
			|| (bCatchup && (FRand() < 0.65) && (!LineOfSightTo(RouteGoal) || (CarriedObject(RouteGoal) != None)))) )
	{
		bRecommendFastMove = false;
		bTranslocatorHop = true;
		TranslocationTarget = MoveTarget;
		RealTranslocationTarget = TranslocationTarget;
		Focus = MoveTarget;
		Dist = VSize(Pawn.Location - MoveTarget.Location);
		MinDist = 300 + 40 * FMax(0,TranslocFreq - Level.TimeSeconds);
		if ( (CarriedObject(RouteGoal) != None) && (VSize(Pawn.Location - RouteGoal.Location) < 1000 + 1200 * FRand()) && LineOfSightTo(RouteGoal) )
		{
			TranslocationTarget = RouteGoal;
			RealTranslocationTarget = TranslocationTarget;
			Dist = VSize(Pawn.Location - TranslocationTarget.Location);
			Focus = RouteGoal;
		}
		else if ( MinDist + 200 + 1000 * FRand() > Dist )
		{
			N = AlternateTranslocDest();
			if ( N != None )
			{
				TranslocationTarget = N;
				RealTranslocationTarget = TranslocationTarget;
				Dist = VSize(Pawn.Location - TranslocationTarget.Location);
				Focus = N;
			}
		}
		if ( (Dist < MinDist) || ((Dist < MinDist + 150) && !Pawn.Weapon.IsA('TransLauncher')) )
		{
			TranslocationTarget = None;
			RealTranslocationTarget = TranslocationTarget;
			bTranslocatorHop = false;
		}
		else
		{	
			SwitchToBestWeapon();
			return Focus;
		}
	}
	bRecommendFastMove = false;
	if ( (Enemy == None) || (Level.TimeSeconds - LastSeenTime > 6 - StrafingModifier) )
		return FaceMoveTarget();	
	if ( (MoveTarget == Enemy) || ((skill + StrafingAbility >= 6) && !Pawn.Weapon.bMeleeWeapon) 
		|| (VSize(MoveTarget.Location - Pawn.Location) < 4 * Pawn.CollisionRadius) )
		return Enemy;	
	if ( Level.TimeSeconds - LastSeenTime > 4 - StrafingModifier)
		return FaceMoveTarget();
	if ( (Skill > 2.5) && (CarriedObject(MoveTarget) != None) )
		return Enemy;
	RelativeDir = Normal(Enemy.Location - Pawn.Location - vect(0,0,1) * (Enemy.Location.Z - Pawn.Location.Z)) 
			Dot Normal(MoveTarget.Location - Pawn.Location - vect(0,0,1) * (MoveTarget.Location.Z - Pawn.Location.Z));

	if ( RelativeDir > 0.85 )
		return Enemy;
	if ( (RelativeDir > 0.3) && (Bot(Enemy.Controller) != None) && (MoveTarget == Enemy.Controller.MoveTarget) )
		return Enemy;
	if ( skill + StrafingAbility < 2 + FRand() )
		return FaceMoveTarget();
		
	if ( (Pawn.Weapon.bMeleeWeapon && (RelativeDir < 0.3))
		|| (Skill + StrafingAbility < (5 + StrafingModifier) * FRand())
		|| (0.4*RelativeDir + 0.8 < FRand()) )
		return FaceMoveTarget();
		
	return Enemy;
}

// Added:  Sean C. Dumas/Taldren
function bool FaceDestination(float StrafingModifier)
{
	local float RelativeDir;

	if ( Level.TimeSeconds - LastSeenTime > 7.5 - StrafingModifier )
		return true;
	if ( Enemy == None )
		return true;
	if ( (skill >= 6) && !Pawn.Weapon.bMeleeWeapon )
		return false;
	if ( VSize(MoveTarget.Location - Pawn.Location) < 2.5 * Pawn.CollisionRadius )
		return false;	
	if ( Level.TimeSeconds - LastSeenTime > 4 - StrafingModifier)
		return true;

	RelativeDir = Normal(Enemy.Location - Pawn.Location - vect(0,0,1) * (Enemy.Location.Z - Pawn.Location.Z)) 
			Dot Normal(MoveTarget.Location - Pawn.Location - vect(0,0,1) * (MoveTarget.Location.Z - Pawn.Location.Z));

	if ( RelativeDir > 0.93 )
		return false;
	if ( Pawn.Weapon.bMeleeWeapon && (RelativeDir < 0) )
		return true;
	if ( FRand() < 0.2 * (2 - StrafingModifier) )
		return false;
	if ( 0.5 * Skill - StrafingModifier * FRand() + RelativeDir + 0.6 + StrafingAbility < 0 )
		return true;

	return false;
}
// End Added

function WanderOrCamp(bool bMayCrouch)
{
	Pawn.bWantsToCrouch = bMayCrouch && (Pawn.bIsCrouched || (FRand() < 0.75));
	Focus = Enemy;
	GotoState('RestFormation');
}

function bool NeedWeapon()
{
	local inventory Inv;
	
	if (!Pawn.bCanPickupInventory)
		return false;

	if ( Pawn.Weapon.AIRating > 0.5 )
		return ( !Pawn.Weapon.HasAmmo() );

	// see if have some other good weapon, currently not in use
	for ( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory )
		if ( (Weapon(Inv) != None) && (Weapon(Inv).AIRating > 0.5) && Weapon(Inv).HasAmmo() )
			return false;		

	return true;
}

event float Desireability(Pickup P)
{
	if (!Pawn.bCanPickupInventory)
		return -1;

	if (UnrealPawn(Pawn) != None)
	{
		if ( !UnrealPawn(Pawn).IsInLoadout(P.InventoryType) )
			return -1;
	}

	return P.BotDesireability(Pawn);
}

function DamageAttitudeTo(Pawn Other, float Damage)
{
	if ( (Pawn.health > 0) && (Damage > 0) && SetEnemy(Other) )
		WhatToDoNext(5);
}

function bool IsRetreating()
{
	return false;
}

//**********************************************************************************
// AI States

//=======================================================================================================
// No goal/no enemy states

state NoGoal
{
	function EnemyChanged(bool bNewEnemyVisible)
	{
		if ( EnemyAcquisitionScript != None )
		{
			bEnemyAcquired = false;
			SetEnemyInfo(bNewEnemyVisible);
			EnemyAcquisitionScript.TakeOver(Pawn);
		}
		else
			Global.EnemyChanged(bNewEnemyVisible);
	}
}

function bool Formation()
{
	return false;
}

state RestFormation extends NoGoal
{
	ignores EnemyNotVisible;

	function CancelCampFor(Controller C)
	{
		DirectedWander(Normal(Pawn.Location - C.Pawn.Location));
	}

	function bool Formation()
	{
		return true;
	}

	function Timer()
	{
		SetCombatTimer();		
		enable('NotifyBump');
	}

	function BeginState()
	{
		//Enemy = None;
		SetEnemy(None);

		SetAlertness(0.2);
		Pawn.bCanJump = false;
		Pawn.bAvoidLedges = true;
		Pawn.bStopAtLedges = true;
		//Pawn.SetWalking(true);
		MinHitWall += 0.15;
	}
	
	function EndState()
	{
		MonitoredPawn = None;
		Squad.GetRestingFormation().LeaveFormation(self);
		MinHitWall -= 0.15;
		if ( Pawn != None )
		{
			Pawn.bStopAtLedges = false;
			Pawn.bAvoidLedges = false;
			//Pawn.SetWalking(false);
			if (Pawn.JumpZ > 0)
				Pawn.bCanJump = true;
		}
	}

	event MonitoredPawnAlert()
	{
		WhatToDoNext(6);
	}

	function PickDestination()
	{
		FormationPosition = Squad.GetRestingFormation().RecommendPositionFor(self);
		Destination = Squad.GetRestingFormation().GetLocationFor(FormationPosition,self);
	}

Begin:
	//log("Miket: RestFormation state start");
 	StartState();
	Sleep(0.1);

	WaitForLanding();
	PickDestination();
	
Moving:
	if ( (Squad.SquadLeader != self) && (Squad.SquadLeader.Pawn != None) && (Squad.FormationCenter() == Squad.SquadLeader.Pawn) )
		StartMonitoring(Squad.SquadLeader.Pawn,Squad.GetRestingFormation().FormationSize);
	else
		MonitoredPawn = None;

	MoveTo(Destination,,ShouldWalk());
	WaitForLanding();
	if ( !Squad.NearFormationCenter(Pawn) )
	{
		Pawn.Acceleration = vect(0,0,0);
		Sleep(0.5); 
		WhatToDoNext(7);
	}
Camping:
	Sleep(0.5);
	Pawn.Acceleration = vect(0,0,0);
	Focus = None;
	FocalPoint = Squad.GetRestingFormation().GetViewPointFor(self,FormationPosition);
	NearWall(MINVIEWDIST);
	FinishRotation();
	if ( (Squad.SquadLeader.Pawn != None) && (Squad.FormationCenter() == Squad.SquadLeader.Pawn) )
		StartMonitoring(Squad.SquadLeader.Pawn,Squad.GetRestingFormation().FormationSize);
	else
		MonitoredPawn = None;
	Sleep(3 + FRand());
	WaitForLanding();
	if ( !Squad.WaitAtThisPosition(Pawn) ) 
	{
		if ( Squad.WanderNearLeader(self) )
			SetAttractionState();
		else
			WhatToDoNext(8);
	}
	if ( FRand() < 0.6 )
		Goto('Camping');
	Goto('Begin');

ShortWait:
	Pawn.Acceleration = vect(0,0,0);
	Focus = None;
	FocalPoint = Squad.GetRestingFormation().GetViewPointFor(self,FormationPosition);
	NearWall(MINVIEWDIST);
	FinishRotation();
	Sleep(CampTime);
	WaitForLanding();
	WhatToDoNext(9);
}

function Celebrate()
{
	Pawn.PlayVictoryAnimation();
}

//=======================================================================================================
// Move To Goal states

state Startled
{
	ignores EnemyNotVisible,SeePlayer,HearNoise;

	function Startle(Actor Feared)
	{
		GoalString = "STARTLED!";
		StartleActor = Feared;
		BeginState();
	}

	function BeginState()
	{
		// FIXME - need FindPathAwayFrom()
		Pawn.Acceleration = Pawn.Location - StartleActor.Location;
		Pawn.Acceleration.Z = 0;
		Pawn.bIsWalking = false;
		Pawn.bWantsToCrouch = false;
		if ( Pawn.Acceleration == vect(0,0,0) )
			Pawn.Acceleration = VRand();
		Pawn.Acceleration = Pawn.AccelRate * Normal(Pawn.Acceleration);
	}			
Begin:
	//log("Miket: Startled state start");
	Sleep(0.5);
	WhatToDoNext(11);
	Goto('Begin');
}

state MoveToGoal
{
	function bool CheckPathToGoalAround(Pawn P)
	{
		if ( (MoveTarget == None) || (Bot(P.Controller) == None) || !SameTeamAs(P.Controller) )
			return false;

		if ( Bot(P.Controller).Squad.ClearPathFor(self) )
			return true;
		return false;
	}

	function Timer()
	{
		SetCombatTimer();
		enable('NotifyBump');
	}

	function BeginState()
	{
		if (Squad != None)
			Pawn.bWantsToCrouch = Squad.CautiousAdvance(self);
	}
}

state MoveToGoalNoEnemy extends MoveToGoal
{
	function EnemyChanged(bool bNewEnemyVisible)
	{
		if ( EnemyAcquisitionScript != None )
		{
			bEnemyAcquired = false;
			SetEnemyInfo(bNewEnemyVisible);
			EnemyAcquisitionScript.TakeOver(Pawn);
		}
		else
			Global.EnemyChanged(bNewEnemyVisible);
	}
}

state MoveToGoalWithEnemy extends MoveToGoal
{
	function Timer()
	{
		TimedFireWeaponAtEnemy();
	}
}

function float GetDesiredOffset()
{
	if ( MoveTarget != Squad.SquadLeader.Pawn )
		return 0;

	return Squad.GetRestingFormation().FormationSize*0.5;
}

state Roaming extends MoveToGoalNoEnemy
{
	ignores EnemyNotVisible;

	function MayFall()
	{
		Pawn.bCanJump = ( (MoveTarget != None) 
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Pickup')) );
	}
	
Begin:
	//log("Miket: Roaming state start");
	StartState();
	Sleep(0.1);

	SwitchToBestWeapon();
	WaitForLanding();
	if ( Pawn.bCanPickupInventory && (InventorySpot(MoveTarget) != None) && (Squad.PriorityObjective(self) == 0) )
	{
		MoveTarget = InventorySpot(MoveTarget).GetMoveTargetFor(self,5);
		if ( (Pickup(MoveTarget) != None) && !Pickup(MoveTarget).ReadyToPickup(0) )
		{
			CampTime = MoveTarget.LatentFloat;
			GoalString = "Short wait for inventory "$MoveTarget;
			GotoState('RestFormation','ShortWait');
		}
	}
	MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget), ShouldWalk());
DoneRoaming:
	WaitForLanding();
	WhatToDoNext(12);
	if ( bSoaking )
		SoakStop("STUCK IN ROAMING!");
}

state Fallback extends MoveToGoalWithEnemy
{
	function bool IsRetreating()
	{
		return ( (Acceleration Dot (Pawn.Location - Enemy.Location)) > 0 );
	}

	event bool NotifyBump(actor Other)
	{
		local Pawn P;

		Disable('NotifyBump');
		if ( MoveTarget == Other )
		{
			if ( MoveTarget == Enemy )
			{
				TimedFireWeaponAtEnemy();
				DoRangedAttackOn(Enemy);
			}
			return false;
		}
		
		P = Pawn(Other);
		if ( (P == None) || (P.Controller == None) )
			return false;
		if ( !SameTeamAs(P.Controller) && (MoveTarget == RouteCache[0]) && (RouteCache[1] != None) && P.ReachedDestination(MoveTarget) )
		{
			MoveTimer = VSize(RouteCache[1].Location - Pawn.Location)/(Pawn.GroundSpeed * Pawn.DesiredSpeed) + 1;
			MoveTarget = RouteCache[1];
		}
		SetEnemy(P);

		if ( Enemy == Other )
		{
			Focus = Enemy;
			TimedFireWeaponAtEnemy();
		}
		if ( CheckPathToGoalAround(P) )
			return false;

		AdjustAround(P);
		return false;
	}
	
	function MayFall()
	{
		Pawn.bCanJump = ( (MoveTarget != None) 
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Pickup')) );
	}

	function EnemyNotVisible()
	{
		if ( Squad.FindNewEnemyFor(self,false) || (Enemy == None) )
			WhatToDoNext(13);
		else
		{
			enable('SeePlayer');
			disable('EnemyNotVisible');
		}
	}

	function EnemyChanged(bool bNewEnemyVisible)
	{
		bEnemyAcquired = false;
		SetEnemyInfo(bNewEnemyVisible);
		if ( bNewEnemyVisible )
		{
			disable('SeePlayer');
			enable('EnemyNotVisible');
		}
	}

Begin:
	//log("Miket: Fallback state start");
	StartState();
	WaitForLanding();

Moving:
	if ( InventorySpot(MoveTarget) != None )
		MoveTarget = InventorySpot(MoveTarget).GetMoveTargetFor(self,0);
	MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget), ShouldWalk());
	WhatToDoNext(14);
	DoTacticalMove();	// If we're here, clearly we didn't enter into a new appropriate state.
	if ( bSoaking )
		SoakStop("STUCK IN FALLBACK!");
	goalstring = goalstring$" STUCK IN FALLBACK!";
}

// FIXME - implement acquisition state for SP

//=======================================================================================================================
// Tactical Combat states

/* LostContact()
return true if lost contact with enemy
*/
function bool LostContact(float MaxTime)
{
	if ( Enemy == None )
		return true;

	if ( Enemy.Visibility < 2 )
		MaxTime = FMax(2,MaxTime - 2);
	if ( Level.TimeSeconds - FMax(LastSeenTime,AcquireTime) > MaxTime )
		return true;

	return false;
}

/* LoseEnemy()
get rid of old enemy, if squad lets me
*/
function bool LoseEnemy()
{
	if ( Enemy == None )
		return true;
	if ( (Enemy.Health > 0) && (Enemy.Controller != None) && (LoseEnemyCheckTime > Level.TimeSeconds - 0.2) )
		return false;
	LoseEnemyCheckTime = Level.TimeSeconds;
	if ( Squad.LostEnemy(self) )
	{
		bFrustrated = false;
		return true;
	}
	// still have same enemy
	return false;
}

function DoStakeOut()
{
	Focus = Enemy;
	GotoState('StakeOut');
}

function DoCharge()
{
	if ( Enemy.PhysicsVolume.bWaterVolume )
	{
		if ( !Pawn.bCanSwim )
		{ 
			DoTacticalMove();
			return;
		}
	}
	else if ( !Pawn.bCanFly && !Pawn.bCanWalk )
	{
		DoTacticalMove();
		return;
	}
	Focus = Enemy;
	GotoState('Charging');
}

function DoTacticalMove()
{
	Focus = Enemy;
	GotoState('TacticalMove');
}


function float GetStrafeDist()
{
	return (MINSTRAFEDIST * 2.0) * (Pawn.GroundSpeed / 200.0);
}


function DoRetreat()
{
	if ( Squad.PickRetreatDestination(self) )
	{
		Focus = Enemy;
		GotoState('Retreating');
		return;
	}

	// if nothing, then tactical move
	if ( EnemyVisible() )
	{
		GoalString= "No retreat because frustrated";
		bFrustrated = true;
		if ( Pawn.Weapon.bMeleeWeapon )
			DoCharge();
		else
			DoTacticalMove();
		return;
	}
	GoalString = "Stakeout because no retreat dest";
	DoStakeOut();
}

/* DefendMelee()
return true if defending against melee attack
*/
function bool DefendMelee(float Dist)
{
	return ( (Enemy.Weapon != None) && Enemy.Weapon.bMeleeWeapon && (Dist < 1000) );
}

state Retreating extends Fallback
{
	function bool IsRetreating()
	{
		return true;
	}
	
	function Actor FaceActor(float StrafingModifier)
	{
		return Global.FaceActor(2);
	}

	function BeginState()
	{
		Pawn.bWantsToCrouch = Squad.CautiousAdvance(self);
	}
}

state Charging extends MoveToGoalWithEnemy
{
ignores SeePlayer, HearNoise;

	/* MayFall() called by engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting 
		bCanJump to false) to avoid fall
	*/
	function MayFall()
	{
		if ( MoveTarget != Enemy )
			return;

		Pawn.bCanJump = ActorReachable(Enemy);
		if ( !Pawn.bCanJump )
			MoveTimer = -1.0;
	}

	function bool TryToDuck(vector duckDir, bool bReversed)
	{
		if ( FRand() < 0.6 )
			return Global.TryToDuck(duckDir, bReversed);
		if ( MoveTarget == Enemy ) 
			return TryStrafe(duckDir);
	}

	function bool StrafeFromDamage(float Damage, class<DamageType> DamageType, bool bFindDest)
	{
		local vector sideDir;

		if ( FRand() * Damage < 0.15 * CombatStyle * Pawn.Health ) 
			return false;

		if ( !bFindDest )
			return true;

		sideDir = Normal( Normal(Enemy.Location - Pawn.Location) Cross vect(0,0,1) );
		if ( (Pawn.Velocity Dot sidedir) > 0 )
			sidedir *= -1;

		return TryStrafe(sideDir);
	}

	function bool TryStrafe(vector sideDir)
	{ 
		local vector extent, HitLocation, HitNormal;
		local actor HitActor;

		Extent = Pawn.GetCollisionExtent();
		HitActor = Trace(HitLocation, HitNormal, Pawn.Location + MINSTRAFEDIST * sideDir, Pawn.Location, false, Extent);
		if (HitActor != None)
		{
			sideDir *= -1;
			HitActor = Trace(HitLocation, HitNormal, Pawn.Location + MINSTRAFEDIST * sideDir, Pawn.Location, false, Extent);
		}
		if (HitActor != None)
			return false;
		
		if ( Pawn.Physics == PHYS_Walking )
		{
			HitActor = Trace(HitLocation, HitNormal, Pawn.Location + MINSTRAFEDIST * sideDir - MAXSTEPHEIGHT * vect(0,0,1), Pawn.Location + MINSTRAFEDIST * sideDir, false, Extent);
			if ( HitActor == None )
				return false;
		}
		Destination = Pawn.Location + 2 * MINSTRAFEDIST * sideDir;
		GotoState('TacticalMove', 'DoStrafeMove');
		return true;
	}

	function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{	
		local float pick;
		local vector sideDir;
		local bool bWasOnGround;

		Super.NotifyTakeHit(InstigatedBy,HitLocation, Damage,DamageType,Momentum);

		bWasOnGround = (Pawn.Physics == PHYS_Walking);
		if ( Pawn.health <= 0 )
			return;
		if ( StrafeFromDamage(damage, damageType, true) )
			return; 
		else if ( bWasOnGround && (MoveTarget == Enemy) && 
					(Pawn.Physics == PHYS_Falling) ) //weave
		{
			pick = 1.0;
			if ( bStrafeDir )
				pick = -1.0;
			sideDir = Normal( Normal(Enemy.Location - Pawn.Location) Cross vect(0,0,1) );
			sideDir.Z = 0;
			Pawn.Velocity += pick * Pawn.GroundSpeed * 0.7 * sideDir;   
			if ( FRand() < 0.2 )
				bStrafeDir = !bStrafeDir;
		}
	}

	event bool NotifyBump(actor Other)
	{
		if ( (Other == Enemy)
			&& (Pawn.Weapon != None) && !Pawn.Weapon.bMeleeWeapon && (FRand() > 0.4 + 0.1 * skill) )
		{
			Focus = Enemy;

			DoRangedAttackOn(Enemy);
			return false;
		}
		return Global.NotifyBump(Other);
	}

	function Timer()
	{
		enable('NotifyBump');
		Target = Enemy;	
		TimedFireWeaponAtEnemy();
	}
	
	function EnemyNotVisible()
	{
		WhatToDoNext(15); 
	}

	function EndState()
	{
		if ( (Pawn != None) && Pawn.JumpZ > 0 )
			Pawn.bCanJump = true;
	}

Begin:
	//log("Miket: Charging state start");
	StartState();

	if (Pawn.Physics == PHYS_Falling)
	{
		Focus = Enemy;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	if ( Enemy == None )
		WhatToDoNext(16);
	if ( !FindBestPathToward(Enemy, false,true) )
		DoTacticalMove();

Moving:
	if ( (Pawn.Weapon != None) && (Pawn.Weapon.bMeleeWeapon) ) // FIXME HACK
		FireWeaponAt(Enemy);
	MoveToward(MoveTarget,FaceActor(1),,ShouldStrafeTo(MoveTarget), ShouldWalk());

	WhatToDoNext(17);
	if ( bSoaking )
		SoakStop("STUCK IN CHARGING!");
}

// Moves towards the enemy, but not all the way.
state MoveTowardsEnemy extends Charging
{
Begin:
	//log("Miket: MoveTowardsEnemy state start");
	StartState();
	////log("Miket: State MoveTowardsEnemy");
	if (Pawn.Physics == PHYS_Falling)
	{
		Focus = Enemy;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	if ( !FindBestPathToward(Enemy, true,true) )	// Modified:  Sean C. Dumas/Taldren
		DoTacticalMove();
	if ( FaceDestination(1.5) )
	{
		StopFiring();
		MoveToward(MoveTarget,,,ShouldStrafeTo(MoveTarget), ShouldWalk());
	}
	else
		MoveToward(MoveTarget, Enemy,,ShouldStrafeTo(MoveTarget), ShouldWalk());

	ChooseAttackMode();	// If we're here, clearly we didn't enter into a new appropriate state.
	DoTacticalMove();		// Crap.  Oh well, the tactical move is fine.
	if ( bSoaking )
		SoakStop("STUCK IN CHARGING!");
	////log("Miket: State MoveTowardsEnemy End");
}


function bool IsStrafing()
{
	return false;
}


state TacticalMove
{
ignores SeePlayer, HearNoise;

	function bool IsStrafing()
	{
		return true;
	}

	function ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir)
	{	
		if ( bCanFire && (FRand() < 0.4) ) 
			return;

		Super.ReceiveWarning(shooter, projSpeed, FireDir);
	}

	function SetFall()
	{
		Pawn.Acceleration = vect(0,0,0);
		Destination = Pawn.Location;
		Global.SetFall();
	}

	function bool NotifyHitWall(vector HitNormal, actor Wall)
	{
		if (Pawn.Physics == PHYS_Falling)
			return false;
		if ( Enemy == None )
		{
			WhatToDoNext(18);
			return false;
		}
		if ( bChangeDir || (FRand() < 0.5) 
			|| (((Enemy.Location - Pawn.Location) Dot HitNormal) < 0) )
		{
			Focus = Enemy;
			WhatToDoNext(19);
		}
		else
		{
			bChangeDir = true;
			Destination = Pawn.Location - HitNormal * FRand() * 500;
		}
		return true;
	}

	function Timer()
	{
		enable('NotifyBump');
		Target = Enemy;
		if ( (Enemy != None) && !bNotifyApex )
			TimedFireWeaponAtEnemy();
		else
			SetCombatTimer();
	}

	function EnemyNotVisible()
	{
		StopFiring();
		if ( aggressiveness > relativestrength(enemy) )
		{
			if ( FastTrace(Enemy.Location, LastSeeingPos) )
			{
				Focus = Enemy;
				GotoState('TacticalMove','RecoverEnemy');
			}
			else
				WhatToDoNext(20);
		}
		Disable('EnemyNotVisible');
	}

	function PawnIsInPain(PhysicsVolume PainVolume)
	{
		Destination = Pawn.Location - MINSTRAFEDIST * Normal(Pawn.Velocity);
	}

	/* PickDestination()
	Choose a destination for the tactical move, based on aggressiveness and the tactical
	situation. Make sure destination is reachable
	*/
	function PickDestination()
	{
		local vector pickdir, enemydir, enemyPart, Y;
		local float strafeSize;

		if ( Pawn == None )
		{
			warn(self$" Tactical move pick destination with no pawn");
			return;
		}
		bChangeDir = false;
		if ( Pawn.PhysicsVolume.bWaterVolume && !Pawn.bCanSwim && Pawn.bCanFly)
		{
			Destination = Pawn.Location + 75 * (VRand() + vect(0,0,1));
			Destination.Z += 100;
			return;
		}

		enemydir = Normal(Enemy.Location - Pawn.Location);
		Y = (enemydir Cross vect(0,0,1));
		if ( Pawn.Physics == PHYS_Walking )
		{
			Y.Z = 0;
			enemydir.Z = 0;
		}
		else 
			enemydir.Z = FMax(0,enemydir.Z);
			
		strafeSize = FClamp(((2 * Aggression + 1) * FRand() - 0.65),-0.7,0.7);
		if ( Squad.MustKeepEnemy(Enemy) )
			strafeSize = FMax(0.4 * FRand() - 0.2,strafeSize);
		enemyPart = enemydir * strafeSize;
		strafeSize = FMax(0.0, 1 - Abs(strafeSize));
		pickdir = strafeSize * Y;
		if ( bStrafeDir )
			pickdir *= -1;
		bStrafeDir = !bStrafeDir;
		
		if ( EngageDirection(enemyPart + pickdir, false) )
			return;
	
		if ( EngageDirection(enemyPart - pickdir,false) )
			return;
			
		bForcedDirection = true;
		StartTacticalTime = Level.TimeSeconds;
		EngageDirection(EnemyPart + PickDir, true);
	}

	function bool EngageDirection(vector StrafeDir, bool bForced)
	{
		local actor HitActor;
		local vector HitLocation, collspec, MinDest, HitNormal;
		local float  StrafeDist;

		StrafeDist = GetStrafeDist();

		// successfully engage direction if can trace out and down
		MinDest = Pawn.Location + StrafeDist * StrafeDir;

		if ( !bForced )
		{
			collSpec = Pawn.GetCollisionExtent();
			collSpec.Z = FMax(6, Pawn.CollisionHeight - Pawn.CollisionRadius);

			HitActor = Trace(HitLocation, HitNormal, MinDest, Pawn.Location, false, collSpec);
			if ( HitActor != None )
				return false;

			if ( Pawn.Physics == PHYS_Walking )
			{
				collSpec.X = FMin(14, 0.5 * Pawn.CollisionRadius);
				collSpec.Y = collSpec.X;
				HitActor = Trace(HitLocation, HitNormal, minDest - (Pawn.CollisionRadius + MAXSTEPHEIGHT) * vect(0,0,1), minDest, false, collSpec);
				if ( HitActor == None )
				{
					HitNormal = -1 * StrafeDir;
					return false;
				}
			}
		
			if ( (Physics != PHYS_Falling) && ((bJumpy && (FRand() < 0.8)) || (Pawn.Weapon.SplashJump() && ProficientWithWeapon())
				&& (Enemy.Location.Z - Enemy.CollisionHeight <= Pawn.Location.Z + MAXSTEPHEIGHT - Pawn.CollisionHeight)) 
				&& !NeedToTurn(Enemy.Location) )
			{
				if ( Pawn.Weapon.SplashJump() )
					StopFiring();
				bNotifyApex = true;
				bTacticalDoubleJump = true; 
				// try jump move
				Pawn.SetPhysics(PHYS_Falling);
				Pawn.Velocity.Z = Pawn.JumpZ;
				Pawn.Acceleration = vect(0,0,0);
				Destination = MinDest;
				return true;
			}
		}
		Destination = MinDest + StrafeDir * (0.5 * StrafeDist 
											+ FMin(VSize(Enemy.Location - Pawn.Location), StrafeDist * (FRand() + FRand())));  
		return true;
	}

	event NotifyJumpApex()
	{
		if ( bTacticalDoubleJump && !bPendingDoubleJump && (FRand() < 0.35) && (Skill > 2 + 5 * FRand()) )
		{
			bTacticalDoubleJump = false;
			bNotifyApex = true;
			bPendingDoubleJump = true;
		}
		else if ( CanAttack(Enemy) )
			TimedFireWeaponAtEnemy();
		Global.NotifyJumpApex();
	}

	function BeginState()
	{
		bForcedDirection = false;
		if ( Skill < 4 ) 
			Pawn.MaxDesiredSpeed = 0.4 + 0.08 * skill;
		MinHitWall += 0.15;
		Pawn.bAvoidLedges = true;
		Pawn.bStopAtLedges = true;
		Pawn.bCanJump = false;
		bAdjustFromWalls = false;
		Pawn.bWantsToCrouch = Squad.CautiousAdvance(self);
	}
	
	function EndState()
	{
		if ( !bPendingDoubleJump )
			bNotifyApex = false;
		bAdjustFromWalls = true;
		if ( Pawn == None )
			return;
		SetMaxDesiredSpeed();
		Pawn.bAvoidLedges = false;
		Pawn.bStopAtLedges = false;
		MinHitWall -= 0.15;
		if (Pawn.JumpZ > 0)
			Pawn.bCanJump = true;
	}

Begin:
	//log("Miket: TacticalMove state start");
	StartState();
	Sleep(0.1);

	if (Pawn.Physics == PHYS_Falling)
	{
		Focus = Enemy;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	PickDestination();

DoMove:
	if ( Pawn.Weapon.FocusOnLeader(false) )
		MoveTo(Destination, Squad.SquadLeader, ShouldWalk());
	else if ( !Pawn.bCanStrafe )
	{ 
		StopFiring();
		MoveTo(Destination,,ShouldWalk());
	}
	else
	{
DoStrafeMove:
	MoveTo(Destination, Enemy, ShouldWalk());
	}

	// If stuck, wait a little while.
	if (VSize(Destination - Pawn.Location) > MINSTRAFEDIST)
		Sleep(0.5);

	if ( bForcedDirection && (Level.TimeSeconds - StartTacticalTime < 0.2) )
	{
		if ( Skill > 2 + 3 * FRand() )
		{
			bMustCharge = true;
			WhatToDoNext(51);
		}
		GoalString = "RangedAttack from failed tactical";
		DoRangedAttackOn(Enemy);
	}
	if ( (Enemy == None) || EnemyVisible() || !FastTrace(Enemy.Location, LastSeeingPos) || Pawn.Weapon.bMeleeWeapon )
		Goto('FinishedStrafe');
	//CheckIfShouldCrouch(LastSeeingPos,Enemy.Location, 0.5);

RecoverEnemy:
	GoalString = "Recover Enemy";
	HidingSpot = Pawn.Location;
	StopFiring();
	Sleep(0.1 + 0.2 * FRand());
	Destination = LastSeeingPos + 4 * Pawn.CollisionRadius * Normal(LastSeeingPos - Pawn.Location);
	MoveTo(Destination, Enemy, ShouldWalk());

	if ( FireWeaponAt(Enemy) )
	{
		Pawn.Acceleration = vect(0,0,0);
		if ( Pawn.Weapon.SplashDamage() )
		{
			StopFiring();
			Sleep(0.05);
		}
		else
			Sleep(0.1 + 0.3 * FRand() + 0.06 * (7 - FMin(7,Skill)));
		if ( (FRand() + 0.3 > Aggression) )
		{
			Enable('EnemyNotVisible');
			Destination = HidingSpot + 4 * Pawn.CollisionRadius * Normal(HidingSpot - Pawn.Location);
			Goto('DoMove');
		}
	}
FinishedStrafe:
	WhatToDoNext(21);
	if ( bSoaking )
		SoakStop("STUCK IN TACTICAL MOVE!");
}

function bool IsHunting()
{
	return false;
}



// There's some bizzaro problem where the script sometimes can't find this function even though
// its only called once in the state that its defined in.
function bool FindViewSpot()
{
	return false;
}


state Hunting extends MoveToGoalWithEnemy
{
ignores EnemyNotVisible; 

	/* MayFall() called by] engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting 
		bCanJump to false) to avoid fall
	*/
	function bool IsHunting()
	{
		return true;
	}

	function MayFall()
	{
		Pawn.bCanJump = ( (MoveTarget == None) || (MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Pickup') );
	}

	function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{	
		Super.NotifyTakeHit(InstigatedBy,HitLocation, Damage,DamageType,Momentum);
		if ( (Pawn.Health > 0) && (Damage > 0) )
			bFrustrated = true;
	}

	function SeePlayer(Pawn SeenPlayer)
	{
		if ( SeenPlayer == Enemy )
		{
			VisibleEnemy = Enemy;
			EnemyVisibilityTime = Level.TimeSeconds;
			bEnemyIsVisible = true;
			BlockedPath = None;
			Focus = Enemy;
			WhatToDoNext(22);
		}
		else
			Global.SeePlayer(SeenPlayer);
	} 

	function Timer()
	{
		SetCombatTimer();
		StopFiring();
	}

	function PickDestination()
	{
		local vector nextSpot, ViewSpot,Dir;
		local float posZ;
		local bool bCanSeeLastSeen;
		local int i;

		// If no enemy, or I should see him but don't, then give up	
		if ( (Enemy == None) || (Enemy.Health <= 0) )
		{
			LoseEnemy();
			WhatToDoNext(23);
			return;
		}

		if ( Pawn.JumpZ > 0 )
			Pawn.bCanJump = true;
		
		if ( ActorReachable(Enemy) )
		{
			BlockedPath = None;
			if ( (LostContact(5) && (((Enemy.Location - Pawn.Location) Dot vector(Pawn.Rotation)) < 0)) 
				&& LoseEnemy() )
			{
				WhatToDoNext(24);
				return;
			}
			Destination = Enemy.Location;
			MoveTarget = None;
			return;
		}

		ViewSpot = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1);
		bCanSeeLastSeen = bEnemyInfoValid && FastTrace(LastSeenPos, ViewSpot);

		if ( Squad.BeDevious() )
		{
			if ( BlockedPath == None )
			{
				// block the first path visible to the enemy
				if ( FindPathToActor(Enemy,false) != None )
				{
					for ( i=0; i<16; i++ )
					{
						if ( NavigationPoint(RouteCache[i]) == None )
							break;
						else if ( Enemy.Controller.LineOfSightTo(RouteCache[i]) )
						{
							BlockedPath = NavigationPoint(RouteCache[i]);
							break;
						}
					}
				}
				else if ( CanStakeOut() )
				{
					GoalString = "Stakeout from hunt";
					DoStakeOut();
					return;
				}
				else if ( LoseEnemy() )
				{
					WhatToDoNext(25);
					return;
				}
				else 
				{
					GoalString = "Retreat from hunt";
					DoRetreat();
					return;
				}
			}
			// control path weights
			if ( BlockedPath != None )
				BlockedPath.TransientCost = 1500;
		}
		if ( FindBestPathToward(Enemy, true,true) )
			return;

		if ( bSoaking && (Physics != PHYS_Falling) )
			SoakStop("COULDN'T FIND PATH TO ENEMY "$Enemy);
		
		MoveTarget = None;
		if ( !bEnemyInfoValid && LoseEnemy() )
		{
			WhatToDoNext(26);
			return;
		}

		Destination = LastSeeingPos;
		bEnemyInfoValid = false;
		if ( FastTrace(Enemy.Location, ViewSpot) 
			&& VSize(Pawn.Location - Destination) > Pawn.CollisionRadius )
			{
				SeePlayer(Enemy);
				return;
			}

		posZ = LastSeenPos.Z + Pawn.CollisionHeight - Enemy.CollisionHeight;
		nextSpot = LastSeenPos - Normal(Enemy.Velocity) * Pawn.CollisionRadius;
		nextSpot.Z = posZ;
		if ( FastTrace(nextSpot, ViewSpot) )
			Destination = nextSpot;
		else if ( bCanSeeLastSeen )
		{
			Dir = Pawn.Location - LastSeenPos;
			Dir.Z = 0;
			if ( VSize(Dir) < Pawn.CollisionRadius )
			{
				GoalString = "Stakeout 3 from hunt";
				DoStakeOut();
				return;
			}
			Destination = LastSeenPos;
		}
		else
		{
			Destination = LastSeenPos;
			if ( !FastTrace(LastSeenPos, ViewSpot) )
			{
				// check if could adjust and see it
				if ( PickWallAdjust(Normal(LastSeenPos - ViewSpot)) || FindViewSpot() )
				{
					if ( Pawn.Physics == PHYS_Falling )
						SetFall();
					else
					{
						Focus = Enemy;
						GotoState('Hunting', 'AdjustFromWall');
					}
				}
				else
				{
					GoalString = "Stakeout 2 from hunt";
					DoStakeOut();
					return;
				}
			}
		}
	}	

	function bool FindViewSpot()
	{
		local vector X,Y,Z;
		local bool bAlwaysTry;

		GetAxes(Rotation,X,Y,Z);

		// try left and right
		// if frustrated, always move if possible
		bAlwaysTry = bFrustrated;
		bFrustrated = false;
		
		if ( FastTrace(Enemy.Location, Pawn.Location + 2 * Y * Pawn.CollisionRadius) )
		{
			Destination = Pawn.Location + 2.5 * Y * Pawn.CollisionRadius;
			return true;
		}

		if ( FastTrace(Enemy.Location, Pawn.Location - 2 * Y * Pawn.CollisionRadius) )
		{
			Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
			return true;
		}
		if ( bAlwaysTry )
		{
			if ( FRand() < 0.5 )
				Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
			else
				Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
			return true;
		}

		return false;
	}

	function BeginState()
	{
		Pawn.bWantsToCrouch = Squad.CautiousAdvance(self);
		SetAlertness(0.5);
	}

	function EndState()
	{
		if ( (Pawn != None) && (Pawn.JumpZ > 0) )
			Pawn.bCanJump = true;
	}

AdjustFromWall:
	MoveTo(Destination, MoveTarget, ShouldWalk());

Begin:
	//log("Miket: Hunting state start");
	StartState();
	Sleep(0.1);

	WaitForLanding();
	if ( CanSee(Enemy) )
		SeePlayer(Enemy);
	PickDestination();
SpecialNavig:
	if (MoveTarget == None)
		MoveTo(Destination,,ShouldWalk());
	else
		MoveToward(MoveTarget,FaceActor(10),,(FRand() < 0.75) && ShouldStrafeTo(MoveTarget), ShouldWalk());

	WhatToDoNext(27);
	if ( bSoaking )
		SoakStop("STUCK IN HUNTING!");
}

state StakeOut
{
ignores EnemyNotVisible; 

	function bool CanAttack(Actor Other)
	{
		return true;
	}

	function bool Stopped()
	{
		return true;
	}

	event SeePlayer(Pawn SeenPlayer)
	{
		if (AttitudeTo(SeenPlayer) >= Attitude_Ignore)
			return;

		if ( SeenPlayer == Enemy )
		{
			VisibleEnemy = Enemy;
			EnemyVisibilityTime = Level.TimeSeconds;
			bEnemyIsVisible = true;
			if ( !Pawn.Weapon.FocusOnLeader(false) && (FRand() < 0.5) )
			{
				Focus = Enemy;
				FireWeaponAt(Enemy);
			}
			WhatToDoNext(28);
		}
		else if ( SetEnemy(SeenPlayer) )
		{
			if ( Enemy == SeenPlayer )
			{	
				VisibleEnemy = Enemy;
				EnemyVisibilityTime = Level.TimeSeconds;
				bEnemyIsVisible = true;
			}
			WhatToDoNext(29);
		}
	}
	/* DoStakeOut()
	called by ChooseAttackMode - if called in this state, means stake out twice in a row
	*/
	function DoStakeOut()
	{
		SetFocus();
		if ( (FRand() < 0.3) || !FastTrace(FocalPoint + vect(0,0,0.9) * Enemy.CollisionHeight, Pawn.Location + vect(0,0,0.8) * Pawn.CollisionHeight) )
			FindNewStakeOutDir();
		GotoState('StakeOut','Begin');
	}

	function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{	
		Super.NotifyTakeHit(InstigatedBy,HitLocation, Damage,DamageType,Momentum);
		if ( (Pawn.Health > 0) && (Damage > 0) )
		{
			bFrustrated = true;
			if ( InstigatedBy == Enemy )
				AcquireTime = Level.TimeSeconds;
			WhatToDoNext(30);
		}
	}
	
	function Timer()
	{
		enable('NotifyBump');
		SetCombatTimer();
	}

	function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
	{
		local vector FireSpot;
		local actor HitActor;
		local vector HitLocation, HitNormal;
				
		FireSpot = FocalPoint;
			 
		HitActor = Trace(HitLocation, HitNormal, FireSpot, ProjStart, false);
		if( HitActor != None ) 
		{
			FireSpot += 2 * Enemy.CollisionHeight * HitNormal;
			if ( !FastTrace(FireSpot, ProjStart) )
			{
				FireSpot = FocalPoint;
				StopFiring();
			}
		}
		
		SetRotation(Rotator(FireSpot - ProjStart));
		return Rotation;
	}
	
	function FindNewStakeOutDir()
	{
		local NavigationPoint N, Best;
		local vector Dir, EnemyDir;
		local float Dist, BestVal, Val;

		EnemyDir = Normal(Enemy.Location - Pawn.Location);
		for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		{
			Dir = N.Location - Pawn.Location;
			Dist = VSize(Dir);
			if ( (Dist < MAXSTAKEOUTDIST) && (Dist > MINSTRAFEDIST) )
			{
				Val = (EnemyDir Dot Dir/Dist);
				if ( Level.Game.bTeamgame )
					Val += FRand();
				if ( (Val > BestVal) && LineOfSightTo(N) )
				{
					BestVal = Val;
					Best = N;
				}
			}
		}
		if ( Best != None )
			FocalPoint = Best.Location + 0.5 * Pawn.CollisionHeight * vect(0,0,1);			
	}

	function SetFocus()
	{
		if ( Pawn.Weapon.FocusOnLeader(false) )
			Focus = Squad.SquadLeader.Pawn;
		else if ( bEnemyInfoValid )
			FocalPoint = LastSeenPos;
		else
			FocalPoint = Enemy.Location;
	}
		
	function BeginState()
	{
		StopStartTime = Level.TimeSeconds;
		Pawn.Acceleration = vect(0,0,0);
		Pawn.bCanJump = false;
		SetAlertness(0.5);
		SetFocus();
		if ( !bEnemyInfoValid || !ClearShot(FocalPoint,false) || ((Level.TimeSeconds - LastSeenTime > 6) && (FRand() < 0.5)) )
			FindNewStakeOutDir();
	}

	function EndState()
	{
		if ( (Pawn != None) && (Pawn.JumpZ > 0) )
			Pawn.bCanJump = true;
	}

Begin:
	//log("Miket: StakeOut state start");
	Pawn.Acceleration = vect(0,0,0);
	if ( Pawn.Weapon.FocusOnLeader(false) )
		Focus = Squad.SquadLeader.Pawn;
	else
		Focus = None;
	CheckIfShouldCrouch(Pawn.Location,FocalPoint, 1);
	FinishRotation();
	if ( Pawn.Weapon.FocusOnLeader(false) )
	{
		Focus = Squad.SquadLeader.Pawn;
		FireWeaponAt(Squad.SquadLeader.Pawn);
	}
	else if ( (Pawn.Weapon != None) && !Pawn.Weapon.bMeleeWeapon && (FRand() < 0.5) && (VSize(Enemy.Location - FocalPoint) < 150) 
		 && (Level.TimeSeconds - LastSeenTime < 4) && ClearShot(FocalPoint,true) )
	{
		FireWeaponAt(Enemy);
	}
	else
		StopFiring();
	Sleep(1 + FRand());
	// check if uncrouching would help
	if ( Pawn.bIsCrouched 
		&& !FastTrace(FocalPoint, Pawn.Location + Pawn.EyeHeight * vect(0,0,1))
		&& FastTrace(FocalPoint, Pawn.Location + (Pawn.Default.EyeHeight + Pawn.Default.CollisionHeight - Pawn.CollisionHeight) * vect(0,0,1)) )
	{
		Pawn.bWantsToCrouch = false;
		Sleep(0.15 + 0.05 * (1 + FRand()) * (10 - skill));
	}
	WhatToDoNext(31);
	if ( bSoaking )
		SoakStop("STUCK IN STAKEOUT!");
}

function bool Stopped()
{
	return bPreparingMove;
}

state RangedAttack
{
ignores SeePlayer, HearNoise, Bump;

	function bool Stopped()
	{
		return true;
	}

	function CancelCampFor(Controller C)
	{
		DoTacticalMove();
	}

	function StopFiring()
	{
		Global.StopFiring();
		if ( bHasFired )
		{
			if ( IsSniping() )
				Pawn.bWantsToCrouch = (Skill > 2);
			else
			{
				bHasFired = false;
				WhatToDoNext(32);
			}
		}
	}

	function EnemyNotVisible()
	{
		//let attack animation complete
		if ( Target == Enemy )
			WhatToDoNext(33);
	}

	function Timer()
	{
		if ( Pawn.Weapon.bMeleeWeapon )
		{
			SetCombatTimer();
			StopFiring();
			WhatToDoNext(34);
		}
		else
			TimedFireWeaponAtEnemy();
	}

	function DoRangedAttackOn(Actor A)
	{
		if ( Pawn.Weapon.FocusOnLeader(false) )
			Target = Squad.SquadLeader.Pawn;
		else 
			Target = A;
		GotoState('RangedAttack');
	}	
	
	function BeginState()
	{
		StopStartTime = Level.TimeSeconds;
		bHasFired = false;
		Pawn.Acceleration = vect(0,0,0); //stop
		if ( Pawn.Weapon.FocusOnLeader(false) )
			Target = Squad.SquadLeader.Pawn;
		else if ( Target == None )
			Target = Enemy;
		if ( Target == None )
			log(GetHumanReadableName()$" no target in ranged attack");
	}

Begin:
	//log("Miket: RangedAttack state start");
	StartState();

	bHasFired = false;
	if ( Pawn.Weapon.bMeleeWeapon )
		SwitchToBestWeapon();
	GoalString = "Ranged attack";
	Focus = Target;
	Sleep(0.0);
	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	if ( NeedToTurn(Target.Location) )
	{
		Focus = Target;
		FinishRotation();
	}
	bHasFired = true;
	if ( Target == Enemy )
		TimedFireWeaponAtEnemy();
	else
		FireWeaponAt(Target);
	Sleep(0.1);
	if ( Pawn.Weapon.bMeleeWeapon || (Target == None) || (Target != Enemy) )
		WhatToDoNext(35);
	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	Focus = Target;
	Sleep(FMax(Pawn.Weapon.RangedAttackTime(),0.2 + (0.5 + 0.5 * FRand()) * 0.4 * (7 - Skill))); 
	WhatToDoNext(36);
	if ( bSoaking )
		SoakStop("STUCK IN RANGEDATTACK!");
}

state Dead
{
ignores SeePlayer, EnemyNotVisible, HearNoise, ReceiveWarning, NotifyLanded, NotifyPhysicsVolumeChange,
		NotifyHeadVolumeChange,NotifyLanded,NotifyHitWall,NotifyBump;

	function WhatToDoNext(byte CallingByte)
	{
		//log(self$" WhatToDoNext while dead CALLED BY "$CallingByte);
	}

	function Celebrate()
	{
		log(self$" Celebrate while dead");
	}

	function SetAttractionState()
	{
		log(self$" SetAttractionState while dead");
	}

	function EnemyChanged(bool bNewEnemyVisible)
	{
		log(self$" EnemyChanged while dead");
	}

	function WanderOrCamp(bool bMayCrouch)
	{
		log(self$" WanderOrCamp while dead");
	}

	function Timer() {}

	function BeginState()
	{
		if ( Level.Game.TooManyBots(self) )
		{
			Destroy();
			return;
		}
		if ( (GoalScript != None) && (HoldSpot(GoalScript) == None) )
			FreeScript();
		if ( NavigationPoint(MoveTarget) != None )
			NavigationPoint(MoveTarget).FearCost = 2 * NavigationPoint(MoveTarget).FearCost + 600;
		//Enemy = None;
		SetEnemy(None);
		bFrustrated = false;
		BlockedPath = None;
		bInitLifeMessage = false;
		bReachedGatherPoint = false;
		bFinalStretch = false;
		bWasNearObjective = false;
		bPreparingMove = false;
		bEnemyEngaged = false;
		bPursuingFlag = false;
	}
	
Begin:
	//log("Miket: Dead state start");
	if ( Level.Game.bGameEnded )
		GotoState('GameEnded');
	Sleep(0.2);
TryAgain:
	if ( UnrealMPGameInfo(Level.Game) == None )
		destroy();
	else
	{
		Sleep(0.25 + UnrealMPGameInfo(Level.Game).SpawnWait(self));
		LastRespawnTime = Level.TimeSeconds;
		Level.Game.ReStartPlayer(self, false);
		Goto('TryAgain');
	}
/*
MPStart:
	Sleep(0.75 + FRand());
	Level.Game.ReStartPlayer(self);
	Goto('TryAgain');
*/
}

state FindAir
{
ignores SeePlayer, HearNoise, Bump;

	function bool NotifyHeadVolumeChange(PhysicsVolume NewHeadVolume)
	{
		Global.NotifyHeadVolumeChange(newHeadVolume);
		if ( !newHeadVolume.bWaterVolume )
			WhatToDoNext(37);
		return false;
	}

	function bool NotifyHitWall(vector HitNormal, actor Wall)
	{
		//change directions
		Destination = MINSTRAFEDIST * (Normal(Destination - Pawn.Location) + HitNormal);
		return true;
	}

	function Timer() 
	{
		if ( (Enemy != None) && EnemyVisible() )
			TimedFireWeaponAtEnemy();
		else
			SetCombatTimer();
	}

	function EnemyNotVisible() {}

/* PickDestination()
*/
	function PickDestination(bool bNoCharge)
	{
		Destination = VRand();
		Destination.Z = 1;
		Destination = Pawn.Location + MINSTRAFEDIST * Destination;				
	}

	function BeginState()
	{
		Pawn.bWantsToCrouch = false; 
		bAdjustFromWalls = false;
	}

	function EndState()
	{
		bAdjustFromWalls = true;
	}

Begin:
	//log("Miket: FindAir state start");
	PickDestination(false);

DoMove:	
	if ( Enemy == None )
		MoveTo(Destination,,ShouldWalk());
	else
		MoveTo(Destination, Enemy, ShouldWalk());

	WhatToDoNext(38);
}

function SetEnemyReaction(int AlertnessLevel)
{
	ScriptedCombat = FOLLOWSCRIPT_IgnoreEnemies;
	if ( AlertnessLevel == 0 )
	{
		ScriptedCombat = FOLLOWSCRIPT_IgnoreAllStimuli;
		bGodMode = true;
	}
	else
		bGodMode = false;

	if ( AlertnessLevel < 2 )
	{
		Disable('HearNoise');
		Disable('SeePlayer');
		Disable('SeeMonster');
		Disable('NotifyBump');
	}
	else
	{
		Enable('HearNoise');
		Enable('SeePlayer');
		Enable('SeeMonster');
		Enable('NotifyBump');
		if ( AlertnessLevel == 2 )
			ScriptedCombat = FOLLOWSCRIPT_StayOnScript;
		else
			ScriptedCombat = FOLLOWSCRIPT_LeaveScriptForCombat;
	}
}

state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, NotifyBump, HitWall, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, Falling, TakeDamage, ReceiveWarning;

	function SwitchToBestWeapon() {}

	function WhatToDoNext(byte CallingByte)
	{
		log(self$" WhatToDoNext while gameended CALLED BY "$CallingByte);
	}

	function Celebrate()
	{
		log(self$" Celebrate while gameended");
	}

	function SetAttractionState()
	{
		log(self$" SetAttractionState while gameended");
	}

	function EnemyChanged(bool bNewEnemyVisible)
	{
		log(self$" EnemyChanged while gameended");
	}

	function WanderOrCamp(bool bMayCrouch)
	{
		log(self$" WanderOrCamp while gameended");
	}
	
	function Timer()
	{
		if ( (DeathMatch(Level.Game) != None) && (DeathMatch(Level.Game).EndGameFocus == Pawn) && (Pawn != None) )
		{
			Pawn.PlayVictoryAnimation();
			//UnrealPawn(Pawn).bKeepTaunting = true;
		}
	}
	
	function BeginState()
	{
		Super.BeginState();
		
		if ( (DeathMatch(Level.Game) != None) && (DeathMatch(Level.Game).EndGameFocus == Pawn) && (Pawn != None) )
			SetTimer(3.0, false);
	}
}

function SetNewScript(ScriptedSequence NewScript)
{
	Super.SetNewScript(NewScript);
	GoalScript = UnrealScriptedSequence(NewScript);
	if ( GoalScript != None )
	{
		if ( FRand() < GoalScript.EnemyAcquisitionScriptProbability )
			EnemyAcquisitionScript = GoalScript.EnemyAcquisitionScript;
		else
			EnemyAcquisitionScript = None;
	}
}

function bool ScriptingOverridesAI()
{
	return ( (GoalScript != None) && (ScriptedCombat <= FOLLOWSCRIPT_StayOnScript) );
}

function bool ShouldPerformScript()
{
	if ( GoalScript != None )
	{
		if ( (Enemy != None) && (ScriptedCombat == FOLLOWSCRIPT_LeaveScriptForCombat) )
		{
			SequenceScript = None;
			ClearScript();
			return false;
		}
		if ( SequenceScript != GoalScript )
			SetNewScript(GoalScript);
		GotoState('Scripting','Begin');
		return true;
	}
	return false;
}

State Scripting
{
	ignores EnemyNotVisible;

	function Restart() {}

	function Timer()
	{
		if (CurrentAction == None)
		{
			AbortScript();
			return;
		}
		Super.Timer();
		enable('NotifyBump');
	}

	function CompleteAction()
	{
		//ActionNum++;
		//WhatToDoNext(39);
	}

	/* UnPossess()
	scripted sequence is over - return control to PendingController
	*/
	function LeaveScripting()
	{
		if ( (SequenceScript == GoalScript) && (HoldSpot(GoalScript) == None) )
		{
			FreeScript();
		Global.WhatToDoNext(40);
	}
		else
			WanderOrCamp(true);	
	}

	function EndState()
	{
		Super.EndState();
		SetCombatTimer();
		if ( (Pawn != None) && (Pawn.Health > 0) )
			Pawn.bPhysicsAnimUpdate = true;
	}
	
	function ClearPathFor(Controller C)
	{
		CancelCampFor(C);
	}

	function CancelCampFor(Controller C)
	{
		if ( Velocity == vect(0,0,0) )
			DirectedWander(Normal(Pawn.Location - C.Pawn.Location));
	}

	function AbortScript()
	{
		if ( (SequenceScript == GoalScript) && (HoldSpot(GoalScript) == None) )
			FreeScript();
		WanderOrCamp(true);
	}
	
	function SetMoveTarget()
	{
		Super.SetMoveTarget();
		if ( Pawn.ReachedDestination(Movetarget) )
		{
			ActionNum++;
			GotoState('Scripting','Begin');
			return;
		}
		if ( (Enemy != None) && (ScriptedCombat == FOLLOWSCRIPT_StayOnScript) )
			GotoState('Fallback');
	}

	function MayShootAtEnemy()
	{
		if ( Enemy != None )
		{
			Target = Enemy;
			GotoState('Scripting','ScriptedRangedAttack'); 
		}
	}

ScriptedRangedAttack:
	GoalString = "Scripted Ranged Attack";
	Focus = Enemy;
	WaitToSeeEnemy();
	if ( Target != None )
		FireWeaponAt(Target);
}

State WaitingForLanding
{
	function bool DoWaitForLanding()
	{
		if ( bJustLanded )
			return false;
		BeginState();
		return true;
	}
	
	function bool NotifyLanded(vector HitNormal)
	{
		bJustLanded = true;
		Super.NotifyLanded(HitNormal);
		WhatToDoNext(50);
		return false;
	}	
	
	function Timer()
	{
		if ( Focus == Enemy )
			TimedFireWeaponAtEnemy();
		else
			SetCombatTimer();
	}

	function BeginState()
	{
		bJustLanded = false;
		if ( (MoveTarget != None) && ((Enemy == None) ||(Focus != Enemy)) )
			FaceActor(1.5);
		if ( (Enemy == None) || (Focus != Enemy) )
			StopFiring();
	}
}

State Testing
{
ignores SeePlayer, EnemyNotVisible, HearNoise, ReceiveWarning, NotifyLanded, NotifyPhysicsVolumeChange,
		NotifyHeadVolumeChange,NotifyLanded,NotifyHitWall,NotifyBump;

	function WhatToDoNext(byte CallingByte)
	{
	}

	function Celebrate()
	{
		log(self$" Celebrate while dead");
	}

	function SetAttractionState()
	{
		log(self$" SetAttractionState while dead");
	}

	function EnemyChanged(bool bNewEnemyVisible)
	{
		log(self$" EnemyChanged while dead");
	}

	function WanderOrCamp(bool bMayCrouch)
	{
		log(self$" WanderOrCamp while dead");
	}

	function bool AvoidCertainDeath()
	{
		Pawn.SetLocation(TestStart.Location);
		MoveTimer = -1.0;
		return true;
	}

	function Timer() {}

	function FindNextMoveTarget()
	{
		local NavigationPoint N;
		local bool bFoundStart;
		local int i;
		
		bFoundStart = ( TestStart == None );
		Pawn.Health = 100;
		for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		{
			if ( N == TestStart )
				bFoundStart = true;
			if ( bFoundStart && (TestPath < N.PathList.Length) )
			{
				for ( i=TestPath; i<N.PathList.length; i++ )
					if ( (JumpSpot(N.PathList[i].End) != None) && N.PathList[i].bForced )
					{
						log("Test translocation from "$N$" to "$(N.PathList[i].End));
						Pawn.SetLocation(N.Location + (Pawn.CollisionHeight - N.CollisionHeight) * vect(0,0,1));
						Pawn.Anchor = N;
						TestStart = N;
						TestPath = i+1;
						MoveTarget = N.PathList[i].End;
						JumpSpot(N.PathList[i].End).bOnlyTranslocator = true;
						ClientSetRotation(rotator(MoveTarget.Location - Pawn.Location));
						return;
					}
			}
			if ( N == TestStart )
				Testpath = 0;
		}
		TestStart = None;
		TestPath = 0;
		if ( bSingleTestSection )
			GotoState('Testing','AllFinished');
		else
			GotoState('Testing','Finished');
	}

	function FindNextJumpTarget()
	{
		local NavigationPoint N;
		local bool bFoundStart;
		local int i;
		
		bFoundStart = ( TestStart == None );
		Pawn.Health = 100;
		for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		{
			if ( N == TestStart )
				bFoundStart = true;
			if ( bFoundStart && (JumpPad(N) == None) && (TestPath < N.PathList.Length) )
			{
				for ( i=TestPath; i<N.PathList.length; i++ )
					if ( (JumpSpot(N.PathList[i].End) != None) && N.PathList[i].bForced )
					{
						JumpSpot(N.PathList[i].End).bOnlyTranslocator = JumpSpot(N.PathList[i].End).bRealOnlyTranslocator;
						if ( (JumpSpot(N.PathList[i].End).SpecialCost(Pawn, N.PathList[i]) < 1000000) )
 						{
							log("Test "$GoalString$" from "$N$" to "$(N.PathList[i].End));
							Pawn.SetLocation(N.Location + (Pawn.CollisionHeight - N.CollisionHeight) * vect(0,0,1));
							Pawn.Anchor = N;
							TestStart = N;
							TestPath = i+1;
							MoveTarget = N.PathList[i].End;
							ClientSetRotation(rotator(MoveTarget.Location - Pawn.Location));
							return;
						}
					}
			}
			if ( N == TestStart )
				TestPath = 0;
		}
		TestStart = None;
		TestPath = 0;
		if ( bSingleTestSection )
			GotoState('Testing','AllFinished');
		else
			GotoState('Testing',TestLabel);
	}

	function SetLowGrav(bool bSet)
	{
		local PhysicsVolume V;
		
		if ( bSet )
		{
			ForEach AllActors(class'PhysicsVolume', V)
				V.Gravity.Z = FMax(V.Gravity.Z,-300);
		}
		else
		{
			ForEach AllActors(class'PhysicsVolume', V)
				V.Gravity.Z = V.Default.Gravity.Z;
		}
	}
	
	function EndState()
	{
		log(self$" leaving test state");
	}
		
	function BeginState()
	{
		bHasImpactHammer = false;
		bAllowedToImpactJump = false;
		log(self$" entering test state");
		SetTimer(0.0,false);
		Skill = 7;
	}
	
Begin:
	//log("Miket: Testing state start");
	if ( Pawn.Weapon == None )
	{
	    Pawn.PendingWeapon = Weapon(Pawn.FindInventoryType(class<Inventory>(DynamicLoadObject("XWeapons.Translauncher",class'class'))));
		Pawn.ChangedWeapon();
		Sleep(0.5);
	}
	bAllowedToTranslocate = true;
	bHasTranslocator = true;
	GoalString = "TRANSLOCATING";
	FindNextMoveTarget();
	Pawn.Acceleration = vect(0,0,0);
	MoveToward(MoveTarget,,,, ShouldWalk());

	if ( !Pawn.ReachedDestination(MoveTarget) )
		log("FAILED to reach "$MoveTarget);
	else if ( Pawn.Health < 100 )
		log("TOOK DAMAGE "$(100-Pawn.Health)$" but succeeded");
	else
		log("Success!");
	Goto('Begin');
Finished:
	if ( !bAllowedToImpactJump )
	{
	    Pawn.GiveWeapon("XWeapons.ShieldGun");
		bAllowedToImpactJump = true;
		Sleep(0.5);
	}
	TestLabel = 'FinishedJumping';
	bAllowedToTranslocate = false;
	bHasImpactHammer = true;
	bHasTranslocator = false;
	Pawn.bCanDoubleJump = true;
	GoalString = "DOUBLE/IMPACT JUMPING";
	FindNextJumpTarget();
	Pawn.Acceleration = vect(0,0,0);
	MoveToward(MoveTarget,,,, ShouldWalk());

	if ( !Pawn.ReachedDestination(MoveTarget) )
		log("FAILED to reach "$MoveTarget);
	else if ( Pawn.Health < 100 )
		log("TOOK DAMAGE "$(100-Pawn.Health)$" but succeeded");
	else
		log("Success!");
	Goto('Finished');

FinishedJumping:
	Pawn.bCanDoubleJump = true;
	Pawn.Health = 100;
	bHasImpactHammer = false;
	bAllowedToTranslocate = false;
	bHasTranslocator = false;
	bAllowedToImpactJump = false;
	TestLabel = 'FinishedComboJumping';
	Pawn.JumpZ = Pawn.Default.JumpZ * 1.5;
	Pawn.GroundSpeed = Pawn.Default.GroundSpeed * 1.4;
	GoalString = "COMBO JUMPING";
	FindNextJumpTarget();
	Pawn.Acceleration = vect(0,0,0);
	MoveToward(MoveTarget,,,, ShouldWalk());

	if ( !Pawn.ReachedDestination(MoveTarget) )
		log("FAILED to reach "$MoveTarget);
	else if ( Pawn.Health < 100 )
		log("TOOK DAMAGE "$(100-Pawn.Health)$" but succeeded");
	else
		log("Success!");
	Goto('FinishedJumping');
	
FinishedComboJumping:
	Pawn.bCanDoubleJump = true;
	TestLabel = 'AllFinished';
	bHasImpactHammer = false;
	bAllowedToTranslocate = false;
	bHasTranslocator = false;
	bAllowedToImpactJump = false;
	SetLowGrav(true);
	Pawn.GroundSpeed = Pawn.Default.GroundSpeed;
	Pawn.JumpZ = Pawn.Default.JumpZ;
	GoalString = "LOWGRAV JUMPING";
	FindNextJumpTarget();
	Pawn.Acceleration = vect(0,0,0);
	MoveToward(MoveTarget,,,, ShouldWalk());

	if ( !Pawn.ReachedDestination(MoveTarget) )
		log("FAILED to reach "$MoveTarget);
	else if ( Pawn.Health < 100 )
		log("TOOK DAMAGE "$(100-Pawn.Health)$" but succeeded");
	else
		log("Success!");
	Goto('FinishedComboJumping');
AllFinished:
	SetLowGrav(false);
	bSingleTestSection = false;
	Pawn.PlayVictoryAnimation();	
}


//
// ?, end changes
//////////////////////
defaultproperties
{
	bLeadTarget=true
	Aggressiveness=0.4
	LastAttractCheck=-10000
	BaseAggressiveness=0.4
	CombatStyle=0.2
	TranslocUse=1
	LastSearchTime=-10000
	ComboNames[0]="xGame.ComboSpeed"
	ComboNames[1]="xGame.ComboBerserk"
	ComboNames[2]="xGame.ComboDefensive"
	ComboNames[3]="xGame.ComboInvis"
	OrderNames[0]=Defend
	OrderNames[1]=Hold
	OrderNames[2]=attack
	OrderNames[3]=Follow
	OrderNames[4]=Freelance
	OrderNames[10]=attack
	OrderNames[11]=Defend
	FovAngle=85
	bIsPlayer=true
	OldMessageTime=-100
	PlayerReplicationInfoClass=Class'TeamPlayerReplicationInfo'
	RemoteRole=0
}