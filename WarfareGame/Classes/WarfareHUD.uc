//=============================================================================
// WarfareHUD
// Heads up display
//=============================================================================
class WarfareHUD extends HUD
	config;

#exec TEXTURE IMPORT NAME=MessageWindow  FILE=..\HUD\Textures\TalkBorder.PCX GROUP="Icons" MIPS=OFF ALPHATEXTURE=1
#exec Font Import File=..\botpack\Textures\TinyFon2.pcx Name=TinyRedFont
#exec TEXTURE IMPORT NAME=HudElements1 FILE=..\HUD\TEXTURES\HudComp4.pcx GROUP="Icons" MIPS=OFF
#exec OBJ LOAD FILE=..\Textures\LadrStatic.utx PACKAGE=WarfareGame.LadrStatic
#exec OBJ LOAD FILE=..\Textures\TempHud.utx PACKAGE=TempHud
#exec OBJ LOAD FILE=..\Textures\sg_Hud.utx PACKAGE=SG_Hud

var() int SizeY,Count;

var float IdentifyFadeTime;
var PlayerReplicationInfo IdentifyTarget;
var Pawn PawnOwner;	// pawn currently managing this HUD (may be the viewtarget of the owner rather than the owner)
var PlayerController PlayerOwner;
var PlayerReplicationInfo ViewedInfo;
var FontInfo MyFont;
var float StartupMessageEnd;
var int StartupHeight;	// half of height in text lines of startup window
var byte StartupStage;

// Localized Messages
var HUDLocalizedMessage LocalMessages[10];

var int PlayerCount;
var float TutIconBlink, TutDir;

var float TalkTime;
var PlayerReplicationInfo TalkPRI;

var int LastReportedTime;
var int OldClipX;
var bool bStartUpMessage;
var bool bTimeValid;

// configuration options
var bool bAlwaysHideFrags;
var byte Style;
var color FaceColor, WhiteColor;

// Identify Strings
var localized string IdentifyName, IdentifyHealth;
var localized string LiveFeed;

var float PickupTime;

var float WeaponFadeTime;
var float MessageFadeTime;
var bool bDrawFaceArea;
var float FaceAreaOffset, MinFaceAreaOffset;
var class<CriticalEventPlus> TimeMessageClass;
var string FontInfoClass;

var int EdgeOffsetX, EdgeOffsetY;
var float LastTime, CurrentDeltaTime;

var float Scale;

var localized string SingleWaitingMessage;
var localized string gamegoal;
var localized string TourneyMessage;
var localized string WaitingMessage1;
var localized string WaitingMessage2;
var localized string ReadyMessage;
var localized string NotReadyMessage;
var localized string StartMessage;
var localized string LoadoutMessage,LoadoutCycle;

var Material RightHud[2];
var Material LeftHud[2];

var Actor LastTraceActor;		// Who was touched in the last trace

exec function Order( name NewOrders )
{
	if ( (IdentifyTarget == None) || (Bot(IdentifyTarget.Owner) == None) )
		return;

	// FIXME - need to replicate orders to server
	Bot(IdentifyTarget.Owner).SetOrders(NewOrders,PlayerOwner);
}
	
function PlayStartupMessage(byte Stage)
{
	StartupStage = Stage;
	StartupMessageEnd = Level.TimeSeconds + 6;
}

function DrawTextAt(Canvas Canvas, string Text, out int offset, float YL)
{
	Canvas.SetPos(0, Canvas.ClipY*0.5 + YL*(offset-StartupHeight));
	offset++;
	Canvas.DrawText(Text);
}

