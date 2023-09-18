//=============================================================================
// B9MP_ClientBrowser_GameSpy.
//=============================================================================
class B9MP_ClientBrowser_GameSpy extends B9MP_ClientBrowser
	native
	config(GameSpy);




// Setup
var config float	fClientBrowserDeltaRate;		// Controls how often the browser is updated, # of seconds before an update is needed (0.10 would then be 10 hz)

// Runtime
var int				fProductID;


native(2520) static final function eResult InternalInit( String platform );
native(2521) static final function InternalQuit();
native(2522) static final function InternalTick();
native(2523) static final function eResult InternalRefresh();
native(2524) static final function eResult InternalFindFriend( String name );
native(2525) static final function eResult InternalInviteToBeBuddy( B9MP_ClientDescription clientDesc );
native(2526) static final function eResult InternalInviteToGame( B9MP_ClientDescription clientDesc );
native(2527) static final function eResult InternalAnswerBuddyInvitation( B9MP_ClientDescription clientDesc, bool accept );
native(2528) static final function eResult InternalRemoveBuddy( B9MP_ClientDescription clientDesc );


/************************************************************************************************************
 *
 *	PreBeginPlay
 *		
 *
 *
 ************************************************************************************************************/

event PreBeginPlay()
{
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
	local B9MP_ClientDescription description;
	local int buddiesReceived;
	local int i;

	fClientOwner.Tick( DeltaTime );

	if ( ReadyForTick( DeltaTime, fClientBrowserDeltaRate ) )
	{
		InternalTick();

		buddiesReceived = B9MP_Client_GameSpy( fClientOwner ).InternalGetBuddyCount();

		// Process what came in
		if ( buddiesReceived > 0 )
		{
			for ( i = 0; i < buddiesReceived; i++ )
			{
				description = Spawn( class 'B9MP_ClientDescription' );

				if ( description != None )
				{
					B9MP_Client_GameSpy( fClientOwner ).InternalGetBuddy( i, description );

					Log( "KMY: Got buddy # " $ i $ "(" $ description.fInfo.fName $ ")" );

					fClients.PushFront( description );
				}

				description = None;
			}

			B9MP_Client_GameSpy( fClientOwner ).InternalClearBuddyList();

			fClientsDirty = true;
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
	InternalRefresh();

	return Super.Refresh();
}


/************************************************************************************************************
 *
 *	FindFriend
 *		
 *
 *
 ************************************************************************************************************/

function eResult FindFriend( String name )
{
	local eResult result;
	result = InternalFindFriend( name );
	return result;
}


/************************************************************************************************************
 *
 *	InviteToBeBuddy
 *		
 *
 *
 ************************************************************************************************************/

function eResult InviteToBeBuddy( B9MP_ClientDescription clientDesc )
{
	local eResult result;

	if ( ! clientDesc.fInfo.fBuddy )
	{
		fErrorOccurred = true;
		fErrorMessage = "Cannot invite someone to a game unless they are a buddy";
		return kFailure;
	}

	result = InternalInviteToBeBuddy( clientDesc );
	return result;
}


/************************************************************************************************************
 *
 *	InviteToGame
 *		
 *
 *
 ************************************************************************************************************/

function eResult InviteToGame( B9MP_ClientDescription clientDesc )
{
	local eResult result;
	result = InternalInviteToGame( clientDesc );
	return result;
}


/************************************************************************************************************
 *
 *	AnswerBuddyInvitation
 *		
 *
 *
 ************************************************************************************************************/

function eResult AnswerBuddyInvitation( B9MP_ClientDescription clientDesc, bool accept )
{
	local eResult result;
	result = InternalAnswerBuddyInvitation( clientDesc, accept );
	return result;
}


/************************************************************************************************************
 *
 *	RemoveBuddy
 *		
 *
 *
 ************************************************************************************************************/

function eResult RemoveBuddy( B9MP_ClientDescription clientDesc )
{
	local LinkedListElement buddy;
	local eResult result;

	buddy = fClients.FindElement( clientDesc );
	if ( buddy != None )
	{
		fClients.RemoveElement( buddy );
		fClientsDirty = true;
	}

	result = InternalRemoveBuddy( clientDesc );
	return result;
}


defaultproperties
{
	fClientBrowserDeltaRate=0.1
}