//=============================================================================
// B9MP_Server_XBox.
//=============================================================================
class B9MP_Server_XBox extends B9MP_Server
	native;

native(2404) final function int BeginBroadcasting(string GameName);
native(2403) final function int ContinueBroadcasting();
native(2402) final function int StopBroadcasting();
native(2401) final function int UpdatePlayerCount(int nCount);

function eResult Publish()
{	
	if(fServerDescription == None)
	{
		return kFailure;
	}
	
	if( BeginBroadcasting(fServerDescription.fInfo.fName) == 0)
	{
		return kFailure;
	}
	
	fPublishing = True;
	
	return kSuccess;
}

/************************************************************************************************************
 *
 *	UnPublish
 *		Will cause the server to no longer be listed in the master lists.
 *		closingServer:		Host is quitting or leaving HQ.  Otherwise it's travelling to another map.  This
 *							is needed for XBox, which must keep the connection live.
 *
 ************************************************************************************************************/

function eResult UnPublish( bool closingServer )
{
	StopBroadcasting();	
	
	fPublished = False;
	
	return kSuccess;
}

/************************************************************************************************************
 *
 *	Tick
 *		
 *
 *
 ************************************************************************************************************/
function Tick(float DeltaSeconds)
{
	// If published, call continue broadcasting and return
	if(	fPublished == True )
	{
		ContinueBroadcasting();
		Super.Tick(DeltaSeconds);
		return;
	}

	// If not publishing, return
	if(	fPublishing == False)
	{
		Super.Tick(DeltaSeconds);
		return;
	}

	switch(ContinueBroadcasting())
	{
	case 0:
		break;
		
	case 1:
		fPublishing = False;
		fPublished = True;
		break;
	
	default:
		fPublishing = False;
		fPublicationResult = kFailure;
	}
	
	Super.Tick(DeltaSeconds);
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
	// UNDONE: UpdatePlayerCount will be replaced with
	// a function that updates everything in fServerDescription.
	// Native code already has access to it
	UpdatePlayerCount(fServerDescription.fInfo.fCurrentPlayers);
	return kSuccess;
}


defaultproperties
{
	bAlwaysTick=true
}