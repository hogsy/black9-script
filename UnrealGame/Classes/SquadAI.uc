//=============================================================================
// SquadAI.
// operational AI control for TeamGame
// 
//=============================================================================
class SquadAI extends ReplicationInfo;

var UnrealTeamInfo Team;
var Controller SquadLeader;
var TeamPlayerReplicationInfo LeaderPRI;
var SquadAI NextSquad;	// list of squads on a team
var GameObjective SquadObjective;
var int Size;
var AssaultPath AlternatePath;	// path to use for attacking base
var name AlternatePathTag;
var Bot SquadMembers;
var float GatherThreshold;
var localized string SupportString, DefendString, AttackString, HoldString, FreelanceString;
var localized string SupportStringTrailer;
var name CurrentOrders;
var Pawn Enemies[8];
var int MaxSquadSize;
var bool bFreelance;
var bool bFreelanceAttack;
var bool bFreelanceDefend;
var UnrealScriptedSequence FreelanceScripts;

var RestingFormation RestingFormation;
var class<RestingFormation> RestingFormationClass;

var Vehicle SquadVehicle;

replication
{
	reliable if ( Role == ROLE_Authority )
		LeaderPRI, CurrentOrders, SquadObjective, bFreelance;
}
	
function AssignCombo(Bot B)
{
	if ( (B.Enemy != None) && B.EnemyVisible() )
	{
		if ( CurrentOrders == 'Defend' )
			B.TryCombo("DMRandom");
		else
			B.TryCombo("Random");
	}
}

function bool AllowDetourTo(Bot B,NavigationPoint N)
{
	return true;
}

function RestingFormation GetRestingFormation()
{
	if ( RestingFormation == None )
		RestingFormation = spawn(RestingFormationClass,self);
	return RestingFormation;
}

function Destroyed()
{
	if ( Team != None )
		Team.AI.RemoveSquad(self);
	Super.Destroyed();
}

function bool AllowTranslocationBy(Bot B)
{
	return true;
}

function bool AllowImpactJumpBy(Bot B)
{
	return true;
}

function actor SetFacingActor(Bot B)
{
	return None;
}

/* GetFacingRotation()
return the direction the squad is moving towards its objective
*/
function rotator GetFacingRotation()
{
	local rotator Rot;
	// FIXME - use path to objective, rather than just direction

	if ( SquadObjective == None )
		Rot = SquadLeader.Rotation;
///////////////////////////////////
// ?,Taldren,
// 
//
	else if ( (Team != None) && (SquadObjective.DefenderTeamIndex == Team.TeamIndex) )
//
// ?, end changes
//////////////////////
		Rot.Yaw = Rand(65536);
	else if ( SquadLeader.Pawn != None )
		Rot = rotator(SquadObjective.Location - SquadLeader.Pawn.Location);
	else
		Rot.Yaw = Rand(65536);

	Rot.Pitch = 0;
	Rot.Roll = 0;
	return Rot;
}

function actor FormationCenter()
{
///////////////////////////////////
// ?,Taldren,
// 
//
	if ( (Team != None) && (SquadObjective != None) && (SquadObjective.DefenderTeamIndex == Team.TeamIndex) )
//
// ?, end changes
//////////////////////
		return SquadObjective;
	return SquadLeader.Pawn;
}

function Reset()
{
	local int i;

	for ( i=0; i<8; i++ )
		Enemies[i] = None;

	//FIXME - what about squad objectives?
	Super.Reset();
}

/* MergeEnemiesFrom()
Add squad S enemies to my list.
returns false if no enemies were added to my list
*/
function bool MergeEnemiesFrom(SquadAI S)
{
	local int i;
	local bool bNew, bAdd;

	if ( S == None )
		return false;
	for ( i=0; i<ArrayCount(Enemies); i++ )
	{
		if ( S.Enemies[i] != None )
			bAdd = AddEnemy(S.Enemies[i]);
		bNew = bNew || bAdd;
	}
	return bNew;
}

/* LostEnemy()
Bot lost track of enemy.  Change enemy for this bot, clear from list if no one can see it
*/
function bool LostEnemy(Bot B)
{
	local pawn Lost;
	local bool bFound;
	local Bot M;

	if ( (B.Enemy.Health <= 0) || (B.Enemy.Controller == None) )
	{
///////////////////////////////////
// ?,Taldren,
// 
//
		B.SetEnemy(None);
//
// ?, end changes
//////////////////////
		RemoveEnemy(B.Enemy);
		FindNewEnemyFor(B,false);
		return true;
	}
	
	if ( MustKeepEnemy(B.Enemy) )
		return false;
	Lost = B.Enemy;
///////////////////////////////////
// ?,Taldren,
// 
//
		B.SetEnemy(None);
//
// ?, end changes
//////////////////////

	for	( M=SquadMembers; M!=None; M=M.NextSquadMember )
		if ( (M.Enemy == Lost) && !M.LostContact(5) )
		{
			bFound = true;
			break;
		}

	if ( bFound )
///////////////////////////////////
// ?,Taldren,
// 
//
		if (B.IsEnemy(Lost))
			B.Enemy = Lost;
//
// ?, end changes
//////////////////////
	else
	{
		RemoveEnemy(Lost);
		FindNewEnemyFor(B,false);
	}
	return (B.Enemy != Lost);
}

function bool MustKeepEnemy(Pawn E)
{
	return false;
}

