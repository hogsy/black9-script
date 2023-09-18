//////////////////////////////////////////////////////////////////////////
//
// Black 9 Controller Civilian
//
//////////////////////////////////////////////////////////////////////////
class B9_AI_ControllerCivilian extends B9_AI_ControllerBase;

// Vars
var vector			fRandomDirection;
var const float		fBumpedSleepTime;
var float			fLastBumpTime;
var const float		fTimeToCowerFromLastBump;
var float			fCowerBegTime;
var float			fCowerMidTime;
var float			fCowerEndTime;
var (Civilian) bool	fHasGun;

var float			fAttackFacingSeconds;
var bool			fHoldWeapon;
var bool			fWillTeleport;
var float			fSavedAnimSpeed;

var bool			fWaitHere;

//var PathNode		fBadHidingPlace;
//var PathNode		fLastHidingPlace;



var B9_ArchetypePawnBase	fCowerTarget;
var float					fCowerTargetRange;

function bool Think()
{
	if( Super.Think() == true )
	{
		// Check to see if a following civilian should drop itself off
		CheckForDropOff();
		return true;
	}
	else
	{
		return false;
	}
}

// Events
event bool NotifyBump( Actor Other )
{
	// React to the bump
	ReactToBump( other );
	return false;
}

// States
state Start 
{
	function init()
	{
		log( "Civilian idle init function called" );
		Pawn.Acceleration = vect( 0, 0, 0 );
		
		
		GotoState( 'Travel' );
	}
begin:
	init();
}

state DropedOff
{
	simulated function BeginState()
	{
		local B9_ArchetypePawnBase P;

		P = B9_ArchetypePawnBase( Pawn );
		if( P != None && ( P.RescueScriptTag != 'None' && P.RescueScriptTag != '' ) )
		{
			P.Rescued();
			GotoState( '' );
		}
	}

	function float SetAnimSpeed( float speed )
	{
		local float animRate, animFrame;
		local name outSeqName;
		
		Pawn.GetAnimParams( 0, outSeqName, animFrame, animRate );
		Pawn.SetAnimRate( 0, speed );
		
		return animRate;
	}

Begin:

	//	Log( "Civilian is in a bumped state" );
	Pawn.Acceleration = vect( 0, 0, 0 );

	// Set focus to prior leader
	Focus = fHuntingForActor;

	// Not following anymore
	AttitudeToPlayer = ATTITUDE_Friendly;
	fHuntingForActor = None;

	// bob
	//fSavedAnimSpeed = SetAnimSpeed( 1000.f );
	Pawn.FinishAnim();
	//SetAnimSpeed( fSavedAnimSpeed );

	Pawn.PlayAnim( 'head_bob', 0.5 + 0.5 * frand(), 0.5 );
	
//	log( "ALEX: Should be bowing" );
}

state Travel
{
	function bool AlternateAction()
	{
		local B9_PlayerPawn PP;

		if (B9_ArchetypeCivilianPawn(Pawn).fCanTeleport)
		{
			if (fWillTeleport)
			{
				ForEach Pawn.VisibleActors( class'B9_PlayerPawn', PP )
				{
					fWillTeleport = !TeleportToMeleeRange(PP, true, 100.0f, 200.0f, 1.0f);
					return true;
				}
			}
			else
			{
				fWillTeleport = true;
			}
		}

		return false;
	}
}

state PlayerBumped
{
Begin:
	//	Log( "Civilian is in a bumped state" );
	Pawn.Acceleration = vect( 0, 0, 0 );

	// bob
	Pawn.PlayAnim( 'head_bob', 0.5 + 0.5 * frand(), 0.5 );
		
	// Stay bumped for a while
	Sleep( fBumpedSleepTime * 0.5 + frand() );

	// go into an idle state
	GotoState( fDefaultState );
}

