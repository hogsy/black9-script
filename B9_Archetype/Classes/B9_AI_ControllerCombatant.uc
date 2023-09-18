//////////////////////////////////////////////////////////////////////////
//
// Black 9 Bot Controller
//
//////////////////////////////////////////////////////////////////////////
class B9_AI_ControllerCombatant extends Bot;


var bool			fAboutToDieCalled;
var bool			fTriedGiveGun;
var float			fRand60Deg[3];

// Travel variables
var Actor			fTravelTarget;
var vector			fRouteGoalLocation;
var vector			pos;
var vector			fLastMovementPosition;
var vector			fLastPlayerPos;
var bool			fRouteGoalLocationValid;
var bool			fTravelActorReachable;
var bool			fShouldAlternateMoveToLocation;
var int				fOnAlert;
var bool			fRestartTravelToTarget;
var Actor			fBestPath;
var Actor			fActorSeen;
var Actor			fCurrentNavPoint;
var Pawn			fPlayer;

// Patrol variables.
var PathNodeNamed	fLastPathNodeNamed;

// Return to Position variables.
var Vector			fOriginalLocation;
var Rotator			fOriginalRotation;
var bool			fOriginalLocationSet;

// Enemy storage variables.
var Pawn			fSetEnemy;
var Pawn			fPrey;

const				fDistanceToLocation	= 300;

// Alarm variables
var bool			fHitAlarm;

// Warnings about the enemy's position.
var float			fLastTimeGaveUpEnemyPosition;

// Retreat variables.
var Pathnode		fLastRetreatPoint;
var float			fTimeLastRetreatPoint;
var bool			fRetreated;
var bool			fFiredAfterRetreat;
var int				fNumAlliesCloseBy;
var int				fNumEnemiesCloseBy;
var float			fTimeLastCountedAllies;

// Jumping variables.
var float			fNextJumpTime;
var bool			fStoreJump;
var bool			fFirstTimeSeeEnemy;

enum eCombatItemResult
{
	kNothing,
	kWeapon,
	kNanoTech
};

enum ETravelResponse
{
	kNone,
	kDefault,
	kTargetLOS,
	kPause,
};



//*************************************************************************************************
// Global Functions
//*************************************************************************************************


// Sets the actor for which this pawn will hunt; it will follow it to where ever it is on the map.
function SetPrey(B9_AdvancedPawn prey)
{
	B9_ArchetypePawnBase(Pawn).fStartupState = kHunt;
	SetEnemy(prey);
	fPrey = prey;
	
	WhatToDoNext(0);
}


function AboutToDie()
{
	if( !fAboutToDieCalled )
	{
		//log( "MikeT: 'About To Die' CALLED!" ); 
		fAboutToDieCalled = true;

		// Destroy currently held weapon
		DestroyWeapon();

		// Drop required items
		DropEmplacedItems();
	}
}


function EquipCombatItemByString( string className, bool hidden )
{
	EquipCombatItem( className, hidden );
}

function eCombatItemResult EquipCombatItem( string className, bool hidden )
{
	// Try this as a weapon first
	Pawn.GiveAndEquipWeapon( className );

	// If it's not a weapon, try it as a nano-tech skill.
	if( Pawn.Weapon != None )
	{
		/*
			SB, fixed
			Never cause Pawn.Weapon to become visible. Only Weapon.ThirdPersonActor should be shown.
		*/
		//Pawn.Weapon.bHidden = hidden;
		
		Pawn.Weapon.ThirdPersonActor.bHidden = hidden;
		return kWeapon;
	}
	else
	{
		if( B9_ArchetypePawnCombatant( Pawn ).GiveNanotech( className ) )
		{
			return kNanoTech;
		}
		else
		{
			return kNothing;
		}
	}
}


// Returns the type of combat item the bot has.
function eCombatItemResult HasCombatItem()
{
	if( Pawn.Weapon != None )
	{
		return kWeapon;
	}
	else if( B9_AdvancedPawn( Pawn ).fSelectedSkill != None )
	{
		return kNanoTech;
	}
	else
	{
		return kNothing;
	}
}


// Adds the specified piece of equipment by string; adds some ammo too if its a gun.
function HandleEquipCombatItem
(
	B9_ArchetypePawnCombatant p,
	string	weapon,
	int		ammo
)
{
	// XT: Added NULL string check 05/11/03
	// UNDONE: why is it empty or "None" at the first place???
	if( weapon != "" && weapon != "None" )
	{
		switch( EquipCombatItem( weapon, P.bWeaponHidden ) )
		{
			case kWeapon:
				Pawn.Weapon.AmmoType.AmmoAmount = ammo;
			break;

			case kNanoTech:
			break;

			case kNothing:
			default:
			break;
		}
	}
}


function SetupWeapon()
{
	local B9_ArchetypePawnCombatant P;
	P = B9_ArchetypePawnCombatant( Pawn );

	if( !fTriedGiveGun && Pawn.Weapon == None )
	{
		// Do I have a gun? No, create one!
		fTriedGiveGun = true;

		HandleEquipCombatItem(P, P.fWeaponIdentifierName1, P.fWeaponStartingAmmo1);
		HandleEquipCombatItem(P, P.fWeaponIdentifierName2, P.fWeaponStartingAmmo2);
		HandleEquipCombatItem(P, P.fWeaponIdentifierName3, P.fWeaponStartingAmmo3);
		HandleEquipCombatItem(P, P.fWeaponIdentifierName, P.fWeaponStartingAmmo);
	}	
}


// Destroy the weapon current held by this controller (typically executed before death)
function DestroyWeapon()
{
	if (Pawn.Weapon != None)
	{
		Pawn.Weapon.DetachFromPawn( Pawn );
		Pawn.DeleteInventory( Pawn.Weapon );
		Pawn.Weapon.Destroy();
	}
}

function DropEmplacedItems()
{
	local Pickup newPickupOne;
	local Pickup newPickupTwo;
	local Pickup newPickupThree;

	local vector dropPositionOne;
	local vector dropPositionTwo;
	local vector dropPositionThree;

	dropPositionOne = Pawn.Location;
	dropPositionOne.X += ( Rand( 100 ) - 50 ); 
	dropPositionOne.Y += ( Rand( 100 ) - 50 ); 

	dropPositionTwo = Pawn.Location;
	dropPositionTwo.X += ( Rand( 100 ) - 50 ); 
	dropPositionTwo.Y += ( Rand( 100 ) - 50 ); 

	dropPositionThree = Pawn.Location;
	dropPositionThree.X += ( Rand( 100 ) - 50 ); 
	dropPositionThree.Y += ( Rand( 100 ) - 50 ); 
		
	if( B9_ArchetypePawnBase( Pawn ).fItemToDropOne != None )
	{
		//log( "MikeT: TRYING TO DROP ITEM: " $B9_ArchetypePawnBase( Pawn ).fItemToDropOne );

		newPickupOne = Spawn( B9_ArchetypePawnBase( Pawn ).fItemToDropOne,,,dropPositionOne );
		
		if( newPickupOne != None )
		{
			//log( "MikeT: ITEM DROPPED: " $newPickupOne $"Thought it dropped: " $B9_ArchetypePawnBase( Pawn ).fItemToDropOne );
		}
	}

	if( B9_ArchetypePawnBase( Pawn ).fItemToDropTwo != None )
	{
		//log( "MikeT: TRYING TO DROP ITEM: " $B9_ArchetypePawnBase( Pawn ).fItemToDropTwo );

		newPickupTwo = Spawn( B9_ArchetypePawnBase( Pawn ).fItemToDropTwo,,,dropPositionTwo );
		
		if( newPickupTwo != None )
		{
			//log( "MikeT: ITEM DROPPED: "  $newPickupTwo $"Thought it dropped: " $B9_ArchetypePawnBase( Pawn ).fItemToDropTwo );
		}
	}

	if( B9_ArchetypePawnBase( Pawn ).fItemToDropThree != None )
	{
		//log( "MikeT: TRYING TO DROP ITEM: " $B9_ArchetypePawnBase( Pawn ).fItemToDropThree );

		newPickupThree = Spawn( B9_ArchetypePawnBase( Pawn ).fItemToDropThree,,,dropPositionThree );
		
		if( newPickupThree != None )
		{
			//log( "MikeT: ITEM DROPPED: "  $newPickupThree $"Thought it dropped: " $B9_ArchetypePawnBase( Pawn ).fItemToDropThree );
		}
	}
}


