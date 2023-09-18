//////////////////////////////////////////////////////////////////////////
//
// Black 9 Surface scrubbing automaton.
//
//////////////////////////////////////////////////////////////////////////
class B9_AI_ControllerScrubberBot extends B9_AI_ControllerBase;

/* New bahaviour: Instead of using the path nodes for movement orientation and goal selection, these little guys will 
   randomly choose a vector of direction and travel along said vector for a variable length of time.  When said variable time
   has expired, they will wait at their end goal then start the process over again by selecting a new random vector of 
   direction.
*/

var() const float BASE_WANDER_TIME;
var() const float VARIABLE_WANDER_TIME;
var() const float RUN_CHANCE;
var() const float BASE_IDLE_TIME;
var() const float VARIABLE_IDLE_TIME;

var bool	fFindNewWanderVector;
var float	fWanderTimerInterval;
var vector	fWanderDirection;
var bool	fAgainstWall;
var vector  fWallHitVector;
var vector  fWallHitVelocity;

function PostBeginPlay()
{
	// Setup the timer for checking the wander states
	SetTimer( fWanderTimerInterval, true );
}

auto state Idle
{
	event bool NotifyHitWall( vector HitNormal, actor HitActor )
	{
		fWallHitVector = HitNormal;
		fWallHitVelocity = Pawn.Velocity;
		fAgainstWall = true;
		return true;
	}

Begin:

WanderAndClean:
	//Log( "Scrubber is wandering and cleaning" );
	
	// Run if needed, otherwise walk.
	if( Frand() < RUN_CHANCE )
	{
		Run( fWanderDirection );
	}
	else
	{
		Walk( fWanderDirection );
	}
	
	// Wait for a variable period of time (as it's cleaning/wandering
	Sleep( BASE_WANDER_TIME + Frand() * VARIABLE_WANDER_TIME );

	// Now stop
	StopMoving();

	// Wait for a varible period of time (as it's idling)
	Sleep( BASE_IDLE_TIME + Frand() * VARIABLE_IDLE_TIME );


	// Determine a new vector
	
	if( fAgainstWall )
	{
		// Reflect off the Wall 
		fWanderDirection = ( fWallHitVelocity dot fWallHitVector ) * fWallHitVector * ( -2.0 ) + fWallHitVelocity;   
		fAgainstWall = false;
	}
	else
	{
		fWanderDirection = GenerateRandomDirection();
	}
	
	// Go back to wandering and cleaning.
	Goto( 'WanderAndClean' );
}

defaultproperties
{
	BASE_WANDER_TIME=2
	VARIABLE_WANDER_TIME=5
	RUN_CHANCE=0.3
	BASE_IDLE_TIME=1
	VARIABLE_IDLE_TIME=4
	fFindNewWanderVector=true
	fWanderTimerInterval=3
	AttitudeToPlayer=4
}