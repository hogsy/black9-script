//=============================================================================
// B9MP_ClientBrowser.
//
// Description:
//		Used to browe the list of buddies or friends.
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
class B9MP_ClientBrowser extends B9MP_Online
	native;


// Setup
var B9MP_Client				fClientOwner;					// Current client that is doing the browsing (REQUIRED)

// Runtime
var bool					fErrorOccurred;
var String					fErrorMessage;
var bool					fClientsDirty;					// if true, fClients has been changed (result of a Refresh() for example).  Set to false when the contents have been read.
var LinkedList				fClients;


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

	if ( fClients == None )
	{
		fClients = (new(None) class'LinkedList')._LinkedList();
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
 *	FindFriend
 *		Given a unique name (for GameSpy the email address of the account) will search GameSpy and if found,
 *		the friend will be added to the list of friends (but you still have to invite them to be a buddy).
 *
 *		Note:
 *			On the XBox, this action is taken with the XBoxLive! Controller, not the game.  So this function
 *			should only be available under GameSpy (PC and PS/2).
 *
 ************************************************************************************************************/

function eResult FindFriend( String name )
{
	return kSuccess;
}


/************************************************************************************************************
 *
 *	InviteToBeBuddy
 *		Will send an invitation for this person to be a "buddy".  Caller must set fAskingToBeBuddy and change
 *		fInviteStatus to kInvitePending before calling this method.
 *
 ************************************************************************************************************/

function eResult InviteToBeBuddy( B9MP_ClientDescription clientDesc )
{
	return kSuccess;
}


/************************************************************************************************************
 *
 *	InviteToGame
 *		Will send an invitation to this person to join the current game.  Caller must set fInvitingToGame and
 *		this only works on "buddies" (fBuddy must be true);
 *
 ************************************************************************************************************/

function eResult InviteToGame( B9MP_ClientDescription clientDesc )
{
	return kSuccess;
}


/************************************************************************************************************
 *
 *	AnswerBuddyInvitation
 *		Respond to query to be added as a buddy to someone's buddy list.  Does not automatically make them a
 *		buddy.
 *
 ************************************************************************************************************/

function eResult AnswerBuddyInvitation( B9MP_ClientDescription clientDesc, bool accept )
{
	return kSuccess;
}


/************************************************************************************************************
 *
 *	RemoveBuddy
 *		Removes buddy from list (and makes them not your buddy any more).
 *
 ************************************************************************************************************/

function eResult RemoveBuddy( B9MP_ClientDescription clientDesc )
{
	return kSuccess;
}