/* AddEnemy()
adds an enemy - returns false if enemy was already on list
*/
function bool AddEnemy(Pawn NewEnemy)
{
	local int i;
	local Bot M;
	local bool bCurrentEnemy;
	
	for ( i=0; i<ArrayCount(Enemies); i++ )
		if ( Enemies[i] == NewEnemy )
			return false;
	for ( i=0; i<ArrayCount(Enemies); i++ )
		if ( Enemies[i] == None )
		{
			Enemies[i] = NewEnemy;
			return true;
		}
	for ( i=0; i<ArrayCount(Enemies); i++ )
	{
		bCurrentEnemy = false;
		for	( M=SquadMembers; M!=None; M=M.NextSquadMember )
			if ( M.Enemy ==	Enemies[i] )
			{
				bCurrentEnemy = true;
				break;
			}
		if ( !bCurrentEnemy )
		{
			Enemies[i] = NewEnemy;
			return true;
		}
	}
	log("FAILED TO ADD ENEMY");
	return false;
}

function bool SetEnemy( Bot B, Pawn NewEnemy )
{
	local Bot M;
	local bool res;

///////////////////////////////////
// ?,Taldren,
// 
//
	if ( (NewEnemy == B.Enemy) || (NewEnemy == None) || NewEnemy.bAmbientCreature || (NewEnemy.Health <= 0)
		|| FriendlyToward(NewEnemy) )
//
// ?, end changes
//////////////////////
		return false;

	// add new enemy to enemy list - return if already there
	if ( !AddEnemy(NewEnemy) )
	{
		if (B.Enemy == None)
		{
			B.Enemy = NewEnemy;
			return true;
		}
		
		return false;
	}

	// reassess squad member enemies
	res = false;
	for	( M=SquadMembers; M!=None; M=M.NextSquadMember )
		res = FindNewEnemyFor(M,(M.Enemy !=None) && M.LineOfSightTo(M.Enemy)) || res;
	
	return res;
}


function byte PriorityObjective(Bot B)
{
	return 0;
}

function bool IsOnSquad(Controller C)
{
	if ( Bot(C) != None )
		return ( Bot(C).Squad == self );

	return ( C == SquadLeader );
}

function RemoveEnemy(Pawn E)
{
	local Bot B;
	local int i;
	
	for ( i=0; i<ArrayCount(Enemies); i++ )
		if ( Enemies[i] == E )
			Enemies[i] = None;

	if ( Level.Game.bGameEnded )
		return;
		
	for	( B=SquadMembers; B!=None; B=B.NextSquadMember )
		if ( B.Enemy == E )
		{
///////////////////////////////////
// ?,Taldren,
// 
//
			B.SetEnemy(None);
//
// ?, end changes
//////////////////////
			FindNewEnemyFor(B,false);
			if ( (B.Pawn != None) && (B.Enemy == None) )
			{
				if ( B.InLatentExecution(B.LATENT_MOVETOWARD) && (NavigationPoint(B.MoveTarget) != None) 
					&& !B.bPreparingMove )
					B.GotoState('Roaming');
				else
					B.WhatToDoNext(42);
			}
		}
}

function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn)
{
	local Bot B;

	if ( Killed == None )
		return;
		
	// if teammate killed, no need to update enemy list
	if ( (Team != None) && (Killed.PlayerReplicationInfo != None)
		&& (Killed.PlayerReplicationInfo.Team == Team) )
	{
		if ( IsOnSquad(Killed) )
		{
			// check if death was witnessed
			for	( B=SquadMembers; B!=None; B=B.NextSquadMember )
				if ( (B != Killed) && B.LineOfSightTo(KilledPawn) )
				{
					B.SendMessage(None, 'OTHER', B.GetMessageIndex('MANDOWN'), 10, 'TEAM'); 
					break;
				}
		}
		return;
	}
	RemoveEnemy(KilledPawn);

	B = Bot(Killer);
	if ( (B != None) && (B.Squad == self) && (B.Enemy == None) && (B.Pawn != None) && AllowTaunt(B) )
	{
		B.Target = KilledPawn;
		B.Celebrate();
	}
}

function bool FindNewEnemyFor(Bot B, bool bSeeEnemy)
{
	local int i;
	local Pawn BestEnemy, OldEnemy;
	local bool bSeeNew;
	local float BestThreat,NewThreat;

	if ( B.Pawn == None )
		return true;

	BestEnemy = B.Enemy;
	OldEnemy = B.Enemy;
	if ( BestEnemy != None )
	{
		if ( (BestEnemy.Health < 0) || (BestEnemy.Controller == None) )
		{
///////////////////////////////////
// ?,Taldren,
// 
//
			B.SetEnemy(None);
//
// ?, end changes
//////////////////////
			BestEnemy = None;
		}
		else
		{
			if ( ModifyThreat(0,BestEnemy,bSeeEnemy,B) > 5 )
				return false;
			BestThreat = AssessThreat(B,BestEnemy,bSeeEnemy);
		}
	}
	for ( i=0; i<ArrayCount(Enemies); i++ )
	{
///////////////////////////////////
// ?,Taldren,
// 
//
		if ( (Enemies[i] != None) && (Enemies[i].Health > 0) )
//
// ?, end changes
//////////////////////
		{
			if ( BestEnemy == None )
			{
				BestEnemy = Enemies[i];
				bSeeEnemy = B.CanSee(Enemies[i]);
				BestThreat = AssessThreat(B,BestEnemy,bSeeEnemy);
			}
			else if ( Enemies[i] != BestEnemy )
			{
				if ( VSize(Enemies[i].Location - B.Pawn.Location) < 1500 )
					bSeeNew = B.LineOfSightTo(Enemies[i]);
				else
					bSeeNew = B.CanSee(Enemies[i]);	// only if looking at him
				NewThreat = AssessThreat(B,Enemies[i],bSeeNew);
///////////////////////////////////
// ?,Taldren,
// 
//
				if ( (NewThreat > BestThreat) && B.IsEnemy(Enemies[i]) )
//
// ?, end changes
//////////////////////
				{
					BestEnemy = Enemies[i];
					BestThreat = NewThreat;
					bSeeEnemy = bSeeNew;
				}
			}
		}
		else
			Enemies[i] = None;
	}
///////////////////////////////////
// ?,Taldren,
// 
//
	B.Enemy = BestEnemy;
//
// ?, end changes
//////////////////////
	if ( (B.Enemy != OldEnemy) && (B.Enemy != None) )
	{
		B.EnemyChanged(bSeeEnemy);
		return true;
	}
	return false;
}

