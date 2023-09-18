//////////////////////////////////////////////////////////////////////////
//
// Black 9 Controller Combatant
//
//////////////////////////////////////////////////////////////////////////
class B9_AI_OldControllerCombatant extends B9_AI_ControllerBase;

// Variables
var bool		fTriedGiveGun;
var int			fAttackFacingSeconds;
var float		fAttackFrustrationLevel;
var float		fReloadFrustrationLevel;
var float		fRangeToAssail;
var Pickup		fPickupOfInterest;
var vector		fSentryLocation;
var PathNode	fLastSeenPosOfPrey;
var PathNode	fRetreatToCoverPos;
var	int			fLastCalcRetreatToCoverPos;
var bool		fLookForFirst;
var bool		fFirstLostSightOf;
var float		fLastTimeGaveUpEnemyPosition;
var bool		fRetreated;

// States
state Start 
{
//ignores SeePlayer, HearNoise;

	event SeePlayer( Pawn Seen )
	{
		// Do nothing
	}

	function BeginState()
	{
		//log( "Combatant BeginState() function called: "$self $" Pawn: " $Pawn );
	}

	function init()
	{
		//log( "Combatant idle init function called: "$self );
		
		fPickupOfInterest = None;
		Pawn.bCanPickupInventory = false;
		Pawn.Acceleration = vect( 0, 0, 0 );

		// Have this bot remember where it orginally started out from
		fSentryLocation = Pawn.Location;

		// Setup the default state
		SetupDefaultState();

		// Start off by going to the default state
		GotoState( fDefaultState );
	}
begin:
	init();
}