state Cower
{
Begin:

//	log( "Cowering" );

	// Stop moving
	MoveTo( Pawn.Location );
	Pawn.Acceleration = vect( 0, 0, 0 );

	// Focus on it
	Focus = fCowerTarget;
	
	fCowerBegTime = 1.0 + 0.5 * frand();
	fCowerMidTime = 1.0 + 0.5 * frand();
	fCowerEndTime = 0.5 + 0.5 * frand();

	Pawn.Acceleration	= vect( 0, 0, 0 );
	fLastBumpTime		= Level.TimeSeconds;

	// Go into a cowering stance
	Pawn.PlayAnim( 'cower_begining', fCowerBegTime, 0.5 );
	Sleep( fCowerBegTime );
	
	// Now cower in earnest
	Pawn.LoopAnim( 'cower_middle', fCowerMidTime, 0.5 ); 
RemainCowering:

	// Ensure the pawn knows how to continue the cowering animation
	B9_ArchetypePawnBase( Pawn ).fWaitingAnimationState = kAnimCower;
	Sleep( Max( fTimeToCowerFromLastBump, fCowerMidTime ) );
	
	// Check to see if this guy should still be cowering
	if( CowerTargetStillInArea() )
	{
		Goto( 'RemainCowering' );
	}
	else
	{
//		log( "Not in area, going to idle state" );

		// Clear the cower target
		fCowerTarget = None;

		// Now un-cower
		Pawn.PlayAnim( 'cower_end', fCowerEndTime, 0.5 );
		Sleep( fCowerEndTime );

		// Reset the waiting animation
		B9_ArchetypePawnBase( Pawn ).fWaitingAnimationState = kAnimIdle;

		// Otherwise go back to the idle state
		GotoState( 'Idle' );
	}
}