/* ModifyThreat()
return a modified version of the threat value passed in for a potential enemy
*/
function float ModifyThreat(float current, Pawn NewThreat, bool bThreatVisible, Bot B)
{
	return current;
}

function bool UnderFire(Pawn NewThreat, Bot Ignored)
{
	local Bot B;
	
	for ( B=SquadMembers; B!=None; B=B.NextSquadMember )
	{
		if ( (B != Ignored) && (B.Pawn != None) && (B.Enemy == NewThreat) && (B.Focus == NewThreat)
			&& (VSize(Ignored.Pawn.Location - NewThreat.Location + NewThreat.Velocity) > VSize(B.Pawn.Location - NewThreat.Location + NewThreat.Velocity)) 
			&& B.EnemyVisible() )
			return true;
	}
	return false;
}

function float AssessThreat( Bot B, Pawn NewThreat, bool bThreatVisible )
{
	local float ThreatValue, NewStrength, Dist;

	NewStrength = B.RelativeStrength(NewThreat);
	ThreatValue = NewStrength;
	Dist = VSize(NewThreat.Location - B.Pawn.Location);
	if ( Dist < 2000 )
	{
		ThreatValue += 0.2;
		if ( Dist < 1500 )
			ThreatValue += 0.2;
		if ( Dist < 1000 )
			ThreatValue += 0.2;
		if ( Dist < 500 )
			ThreatValue += 0.2;
	}

	if ( bThreatVisible )
		ThreatValue += 1; 
	if ( (NewThreat != B.Enemy) && (B.Enemy != None) )
	{
		if ( !bThreatVisible )
			ThreatValue -= 5;
		else if ( Level.TimeSeconds - B.LastSeenTime > 2 )
			ThreatValue += 1;
		if ( Dist > 0.7 * VSize(B.Enemy.Location - B.Pawn.Location) )
			ThreatValue -= 0.25;
		ThreatValue -= 0.2;

		if ( B.IsHunting() && (NewStrength < 0.2) 
			&& (Level.TimeSeconds - FMax(B.LastSeenTime,B.AcquireTime) < 2.5) )
			ThreatValue -= 0.3;
	}

	ThreatValue = ModifyThreat(ThreatValue,NewThreat,bThreatVisible,B);
	if ( NewThreat.IsHumanControlled() )
			ThreatValue += 0.25;
			
	//log(B.GetHumanReadableName()$" assess threat "$ThreatValue$" for "$NewThreat.GetHumanReadableName());
	return ThreatValue;
}
		
/* 
Return true if squad should defer to C
*/
function bool ShouldDeferTo(Controller C)
{
	return ( C == SquadLeader );
}

/* WaitAtThisPosition()
Called by bot to see if its pawn should stay in this position
returns true if bot has human leader holding near this position
*/
function bool WaitAtThisPosition(Pawn P)
{
	if ( Bot(P.Controller).NeedWeapon() || (PlayerController(SquadLeader) == None) || (SquadLeader.Pawn == None) ) 
		return false;
	return CloseToLeader(P);
}

function bool WanderNearLeader(Bot B)
{
	if ( B.NeedWeapon() || (PlayerController(SquadLeader) == None) || (SquadLeader.Pawn == None) || !CloseToLeader(B.Pawn) ) 
		return false;
	if ( B.FindInventoryGoal(0.0005) )
		return true;
}

function bool NearFormationCenter(Pawn P)
{
	local Actor Center;

	Center = FormationCenter();
	if ( Center == None )
		return true;
	if ( Center == SquadLeader.Pawn )
	{
		if ( PlayerController(SquadLeader) != None )
			return CloseToLeader(P);
		else
			return false;
	}
	if ( VSize(Center.Location - P.Location) > GetRestingFormation().FormationSize )
		return false;
	return ( P.Controller.LineOfSightTo(Center) );
}

/* CloseToLeader()
Called by bot to see if his pawn is in an acceptable position relative to the squad leader
*/
function bool CloseToLeader(Pawn P)
{
	local float dist;

	if ( (P == None) || (SquadLeader.Pawn == None) )
		return true;

	// for certain games, have bots wait for leader for a while
	if ( (P.Base != None) && (SquadLeader.Pawn.Base != None) && (SquadLeader.Pawn.Base != P.Base) )
		return false;	

	dist = VSize(P.Location - SquadLeader.Pawn.Location);
	if ( dist > GetRestingFormation().FormationSize ) 
		return false;
	
	// check if leader is moving away
	if ( PhysicsVolume.bWaterVolume )
	{
		if ( VSize(SquadLeader.Pawn.Velocity) > 0 )
			return false;
	}
	else if ( VSize(SquadLeader.Pawn.Velocity) > SquadLeader.Pawn.WalkingPct * SquadLeader.Pawn.GroundSpeed )
		return false;
				
	return ( P.Controller.LineOfSightTo(SquadLeader.Pawn) );
}