// This hunting state designed specifically for combatants allow the combatants to 
// use the path-node system to keep after their target and attack them with weaponary at the same time.
state AttackAndHunting extends Hunting
{	
//ignores SeePlayer, HearNoise;

	event SeePlayer( Pawn Seen )
	{
		// Do nothing
	}
	
	event HearNoise( float Loudness, Actor NoiseMaker)
	{
		// Do nothing
	}
	
	// Overrides the b9_AI_ControllerBase CalculateNextMoveTarget().  Doesn't use the magic method
	// of finding its target; the AI will now go to the last place that it saw the target, and continue
	// following pathnodes towards the target that are visible from the original spot until it sees the
	// target, or runs out of visible pathnodes.  If its the latter, it will go back to looking for the
	// player.
	function bool CalculateNextMoveTarget()
	{
		local bool alwaysSees;
		local bool hasLOS;
		
		alwaysSees = false;
		if (B9_ArchetypePawnBase(Pawn) != None)
			alwaysSees = B9_ArchetypePawnBase(Pawn).fCheatAlwaysSeesEnemy;
		hasLOS = LineOfSightTo(fHuntingForActor);
		if (!hasLOS)
			B9_ArchetypePawnCombatant(Pawn).fFiredFromCover = false;

		if (!hasLOS && !ReachedRouteGoal())
		{
			if (PathNode(fHuntingForActor) != None)	// If we're headed to a pathnode, we can always get to it.
				return Super.CalculateNextMoveTarget();
			else if ((RouteGoal == None) && fRouteGoalLocationValid) // If we're headed to a spot, just go for it.
				return Super.CalculateNextMoveTarget();
		}

		// If we can see the target, go for it.
		if (alwaysSees || hasLOS && (B9_Pawn(fHuntingForActor) != None) )
		{
			if ( (fLastTimeGaveUpEnemyPosition + B9_ArchetypePawnCombatant(Pawn).fFrequencyOnGivingUpEnemyPosition) < Level.TimeSeconds)
			{
				if ( (B9_ArchetypePawnCombatant(Pawn) != None) &&
					 B9_ArchetypePawnCombatant(Pawn).fWarnsAlliesAboutEnemies &&
					 (Pawn(fHuntingForActor) != None) )
					B9_ArchetypePawnBase(Pawn).EmitEnemySpottedMessage(Pawn(fHuntingForActor));
				fLastTimeGaveUpEnemyPosition = Level.TimeSeconds;
			}

			fFirstLostSightOf = true;	// The next time we lose sight of the player, we can 
			return Super.CalculateNextMoveTarget();
		}
		else if ((fLastSeenPosOfPrey != None) || fFirstLostSightOf)
		{
			if (fFirstLostSightOf)
			{
				fLastSeenPosOfPrey = B9_Pawn(fHuntingForActor).GetCachedClosestPathNode();
				fLookForFirst = true;
				fFirstLostSightOf = false;
				//Log("Miket: fLastSeenPosOfPrey: " $fLastSeenPosOfPrey);
			}

			if (ReachedRouteGoal() || !fLookForFirst)
			{
				//Log("Miket: Reached last seen position.");
				fLookForFirst = false;
				fLastTimeGaveUpEnemyPosition = 0;
				
				// Here we cheat a little.  We'll go in the direction of the player, but we'll only
				// travel until we hit a path node that's not visible from the original point.
				SetRouteGoal(fHuntingForActor);
				if (FindNextBestPathToGoal())
				{
					if (LineOfSightTo(fLastSeenPosOfPrey))
					{
						//log("MikeT: fLastSeenPosOfPrey is visible...");
						return true;
					}			
				}
			}
			else
			{
				//Log("MikeT: Setting fLastSeenPosOfPrey as route goal.");
				SetRouteGoal(fLastSeenPosOfPrey);
				return FindNextBestPathToGoal();
			}
		} 
		
		//log("MikeT: Giving up after not being able to see player.");
		fLastSeenPosOfPrey = None;
		fDesiredState = 'Start';
		MoveTarget = None;
		fHuntingForActor = None;
		SetRouteGoal(None);
		fRunForAWhile = true;
		fRunForAWhileTo = Level.TimeSeconds + 180;	// Run around for 3 minutes looking for the player.
		return false;
	}

	function bool CanFire()
	{
		//local vector	fireDirection;
		//local rotator	fireDirectionRot;
		
		if (Enemy == None)
			return false;

		switch( HasCombatItem() )
		{
			case kWeapon:

				if( Pawn.Weapon != None )
				{

					//Log( "Before FireWeaponAt, the attack range and distance to enemy is: " $B9_ArchetypePawnCombatant( Pawn ).fMaxAttackTargetRange $VSize( Pawn.Location - Enemy.Location ) );
					//Log( "Weapon" $Pawn.Weapon );
					//Log( "Ammo" $Pawn.Weapon.ReloadCount );
					if( VSize( Pawn.Location - Enemy.Location ) < B9_ArchetypePawnCombatant( Pawn ).fMaxAttackTargetRange )
					{
						//Log( "FireWeaponAt " $ Pawn.Weapon.Name $ " " $ Enemy.Name $ " " $ string(Pawn.Weapon.HasAmmo()) );
						
						// Has a valid conventional tech weapon enabled.
						return true;
					}
				}
				else
				{
					//log( "MikeT: No weaponary! Error!" );
				}

			break;

			case kNanoTech:
			
				if( B9_AdvancedPawn( Pawn ).fSelectedSkill != None )
				{
					// Has a valid nano tech weapon enabled.
					return true;
				}					
				else
				{
					//log( "MikeT: No Nano-based weaponary! Error!" );
				}


			break;

			case kNothing:
			default:
				return false;
			break;
		}
		
		return false;
	}

	// Overriden state functions
	function StartupHunting()
	{
		//log( "MikeT: In StartupHunting." );

		Super.StartupHunting();

		// Calculate reload counts
		if( HasCombatItem() == kWeapon )
		{
			// Set the weapon reload count
			Pawn.Weapon.ReloadCount = Pawn.Weapon.Default.ReloadCount;
		}

		// Go back to this state by default
		fDesiredState = 'AttackAndHunting';
	}

	// Besides checking to see if the super wants to do a post hunting action
	// a combatant has other dependencies.
	function bool DoPostHuntingAction()
	{
		local bool isInFiringState;
		isInFiringState	= B9_ArchetypePawnCombatant( Pawn ).IsInFiringState();
		
		if( Super.DoPostHuntingAction() )
		{
			// Fire weapon if within range and a weapon is properly equiped.
			if( !isInFiringState && CanFire() )
			{
				//log( "MikeT: Doing post COMBATANT hunting action, canFire" );
				return true;
			}
		}

		//log( "MikeT: NOT Doing post COMBATANT hunting action: " $CanFire() $" isInFiringState: " $isInFiringState );
		return false;
	}

	function bool HasReachedHuntTargetRadius()
	{
		local bool stopShort;
		local bool enemyStandOffDistReached;
		
		if (fRetreated)
		{
			if ( VSize(fHuntingForActor.Location - Pawn.Location) < ((Pawn.Weapon.MaxRange * 7) / 10) )
				return true;
		}
		
		stopShort = Super.HasReachedHuntTargetRadius();
		enemyStandOffDistReached = HasReachedEnemyStandoffDistance();

		if( stopShort || enemyStandOffDistReached )
		{
			return true;
		}
		
		return false;
	}
}

