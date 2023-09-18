class B9_MPHQ_ReadyDetector extends actor
	placeable;
var (ReadyDetector) float fDetectionRadius;
// Set this Actors event to the B9_MPHQ_GameStarter's Tag (normally B9_MPHQ_GameStarter)
function PostBeginPlay()
{
	SetTimer( 1, true );

}

function Timer()
{
	local int BodyCount;
	local int TeamCount;
	local B9_PlayerPawn targetPawn;
	local B9_MultiPlayerHQGameInfo HQ;
	if( Role == ROLE_Authority )
	{

		if( B9_TeamGame(Level.Game).Teams[0] == None )
		{
			Log("This Actor only works for Team Games");
			return;
		}
		ForEach VisibleCollidingActors( class'B9_PlayerPawn',targetPawn, fDetectionRadius )
		{
			BodyCount++;
		}
		TeamCount = B9_TeamGame(Level.Game).Teams[0].Size + B9_TeamGame(Level.Game).Teams[1].Size;
		HQ = B9_MultiPlayerHQGameInfo( Level.Game );
		if( BodyCount == TeamCount && HQ != None && HQ.fCountDownTimer > 5)
		{
			// Speed it on its way
			HQ.fCountDownTimer = 5;
		}
	}
}

defaultproperties
{
	fDetectionRadius=300
	bHidden=true
}