function MergeWith(SquadAI S)
{
	local Bot B,Prev;

	if ( S == self )
		return;

	for ( B=SquadMembers; B!=None; B=B.NextSquadMember )
	{
		if ( Prev != None )
			S.AddBot(Prev);
		Prev = B;
	}
	if ( Prev != None )
		S.AddBot(Prev);
	Destroy();
}	

function Initialize(UnrealTeamInfo T, GameObjective O, Controller C)
{
	Team = T;
	SetLeader(C);
	SetObjective(O,false);
}

function SetAlternatePath(bool bResetSquad)
{
	local AssaultPath List[16];
	local int i,num;
	local AssaultPath A;
	local float sum,r;
	local bot S;

	AlternatePath = None;
	AlternatePathTag = 'None';
	if ( bResetSquad )
	{
		for ( S=SquadMembers; S!=None; S=S.NextSquadMember )
		{
			S.bFinalStretch = false;
			S.bReachedGatherPoint = false;
		}
	}

	for ( A=SquadObjective.AlternatePaths; A!=None; A=A.NextPath )
	{
		if ( A.bEnabled && A.bFirstPath && !A.bReturnOnly )
		{
			List[num] = A;
			num++;
			if ( num > 15 )
				break;
		}
	}

	//if ( (num < 2) && (Bot(SquadLeader) != None) && Bot(SquadLeader).bSoaking )
	//	Bot(SquadLeader).SoakStop("UNHAPPY BECAUSE THERE ARE ONLY "$num$" ASSAULTPATHS TO "$SquadObjective);

	if ( num > 0 )
	{
		for ( i=0; i<num; i++ )
			sum += List[i].Priority;
		r = FRand() * sum;
		sum = 0;
		for ( i=0; i<num; i++ )
		{
			sum += List[i].Priority;
			if ( r <= sum )
			{
				AlternatePath = List[i];
				AlternatePathTag = List[i].PickTag();
				return;
			}
		}
		AlternatePath = List[0];
		AlternatePathTag = List[0].PickTag();
	}
}

function bool TryToIntercept(Bot B, Pawn P, Actor RouteGoal)
{
	if ( (P == None) || (NavigationPoint(RouteGoal) == None) || (B.Skill + B.Tactics < 4) )
		return FindPathToObjective(B,P);

	B.MoveTarget = None;
	if ( B.ActorReachable(P) )
	{
		B.GoalString = "almost to "$P;
		if ( B.Enemy != P )
			SetEnemy(B,P);
		if ( B.Enemy != None )
		{
			B.FightEnemy(true,0);
			return true;
		}
		else
		{
			log("Not attacking intercepted enemy!");
			B.MoveTarget = P;
			B.SetAttractionState();
			return true;
		}
	}
	B.MoveTarget = B.FindPathToIntercept(P,RouteGoal,true);
	if ( B.MoveTarget == None )
	{
		if ( P == B.Enemy )
		{
			B.FailedHuntEnemy = B.Enemy;
			B.FailedHuntTime = Level.TimeSeconds;
		}
	}
	else if ( B.Pawn.ReachedDestination(B.MoveTarget) )
		return false;
	return B.StartMoveToward(P);
}

