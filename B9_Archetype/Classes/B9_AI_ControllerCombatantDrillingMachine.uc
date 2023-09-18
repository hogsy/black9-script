//////////////////////////////////////////////////////////////////////////
//
// Black 9 Drilling Machine
//
//////////////////////////////////////////////////////////////////////////
class B9_AI_ControllerCombatantDrillingMachine extends B9_AI_OldControllerCombatant;

var float			fLastHurtTime;
var B9_AdvancedPawn	fPawnBeingHurt;	// NYI: This sucks. Only attack one pawn at a time?  Rework.


event bool NotifyBump(Actor Other)
{
	if( B9_AdvancedPawn( Other ) != None )
		fPawnBeingHurt = B9_AdvancedPawn( Other );

	return false;
}


state Hunting
{
	function EStateResponse ProcessHunting()
	{
		// First check for target acquistion
		if( fHuntingForActor == None )
		{
			// Exit hunt mode
			return kDefault;
		}
		else if( FindPathToward( fHuntingForActor ) == None )
		{
			if( WillActorBeOnPathGrid( fHuntingForActor ) == true )
			{
				// Try again later
				return kNone;				
			}

			// Can't see the target, and don't know how to get to it,
			// so give up on this target
			fHuntingForActor = None;
			return kDefault;
		}

		// Ensure Routegoal is set to the fHuntingForActor
		SetRouteGoal(fHuntingForActor);
		
		// Get the next location to move to
		FindNextBestPathToGoal();

		// Perform no response
		return kNone;
	}
}

function bool Think()
{
	if( Super.Think() )
	{
		if( fPawnBeingHurt != None )
		{
			// NYI: This won't work.  Throw the player like off a force field, then take the damage again.  Alternatively, figure out if the enemy
			// is in the collision mesh.
			if( Level.TimeSeconds - fLastHurtTime > B9_ArchetypePawnCombatantDrillingMachine( Pawn ).fDamageFrequency )
			{
				fLastHurtTime = Level.TimeSeconds;

				// Hurt the pawn
				//log( "ALEX: Bumped: " $Other $"Inflicting damage to it!" );
				fPawnBeingHurt.TakeDamage( B9_ArchetypePawnCombatantDrillingMachine( Pawn ).fDamageToInflict, Pawn, fPawnBeingHurt.Location, vect( 0, 0, 0 ), class 'WarDamageExplosion' );

				// See if the pawn should no longer be hurt
				if( VSize( Location - fPawnBeingHurt.Location ) > ( ( Pawn.CollisionRadius * 1.10 ) /2 ) )
				{
					fPawnBeingHurt=None;
				}
			}
		}
		
		return true;
	}
	else
	{
		return false;
	}
}

function AttackOthers()
{
	// The drilling machine does not attack as a normal AI would - it instead will always be in 'hunt' mode - trying to 
	// touch it's target, and thereby do it injury.

	local B9_BasicPlayerPawn assailPawn;
	local float rangeToTarget, closestTarget, maxRangeToTarget;

	//log( "ALEX: IN DRILLING MACHINE attack others" );

	if( B9_ArchetypePawnCombatant( Pawn ).bHostile == false )
	{
		return;
	}

	// Set closest target to an impossibly large value.
	closestTarget = 9999999.0;

	
	// Set the attack range of the pawn 
	B9_ArchetypePawnCombatant( Pawn ).fMaxAttackTargetRange = B9_ArchetypePawnCombatantDrillingMachine( Pawn ).fMaxAttackRange;
		
	if( CanAttack() && !IsInState( 'Hunting' ) )
	{
//		Log( "ALEX: B9_AI_OldControllerCombatant consider's hunting" );

		assailPawn = None;
		maxRangeToTarget = B9_ArchetypePawnCombatant( Pawn ).fMaxAttackTargetRange;
		
		// Attack just the player
		ForEach Pawn.VisibleActors( class'B9_BasicPlayerPawn', assailPawn, B9_ArchetypePawnCombatant( Pawn ).fMaxAttackTargetRange )
		{
			if( assailPawn != B9_AdvancedPawn( Pawn ) && assailPawn.Health > 0)
			{
				//log( "ALEX: Checking potential target: " $assailPawn );

				rangeToTarget = VSize( Pawn.Location - assailPawn.Location );
				if( rangeToTarget < maxRangeToTarget && 
					rangeToTarget < closestTarget )
				{
					//Log( "B9_AI_OldControllerCombatant considering " $ assailPawn.Name $ ", range " $ string(rangeToTarget));
		
					fRangeToAssail = rangeToTarget;
					closestTarget = rangeToTarget;
					
					// Set the enemy
					SetAsEnemy( assailPawn );
				}
			}
		}

		// If a new target has been aquired, Start hunting it
  		if( closestTarget < maxRangeToTarget )
  		{
  			//log( "ALEX: In range, hunting." );

  			GotoState( 'Hunting' );
  		}

		//log( "ALEX: NOT hunting." );
	}
}

