//=============================================================================
// B9MP_ServerBrowser_XBox.
//=============================================================================
class B9MP_ServerBrowser_XBox extends B9MP_ServerBrowser
	native
	transient;

native(2410) final function string GetSessionName(int nSessionIndex);
native(2411) final function int GetSessionCount();
native(2412) final function int ContinueSearching();
native(2413) final function int BeginSearchingForHost();
native(2414) final function string GetSessionAddress(int nSessionIndex);
native(2415) final function string _PreJoinGame(string szAddress);

function eResult PreJoinGame(B9MP_ServerDescription ServerDescription)
{	
	ServerDescription.fInfo.fIPAddress = _PreJoinGame(ServerDescription.fInfo.fIPAddress);
	
	Log( "Address = " $ ServerDescription.fInfo.fIPAddress);
	  
	return Super.PreJoinGame(ServerDescription);
}

function BeginPlay()
{
	BeginSearchingForHost();
	fBrowsing = true;
}

function CopyServerDescriptions()
{
	local int nCount;
	local int i;
	//local B9MP_ServerDescription Desc;
	
	nCount = GetSessionCount();
	
	for( i = 0; i < nCount; i++ )
	{
		fServers.PushBack(Spawn( class 'B9MP_ServerDescription', None ));
		B9MP_ServerDescription(fServers.GetBottom().fObject).fInfo.fName = GetSessionName(i);
		B9MP_ServerDescription(fServers.GetBottom().fObject).fInfo.fIPAddress = GetSessionAddress(i);
		//Log( "Session[" $ i $ "]=" $ Desc.fInfo.fName );
	}	
}

function Tick(float DeltaSeconds)
{
	if(fBrowsing == false)
	{
		return;
	}
	
	switch(ContinueSearching())
	{
	case 2:
		fBrowsing = false;			// No longer searching
		fServersDirty = true;		// Search completed
		CopyServerDescriptions();
		break;
		
	case 1:
		break;						// Not done yet

	default:
		fBrowsing = false;			// No longer searching
		fServersDirty = false;		// Search completed
		fBrowseResult = kFailure;	// Error flag	
		break;
	}
			
	Super.Tick( DeltaSeconds );
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

	return Super.Refresh();
}