/* FindPathToObjective()
Returns path a bot should use moving toward a base
*/
function bool FindPathToObjective(Bot B, Actor O)
{
	local Bot S;
	local float N, GatherWaitTime;

	if ( O == None )
	{
		O = SquadObjective;
		if ( O == None )
		{
			B.GoalString = "No SquadObjective";
			return false;
		}
	}
	if ( B.bFinalStretch || (O != SquadObjective) || SquadObjective.BotNearObjective(B) )
		return B.SetRouteToGoal(O);
	if ( (AlternatePath == None) || (AlternatePath.AssociatedObjective != SquadObjective) )
		SetAlternatePath(false);
	if ( AlternatePath == None )
		return B.SetRouteToGoal(O);

	B.MoveTarget = None;
	if ( B.ActorReachable(O) )
	{
		if ( B.Pawn.ReachedDestination(O) )
		{
			log(B.GetHumanReadableName()$" Force touch for reached objective");
			O.Touch(B.Pawn);
			return false;
		}
		B.RouteGoal = O;
		B.RouteCache[0] = None;
		B.GoalString = "almost at "$O;
		B.MoveTarget = O;
		B.SetAttractionState();
		return true;
	}

	if ( B.bReachedGatherPoint || B.Pawn.ReachedDestination(AlternatePath) )
	{
		B.GoalString = "Find path to "$O$" now near "$AlternatePath;
		B.MoveTarget = AlternatePath;
		if ( !B.bReachedGatherPoint )
		{
			B.bReachedGatherPoint = true;
			B.GatherTime = Level.TimeSeconds;
		}
		if ( (B.Enemy != None) && B.EnemyVisible() )
			GatherWaitTime = 3;
		else
			GatherWaitTime = 8;
	
		if ( Level.TimeSeconds - B.GatherTime > GatherWaitTime )
			N = Size;
		else
		{
			// check if should update alternatepath, because squad has reached it
			for ( S=SquadMembers; S!=None; S=S.NextSquadMember )
				if ( (S.Pawn != None) && S.bReachedGatherPoint )
					N += 1;
		}
		if ( AlternatePath.bNoGrouping || (N/Size >= GatherThreshold) )
		{
			for ( S=SquadMembers; S!=None; S=S.NextSquadMember )
				S.bReachedGatherPoint = false;
			AlternatePath = AlternatePath.FindNextPath(AlternatePathTag);
			if ( AlternatePath == None )
			{
				B.GoalString = "Final stretch to "$O;
				SetFinalStretch(true);
				B.FindBestPathToward(O,true,true);
			}
			else
				B.FindBestPathToward(AlternatePath,true,true);
			return B.StartMoveToward(O);			
		}
		else if ( B.Enemy != None )
		{
			if ( B.LostContact(7) )
				B.LoseEnemy();
			if ( B.Enemy != None )
			{
				B.FightEnemy(false, 0);
				return true;
			}
		}	
		B.GoalString = "Waiting for Squad";
		B.WanderOrCamp(true);
		return true;
	}
	else
	{
		B.GoalString = "Find path to "$O$" through "$AlternatePath;
		if ( !B.FindBestPathToward(AlternatePath,true,true) )
		{
			B.GoalString = "Find path to "$O$" no path to alternate path";
			if ( B.bSoaking && (Physics != PHYS_Falling) )
				B.SoakStop("COULDN'T FIND PATH TO ALTERNATEPATH "$AlternatePath);
				B.FindBestPathToward(O,true,true);
		}
		if ( B.MoveTarget == AlternatePath )
		{
			B.GatherTime = Level.TimeSeconds;
			B.bReachedGatherPoint = true;
		}
	}
	return B.StartMoveToward(O);
}

function SetFinalStretch(bool bValue)
{
	local Bot S;

	for ( S=SquadMembers; S!=None; S=S.NextSquadMember )
		S.bFinalStretch = bValue;
}

function SetLeader(Controller C)
{
	SquadLeader = C;
	LeaderPRI = TeamPlayerReplicationInfo(C.PlayerReplicationInfo);
	if ( Bot(C) != None )
		AddBot(Bot(C));
}

function RemovePlayer(PlayerController P)
{
	if ( SquadLeader != P )
		return;
	if ( SquadMembers == None )
	{
		destroy();
		return;
	}

///////////////////////////////////
// ?,Taldren,
// 
//
	if (Team != None)
//
// ?, end changes
//////////////////////
		SquadObjective = Team.AI.GetPriorityAttackObjective();
	PickNewLeader();
}
 
function RemoveBot(Bot B)
{
	local Bot Prev;

	if ( B.Squad != self )
		return;
		
	B.Squad = None;
	Size --;

	if ( SquadMembers == B )
	{
		SquadMembers = B.NextSquadMember;
		if ( SquadMembers == None )
		{
			destroy();
			return;
		}
	}
	else
	{
		for ( Prev=SquadMembers; Prev!=None; Prev=Prev.NextSquadMember )
			if ( Prev.NextSquadMember == B )
			{
				Prev.NextSquadMember = B.NextSquadMember;
				break;
			}	
	}
	if ( SquadLeader == B )
		PickNewLeader();
}

function AddBot(Bot B)
{
	if ( B.Squad == self )
		return;
	if ( B.Squad != None )
		B.Squad.RemoveBot(B);

	Size++;

	B.NextSquadMember = SquadMembers;
	SquadMembers = B;
	B.Squad = self;
	if ( TeamPlayerReplicationInfo(B.PlayerReplicationInfo) != None )
	TeamPlayerReplicationInfo(B.PlayerReplicationInfo).Squad = self;
}

function SetDefenseScriptFor(Bot B)
{
	local UnrealScriptedSequence S;

	if ( !B.bEnemyEngaged && (B.GoalScript != None) 
		&& !B.Pawn.ReachedDestination(B.GoalScript.GetMoveTarget())
		&& SquadObjective.OwnsDefenseScript(B.GoalScript) )
	{
		B.bEnemyEngaged = false;
		return;
	}
	B.bEnemyEngaged = false;
	
	// possibly stay with same defense point if right on it
	if ( (B.GoalScript != None) 
		&& !B.GoalScript.bRoamingScript
		&& (B.GoalScript.bDontChangeScripts || ((FRand() < 0.85) && B.Pawn.ReachedDestination(B.GoalScript.GetMoveTarget())))
		&& SquadObjective.OwnsDefenseScript(B.GoalScript) )
		return;

	if ( B.GoalScript != None )
	{
		B.GoalScript.bAvoid = true;
		B.FreeScript();
	}
	for ( S=SquadObjective.DefenseScripts; S!=None; S=S.NextScript )
		if ( S.HigherPriorityThan(B.GoalScript, B) )
			B.GoalScript = S;

	if ( B.GoalScript != None )
		B.GoalScript.CurrentUser = B;
}