// Finds the nearest alarm switch, which is a type of pathnode.
function B9_PathNodeAlarmSwitch FindNearestAlarmSwitch()
{
	local float rangeToTarget, closestTarget, maxRangeToTarget;
	local B9_PathNodeAlarmSwitch	alarmSwitch, nearestAlarmSwitch;	// Default to none
	local bool allSwitchesFlipped;

	// Set closest target to something big
	closestTarget = 999999;
	maxRangeToTarget = 10000;
	allSwitchesFlipped = true;

	ForEach Pawn.RadiusActors( class'B9_PathNodeAlarmSwitch', alarmSwitch, maxRangeToTarget )
	{
		rangeToTarget = VSize( Pawn.Location - alarmSwitch.Location );
		
		//log( "MikeT: Found a switch at range: " $rangeToTarget );

		
		// Check to see if this switch has already been flipped
		if( !alarmSwitch.fFlipped )
		{
			allSwitchesFlipped = false;

			// Check range
			if( rangeToTarget < closestTarget )
			{
				closestTarget = rangeToTarget;
				nearestAlarmSwitch = alarmSwitch;
			}
		}
	}

	return nearestAlarmSwitch;
}



function Actor FindRandomNavpoint()
{
	local PathNode N;
	local actor goal;
	local float lowest;
	local float newRand;
	
	lowest = 10000;
	ForEach Pawn.AllActors(class'PathNode', N)
	{
		newrand = frand();
		if ((newRand < lowest) && (N != fCurrentNavPoint))
		{
			//if (ActorReachable(N))
			//{
				lowest = newRand;
				goal = N;
			//}
		}
	}
	
	return goal;
}

// Flips the state of all the alarms.
function FlipAllAlarms()
{
	local B9_PathNodeAlarmSwitch	alarmSwitch;

	ForEach Pawn.AllActors( class'B9_PathNodeAlarmSwitch', alarmSwitch )
	{
		alarmSwitch.fFlipped = true;
	}
}



function GoToTravelToAlarm()
{
	if (!IsSentry())
	{
		Focus = None;
		GotoState('TravelToAlarm');
	}
}



// Call this function when the goal the actor should reach is an actor.
function SetRouteGoal(Actor goal)
{
	if (RouteGoal != goal)
	{
		RouteGoal = goal;
		if (goal != None)
		{
			fRouteGoalLocation = goal.Location;
			fRouteGoalLocationValid = true;
		}
		else
			fRouteGoalLocationValid = false;
	}

	MoveTarget = goal;
}

// Call this function when the goal the actor should reach is a location.
function SetRouteGoalLocation(Vector location)
{
	RouteGoal = None;
	MoveTarget = None;
	fRouteGoalLocation = location;
	fRouteGoalLocationValid = true;
}


// Have we reached the place we're trying to go to.
function bool ReachedRouteGoal()
{
	if (RouteGoal == None)
	{
		if (fRouteGoalLocationValid)
			return VSize(fRouteGoalLocation - Pawn.Location) < fDistanceToLocation;
		else
			return true;  // If we don't have a goal then we must be there already...
	}

	if ( Pawn.ReachedDestination( RouteGoal ) )
	{
		fCurrentNavPoint = RouteGoal;
		return true;
	}
	
	return false;
}


// Find the next pathnode to our RouteGoal or routegoal position.  Handles the case of
// our goal being an pawn, pathnode, arbitrary actor or arbitrary position.  Also
// handles some bugs in Unreal code.
function Actor FindPath(bool clear)
{
	local Actor nextPath;

	nextPath = None;
	if (RouteGoal == None)
	{
		if (fRouteGoalLocationValid)
		{
			nextPath = FindPathTo(fRouteGoalLocation, clear);
			//log( "MikeT: Bestpath Pass 0 is: " $ nextPath );
		}
	}
	else
	{
		nextPath = FindPathToward(RouteGoal, clear);
		//log( "MikeT: Bestpath Pass 1 is: " $ nextPath );
		
		if (nextPath == None)
		{
			nextPath = FindPathTo(RouteGoal.Location, clear);
			//log( "MikeT: Bestpath Pass 2 is: " $ nextPath );
			if (nextPath == None)
			{
				nextPath = FindPathTo(fRouteGoalLocation, clear);
				//log( "MikeT: Bestpath Pass 3 is: " $ nextPath );
			}
			else
				fRouteGoalLocation = RouteGoal.Location;
		}
		else
			fRouteGoalLocation = RouteGoal.Location;
	}
	
	if (nextPath != None)
		MoveTarget = nextPath;
	
	return nextPath;
}


// Finds the next path to our RouteGoal, and handles the case of the destination being
// off the pathnode grid.
function bool FindNextBestPathToGoal()
{
	local Actor nextPath;

	if ( (RouteGoal != None) && actorReachable(RouteGoal))
	{
		MoveTarget = RouteGoal;
		nextPath = RouteGoal;
	}
	else
		nextPath = FindPath(true);

	if( nextPath != None )
	{
		// Set as the next move-to point
		fBestPath = nextPath;
		MoveTarget = nextPath;
		//log("MikeT: FindNextBestPathToGoal Nextpath: " $nextPath);
	}
	else
	{
		//Log("MikeT: Off pathnode list.");
		// Find a pathnode that's closest to the target actor.
		if (B9_Pawn(RouteGoal) != None)
		{
			nextPath = FindPathToward(B9_Pawn(RouteGoal).GetCachedClosestPathNode());
			if (nextPath == None)
			{
				// Get back onto the pathnode grid.
				nextPath = B9_Pawn(Pawn).GetCachedClosestPathNode();
			}
			if (nextPath != None)
				fBestPath = nextPath;
		}

		if (nextPath != None)
			MoveTarget = fBestPath;
		else
			return false;
	}

	return true;
}


// Basically, is the actor jumping.
function bool IsActorOnPathGrid( Actor testActor )
{
	local Pawn testPawn;
	testPawn = Pawn( testActor );

	// AFSNOTE@: Add more conditions and issues arise.
	if( testPawn != None )
	{
		if( testPawn.Physics == PHYS_Falling )
		{
			//log( "MikeT: moveto target is not on grid, but is falling, so try again later: " $testPawn );

			// Try again later
			return false;
		}
	}

	return true;
}

// Are we a sentry bot.
function bool IsSentry()
{
	if (B9_ArchetypePawnBase( Pawn ) != None)
		return B9_ArchetypePawnBase( Pawn ).fSentry;
	return false;
}


// Will we return to our original position after losing sight of the enemy.
function bool WillReturnToOrigPos()
{
	return B9_ArchetypePawnBase(Pawn).fReturnToOrigPos;
}


// Are we stalled.
function bool UpdateMovementStallTellTales()
{
	if( VSize( Pawn.Location - fLastMovementPosition ) < 10 )
	{
		fShouldAlternateMoveToLocation = true;
		return true;
	}
	else
	{
		fShouldAlternateMoveToLocation = false;
		fLastMovementPosition = Pawn.Location;
		return false;
	}
}

// Do we need to deviate our path?
function bool PopShouldAlternateMoveToLocation()
{
	if( fShouldAlternateMoveToLocation )
	{
		fShouldAlternateMoveToLocation = false;
		return true;
	}
	else
	{
		return false;
	}
}

