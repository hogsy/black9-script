//=============================================================================
// B9MP_ServerDescription.
//
// Description:
//		Describes a single server.  Used to describe a running server and one in a listing.
//
// Usage:
//		It's just data.
//
//		Setup:
//
//		Required:
//
//		Methods:
//
//	Notes:
//
//
//=============================================================================
class B9MP_ServerDescription extends B9MP_OnlineCore
	native;


enum eServerStatusCode
{
	kSSNoStatusCode,		
	kSSPublishing,
	kSSPublished,
	kSSInvalidStatusCode3,		//Cannot be publishing in and published in at the same time
	kSSPublicationFailed
};



// MUST MATCH ABOVE!
struct ServerDescription
{
	// Settings
	var String			fName;
	var String			fIPAddress;
	var String			fMapName;
	var eGameType		fGameType;
	var bool			fVisible;											// Used by Filter(), menus would ignore this server
	var bool			fDedicated;
	var bool			fRanked;
	var bool			fPrivate;
	var bool			fLAN;

	// Status
	var int				fCurrentPlayers;
	var int				fMinPlayers;
	var int				fMaxPlayers;
	var int				fMinCharacterLevel;
	var int				fMaxCharacterLevel;
	var int				fPing;
	var int				fAveragePlayerSkill;
	var eSociety		fWinningTeam;
	var eSociety		fLosingTeam;
	var String			fPlayerSkillsEncoded;								// Format="<skill #>,<skill #>,<skill #>", example: "4,1,4,6,2"
};


var ServerDescription	fInfo;


event Destroyed()
{
	Super.Destroyed();
}


