//=============================================================================
// B9MP_Invitation.
//=============================================================================
class B9MP_Invitation extends B9MP_OnlineCore
	native;


var B9MP_ClientDescription		fClientInfo;
var B9MP_ServerDescription		fServerInfo;


/************************************************************************************************************
 *
 *	PreBeginPlay
 *		
 *
 *
 ************************************************************************************************************/

event PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( fClientInfo == None )
	{
		fClientInfo = Spawn( class'B9MP_ClientDescription' );
	}

	if ( fServerInfo == None )
	{
		fServerInfo = Spawn( class'B9MP_ServerDescription' );
	}
}


/************************************************************************************************************
 *
 *	Destroyed
 *		
 *
 *
 ************************************************************************************************************/

event Destroyed()
{
	Super.Destroyed();
}