function bool ShouldGetAlternateMoveToLocation()
{
	return PopShouldAlternateMoveToLocation();
}

// Get a deviation for our path.
function vector GetAlternateMoveToLocation()
{
	local vector	X, Y, Z;
	local vector	tangentMoveVector;
	local vector	delta;
	
	GetAxes( Rotation, X, Y, Z );

	tangentMoveVector = Y -( X*0.3 );

	delta = B9_ArchetypePawnBase( Pawn ).fSideStepAmount * tangentMoveVector;
	
	if( Rand( 2 ) == 0 )
	{
		return Pawn.Location + delta;
	}
	else
	{
		return Pawn.Location - delta;
	}
}


// Finds a pathnode that we can retreat to.  CPU intensive; should not be called very often.
function PathNode FindPathnodeToRetreatTo()
{
	local PathNode	np;
	local PathNode	cur;
	local PathNode	alt;
	local int		curPNDistanceToEnemy;
	local int		altPNDistanceToEnemy;
	local int		enemyDistance;
	local int		test;
	local bool		useAsAlt;
	
	// NYI: Look for pathnodes that are specifically suitable for cover.
	// NYI: Look for pathnodes that are good for crouching behind.
	
	if (Enemy == None)
		return None;

	// Only calculate this at most every 10 seconds.
	if ((fTimeLastRetreatPoint + 10) > Level.TimeSeconds)
		return fLastRetreatPoint;

	fTimeLastRetreatPoint = Level.TimeSeconds;
	alt = None;
	cur = None;
	curPNDistanceToEnemy = 0;
	altPNDistanceToEnemy = 0;
	enemyDistance = VSize(Pawn.Location - Enemy.Location);
	
	foreach Pawn.AllActors(class'PathNode',np)
	{
		// If the enemy can't get to the point directly or see the point, good.
		if (!Enemy.Controller.pointReachable(np.Location) && !Enemy.Controller.LineOfSightTo(np))
		{
			test = VSize(np.Location - Pawn.Location);
			useAsAlt = true;
			// If the point is closer to the AI than the enemy, good.
			if (test < VSize(np.Location - Enemy.Location))
			{
				// If the point is closer to the AI than the last point that we saw, good.
				if ( (test < curPNDistanceToEnemy) || (cur == None) )
				{
					// Check to see if the pathnode to get to this point requires us to run towards
					// the enemy.
					// NYI: For some reason, the below code is not working.  Don't know why.
//					if (ActorReachable(np)
//						path = np;
//					else
//						path = FindPathToActor(np);
					//if ( (path != none) && (enemyDistance < VSize(path.Location - Enemy.Location)) )
//					{
						// Looks like we have a new retreat point.
						cur = np;
						curPNDistanceToEnemy = test;
						useAsAlt = false;
//					}
				}
			}
			
			if (useAsAlt)	// Look at this spot if its not near the enemy.
			{
				// If the point is closer to the AI than the last alternate point that we saw, good.
				if ( (test < altPNDistanceToEnemy) || (alt == None) )
				{
					// Looks like we have a new alternative retreat point.
					alt = np;
					altPNDistanceToEnemy = test;
				}
			}
		}
	}
	
	// If the distance to the alternative point (one that requires the AI to perhaps run past then enemy)
	// is 1/4 the distance to the other spot, use it instead.  Or if we have no other choice...
	if ( (alt != None) && ((cur == None) || ((altPNDistanceToEnemy * 4) < curPNDistanceToEnemy)) )
	{
		//Log("MikeT: Alt Retreat Point found: " $alt $" Location: " $alt.Location $" Enemy Location: " $enemy.Location);
		//if (cur != None)
		//Log("MikeT: Retreat Point discarded: " $cur $" Location: " $cur.Location $" Enemy Location: " $enemy.Location);
		fLastRetreatPoint = alt;
		return alt;
	}
	
	//Log("MikeT: Retreat Point found: " $cur $" Location: " $cur.Location $" Enemy Location: " $enemy.Location);
	fLastRetreatPoint = cur;
	return cur;
}



function bool TeleportToMeleeRange(Actor victim, optional bool bFrontOnly, optional float minDist, optional float maxDist, optional float leadTime)
{
	/*
		Attempts to teleport near or ahead of an actor. Suffers from an indirect flaw
		in that there is no native call that can pre-check for a valid SetLocation
		call, although the internal native function FarMoveActor does have that capability.
	*/
	local float dist;
	local float angle;
	local vector loc;
	local rotator rot;
	local vector vx, vy, vz;
	local bool result;
	local int i, j, k;
	local float distarray[3];

	if (minDist == 0.0f)
		minDist = 100.0f; // !!!! What is a good default?
	if (maxDist == 0.0f)
		maxDist = 200.0f; // !!!! What is a good default?
	minDist += Pawn.CollisionRadius;
	maxDist += Pawn.CollisionRadius;

	dist = minDist + (maxDist - minDist) * Frand();
	angle = 32768.0f * FRand() - 16384.0f;
	rot = victim.Rotation;
	rot.Yaw += angle;
	GetAxes(rot, vx, vy, vz);

	loc = victim.Location + victim.Velocity * leadTime;

	result = Pawn.SetLocation(vx * dist + loc);

	if (!result)
	{
		distarray[0] = dist;
		distarray[1] = minDist;
		distarray[2] = maxDist;
		for (k=0;k<3 && !result;k++)
		{
			dist = distarray[k];

			// try -60,0,60 degrees
			j = Rand(3);
			for (i=0;i<3;i++)
			{
				rot = victim.Rotation;
				rot.Yaw += fRand60Deg[(i + j) % 3];
				GetAxes(rot, vx, vy, vz);
				result = Pawn.SetLocation(vx * dist + loc);
				if (result) break;
			}
		}

		if (!result && !bFrontOnly)
		{
			loc = victim.Location; // can't teleport forward of position in this case
			
			for (k=0;k<3 && !result;k++)
			{
				// try 120,180,240 degrees
				j = Rand(3);
				for (i=0;i<3;i++)
				{
					rot = victim.Rotation;
					rot.Yaw += (fRand60Deg[(i + j) % 3] + 32768.0f);
					GetAxes(rot, vx, vy, vz);
					result = Pawn.SetLocation(vx * dist + loc);
					if (result) break;
				}
			}
		}
	}

	if (result)
	{
		rot.Yaw += 32768.0f;
		Pawn.SetRotation(rot);
	}
	
	return result;
}


//*************************************************************************************************
// Overridden Bot operations.
//*************************************************************************************************

event PreBeginPlay()
{
	Super.PreBeginPlay();
	// NYI: Set this up according to the skill level specified by the map.
	InitializeSkill(4);
}


// First function that's called after the pawn is posessed.
function Restart()
{
	// Note: We do not call the super.Restart() on purpose.  It does things that we don't want it
	// to do.
	ReSetSkill();
	Focus = None;
	Enemy = None;

	if (!IsInState('Scripting'))
		WhatToDoNext( 0 );
}


function SetPeripheralVision()
{
	Pawn.PeripheralVision = FMin(0.2 - BaseAlertness, 0.9);
}



function eAttitude AttitudeToQuick(Pawn Other)
{
	if (Other.Health <= 0)
		return ATTITUDE_Ignore;

	if (B9_ArchetypePawnCombatant(Pawn) != None)
	{
		if (!B9_ArchetypePawnCombatant(Pawn).bHostile)
			return ATTITUDE_Ignore;
	}
	// If we're on the same faction, return true.
	if (B9_AdvancedPawn(Other) != None)
	{
		if (B9_AdvancedPawn(Other).fFaction == B9_AdvancedPawn(Pawn).fFaction)
			return ATTITUDE_Friendly;
	}

	return ATTITUDE_Hate;
}

