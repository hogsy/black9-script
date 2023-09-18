//=============================================================================
// B9MP_Server.
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
class B9MP_Server extends B9MP_Online
	native;


var bool						fPublished;
var bool						fPublishing;
var eResult						fPublicationResult;
var B9MP_ServerDescription		fServerDescription;


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

	if ( fServerDescription == None )
	{
		fServerDescription = Spawn( class'B9MP_ServerDescription' );

		// KMYNF: Why is this here?????
		if ( fServerDescription != None )
		{
			fServerDescription.fInfo.fName = Level.Game.GetBeaconText();
		}
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


/************************************************************************************************************
 *
 *	Publish
 *		Fill out fServerDescription, then call Publish() to beging announcing a server to the master lists.
 *
 *
 ************************************************************************************************************/

function eResult Publish()
{
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
	return kSuccess;
}


