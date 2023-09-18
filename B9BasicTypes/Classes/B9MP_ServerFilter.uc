//=============================================================================
// B9MP_ServerFilter.
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
class B9MP_ServerFilter extends B9MP_OnlineCore
	native;


var eGameType		fGameType;
var int				fMinPlayers;
var int				fMaxPlayers;
var int				fMinCharacterLevel;
var int				fMaxCharacterLevel;
var eSociety		fDesiredIlluminati;							// kSociety_Unknown == any will do
var bool			fOnlyGamesNeedingPlayers;
var bool			fOnlyDedicatedHosts;
var bool			fOnlyRankedGames;



