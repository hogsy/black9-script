//=============================================================================
// B9MP_GameClient_XBox.
//=============================================================================
class B9MP_GameClient_XBox extends B9MP_GameClient
	native;


/************************************************************************************************************
 *
 *	JoinGame
 *
 ************************************************************************************************************/

function eResult JoinGame()
{	
	
	if( _JoinGame() <= 0)
	{
		return kFailure;
	}
	
	fJoining = true;

	return kSuccess;
}

/************************************************************************************************************
 *
 *	_JoinGame
 *		
 *
 *
 ************************************************************************************************************/
native(2446) final function int _JoinGame();

/************************************************************************************************************
 *
 *	ContinueJoinGame
 *		
 *
 *
 ************************************************************************************************************/

native(2447) final function int ContinueJoinGame();

/************************************************************************************************************
 *
 *	_ExitGame
 *		
 *
 *
 ************************************************************************************************************/

native(2448) final function int _ExitGame();

function eResult ExitGame()
{
	if( _ExitGame() == 0)
	{
		return kFailure;
	}
	
	fJoined = false;
	
	return kSuccess;
}

native(2449) final function int TickSession();

/************************************************************************************************************
 *
 *	Tick
 *		
 *
 *
 ************************************************************************************************************/
function Tick(float DeltaSeconds)
{
	// If already logged in, return
	if(	fJoined == true)
	{
		TickSession();
		Super.Tick(DeltaSeconds);
		return;
	}

	// If not logging in, return
	if(	fJoining == false)
	{
		Super.Tick(DeltaSeconds);
		return;
	}

	switch(ContinueJoinGame())
	{
	case 0:
		break;
		
	case 1:
		fJoining = false;
		fJoined = true;
		break;
	
	default:
		fJoining = false;
		fJoined = false;
		fJoinResult = kFailure;
	}
	
	Super.Tick(DeltaSeconds);
}

defaultproperties
{
	RemoteRole=0
}