function int DisplayStartupMessage(Canvas Canvas, int lines)
{
	local int i;
	local float XL, YL;

	if ( StartupStage == 2 )
		return 0;
	Canvas.SetDrawColor(0,32,0);
	Canvas.Font = MyFont.GetMediumFont(Canvas.ClipX);
	Canvas.TextSize( "T", XL, YL );
	Canvas.bCenter = true;
	if ( StartupStage < 2 )
	{
		Canvas.SetPos(Canvas.ClipX*0.25, Canvas.ClipY*0.5 - StartupHeight*YL);
		Canvas.DrawTile(texture'MessageWindow', Canvas.ClipX*0.5, 2*StartupHeight*YL, 
							0, 0, texture'MessageWindow'.USize, texture'MessageWindow'.VSize);
	}
	Canvas.SetDrawColor(128,255,128);
	i = 1;

	if ( (StartupStage == 1) && (Level.NetMode != NM_Standalone) )
	{
		DrawTextAt(Canvas,PlayerOwner.GameReplicationInfo.GameName,i,YL);
		DrawTextAt(Canvas,LoadOutMessage@PlayerOwner.PawnClass.Default.MenuName@LoadOutCycle,i,YL);
		DrawTextAt(Canvas,WaitingMessage1,i,YL);
		DrawTextAt(Canvas,WaitingMessage2,i,YL);
		if ( PlayerOwner.PlayerReplicationInfo.bReadyToPlay )
			DrawTextAt(Canvas,ReadyMessage,i,YL);
		else
			DrawTextAt(Canvas,NotReadyMessage,i,YL);
		return i;
	}
	else if ( StartupStage == 3 )
	{
		DrawTextAt(Canvas,StartMessage,i,YL);
		return i;
	}		
		
	// StartupStage == 0

	DrawTextAt(Canvas,PlayerOwner.GameReplicationInfo.GameName,i,YL);
	
	if (PlayerOwner.PawnClass!=None)
		DrawTextAt(Canvas,LoadOutMessage@PlayerOwner.PawnClass.Default.MenuName@LoadOutCycle,i,YL);

	// Optional FragLimit
	if ( PlayerOwner.GameReplicationInfo.GoalScore > 0 )
		DrawTextAt(Canvas,PlayerOwner.GameReplicationInfo.GoalScore@GameGoal,i,YL);

	if ( Level.NetMode == NM_Standalone )
		DrawTextAt(Canvas,SingleWaitingMessage,i,YL);
	else
		DrawTextAt(Canvas,TourneyMessage,i,YL);

	return i;
}

simulated function HideHUD()
{
	bHideHUD = true;
}

simulated function ShowHUD()
{
	bHideHUD = false;
}

simulated function PostBeginPlay()
{
	FaceAreaOffset = -64;
	MyFont = FontInfo(spawn(Class<Actor>(DynamicLoadObject(FontInfoClass, class'Class'))));
	Super.PostBeginPlay();
	SetTimer(1.0, True);
	PlayerOwner = PlayerController(Owner);

	if ( (PlayerOwner.GameReplicationInfo != None)
		&& (PlayerOwner.GameReplicationInfo.RemainingTime > 0) )
		TimeMessageClass = class<CriticalEventPlus>(DynamicLoadObject("WarfareGame.TimeMessage", class'Class'));
}

simulated function HUDSetup(canvas canvas)
{
	OldClipX = Canvas.ClipX;

	CurrentDeltaTime = Level.TimeSeconds - LastTime;
	LastTime = Level.TimeSeconds;
	
	if (PlayerOwner.ViewTarget == PlayerOwner)
	{
		PawnOwner = PlayerOwner.Pawn;
	}
	else if (PlayerOwner.ViewTarget.IsA('Pawn') && Pawn(PlayerOwner.ViewTarget).Controller != None)
	{	
		PawnOwner = Pawn(PlayerOwner.ViewTarget);
	}
	else if ( PlayerOwner.Pawn != None )
	{
		PawnOwner = PlayerOwner.Pawn;
	}
	else
	{
		PawnOwner = None;
	}
	
	if ( (PawnOwner != None) && (PawnOwner.Controller != None) )
		ViewedInfo = PawnOwner.PlayerReplicationInfo;
	else
		ViewedInfo = PlayerOwner.PlayerReplicationInfo;
		
	// Setup the way we want to draw all HUD elements
	Canvas.Reset();
	Canvas.SpaceX=0;
	Canvas.bNoSmooth = True;

	Style = ERenderStyle.STY_Translucent;
	Canvas.DrawColor = WhiteColor;
	Canvas.Style = Style;
//	Scale = Canvas.ClipX/640.0;
	Scale = Canvas.ClipX / 1024.0;
	Canvas.Font = MyFont.GetSmallFont( Canvas.ClipX );
}

simulated function DrawStatus(Canvas Canvas)
{
	local float xl,yl;
	Local int ArmorAmount,i;
	Local inventory Inv;
	local string s;
	//local int team;
	
	for( Inv=PawnOwner.Inventory; Inv!=None; Inv=Inv.Inventory )
	{ 
		if ( Inv.IsA('Armor') ) 
			ArmorAmount += Inv.Charge;
		else
		{
			i++;
			if ( i > 100 )
				break; // can occasionally get temporary loops in netplay
		}
	}

	//Team = PlayerOwner.PlayerReplicationInfo.Team.TeamIndex; 
	
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetDrawColor(255,255,255);
//	Canvas.SetPos(Canvas.ClipX-(222*Scale),0);
//	Canvas.DrawTile(RightHud[Team],222*Scale,222*Scale,34,0,222,222);		
	Canvas.SetPos(Canvas.ClipX-(255*Scale),0);
	//Canvas.DrawTile(RightHud[Team],256*Scale,256*Scale,0,0,256,256);		
	Canvas.Font = MyFont.GetMediumFont(Canvas.ClipX);

	Canvas.SetDrawColor(255,255,0);
	
	s = ""$PawnOwner.Health;
	Canvas.StrLen(s,xl,yl);
	Canvas.SetPos(Canvas.ClipX - (210*Scale) - (xl/2), (24*Scale));	
	Canvas.DrawText(s,false);	

	s = ""$ArmorAmount;
	Canvas.StrLen(s,xl,yl);
	Canvas.SetPos(Canvas.ClipX -(37*Scale) - (xl/2),(200*Scale));
	Canvas.DrawText(s,false);

/*
	WP = WarfarePawn(PawnOwner);
	if (WP!=None)
	{
	
		WP.DrawClassIcon(Canvas, Scale, Canvas.ClipX - (123*Scale) - (48*Scale), (127 * Scale) - (48*Scale));
	
		s = "Energy: "$int(WP.Energy);
		Canvas.StrLen(s,xl,yl);
		Canvas.SetPos(Canvas.ClipX -xl - 5,Canvas.ClipY-yl-5);
		Canvas.DrawText(s,false);
	}	
*/
}

