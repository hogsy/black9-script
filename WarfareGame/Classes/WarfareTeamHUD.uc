//=============================================================================
// WarfareTeamHUD
//=============================================================================
class WarfareTeamHUD extends WarfareHUD;

#exec TEXTURE IMPORT NAME=Static1 FILE=..\botpack\TEXTURES\HUD\Static1.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=Static2 FILE=..\botpack\TEXTURES\HUD\Static2.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=Static3 FILE=..\botpack\TEXTURES\HUD\Static3.PCX GROUP="Icons" MIPS=OFF

var() name OrderNames[16];
var() int NumOrders;
var localized string StartUpTeamMessage, StartupTeamTrailer, CanChangeTeam;

function int DisplayStartUpMessage(Canvas C, int lines)
{
	local int Y;
	local float XL,YL;

	if ( StartupStage == 2 )
		return 0;
	Y = Super.DisplayStartUpMessage(C,1);

	if ( PlayerOwner.PlayerReplicationInfo.Team != None )
	{
		C.TextSize("TEST",XL,YL);
		C.SetPos(0.5*C.ClipX, Y+YL);
		C.DrawColor = PlayerOwner.PlayerReplicationInfo.Team.TeamColor;
		if ( StartupStage < 2 )
			DrawTextAt(C,StartupTeamMessage@PlayerOwner.PlayerReplicationInfo.Team.TeamName$StartupTeamTrailer@CanChangeTeam,Y,YL);
		else
			DrawTextAt(C,StartupTeamMessage@PlayerOwner.PlayerReplicationInfo.Team.TeamName$StartupTeamTrailer,Y,YL);
	}
	return Y;
}

simulated function DrawGameSynopsis(Canvas Canvas)
{
	local int i;

	for ( i=0 ;i<2; i++ )
		DrawTeam(Canvas, PlayerOwner.GameReplicationInfo.Teams[i]);
}

simulated function DrawTeam(Canvas Canvas, TeamInfo TI)
{
	local float XL, YL;

	if ( (TI != None) && (TI.Size > 0) )
	{
		Canvas.Font = MyFont.GetHugeFont( Canvas.ClipX );
		Canvas.DrawColor = TI.TeamColor;
		Canvas.SetPos(Canvas.ClipX - 32 * Scale, Canvas.ClipY - (256 + 64 * TI.TeamIndex) * Scale);
		Canvas.DrawTile(TI.TeamIcon, 256*Scale, 256*Scale,0,0,256,256);
		Canvas.StrLen(int(TI.Score), XL, YL);
		Canvas.SetPos(Canvas.ClipX - XL - 34 * Scale, Canvas.ClipY - (256 + 64 * TI.TeamIndex) * Scale + ((32 * Scale) - YL)/2 );
		Canvas.DrawText(int(TI.Score), false);
	}
}

simulated function SetIDColor( Canvas Canvas, int type )
{
	if ( type == 0 )
		Canvas.DrawColor = IdentifyTarget.Team.AltTeamColor * 0.333 * IdentifyFadeTime;
	else
		Canvas.DrawColor = IdentifyTarget.Team.TeamColor * 0.333 * IdentifyFadeTime;
}

// Pawns are only valid if on the same team

simulated function bool PawnIsValid(vector vecPawnView, vector X, pawn P)
{
	if ( (P.PlayerReplicationInfo == None) || ( P.PlayerReplicationInfo.Team != PlayerOwner.PlayerReplicationInfo.Team) )
		return false; 
		
	return true;
}

// Draw a bracket around a pawn 

simulated function DrawPawnInfo(Canvas canvas, float screenX, float screenY, pawn P)
{
	// draw range to target info
	local float xl,yl, perc;
	local PlayerReplicationInfo PRI;

	Canvas.Font = Canvas.SmallFont;

	PRI = P.PlayerReplicationInfo;
	Canvas.StrLen(PRI.PlayerName,xl,yl);
	
	ScreenY-= YL*3;
	
	Canvas.SetDrawColor(255,255,255);
	Canvas.SetPos(screenX - (xl/2),ScreenY);
	Canvas.DrawText(PRI.PlayerName, false);
	Canvas.Style = 1;

	ScreenY+= YL + 3;

	Perc = float(P.Health) / 100.0;
	if (Perc>1)
		Perc = 1;

	DrawPercBar(Canvas,25,ScreenX,ScreenY, Perc);
}

defaultproperties
{
	OrderNames[0]=Defend
	OrderNames[1]=Hold
	OrderNames[2]=attack
	OrderNames[3]=Follow
	OrderNames[4]=Freelance
	OrderNames[5]=point
	OrderNames[10]=attack
	OrderNames[11]=Freelance
	NumOrders=5
	StartUpTeamMessage="You are on"
	CanChangeTeam="(F4 changes)."
	StartupHeight=4
}