function SetFreelanceScriptFor(Bot B)
{
	local UnrealScriptedSequence S;
			
	// possibly stay with same defense point if right on it
	if ( (B.GoalScript != None)	&& !B.GoalScript.bRoamingScript
		&& (B.GoalScript.bDontChangeScripts || ((FRand() < 0.8)	&& B.Pawn.ReachedDestination(B.GoalScript.GetMoveTarget()))) )
		return;

	if ( B.GoalScript != None )
	{
		B.GoalScript.bAvoid = true;
		B.FreeScript();
	}
	// find a freelance script
	if ( FreelanceScripts == None )
		ForEach AllActors(class'UnrealScriptedSequence',S)
			if ( S.bFreelance && S.bFirstScript )
			{
				FreelanceScripts = S;
				break;
			}

	for ( S=FreelanceScripts; S!=None; S=S.NextScript )
		if ( S.HigherPriorityThan(B.GoalScript, B) )
			B.GoalScript = S;

	if ( B.GoalScript != None )
		B.GoalScript.CurrentUser = B;
}
			
function SetObjective(GameObjective O, bool bForceUpdate)
{
	local bot M;
	
	if ( SquadObjective == O )
	{
		if ( !bForceUpdate )
			return;
	}
	else
	{
		SquadObjective = O;
		if ( SquadObjective != None )
			SetAlternatePath(true);
	}
	//log("set objective &&&&&");
	for	( M=SquadMembers; M!=None; M=M.NextSquadMember )
		if ( M.Pawn != None )
			Retask(M);
}

function Retask(bot B)
{
	if ( B.InLatentExecution(B.LATENT_MOVETOWARD) )
	{
		if ( B.bPreparingMove )
		{
			B.bPreparingMove = false;
			B.WhatToDoNext(63);
		}
		else if ( (B.Pawn.Physics == PHYS_Falling) && (JumpSpot(B.Movetarget) != None) )
			return;
		else if ( B.MoveTimer > 0.3 )
			B.MoveTimer = 0.05 + 0.15 * FRand();
	}
	else
	{
		B.RetaskTime = Level.TimeSeconds + 0.05 + 0.15 * FRand();
		GotoState('Retasking');
	}
}

State Retasking
{
	function Tick(float DeltaTime)
	{
		local Bot M;
		local bool bStillTicking;

		for	( M=SquadMembers; M!=None; M=M.NextSquadMember )
			if ( (M.Pawn != None) && (M.RetaskTime > 0) )
			{
				if ( Level.TimeSeconds > M.RetaskTime )
					M.WhatToDoNext(43);	
				else
					bStillTicking = true;
			}
			
		if ( !bStillTicking )
			GotoState('');
	}
}	

function name GetOrders()
{
	local name NewOrders;

	if ( PlayerController(SquadLeader) != None )
		NewOrders = 'Human';
	else if ( bFreelance && !bFreelanceAttack && !bFreelanceDefend )
		NewOrders = 'Freelance';
///////////////////////////////////
// ?,Taldren,
// 
//
	else if ( (SquadObjective != None) && (Team != None) && (SquadObjective.DefenderTeamIndex == Team.TeamIndex) )
//
// ?, end changes
//////////////////////
		NewOrders = 'Defend';
	else
		NewOrders = 'Attack';
	if ( NewOrders != CurrentOrders )
		CurrentOrders = NewOrders;
	return CurrentOrders;
}

simulated function String GetOrderStringFor(TeamPlayerReplicationInfo PRI)
{
	if ( (LeaderPRI != None) && !LeaderPRI.bBot )
	{
		// FIXME - holding replication
		if ( PRI.bHolding )
			return HoldString;

		return SupportString@LeaderPRI.PlayerName@SupportStringTrailer;
	}
	if ( bFreelance || (SquadObjective == None) )
		return FreelanceString;
	else
	{
		GetOrders();
		if ( CurrentOrders == 'defend' )
			return DefendString@SquadObjective.GetHumanReadableName();
		if ( CurrentOrders == 'attack' )
			return AttackString@SquadObjective.GetHumanReadableName();
	}
	return string(CurrentOrders);
}

function int GetSize()
{
	if ( PlayerController(SquadLeader) != None )
		return Size + 1; // add 1 for leader
	else 
		return Size;
}
	
function PickNewLeader()
{
	local Bot B;

	// FIXME - pick best based on distance to objective

	// pick a leader that isn't out of the game
	for ( B=SquadMembers; B!=None; B=B.NextSquadMember )
		if ( !B.PlayerReplicationInfo.bOutOfLives )
			break;

	SquadLeader = B;
	if ( SquadLeader == None )
		LeaderPRI = None;
	else
		LeaderPRI = TeamPlayerReplicationInfo(SquadLeader.PlayerReplicationInfo);
}

function bool TellBotToFollow(Bot B, Controller C)
{
	local Pawn Leader;

	if ( (C == None) || C.bDeleteMe )
	{
		PickNewLeader();
		C = SquadLeader;
	}

	if ( B == C )
		return false;

	B.GoalString = "Follow Leader";
	Leader = C.Pawn;
	if ( Leader == None )
		return false;

	if ( CloseToLeader(B.Pawn) )
	{
		if ( !B.bInitLifeMessage )
		{
			B.bInitLifeMessage = true;
		  	B.SendMessage(SquadLeader.PlayerReplicationInfo, 'OTHER', B.GetMessageIndex('GOTYOURBACK'), 10, 'TEAM');
		}
		if ( B.Enemy == None )
		{
			if ( B.FindInventoryGoal(0.0005) )
			{
				B.SetAttractionState();
				return true;
			}
			B.WanderOrCamp(true);
			return true;
		}
		else if ( B.Pawn.Weapon.FocusOnLeader(false) )
		{
			B.FightEnemy(false,0);
			return true;
		}
		return false;
	}	
	else if ( B.SetRouteToGoal(Leader) )
		return true;
	else
	{
		B.GoalString = "Can't reach leader";
		return false;
	}
}