simulated function DrawAmmo(Canvas Canvas)
{
}

simulated function DrawFragCount(Canvas Canvas)
{
	local int X,Y;
	local float XL,YL;
	local int Score;

	if ( ViewedInfo == None )
		return;

	Canvas.Style = ERenderStyle.STY_Translucent;
	Y = Canvas.ClipY - 32 * Scale - EdgeOffsetY;
	X = EdgeOffsetX;
	if ( ViewedInfo.Team != None )
		Canvas.DrawColor = ViewedInfo.Team.TeamColor;
	else
		Canvas.DrawColor = WhiteColor;

	Canvas.SetPos(X,Y);
	Canvas.DrawTile(Texture'HudElements1', 105 * Scale, 35 * Scale, 0, 93, 105, 35);
	Canvas.DrawColor = WhiteColor;
	Canvas.Font = MyFont.GetHugeFont(Canvas.ClipX);
	Score = Clamp(int(ViewedInfo.Score), -99, 999);
	Canvas.StrLen(Score, XL, YL);
	Canvas.SetPos(X+88*Scale-XL, Y-5);
	Canvas.DrawText(Score, false);
	Canvas.Style = ERenderStyle.STY_Translucent;
}

simulated function DrawGameSynopsis(Canvas Canvas);

function DrawTalkFace(Canvas Canvas, int i, float YPos)
{
/* FIXME_MERGE
	if ( !ViewedInfo.bIsSpectator && (TalkPRI.TalkTexture != None) )
	{
		bDrawFaceArea = True;
		Canvas.DrawColor = WhiteColor;
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.SetPos(FaceAreaOffset + EdgeOffsetX + 2, 2 + EdgeOffsetY);
		Canvas.DrawTile(TalkPRI.TalkTexture, TalkPRI.TalkTexture.USize, TalkPRI.TalkTexture.VSize, 0, 0, TalkPRI.TalkTexture.USize, TalkPRI.TalkTexture.VSize);
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.DrawColor = FaceColor;
		Canvas.SetPos(FaceAreaOffset + EdgeOffsetX, EdgeOffsetY);
//		Canvas.DrawTile(texture'LadrStatic.Static_a00', TalkPRI.TalkTexture.USize + 3, TalkPRI.TalkTexture.VSize + 3, 0, 0, texture'LadrStatic.Static_a00'.USize, texture'LadrStatic.Static_a00'.VSize); // Modified Sean C. Dumas/Taldren
		if ( TalkPRI.Team != None )
			Canvas.DrawColor = TalkPRI.Team.TeamColor;
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.Font = MyFont.GetBigFont(Canvas.ClipX);
		Canvas.SetPos(FaceAreaOffset + EdgeOffsetX, 70 + EdgeOffsetY);
		if ( TalkPRI.Team.TeamIndex > 3 ) 
			Canvas.SetDrawColor(0,255,255);
		Canvas.DrawText(TalkPRI.PlayerName, False);
		Canvas.DrawColor = WhiteColor;
	}
*/
}

//========================================
// Master HUD render function.

