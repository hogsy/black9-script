//////////////////////////////////////////////////////////////////////////
//
// Black 9 Controller Combatant Clockwork Charles
//
//////////////////////////////////////////////////////////////////////////
class B9_AI_ControllerCombatantGenesisClockworkCharles extends B9_AI_ControllerCombatant;

var float NextDrainAttack;
var float NextTeleport;

var float DrainAttackDelay;
var float DrainPerSecond;
var float TeleportDelay;

// We override WhatToDoNext() so that B9's custom behaviors can show up.
function WhatToDoNext( byte CallingByte )
{
	local B9_AdvancedPawn test;
	
	if (Enemy != None)
	{
		test = B9_AdvancedPawn(Enemy);

		if ( (NextDrainAttack < Level.TimeSeconds) && (test != None) && ((test.fCharacterFocus*2) > test.fCharacterMaxFocus) &&
			 LineOfSightTo(Enemy) )
		{
			GotoState('DrainAttack');
			return;
		}
		else if (NextTeleport < Level.TimeSeconds)
		{
			
			GotoState('Teleport');
			return;
		}
	}

	Super.WhatToDoNext(CallingByte);
}


function bool SetEnemy(Pawn P)
{
	if (Enemy == None)
	{
		NextDrainAttack = Level.TimeSeconds + DrainAttackDelay + frand()*DrainAttackDelay;
		NextTeleport = Level.TimeSeconds + TeleportDelay + frand()*TeleportDelay;
	}
	
	return Super.SetEnemy(P);
}



// Does the drain attack on the player.  Basically, it runs the nano attack animation continuously until the
// enemy's focus is 0, or is dead.
state DrainAttack
{
ignores SeePlayer, EnemyNotVisible, HearNoise, ReceiveWarning, NotifyLanded, NotifyPhysicsVolumeChange,
		NotifyHeadVolumeChange,NotifyLanded,NotifyHitWall,NotifyBump;

	event AnimEnd(int Channel)
	{
	}

	function Timer()
	{
	}
	
	function EndState()
	{
		Pawn.StopPlayFiring();
	}

	function Tick( float timeDelta )
	{
		local B9_AdvancedPawn target;

		Super.Tick(timeDelta);
		
		target = B9_AdvancedPawn(Enemy);
		if (target == None)
		{
			NextDrainAttack = Level.TimeSeconds + DrainAttackDelay + frand()*DrainAttackDelay;
			log("MikeT: Drain Attack lost enemy.");
			StopFiring();
			WhatToDoNext(1000);
		}
		else // Drain enemy focus.
			target.fCharacterFocus -= DrainPerSecond * target.fCharacterMaxFocus * timeDelta;

		// If enemy focus is 0, stop animation and call what to do next.
		if ((target.fCharacterFocus <= 0) || (target.Health <= 0))
		{
			log("MikeT: Drain Attack ending; enemy health or focus at 0.");
			target.fCharacterFocus = 0;
			NextDrainAttack = Level.TimeSeconds + DrainAttackDelay + frand()*DrainAttackDelay;
			StopFiring();
			WhatToDoNext(1001);
		}
	}

Begin:
	// Play nano attack animation.
	log("MikeT: Clockwork Charles Drain Attack.");
	StopFiring();
	NextDrainAttack = Level.TimeSeconds + DrainAttackDelay + frand()*DrainAttackDelay;
	B9_AdvancedPawn(Pawn).PlayNanoAttack();
}


// Does the teleport attack on the player.  Finds pathnodes that are marked as teleporting, then
state Teleport
{
	function DoIt()
	{
		local PathNodeNamed namedNode;
		local PathNodeNamed bestNode;
		local float			chance;
		local float			bestChance;
	
		bestNode = None;
		// Find new spot to teleport to.
		ForEach Pawn.AllActors( class'PathNodeNamed', namedNode )
		{
			if (namedNode.fName == 'TeleportNode')
			{
				// Randomly pick a new position to telport to.
				chance = frand();
				if ( (bestNode == None) || (bestChance > chance) )
				{
					bestNode = namedNode;
					bestChance = chance;
				}
			}
		}
		
		// Some teleporting effect?
		if (bestNode != None)
			Pawn.SetLocation(bestNode.Location);
	}

Begin:
	// Teleports to melee range every once in a while.
	if ( (frand() < 0.25) || !LineOfSightTo(Enemy) )
	{
		log("Miket: Clockwork Charles teleporting to mele range.");
		TeleportToMeleeRange(Enemy, true, 200, 400, 1.0);
	}
	else
	{
		log("Miket: Clockwork Charles teleporting to pathnode.");
		DoIt();
	}

	NextTeleport = Level.TimeSeconds + TeleportDelay + frand()*TeleportDelay;
	WhatToDoNext(1002);
}



defaultproperties
{
	DrainAttackDelay=8
	DrainPerSecond=0.35
	TeleportDelay=15
}