function bool AllowTaunt(Bot B)
{
	return ( FRand() < 0.5 );
}

function AddTransientCosts(Bot B, float f)
{
	local Bot S;
	
	for ( S=SquadMembers; S!=None; S=S.NextSquadMember )
		if ( (S != B) && (NavigationPoint(S.MoveTarget) != None) && S.InLatentExecution(S.LATENT_MOVETOWARD) )
			NavigationPoint(S.MoveTarget).TransientCost = 1000 * f;
}

function bool AssignSquadResponsibility(Bot B)
{
	// set new defense script
	if ( (SquadObjective != None) && (SquadObjective.DefenderTeamIndex == Team.TeamIndex) && (B.Enemy == None) && (GetOrders() == 'Defend') )
		SetDefenseScriptFor(B);
	else if ( (B.GoalScript != None) && (HoldSpot(B.GoalScript) == None) )
		B.FreeScript();
	
	AssignCombo(B);
			
	// check for major game objective responsibility
	if ( CheckSquadObjectives(B) )
		return true;

	if ( B.Enemy == None )
	{
		// suggest inventory hunt
		// FIXME - don't load up on unnecessary ammo in DM
		if ( B.FindInventoryGoal(0) )
		{
			B.SetAttractionState();
			return true;
		}

		// roam around level?
		if ( (B == SquadLeader) || (GetOrders() == 'Freelance') )
			return B.FindRoamDest();
	}
	return false;
}

function bool CheckVehicle(Bot B)
{
	local Actor BestPath, BestEntry;
	
	if ( (SquadVehicle == None) || SquadVehicle.Occupied() )
		return false;
		
	if ( B.LastSearchTime == Level.TimeSeconds )
		return false;
		
	BestEntry = SquadVehicle.GetBestEntry(B.Pawn);
	if ( B.ActorReachable(BestEntry) )
	{
		B.MoveTarget = BestEntry;
		return true;
	}
		
	BestPath = B.FindPathToward(BestEntry,true);
	if ( BestPath != None )
	{
		B.MoveTarget = BestPath;
		return true;
	}
	return false;
}

function bool CheckSquadObjectives(Bot B)
{
	local Actor DesiredPosition;
	local GameObjective PickedObjective;
	local bool bInPosition;

///////////////////////////////////
// ?,Taldren,
// 
//
	return false;  // The code here is broken; AIs will just stand and hang around if we run it.
//
// ?, end changes
//////////////////////

	if ( CheckVehicle(B) )
	{
		B.GoalString = "Need weapon or ammo";
		B.SetAttractionState();
		return true;
	}
	
	if ( B.NeedWeapon() && B.FindInventoryGoal(0) )
	{
		B.GoalString = "Need weapon or ammo";
		B.SetAttractionState();
		return true;
	}

	if ( PlayerController(SquadLeader) != None )
	{
		if ( HoldSpot(B.GoalScript) == None )
		{
			// attack objective if close by
///////////////////////////////////
// ?,Taldren,
// 
//
			if (Team != None)
				PickedObjective = Team.AI.GetPriorityAttackObjective();
			else
				PickedObjective = None;
//
// ?, end changes
//////////////////////
			if ( (PickedObjective != None) && (PickedObjective.DefenderTeamIndex != Team.TeamIndex) && B.LineOfSightTo(PickedObjective) )
				return PickedObjective.TellBotHowToDisable(B);
			
			// follow human leader
			return TellBotToFollow(B,SquadLeader);	
		}
		// hold position as ordered (position specified by goalscript)
	}
	if ( ShouldDestroyTranslocator(B) )
		return true;
	if ( B.GoalScript != None )
	{
		DesiredPosition = B.GoalScript.GetMoveTarget();
		bInPosition = B.Pawn.ReachedDestination(DesiredPosition);
		if ( bInPosition && B.GoalScript.bRoamingScript && (GetOrders() == 'Freelance') )
			return false;
		if ( !bInPosition )
			B.ClearScript();
	}
	else if ( SquadObjective == None )
		return TellBotToFollow(B,SquadLeader);	
	else if ( GetOrders() == 'Freelance' )
		return false;
	else
	{
///////////////////////////////////
// ?,Taldren,
// 
//
		if ( (Team != None) && (SquadObjective.DefenderTeamIndex != Team.TeamIndex) )
//
// ?, end changes
//////////////////////
		{
			if ( SquadObjective.bDisabled )
			{
				B.GoalString = "Objective already disabled";
				return false;
			}
			B.GoalString = "Disable Objective";
			return SquadObjective.TellBotHowToDisable(B);
		}
		DesiredPosition = SquadObjective;
		bInPosition = ( (VSize(SquadObjective.Location - B.Pawn.Location) < 1200) && B.LineOfSightTo(SquadObjective) );
	}

	if ( B.Enemy != None )
	{
		if ( (B.GoalScript != None) && B.GoalScript.bRoamingScript )
		{
			B.GoalString = "Attack enemy freely";
			return false; 
		}
		if ( B.LostContact(5) )
			B.LoseEnemy();
		if ( B.Enemy != None )
		{
			B.FightEnemy(false, 0);
			return true;
		}
	}
	if ( bInPosition )
	{
		B.GoalString = "Near "$DesiredPosition;
		if ( !B.bInitLifeMessage )
		{
			B.bInitLifeMessage = true;
			B.SendMessage(None, 'OTHER', B.GetMessageIndex('INPOSITION'), 10, 'TEAM');
		}
		if ( B.GoalScript != None )
			B.GoalScript.TakeOver(B.Pawn);
		else
			B.WanderOrCamp(true);
		return true;
	}
	B.GoalString = "Follow path to "$DesiredPosition;
	B.FindBestPathToward(DesiredPosition,false,true);
	return B.StartMoveToward(DesiredPosition);
}