state Firing
{
//ignores SeePlayer, HearNoise;

	event SeePlayer( Pawn Seen )
	{
		// Do nothing
	}

	event HearNoise( float Loudness, Actor NoiseMaker)
	{
		// Do nothing
	}

	function bool TurnTowardEnemy()
	{
		if (Enemy == None)
		{
			Focus = None;
			return false;
		}

		// Face the target
		Focus = Enemy;

		// Turn toward the target
		return ( NeedToTurn( Focus.Location ) );
	}

Begin:

	//log( "MikeT: In firing state" );
	
	// Ensure AI is pointed toward it's target
	if( TurnTowardEnemy() )
	{
		// AFSNOTE: May want to remove the latent rotation finisher and allow the rotation to happen
		// asynchornously.
		FinishRotation();
	}

	// Tell the pawn to start firing
	//Log("MikeT: Going to Pawn Firing State");
	Pawn.GotoState('Firing');

	// Still have an enemy? 
	if( Enemy != None )
	{
		//Log("MikeT: Going to AttackAndHunting state");
		GotoState( 'AttackAndHunting' );
	}
	else
	{
		// Go to this AI's default to allow it a decision point 
		// whereby it can continue attacking or decided to do something else
		//Log("MikeT: Going to state " $fDefaultState);
		GotoState( fDefaultState );
	}
}

state PickUpItem
{
//ignores SeePlayer, HearNoise;

	event SeePlayer( Pawn Seen )
	{
		// Do nothing
	}

	function bool RecheckForAmmo()
	{
		local Actor A;

		fPickupOfInterest = None;
		
		if( HasCombatItem() == kWeapon && !WeaponHasAmmo() )
		{
			ForEach Pawn.RadiusActors( Pawn.Weapon.PickupClass, A, 20000.0f )
			{
				fPickupOfInterest = Pickup(A);
				break;
			}
		}

		return (fPickupOfInterest != None);
	}

Begin:
//	Log( "B9_AI_OldControllerCombatant find " $ fPickupOfInterest.Name);
	Pawn.bCanPickupInventory = true;
	Pawn.SetWalking( false );
Loop:
	if( !IsSentry() )
	{
		MoveToward( fPickupOfInterest, fPickupOfInterest,,,Pawn.bIsWalking );
	}

	Sleep( 1 );
	if( RecheckForAmmo() ) 
	{
		Goto( 'Loop' );
	}
	GotoState( 'Start' );
}

