//=============================================================================
// B9MP_Client_GameSpy.
//=============================================================================
class B9MP_Client_GameSpy extends B9MP_Client
	native
	config(GameSpy);




// Setup
var config float	fClientDeltaRate;		// Controls how often the client is updated, # of seconds before an update is needed (0.10 would then be 10 hz)

// Runtime
var String			fPlatform;


native(2500) static final function eResult InternalInit();
native(2501) static final function InternalQuit();
native(2502) static final function InternalTick();
native(2503) static final function eResult InternalRefresh();
native(2504) static final function eResult InternalLogin();
native(2505) static final function eResult InternalLogout();
native(2506) static final function eResult InternalCreate();
native(2507) static final function eResult InternalDelete();
native(2508) static final function int InternalGetBuddyCount();
native(2509) static final function InternalGetBuddy( int index, out B9MP_ClientDescription description);
native(2510) static final function InternalClearBuddyList();


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

	fPlatform = Platform();

	InternalInit();
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
	// Tick
	if ( ReadyForTick( DeltaTime, fClientDeltaRate ) )
	{
		InternalTick();
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
	if ( fLoggedIn )
	{
		InternalRefresh();
	}

	return Super.Refresh();
}


/************************************************************************************************************
 *
 *	Login
 *		
 *
 *
 ************************************************************************************************************/

function eResult Login()
{
	local eResult result;

	if ( fLoggedIn )
	{
		fErrorMessage = "You are already logged on.";
		return kFailure;
	}

	if ( fLoggingIn )
	{
		fErrorMessage = "Already attempting to log on.";
		return kFailure;
	}

	Super.Login();

	fErrorMessage = "";

	// KMY: Currently a BUG in unrealscript
//	return InternalLogin();

	result = InternalLogin();
	return result;
}


/************************************************************************************************************
 *
 *	Logout
 *		
 *
 *
 ************************************************************************************************************/

function eResult Logout()
{
	local eResult result;
	result = InternalLogout();
	return result;
}


/************************************************************************************************************
 *
 *	Create
 *		Fill out fClientDescription, then call Create to create an account.
 *
 *
 ************************************************************************************************************/

function eResult Create()
{
	local eResult result;
	result = InternalCreate();
	return result;
}


/************************************************************************************************************
 *
 *	Delete
 *		Fill out fClientDescription, then call Delete to delete that account.
 *
 *
 ************************************************************************************************************/

function eResult Delete()
{
	local eResult result;
	result = InternalDelete();
	return result;
}


/************************************************************************************************************
 *
 *	JoinedGame
 *		Call when player joins game
 *
 *
 ************************************************************************************************************/

function JoinedGame( B9MP_ServerDescription description )
{
	fClientDescription.fInfo.fInGame = true;
	fClientDescription.fInfo.fCurrentGame = description.fInfo.fIPAddress;
}


/************************************************************************************************************
 *
 *	LeftGame
 *		Call when player leaves a game
 *
 *
 ************************************************************************************************************/

function LeftGame()
{
	fClientDescription.fInfo.fInGame = false;
	fClientDescription.fInfo.fCurrentGame = "";
}


defaultproperties
{
	fClientDeltaRate=2
}