simulated function DrawHUD( canvas Canvas )
{
	local float YPos,XL, YL,OldOriginX,FadeValue;
	local int i, FaceNum;

	HUDSetup(canvas);
	if ( bHideHUD || (ViewedInfo == None) )
		return;
	
	
	if ( (PlayerOwner.Pawn==None) && (!bShowScores) && (StartupStage == 2 )  )
	{
		Canvas.Font = MyFont.GetSmallestFont(Canvas.ClipX);
		Canvas.StrLen("You have died.. press [Fire] to respawn or [ALT-Fire] for summary",xl,yl);
		Canvas.SetPos((Canvas.ClipX*0.5) - (XL*0.5), Canvas.ClipY-2-YL);
		Canvas.SetDrawColor(255,255,0);
		Canvas.DrawText("You have died.. press [Fire] to respawn or [ALT-Fire] for summary",true);
	}	
		
	OldOriginX = Canvas.OrgX;
	// Master message short queue control loop.
	FaceNum = -1;
	Canvas.DrawColor = WhiteColor;
	Canvas.SetClip(OldClipX, Canvas.ClipY);

	bDrawFaceArea = ( (TalkTime > Level.TimeSeconds) && (TalkPRI != None) );
	if ( bDrawFaceArea && !bShowScores
			&& (Canvas.ClipY > 320) 
			&& !ViewedInfo.bIsSpectator )
	{
		MinFaceAreaOffset = -1 * (FMax(YL*4 + 8, 35) + 3.5);
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.DrawColor = WhiteColor * MessageFadeTime;
		YPos = FMax(YL*4 + 8, 35);
		DrawTalkFace( Canvas, FaceNum, YPos );
	}

	// Perform Player Tracking
	
	DrawPawnTrackers(Canvas);
	
	// Display Weapons
	Canvas.Style=ERenderStyle.STY_Translucent;

	if ( (PawnOwner !=None) && (Canvas.ClipY > 300) )
	{
		// draw weapon name when it changes
		YPos = Canvas.ClipY - 48;
		Canvas.Font = MyFont.GetMediumFont(Canvas.ClipX);
		if ( PawnOwner.PendingWeapon != None )
		{
			WeaponFadeTime = Level.TimeSeconds + 1.0;
			Canvas.DrawColor = PawnOwner.PendingWeapon.NameColor;
			Canvas.StrLen( PawnOwner.PendingWeapon.ItemName, XL, YL );
			Canvas.SetPos(0.5 * (Canvas.ClipX - XL), YPos);
			Canvas.DrawText(PawnOwner.PendingWeapon.ItemName, False);
		}
		else if ( (WeaponFadeTime > Level.TimeSeconds) && (PawnOwner.Weapon != None) )
		{
			Canvas.DrawColor = PawnOwner.Weapon.NameColor;
			if ( WeaponFadeTime - Level.TimeSeconds < 1 )
				Canvas.DrawColor = Canvas.DrawColor * (WeaponFadeTime - Level.TimeSeconds);
			Canvas.StrLen( PawnOwner.Weapon.ItemName, XL, YL );
			Canvas.SetPos(0.5 * (Canvas.ClipX - XL), YPos);
			Canvas.DrawText(PawnOwner.Weapon.ItemName, False);
		}
	}
	if ( StartupMessageEnd > Level.TimeSeconds )
		DisplayStartupMessage(Canvas, 0);
//	else if ( !bHideCenterMessages )
//	{
		// Master localized message control loop.
		for (i=0; i<10; i++)
		{
			if (LocalMessages[i].Message != None)
			{
				if ( LocalMessages[i].Message.Default.bFadeMessage )
				{
					Canvas.Style = ERenderStyle.STY_Translucent;
					FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds);
					if ( FadeValue > 0.0 ) 
					{
						Canvas.Font = LocalMessages[i].StringFont;
						Canvas.DrawColor = LocalMessages[i].DrawColor * (FadeValue/LocalMessages[i].LifeTime);
						Canvas.StrLen(LocalMessages[i].StringMessage, XL, YL);
						LocalMessages[i].YPos = LocalMessages[i].Message.Static.GetOffset(LocalMessages[i].Switch, YL, Canvas.ClipY);
						if ( (WeaponFadeTime < Level.TimeSeconds) || (LocalMessages[i].YPos != Canvas.ClipY - YL - (64.0/768)*Canvas.ClipY) )
						{
							Canvas.SetPos( 0.5 * (Canvas.ClipX - XL), LocalMessages[i].YPos );
							Canvas.DrawText( LocalMessages[i].StringMessage, False );
						}
						else
							LocalMessages[i].EndOfLife = Level.TimeSeconds;
					}
				} 
				else 
				{
					Canvas.Font = LocalMessages[i].StringFont;
					Canvas.Style = ERenderStyle.STY_Normal;
					Canvas.DrawColor = LocalMessages[i].DrawColor;
					Canvas.StrLen(LocalMessages[i].StringMessage, XL, YL);
					LocalMessages[i].YPos = LocalMessages[i].Message.Static.GetOffset(LocalMessages[i].Switch, YL, Canvas.ClipY);
					Canvas.SetPos( 0.5 * (Canvas.ClipX - XL), LocalMessages[i].YPos );
					Canvas.DrawText( LocalMessages[i].StringMessage, False );
				}
			}
		}