state Sentry
{
Begin:

	//log( "MikeT: In sentry mode" );

	// Start with no acceleration
	Pawn.Acceleration = vect( 0, 0, 0 );

ReturnToPosition:

	// If there is an enemy, see if this AI wants to hunt
	if( B9_ArchetypePawnBase( Pawn ).bAllowHunting )
	{
		// Does this AI have a current enemy?
		if( Enemy != None )
		{
			// Start hunting
			GotoState( 'Hunting' );
		}
	}

	// The AI will only be in this state (for long) if there are no visible,
	// attackable, targets.  In this state it will either wait, or if it's not where it's supposed
	// to be, wander back to it's original sentry spot
	if( Pawn.Location != fSentryLocation && Pawn.GroundSpeed > 0 )
	{
		//log( "MikeT: returning to position, speed: " $( Pawn.GroundSpeed * Pawn.WalkingPct ) );
		
		MoveTarget = FindPathTo( fSentryLocation );

		// Since it's a rule for B9 to have unified pathing grids, this should be impossible
		if( MoveTarget == None )
		{
//			log( "Teleporting..." );
			// In this case, simply teleport the AI to it's original spot - it's probably stuck somewhere.
			Pawn.Setlocation( fSentryLocation );
		}
		else
		{
			if( !IsSentry() )
			{
				Pawn.SetWalking( true );
				MoveToward( MoveTarget, MoveTarget, Pawn.WalkingPct,,true );
			}
		}

		// Keep doing this until the AI is back in it's sentry position
		if( Pawn.Location != fSentryLocation )
		{
			//log( "MikeT: Pos" $Pawn.Location );
			//log( "MikeT: SentryPos" $fSentryLocation );
			
			Goto( 'ReturnToPosition' );
		}
	}
}

state IntruderAlert
{
//ignores SeePlayer, HearNoise;

	event SeePlayer( Pawn Seen )
	{
		// Do nothing
	}

	function Init()
	{
		if( fActorSeenAlarm != None )
		{
//			log( "MikeT: Intruder detected, going to hunt mode: " $self );

			// Set as the enemy 
			SetAsEnemy( fActorSeenAlarm );

//			log( "MikeT: enemy set as: " $fActorSeenAlarm );

			// Clear the field
			fActorSeenAlarm = None;

			// Set the desired state
			fDesiredState = 'AttackAndHunting';
		}
		else
		{
//			log( "MikeT: False positive in IntruderAlert: " $fActorSeenAlarm );
		}
	}
}

// Overriden
function bool SetEnemy( Pawn Enemy )
{
//	log( "MikeT: in B9_AI_OldControllerCombatant SetEnemy, enemy: " $Enemy );
	SetAsEnemy( Enemy );
	return true;
}

// Global functions

function bool ShouldGetAlternateFiringLocation()
{
	if (B9_ArchetypePawnCombatant(Pawn).fRetreatToCover)
	{
		// Only withdraw if we fired a shot off.  This will give the AI a chance to come out from cover,
		// fire, then withdraw again.
		if (B9_ArchetypePawnCombatant(Pawn).fFiredFromCover)
			return true;
	}
	
	return B9_ArchetypePawnCombatant(Pawn).PopShouldChangeFiringPositionQue();
}

