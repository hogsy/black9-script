//////////////////////////////////////////////////////////////////////////
//
// Black 9 Controller Civilian, Joe-style
//
//////////////////////////////////////////////////////////////////////////
class B9_AI_ControllerCivilian_Joe extends B9_AI_ControllerCivilian;

var float fLastBestPathCalcTicks;

auto state Idle
{
Begin:
	Pawn.Acceleration = vect( 0, 0, 0 );
	if ( Pawn.Weapon != None )
		B9_ArchetypePawnBase( Pawn ).PutAwayWeapon();

//	log( "Taking cover from pawn" );
//	GotoState( 'Hide' );
	GotoState( 'TakeCover' );
//	GotoState( 'Wander' );
}

state TakeCover extends Hide
{
	function bool PathNodeGoodness(PathNode pn)
	{
		return B9_PathNode(pn) != None && B9_PathNode(pn).fGoodForCoverFire;
	}

	function name SuccessStateName()
	{
		return 'FireFromCover';
	}

	function name FailureStateName()
	{
		return 'Attack';
	}
}

state RestInOpen
{
	function SeeSomething( Pawn Seen )
	{
		SetEnemyByHidingFromPawnClass();
		if (Enemy != None && Pawn.Controller.CanSee(Seen))
		{
//			Log("Rest in open terminated by " $Seen);
			GotoState('Idle');
		}
	}

	event SeePlayer( Pawn Seen )
	{
		SeeSomething( Seen );
	}

	event SeeMonster( Pawn Seen )
	{
		SeeSomething( Seen );
	}

	function vector GetSpinPoint(vector dest)
	{
		local vector v;
		v = dest - Pawn.Location;
		return v * (80.0f / VSize(v)) + Pawn.Location;
	}

Begin:
	// We're not in good cover, but we can't be seen by Enemy
//	log( "Rest in open" );
	if (bEnemyInfoValid)
	{
		if (NeedToTurn(LastSeeingPos))
		{
			MoveTo(GetSpinPoint(LastSeeingPos));
			FinishRotation();
		}
	}
	Pawn.Acceleration = vect( 0, 0, 0 );
	Sleep( 10.0f ); // go to sleep, can be awakened by SeePlayer/SeeMonster
//	log( "Rest in open - finis" );
	GotoState('Idle');
}

state FireFromCover
{
	function PickFireLocation()
	{
		local B9_PathNode pnode;
		local PathNode bestNode;
		local int n;
		local int i;
		local float dist, bestDist;

		pnode = B9_PathNode(fLastHidingPlace);

		if (pnode != None && pnode.fCoverFireNodes[0] != None)
		{
			if (bEnemyInfoValid)
			{
				bestDist = 1000000.0f;
				for (n=0;n<4 && pnode.fCoverFireNodes[n] != None;n++)
				{
					dist = VSize(LastSeenPos - pnode.fCoverFireNodes[n].Location);
					if (dist < bestDist)
					{
						dist = bestDist;
						bestNode = pnode.fCoverFireNodes[n];
					}
				}

				if (bestNode != None)
				{
					SetRouteGoal(bestNode);
					return;
				}
			}

			i = 0;
			n = Rand(4);
			while (pnode.fCoverFireNodes[n] == None)
			{
				if (++i == 25) n = 0;
				else n = Rand(4);
			}

			SetRouteGoal(pnode.fCoverFireNodes[n]);
		}
	}

	function TweekLocationTowardsBestPath()
	{
		Pawn.SetLocation((fBestPath.Location - Pawn.Location) * 0.25f + Pawn.Location);
	}

Begin:
	Pawn.Acceleration = vect( 0, 0, 0 );

	if (fLastHidingPlace == None)
		GotoState( 'RestInOpen' );

	PickFireLocation();

//	log( "Initial fire location: " $ RouteGoal );

Loop:
	fBestPath = None;
	while (RouteGoal != None)
	{
		if( Pawn.ReachedDestination( RouteGoal ) )
			break;

//		log( RouteGoal $ "  " $ fBestPath $ " " $ fCurrentNavPoint $ " " $ fBadHidingPlace );

		if( fBestPath == None || Pawn.ReachedDestination( fBestPath ) )
		{
//			Log( "Reached fBestPath " $ fBestPath ); 
			fCurrentNavPoint = fBestPath;
			fBestPath = FindPathToward( RouteGoal, true );
			fLastBestPathCalcTicks = Level.TimeSeconds;

			if (MoveTarget != None)
			{
//				log( "MoveToward: " $ MoveTarget );
				Pawn.SetWalking( RouteGoal != fLastHidingPlace );
				MoveToward( MoveTarget, MoveTarget,,,Pawn.bIsWalking );
			}
			else
			{
//				log( "MoveTarget is None!" );
				SetRouteGoal(None);
				break;
			}
		}
		else if ( fLastBestPathCalcTicks > 1.0f )
		{
			// What has happened here is that MoveToward says we have reached fBestPath,
			// but ReachedDestination disagrees. So, lets move the character a little closer
			// to fBestPath and hope for the best. We also sleep to make interpreter happy.
//			log( "MoveToward returned without really reaching goal!" );

			Sleep( 0.2 );
			TweekLocationTowardsBestPath();
			fLastBestPathCalcTicks = Level.TimeSeconds;
		}
	}

//	log( "Final fBestPath: " $ fBestPath );

	SetEnemyByHidingFromPawnClass();
	if (Enemy != None && Pawn.Controller.CanSee(Enemy))
	{
//		log( "See an enemy" );

		if (RouteGoal != fLastHidingPlace)
			GotoState( 'Attack' );
		else
			GotoState( 'TakeCover' );
	}

	bEnemyInfoValid = false;
//	log( "Can't see the enemy / fLastHidingPlace is " $	fLastHidingPlace );

	if (RouteGoal == None || RouteGoal != fLastHidingPlace)
		SetRouteGoal(fLastHidingPlace);
	else
		PickFireLocation();

//	log( "New dest " $ RouteGoal );

	Sleep( 1 );
	Goto( 'Loop' );
}

state Attack
{
Begin:
	Pawn.Acceleration = vect( 0, 0, 0 );
	
	if (Pawn.Weapon == None)
		Weapon(Pawn.FindInventoryType( class'B9Weapons.pistol_9mm' )).ClientWeaponSet(true);
	
//	Log( "Civilian enters Attack state " $ string(Pawn.Weapon.ReloadCount) $ "/" $ string(Pawn.Weapon.AmmoType.AmmoAmount) );

	if (NeedToTurn(Enemy.Location))
	{
		Focus = Enemy;
		FinishRotation();
	}
	if (!NeedToTurn(Enemy.Location))
	{
		Pawn.PlayAnim( 'shoot_pistol' );
		Sleep( 0.5 );

//		Log( "Civilian firing " $ Pawn.Weapon.Name $ " at " $ Enemy.Name );
		
		FireWeaponAt(Enemy);

		Sleep( 3 );

		StopFiring();

		//Log( "9mm pistol ammo after shooting=" $ string(Pawn.Weapon.ReloadCount) $ "/" $ string(Pawn.Weapon.AmmoType.AmmoAmount) );
	}

	GotoState( 'TakeCover' );
}

