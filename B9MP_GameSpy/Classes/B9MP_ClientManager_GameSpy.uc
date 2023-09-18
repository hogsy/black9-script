//=============================================================================
// B9MP_ClientManager_GameSpy.
//=============================================================================
class B9MP_ClientManager_GameSpy extends B9MP_ClientManager
	native
	config(GameSpy);



// MUST MATCH ABOVE!
struct AccountDefinition
{
	var String		fName;
	var String		fNickName;
	var String		fPassword;
};


// Setup
var config AccountDefinition	fAccounts[ 4 ];
var config int					fAccountCount;
var config int					fMaxAccounts;

// Runtime
var int							fCurrentSelection;


//native(2530)
native(2530) static final function eResult InternalInit( String platform );


/************************************************************************************************************
 *
 *	PreBeginPlay
 *		
 *
 *
 ************************************************************************************************************/

event PreBeginPlay()
{
	local B9MP_ClientDescription Description;
	local int i;

	Super.PreBeginPlay();

	InternalInit( Platform() );

	for ( i = 0; i < fAccountCount; i++ )
	{
		Description = Spawn( class'B9MP_ClientDescription' );

		if ( Description != None )
		{
			Description.fInfo.fName	  = fAccounts[ i ].fName;
			Description.fInfo.fNickName = fAccounts[ i ].fNickName;
			Description.fInfo.fPassword = fAccounts[ i ].fPassword;

			fClients.PushBack( Description );
		}
	}
}


/************************************************************************************************************
 *
 *	AddClient
 *		
 *
 *
 ************************************************************************************************************/

function eResult AddClient( B9MP_ClientDescription Description )
{
	if ( fAccountCount >= fMaxAccounts )
	{
		log( self@ " No more room for account storage" );
		return kFailure;
	}

	// Store info in array for config
	fAccounts[ fAccountCount ].fName	 = Description.fInfo.fName;
	fAccounts[ fAccountCount ].fNickName = Description.fInfo.fNickName;
	fAccounts[ fAccountCount ].fPassword = Description.fInfo.fPassword;
	fAccountCount++;

	Save();

	// Add to fClients
	fClients.PushBack( Description );

	return kSuccess;
}


/************************************************************************************************************
 *
 *	DeleteClient
 *		
 *
 *
 ************************************************************************************************************/

function eResult DeleteClient( B9MP_ClientDescription Description )
{
	local LinkedListElement client;

	client = fClients.FindElement( Description );
	if ( client != None )
	{
		fClients.RemoveElement( client );
	}

	DeleteAccount( FindOffset( Description.fInfo.fName ) );

	return kSuccess;
}


/************************************************************************************************************
 *
 *	Save
 *		Cause config to save now.
 *
 *
 ************************************************************************************************************/

function Save()
{
	SaveConfig();
}


/************************************************************************************************************
 *
 *	FindOffset
 *		Given name, find offset in account list
 *
 *
 ************************************************************************************************************/

function int FindOffset( String name )
{
	local int i;

	for ( i = 0; i < fAccountCount; i++ )
	{
		if ( fAccounts[ i ].fName == name )
		{
			return i;
		}
	}

	return -1;
}


/************************************************************************************************************
 *
 *	DeleteAccount
 *		Remove the account information from the config file
 *
 *
 ************************************************************************************************************/

function DeleteAccount( int offset )
{
	local int i;

	if ( ( offset >= 0 ) && ( offset < fAccountCount ) )
	{
		for ( i = offset; i < fAccountCount; i++ )
		{
			fAccounts[ i ].fName	 = fAccounts[ i + 1 ].fName;
			fAccounts[ i ].fNickName = fAccounts[ i + 1 ].fNickName;
			fAccounts[ i ].fPassword = fAccounts[ i + 1 ].fPassword;
		}

		fAccountCount--;

		fAccounts[ fAccountCount ].fName	 = "";
		fAccounts[ fAccountCount ].fNickName = "";
		fAccounts[ fAccountCount ].fPassword = "";

		Save();
	}
	else
	{
		log( self@ " Asked to delete an account not in storage" );
	}
}


defaultproperties
{
	fMaxAccounts=4
}