function eAttitude AttitudeTo(Pawn Other)
{
	local B9_AdvancedPawn bud;
	
	if (Other.Health <= 0)
		return ATTITUDE_Ignore;

	if (B9_ArchetypePawnCombatant(Pawn) != None)
	{
		if (!B9_ArchetypePawnCombatant(Pawn).bHostile)
			return ATTITUDE_Ignore;
	}

//	if ( (Squad != None) && Squad.FriendlyToward(Other) )
//		return ATTITUDE_Friendly;
	
	// If we're on the same faction, return friendly.
	if (B9_AdvancedPawn(Other) != None)
	{
		if (B9_AdvancedPawn(Other).fFaction == B9_AdvancedPawn(Pawn).fFaction)
			return ATTITUDE_Friendly;
	}
		
	if ( bFrustrated || (B9_ArchetypePawnCombatant(Pawn) == None) || (Pawn == None) )
		return ATTITUDE_Hate;
	
	// Bots are brave if they outnumber the enemy, regardless of their relative strength and health.
	if ((fTimeLastCountedAllies + 5) < Level.TimeSeconds)
	{
		fTimeLastCountedAllies = Level.TimeSeconds;
		fNumAlliesCloseBy = 0;
		fNumEnemiesCloseBy = 0;
		ForEach Pawn.RadiusActors( class'B9_AdvancedPawn', bud, B9_ArchetypePawnCombatant(Pawn).fPainMessageRadius )
		{
			if (bud.fFaction == B9_AdvancedPawn(Pawn).fFaction)
				fNumAlliesCloseBy++;
			else //if (!Squad.FriendlyToward(bud))
				fNumEnemiesCloseBy++;
		}
	}
	if (fNumAlliesCloseBy > (fNumEnemiesCloseBy+1))
		return ATTITUDE_Hate;
	
	// If the bot is aggressive in numbers, it will attack irregardless of whether or not they
	// outnumber the enemy.
	if ( B9_ArchetypePawnCombatant(Pawn).fAggressiveInNumbers && (fNumAlliesCloseBy > 2) )
		return ATTITUDE_Hate;
	
	// If the enemy bot is much stronger than us, run away.
	if ( RelativeStrength(Other) > Aggressiveness + 0.44 - skill * 0.06 )
		return ATTITUDE_Fear;

	// If our health is lower than the LD settable fRetreatToCoverRatio of original health, become more conservative.
	if ( ( B9_ArchetypePawnCombatant(Pawn).fRetreatToCoverRatio * B9_AdvancedPawn(Pawn).fCharacterMaxHealth) > Pawn.Health )
		return ATTITUDE_Fear;

	return ATTITUDE_Hate;
}



function bool ShouldWalk()
{
	if( !B9_ArchetypePawnBase( Pawn ).fTryToRun )
		return true;
	else if( (Enemy != None) ||								// Always run to an enemy
			 (B9_ArchetypePawnBase( Pawn ).fAlwaysRun) ||	// Always obey flag
			 fOnAlert > 0)										// Someone hit an alarm
	{
		return false;
	}
	else if ( (fSetEnemy != None) && B9_ArchetypePawnBase(Pawn).fCheatAlwaysSeesEnemy )
		return false;
	else
		return true;
}


// Slows down the shucking and jiving of big bots.
function float GetStrafeDist()
{
	if (B9_ArchetypePawnBase( Pawn ).bIsBig)
		return (MINSTRAFEDIST * 0.5) * (Pawn.GroundSpeed / 200.0);
	else
		return Super.GetStrafeDist();
}



// We override WhatToDoNext() so that B9's custom behaviors can show up.
function WhatToDoNext( byte CallingByte )
{
	local B9_PlayerPawn N;
	local int dist;

//log("MikeT: WhatToDoNext");

	if (!fOriginalLocationSet)
	{
		//log("MikeT: Storing original pos.");
		fOriginalLocation = Pawn.Location;
		fOriginalRotation = Pawn.Rotation;
		fOriginalLocationSet = true;
		
		// NYI: Bots should pick up stuff sometimes.  Figure out how.
		Pawn.bCanPickupInventory = false;

		Enable('SeeMonster');
	}
	
	if ( B9_ArchetypePawnCombatant(Pawn).fPsychicKnowPlayerPosition && (fPlayer == None) )
	{
		// Find closest player.
		dist = 0;
		ForEach Pawn.AllActors(class'B9_PlayerPawn', N)
		{
			if (N.IsPlayer())
			{
				if ( (fPlayer == None) || (dist > VSize(N.Location - Pawn.Location)) )
				{
					fPlayer = N;
					dist = VSize(fPlayer.Location - Pawn.Location);
				}
			}
		}
		
		//log("MikeT: fPsychicKnowPlayerPosition: " $fPlayer);
		if (fPlayer != None)
		{
			B9_ArchetypePawnBase(Pawn).fCheatAlwaysSeesEnemy = true;
			fSetEnemy = fPlayer;
		}
	}

	if ( WillReturnToOrigPos() )
	{
		if (Enemy != None)
		{
			if (!LineOfSightTo(Enemy))
			{
				//Log("MikeT: Setting Enemy to None.");
				SetEnemy(None);
			}
		}

		if (Enemy == None)
		{
			if ( VSize(fOriginalLocation - Pawn.Location) > fDistanceToLocation )
			{
				//log("MikeT: Returning to original pos.");
				fTravelTarget = None;
				RouteGoal = None;
				Focus = None;
				SetRouteGoalLocation(fOriginalLocation);
				GoToState('AlertTravelToTarget');
				return;
			}
			else
			{
				//log("MikeT: Going to SentryAlert.");
				Focus = None;
				SetRotation(fOriginalRotation);
				GoToState('SentryAlert');
				return;
			}
		}
	}

	else if (IsSentry())
	{
		Focus = None;
		GotoState('Sentry');
		return;
	}

	else if (Enemy == None)
	{
		Enemy = None;

		if ( B9_ArchetypePawnBase(Pawn).fCheatAlwaysSeesEnemy && (fSetEnemy != None) && (fSetEnemy.Health > 0) )
		{
			SetRouteGoal(fSetEnemy);
			Focus = None;
			GotoState('AlertTravelToTarget');
			return;
		}
		
		switch(B9_ArchetypePawnBase(Pawn).fStartupState)
		{
			case kPatrolling:
				Focus = None;
				GotoState('Patrolling');
				return;
			
			case kWandering:
				Focus = None;
				GotoState('Wander');
				return;
			
			case kFollowLeader:
				if (Squad.SquadLeader != Self)
				{
					Squad.TellBotToFollow(Self, Squad.SquadLeader);
					return;
				}
			
			case kHunt:
				if (fPrey != None)
				{
					if (fPrey.Health > 0)
					{
						SetRouteToGoal(fPrey);
						return;
					}
					
					fPrey = None;
				}
		}
	}

	Super.WhatToDoNext(CallingByte);
}


function bool SetEnemy(Pawn P)
{
	local bool res;
	
	if (P != None && P.bHidden)
		return false;
	
	if ( (fPrey != None) && (fPrey.Health <= 0) )
		fPrey = None;
	
	if ( (B9_ArchetypePawnCombatant(Pawn).fLastGuyWhoShotMe != None) &&
		 (B9_ArchetypePawnCombatant(Pawn).fLastGuyWhoShotMe.Health <= 0) )
		B9_ArchetypePawnCombatant(Pawn).fLastGuyWhoShotMe = None;
	
	if (fPrey != None)
	{
		if (LineOfSightTo(fPrey))
			P = fPrey;
		else if (P != B9_ArchetypePawnCombatant(Pawn).fLastGuyWhoShotMe)
		{
			if ( (Enemy == None) && (B9_ArchetypePawnCombatant(Pawn).fLastGuyWhoShotMe != None) &&
				 LineOfSightTo(B9_ArchetypePawnCombatant(Pawn).fLastGuyWhoShotMe) )
				P = B9_ArchetypePawnCombatant(Pawn).fLastGuyWhoShotMe;
			else
				return false;
		}
	}
	
	if (!IsSentry())
	{
		if ( (P == None) && (B9_ArchetypePawnBase(Pawn) != None) && B9_ArchetypePawnBase(Pawn).fCheatAlwaysSeesEnemy &&
			 (fSetEnemy != None) && (fSetEnemy.Health > 0) )
		{
			SetRouteGoal(fSetEnemy);
			Focus = P;
			GotoState('AlertTravelToTarget');
		}
	}
	
	if (P != None)
		fSetEnemy = P;

	res = Super.SetEnemy(P);
	
	if ( (P == fPrey) && (fPrey != None) )
		Enemy = fPrey;
	
	return res;
}


