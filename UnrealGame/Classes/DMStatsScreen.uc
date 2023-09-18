class DMStatsScreen extends Scoreboard;

#EXEC OBJ LOAD FILE=InterfaceContent.utx

var UnrealPlayer PlayerOwner;
var TeamPlayerReplicationInfo PRI;
var localized string StatsString, AwardsString, FirstBloodString, SuicidesString, LongestSpreeString, FlakMonkey, ComboWhore, 
	HeadHunter, FlagTouches, FlagReturns,GoalsScored,HatTrick, KillString[7], AdrenalineCombos, ComboNames[5], KillsByWeapon,
	CombatResults,Kills,Deaths,Suicides, NextStatsString, WeaponString, DeathsBy, DeathsHolding, EfficiencyString, WaitingForStats;
var float LastUpdateTime;
var Material BoxMaterial;

static function string MakeColorCode(color NewColor)
{
	// Text colours use 1 as 0.
	if(NewColor.R == 0)
		NewColor.R = 1;

	if(NewColor.G == 0)
		NewColor.G = 1;

	if(NewColor.B == 0)
		NewColor.B = 1;

	return Chr(0x1B)$Chr(NewColor.R)$Chr(NewColor.G)$Chr(NewColor.B);
}

simulated event DrawScoreboard( Canvas C )
{
	local int i,j, temp, AwardsNum, CombosNum,GoalsNum;
	local int Ordered[20];
	local float OffsetY;
	local float AwardsOffsetY, CombosOffsetY, GoalsOffsetY, CombatOffsetY, WeaponsOffsetY;
	local float AwardsBoxSizeY, CombosBoxSizeY, GoalsBoxSizeY, CombatBoxSizeY, WeaponsBoxSizeY, XL, LargeYL;
	local float IndentX, AwardWidth, WeaponWidth, AwardX, AwardsBoxX, CombatBoxX, GoalsBoxX, CombosBoxX;
	
	if ( PlayerOwner == None )
	{
		PlayerOwner = UnrealPlayer(Owner);
		if ( PlayerOwner == None )
		{
			C.SetPos(IndentX,IndentX);
			C.DrawText(WaitingForStats);
			return;
		}
	}
	if ( PRI == None )
	{
		PRI = TeamPlayerReplicationInfo(PlayerOwner.PlayerReplicationInfo);
		if ( PRI == None )
		{
			C.SetPos(IndentX,IndentX);
			C.DrawText(WaitingForStats);
			return;
		}
	}
	if ( Level.TimeSeconds - LastUpdateTime > 2 )
	{
		LastUpdateTime = Level.TimeSeconds;
		PlayerOwner.ServerUpdateStats(PRI);
	}
	C.DrawColor =  class'Canvas'.Static.MakeColor(255,255,255);
	
	// draw boxes
	
	// FIXME C.Font = PlayerOwner.myHUD.GetFontSizeIndex(C,-1);
	PlayerOwner.myHUD.UseSmallFont(C);
	C.StrLen(StatsString, XL, LargeYL);
	
	IndentX = 0.015 * C.ClipX;
	AwardsOffsetY = IndentX + 2*LargeYL;
	
	if ( PRI.bFirstBlood )
		AwardsNum++;
		
	for ( i=0; i<6; i++ )
		if ( PRI.Spree[i] > 0 )
			AwardsNum++;
	
	for ( i=0; i<7; i++ )
		if ( PRI.MultiKills[i] > 0 )
			AwardsNum++;

	if ( PRI.flakcount >= 15 )
		AwardsNum++;	
	if ( PRI.combocount >= 15 )
		AwardsNum++;	
	if ( PRI.headcount >= 15 )
		AwardsNum++;	
	if ( PRI.GoalsScored >= 3 )
		AwardsNum++;
		
	C.StrLen("REALLY X999"$KillString[5], AwardWidth, LargeYL);
	if ( AwardsNum > 0 )
	{
		AwardsBoxX = FMin(0.9*C.ClipX, Min(3,AwardsNum)*AwardWidth + 4*IndentX);
		AwardsBoxSizeY = LargeYL + (2 + (AwardsNum-1)/3) * LargeYL;
		C.SetPos(IndentX, AwardsOffsetY);
		C.DrawColor =  class'Canvas'.Static.MakeColor(255,0,255);
		C.DrawColor.R = 128;
		C.DrawTileStretched( BoxMaterial, AwardsBoxX, AwardsBoxSizeY);
	}
	
	CombosOffsetY = AwardsOffsetY + AwardsBoxSizeY + 0.5*LargeYL;	
	for ( i=0; i<5; i++ )
		if ( PRI.Combos[i] > 0 )
			CombosNum++;	

	if ( CombosNum > 0 )
	{
		C.DrawColor =  class'Canvas'.Static.MakeColor(0,0,255);
		CombosBoxSizeY = LargeYL + (1+CombosNum) * LargeYL;
		C.SetPos(IndentX, CombosOffsetY);
		C.StrLen(AdrenalineCombos, XL, LargeYL);
		CombosBoxX = 4*IndentX + 2*XL;
		C.DrawTileStretched( BoxMaterial, CombosBoxX, CombosBoxSizeY);
	}
	
	C.DrawColor =  class'Canvas'.Static.MakeColor(0,255,0);
	CombatOffsetY = CombosOffsetY + CombosBoxSizeY + 0.5*LargeYL;
	CombatBoxSizeY = LargeYL + 4 * LargeYL;
	C.SetPos(IndentX, CombatOffsetY);
	C.StrLen(CombatResults, XL, LargeYL);
	CombatBoxX = XL + 4*IndentX;
	C.DrawTileStretched( BoxMaterial, CombatBoxX, CombatBoxSizeY);
	
	GoalsOffsetY = CombatOffsetY;
	
	if ( PRI.GoalsScored > 0 )
		GoalsNum++;
	if ( PRI.FlagTouches > 0 )
		GoalsNum++;
	if ( PRI.FlagReturns > 0 )
		GoalsNum++;
	if ( GoalsNum > 0 )
	{
		C.DrawColor =  class'Canvas'.Static.MakeColor(255,255,0);
		GoalsBoxSizeY = LargeYL + GoalsNum * LargeYL;
		C.SetPos(3*IndentX+CombatBoxX, GoalsOffsetY);
		C.StrLen(GoalsScored$" 999 XXXxxXX", XL, LargeYL);
		GoalsBoxX = CombatBoxX;
		C.DrawTileStretched( BoxMaterial, GoalsBoxX, GoalsBoxSizeY);
	}

	C.DrawColor = class'Canvas'.Static.MakeColor(255,255,255);
	WeaponsOffsetY = GoalsOffsetY + FMax(CombatBoxSizeY,GoalsBoxSizeY) + 0.5*LargeYL;
	WeaponsBoxSizeY = FMin(3*LargeYL + PRI.WeaponStatsArray.Length * LargeYL, C.ClipY - WeaponsOffsetY - IndentX);
	C.SetPos(IndentX, WeaponsOffsetY);
	C.StrLen("ROCKET LAUNCHER REALLY", WeaponWidth, LargeYL);
	C.DrawTileStretched( BoxMaterial, C.ClipX - 2*IndentX, WeaponsBoxSizeY);
	
	// Draw text
	C.SetPos(IndentX,IndentX);
	C.DrawText(StatsString@PRI.PlayerName);
	C.SetPos(IndentX,IndentX+LargeYL);
	
	if ( (PRI.WeaponStatsArray.Length == 0) && (AwardsNum == 0) && (CombosNum == 0) && (GoalsNum == 0) )
		C.DrawText(WaitingForStats);
	else
		C.DrawText(NextStatsString);
	
	if ( AwardsNum > 0 )
	{
		AwardsNum = 0;
		AwardX = 2*IndentX;
		OffsetY = AwardsOffsetY + 0.5*LargeYL;
		C.SetPos(AwardX,OffsetY);
		C.DrawColor =  class'Canvas'.Static.MakeColor(255,255,0);
		C.DrawText(AwardsString);
		OffsetY += LargeYL;
		C.SetPos(AwardX,OffsetY);
		
		C.DrawColor = class'Canvas'.Static.MakeColor(255,0,0);;
		if ( PRI.bFirstBlood )
		{
			C.DrawText(FirstBloodString);
			AwardsNum++;
			if ( AwardsNum%3 == 0 )
				OffsetY += LargeYL;
			C.SetPos(AwardX + (AwardsNum%3)*AwardsBoxX*0.33,OffsetY);
		}
		C.DrawColor = class'Canvas'.Static.MakeColor(0,255,128);
		for ( i=0; i<6; i++ )
			if ( PRI.Spree[i] > 0 )
			{
				C.DrawText(class'KillingSpreeMessage'.default.SelfSpreeNote[i]$MakeColorCode( class'Canvas'.Static.MakeColor(255,255,0))$"X"$PRI.Spree[i]);
				AwardsNum++;
				if ( AwardsNum%3 == 0 )
					OffsetY += LargeYL;
				C.SetPos(AwardX + (AwardsNum%3)*AwardsBoxX*0.33,OffsetY);
			}
		
		C.DrawColor = class'Canvas'.Static.MakeColor(255,0,0);;
		C.DrawColor.G = 128;
		for ( i=0; i<7; i++ )
			if ( PRI.MultiKills[i] > 0 )
			{
				C.DrawText(KillString[i]$MakeColorCode(class'Canvas'.Static.MakeColor(255,255,0))$"X"$PRI.MultiKills[i]);
				AwardsNum++;
				if ( AwardsNum%3 == 0 )
					OffsetY += LargeYL;
				C.SetPos(AwardX + (AwardsNum%3)*AwardsBoxX*0.33,OffsetY);
			}

		C.DrawColor = class'Canvas'.Static.MakeColor(255,255,255);
		if ( PRI.flakcount >= 15 )
		{
			C.DrawText(FlakMonkey);	
			AwardsNum++;
			if ( AwardsNum%3 == 0 )
				OffsetY += LargeYL;
			C.SetPos(AwardX + (AwardsNum%3)*AwardsBoxX*0.33,OffsetY);
		}
		if ( PRI.combocount >= 15 )
		{
			C.DrawText(ComboWhore);	
			AwardsNum++;
			if ( AwardsNum%3 == 0 )
				OffsetY += LargeYL;
			C.SetPos(AwardX + (AwardsNum%3)*AwardsBoxX*0.33,OffsetY);
		}
		if ( PRI.headcount >= 15 )
		{
			C.DrawText(HeadHunter);	
			AwardsNum++;
			if ( AwardsNum%3 == 0 )
				OffsetY += LargeYL;
			C.SetPos(AwardX + (AwardsNum%3)*AwardsBoxX*0.33,OffsetY);
		}
		if ( PRI.GoalsScored >= 3 )
		{
			C.DrawColor = class'Canvas'.Static.MakeColor(255,255,0);
			C.DrawText(HatTrick);	
			AwardsNum++;
			if ( AwardsNum%3 == 0 )
				OffsetY += LargeYL;
			C.SetPos(AwardX + (AwardsNum%3)*AwardsBoxX*0.33,OffsetY);
		}
	}
	
	if ( CombosNum > 0 )
	{	
		CombosNum = 0;
		OffsetY = CombosOffsetY + 0.5*LargeYL;
		C.SetPos(2*IndentX,OffsetY);
		C.DrawColor = class'Canvas'.Static.MakeColor(255,255,0);
		C.DrawText(AdrenalineCombos);	
		OffsetY += LargeYL;
		C.SetPos(2*IndentX,OffsetY);
		C.DrawColor = class'Canvas'.Static.MakeColor(0,255,255);
		for ( i=0; i<5; i++ )
			if ( PRI.Combos[i] > 0 )
			{
				C.DrawText(ComboNames[i]$MakeColorCode(class'Canvas'.Static.MakeColor(255,255,0))$"X"$PRI.Combos[i]);
				CombosNum++;
				if ( CombosNum%2 == 0 )	
					OffsetY += LargeYL;
				C.SetPos(2*IndentX + (CombosNum%2)*0.5*CombosBoxX,OffsetY);
			}
	}
			
	C.DrawColor = class'Canvas'.Static.MakeColor(255,255,0);
	OffsetY = CombatOffsetY + 0.5*LargeYL;
	C.SetPos(2*IndentX,OffsetY);
	C.DrawText(CombatResults);
	C.DrawColor = class'Canvas'.Static.MakeColor(255,255,255);
	OffsetY += LargeYL;
	C.SetPos(2*IndentX,OffsetY);
	C.DrawText(Kills);
	C.StrLen(PRI.Kills, XL, LargeYL);
	C.SetPos(CombatBoxX - XL - 2*IndentX,OffsetY);
	C.DrawText(PRI.Kills);
	OffsetY += LargeYL;
	C.SetPos(2*IndentX,OffsetY);
	C.DrawText(Deaths);
	C.StrLen(int(PRI.Deaths), XL, LargeYL);
	C.SetPos(CombatBoxX - XL - 2*IndentX,OffsetY);
	C.DrawText(int(PRI.Deaths));
	OffsetY += LargeYL;
	C.SetPos(2*IndentX,OffsetY);
	C.DrawText(Suicides);
	C.StrLen(PRI.Suicides, XL, LargeYL);
	C.SetPos(CombatBoxX - XL - 2*IndentX,OffsetY);
	C.DrawText(PRI.Suicides);
			
	if ( GoalsNum > 0 )
	{
		C.DrawColor = class'Canvas'.Static.MakeColor(0,255,255);
		OffsetY = CombatOffsetY + 0.5*LargeYL;
		C.SetPos(4*IndentX+CombatBoxX,OffsetY);
		if ( PRI.GoalsScored > 0 )
		{
			C.DrawText(GoalsScored);
			C.StrLen(PRI.GoalsScored, XL, LargeYL);
			C.SetPos(IndentX+CombatBoxX+GoalsBoxX - XL,OffsetY);
			C.DrawText(PRI.GoalsScored);
			OffsetY += LargeYL;
			C.SetPos(4*IndentX+CombatBoxX,OffsetY);
		}
		if ( PRI.FlagTouches > 0 )
		{
			C.DrawText(FlagTouches);
			C.StrLen(PRI.FlagTouches, XL, LargeYL);
			C.SetPos(IndentX+CombatBoxX+GoalsBoxX - XL,OffsetY);
			C.DrawText(PRI.FlagTouches);
			OffsetY += LargeYL;
			C.SetPos(4*IndentX+CombatBoxX,OffsetY);
		}

		if ( PRI.FlagReturns > 0 )
		{
			C.DrawText(FlagReturns);
			C.StrLen(PRI.FlagReturns, XL, LargeYL);
			C.SetPos(IndentX+CombatBoxX+GoalsBoxX - XL,OffsetY);
			C.DrawText(PRI.FlagReturns);
			OffsetY += LargeYL;
			C.SetPos(4*IndentX+CombatBoxX,OffsetY);
		}
	}
	
	OffsetY = WeaponsOffsetY + 0.5*LargeYL;
	C.SetPos(2*IndentX,OffsetY);
	C.DrawColor = class'Canvas'.Static.MakeColor(255,255,0);
	C.DrawText(KillsByWeapon);
	OffsetY += LargeYL;
	C.SetPos(2*IndentX,OffsetY);
	C.DrawColor = class'Canvas'.Static.MakeColor(128,128,128);
	C.DrawColor.G = 255;
	
	C.SetPos(2*IndentX,OffsetY);
	C.DrawText(WeaponString);
	C.SetPos(2*IndentX + WeaponWidth,OffsetY);
	C.DrawText(Kills);
	C.SetPos(2*IndentX + WeaponWidth + 0.2 * (C.ClipX - 4*IndentX - WeaponWidth),OffsetY);
	C.DrawText(DeathsBy);
	C.SetPos(2*IndentX + WeaponWidth + 0.5 * (C.ClipX - 4*IndentX - WeaponWidth),OffsetY);
	C.DrawText(DeathsHolding);
	C.SetPos(2*IndentX + WeaponWidth + 0.8 * (C.ClipX - 4*IndentX - WeaponWidth),OffsetY);
	C.DrawText(EfficiencyString);
	OffsetY += LargeYL;
	C.SetPos(2*IndentX,OffsetY);
	C.DrawColor =  class'Canvas'.Static.MakeColor(0,255,0);

	for ( i=0; i<PRI.WeaponStatsArray.Length; i++ )
		Ordered[i] = i;
	
	for ( i=0; i<PRI.WeaponStatsArray.Length; i++ )
	{
		for ( j=i; j<PRI.WeaponStatsArray.Length; j++ )
		{
			if ( PRI.WeaponStatsArray[Ordered[i]].Kills < PRI.WeaponStatsArray[Ordered[j]].Kills )
			{
				temp = Ordered[i];
				Ordered[i] = Ordered[j];
				Ordered[j] = temp;
			}
		}
	}
	for ( i=0; i<PRI.WeaponStatsArray.Length; i++ )
	{
		C.DrawText(PRI.WeaponStatsArray[Ordered[i]].WeaponClass.Default.ItemName);
		C.SetPos(2*IndentX + WeaponWidth,OffsetY);
		C.DrawText(PRI.WeaponStatsArray[Ordered[i]].Kills);
		C.SetPos(2*IndentX + WeaponWidth + 0.2 * (C.ClipX - 4*IndentX - WeaponWidth),OffsetY);
		C.DrawText(PRI.WeaponStatsArray[Ordered[i]].Deaths);
		C.SetPos(2*IndentX + WeaponWidth + 0.5 * (C.ClipX - 4*IndentX - WeaponWidth),OffsetY);
		C.DrawText(PRI.WeaponStatsArray[Ordered[i]].DeathsHolding);
		C.SetPos(2*IndentX + WeaponWidth + 0.8 * (C.ClipX - 4*IndentX - WeaponWidth),OffsetY);
		if ( PRI.WeaponStatsArray[Ordered[i]].DeathsHolding+PRI.WeaponStatsArray[Ordered[i]].Kills == 0 )
			C.DrawText("0%");
		else
			C.DrawText(int(100 * float(PRI.WeaponStatsArray[Ordered[i]].Kills)/float(PRI.WeaponStatsArray[Ordered[i]].DeathsHolding+PRI.WeaponStatsArray[Ordered[i]].Kills))$"%");
		
		OffsetY += LargeYL;
		C.SetPos(2*IndentX,OffsetY);
		
		if ( OffsetY > C.ClipY - LargeYL - IndentX )
			break;
	}
}

