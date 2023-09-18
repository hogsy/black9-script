//=============================================================================
// B9MP_ClientBrowser_XBox.
//=============================================================================
class B9MP_ClientBrowser_XBox extends B9MP_ClientBrowser
	native;

var bool					fEnumerationCompleted;
var bool					fEnumerating;
var eResult					fEnumerationResult;
var int						fUserIndex;

native(2450) final function eResult _BeginEnumeration();
native(2451) final function int ContinueEnumeration();
native(2452) final function int GetFriendCount();
native(2453) final function string GetFriendName(int nIndex);
native(2454) final function int NewInvitationsAvailable();
native(2455) final function int NewFriendsRequestsAvailable();
native(2456) final function int GetResponsesToInvitations();

function eResult BeginEnumeration()
{
	if(_BeginEnumeration() == kFailure)
	{
		return kFailure;
	}

	fEnumerating = true;

	return kSuccess;
}

event Tick(float DeltaSeconds)
{
	if(NewInvitationsAvailable() != 0)
	{
		// Do something -- use fClientsDirty for now
		fClientsDirty = true;
	}

	if(NewFriendsRequestsAvailable() != 0)
	{
		// Do something -- use fClientsDirty for now
		fClientsDirty = true;
	}

	if(fEnumerating == false)
	{
		return;
	}

	switch(ContinueEnumeration())
	{
	case 2:
		fEnumerating = false;				// No longer enumerating
		fEnumerationCompleted = true;		// Enum completed
		CopyClientDescriptions();
		break;
		
	case 1:
		break;						// Not done yet

	default:
		fEnumerating = false;				// No longer enumerating
		fEnumerationCompleted = false;		// Enum completed
		fEnumerationResult = kFailure;		// Error flag	
		break;
	}
			
	Super.Tick( DeltaSeconds );
}

function CopyClientDescriptions()
{
	local int nCount;
	local int i;
	local B9MP_ClientDescription Desc;
	
	nCount = GetFriendCount();
	
	for( i = 0; i < nCount; i++ )
	{
		Desc = Spawn(class'B9MP_ClientDescription');
		Desc.fInfo.fName = GetFriendName(i);
		Log( "Friend[" $ i $ "]=" $ Desc.fInfo.fName );
		fClients.PushBack(Desc);	
	}	
}