function bool SetRouteToGoal(Actor A)
{
	if (!IsSentry())
	{
		SetRouteGoal(A);
		Focus = A;
		GoToState('AlertTravelToTarget');
		return true;
	}
	
	return false;
}



function bool FindRoamDest()
{
	local NavigationPoint N;
	local actor BestPath, HitActor;
	local vector HitNormal, HitLocation;
	local int Num;
	local actor goal;

	GoalString = "Find roam dest "$Level.TimeSeconds;
	goal = None;

	// first look for a scripted sequence
//	Squad.SetFreelanceScriptFor(self);
//	if ( GoalScript != None )
//		goal = GoalScript.GetMoveTarget();
	
	// find random NavigationPoint to roam to
	if (goal == None)
	{
		Num = Rand(6);
		ForEach RadiusActors(class'NavigationPoint',N,1000)
		{
			HitActor = Trace(HitLocation, HitNormal,N.Location, Pawn.Location,false);
			if ( HitActor == None )
			{
				goal = N;
				Num--;
				if ( Num < 0 )
					break;
			}
		}
	}
		
	if (goal != None)
	{
		fTravelTarget = goal;
		SetRouteToGoal(goal);
		return true;
	}
	
	if ( bSoaking && (Physics != PHYS_Falling) )
		SoakStop("COULDN'T FIND ROAM PATH TO "$RouteGoal);
	RouteGoal = None;
	FreeScript();
	GoalString = "Off navigation network - wandering";
	if ( FRand() < 0.5 )
		return false;

	Num = Rand(6);
	ForEach RadiusActors(class'NavigationPoint',N,1000)
	{
		HitActor = Trace(HitLocation, HitNormal,N.Location, Pawn.Location,false);
		if ( HitActor == None )
		{
			BestPath = N;
			Num--;
			if ( Num < 0 )
				break;
		}
	}
	SetRouteToGoal(BestPath);
	fTravelTarget = BestPath;
	return true;
}



function SetAttractionState()
{
	if (IsSentry())
		return;

	if ( Enemy != None )
	{
		Focus = Enemy;
		GotoState('FallBack');
	}
	else if (MoveTarget != None)
	{
		fTravelTarget = MoveTarget;
		Focus = MoveTarget;
		SetRouteToGoal(MoveTarget);
	}
	else
		FindRoamDest();
}


/*
	SB, Taldren, 5/31/03
	Fixed "accessed none" spam in the log
*/

function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
	if( FiredAmmunition == None && Pawn.Weapon != None )
	{
		FiredAmmunition = Pawn.Weapon.AmmoType;
	}

	return Super.AdjustAim( FiredAmmunition, projStart, aimerror );
}

/*
	SB End Changes
*/


/*
	SB, Taldren, 5/31/03
	Tring to get bots to shoot more convincingly
*/

function SetCombatTimer()
{
	//SetTimer(2.0 - 0.2 * Skill, True);
	SetTimer(fRand()*2 + 2.0 - 0.09 * FMin(10,Skill+ReactionTime), True);
}

function bool FireWeaponAt(Actor A)
{
	local B9WeaponBase	pWep;

	fFiredAfterRetreat = true;

	if ( A == None )
		A = Enemy;
	if ( (A == None) || (Focus != A) )
		return false;
	Target = A;
	if ( (Pawn.Weapon != None) && Pawn.Weapon.HasAmmo() )
	{
		//return WeaponFireAgain(Pawn.Weapon.RefireRate(),false);
		pWep = B9WeaponBase( Pawn.Weapon );
		if( pWep != None )
		{
			return WeaponFireAgain( pWep.GetROF(), false );
		}
	}
		
	return false;
}

function bool WeaponFireAgain(float RefireRate, bool bFinishedFire)
{
//	log( "WeaponFireAgain: RefireRate:"$RefireRate );

	if ( !Pawn.Weapon.IsFiring() )
	{
		if ( Target == None )
			Target = Enemy;
		if ( !NeedToTurn(Target.Location) && Pawn.Weapon.CanAttack(Target) )
		{
			Focus = Target;
			bCanFire = true;
//			log( "FireAgain Shooting1" );
			return Pawn.Weapon.BotFire(bFinishedFire);
		}
		else
		{
//			log( "FireAgain Stopped1" );
			bCanFire = false;
		}
	}
	else if ( bCanFire && (FRand() >= ( RefireRate * 0.5 ) ) )
	{
//		log( "FireAgain trying for shooting2" );

		if ( (Target != None) && (Focus == Target) && !Target.bDeleteMe )
		{
//			log( "FireAgain Shooting2" );
			return Pawn.Weapon.BotFire(bFinishedFire);
		}
	}
	StopFiring();
	return false;
}

/*
	SB End Changes
*/


function DoRetreat()
{
	local Actor node;

	if (IsSentry())
		return;

	//log("MikeT: Run away!  Run away!");
	if ( LostContact(9) && LoseEnemy() )
		return;
//	if ( Squad.PickRetreatDestination(self) )
//		GotoState('Retreating');

	if (fRetreated)
	{
		if (!fFiredAfterRetreat)
		{
			//log("MikeT: Firing from cover.");
			Focus = Enemy;
			GotoState('TacticalMove');
		}
	}

	node = FindPathnodeToRetreatTo();
	if (node != None)
	{
		SetRouteGoal(node);
		Focus = Enemy;
		GotoState('RetreatTravelToTarget');
		//log("MikeT: Running away...");
		return;
	}

	// if nothing, then tactical move
	if ( LineOfSightTo(Enemy) )
	{
		bFrustrated = true;
		Focus = Enemy;
		GotoState('TacticalMove');
		return;
	}
	if ( !LoseEnemy() )
		DoStakeOut();
}

function StartState()
{
	if (IsSentry())
		return;

	if (B9_ArchetypePawnCombatant(Pawn).fJumpAtEnemy)
	{
		if (Enemy == None)
			fFirstTimeSeeEnemy = true;

		if (fNextJumpTime < Level.TimeSeconds)
		{
			if ( (Enemy != None) && ActorReachable(Enemy) )
			{
				if (fFirstTimeSeeEnemy)
				{
					fFirstTimeSeeEnemy = false;
					fNextJumpTime = Level.TimeSeconds + 3 + frand() * 3;
				}
				else
				{
					fNextJumpTime = Level.TimeSeconds + 6 + frand() * 3;
					Focus = Enemy;
					GotoState('JumpAtEnemy');
				}
			}
		}
	}
}



//*************************************************************************************************
// Events
//*************************************************************************************************