function vector GetAlternateFiringLocation()
{
	local vector	X, Y, Z;
	local vector	delta;
	local int		sign;
	local actor		nextPath;
	
	MoveTarget = None;
	if (B9_ArchetypePawnCombatant(Pawn).fRetreatToCover)
	{
		// Check to see if we should calculate another retreat to cover position.  We only do it once every
		// five or so seconds.
		if ( (Level.TimeSeconds - fLastCalcRetreatToCoverPos) > 5 )
		{
			// If we have no place to withdraw to, or the enemy can see the place we want to withdraw to,
			// calculate another spot.
			if ( (fRetreatToCoverPos == None) || Enemy.Controller.pointReachable(fRetreatToCoverPos.Location) )
			{
				fRetreatToCoverPos = FindPathNodeToRetreatTo();
				fLastCalcRetreatToCoverPos = Level.TimeSeconds;
				Log("MikeT: GetAlternateFiringLocation : " $fRetreatToCoverPos);
			}
		}
		
		if (fRetreatToCoverPos != None)
		{
			nextPath = FindPathToward(fRetreatToCoverPos, true);
			if (nextPath == None)
			{
				nextPath = FindPathTo(fRetreatToCoverPos.Location, true);
				if (nextPath == None)
				{
					nextPath = FindPathToward(fRetreatToCoverPos);
					if (nextPath == None)
					{
						nextPath = FindPathTo(fRetreatToCoverPos.Location);
						Log("MikeT: NextPath4: " $nextPath.Location $" CurPos: " $Pawn.Location);
					}
					else
						Log("MikeT: NextPath3: " $nextPath.Location $" CurPos: " $Pawn.Location);
				}
				else
					Log("MikeT: NextPath2: " $nextPath.Location $" CurPos: " $Pawn.Location);
			}
			else
				Log("MikeT: NextPath: " $nextPath.Location $" CurPos: " $Pawn.Location);
			
			if (nextPath != None)
			{
				MoveTarget = nextPath;
				return nextPath.Location;
			}
		}
		
		// If we can't find a retreat node path, then we just zig zag backwards.  Shouldn't happen though...
		Log("MikeT: Could not find a node.  Just retreating.");
	}

	// Zig zag, and maybe retreat a little bit too.
	if( Rand( 2 ) == 0 )
		sign = 1;
	else
		sign = -1;

	GetAxes( Rotation, X, Y, Z );

	delta = B9_ArchetypePawnCombatant( Pawn ).fChangePositionAmount * Y * sign;
	if (B9_ArchetypePawnCombatant( Pawn ).PopTakingDamageQue() || B9_ArchetypePawnCombatant(Pawn).fRetreatToCover)
	{
		delta -= B9_ArchetypePawnCombatant( Pawn ).fChangePositionAmount * X;
		fRetreated = true;
	}
	
	return Pawn.Location + delta;
}

function SetupWeapon()
{
	local B9_ArchetypePawnCombatant P;
	P = B9_ArchetypePawnCombatant( Pawn );

	if( !fTriedGiveGun && Pawn.Weapon == None )
	{
		// Do I have a gun? No, create one!
		fTriedGiveGun = true;
		
		// XT: Added NULL string check 05/11/03
		// UNDONE: why is it empty or "None" at the first place???
		if( P.fWeaponIdentifierName != "" &&  P.fWeaponIdentifierName != "None" )
		{
			switch( EquipCombatItem( P.fWeaponIdentifierName, P.bWeaponHidden ) )
			{
				case kWeapon:
					/*
					if ((Pawn.Weapon != None) && Pawn.Weapon.HasAmmo())
						Log( "B9_AI_OldControllerCombatant has weapon " $ Pawn.Weapon.Name $ " & ammo" );
					else if ((Pawn.Weapon != None))
						Log( "B9_AI_OldControllerCombatant has weapon " $ Pawn.Weapon.Name $ ", but no ammo" );
					else 
						Log( "B9_AI_OldControllerCombatant has no weapon" );
					*/
			
					Pawn.Weapon.AmmoType.AmmoAmount = P.fWeaponStartingAmmo;
				break;

				case kNanoTech:
				break;

				case kNothing:
				default:
				break;
			}
		}
		else
		{
			Pawn.Weapon		= None;
			P.fSelectedSkill	= None;
		}
	}	
}