//	}

	Canvas.Style = ERenderStyle.STY_Normal;

	if ( PawnOwner != None )
	{
		if ( (PawnOwner != PlayerOwner.Pawn) && (ViewedInfo != None) )
		{
			Canvas.Font = MyFont.GetBigFont(Canvas.ClipX);
			Canvas.bCenter = true;
			Canvas.Style = ERenderStyle.STY_Normal;
			Canvas.SetDrawColor(0,255 * TutIconBlink,255 * TutIconBlink);
			Canvas.SetPos(4, Canvas.ClipY - 48);
			Canvas.DrawText( LiveFeed$ViewedInfo.PlayerName, true );
			Canvas.bCenter = false;
			Canvas.DrawColor = WhiteColor;
			Canvas.Style = Style;
		}
	}

	if ( bStartUpMessage && (Level.TimeSeconds < 5) )
	{
		bStartUpMessage = false;
		PlayerOwner.SetProgressTime(7);
	}
		 
	if ( !ViewedInfo.bIsSpectator )
	{
		Canvas.Style = Style;

		// Let the Weapon draw it's info
		if ( PawnOwner != None )
		{
			if (PawnOwner.Weapon!=None)
			{
				WarfareWeapon(PawnOwner.Weapon).DrawHud(Canvas,Self,MyFont,Scale);
			}
			
			// Draw Health/Armor status
			DrawStatus(Canvas);
		}

		// Display Frag count
//		if ( !bAlwaysHideFrags )
//			DrawFragCount(Canvas);

		// Team Game Synopsis
		DrawGameSynopsis(Canvas);
	}

	// Display Identification Info
	if ( (Canvas.ClipY > 320) && TraceIdentify(Canvas) )
	{
		Canvas.Font = MyFont.GetBigFont(Canvas.ClipX);
		DrawTwoColorID(Canvas,IdentifyName, IdentifyTarget.PlayerName, Canvas.ClipY - 144);
	}	

	if ( (PlayerOwner.GameReplicationInfo != None) && (PlayerOwner.GameReplicationInfo.RemainingTime > 0) ) 
	{
		if ( (PlayerOwner.GameReplicationInfo.RemainingTime <= 300)
		  && (PlayerOwner.GameReplicationInfo.RemainingTime != LastReportedTime) )
		{
			LastReportedTime = PlayerOwner.GameReplicationInfo.RemainingTime;
			if ( PlayerOwner.GameReplicationInfo.RemainingTime <= 30 )
			{
				bTimeValid = ( bTimeValid || (PlayerOwner.GameReplicationInfo.RemainingTime > 0) );	
				if ( PlayerOwner.GameReplicationInfo.RemainingTime == 30 )
					TellTime(30);
				else if ( bTimeValid && PlayerOwner.GameReplicationInfo.RemainingTime <= 10 )
					TellTime(PlayerOwner.GameReplicationInfo.RemainingTime);
			}
			else if ( PlayerOwner.GameReplicationInfo.RemainingTime % 60 == 0 )
				TellTime(PlayerOwner.GameReplicationInfo.RemainingTime);
		}
	}
	
	if (WarfarePawn(PawnOwner)!=None)
		WarfarePawn(PawnOwner).DrawWarfareHud(Canvas,self,MyFont,Scale);
	
}

function Timer()
{
	local int i;

	// Age all localized messages.
	for (i=0; i<10; i++)
	{
		// Purge expired messages.
		if ( (LocalMessages[i].Message != None) && (Level.TimeSeconds >= LocalMessages[i].EndOfLife) )
			ClearMessage(LocalMessages[i]);
	}

	// Clean empty slots.
	for (i=0; i<9; i++)
	{
		if ( LocalMessages[i].Message == None )
		{
			CopyMessage(LocalMessages[i],LocalMessages[i+1]);
			ClearMessage(LocalMessages[i+1]);
		}
	}

	if ( (PlayerOwner == None) || (PawnOwner == None) || (PlayerOwner.GameReplicationInfo == None)
		|| (ViewedInfo == None) )
		return;
}

simulated function TellTime(int num)
{
	PlayerOwner.ReceiveLocalizedMessage( TimeMessageClass, Num );
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	IdentifyFadeTime = FMax(0.0, IdentifyFadeTime - DeltaTime);
	
	TutIconBlink += TutDir * DeltaTime;
	if ( TutIconBlink >= 1 )
	{
		TutDir *= -1;
		TutIconBlink = 1;
	}
	else if ( TutIconBlink <= 0 )
	{
		TutDir *= -1;
		TutIconBlink = 0;
	}

	if ( bDrawFaceArea )
	{
		if ( FaceAreaOffset < 0 )
			FaceAreaOffset += DeltaTime * 600;
		if ( FaceAreaOffset > 0 )
			FaceAreaOffset = 0.0;
	} 
	else if ( FaceAreaOffset > MinFaceAreaOffset )
		FaceAreaOffset = FMax(FaceAreaOffset - DeltaTime * 600, MinFaceAreaOffset );

	if ( MessageFadeTime < 1.0 )
	{
		MessageFadeTime += DeltaTime * 8;
		if (MessageFadeTime > 1.0)
			MessageFadeTime = 1.0;
	}
}

