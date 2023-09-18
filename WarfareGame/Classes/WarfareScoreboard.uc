class WarfareScoreboard extends ScoreBoard;

const MAXPLAYERS=32;
var() localized string      RankText;
var() localized string      PlayerText;
var() localized string      PointsText;
var() localized string      TimeText;
var() localized string      PingText;
var() localized string		DeathsText;
var() localized string		AdminText;
var() localized string		NetText;
var() localized string      FooterText;
var localized string MatchIDText;
var localized string		OutText;
var localized string ReadyText,NotReadyText;
var localized string		SkillLevel[8];  // all accesses are clamped (0,7)
var localized string YouveLostTheMatch,YouveWonTheMatch;
var PlayerReplicationInfo PRIArray[MAXPLAYERS];

// gamestats
var() localized String		MaxLives, FragLimit, FPH, GameType,MapName, Restart, Continue, Ended, TimeLimit, Spacer;

var() Material BoxMaterial;

simulated function UpdatePrecacheMaterials()
{
    UpdatePrecacheFonts();
}

function UpdatePrecacheFonts();
	
function DrawTitle(Canvas Canvas, float HeaderOffsetY, float PlayerAreaY)
{
	local string titlestring,scoreinfostring;
	local float TitleXL,ScoreInfoXL,YL;

	if ( Canvas.ClipX < 512 )
		return;	
	if ( Level.NetMode == NM_Standalone )
		titlestring = SkillLevel[Clamp(Level.Game.GameDifficulty,0,7)];

	titlestring = titlestring@GRI.GameName$MapName$Level.Title;
	Canvas.StrLen(TitleString,TitleXL,YL);

	if ( GRI.MaxLives != 0 )
		ScoreInfoString = MaxLives@GRI.MaxLives;
	else if ( GRI.GoalScore != 0 )
		ScoreInfoString = FragLimit@GRI.GoalScore;
	if ( GRI.TimeLimit != 0 )
		ScoreInfoString = ScoreInfoString@spacer@TimeLimit$FormatTime(GRI.RemainingTime);
	else
		ScoreInfoString = ScoreInfoString@spacer@FooterText@FormatTime(GRI.ElapsedTime);

	Canvas.DrawColor = class'Canvas'.static.MakeColor(255,255,0);
	if ( UnrealPlayer(Owner).bDisplayLoser )
		ScoreInfoString = YouveLostTheMatch;
	else if ( UnrealPlayer(Owner).bDisplayWinner )
		ScoreInfoString = YouveWonTheMatch;
	else if ( PlayerController(Owner).IsDead() )
	{
		if ( Canvas.ClipY - HeaderOffsetY - PlayerAreaY >= 2.5 * YL )
		{
			Canvas.StrLen(Restart,ScoreInfoXL,YL);
			Canvas.SetPos(0.5*(Canvas.ClipX-ScoreInfoXL), Canvas.ClipY - 2.5 * YL);
			Canvas.DrawText(Restart,true);
		}		
		else
			ScoreInfoString = Restart;
	}
	Canvas.StrLen(ScoreInfoString,ScoreInfoXL,YL);
	
	Canvas.SetPos(0.5*(Canvas.ClipX-TitleXL), 0.5*YL);
	Canvas.DrawText(TitleString,true);
	Canvas.SetPos(0.5*(Canvas.ClipX-ScoreInfoXL), Canvas.ClipY - 1.5 * YL);
	Canvas.DrawText(ScoreInfoString,true);
}

