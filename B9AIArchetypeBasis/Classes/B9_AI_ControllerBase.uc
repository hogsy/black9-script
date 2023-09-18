//////////////////////////////////////////////////////////////////////////
//
// Black 9 Artificial Intelligence Controller Base Class
//
//////////////////////////////////////////////////////////////////////////
//class B9_AI_ControllerBase extends AIController;
class B9_AI_ControllerBase extends ScriptedController;

// Variables
var Actor			fCurrentNavPoint;
var Actor			fBestPath;
var	bool			bCanFire;
var float			fThinkTimerInterval;

var vector			fRouteGoalLocation;
var vector			pos;
var bool			fRouteGoalLocationValid;
var bool			fLongWait;	// Whether to wait longer between hunting and travelling calculations.

var int				fDialogueStartIndex;
var int				fFaceToFace;
var name			fDialoguePrevState;
var name			fFirstState;
var PathNodeNamed	fLastPathNodeNamed;

// Blocking 
/*
var vector			fPreviousLocation;
var float			fBlockLastTime;
*/

var bool	fShouldAlternateMoveToLocation;
var vector	fLastMovementPosition;

var float			fRand60Deg[3];

//var name	fTargetLOSResponseState;
var name	fDefaultState;
var name	fDesiredState;
var name	fPostHuntActionState;

var Actor	fHuntingForActor;
var bool	fHuntedActorReachable;

var bool	fReachedHuntedActor;
var bool	fHuntedActorReachedEventFired;
var bool	fHuntedMoveToUsed;

var bool	fRunForAWhile;		// Whether the AI should run for a while.  Typically, this is after the AI has seen an enemy, but lost track of him/her.
var float	fRunForAWhileTo;	// How long the AI should be running.

var bool	fAllAlarmSwitchesFlipped;

var bool	fAboutToDieCalled;

var Pawn	fActorSeen;
var Pawn	fActorSeenAlarm;

var bool	fHuntMoving;
var float	fPauseFor;
var float	fDistanceToLocation;

// Hiding state variables
var PathNode		fBadHidingPlace;
var PathNode		fLastHidingPlace;

var Vector			fOriginalLocation;
var Rotator			fOriginalRotation;
var bool			fOriginalLocationSet;

// Consts
//const kMaxBlockTimeBeforeMovePauseCheck = 0.5f;

enum EStateResponse
{
	kNone,
	kDefault,
	kTargetLOS,
	kPause,
};

enum EHuntTargetReachedReaction
{
	kNoReaction,
	kActivateAlarm,
};

// Hunting
var float	fHuntingTimeElapsed;
var EHuntTargetReachedReaction fHuntTargetReachedReaction;


// Global

function Tick( float timeDelta )
{
	fHuntingTimeElapsed += timeDelta;
	// Update cloak
	UpdateCloak( timeDelta );
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
}

// Call this function when the goal the actor should reach is a location.
function SetRouteGoalLocation(Vector location)
{
	RouteGoal = None;
	fRouteGoalLocation = location;
	fRouteGoalLocationValid = true;
}


function bool ReachedRouteGoal()
{
	if (RouteGoal == None)
	{
		if (fRouteGoalLocationValid)
			return VSize(fRouteGoalLocation - Pawn.Location) < fDistanceToLocation;
		else
			return true;  // If we don't have a goal then we must be there already...
	}

	return ( Pawn.ReachedDestination( RouteGoal ) );
}

function bool ReachedMoveTarget()
{
	return (Pawn.ReachedDestination(MoveTarget));
}


// Events
event SeePlayer( Pawn Seen )
{
	if( !fAllAlarmSwitchesFlipped )
	{
		//log( "MikeT: In global Seeplayer event, IN state: " $GetStateName() );

		// Who?
		fActorSeen = Seen;

		// Do something about it
		GotoState( 'PlayerSpotted' );
	}
}

event SeeMonster( Pawn Seen )
{
		
}

auto state StartingState
{
	function init()
	{
		// Enable the 'SeePlayer' event
		//enable( 'SeePlayer' );	

		//Log( "MikeT: Seeplayer enabled" );

		if (!fOriginalLocationSet)
		{
			fOriginalLocation = Pawn.Location;
			fOriginalRotation = Pawn.Rotation;
			fOriginalLocationSet = true;
		}
	}
	
begin:
	//log( "MikeT: In starting state" );
	init();

	switch( B9_ArchetypePawnBase( Pawn ).fStartupState )
	{
		case kPatrolling:
				GotoState( 'Patrolling' );
			break;

//		case kHiding:
//				GotoState( 'Hide' );
//			break;

		default:
			//log( "MikeT: Going to state: " $fFirstState );
			GotoState( fFirstState );
			break;
	}
}

State Scripting
{
	event SeePlayer( Pawn Seen )
	{
		// Do nothing
	}

	function BeginState()
	{
		//log( "MikeT: In Scripting::BeginState()" );
		Super.BeginState();

		// Ensure combatants have weapons
		//log( "MikeT: In Scripting::BeginState(), for calling SetupWeapon()" );
		SetupWeapon();
	}
	
	// Don't call the Super.LeaveScripting() becuase it destroys the pawn and controller.
	function LeaveScripting()
	{
		//log( "MikeT: In Scripting::LeaveScripting()" );

		//log( "MikeT: Going to starting state from script state: "$fFirstState $" Controller: " $self );
		GotoState( fFirstState );

		//log( "MikeT: Now in state: " $GetStateName() );
		//log( "MikeT: In Scripting::LeaveScripting(), Calling allow think and setup timer" );

		// Call the constructor for this bot
		Constructor();

		//log( "MikeT: Now leaving the LeavingScript() state: "$GetStateName() );
	}
}