function Tick( float timeDelta )
{
	Super.Tick(timeDelta);
	
	if (Enemy != None)
	{
		// NYI: Have a confused mode?  A looking and firing randomly mode?  Perhaps sometimes it can see the enemy?
		if (Enemy.bHidden)
			SetEnemy(None);
	}

	if ( (Enemy != None) && (B9_ArchetypePawnCombatant(Pawn) != None) )
	{
		if ( (fLastTimeGaveUpEnemyPosition + B9_ArchetypePawnCombatant(Pawn).fFrequencyOnGivingUpEnemyPosition) < Level.TimeSeconds)
		{
			if (B9_ArchetypePawnCombatant(Pawn).fWarnsAlliesAboutEnemies)
			{
				if (LineOfSightTo(Enemy))
					B9_ArchetypePawnBase(Pawn).EmitEnemySpottedMessage(Enemy);
			}
			fLastTimeGaveUpEnemyPosition = Level.TimeSeconds;
		}
	}
	else if (B9_ArchetypePawnBase(Pawn) != None)
	{
		B9_ArchetypePawnBase(Pawn).PlayIdleSpeech();
	}
}

event SeePlayer( Pawn Seen )
{
	if ( (Enemy == fPrey) && (fPrey != None) )
		return;

	if( (B9_ArchetypePawnBase( Pawn ).fAlarmGuard) && (fActorSeen == None) && (AttitudeToQuick(Seen) < ATTITUDE_Ignore) )
	{
		fActorSeen = Seen;
		fTravelTarget = FindNearestAlarmSwitch();
		// Flip all switches (AFSNOTE: May want to differentiate here in the future)
		FlipAllAlarms();
		fLastPlayerPos = Seen.Location;

		if (fTravelTarget != None)
		{
			SetEnemy(Seen);
			fOnAlert = fOnAlert + 1;// Small Bug: This will mean that even after the alarm is silenced, this NPC will still be on alrt.  THis could be explained by saying that since he/she saw the player, he/she will not be fooled by the alarm going silnt If it becomes a problem, we can change this of course.
			GoToTravelToAlarm();
			return;
		}
	}
	
	Super.SeePlayer(Seen);

	if (Enemy == None)
		Squad.FindNewEnemyFor(Self, false);
	
	if ( (Seen == fPrey) && (Seen != None) )
	{
		SetEnemy(fPrey);
		Enemy = fPrey;
	}
}


event SeeMonster( Pawn Seen )
{
	SeePlayer(Seen);
}



event HearNoise(float Loudness, Actor NoiseMaker)
{
	if (Enemy == None)
	{
		if ( !IsSentry() &&
			 ( ((Pawn.Alertness+2*Loudness+0.5) > (frand()*2)) ||
			   ((VSize(Pawn.Location - NoiseMaker.Location) < fDistanceToLocation) && (Pawn.Alertness >= 0)) ) )
		{
			Focus = None;
			SetRouteGoalLocation(NoiseMaker.Location);
			GoToState('AlertTravelToTarget');
		}

		// OK, we're not going to travel to the noise, mabe we should just turn and look at it.
		else if ( (Pawn.Alertness+4*Loudness+0.5) > (frand()*2) )
		{
			Focus = NoiseMaker;
			GoToState('TurnToFocus');
		}
	}
}



//-------------------------------------------------------------------------------------------------
// States created in this class.
//-------------------------------------------------------------------------------------------------


//*************************************************************************************************
// This state is for travelling to a target, whether it be an actor, or a position.  This state
// requires that the target be on the pathnode system.  If it discovers an enemy while travelling
// to the target, it will forget all about its destination, and attack it.
//*************************************************************************************************
state AlertTravelToTarget
{
	function bool CalculateNextMoveTarget()
	{
		// Ensure Routegoal is set to the fTravelTarget
		if (fTravelTarget != None)
			SetRouteGoal(fTravelTarget);
		
		// Get the next location to move to
		return FindNextBestPathToGoal();
	}

	function ETravelResponse ProcessTravelToTarget()
	{
		if (fRouteGoalLocationValid)
		{
			if (!CalculateNextMoveTarget())
				return kDefault;
		}
		else if( (fTravelTarget != None) && IsActorOnPathGrid( fTravelTarget ) )
		{
			// Calculate the next move target first, before anything else
			if( !CalculateNextMoveTarget() || (fTravelTarget == None) )
			{
				//log( "MikeT: ProcessTravelToTarget, exit: Can't find target, or target invalid: " $fTravelTarget );
				return kDefault;
			}
			
			// Note to self if AI can see travel target
			if( LineOfSightTo(fTravelTarget) )
			{
				//log( "MikeT: ProcessTravelToTarget, exit: kTargetLOS" );
				// Respond to visual
				return kTargetLOS;
			}
		}
		
		//log( "MikeT: ProcessTravelToTarget, exit: kNone" );
		return kNone;	// Perform no response by default
	}

	function StartupTravelToTarget()
	{
		//log( "MikeT: IN startup ProcessTravelToTarget, ID: " $self );
		fRestartTravelToTarget = false;
		Pawn.Acceleration = vect( 0, 0, 0 );
	}

	function float GetStopShortDeltaRatio()
	{
		return 1.20f;
	}

	function float GetStopShortDelta()
	{
		local vector	vecDiff;
		local vector	moveDir;
		local float		currentDistance;
		local float		InRadiusCheckRadius;
		local float		MoveToRadius;

		InRadiusCheckRadius = ( fTravelTarget.CollisionRadius + Pawn.CollisionRadius ) * GetStopShortDeltaRatio();
		MoveToRadius		= ( fTravelTarget.CollisionRadius + Pawn.CollisionRadius ) * GetStopShortDeltaRatio() - 0.10f;
		if (B9WeaponBase(Pawn.Weapon) != None)
		{
			if (MoveToRadius < B9WeaponBase(Pawn.Weapon).fMinRange)
				MoveToRadius = B9WeaponBase(Pawn.Weapon).fMinRange;
		}

		//log( "MikeT: stop short radius is: " $InRadiusCheckRadius );

		// Get the vector diff 
		vecDiff = fTravelTarget.Location - Pawn.Location;

		// Determine the movement vector
		moveDir = Normal( vecDiff );

		// Determine the current distance between this pawn and it's target
		currentDistance = VSize( vecDiff );

		// If the current distance is less then the desired distance, return a delta of zero
		// Epsilon is 20%, otherwise the collision avoidance will prevent this from ever 
		// happening
		if( currentDistance < InRadiusCheckRadius ) 
		{
			return 0;
		}
		else
		{
			// Otherwise, get the distance needed...
			//distDiff = currentDistance - MoveToRadius;
            //return distDiff;

			// Just return the distance as an offset
			return MoveToRadius;
		}
	}

	function bool HasReachedHuntTargetRadius()
	{
		if (fTravelTarget != None)
		{
			if( GetStopShortDelta() <= 0 )
				return true;
		}
		else if (fRouteGoalLocationValid)
			return VSize(fRouteGoalLocation - Pawn.Location) < fDistanceToLocation;

		return false;
	}

	function bool ShouldDoPostTravelAction()
	{
		return true;
	}
	
	function DoPostTravelAction()
	{
		//log("MikeT: WhatToDoNext()");
		WhatToDoNext(45);
	}
	
	function TravelAction()
	{
		if (Enemy != None)
			WhatToDoNext(46);
	}
	
Begin:
	// Start Travel
	//log( "MikeT: State AlertTravelToTarget" );
	StartupTravelToTarget();

KeepTravelling:

	fTravelActorReachable = false;

	//log( "MikeT: Before ProcessTravelToTarget." );
	// Setup travel
	switch( ProcessTravelToTarget() )
	{
		// kDefault is a travel result that basically means the AI is giving up on the hunt
		case kDefault:
			//log( "MikeT: Going to default state" );
			sleep( 0.5f );
			WhatToDoNext(47);
			break;

		case kTargetLOS:
			//log( "MikeT: Going to LOS Response state" );
			fTravelActorReachable = ( (fTravelTarget != None) && actorReachable(fTravelTarget) );
			break;

		case kPause:
			sleep( 0.5 );
			Goto( 'KeepTravelling' );
			break;
		
		case kNone:
		default:
		// Fall through
	};

	//log( "MikeT: Before move." );

	TravelAction();

	if( HasReachedHuntTargetRadius() )
	{
		//log("Miket: ReachedHuntTargetRadius()");
		Pawn.Acceleration = vect( 0, 0, 0 );
		MoveTo(Pawn.Location);
		if (ShouldDoPostTravelAction())
			DoPostTravelAction();
		if (fRestartTravelToTarget)
			Goto( 'KeepTravelling' );
	}
	else
	{
		if( ShouldGetAlternateMoveToLocation() )
		{
			if( !IsSentry() )
			{
				//log( "MikeT: Moving to alternate location" );
				Pawn.SetWalking( ShouldWalk() );
				if (Focus == None)
					MoveTo( GetAlternateMoveToLocation(), MoveTarget, ShouldWalk() );
				else
					MoveTo( GetAlternateMoveToLocation(), Focus, ShouldWalk() );
			}
		}
		else if( !IsSentry() )
		{
			Pawn.SetWalking( ShouldWalk() );
			if (Focus == None)
			{
	  			MoveToward( MoveTarget,,,, ShouldWalk() );
	  			Focus = None;
	  		}
	  		else
	  			MoveToward( MoveTarget, Focus,,, ShouldWalk() );
		}

		// Check for movement stalls.
		if (UpdateMovementStallTellTales())
			sleep( 0.1f );

		//log( "MikeT: going to KeepHunting" );
		// Stay in this state, until jumped out of it
		Goto( 'KeepTravelling' );
	}
	
	//log("Miket: Out of AlertTravelToTarget");
}



