//=============================================================================
// B9MP_GameClient.
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
class B9MP_GameClient extends B9MP_Online
	native;

var bool fJoining;
var bool fJoined;
var eResult fJoinResult;

/************************************************************************************************************
 *
 *	JoinGame
 *
 ************************************************************************************************************/

function eResult JoinGame()
{
	return kSuccess;
}


/************************************************************************************************************
 *
 *	ExitGame
 *
 *
 ************************************************************************************************************/

function eResult ExitGame()
{
	return kSuccess;
}