// Finds a pathnode that we can retreat to.
function PathNode FindPathnodeToRetreatTo()
{
	local PathNode np;
	local PathNode cur;
	local PathNode alt;
	local int		curPNDistanceToEnemy;
	local int		altPNDistanceToEnemy;
	local int		test;
	
	// NYI: Look for pathnodes that are specifically suitable for cover.
	// NYI: Look for pathnodes that are good for crouching behind.
	
	if (Enemy == None)
		return None;

	alt = None;
	cur = None;
	curPNDistanceToEnemy = 0;
	altPNDistanceToEnemy = 0;
	
	foreach Pawn.AllActors(class'PathNode', np)
	{
		// If the enemy can't get to the point directly or see the point, good.
		if (!Enemy.Controller.pointReachable(np.Location) && !Enemy.Controller.LineOfSightTo(np))
		{
			test = VSize(np.Location - Pawn.Location);
			// If the point is closer to the AI than the enemy, good.
			if (test < VSize(np.Location - Enemy.Location))
			{
				// If the point is closer to the AI than the last point that we saw, good.eat
				if ( (test < curPNDistanceToEnemy) || (cur == None) )
				{
					// Looks like we have a new retreat point.
					cur = np;
					curPNDistanceToEnemy = test;
				}
			}
			else if (test > 1000)	// Look at this spot if its not near the enemy.
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
	if ( (cur == None) ) // || ( (altPNDistanceToEnemy * 4) < curPNDistanceToEnemy) )
	{
		Log("MikeT: Alt Retreat Point found: " $alt $" Location: " $alt.Location $" Enemy Location: " $enemy.Location);
		return alt;
	}
	
	Log("MikeT: Retreat Point found: " $cur $" Location: " $cur.Location $" Enemy Location: " $enemy.Location);
	return cur;
}

function SetupDefaultState()
{
	if( B9_ArchetypePawnCombatant( Pawn ).bWanderAllowed )
	{
		fDefaultState = 'Travel';
	}
	else
	{
		fDefaultState = 'Sentry';
	}
}

function bool Think()
{
	if( Super.Think() )
	{
		// Try to imtimiated any entity that needs it.
		IntimidateOthers();
		
		//log( "MikeT: Before fActorSeenAlarm check" );

		// Try to attack any entity that needs it.
		if( fActorSeenAlarm == None )	// On the way to hit the alarm, don't bother...
		{
			//log( "MikeT: After fActorSeenAlarm check" );

			if( !B9_ArchetypePawnBase( Pawn ).IsInState( 'Hide' ) )
			{
				//log( "MikeT: calling AttackOthers()" );
				AttackOthers();
			}
		}

		StandOffFromEnemy();

		return true;
	}
	else
	{
		log( "MikeT: Returned false in combatant think()" );
		return false;
	}
}

function StandOffFromEnemy()
{
	if( IsInState( 'AttackAndHunting' ) )
	{
		if( HasReachedEnemyStandoffDistance() )
		{
			if( fHuntMoving )
			{
				GotoState( 'AttackAndHunting', 'StopMoving' );
			}
		}
	}
}

function bool HasReachedEnemyStandoffDistance()
{
	if( Enemy == fHuntingForActor )
	{
		// If stand off distance reached and the hunting target is an enemy, don't approach any further.
		if( VSize( fHuntingForActor.Location - Pawn.Location ) <= B9_ArchetypePawnBase( Pawn ).fStandOffRange )
		{
			return true;			
		}
	}
	
	return false;
}

function IntimidateOthers()
{
	local B9_ArchetypePawnBase targetPawn;
	local float rangeToTarget;

	if( B9_ArchetypePawnBase( Pawn ) != None )
	{
		// Intimidate everyone in the area
		//ForEach RadiusActors( class'B9_ArchetypePawnBase',targetPawn, B9_ArchetypePawnBase( Pawn ).GetIntimidationRange() )
		ForEach Pawn.VisibleCollidingActors( class'B9_ArchetypePawnBase',targetPawn, B9_ArchetypePawnBase( Pawn ).GetIntimidationRange() )
		{
			if( targetPawn != B9_ArchetypePawnBase( Pawn ) )
			{
				rangeToTarget = VSize( Pawn.Location - targetPawn.Location );

				// ANF@@@ the function call seems to not take range into account.
				if( rangeToTarget <= B9_ArchetypePawnBase( Pawn ).GetIntimidationRange() )
				{
//					log( "Found a target: making them cower: " $B9_ArchetypePawnBase( Pawn ).GetIntimidationRange() $rangeToTarget );
					targetPawn.IntimidatedBy( B9_ArchetypePawnBase( Pawn ) );
				}
			}
		}
	}
}

function bool CanAttack()
{
	if( IsInState( 'Travel' ) || IsInState( 'Sentry' ) )
	{
		return true;
	}

	return false;
}

function AttackOthers()
{
	local GameRules R;
	local B9_AdvancedPawn assailPawn;
	local float rangeToTarget, closestTarget, maxRangeToTarget;
	local bool attacking;
	local Actor A;
	local B9_ArchetypePawnCombatant P;
	
	P = B9_ArchetypePawnCombatant( Pawn );

	//log( "MikeT: IN attack others, state: " $GetStateName() );

	if( P == None || !P.bHostile )
	{
		return;
	}

	// Set closest target to an impossibly large value.
	closestTarget = 9999999.0;

	// Give this guy a weapon if he doesn't have one
	SetupWeapon();

	if (!fTriedGiveGun)
	{
		// MikeT: There is no 'Start' state in weapons.
/*
		if( HasCombatItem() != kNothing )
		{
			//Pawn.Weapon.GotoState('Start');
		}
*/

		R = Level.Game.GameRulesModifiers;
		while (R != None)
		{
			if (R.Class == class'B9_AI_CombatantGameRules')
				break;
			R = R.NextGameRules;
		}
		if (R == None)
		{
			if ( Level.Game.GameRulesModifiers == None )
				Level.Game.GameRulesModifiers = Spawn(class'B9_AI_CombatantGameRules');
			else	
				Level.Game.GameRulesModifiers.AddGameRules(Spawn(class'B9_AI_CombatantGameRules'));
		}
	}

	// Set the attack range of the pawn to that of the current weapon.
	if( HasCombatItem() == kWeapon )
	{
		P.fMaxAttackTargetRange = Pawn.Weapon.MaxRange;
	}
	else
	{
		P.fMaxAttackTargetRange = 10000;
	}
	
	if( CanAttack() )
	{
		attacking = false;

		// maybe attack someone (pick closed)
		if (fAttackFrustrationLevel >= 0.2f && Frand() < fAttackFrustrationLevel)
		{
			fAttackFrustrationLevel = 0.0f;

			//Log( "MikeT: B9_AI_OldControllerCombatant consider's attacking" );

			if( P.fSearchForWeapons )
			{
				if( HasCombatItem() == kNothing || 
					( HasCombatItem() == kWeapon && !WeaponHasAmmo() ) )
				{
					Log( "B9_AI_OldControllerCombatant no weapon or ammo" );

					SwitchToBestWeapon();
					if( HasCombatItem() == kNothing || 
					    ( HasCombatItem() == kWeapon && !WeaponHasAmmo() ) )
					{
						if (fReloadFrustrationLevel >= 1.0f)
						{
							fReloadFrustrationLevel = 0.0f;
							ForEach Pawn.RadiusActors( Pawn.Weapon.PickupClass, A, 20000.0f )
							{
								fPickupOfInterest = Pickup(A);
								if (fPickupOfInterest != None)
									GotoState( 'PickUpItem' );
							}
						}
						else
						{
							fReloadFrustrationLevel = 1.0f;
							Pawn.Weapon.GotoState('Reloading');
						}

						return;
					}
					else if (Pawn.Weapon == None)
					{
						return;
					}
				}
			}

			if( HasCombatItem() == kWeapon )
			{
				if( Pawn.Weapon.GetStateName() == 'DownWeapon' )
				{
					Pawn.Weapon.BringUp();
				}
			}

			assailPawn = None;
			maxRangeToTarget = P.fMaxAttackTargetRange + 1;
			
			// Attack just the player
			ForEach Pawn.VisibleActors( class'B9_AdvancedPawn', assailPawn, B9_ArchetypePawnCombatant( Pawn ).fMaxAttackTargetRange )
			{
				if( assailPawn != P && assailPawn.Health > 0)
				{
					// Ensure pawn is of an opposing faction
					if( assailPawn.fFaction != B9_AdvancedPawn( Pawn ).fFaction )
					{
						if( CanSee( assailPawn ) )
						{

							//log( "MikeT: Found enemy to attack.  My Faction:" $B9_AdvancedPawn( Pawn ).fFaction $"Enemy faction: " $assailPawn.fFaction );
							rangeToTarget = VSize( Pawn.Location - assailPawn.Location );
							if( rangeToTarget < maxRangeToTarget && 
								rangeToTarget < closestTarget )
							{
								Log( "B9_AI_OldControllerCombatant considering " $ assailPawn.Name $ ", range " $ string(rangeToTarget));
					
								fRangeToAssail = rangeToTarget;
								closestTarget = rangeToTarget;

								// Set the enemy
								SetAsEnemy( assailPawn );
							}
						}
					}
				}
			}

			// If a new target has been aquired, attempt to attack immediately
  			if( closestTarget < maxRangeToTarget )
  			{
  				//log( "MikeT: In range, attacking." );

				attacking = true;
  				GotoState( 'AttackAndHunting' );
  			}

			//log( "MikeT: NO attack." );
		}

		if (!attacking)
			fAttackFrustrationLevel += 0.1f;
	}

}

function EquipCombatItemByString( string className, bool hidden )
{
	EquipCombatItem( className, hidden );
}

function B9_AI_ControllerCombatant.eCombatItemResult EquipCombatItem( string className, bool hidden )
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

function B9_AI_ControllerCombatant.eCombatItemResult HasCombatItem()
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

function SetAsEnemy( Pawn target )
{
	// Set the enemy
	Enemy = target;

	// And set the hunt target
	fHuntingForActor = target;
}

function bool WeaponFireAgain(float RefireRate, bool bFinishedFire)
{
	// we don't immediately refire after a reload
	if (/*!Pawn.Weapon.fContinuous && */bFinishedFire)
	{
		//Log("MikeT: StopFiring called from B9_AI_OldControllerCombatant::WeaponFireAgain");
		StopFiring();
		return false;
	}

	return Super.WeaponFireAgain(RefireRate, bFinishedFire);
}

function ReceiveWarning( Pawn shooter, float projSpeed, vector FireDir )
{
	local bool dodgeToLeft;
	
	dodgeToLeft = ( Frand() > 0.50 );
	//log( "MikeT: In ReceiveWarning: in COMBATANT" );

	// Check to see if this AI should try to duck
	//if( ( Pawn.health <= 0 ) || ( Enemy == None ) || ( Pawn.Physics == PHYS_Falling ) || ( Pawn.Physics == PHYS_Swimming ) )
	//{
		//return;
	//}
	//else
	//{
		// log( "MikeT: Would be ducking now" );
		// try to duck here

		//log( "MikeT: Before pawn type conversion" );

		if( B9_ArchetypePawnCombatant( Pawn ) != None )
		{
			// SEAN &&& AMPERSAND HERE!

			//log( "MikeT: Before pawn dodge check" );

			if( B9_ArchetypePawnCombatant( Pawn ).bCanDodge )
			{
				B9_ArchetypePawnCombatant( Pawn ).PlayDodging( dodgeToLeft );
			}
		}
	//}
}

defaultproperties
{
	fLookForFirst=true
	fFirstLostSightOf=true
	fThinkTimerInterval=0.25
	fFirstState=Start
	fPostHuntActionState=Firing
	bAdvancedTactics=true
	AttitudeToPlayer=1
}