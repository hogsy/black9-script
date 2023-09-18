//=============================================================================
// B9MP_Online.
//
//	Any Multiplayer class that interacts with a service will inherit from this
//	class.
//
//
//
//
//=============================================================================
class B9MP_Online extends B9MP_OnlineCore
	native;


// Runtime
var float		fAccumulatedTime;


/************************************************************************************************************
 *
 *	Init
 *		Place any initialization code that can fail here.  Should always be called after being spawned, it is
 *		controlled by setup variables within the class.
 *
 ************************************************************************************************************/

// KMYNF: Change ALL inherited classes to use this instead of PreBeginPlay, since the owners should call Init() AND handle failure.
function eResult Init()
{
	return kSuccess;
}


/************************************************************************************************************
 *
 *	Refresh
 *		Call to reflect changes made back to a master server or ask for changes to be made from the master server.
 *
 *
 ************************************************************************************************************/

function eResult Refresh()
{
	return kSuccess;
}


/************************************************************************************************************
 *
 *	ReadyForTick
 *		Help regulate how often something is serviced within a Tick().
 *
 *
 ************************************************************************************************************/

function bool ReadyForTick( float DeltaTime, float DeltaRate )
{
	fAccumulatedTime += DeltaTime;

	if ( fAccumulatedTime > DeltaRate )
	{
		fAccumulatedTime = 0.0f;

		return true;
	}

	return false;
}