state Travel
{
	function bool AlternateAction() { return false; }

	function bool ProcessTraveling()
	{
		// Process goal finding
		if (ReachedRouteGoal())
		{
			fCurrentNavPoint = fBestPath;
			FindNextGoal();
		}

		// Get the next location to move to
		return FindNextBestPathToGoal();
	}

	function FindNextGoal()
	{
		// Setup local variables
		local int kMaxAttempts;
		local int attempt;
		local bool ladderSpot;
		local bool lookingForNewNavPoint;
		local Actor proposedNavGoal;

		kMaxAttempts			= 5;
		attempt					= 0;
		ladderSpot				= false;
		lookingForNewNavPoint	= false;
		proposedNavGoal			= RouteGoal;
		
		// Invalidate current route goal
		SetRouteGoal(None);

		// Disallow the current spot the actor is occuying
		// Try only kMaxAttempts times 
		// And ensure the spot is not on a ladder
		while( attempt < kMaxAttempts )
		{
			lookingForNewNavPoint = true;
			proposedNavGoal = FindRandomDest();
			
			//log( "RouteGoal is: " $ RouteGoal );
			attempt++;

			if( AutoLadder( RouteGoal ) != None )
			{
				ladderSpot = true;
			}
			else
			{
				ladderSpot = false;
			}

			// Early done?
			if( !ladderSpot && 
				(proposedNavGoal != fCurrentNavPoint) && 
				(proposedNavGoal != None) )
			{
				SetRouteGoal(proposedNavGoal);
				break;
			}
		}

		if( RouteGoal == None )
		{
			//log( "MikeT: AI can't find a RouteGoal " $Self );
		}
	}

	function Start()
	{
		//log( "MikeT: In travel state" );
		if (!fOriginalLocationSet)
		{
			fOriginalLocation = Pawn.Location;
			fOriginalRotation = Pawn.Rotation;
			fOriginalLocationSet = true;
		}

		Pawn.Acceleration = vect( 0, 0, 0 );

		// We are the current desired state 
		fDesiredState = 'Travel';	
	}

StopMoving:
	MoveTo( Self.Pawn.Location, Focus );
	Goto( 'KeepTraveling' );

Begin:
	Start();

KeepTraveling:

	// If there is an fHuntingForActor, see if this AI wants to hunt
	if( B9_ArchetypePawnBase( Pawn ).bAllowHunting )
	{
		//log( "MikeT: Hunting allowed" );

		// Does this AI have a current fHuntingForActor?
		if( fHuntingForActor != None )
		{
			//log( "MikeT: Going to hunting state from Travel state" );

			// Start hunting
			GotoState( 'Hunting' );
		}
	}

	if (WillReturnToOrigPos())
	{
		if ( VSize(fOriginalLocation - Pawn.Location) > fDistanceToLocation )
		{
			SetRouteGoalLocation(fOriginalLocation);
			Pawn.SetWalking(false);
			FindNextBestPathToGoal();
			MoveToward(MoveTarget, MoveTarget,, false);
		}
		else
		{
			// Rotate back to the original direction.
			if (Rotation != fOriginalRotation)
			{
				Focus = None;
				SetRotation(fOriginalRotation);
				FinishRotation();
			}
				
		}
	}
	// Unless there is an alternate travel action...
	else if( !AlternateAction() )
	{
		// Setup travel
		if( !ProcessTraveling() )
		{
			//log( "MikeT: COULD NOT find a path to follow" );
			Pawn.Acceleration = vect( 0, 0, 0 );
			sleep( 10.0 );
		}
		
		if( ShouldGetAlternateMoveToLocation() )
		{
			if( !IsSentry() )
			{
				//log( "MikeT: Moving to alternate location" );
				Pawn.SetWalking( IsWalking() );
				MoveTo( GetAlternateMoveToLocation(), MoveTarget, IsWalking() );
			}
		}
		else
		{
			if( !IsSentry() )
			{
				// Move
				Pawn.SetWalking( IsWalking() );
				MoveToward( MoveTarget, MoveTarget,,IsWalking() );
			}

			// Check for movement stalls.
			UpdateMovementStallTellTales();
		}
	}

	// This is required, otherwise it will starve every other system
	// in the game.
	//log( "MikeT: Right before sleep in traveling" );
	if (fLongWait)
		sleep( 0.5 );
	else
		sleep( 0.1f );

	// Stay in this state, until jumped out of it
	Goto( 'KeepTraveling' );
}