simulated event UpdateScoreBoard(Canvas Canvas)
{
	local PlayerReplicationInfo PRI, OwnerPRI;
	local int i, FontReduction, OwnerPos, NetXPos, PlayerCount,HeaderOffsetY,HeadFoot, MessageFoot, PlayerBoxSizeY, BoxSpaceY, NameXPos, BoxTextOffsetY, OwnerOffset, ScoreXPos, DeathsXPos, BoxXPos, TitleYPos, BoxWidth;
	local float XL,YL, MaxScaling;
	local float deathsXL, scoreXL, netXL;
	local string playername[MAXPLAYERS];
	local color WhiteColor;
	
	OwnerPRI = PlayerController(Owner).PlayerReplicationInfo;
    for (i=0; i<GRI.PRIArray.Length; i++)
	{
		PRI = GRI.PRIArray[i];
		if ( !PRI.bIsSpectator || PRI.bWaitingPlayer )
		{
			if ( PRI == OwnerPRI )
				OwnerOffset = i;
			PlayerCount++;
		}
	}
	PlayerCount = Min(PlayerCount,MAXPLAYERS);
	
	// Select best font size and box size to fit as many players as possible on screen
	Canvas.Font = HUDClass.static.GetMediumFontFor(Canvas);
	Canvas.StrLen("Test", XL, YL);
	BoxSpaceY = 0.25 * YL;
	PlayerBoxSizeY = 1.5 * YL;
	HeadFoot = 5*YL;
	MessageFoot = 1.5 * HeadFoot;
	if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
	{
		BoxSpaceY = 0.125 * YL;
		PlayerBoxSizeY = 1.25 * YL;
		if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
		{
			if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
				PlayerBoxSizeY = 1.125 * YL;
			if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
			{
				FontReduction++;
				Canvas.Font = GetSmallerFontFor(Canvas,FontReduction); 
				Canvas.StrLen("Test", XL, YL);
				BoxSpaceY = 0.125 * YL;
				PlayerBoxSizeY = 1.125 * YL;
				HeadFoot = 5*YL;
				if ( PlayerCount > (Canvas.ClipY - HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
				{
					FontReduction++;
					Canvas.Font = GetSmallerFontFor(Canvas,FontReduction); 
					Canvas.StrLen("Test", XL, YL);
					BoxSpaceY = 0.125 * YL;
					PlayerBoxSizeY = 1.125 * YL;
					HeadFoot = 5*YL;
					if ( (Canvas.ClipY >= 768) && (PlayerCount > (Canvas.ClipY - HeadFoot)/(PlayerBoxSizeY + BoxSpaceY)) )
					{
						FontReduction++;
						Canvas.Font = GetSmallerFontFor(Canvas,FontReduction); 
						Canvas.StrLen("Test", XL, YL);
						BoxSpaceY = 0.125 * YL;
						PlayerBoxSizeY = 1.125 * YL;
						HeadFoot = 5*YL;
					}
				}
			}	
		}	
	}	
	if ( Canvas.ClipX < 512 )
		PlayerCount = Min(PlayerCount, 1+(Canvas.ClipY - HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) );
	else
		PlayerCount = Min(PlayerCount, (Canvas.ClipY - HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) );
	if ( OwnerOffset >= PlayerCount )
		PlayerCount -= 1;

	if ( FontReduction > 2 )
		MaxScaling = 3;	
	else
		MaxScaling = 2.125;
	PlayerBoxSizeY = FClamp((1+(Canvas.ClipY - 0.67 * MessageFoot))/PlayerCount - BoxSpaceY, PlayerBoxSizeY, MaxScaling * YL);
		
	bDisplayMessages = (PlayerCount <= (Canvas.ClipY - MessageFoot)/(PlayerBoxSizeY + BoxSpaceY));
	HeaderOffsetY = 3 * YL;
	BoxWidth = 0.9375 * Canvas.ClipX;
	BoxXPos = 0.5 * (Canvas.ClipX - BoxWidth);
	BoxWidth = Canvas.ClipX - 2*BoxXPos;
	NameXPos = BoxXPos + 0.0625 * BoxWidth;
	ScoreXPos = BoxXPos + 0.5 * BoxWidth;
	DeathsXPos = BoxXPos + 0.6875 * BoxWidth;
	NetXPos = BoxXPos + 0.8125 * BoxWidth;
		
	// draw background boxes
	Canvas.Style = ERenderStyle.STY_Alpha;
	WhiteColor = class'Canvas'.Static.MakeColor(255,255,255);
	Canvas.DrawColor = WhiteColor * 0.5;
	for ( i=0; i<PlayerCount; i++ )
	{
		Canvas.SetPos(BoxXPos, HeaderOffsetY + (PlayerBoxSizeY + BoxSpaceY)*i);
		Canvas.DrawTileStretched( BoxMaterial, BoxWidth, PlayerBoxSizeY);
	}
	Canvas.Style = ERenderStyle.STY_Translucent;

	// draw title
	Canvas.Style = ERenderStyle.STY_Normal;
	DrawTitle(Canvas,HeaderOffsetY,(PlayerCount+1)*(PlayerBoxSizeY + BoxSpaceY));

	// Draw headers
	TitleYPos = HeaderOffsetY - 1.25*YL;
	Canvas.StrLen(PointsText, ScoreXL, YL);
	Canvas.StrLen(DeathsText, DeathsXL, YL);
	
	Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(NameXPos, TitleYPos);
	Canvas.DrawText(PlayerText,true);
	Canvas.SetPos(ScoreXPos - 0.5*ScoreXL, TitleYPos);
	Canvas.DrawText(PointsText,true);
	Canvas.SetPos(DeathsXPos - 0.5*DeathsXL, TitleYPos);
	Canvas.DrawText(DeathsText,true);
		
	// draw player names
	for ( i=0; i<PlayerCount; i++ )
	{
		playername[i] = GRI.PRIArray[i].PlayerName;
		Canvas.StrLen(playername[i], XL, YL);
		if ( XL > 0.9 * (ScoreXPos - NameXPos) )
			playername[i] = left(playername[i], 0.9 * (ScoreXPos-NameXPos)/XL * len(PlayerName[i]));
	}
	if ( OwnerOffset >= PlayerCount )
	{
		playername[OwnerOffset] = GRI.PRIArray[OwnerOffset].PlayerName;
		Canvas.StrLen(playername[OwnerOffset], XL, YL);
		if ( XL > 0.9 * (ScoreXPos - NameXPos) )
			playername[OwnerOffset] = left(playername[OwnerOffset], 0.9 * (ScoreXPos-NameXPos)/XL * len(PlayerName[OwnerOffset]));
	}	
			
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(0.5 * Canvas.ClipX, HeaderOffsetY + 4);
	BoxTextOffsetY = HeaderOffsetY + 0.5 * (PlayerBoxSizeY - YL);

	Canvas.DrawColor = WhiteColor;
	for ( i=0; i<PlayerCount; i++ )
		if ( i != OwnerOffset )
		{
			Canvas.SetPos(NameXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
			Canvas.DrawText(playername[i],true);
		}

	// draw scores
	Canvas.DrawColor = WhiteColor;
	for ( i=0; i<PlayerCount; i++ )
		if ( i != OwnerOffset )
		{
			Canvas.SetPos(ScoreXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
			if ( GRI.PRIArray[i].bOutOfLives )
				Canvas.DrawText(OutText,true);
			else
				Canvas.DrawText(int(GRI.PRIArray[i].Score),true);
		}
	
	// draw deaths
	Canvas.DrawColor = WhiteColor;
	for ( i=0; i<PlayerCount; i++ )
		if ( i != OwnerOffset )
		{
			Canvas.SetPos(DeathsXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
			Canvas.DrawText(int(GRI.PRIArray[i].Deaths),true);
		}
		
	// draw owner line
	if ( OwnerOffset >= PlayerCount )
	{
		OwnerPos = (PlayerBoxSizeY + BoxSpaceY)*PlayerCount + BoxTextOffsetY;
		// draw extra box	
		Canvas.Style = ERenderStyle.STY_Alpha;
		Canvas.DrawColor = class'Canvas'.static.MakeColor(0,255,255) * 0.5;
		Canvas.SetPos(BoxXPos, HeaderOffsetY + (PlayerBoxSizeY + BoxSpaceY)*PlayerCount);
		Canvas.DrawTileStretched( BoxMaterial, BoxWidth, PlayerBoxSizeY);
		Canvas.Style = ERenderStyle.STY_Normal;
	}
	else
		OwnerPos = (PlayerBoxSizeY + BoxSpaceY)*OwnerOffset + BoxTextOffsetY;
		
	Canvas.DrawColor = class'Canvas'.static.MakeColor(255,255,0);
	Canvas.SetPos(NameXPos, OwnerPos);
	Canvas.DrawText(playername[OwnerOffset],true);
	Canvas.SetPos(ScoreXPos, OwnerPos);
	if ( GRI.PRIArray[OwnerOffset].bOutOfLives )
		Canvas.DrawText(OutText,true);
	else
		Canvas.DrawText(int(GRI.PRIArray[OwnerOffset].Score),true);
	Canvas.SetPos(DeathsXPos, OwnerPos);
	Canvas.DrawText(int(GRI.PRIArray[OwnerOffset].Deaths),true);
		
	if ( Level.NetMode == NM_Standalone )
		return;

	Canvas.StrLen(NetText, NetXL, YL);
	Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(NetXPos + 0.5*NetXL, TitleYPos);
	Canvas.DrawText(NetText,true);

	for ( i=0; i<GRI.PRIArray.Length; i++ )
		PRIArray[i] = GRI.PRIArray[i];
	DrawNetInfo(Canvas,FontReduction,HeaderOffsetY,PlayerBoxSizeY,BoxSpaceY,BoxTextOffsetY,OwnerOffset,PlayerCount,NetXPos);
	DrawMatchID(Canvas,FontReduction);
}

function DrawMatchID(Canvas Canvas,int FontReduction)
{
	local float XL,YL;
	
	if ( GRI.MatchID != 0 )
	{
		Canvas.Font = GetSmallFontFor(1.5*Canvas.ClipX, FontReduction+1);
		Canvas.StrLen(MatchIDText@GRI.MatchID, XL, YL);
		Canvas.SetPos(Canvas.ClipX - XL - 4, 4);
		Canvas.DrawText(MatchIDText@GRI.MatchID,true);
	}		
}

function DrawNetInfo(Canvas Canvas,int FontReduction,int HeaderOffsetY,int PlayerBoxSizeY,int BoxSpaceY,int BoxTextOffsetY,int OwnerOffset,int PlayerCount, int NetXPos)
{
	local float XL,YL;
	local int i;
	local bool bHaveHalfFont;

	// draw admins
	if ( GRI.bMatchHasBegun )
	{
		Canvas.DrawColor = class'Canvas'.static.MakeColor(255,0,0);
		for ( i=0; i<PlayerCount; i++ )
			if ( PRIArray[i].bAdmin )
				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
					Canvas.DrawText(AdminText,true);
				}
		if ( (OwnerOffset >= PlayerCount) && PRIArray[OwnerOffset].bAdmin )
		{	
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*PlayerCount + BoxTextOffsetY);
			Canvas.DrawText(AdminText,true);
		}
	}
		
	Canvas.DrawColor = class'Canvas'.static.MakeColor(0,255,255);
	Canvas.Font = GetSmallFontFor(1.5*Canvas.ClipX, FontReduction);
	Canvas.StrLen("Test", XL, YL);
	BoxTextOffsetY = HeaderOffsetY + 0.5*PlayerBoxSizeY;
	bHaveHalfFont = ( YL < 0.5 * PlayerBoxSizeY);
	
	// if game hasn't begun, draw ready or not ready
	if ( !GRI.bMatchHasBegun )
	{
		for ( i=0; i<PlayerCount; i++ )
		{
			if ( bHaveHalfFont )
			{
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
				Canvas.DrawText(PingText@Min(999,PRIArray[i].Ping),true);
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
				if ( PRIArray[i].bReadyToPlay )
					Canvas.DrawText(ReadyText,true);
				else
					Canvas.DrawText(NotReadyText,true);
			}
			else
			{
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5*YL);
				if ( PRIArray[i].bReadyToPlay )
					Canvas.DrawText(ReadyText,true);
				else
					Canvas.DrawText(NotReadyText,true);
			}
		}
		return;
	}
		
	// draw time and ping
	if ( Canvas.ClipX < 512 )
		PingText = "";
	else
		PingText = Default.PingText;
	for ( i=0; i<PlayerCount; i++ )
		if ( !PRIArray[i].bAdmin && !PRIArray[i].bOutOfLives )
 			{
				if ( bHaveHalfFont )
				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
					Canvas.DrawText(PingText@Min(999,PRIArray[i].Ping),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
					Canvas.DrawText(FormatTime(Max(0,GRI.ElapsedTime - PRIArray[i].StartTime)),true);
				}
				else
				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5*YL);
					Canvas.DrawText(PingText@Min(999,PRIArray[i].Ping),true);
				}
			}
	if ( (OwnerOffset >= PlayerCount) && !PRIArray[OwnerOffset].bAdmin && !PRIArray[OwnerOffset].bOutOfLives )
	{	
		if ( bHaveHalfFont )
		{
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
			Canvas.DrawText(PingText@Min(999,PRIArray[OwnerOffset].Ping),true);
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
			Canvas.DrawText(FormatTime(Max(0,GRI.ElapsedTime - PRIArray[OwnerOffset].StartTime)),true);
		}
		else
		{
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5*YL);
			Canvas.DrawText(PingText@Min(999,PRIArray[OwnerOffset].Ping),true);
		}
	}
}

