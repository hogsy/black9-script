//=============================================================================
// CTFHUD.
//=============================================================================
class CTFHUD extends WarfareTeamHUD;

// Blue
#exec TEXTURE IMPORT NAME=I_Capt FILE=..\botpack\TEXTURES\HUD\I_Capt.PCX GROUP="Icons" MASKED=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=I_Down FILE=..\botpack\TEXTURES\HUD\I_Down.PCX GROUP="Icons" MASKED=1 MIPS=OFF
#exec TEXTURE IMPORT NAME=I_Home FILE=..\botpack\TEXTURES\HUD\I_Home.PCX GROUP="Icons" MASKED=1 MIPS=OFF

var CTFFlag MyFlag;

function Timer()
{
	Super.Timer();

	if ( (PlayerOwner == None) || (PawnOwner == None) )
		return;
	if ( ViewedInfo.HasFlag != None )
		PlayerOwner.ReceiveLocalizedMessage( class'CTFHUDMessage', 0 );
	if ( (MyFlag != None) && !MyFlag.bHome )
		PlayerOwner.ReceiveLocalizedMessage( class'CTFHUDMessage', 1 );
}

simulated function DrawHUD( canvas Canvas )
{
	local int X, Y;

	Super.DrawHUD( Canvas );		

	if ( (PlayerOwner == None) || (PawnOwner == None) || (PlayerOwner.GameReplicationInfo == None)
		|| (ViewedInfo == None)
		|| (bShowScores && (Canvas.ClipX < 640)) )
		return;

	Canvas.Style = Style;
	X = Canvas.ClipX - 70 * Scale;
	Y = Canvas.ClipY - 350 * Scale;
}

simulated function DrawTeam(Canvas Canvas, TeamInfo TI)
{
	local float XL, YL, X, Y, Scale;
// FIXME_MERGE	local CTFFlag Flag;

	if ( TI == None )
		return;

	if ( Canvas.ClipY < 300 )
	{
		Scale = 0.5;
		Canvas.Font = MyFont.GetMediumFont(Canvas.ClipX);
		Y = Canvas.ClipY - 88 - 37 * TI.TeamIndex;
	}
	else
	{
		Scale = 1.0;
		Canvas.Font = MyFont.GetHugeFont(Canvas.ClipX);
		Y = Canvas.ClipY - 175 - 75 * TI.TeamIndex;
	}
	Canvas.Style = Style;
	X = Canvas.ClipX - EdgeOffsetX - 32 * Scale;
	Canvas.DrawColor = TI.TeamColor;

/* FIXME_MERGE		
	Flag = CTFFlag(TI.Flag);
	if ( Flag != None )
	{
		Canvas.SetPos(X,Y);

		if (Flag.Team == PlayerOwner.PlayerReplicationInfo.Team)
			MyFlag = Flag;
		if ( Flag.bHome ) 
			Canvas.DrawIcon(texture'I_Home', Scale);
		else if ( Flag.bHeld )
			Canvas.DrawIcon(texture'I_Capt', Scale);
		else
			Canvas.DrawIcon(texture'I_Down', Scale);
	}
*/
	Canvas.StrLen(int(TI.Score), XL, YL);
	Canvas.SetPos(X - XL - 8 * Scale, Y - 4 * Scale );
	Canvas.DrawText(int(TI.Score), false);
}


simulated function DrawGameSynopsis(Canvas Canvas)
{
	local int i;

	for ( i=0 ;i<2; i++ )
		DrawTeam(Canvas, PlayerOwner.GameReplicationInfo.Teams[i]);
}




defaultproperties
{
	gamegoal="captures wins the match!"
}