state Hunting
{
// AFSNOTE: the Ignores keyword does not appear to function when a state enters a latent function.  
// Use and overloaded function instead.
//ignores SeePlayer, HearNoise;
	
	event SeePlayer( Pawn Seen )
	{
		//log( "MikeT: IN Seeplayer in the hunting state" );
	}

	event HearNoise( float Loudness, Actor NoiseMaker)
	{
		// Do nothing
	}

	function bool CalculateNextMoveTarget()
	{
		// Ensure Routegoal is set to the fHuntingForActor
		SetRouteGoal(fHuntingForActor);
		
		// Get the next location to move to
		return FindNextBestPathToGoal();
	}

	function EStateResponse ProcessHunting()
	{
		if( fHuntingForActor != None && IsActorOnPathGrid( fHuntingForActor ) )
		{
			// Calculate the next move target first, before anything else
			if( !CalculateNextMoveTarget() || (fHuntingForActor == None) )
			{
				//log( "MikeT: ProcessHunting, exit: Can't find target, or target invalid: " $fHuntingForActor );
				return kDefault;
			}
			
			// Note to self if AI can see hunting target
			if( LineOfSightTo(fHuntingForActor) )
			{
				//log( "MikeT: ProcessHunting, exit: kTargetLOS" );
				// Respond to visual
				return kTargetLOS;
			}
		}
		
		//log( "MikeT: ProcessHunting, exit: kNone" );
		return kNone;	// Perform no response by default
	}

	function Tick( float timeDelta )
	{
		fHuntingTimeElapsed += timeDelta;
		// Update cloak
		UpdateCloak( timeDelta );
	}

	function StartupHunting()
	{
		//log( "MikeT: IN startup hunting, ID: " $self );

		if (!fOriginalLocationSet)
		{
			fOriginalLocation = Pawn.Location;
			fOriginalRotation = Pawn.Rotation;
			fOriginalLocationSet = true;
		}

		//log( "MikeT: In hunting state" );
		Pawn.Acceleration = vect( 0, 0, 0 );

		// Reset the hunting time elapsed
		fHuntingTimeElapsed	= 0;

		// Set hunt to desired state.
		fDesiredState = 'Hunting';
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

		InRadiusCheckRadius = ( fHuntingForActor.CollisionRadius + Pawn.CollisionRadius ) * GetStopShortDeltaRatio();
		MoveToRadius		= ( fHuntingForActor.CollisionRadius + Pawn.CollisionRadius ) * GetStopShortDeltaRatio() - 0.10f;
		if (B9WeaponBase(Pawn.Weapon) != None)
		{
			if (MoveToRadius < B9WeaponBase(Pawn.Weapon).fMinRange)
				MoveToRadius = B9WeaponBase(Pawn.Weapon).fMinRange;
		}

		//log( "MikeT: stop short radius is: " $InRadiusCheckRadius );

		// Get the vector diff 
		vecDiff = fHuntingForActor.Location - Pawn.Location;

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

	function bool NextMoveTargetIsHuntingTarget()
	{
		if( B9_ArchetypePawnBase( Pawn ).fStopShortOfHuntTarget )
		{
			if( MoveTarget == fHuntingForActor )
			{
				return true;
			}
		}
	}

	function bool HasReachedHuntTargetRadius()
	{
		if (fHuntingForActor != None)
		{
			if( GetStopShortDelta() <= 0 )
			{
				return true;
			}
		}
		else
		{
			//log("MikeT: fHuntingForActor is None");
		}

		return false;
	}

	function bool ShouldStopShort()
	{
		return B9_ArchetypePawnBase( Pawn ).fStopShortOfHuntTarget;
	}

	function bool DoPostHuntingAction()
	{
		if( fPostHuntActionState != 'None' && 
			fActorSeenAlarm == None )
		{
			//log( "MikeT: Doing post hunting action" );
			return true;
		}
		else
		{
			//log( "MikeT: NOT Doing post hunting action" );
			return false;
		}
	}
	
StopMoving:
	//MoveToward( Self.Pawn );
	MoveTo( Self.Pawn.Location, Enemy );
	Goto( 'KeepHunting' );

Begin:

	//log( "At BEGIN hunting" );
	
	// Start hunting
	StartupHunting();

KeepHunting:

	//log( "At KEEPHUNTING hunting" );

	fHuntedActorReachable = false;

	// Has the hunting timer expired?  If so, return to the default state
	if ( (fHuntingTimeElapsed > B9_ArchetypePawnBase( Pawn ).fHuntingTimeLimit) ||
		 ( (B9_ArchetypePawnBase(fHuntingForActor) != None) && (B9_ArchetypePawnBase(fHuntingForActor).Health <= 0) ) )
	{
		//log( "MikeT: Hunting time elapsed, or fHuntingForActor is dead, going to state: " $fDefaultState );
		
		// Clear the fHuntingForActor field, otherwise the AI will start hunting it's target again
		fHuntingForActor = None;
		Enemy = None;
		
		// Goto the default state for this AI
		GotoState( fDefaultState );
	}

	//log( "MikeT: Before processhunting." );
	
	// Setup travel
	switch( ProcessHunting() )
	{
		// kDefault is a hunting result that basically means the AI is giving up on the hunt
		case kDefault:
			//log( "MikeT: Going to default state" );
			sleep( 0.5f );
			GotoState( fDefaultState );
			break;

		case kTargetLOS:
			//log( "MikeT: Going to LOS Response state" );
			if( fHuntingForActor != None && actorReachable( fHuntingForActor ) )
			{
				fHuntedActorReachable = true;
			}
			break;

		case kPause:
			//log( "MikeT: Pausing for" $fPauseFor $"seconds." );
			sleep( fPauseFor );
			Goto( 'KeepHunting' );
			break;
		
		case kNone:
		default:
		// Fall through
	};

	//log( "MikeT: Before move." );

	if( ShouldGetAlternateFiringLocation() )
	{
		if( !IsSentry() )
		{
			//log( "MikeT: Moving to alternate location" );
			Pawn.SetWalking( IsWalking() );
			pos = GetAlternateFiringLocation();
			
			if (MoveTarget == None)
	  			MoveTo(pos, fHuntingForActor, IsWalking() );	
	  		else
				MoveToward( MoveTarget, fHuntingForActor,, IsWalking() );
			//log( "MikeT: Latent Moving to alternate location done" );
		}
	}
	else
	{
		if( HasReachedHuntTargetRadius() )
		{	
			fHuntMoving = false;

			if( !fHuntedActorReachedEventFired )
			{
				//log( "MikeT: Going to 'HuntTargetReached' state from within an offset movement"  );
				
				fHuntedActorReachedEventFired = true;
				GotoState( 'HuntTargetReached' );		
			}
		}
		else
		{
			fHuntedActorReachedEventFired = false;
			fHuntMoving = true;

			if( ShouldGetAlternateMoveToLocation() )
			{
				if( !IsSentry() )
				{
					//log( "MikeT: Moving to alternate location" );
					Pawn.SetWalking( IsWalking() );
  					MoveTo( GetAlternateMoveToLocation(), fHuntingForActor, IsWalking() );	
				}
			}
			else
			{
				if( !IsSentry() )
				{
					Pawn.SetWalking( IsWalking() );
  					MoveToward( MoveTarget, MoveTarget,, IsWalking() );
				}

				// Check for movement stalls.
				UpdateMovementStallTellTales();
			}
		}
	}

	//log( "MikeT: Before Postactionstate." );
	
	// Do something other then just hunting?
	if( DoPostHuntingAction() )
	{
		//log( "MikeT: Executing post hunt action state" );
		GotoState( fPostHuntActionState );
	}

	// This is required, otherwise it will starve every other system
	// in the game.
	//log( "MikeT: Right before sleep in hunting" );
	if (fLongWait)
		sleep( 0.5 );
	else
		sleep( 0.1f );

	//log( "MikeT: going to KeepHunting" );
	// Stay in this state, until jumped out of it
	Goto( 'KeepHunting' );
}

state Patrolling extends Travel
{
	function Start()
	{
		Super.Start();
		
		// This is now the desired state
		fDesiredState = 'Patrolling';
	}

	function FindNextGoal()
	{
		local PathNodeNamed namedNode, closestNode, lastDiscardedNodeSelection;
		local float closestNodeRange, rangeToNode;

		//log( "MikeT: IN FINDNextGoal" );

		closestNodeRange = 999999;
		
		// Try to find the nearest node that this actor is supposed to patrol
		ForEach Pawn.AllActors( class'PathNodeNamed', namedNode )
		{
			rangeToNode = VSize( Pawn.location - namedNode.Location );
			
			// Is this the correct node? (if none is defined for this AI's patrol name, any will do)
			if( B9_ArchetypePawnBase( Pawn ).fPatrolName == 'None' || 
				B9_ArchetypePawnBase( Pawn ).fPatrolName == namedNode.fName )
			{
				//log( "MikeT: Found at least one patrol node" );

				if( namedNode != RouteGoal )
				{
					if( namedNode != fLastPathNodeNamed )
					{
						if( rangeToNode < closestNodeRange )
						{
							//log( "MikeT: Found at least one USABLE patrol node" );

							closestNode			= namedNode;
							closestNodeRange	= rangeToNode;
						}
					}
					else
					{
						lastDiscardedNodeSelection = namedNode;
					}
				}
			}
		}

		if( closestNode != None )
		{
			if( RouteGoal.IsA( 'PathNodeNamed' ) )
			{
				fLastPathNodeNamed = PathNodeNamed( RouteGoal );
			}
			else
			{
				fLastPathNodeNamed = None;
			}

			SetRouteGoal(closestNode);
		}
		else
		{
			if( lastDiscardedNodeSelection != None )
			{
				if( RouteGoal.IsA( 'PathNodeNamed' ) )
				{
					fLastPathNodeNamed = PathNodeNamed( RouteGoal );
				}
				else
				{
					fLastPathNodeNamed = None;
				}

				SetRouteGoal(lastDiscardedNodeSelection);
			}
			else
			{
				//log( "MikeT: AI can't find a RouteGoal " $Self );
			}
		}
	}
}

state PlayerSpotted
{
//ignores SeePlayer, HearNoise;

	event SeePlayer( Pawn Seen )
	{
		// Do nothing
	}

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

		fAllAlarmSwitchesFlipped = allSwitchesFlipped;
		
		return nearestAlarmSwitch;
	}

	function FlipAllAlarms()
	{
		local B9_PathNodeAlarmSwitch	alarmSwitch;

		ForEach Pawn.AllActors( class'B9_PathNodeAlarmSwitch', alarmSwitch )
		{
			alarmSwitch.fFlipped = true;
		}

		// This becomes true.
		fAllAlarmSwitchesFlipped = true;
	}

begin:
	//log("MikeT: fActorSeen: " $fActorSeen);
	
	// Is this an alarm guard?
	if( B9_ArchetypePawnBase( Pawn ).fAlarmGuard && 
		fActorSeen != None )
	{
		//log( "MikeT: Alarm guard activated" );

		// Assign the alarm seen actor
		fActorSeenAlarm = fActorSeen;

		// Deactivate this seen actor
		fActorSeen = None;

		// Try to find an alarm to hit
		fHuntingForActor = FindNearestAlarmSwitch();
		
		//log("MikeT: Alarm Switch found: " $fHuntingForActor);

		// Flip all switches (AFSNOTE: May want to differentiate here in the future)
		FlipAllAlarms();

		// Found one?
		if( fHuntingForActor != None )
		{
			// focus on it
			Focus = fHuntingForActor;

			//log( "MikeT: Alarm guard found alarm switch to hunt for" );

			// set the hunt reaction
			fHuntTargetReachedReaction = kActivateAlarm;

			// Now go to the hunting state
			GotoState( 'Hunting' );
		}
	}
	else
	{
		//log( "MikeT: Going to desired state: " $fDesiredState $" From PlayerSpotted state" );
		GotoState( fDesiredState );
	}
}