state Attack
{

Begin:
	Pawn.Acceleration = vect( 0, 0, 0 );
	
	if (Pawn.Weapon == None)
		Weapon(Pawn.FindInventoryType( class'B9Weapons.pistol_9mm' )).ClientWeaponSet(true);
	
//	Log( "Civilian enters Attack state " $ string(Pawn.Weapon.ReloadCount) $ "/" $ string(Pawn.Weapon.AmmoType.AmmoAmount) );

	if (NeedToTurn(Focus.Location))
	{
		Focus = Target;
		FinishRotation();
	}
	if (!NeedToTurn(Focus.Location))
	{
		if (!fHoldWeapon)
		{
			Pawn.PlayAnim( 'shoot_pistol' );
			Sleep( 0.5 );
			Enemy = Pawn(Focus);

//			Log( "Civilian firing " $ Pawn.Weapon.Name $ " at " $ Enemy.Name );
			
			FireWeaponAt(Enemy);

			Sleep( 3 );
			StopFiring();
			//if (!fHoldWeapon)
				B9_ArchetypePawnBase( Pawn ).PutAwayWeapon();

			//Log( "9mm pistol ammo after shooting=" $ string(Pawn.Weapon.ReloadCount) $ "/" $ string(Pawn.Weapon.AmmoType.AmmoAmount) );
		}
		else
		{
			Spawn(class'B9_TossedGrenade',Pawn,'',Pawn.Location,Pawn.Rotation);
		}

		fHoldWeapon = !fHoldWeapon;
	}

	GotoState( 'Idle' );
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
		else if (fWaitHere)
		{
			Log("MikeT: Pause hunting, move to: " $MoveTarget);
			fPauseFor = 0.5;
			return kPause;
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

function CheckForDropOff()
{
	local PathNodeNamed namedNode;
	local bool			fDropOff;

	// If this follower can be dropped off, try to find the right spot to drop off
	if( fHuntingForActor != None &&
		AttitudeToPlayer == ATTITUDE_Follow &&
		B9_ArchetypeCivilianPawn( Pawn ).fDropOffPoint != 'None' )
	{
		
		fDropOff = false;

		// Finding just one equals success.
		ForEach Pawn.RadiusActors( class'PathNodeNamed', namedNode, B9_ArchetypeCivilianPawn( Pawn ).fDropOffRadius )
		{
			if( namedNode.fName == B9_ArchetypeCivilianPawn( Pawn ).fDropOffPoint )
			{
				fDropOff = true;
				break;
			}
		}

		if( fDropOff )
		{
			GotoState( 'DropedOff' );
		}
	}
}



function ReceiveWarning( Pawn shooter, float projSpeed, vector FireDir )
{
//	log( "ALEX: IN ReceiveWarning at CIVILIAN" );
}



function IntimidatedBy( B9_ArchetypePawnBase pawn )
{
	if( fCowerTarget != pawn && pawn != None )
	{
		// Find out if the civilian is intimidated
		if( pawn.GetIntimidationValue() > 0.1 )
		{
			fCowerTarget			= pawn;
			fCowerTargetRange		= pawn.GetIntimidationRange();

			// Stop moving
			//Pawn.Acceleration = vect( 0, 0, 0 );
			//MoveToward( Pawn )
			Destination = Pawn.Location;

			//@@@
	
//			log( "ALEX: In IntimiatedBy: Now doing cowering animations" );
			
			// ANF@@@ Do a state change here instead?
			if ( B9_ArchetypeCivilianPawn( Pawn ) != None )
			{
				//B9_ArchetypeCivilianPawn( Pawn ).AnimateCowering();
			}

			//@@@

			GotoState( 'Cower' );
		}
	}
}

function B9_ArchetypePawnBase GetCowerTarget()
{
	local B9_ArchetypePawnCombatant ComPawn;

	// See if any combat pawn are near
	ForEach RadiusActors( class'B9_ArchetypePawnCombatant',ComPawn, 500 )
	{
//		log( "Found something to cower about" );
		return ComPawn;
	}

	return None;
}

function bool CowerTargetStillInArea()
{
	local float cowerTargetDistance;

	if( fCowerTarget != None )
	{
		cowerTargetDistance = VSize( fCowerTarget.Location - Pawn.Location );
		if( cowerTargetDistance <= fCowerTargetRange )
		{
//			log( "Still in area" );
			return true;
		}
	}

	return false;	
}


function ReactToBump( Actor other )
{
	if( other.IsA( 'Pawn' )  )
	{
		if( Pawn( other ).Controller.bIsPlayer ) 
		{
			if( B9_ArchetypeCivilianPawn( Pawn ).fFollowWhenBumpedByPlayer )
			{
				AttitudeToPlayer = ATTITUDE_Follow;

				// Follow this player ( by hunting them )
				fHuntingForActor = other;

				// Goto the default state for this AI
				GotoState( fDefaultState );
			}
			else
			{
				// Focus on the actor that just bumped the civilian
				Focus = other;

				// Have the pawn make a 'I'm annoyed' noise
				B9_ArchetypeCivilianPawn( Pawn ).PlayBumpedSound();
				
				if (B9_ArchetypeCivilianPawn( Pawn ).fIsAggressive)
					fHasGun = false;

				if( fHasGun == true )
				{
					// Drop a swarm gun.
					//Spawn( class'SwarmGunPickup',,, B9_ArchetypeCivilianPawn( Pawn ).GetItemDropLocation() );

					// You don't have a gun any longer.
					fHasGun = false;
	//				log( "has gun turned off" );
				}
				
				// Go into the bumped state
				GotoState( 'PlayerBumped' );
			}
		}
	}
	else
	{
		// Do nothing
	}
}

/*
AdjustAim()
Returns a rotation which is the direction the bot should aim - after introducing the appropriate aiming error
*/
function rotator AdjustAim(Ammunition FiredAmmunition, vector projStart, int aimerror)
{
	// NYI: !!!! Not a really accurate simulation of firing -- need for milestone (see Bot.uc for better code)
	local vector aimvec;
	local float range;

	// make sure bot has a valid target
	if ( Target == None )
	{
		Target = Enemy;
		if ( Target == None )
		{
			StopFiring();
			return Rotation;
		}
	}
	
	aimvec = Target.Location - projStart;
	range = VSize(aimvec);

	// NYI: !!!! Always hit out to 200 units, then the probability of accurate aim
	// linearly drops to 0 at 1500 units. TEST CODE.
	if (range < 200.0f || Frand() < 1.0f - (range - 200.0f) / 1300.0f)
		return rotator(aimvec);
	return Rotation;
}


defaultproperties
{
	fBumpedSleepTime=8
	fTimeToCowerFromLastBump=3
	fFirstState=Start
	AttitudeToPlayer=5
}