// Entry point for string messages.
simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	local Class<LocalMessage> MessageClass;

	if ( bMessageBeep )
		PlayerOwner.PlayBeepSound();
	switch (MsgType)
	{
		case 'Say':
			Msg = PRI.PlayerName$": "$Msg;
			MessageClass = class'SayMessagePlus';
			break;
		case 'TeamSay':
			Msg = PRI.PlayerName$": "$Msg;
			MessageClass = class'TeamSayMessagePlus';
			break;
		case 'CriticalEvent':
			MessageClass = class'CriticalStringPlus';
			LocalizedMessage( MessageClass, 0, None, None, None, Msg );
			return;
		case 'DeathMessage':
			MessageClass = class'RedSayMessagePlus';
			break;
		case 'Pickup':
			PickupTime = Level.TimeSeconds;
		default:
			MessageClass = class'StringMessagePlus';
			break;
	}

	if ( ClassIsChildOf(MessageClass, class'SayMessagePlus') || 
				     ClassIsChildOf(MessageClass, class'TeamSayMessagePlus') )
	{
		TalkTime = MessageClass.Default.Lifetime + Level.TimeSeconds;
		TalkPRI = PRI;
	} 
	AddTextMessage(Msg,MessageClass,PRI);
}

//================================================================================
// Identify Info

simulated function bool TraceIdentify(canvas Canvas)
{
	local actor Other;
	local vector HitLocation, HitNormal, StartTrace, EndTrace;

	if ( (PawnOwner == None) || (PawnOwner != PlayerOwner.Pawn) )
		return false;

	StartTrace = PawnOwner.Location;
	StartTrace.Z += PawnOwner.BaseEyeHeight;
	EndTrace = StartTrace + vector(PlayerOwner.Rotation) * 2048.0;
	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
	
	LastTraceActor = other;
	
	if ( IdentifyFadeTime == 0.0 )
		IdentifyTarget = None;

	if ( Pawn(Other) != None )
	{
		if ( (Pawn(Other).PlayerReplicationInfo != None) && !Other.bHidden )
		{
			IdentifyTarget = Pawn(Other).PlayerReplicationInfo;
			IdentifyFadeTime = 3.0;
		}
	}
	else if ( (Other != None) && SpecialIdentify(Canvas, Other) )
		return false;

	if ( (IdentifyFadeTime == 0.0) || (IdentifyTarget == None) || (IdentifyTarget.PlayerName == "") )
		return false;

	return true;
}

simulated function bool SpecialIdentify(Canvas Canvas, Actor Other )
{
	return false;
}

simulated function SetIDColor( Canvas Canvas, int type )
{
	if ( type == 0 )
		Canvas.SetDrawColor(0,160 * (IdentifyFadeTime / 3.0),0);
	else
		Canvas.SetDrawColor(0,255 * (IdentifyFadeTime / 3.0),0);
}

simulated function DrawTwoColorID( canvas Canvas, string TitleString, string ValueString, int YStart )
{
	local float XL, YL, XOffset, X1;

	Canvas.Style = Style;
	Canvas.StrLen(TitleString$": ", XL, YL);
	X1 = XL;
	Canvas.StrLen(ValueString, XL, YL);
	XOffset = Canvas.ClipX/2 - (X1+XL)/2;
	Canvas.SetPos(XOffset, YStart);
	SetIDColor(Canvas,0);
	XOffset += X1;
	Canvas.DrawText(TitleString);
	Canvas.SetPos(XOffset, YStart);
	SetIDColor(Canvas,1);
	Canvas.DrawText(ValueString);
	Canvas.DrawColor = WhiteColor;
}


//=====================================================================
// Deal with a localized message.

simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional String CriticalString )
{
	local int i;

	if ( bMessageBeep && Message.Default.bBeep )
		PlayerOwner.PlayBeepSound();

	if ( ClassIsChildOf(Message, class'PickupMessagePlus') )
		PickupTime = Level.TimeSeconds;

	if ( !Message.Default.bIsSpecial )
	{
		if ( ClassIsChildOf(Message, class'SayMessagePlus') || 
						 ClassIsChildOf(Message, class'TeamSayMessagePlus') )
		{
			TalkTime = Message.Default.Lifetime + Level.TimeSeconds;
			TalkPRI = RelatedPRI_1;
		}
		return;
	} 
	else 
	{
		if ( CriticalString == "" )
			CriticalString = Message.Static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		if ( Message.Default.bIsUnique )
		{
			for (i=0; i<10; i++)
			{
				if (LocalMessages[i].Message != None)
				{
					if ((LocalMessages[i].Message == Message) 
						|| (LocalMessages[i].Message.Static.GetOffset(LocalMessages[i].Switch, 24, 640) 
								== Message.Static.GetOffset(Switch, 24, 640)) ) 
					{
						LocalMessages[i].Message = Message;
						LocalMessages[i].Switch = Switch;
						LocalMessages[i].RelatedPRI = RelatedPRI_1;
						LocalMessages[i].OptionalObject = OptionalObject;
						LocalMessages[i].LifeTime = Message.Default.Lifetime;
						LocalMessages[i].EndOfLife = Message.Default.Lifetime + Level.TimeSeconds;
						LocalMessages[i].StringMessage = CriticalString;
						LocalMessages[i].DrawColor = Message.Static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);				
						if ( LocalMessages[i].Message.Static.GetFontSize(LocalMessages[i].Switch, RelatedPRI_1, RelatedPRI_2,ViewedInfo) == 1 )
							LocalMessages[i].StringFont = MyFont.GetBigFont(OldClipX);
						else // == 2
							LocalMessages[i].StringFont = MyFont.GetHugeFont(OldClipX);
						return;
					}
				}
			}
		}
		for (i=0; i<10; i++)
		{
			if (LocalMessages[i].Message == None)
			{
				LocalMessages[i].Message = Message;
				LocalMessages[i].Switch = Switch;
				LocalMessages[i].RelatedPRI = RelatedPRI_1;
				LocalMessages[i].OptionalObject = OptionalObject;
				LocalMessages[i].EndOfLife = Message.Default.Lifetime + Level.TimeSeconds;
				LocalMessages[i].StringMessage = CriticalString;
				LocalMessages[i].DrawColor = Message.Static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);				
				LocalMessages[i].LifeTime = Message.Default.Lifetime;
				if ( LocalMessages[i].Message.Static.GetFontSize(LocalMessages[i].Switch, RelatedPRI_1, RelatedPRI_2,ViewedInfo) == 1 )
					LocalMessages[i].StringFont = MyFont.GetBigFont(OldClipX);
				else // == 2
					LocalMessages[i].StringFont = MyFont.GetHugeFont(OldClipX);
				return;
			}
		}

		// No empty slots.  Force a message out.
		for (i=0; i<9; i++)
			CopyMessage(LocalMessages[i],LocalMessages[i+1]);

		LocalMessages[9].Message = Message;
		LocalMessages[9].Switch = Switch;
		LocalMessages[9].RelatedPRI = RelatedPRI_1;
		LocalMessages[9].OptionalObject = OptionalObject;
		LocalMessages[9].EndOfLife = Message.Default.Lifetime + Level.TimeSeconds;
		LocalMessages[9].StringMessage = CriticalString;
		LocalMessages[9].DrawColor = Message.Static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);				
		LocalMessages[9].LifeTime = Message.Default.Lifetime;
		if ( LocalMessages[9].Message.Static.GetFontSize(LocalMessages[9].Switch, RelatedPRI_1, RelatedPRI_2,ViewedInfo) == 1 )
			LocalMessages[9].StringFont = MyFont.GetBigFont(OldClipX);
		else // == 2
			LocalMessages[9].StringFont = MyFont.GetHugeFont(OldClipX);
		return;
	}
}

function DisplayMessages(canvas Canvas)
{
	local float XPos, XClip, oOX, oOY, oCX, oCY;

	XPos = 0.25 * Canvas.ClipX;
	oOX = Canvas.OrgX;
	oOY = Canvas.OrgY;
	oCX = Canvas.ClipX;
	oCY = Canvas.ClipY;
	
	// @@@Hack for bad ammo drawing stuff since it's so small
	if (Scale<1)
		XPos = 195;
	else
		XPos = 195*Scale;
		
	XClip = Canvas.ClipX - (235*Scale) - XPos ;
	
	Canvas.SetOrigin(XPos, 5);
	Canvas.SetClip(XClip,Canvas.ClipY);
	
	Super.DisplayMessages(Canvas);

	Canvas.OrgX  = oOX;
	Canvas.OrgY  = oOY; 
	Canvas.ClipX = oCX;
	Canvas.ClipY = oCY; 
	
	Canvas.Reset();		
}