state HuntTargetReached
{
//ignores SeePlayer, HearNoise;

	event SeePlayer( Pawn Seen )
	{
		// Do nothing
	}

	function AlertGuards()
	{
		local B9_ArchetypePawnBase combatant;

		// Now tell all combatants that there is an intruder -- ANF show and tell code.
		// Note: This affects this (self) pawn as well.

		ForEach Pawn.AllActors( class 'B9_ArchetypePawnBase', combatant ) 
		{
			// Propogate the seen pawn
			B9_AI_ControllerBase( combatant.Controller ).fActorSeenAlarm = fActorSeen;

			// Send them into the intruder alter state
			B9_AI_ControllerBase( combatant.Controller ).GotoState( 'IntruderAlert' );
		}
	}

begin:
	//log( "MikeT: Generic hunt target reached" );

	switch( fHuntTargetReachedReaction )
	{
		case kNoReaction:
			// No reaction? Go back to the desired state
			GotoState( fDesiredState );

		break;

		case kActivateAlarm:
			//log( "MikeT: Activating the alrm" );

			// Play an anim of the AI activating the klaxon
			Pawn.PlayAnim( B9_ArchetypePawnBase( Pawn ).fActivateDeviceAnimationName );

			// Cease being alarmed about this guy
			fHuntingForActor = None;

			// Cease reacting
			fHuntTargetReachedReaction = kNoReaction;
			
			// Alert the guards!
			AlertGuards();

		break;
	}
}

