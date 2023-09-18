//=============================================================================
// B9MP_ServerBrowser_GameSpy.
//=============================================================================
class B9MP_ServerBrowser_GameSpy extends B9MP_ServerBrowser
	native
	config(GameSpy);


// Setup
var config int		fStartPort;						// if fLAN, start of Port range to search for servers
var config int		fEndPort;						// if fLAN, end of Port range to search for servers
var config float	fServerBrowserDeltaRate;		// Controls how often the browser is updated, # of seconds before an update is needed (0.10 would then be 10 hz)


// Runtime
var bool			fFinished;
var bool			fErrorOccurred;
var bool			fProcessingRequest;
var String			fError;


native(2570) static final function eResult InternalInit( String platform );
native(2571) static final function InternalQuit();
native(2572) static final function InternalTick();
native(2573) static final function eResult InternalRefresh();
native(2574) static final function int InternalGetServerCount();
native(2575) static final function InternalGetServer( int index, out B9MP_ServerDescription description );


/************************************************************************************************************
 *
 *	PreBeginPlay
 *		
 *
 *
 ************************************************************************************************************/

event PreBeginPlay()
{
	fBrowseResult = kSuccess;
	InternalInit( Platform() );

	Super.PreBeginPlay();
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
	// Quit
	InternalQuit();

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
	local int numServers;
	local int i;
	local B9MP_ServerDescription description;

	// Tick
	if ( ReadyForTick( DeltaTime, fServerBrowserDeltaRate ) )
	{
		InternalTick();

		if ( fErrorOccurred )
		{
			fBrowseResult = kFailure;
			Log( "B9MP: Server browser error: " $ fError );
		}

		if ( fFinished && ( fBrowseResult == kSuccess ) )
		{
			fFinished = false;

			Log( "KMY: SB List has changed" );

			fServers.Clear();
			numServers = InternalGetServerCount();
			for ( i = 0; i < numServers; i++ )
			{
				description = Spawn( class 'B9MP_ServerDescription' );

				if ( description != None )
				{
					InternalGetServer( i, description );

					Log( "KMY: Got server # " $ i $ "(" $ description.fInfo.fName $ ")" );

					if ( description.fInfo.fName != "HOST" )
					{
						fServers.PushFront( description );
					}
				}

				description = None;
			}

			Filter();
			Sort();

			fServersDirty = true;
			fBrowsing = false;
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
	fServersDirty = false;
	fBrowsing = true;
	fBrowseResult = kSuccess;
	InternalRefresh();
	if ( fErrorOccurred )
	{
		Log( "B9MP: Error getting server list: " $ fError );
		fBrowseResult = kFailure;
		return kFailure;
	}

	return Super.Refresh();
}



defaultproperties
{
	fStartPort=7770
	fEndPort=7772
	fServerBrowserDeltaRate=0.1
}