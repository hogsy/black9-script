class B9_VehicleTrigger extends ScriptedSequence
	notplaceable;




var name			fEnterAnim;
var name			fOperateAnim;
var name			fExitAnim;
var vector			fOffset;
var float			fRetriggerDelay;
var	float			fTriggerTime;
var B9_AdvancedPawn	fOperator;




function Touch( Actor Other )
{
	if ( fOperator == None )
	{
		if ( Other.Instigator != None )
		{
			if ( fRetriggerDelay > 0 )
			{
				if ( Level.TimeSeconds - fTriggerTime < fRetriggerDelay )
				{
					return;
				}

				fTriggerTime	= Level.TimeSeconds;
			}

			Other.Instigator.ClientMessage( "Press USE to operate." );
		}
	}
}

function Set( name enterAnim, name operateAnim, name exitAnim, vector offset )
{
	fOffset			= offset;
	fEnterAnim		= enterAnim;
	fOperateAnim	= operateAnim;
	fExitAnim		= exitAnim;

	InitLocation();
}

function InitLocation()
{
	local vector	rotX, rotY, rotZ;


    GetAxes( Owner.Rotation, rotX, rotY, rotZ );
	SetLocation( Owner.Location + fOffset.X * rotX + fOffset.Y * rotY + fOffset.Z * rotZ );
	SetBase( Owner );
}

function BeginSequence( name animName )
{
	local vector	rotX, rotY, rotZ;


	fOperator.bRollToDesired	= true;
	fOperator.DesiredRotation	= Rotation;
	fOperator.SetCollision( false, false, false );
	fOperator.SetPhysics( PHYS_None );

	// adjust location for player height so animation is correct
	GetAxes( Rotation, rotX, rotY, rotZ );
	SetLocation( Location + rotZ * ( fOperator.CollisionHeight ) );
	SetBase( Owner );

	Action_PLAYANIM( Actions[ 1 ] ).BaseAnim	= animName;

	TakeOver( fOperator );

	// keep the pawn relative to the vehicle, not the ScriptedController
	fOperator.SetBase( Owner );
}

function EndSequence( ScriptedController C )
{
	fOperator.bRollToDesired	= false;
	C.LeaveScripting();

	InitLocation();
}

function bool PlayingSequence()
{
	local bool	playingSequence;


	playingSequence	= false;

	if ( fOperator != None )
	{
		playingSequence	= ScriptedController( fOperator.Controller ) != None;
	}

	return playingSequence;
}

function PreSequence( Pawn user )
{
	if ( B9_Vehicle( Owner ) != None )
	{
		B9_Vehicle( Owner ).PreSequence( user );
	}
	else
	if ( B9_KVehicle( Owner ) != None )
	{
		B9_KVehicle( Owner ).PreSequence( user );
	}
}

function PostSequence( Pawn user )
{
	if ( B9_Vehicle( Owner ) != None )
	{
		B9_Vehicle( Owner ).PostSequence( user );
	}
	else
	if ( B9_KVehicle( Owner ) != None )
	{
		B9_KVehicle( Owner ).PostSequence( user );
	}
}

auto state Waiting
{
	function UsedBy( Pawn user )
	{
		if ( ( fOperator == None ) && user.IsPlayerPawn() )
		{
			fOperator	= B9_AdvancedPawn( user );

//			PreSequence( fOperator );
//			BeginSequence( fEnterAnim );
			log( "SCDTemp: B9_VehicleTrigger::Waiting::UsedBy()" );
			B9_Vehicle( Owner ).DriverEnter( fOperator );

			GotoState( 'Operating' );
		}
	}

	function SetActions( ScriptedController C )
	{
		if ( C.ActionNum == Actions.Length )
		{
			EndSequence( C );
			PostSequence( fOperator );

			// start looping operating anim
			fOperator.LoopIfNeeded( fOperateAnim, 1.0, 0.0 );

			if ( B9_Vehicle( Owner ) != None )
			{
				B9_Vehicle( Owner ).DriverEnter( fOperator );

				GotoState( 'Operating' );
			}
			else
			if ( B9_KVehicle( Owner ) != None )
			{
				B9_KVehicle( Owner ).DriverEnter( fOperator );

				GotoState( 'Operating' );
			}
		}
		else
		{
			Super.SetActions( C );
		}
	}
}

state Operating
{
	function UsedBy( Pawn user )
	{
		if ( user == fOperator )
		{
			// stop looping operating anim
//			fOperator.AnimBlendToAlpha( 0, 0, 0.1 );

//			PreSequence( fOperator );
//			BeginSequence( fExitAnim );

			log( "SCDTemp: B9_VehicleTrigger::Operating::UsedBy()" );
			B9_Vehicle( Owner ).DriverLeave();
		}
	}

	function SetActions( ScriptedController C )
	{
		if ( C.ActionNum == Actions.Length )
		{
			EndSequence( C );
			PostSequence( fOperator );

			if ( B9_Vehicle( Owner ) != None )
			{
				B9_Vehicle( Owner ).DriverLeave();

				fOperator	= None;

				GotoState( 'Waiting' );
			}
			if ( B9_KVehicle( Owner ) != None )
			{
				B9_KVehicle( Owner ).DriverLeave();

				fOperator	= None;

				GotoState( 'Waiting' );
			}
		}
		else
		{
			Super.SetActions( C );
		}
	}
}

defaultproperties
{
	fRetriggerDelay=1
	Actions=/* Array type was not detected. */
	ScriptControllerClass=none
	bStatic=false
	bOnlyAffectPawns=true
	bCollideWhenPlacing=false
	CollisionRadius=80
}