//*************************************************************************************************
// Travels to a target mindlessly, ignoring what's going on around.
//*************************************************************************************************
state TravelToTarget extends AlertTravelToTarget
{
	event SeePlayer( Pawn Seen )
	{
		// Do nothing
	}

	event HearNoise( float Loudness, Actor NoiseMaker)
	{
		// Do nothing
	}

	event EnemyNotVisible()
	{
		// Do nothing
	}

	event bool NotifyBump(actor Other)
	{
		return false;
	}

	function bool SetEnemy(Pawn P)
	{
		return false;
	}

	function BeginState()
	{
		//log("MikeT: State TravelToTarget");
		Focus = None;
	}
}



//*************************************************************************************************
// After seeing the player, this state has the bot run to the alrm to throw the switch, notify all
// of its friends, then go back and deal with the player.
//*************************************************************************************************
state TravelToAlarm extends TravelToTarget
{
	function AlertGuards()
	{
		local B9_Level_Alarm alarm;
		local B9_ArchetypePawnBase CombatPawn;
		local int index;


		CombatPawn = B9_ArchetypePawnBase( Pawn );
		// Now tell all combatants that there is an intruder -- ANF show and tell code.
		// Note: This affects this (self) pawn as well.
		if( CombatPawn != None )
		{
			foreach AllActors(class'B9_Level_Alarm', alarm)
			{
				//log("MikeT: Camera Spotted the player: " $Enemy);
				for(index = 0; index < CombatPawn.fAlarmList.length ;index++)
				{
					if( alarm.fAlarmNumber == CombatPawn.fAlarmList[index])
					{
						alarm.TurnAlarmOn(Enemy);
					}
				}
			}
		}		

	}

	function DoPostTravelAction()
	{
		if (!fHitAlarm)
		{
			// Play an anim of the AI activating the klaxon
			Pawn.PlayAnim( B9_ArchetypePawnBase( Pawn ).fActivateDeviceAnimationName );

			// Alert the guards!
			AlertGuards();
			
			fHitAlarm = true;
		}
		
		fTravelTarget = None;
		RouteGoal = None;
		Focus = Enemy;
		SetRouteGoalLocation(fLastPlayerPos);
		GoToState('AlertTravelToTarget');
	}
	
	function TravelAction()
	{
		if (fTravelActorReachable && (fTravelTarget != None))
			fLastPlayerPos = fTravelTarget.Location;
	}
}


//*************************************************************************************************
// Travel to a target, but attack the enemy while it can.
//*************************************************************************************************
state RetreatTravelToTarget extends TravelToTarget
{
	event SeePlayer( Pawn Seen )
	{
		Super.SeePlayer(Seen);
	}

	event HearNoise( float Loudness, Actor NoiseMaker)
	{
		Super.HearNoise(Loudness, NoiseMaker);
	}
	
	event EnemyNotVisible()
	{
		// Do nothing.
	}

	function Timer()
	{
		if (Enemy != None)
			FireWeaponAt(Enemy);
	}

	function TravelAction()
	{
	}

	function BeginState()
	{
		//log("MikeT: State RetreatTravelToTarget");
		fRetreated = false;
		fFiredAfterRetreat = false;
		Focus = Enemy;
	}
	
	function EndState()
	{
		fRetreated = true;
		fFiredAfterRetreat = false;
	}
}



//*************************************************************************************************
// Have the bot run between specified patrol points, and attack the player if it sees him/her.
//*************************************************************************************************
state Patrolling extends AlertTravelToTarget
{
	function FindNextGoal()
	{
		local PathNodeNamed namedNode;
		local PathNodeNamed closestNode;
		local PathNodeNamed lastDiscardedNodeSelection;
		local float			closestNodeRange;
		local float			rangeToNode;

		//log( "MikeT: IN FINDNextGoal" );

		closestNodeRange = 999999;
		
		// Try to find the nearest node that this actor is supposed to patrol
		ForEach Pawn.AllActors( class'PathNodeNamed', namedNode )
		{
			// Is this the correct node? (if none is defined for this AI's patrol name, any will do)
			if( B9_ArchetypePawnBase( Pawn ).fPatrolName == 'None' || 
				B9_ArchetypePawnBase( Pawn ).fPatrolName == namedNode.fName )
			{
				//log( "MikeT: Found at least one patrol node" );

				if (namedNode != RouteGoal)
				{
					if( namedNode != fLastPathNodeNamed )
					{
						rangeToNode = VSize( Pawn.location - namedNode.Location );
						if( rangeToNode < closestNodeRange )
						{
							//log( "MikeT: Found at least one USABLE patrol node" );

							closestNode			= namedNode;
							closestNodeRange	= rangeToNode;
						}
					}
					else
						lastDiscardedNodeSelection = namedNode;
				}
			}
		}

		if( closestNode != None )
		{
			if( (RouteGoal != None) && RouteGoal.IsA( 'PathNodeNamed' ) )
				fLastPathNodeNamed = PathNodeNamed( RouteGoal );
			else
				fLastPathNodeNamed = None;

			SetRouteGoal(closestNode);
		}
		else
		{
			if( lastDiscardedNodeSelection != None )
			{
				if( (RouteGoal != None) && RouteGoal.IsA( 'PathNodeNamed' ) )
					fLastPathNodeNamed = PathNodeNamed( RouteGoal );
				else
					fLastPathNodeNamed = None;

				SetRouteGoal(lastDiscardedNodeSelection);
			}
			else
			{
				//log( "MikeT: AI can't find a RouteGoal " $Self );
			}
		}
		
		fTravelTarget = RouteGoal;
	}
	
	function StartupTravelToTarget()
	{
		//log("MikeT: State Patrolling");
		fRestartTravelToTarget = true;
		//log( "MikeT: IN Patrolling::StartupTravelToTarget, ID: " $self );
		Pawn.Acceleration = vect( 0, 0, 0 );
		FindNextGoal();
		if (fTravelTarget == None)
		{
			log("MikeT: No patrol points defined with name " $B9_ArchetypePawnBase( Pawn ).fPatrolName);
			B9_ArchetypePawnBase( Pawn ).fStartupState = kDefault;
			WhatToDoNext(48);	// There are no points to patrol.
		}
	}

	
	function DoPostTravelAction()
	{
		FindNextGoal();
		fRestartTravelToTarget = true;
	}
}