function bool ShouldDestroyTranslocator(Bot B)
{
	local UnrealMPGameInfo G;
	local TranslocatorBeacon T;
	
	if ( (B.Enemy != None) || (B.Skill < 2) )
		return false;
	G = UnrealMPGameInfo(Level.Game);
	if ( G == None )
		return false;

	for ( T=G.BeaconList; T!=None; T=T.NextBeacon )
	{
		if ( !T.Disrupted() && (T.Instigator != None) && (T.Instigator.Controller != None)
			&& !B.SameTeamAs(T.Instigator.Controller)
			&& (VSize(B.Pawn.Location - T.Location) < 1500)
			&& B.LineOfSightTo(T) )
		{
			B.GoalString = "Destroy Translocator";
			B.DoRangedAttackOn(T);
			return true;
		}
	}
	return false;
}

function float BotSuitability(Bot B)
{
	if ( class<UnrealPawn>(B.PawnClass) == None )
		return 0;

	if ( GetOrders() == 'Defend' )
		return (1.0 - class<UnrealPawn>(B.PawnClass).Default.AttackSuitability);
	return class<UnrealPawn>(B.PawnClass).Default.AttackSuitability;
}

/* PickBotToReassign()
pick a bot to lose
*/
function bot PickBotToReassign()
{
	local Bot B,Best;
	local float Val, BestVal;
	local float Suitability, BestSuitability;

	// pick bot furthest from SquadObjective, with highest suitability
	for	( B=SquadMembers; B!=None; B=B.NextSquadMember )
		if ( !B.PlayerReplicationInfo.bOutOfLives )
		{
			Val = VSize(B.Pawn.Location - SquadObjective.Location);
			if ( B == SquadLeader )
				Val -= 10000000.0;
			Suitability = BotSuitability(B);
			if ( (Best == None) || (Suitability > BestSuitability)
				|| ((Suitability == BestSuitability) && (Val > BestVal)) )
			{
				Best = B;
				BestVal = Val;
				BestSuitability = Suitability;
			}
		}
	return Best;		
}

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string EnemyList;
	local int i;

	Canvas.SetDrawColor(255,255,255);	
	if ( SquadObjective == None )
		Canvas.DrawText("     ORDERS "$GetOrders()$" on "$GetItemName(string(self))$" no objective. Leader "$SquadLeader.GetHumanReadableName(), false);
	else
		Canvas.DrawText("     ORDERS "$GetOrders()$" on "$GetItemName(string(self))$" objective "$SquadObjective.GetHumanReadableName()$". Leader "$SquadLeader.GetHumanReadableName(), false);

	YPos += YL;
	Canvas.SetPos(4,YPos);
	EnemyList = "     Enemies: ";
	for ( i=0; i<ArrayCount(Enemies); i++ )
		if ( Enemies[i] != None )
			EnemyList = EnemyList@Enemies[i].GetHumanReadableName();
	Canvas.DrawText(EnemyList, false);

	YPos += YL;
	Canvas.SetPos(4,YPos);
}

/* BeDevious()
return true if bot should use guile in hunting opponent (more expensive)
*/
function bool BeDevious()
{
	return false;
}

function bool PickRetreatDestination(Bot B)
{
	// FIXME - fall back to other squad members (furthest), or defense objective, or home base
	return B.PickRetreatDestination();
}

/* ClearPathForLeader()
make all squad members close to leader get out of his way
*/
function bool ClearPathFor(Controller C)
{
	local Bot B;
	local bool bForceDefer;
	local vector Dir;
	local float DirZ;

	bForceDefer = ShouldDeferTo(C);

	for ( B=SquadMembers; B!=None; B=B.NextSquadMember )
		if ( (B != C) && (B.Pawn != None) )
		{
			Dir = B.Pawn.Location - C.Pawn.Location;
			DirZ = Dir.Z;
			Dir.Z = 0;
			if ( (Abs(Dir.Z) < B.Pawn.CollisionHeight + C.Pawn.CollisionHeight)
				&& (VSize(Dir) < 8 * B.Pawn.CollisionRadius) )
			{
				if ( bForceDefer )
					B.ClearPathFor(C);
				else
					B.CancelCampFor(C);
			}
		}
	return bForceDefer;
}

function bool IsDefending(Bot B)
{
	if ( GetOrders() == 'Defend' )
		return true;

	return ( B.GoalScript != None );
}

/* CautiousAdvance()
return true if bot should advanced cautiously (crouched)
*/
function bool CautiousAdvance(Bot B)
{
	return false;
}

function bool FriendlyToward(Pawn Other)
{
	if ( Team == None )
		return false;
	return Team.AI.FriendlyToward(Other);
}

defaultproperties
{
	GatherThreshold=0.6
	SupportString="supporting"
	DefendString="defending"
	AttackString="attacking"
	HoldString="holding"
	FreelanceString="Sweeper"
	MaxSquadSize=2
	RestingFormationClass=Class'RestingFormation'
}