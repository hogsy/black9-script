//=============================================================================
// B9MP_Client.
//
// Description:
//		
//
// Usage:
//		
//
//		Setup:
//		
//
//		Required:
//			Must call Tick() within the owning class's Tick()
//
//		Methods:
//		eResult Refresh()
//			Call this to 
//
//	Notes:
//		
//
//=============================================================================
class B9MP_Client extends B9MP_Online
	native;


// Setup
var B9MP_ClientDescription		fClientDescription;

// Runtime
var bool						fLoggedIn;
var bool						fLoggingIn;
var bool						fUseQuickMatch;
var eResult						fLoginResult;
var bool						fErrorOccurred;
var String						fErrorMessage;
var int							fClientHandle;
var bool						fGameInvitationReceived;
var bool						fBuddyInvitationReceieved;


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

	if ( fClientDescription == None )
	{
		fClientDescription = Spawn( class'B9MP_ClientDescription' );
	}
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
	Super.Destroyed();
}


/************************************************************************************************************
 *
 *	Login
 *		Fill out fClientDescription, then call Login to process signing on to the service and announcing the
 *		clients presence.
 *
 ************************************************************************************************************/

function eResult Login()
{
	local Controller C;

	// Set the actual player's name
	for ( C = Level.ControllerList; C != None; C = C.NextController )
		if ( C.IsA( 'PlayerController' ) && (Viewport( PlayerController( C ).Player ) != None ) )
		{
			PlayerController( C ).PlayerReplicationInfo.SetPlayerName( fClientDescription.fInfo.fName );
			break;
		}

	return kSuccess;
}


/************************************************************************************************************
 *
 *	Logout
 *		Signs the client out of the online service.
 *
 *
 ************************************************************************************************************/

function eResult Logout()
{
	return kSuccess;
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
	return kSuccess;
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
	return kSuccess;
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
}