state IntruderAlert
{
//ignores SeePlayer, HearNoise;

	event SeePlayer( Pawn Seen )
	{
		// Do nothing
	}

	// This will set the desired state in derived classes
	function Init();

begin:
	Init();

	// Goto the desired state
	GotoState( fDesiredState );	
}

state Hide
{
	function bool PathNodeGoodness(PathNode pn)
	{
		return B9_PathNode(pn) != None && B9_PathNode(pn).fGoodForHiding;
	}

	function FindNextGoal()
	{
		local PathNode np;
		local PathNode best;
		local float mindist;
		local PathNode best2;
		local float mindist2;
		local PathNode best3;
		local float mindist3;
		local float npdist;
		local float hfpdist;
		local float dist;
		local float beyond;
		local bool isGood;
		local bool testGood;

		hfpdist = VSize(Enemy.Location - Pawn.Location);
		beyond = 3 * Pawn.CollisionRadius;

		mindist = 1000000.0f;
		mindist2 = 1000000.0f;
		mindist3 = 1000000.0f;
		foreach Pawn.AllActors(class'PathNode', np) // ???? RadiusActors
		{
			if (fBadHidingPlace != np)
			{
				dist = VSize(np.Location - Pawn.Location);
				npdist = VSize(Enemy.Location - np.Location);

				// closest nav point that's farther than annoying pawn 
				if (dist >= beyond && hfpdist <= npdist && dist < mindist3)
				{
					mindist3 = dist;
					best3 = np;
				}

				if (!Enemy.LineOfSightTo(np))
				{
					testGood = PathNodeGoodness(np);
					if (testGood)
						npdist *= 2.0f;

					//Log ("Node " $ np $ " " $ testGood $ " d=" $ dist $ " h=" $ hfpdist $ " n=" $ npdist);

					if ( hfpdist <= npdist && ((isGood == testGood && dist < mindist) || (testGood && !isGood)) )
					{
						mindist = dist;
						best = np;
						isGood = testGood;
					}

					if (dist < mindist2)
					{
						mindist2 = dist;
						best2 = np;
					}
				}
			}
		}

		if (best == None && best2 != None)
		{
			// No hiding location farther than I am from "enemy", but there is a hiding place.
			// Is the first node to the hiding place moving away from the annoying pawn?
			np = PathNode(FindPathToward( best2, true ));
			if (np != None)
			{
				npdist = VSize(Enemy.Location - np.Location);
				if (hfpdist * 0.66f < npdist)
					best = best2;
			}
		}

		if (best == None && best3 != None)
		{
			best = best3;
		}

		SetRouteGoal(best);

//		Log ("Best Node " $ best);
	}

	function bool CheckBestPath()
	{
		local float d1, d2;
		local Actor A;
		local PathNode PrevBadPlace;

		PrevBadPlace = fBadHidingPlace;
		fBadHidingPlace = None;

		if (fBestPath != None && fCurrentNavPoint != fBestPath && fBestPath != RouteGoal &&
			Enemy.LineOfSightTo(fBestPath))
		{
			A = fCurrentNavPoint;
			if (A == None)
				A = Pawn;

			d1 = VSize(Enemy.Location - A.Location);
			d2 = VSize(Enemy.Location - fBestPath.Location);
			if (d2 < d1 * 0.66f)
			{
				//Log ("Bad Node " $ fBestPath $ " goal=" $ RouteGoal $ " d1=" $ d1 $ " d2=" $ d2);

				MoveTarget = None;
				fBestPath = None;
			}	
		}

		if (fBestPath == None)
		{
			fBadHidingPlace = PathNode(RouteGoal);
			SetRouteGoal(None);
		}
		return (fBadHidingPlace == None || PrevBadPlace == None);
	}

	function CheckNearHidingPlace()
	{
		if (fLastHidingPlace != None && VSize(fLastHidingPlace.Location - Pawn.Location) > 120.0f)
		{
			//Log("fLastHidingPlace in open? " $ fLastHidingPlace $ "; " $ fLastHidingPlace.Location $ "; " $ Pawn.Location);
			fLastHidingPlace = None;
		}
	}

	function name SuccessStateName()
	{
		return '';
	}

	function name FailureStateName()
	{
		return 'Cower';
	}

Begin:
	//log( "Enter Hide state" );
	SetRouteGoal(None);
	fBestPath = None;
	fLastHidingPlace = None;

	// This is now the desired state
	fDesiredState = 'Hide';

Loop:
	if ( (RouteGoal != None && PathNodeGoodness(PathNode(RouteGoal))) || SetEnemyByHidingFromPawnClass() )
	{
		if( RouteGoal == None || Pawn.ReachedDestination( RouteGoal ) )
		{
			//log( "Reached end goal" );
			//if( !Pawn.bIsCrouched )
			//{
			//	Sleep( 3 );
			//}

			if (RouteGoal != None)
				fLastHidingPlace = PathNode(RouteGoal);

			if (!SetEnemyByHidingFromPawnClass())
				SetRouteGoal(None);
			else
				FindNextGoal();
		}
		
		if (RouteGoal != None)
		{
			if( fBestPath == None || Pawn.ReachedDestination( fBestPath ) )
			{
				//log( "Reached best path" );
				fCurrentNavPoint = fBestPath;
				fBestPath = FindPathToward( RouteGoal, true );
				if (CheckBestPath())
				{
					//Log ("Next Node " $ fBestPath);
					
					MoveTarget = fBestPath;

					// Run
					if (MoveTarget != None)
					{
						if( !IsSentry() )
						{
							Pawn.SetWalking( false );
							//log( "Before MoveToward" );
							MoveToward( MoveTarget, MoveTarget,,Pawn.bIsWalking );
							//log( "After MoveToward" );
						}
					}

					Goto( 'Loop' ); // ???? I think MoveTarget can't be None, but...
				}

				Log ("Next Node is BAD");
				Sleep( 0.2 );
			}
		}
	}

	SetRouteGoal(None);
	fBadHidingPlace = None;

	if (SetEnemyByHidingFromPawnClass())
	{
		CheckNearHidingPlace();
		if (FailureStateName() != '')
		{
			GotoState( FailureStateName() );
		}

		Sleep( 0.5 );
	}
	else
	{
		//log( "Can't be seen" );
		CheckNearHidingPlace();
		if (SuccessStateName() != '')
		{
			GotoState( SuccessStateName() );
		}

		Sleep( 1 );
	}

	//log( "Repeat state loop" );
	Goto( 'Loop' );
}

