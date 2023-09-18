//=============================================================================
// B9MP_ClientDescription.
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
class B9MP_ClientDescription extends B9MP_OnlineCore
	native;


enum eClientStatusCode
{
	kCSNoStatusCode,
	kCSLoggingIn,
	kCSLoggedIn,
	kCSInvalidStatusCode3,		//Cannot be logging in and logged in at the same time
	kCSLoginFailed,
	kCSInvalidStatusCode5,
	kCSInvalidStatusCode6,
	kCSInvalidStatusCode7,
	kCSUseQuickMatch
};

enum eInviteStatus
{
	kInviteNone,				// No invitation status on this person
	kInvitePending,				// Waiting on a response to an invitation that the player sent
	kInviteAccepted,			// Accepted said invitation (now a buddy, since accepting a game invitation would put them in the game)
	kInviteDenied,				// Denied said invitation.
};

enum eAudioStatus
{
	kAudioNone,
};




// MUST MATCH ABOVE!
struct ClientDescription
{
	var String				fName;
	var String				fNickName;
	var String				fPassword;
	var String				fCurrentGame;
	var bool				fDirty;										// This item in the list has changed.  When the owner reads this, they should reset it to false.
	var bool				fBuddy;
	var bool				fVisibleOnline;
	var bool				fInGame;
	var bool				fAskingToBeBuddy;
	var bool				fInvitingToGame;
	var int					fControllerIndex;
	var int					fUniqueID;
	var eInviteStatus		fInviteStatus;
};


var ClientDescription		fInfo;