//*************************************************************************************************
// Stay in place and wait to die... uh, wait for the player to show up so it can be a fixed target.
//*************************************************************************************************
state Sentry
{
	function bool SetEnemy(Pawn P)
	{
		Enemy = P;	// Note: The squad actually sets the enemy.
		Squad.SetEnemy(self,P);
		return true;
	}

	event SeePlayer( Pawn Seen )
	{
		if (AttitudeTo(Seen) < ATTITUDE_Ignore)
			SetEnemy(Seen);
	}

	event HearNoise(float Loudness, Actor NoiseMaker)
	{
		if (Enemy == None)
		{
			if ( ((Pawn.Alertness+2*Loudness+0.5) > (frand()*2)) ||
				((VSize(Pawn.Location - NoiseMaker.Location) < fDistanceToLocation) && (Pawn.Alertness >= 0)) )
			{
				Focus = NoiseMaker;
			}
		}
	}

Begin:
	//log("Miket: State Sentry");
Loop:
	Pawn.Acceleration = vect( 0, 0, 0 );
	Pawn.GroundSpeed = 0;
	// Look for enemy, and turn towards it if found.
	if (Enemy != None)
	{
		Target = Enemy;
		Focus = Target;
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
		if ( NeedToTurn(Target.Location) )
			FinishRotation();
		FireWeaponAt(Enemy);
		Sleep(0.1);
	}
	else if (Focus != None)
	{
		if ( NeedToTurn(Focus.Location) )
			FinishRotation();
		Sleep(0.25);
	}
	else
		Sleep(0.5);
	
	Goto('Loop');
}



//*************************************************************************************************
// Wait in place for the player to show up.
//*************************************************************************************************
state SentryAlert
{
	event SeePlayer( Pawn Seen )
	{
		if (AttitudeTo(Seen) < ATTITUDE_Ignore)
			SetEnemy(Seen);
	}

Begin:
	//log("MikeT: Sentry Alert start.");
	Focus = None;
	SetRotation(fOriginalRotation);
	FinishRotation();
	
	// Wait for an enemy to show up to shoot and chase.
	while (Enemy == None)
		Sleep(0.5);

	WhatToDoNext(49);
}



//*************************************************************************************************
// Travel to the enemy's current position.  This was probably sent as a message from another bot,
// or a sensor like a camera.  If the bot sees the enemy, it will attack it.
//*************************************************************************************************
state GotoEnemyPosition extends AlertTravelToTarget
{
	function StartupTravelToTarget()
	{
		//log("MikeT: State GotoEnemyPosition");
		fRestartTravelToTarget = false;
		//log( "MikeT: IN GotoEnemyPosition::StartupTravelToTarget, ID: " $self );
		if (Enemy == None)
		{
			//log("MikeT: No Enemy assigned in state GotoEnemyPosition");
			WhatToDoNext(50);	// There is no enemy to go after.
		}
		else
		{
			Pawn.Acceleration = vect( 0, 0, 0 );
			SetRouteGoalLocation(Enemy.Location);
		}
	}
}



//*************************************************************************************************
// This state has the AI wander around the map when it has nothing to shoot at.
//*************************************************************************************************
state Wander extends AlertTravelToTarget
{
	function StartupTravelToTarget()
	{
		local actor pos;

		//log("MikeT: State Wander");
		Focus = None;
		// first look for a scripted sequence
		fRestartTravelToTarget = true;
		pos = None;
//		Squad.SetFreelanceScriptFor(self);
//		if ( GoalScript != None )
//			pos = GoalScript.GetMoveTarget();

		if (pos == None)
			pos = FindRandomNavpoint();
		SetRouteGoal(pos);
		fTravelTarget = pos;
	}

	function bool ShouldDoPostTravelAction()
	{
		return true;
	}

	function DoPostTravelAction()
	{
		fRestartTravelToTarget = true;
		StartupTravelToTarget();
	}
	
	function TravelAction()
	{
		fRestartTravelToTarget = true;
		if (Enemy != None)
			WhatToDoNext(51);
	}

	function bool CalculateNextMoveTarget()
	{
		// Ensure Routegoal is set to the fTravelTarget
		if (fTravelTarget != None)
			SetRouteGoal(fTravelTarget);
		
		// Get the next location to move to
		if (!FindNextBestPathToGoal())
		{
			StartupTravelToTarget();
			return FindNextBestPathToGoal();
		}
		
		return true;
	}
}



//*************************************************************************************************
// Functions for the scripting state.
//*************************************************************************************************
State Scripting
{
	event SeePlayer( Pawn Seen )
	{
		// Do nothing
	}

	event HearNoise( float Loudness, Actor NoiseMaker)
	{
		// Do nothing
	}

	event EnemyNotVisible()
	{
		// Do nothing
	}

	function BeginState()
	{
		//log( "MikeT: In Scripting::BeginState()" );
		Super.BeginState();

		// Ensure combatants have weapons
		//log( "MikeT: In Scripting::BeginState(), for calling SetupWeapon()" );
		//SetupWeapon();
		//log( "MikeT: In Scripting::BeginState(), after calling SetupWeapon()" );
	}
	
	// Don't call the Super.LeaveScripting() becuase it destroys the pawn and controller.
	function LeaveScripting()
	{
		//log( "MikeT: In Scripting::LeaveScripting()" );
		//WhatToDoNext(52);
	}
}



//*************************************************************************************************
// State to jump at the enemy.
//*************************************************************************************************
state JumpAtEnemy
{
	function JumpTowardsEnemy()
	{
		fStoreJump = Pawn.bCanJump;
		if ( (Pawn != None) && (Pawn.JumpZ > 0) )
			Pawn.bCanJump = true;

		// try jump move
		Pawn.Velocity = vector(Pawn.Rotation) * Pawn.GroundSpeed * 2.0;
		Pawn.bIsWalking = false;
		Pawn.bNoJumpAdjust = true;
		Pawn.bPhysicsAnimUpdate = false;
		Destination = Enemy.Location;
		Pawn.DoJump(false);
		Pawn.PlayJump();
	}

	function bool TurnTowardEnemy()
	{
		// Face the target
		Focus = Enemy;
		// Turn toward the target
		return ( NeedToTurn( Focus.Location ) );
	}

/*
	event AnimEnd(int Channel)
	{
		fJumped = false;
		JumpTowardsEnemy();
	}
*/


Begin:
	//log("MikeT: State Jump at enemy");
	if (Pawn.Physics == PHYS_Falling)
	{
		Focus = Enemy;
		Destination = Enemy.Location;
		WaitForLanding();
	}

	// Ensure AI is pointed toward it's target
	if( TurnTowardEnemy() )
		FinishRotation();
	
	JumpTowardsEnemy();

	WaitForLanding();
	Pawn.bCanJump = fStoreJump;
	Pawn.bNoJumpAdjust = false;
	Pawn.Velocity = vector(Pawn.Rotation) * Pawn.GroundSpeed;
	Pawn.bPhysicsAnimUpdate = true;
	Focus = Enemy;
	GotoState('TacticalMove');
}



state TurnToFocus
{
	function bool TurnTowardEnemy()
	{
		// Turn toward the target
		return ( NeedToTurn( Focus.Location ) );
	}

Begin:
	if (Pawn.Physics == PHYS_Falling)
		WaitForLanding();

	// Ensure AI is pointed toward the focus.
	if( (Focus != None) && NeedToTurn(Focus.Location) )
		FinishRotation();

	WhatToDoNext( 0 );
}


//--------------------------------------------------------------------------------------------------
// Overridden states.
//--------------------------------------------------------------------------------------------------




defaultproperties
{
	fRand60Deg[0]=-10922
	fRand60Deg[2]=10922
	fFirstTimeSeeEnemy=true
}