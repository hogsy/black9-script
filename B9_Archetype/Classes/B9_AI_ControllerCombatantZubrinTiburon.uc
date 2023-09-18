//////////////////////////////////////////////////////////////////////////
//
// Black 9 Controller Combatant Spider
//
//////////////////////////////////////////////////////////////////////////
class B9_AI_ControllerCombatantZubrinTiburon extends B9_AI_ControllerCombatant;


var float	fTimeFinishFiring;
var bool	fAllowFire;


// We override WhatToDoNext() so that B9's custom behaviors can show up.
function WhatToDoNext( byte CallingByte )
{
	// If we have line of sight to the enemy, open fire.  Pick regular or bad ass gun.
	if ((fTimeFinishFiring < Level.TimeSeconds) && (Enemy != None) && LineOfSightTo(Enemy))
	{
		GotoState('Firing');
		return;
	}
	
	// Move towards the enemy.
	Super.WhatToDoNext(CallingByte);
}


function DoRangedAttackOn(Actor A)
{
	// We can't really do a ranged attack, so we do a Tactical move.
	if (frand() < 0.5)
		DoTacticalMove();
	else
		DoCharge();
}


function bool WeaponFireAgain(float RefireRate, bool bFinishedFire)
{
	// We can't fire the weapon unless we aren't moving.
	if (fAllowFire)
		return Super.WeaponFireAgain(RefireRate, bFinishedFire);
		
	return false;
}


state Firing
{
ignores SeePlayer, EnemyNotVisible, HearNoise, ReceiveWarning, NotifyLanded, NotifyPhysicsVolumeChange,
		NotifyHeadVolumeChange,NotifyLanded,NotifyHitWall,NotifyBump;

	function EndState()
	{
		Pawn.StopPlayFiring();
		fAllowFire = false;
	}
	
	function Timer()
	{
		if ( (Enemy != None) && LineOfSightTo(Enemy) )
			FireWeaponAt(Enemy);
		else
			WhatToDoNext(200);
	}

	function bool TurnTowardEnemy()
	{
		// Face the target
		Focus = Enemy;
		// Turn toward the target
		return ( NeedToTurn( Focus.Location ) );
	}


Begin:
	// Stop moving.
	MoveTo(Pawn.Location);

	fAllowFire = true;
	
	// Turn towards the opponent
	fTimeFinishFiring = Level.TimeSeconds + 3 + frand()*4;
	while (fTimeFinishFiring > Level.TimeSeconds)
	{
		// Ensure AI is pointed toward it's target
		if( TurnTowardEnemy() )
			FinishRotation();
		
		sleep(0.1);
	}
	
	fTimeFinishFiring = Level.TimeSeconds + 3 + frand()*4;
	WhatToDoNext(201);
}


