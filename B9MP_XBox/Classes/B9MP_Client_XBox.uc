//=============================================================================
// B9MP_Client_XBox.
//=============================================================================
class B9MP_Client_XBox extends B9MP_Client
	native;


/************************************************************************************************************
 *
 *	Login
 *		
 *
 *
 ************************************************************************************************************/

function eResult Login()
{	
	if(fClientDescription == None)
	{
		return kFailure;
	}
	
	if( BeginLogin(fClientDescription.fInfo.fControllerIndex, fClientDescription.fInfo.fName) == 0 )
	{
		return kFailure;
	}

	Super.Login();

	fLoggingIn = true;

	return kSuccess;
}

/************************************************************************************************************
 *
 *	BeginLogin
 *		
 *
 *
 ************************************************************************************************************/
native(2422) final function int BeginLogin(int ControllerIndex, String Name);

/************************************************************************************************************
 *
 *	ContiueLogin
 *		
 *
 *
 ************************************************************************************************************/

native(2421) final function int ContinueLogin();



/************************************************************************************************************
 *
 *	Create
 *		Fill out fClientDescription, then call Create to create an account.
 *
 *
 ************************************************************************************************************/
native(2423) final function int CreateAccount();

function eResult Create()
{
	if(CreateAccount() == 0)
	{
		return kFailure;
	}
	
	return kSuccess;
}

/************************************************************************************************************
 *
 *	Delete
 *		Fill out fClientDescription, then call Delete to delete an account.
 *
 *
 ************************************************************************************************************/
native(2424) final function int DeleteAccount();

function eResult Delete()
{
	if(DeleteAccount() == 0)
	{
		return kFailure;
	}
	
	return kSuccess;
}


/************************************************************************************************************
 *
 *	Logout
 *		
 *
 *
 ************************************************************************************************************/

native(2420) final function int _Logout();

function eResult Logout()
{
	if( _Logout() == 0)
	{
		return kFailure;
	}
	
	fLoggedIn = false;
	
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
	// If already logged in, return
	if(	fLoggedIn == true)
	{
		Super.Tick(DeltaSeconds);
		return;
	}

	// If not logging in, return
	if(	fLoggingIn != true)
	{
		Super.Tick(DeltaSeconds);
		return;
	}

	switch(ContinueLogin())
	{
	case 0:
		break;
		
	case 1:
		fLoggingIn = false;
		fLoggedIn = true;
		break;
	
	default:
		fLoggingIn = false;
		fLoggedIn = false;
		fLoginResult = kFailure;
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
	return kSuccess;
}