simulated function DrawPawnTrackers(Canvas Canvas)
{
	local Pawn p,PlayerPawn;
	local vector vecPawnView;
	local float fX;
	local float fY;
	local WarfareWeapon PlayerWeap;
	local vector X, Y, Z, L, V;

	PlayerPawn = PlayerOwner.Pawn;

	if (PlayerPawn==None)
		return;
	
	GetAxes(PlayerPawn.GetViewRotation(), X, Y, Z);

	foreach DynamicActors(Class'Pawn', p)
	{

		if ( (P!=PlayerPawn) && (!P.bInvulnerableBody) )
		{

			// Get a vector from the player to the pawn
			vecPawnView = P.Location - PlayerPawn.Location - (PlayerPawn.EyeHeight * vect(0,0,1));
			
			// Is he visible to the player

			if ( PawnIsVisible(vecPawnView,X,P) )
			{
			
				L = P.Location + ( Vect(0,0,1) * P.CollisionHeight ); 						
				V = PlayerOwner.Player.Console.WorldToScreen(L, PlayerPawn.Location + (PlayerPAwn.EyeHeight * Vect(0,0,1)), PlayerPawn.Rotation);				
				fx = V.X;
				fy = V.Y;
						
				// Allow the Weapon to track players as well
		
				PlayerWeap = WarfareWeapon(PlayerPawn.Weapon);
		
				if ( ( (PlayerWeap==None) || (!PlayerWeap.TrackPlayer(Canvas, fX, fY, P)) ) &&   
						 (PawnIsValid(vecPawnView, X, p)) && PawnIsInRange(P) )  
				{
	
					// draw stuff!
			
					DrawPawnInfo(Canvas, fX, fY, p);
				}
			}
		}
	}
}	

simulated function bool PawnIsVisible(vector vecPawnView, vector X, pawn P)
{
	local vector StartTrace, EndTrace;

    if ( (PawnOwner == None) || (PlayerOwner==None) )
		return false;

	if ( PawnOwner != PlayerOwner.Pawn )
		return false;

	if ( (vecPawnView Dot X) <= 0.70 )
		return false;
		
	StartTrace = PawnOwner.Location;
	StartTrace.Z += PawnOwner.BaseEyeHeight;

	EndTrace = P.Location;
	EndTrace.Z += P.BaseEyeHeight;

	if ( !FastTrace(EndTrace, StartTrace) )
		return false;

	return true;		
}

simulated function bool PawnIsInRange(pawn P)
{
	if ( Vsize(P.Location - PawnOwner.Location) > 4096)
		return false;
		
	return true;
}

simulated function bool PawnIsValid(vector vecPawnView, vector X, pawn P)
{
	return false;
}

// Should be subclassed
simulated function DrawPawnInfo(Canvas canvas, float screenX, float screenY, pawn P);

simulated function DrawPercBar(Canvas Canvas, int Width, float ScreenX, float ScreenY, float Perc)
{
	local float used;	
	Canvas.SetPos(ScreenX - (width/2),ScreenY);
	Canvas.SetDrawColor(255,0,0);
	Canvas.DrawRect(Texture'engine.WhiteSquareTexture', Width, 4);

	Canvas.SetPos(ScreenX - (width/2),ScreenY);
	Canvas.SetDrawColor(0,255,0);
	Used = float(Width) * Perc; 
	Canvas.DrawRect(Texture'engine.WhiteSquareTexture', Used, 4);
}
	


defaultproperties
{
	StartupHeight=3
	TutDir=1
	bStartUpMessage=true
	Style=3
	FaceColor=(B=50,G=50,R=50,A=255)
	WhiteColor=(B=255,G=255,R=255,A=255)
	IdentifyName="Name:"
	IdentifyHealth="Health:"
	LiveFeed="Live Feed from "
	TimeMessageClass=Class'TimeMessage'
	FontInfoClass="WarfareGame.FontInfo"
	EdgeOffsetX=16
	EdgeOffsetY=16
	SingleWaitingMessage="Press Fire to start."
	gamegoal="frags wins the match."
	TourneyMessage="Waiting for other players."
	WaitingMessage1="Waiting for ready signals."
	WaitingMessage2="(Use your fire button to toggle ready!)"
	ReadyMessage="You are READY!"
	NotReadyMessage="You are NOT READY!"
	StartMessage="The match has begun!"
	LoadoutMessage="Loadout:"
	LoadoutCycle=" (F7 cycles)."
	RightHud[0]=Shader'SG_Hud.COG.HUD'
	RightHud[1]=Shader'SG_Hud.COG.HUD'
	LeftHud[0]=Texture'TempHud.HUD.CogHudFlatLeft'
	LeftHud[1]=Texture'TempHud.HUD.GeistHudFlatLeft'
	MedFont=Font'PS2Fonts.PS214'
	BigFont=Font'PS2Fonts.PS220'
	LargeFont=Font'PS2Fonts.PS230'
}