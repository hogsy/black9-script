//////////////////////////////////////////////////////////////////////////
//
// Black 9 Controller Combatant Spider
//
//////////////////////////////////////////////////////////////////////////
class B9_AI_ControllerCombatantGenesisSpider extends B9_AI_ControllerCombatant;


var name fDormantAnim;
var float fLastCheckedCocked;
var bool fFirst;

// States
simulated state Dormant
{
	event SeePlayer( Pawn Seen )
	{
		// Do nothing
	}

	event SeeMonster( Pawn Seen )
	{
		// Do nothing
	}

	event AnimEnd(int Channel)
	{
		// Do nothing
	}

	event MonitoredPawnAlert()
	{
		// Do nothing
	}

	function PlayDormant()
	{
		Pawn.LoopAnim(fDormantAnim);
	}

Begin:
	PlayDormant();
	//Log("MikeT: Spider sleeping.");
	Sleep(2);
	while (Pawn.Physics == PHYS_Falling)
	{
		Sleep(0.4);
	}
	Sleep(0.5);
	//Log("MikeT: Spider going to WhatToDoNext, physics: " $Pawn.bPhysicsAnimUpdate);
	Pawn.bPhysicsAnimUpdate = true;
	WhatToDoNext(53);
}


simulated function Tick( float timeDelta )
{
	if (fFirst)
	{
		fFirst = false;
		//log("MikeT: In Dormant state.");
		GotoState('Dormant');
		return;
	}

	if( Role == ROLE_Authority )
	{
		Super.Tick(timeDelta);

		if (Enemy != None )
		{
			if (( Level.TimeSeconds - fLastCheckedCocked) > 1 )
			{
				fLastCheckedCocked = Level.TimeSeconds;
				if ( B9_ArchetypePawnCombatantGenesisSpiderBot(Pawn).fCocked &&
					(VSize(Pawn.Location - Enemy.Location) > Pawn.Weapon.MaxRange) )
				{
					B9_ArchetypePawnCombatantGenesisSpiderBot(Pawn).PlayPostFire();
				}
			}
		}
	}
}


simulated function SetFall()
{
	if (IsInState('Dormant'))
		return;

	Super.SetFall();
}


// We override WhatToDoNext() so that B9's custom behaviors can show up.
function WhatToDoNext( byte CallingByte )
{
	if (fFirst)
	{
		fFirst = false;
		//log("MikeT: In Dormant state.");
		GotoState('Dormant');
	}
	else
		Super.WhatToDoNext(CallingByte);
}




defaultproperties
{
	fDormantAnim=nowpn_idle_dormant
	fFirst=true
	bJumpy=true
}