defaultproperties
{
	RankText="RANK"
	PlayerText="PLAYER"
	PointsText="SCORE"
	TimeText="TIME:"
	PingText="PING:"
	DeathsText="DEATHS"
	AdminText="ADMIN"
	NetText="NET"
	FooterText="Elapsed Time:"
	MatchIDText="UT2003 Stats Match ID"
	OutText="OUT"
	ReadyText="READY"
	NotReadyText="NOT RDY"
	SkillLevel[0]="NOVICE"
	SkillLevel[1]="AVERAGE"
	SkillLevel[2]="EXPERIENCED"
	SkillLevel[3]="SKILLED"
	SkillLevel[4]="ADEPT"
	SkillLevel[5]="MASTERFUL"
	SkillLevel[6]="INHUMAN"
	SkillLevel[7]="GODLIKE"
	YouveLostTheMatch="You've lost the match"
	YouveWonTheMatch="You've won the match"
	MaxLives="MAX LIVES:"
	FragLimit="FRAG LIMIT:"
	FPH="FPH"
	GameType="GAME"
	MapName=" in "
	Restart="You were killed.  Press [Fire] to respawn!"
	Continue=" Press [Fire] to continue!"
	Ended="The match has ended."
	TimeLimit="REMAINING TIME:"
	Spacer=" "
	BoxMaterial=Texture'InterfaceContent.Menu.ScoreBoxA'
	HudClass=Class'WarfareHUD'
}