// Global Functions
function bool IsSentry()
{
	return B9_ArchetypePawnBase( Pawn ).fSentry;
}

function bool WillReturnToOrigPos()
{
	return B9_ArchetypePawnBase(Pawn).fReturnToOrigPos;
}

function UpdateMovementStallTellTales()
{
	if( VSize( Pawn.Location - fLastMovementPosition ) < 10 )
	{
		fShouldAlternateMoveToLocation = true;
	}
	else
	{
		fShouldAlternateMoveToLocation = false;
		fLastMovementPosition = Pawn.Location;
	}
}

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

function bool ShouldGetAlternateFiringLocation()
{
	return false;
}

function vector GetAlternateFiringLocation()
{
	return Pawn.Location;
}

/*
function bool MovementBlockedByActors()
{
	local B9_ArchetypePawnBase toucher;
	
	// Should be moving but can't?
	if( fPreviousLocation == Pawn.Location &&
		Pawn.Acceleration == vect( 0, 0, 0 ) )
	{
		//log( "MikeT: Blocked" );

		return true;

		
		ForEach Pawn.TouchingActors( class'B9_ArchetypePawnBase', toucher )
		{
			
		}
		
	}

	fPreviousLocation = Pawn.Location;
}


function MovementBlockedPause()
{
	GotoState( fDesiredState, 'StopMoving' );
}
*/

function SetupWeapon()
{
	// Nothing
}

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

function bool WillActorBeOnPathGrid( Actor testActor )
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
			return true;
		}
	}

	return false;
}

//
// Find a hiding place.
//

function bool SetEnemyByHidingFromPawnClass()
{
	local B9_AdvancedPawn ScaryPawn;
	local class HideClass;
	
	HideClass = B9_ArchetypePawnBase(Pawn).fHidingFromPawnClass;

	foreach Pawn.VisibleActors(class'B9_AdvancedPawn', ScaryPawn)
	{
		//Log("MikeT:SEBHFPC:"$ScaryPawn$" "$HideClass);
		if (ScaryPawn != self && ClassIsChildOf(ScaryPawn.Class, HideClass))
		{
			//Log("MikeT:SEBHFPC:TRUE!"$ScaryPawn);
			Enemy = ScaryPawn;
			bEnemyInfoValid = false;
			return true;
		}
	}

	if (Enemy != None)
	{
		LastSeenTime = Level.TimeSeconds;
		LastSeenPos = Enemy.Location;
		LastSeeingPos = Pawn.Location;
		bEnemyInfoValid = true;
		Enemy = None;
	}

	return false;
}


function PostBeginPlay()
{
	//log( "MikeT: PostbeginPlay called" );
	Super.PostBeginPlay();

	Constructor();
}