function NextStats()
{
	local int i;
	
	if ( (PlayerOwner == None) || (PlayerOwner.GameReplicationInfo == None) )
		return;
		
	LastUpdateTime = 0;
	for ( i=0; i<PlayerOwner.GameReplicationInfo.PRIArray.Length-1; i++ )
		if ( PRI == PlayerOwner.GameReplicationInfo.PRIArray[i] )
		{
			PRI = TeamPlayerReplicationInfo(PlayerOwner.GameReplicationInfo.PRIArray[i+1]);
			return;
		}
	PRI = TeamPlayerReplicationInfo(PlayerOwner.GameReplicationInfo.PRIArray[0]);
}

defaultproperties
{
	StatsString="PERSONAL STATS FOR"
	AwardsString="AWARDS"
	FirstBloodString="First Blood!"
	FlakMonkey="Flak Monkey!"
	ComboWhore="Combo Whore!"
	HeadHunter="Head Hunter!"
	FlagTouches="Flag Touches"
	FlagReturns="Flag Returns"
	GoalsScored="Goals Scored:"
	Hattrick="Hat Trick!"
	KillString[0]="Double Kill!"
	KillString[1]="MultiKill!"
	KillString[2]="MegaKill!"
	KillString[3]="UltraKill!"
	KillString[4]="MONSTER KILL!"
	KillString[5]="LUDICROUS KILL!"
	KillString[6]="HOLY SHIT!"
	AdrenalineCombos="ADRENALINE COMBOS"
	ComboNames[0]="Speed"
	ComboNames[1]="Berserk"
	ComboNames[2]="Defensive"
	ComboNames[3]="Invisible"
	ComboNames[4]="Other"
	KillsByWeapon="WEAPON STATS"
	CombatResults="COMBAT RESULTS"
	Kills="Kills"
	Deaths="Deaths"
	Suicides="Suicides"
	NextStatsString="Press F8 for next player"
	WeaponString="Weapon"
	DeathsBy="Killed By"
	deathsholding="Deaths w/"
	EfficiencyString="Efficiency"
	WaitingForStats="Waiting for stats from server.  Press F3 to return to normal HUD."
	BoxMaterial=Texture'InterfaceContent.Menu.ScoreBoxA'
}