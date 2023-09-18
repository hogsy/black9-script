//=============================================================================
// B9MP_Server_GameSpy.
//=============================================================================
class B9MP_Server_GameSpy extends B9MP_Server
	native
	config(GameSpy);


// Setup
var config float	fServerDeltaRate;		// How often (1/Hz) the server must be serviced

// Runtime
var bool			fPublished;


native(2550) static final function eResult InternalPublish( String platform );
native(2551) static final function InternalUnPublish();
native(2552) static final function InternalTick();
native(2553) static final function eResult InternalRefresh();


/************************************************************************************************************
 *
 *	PreBeginPlay
 *		
 *
 *
 ************************************************************************************************************/

event PreBeginPlay()
{
	Super.PreBeginPlay();

	fPublished = false;
}


/************************************************************************************************************
 *
 *	Destroyed
 *		
 *
 *
 ************************************************************************************************************/

event Destroyed()
{
	Log( "KMY: Server Destroyed" );

	// Quit
	if ( fPublished )
	{
		InternalUnPublish();
	}

	super.Destroyed();
}


/************************************************************************************************************
 *
 *	Tick
 *		
 *
 *
 ************************************************************************************************************/

event Tick( float DeltaTime )
{
	if ( ReadyForTick( DeltaTime, fServerDeltaRate ) )
	{
		if ( fPublished )
		{
			InternalTick();
		}
	}

	super.Tick( DeltaTime );
}


/************************************************************************************************************
 *
 *	Refresh
 *		
 *
 *
 ************************************************************************************************************/

function eResult Refresh()
{
	// Fill/Update as necessary
	if ( fPublished )
	{
		InternalRefresh();
	}

	return Super.Refresh();
}


/************************************************************************************************************
 *
 *	Publish
 *		
 *
 *
 ************************************************************************************************************/

function eResult Publish()
{
	local eResult result;

	Log( "KMY: Publishing server " $ fServerDescription.fInfo.fName $ " on " $ Platform() $ " Address: " $ fServerDescription.fInfo.fIPAddress );

	result = InternalPublish( Platform() );

	if ( result == kSuccess )
	{
		fPublished = true;
	}

	return result;
}


/************************************************************************************************************
 *
 *	UnPublish
 *		Will cause the server to no longer be listed in the master lists.
 *		closingServer:		Host is quitting or leaving HQ.  Otherwise it's travelling to another map.  This
 *							is needed for XBox, which must keep the connection live.
 *
 ************************************************************************************************************/

function eResult UnPublish( bool closingServer )
{
	Log( "KMY: UnPublishing server " $ fServerDescription.fInfo.fName $ " on " $ Platform() $ " Address: " $ fServerDescription.fInfo.fIPAddress );

	fPublished = false;
	InternalUnPublish();

	return kSuccess;
}


defaultproperties
{
	fServerDeltaRate=0.1
}