function Constructor()
{
	fDesiredState = fDefaultState;

	// Set this bot's think timer
	SetupTimer();

	fAboutToDieCalled = false;
	//fPreviousLocation = Pawn.Location;
}

function SetupTimer()
{
	SetTimer( fThinkTimerInterval, true );	
}

function Timer()
{
	//log( "MikeT: timer being called" );

	Think();
}

function bool Think()
{
	if( Pawn.Health <= 0 )
	{
		//log( "MikeT: DEAD: " $self );
		Pawn.GotoState('B9_Dying');
		return false;
	}
	
	/*
	if( Level.TimeSeconds - fBlockLastTime > kMaxBlockTimeBeforeMovePauseCheck )
	{
		if( MovementBlockedByActors() )
		{
			MovementBlockedPause();
		}

		fBlockLastTime = Level.TimeSeconds;
	}
	*/

	//log( "MikeT: I'm in the: " $GetStateName() $"State." );

	return true;
}

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
				log( "MikeT: Bestpath Pass 3 is: " $ nextPath );
			}
			else
				fRouteGoalLocation = RouteGoal.Location;
		}
		else
			fRouteGoalLocation = RouteGoal.Location;
	}
	
	return nextPath;
}

function bool FindNextBestPathToGoal()
{
	local Actor nextPath;

	nextPath = FindPath(true);
	if (nextPath == None)
		nextPath = FindPath(false);

	if( nextPath != None )
	{
		// Set as the next move-to point
		fBestPath = nextPath;
		MoveTarget = nextPath;
	}
	else
	{
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

		MoveTarget = fBestPath;
		return (MoveTarget != None);
	}

	return true;
}


// Operations
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

// Destroy the weapon current held by this controller (typically executed before death)
function DestroyWeapon()
{
	Pawn.Weapon.DetachFromPawn( Pawn );
	Pawn.DeleteInventory( Pawn.Weapon );
	Pawn.Weapon.Destroy();
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
	//	log( "MikeT: TRYING TO DROP ITEM: " $B9_ArchetypePawnBase( Pawn ).fItemToDropOne );

		newPickupOne = Spawn( B9_ArchetypePawnBase( Pawn ).fItemToDropOne,,,dropPositionOne );
		
		if( newPickupOne != None )
		{
	//		log( "MikeT: ITEM DROPPED: " $newPickupOne $"Thought it dropped: " $B9_ArchetypePawnBase( Pawn ).fItemToDropOne );
		}
	}

	if( B9_ArchetypePawnBase( Pawn ).fItemToDropTwo != None )
	{
//		log( "MikeT: TRYING TO DROP ITEM: " $B9_ArchetypePawnBase( Pawn ).fItemToDropTwo );

		newPickupTwo = Spawn( B9_ArchetypePawnBase( Pawn ).fItemToDropTwo,,,dropPositionTwo );
		
		if( newPickupTwo != None )
		{
//			log( "MikeT: ITEM DROPPED: "  $newPickupTwo $"Thought it dropped: " $B9_ArchetypePawnBase( Pawn ).fItemToDropTwo );
		}
	}

	if( B9_ArchetypePawnBase( Pawn ).fItemToDropThree != None )
	{
	//	log( "MikeT: TRYING TO DROP ITEM: " $B9_ArchetypePawnBase( Pawn ).fItemToDropThree );

		newPickupThree = Spawn( B9_ArchetypePawnBase( Pawn ).fItemToDropThree,,,dropPositionThree );
		
		if( newPickupThree != None )
		{
//			log( "MikeT: ITEM DROPPED: "  $newPickupThree $"Thought it dropped: " $B9_ArchetypePawnBase( Pawn ).fItemToDropThree );
		}
	}
}

function SetupDefaultState()
{
	fDefaultState='Travel';
}

function ReceiveWarning( Pawn shooter, float projSpeed, vector FireDir )
{
	//log( "MikeT: RECVD ReceiveWarning: at controllerbase" );
}

function vector GenerateRandomDirection()
{
	local vector randomDirection;
	local float ZLeftOver;

	// Generate a random direction
	randomDirection = VRand();
	ZLeftOver = randomDirection.z;
	randomDirection.z = 0;
	randomDirection.x += ZLeftOver /2;
	randomDirection.y += ZLeftOver /2;
	
	return randomDirection;
}

function MoveDirectional( vector dir, float speed )
{
	// Get the normalized direction
	local vector normalizedDirection;
	normalizedDirection = Normal( dir );

	// Set the pawn's acceleration
	Pawn.Acceleration = speed * normalizedDirection;

	// Set the destination
	Destination = Pawn.Location + ( Pawn.GroundSpeed * Pawn.Acceleration );

	// Set the focal point
	FocalPoint = Destination;
}

function Walk( vector dir )
{
	Pawn.SetWalking( true );
	MoveDirectional( dir, Pawn.GroundSpeed  );
}

function Run( vector dir )
{
	Pawn.SetWalking( false );
	MoveDirectional( dir, Pawn.GroundSpeed );
}

function StopMoving()
{
	// Set accel to zero
	Pawn.Acceleration = vect( 0.0, 0.0, 0.0 );
		
	// Set the goal to where the pawn is at
	Destination = Pawn.Location;

	// Leave the focus unchanged.
}

function IntimidatedBy( B9_ArchetypePawnBase pawn )
{
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

function bool IsWalking()
{
	if (fRunForAWhile)
	{
		if (fRunForAWhileTo < Level.TimeSeconds)
			return true;
		else
			fRunForAWhile = false;
	}
	
	if( !B9_ArchetypePawnBase( Pawn ).fTryToRun )
	{
		return true;
	}
	else if( (fHuntingForActor != None) ||					// Always run to a fHuntingForActor
			 (B9_ArchetypePawnBase( Pawn ).fAlwaysRun) )	// Always obey flag
	{
		return false;
	}
	else
	{
		return true;
	}
}

/* WeaponReadyToFire()
Notification from weapon when it is ready to fire (either just finished firing,
or just finished coming up/reloading).
Returns true if weapon should fire.
If it returns false, can optionally set up a weapon change
*/
function bool WeaponFireAgain(float RefireRate, bool bFinishedFire)
{
	return WeaponFireAgainImplementation( RefireRate, bFinishedFire );
}

function bool BotFire(bool bFinishedFire)
{
	if ( Pawn.Weapon.fContinuous)
	{
		bFire = 1;
		return B9WeaponBase(Pawn.Weapon).BotFire(bFinishedFire);
	}
	else
	{
		bFire = 0;
		return Pawn.Weapon.BotFire(bFinishedFire);
	}
}

function bool WeaponFireAgainImplementation(float RefireRate, bool bFinishedFire)
{
	local bool turn;
	//Log( "B9_AI_ControllerBase.WeaponFireAgain start, state=" $ Pawn.Weapon.GetStateName());

	if ( !Pawn.Weapon.IsFiring() )
	{
		if ( Target == None )
			Target = Enemy;

//		Log( "B9_AI_ControllerBase.WeaponFireAgain target=" $ Target.Name);

		turn = NeedToTurn(Target.Location);
		if ( Target != None && !turn && Pawn.Weapon.CanAttack(Target) )
		{
			//Log( "B9_AI_ControllerBase.WeaponFireAgain firing" );

			Focus = Target;
			bCanFire = true;
			return BotFire(bFinishedFire);
		}
		else
		{
			bCanFire = false;
		}
	}
	else if (bCanFire)
	{
		if ( (Target != None) && (Focus == Target) && !Target.bDeleteMe )
		{
			if ( Pawn.Weapon.fContinuous && (Pawn.Controller.bFire > 0) )
			{
				return true;
			}
			else if ( FRand() < RefireRate )
			{
				//Log( "B9_AI_ControllerBase.WeaponFireAgain refiring" );
				return BotFire(bFinishedFire);
			}
		}
	}

	//Log("MikeT: Stop firing from WeaponFireAgainImplementation");
	StopFiring();
	return false;
}

function bool WeaponHasAmmo()
{
	return (Pawn.Weapon != None && Pawn.Weapon.HasAmmo());
}

function bool FireWeaponAt(Actor A)
{
	local Pawn					targetPawn;
	local B9_ArchetypePawnBase	targetArchPawn;
	local B9_AI_ControllerBase	targetArchController;
	local vector				fireDirection;

	//log( "MikeT: In fireweaponat" );

	if ( A == None )
		A = Enemy;
	if ( (A == None) || (Focus != A) )
		return false;
	Target = A;

	//log( "MikeT: After target aquisition" );

	// Warn the target that they are being fired upon.
	targetPawn = Pawn( target );
	if( targetPawn != None )
	{
		targetArchPawn = B9_ArchetypePawnBase( targetPawn );
		if( targetArchPawn != None )
		{
			targetArchController = B9_AI_ControllerBase( targetArchPawn.Controller );
			if( targetArchController != None )
			{
				fireDirection = Target.Location - Pawn.Location;
				targetArchController.ReceiveWarning( Pawn, Pawn.Weapon.AmmoType.ProjectileClass.Default.Speed, fireDirection );
				//log( "MikeT: Send ReceiveWarning" );
			}
		}
	}

	if ( WeaponHasAmmo() )
	{
		//log( "MikeT: Calling WeaponFireAgain at" $Target );
		return WeaponFireAgain(Pawn.Weapon.RefireRate(),false);
	}
	
	StopFiring();
	return false;
}

function StopFiring()
{
	//log( "MikeT: Controller Base , IN StopFiring"  );

	bCanFire = false;
	bFire = 0;
	bAltFire = 0;

	//log( "MikeT: Controller Base , Before leaving StopFiring"  );
}

// Dialogue-related stuff
//

function BeginDialogue(name eventName, Pawn Other, optional int Index, optional bool NotFaceToFace)
{
	fDialogueStartIndex = Index;
	if (NotFaceToFace)
		fFaceToFace = 0;
	else
		fFaceToFace = 1;
	fDialoguePrevState = GetStateName();
	GotoState( 'HandleDialogue' );
	TriggerEvent(eventName, Pawn, Other);
}

function int DialogueInit(out int FaceToFace)
{
	FaceToFace = fFaceToFace;
	return fDialogueStartIndex;
}

function DialogueResult(int Result, int Index)
{
	// default does nothing
	if (GetStateName() == 'HandleDialogue')
	{
		GotoState( fDialoguePrevState );
	}
}

state HandleDialogue
{
Begin:
	Sleep( 10.0 );
	Goto( 'Begin' );
}

defaultproperties
{
	fThinkTimerInterval=0.5
	fFirstState=StartingState
	fRand60Deg[0]=-10922
	fRand60Deg[2]=10922
	fDefaultState=Travel
	fPauseFor=10
	fDistanceToLocation=300
	fCloakFXClass=Class'B9FX.fx_CloakSparkle'
}