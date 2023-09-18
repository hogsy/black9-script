//=============================================================================
// UnrealPlayer.
//=============================================================================
class UnrealPlayer extends PlayerController
	config(User);

var bool		bRising;
var bool		bLatecomer;		// entered multiplayer game after game started
var bool		bDisplayLoser;
var bool		bDisplayWinner;
var class<WillowWhisp> PathWhisps[2];
var int LastTaunt;
var float LastWhispTime;

var() int MultiKillLevel;
var() float LastKillTime;

var float LastTauntAnimTime;


replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		ClientPlayTakeHit,ClientDelayedAnnouncement;
	reliable if ( Role == ROLE_Authority )
		PlayWinMessage, PlayStartupMessage, ClientSendStats, ClientSendSprees,ClientSendMultiKills, ClientSendCombos, ClientSendWeapon;

	reliable if ( Role < ROLE_Authority )
		ServerTaunt, ServerChangeLoadout, ServerSpectate, ServerShowPathToBase,ServerUpdateStats, ServerUpdateStatArrays,ServerGetNextWeaponStats;
}

// Local stats related functions

function ServerUpdateStats(TeamPlayerReplicationInfo PRI)
{
	ClientSendStats(PRI,PRI.GoalsScored,PRI.bFirstBlood, PRI.kills,PRI.suicides,PRI.FlagTouches,PRI.FlagReturns,PRI.FlakCount,PRI.ComboCount,PRI.HeadCount);
}

function ServerUpdateStatArrays(TeamPlayerReplicationInfo PRI)
{
	ClientSendSprees(PRI,PRI.Spree[0],PRI.Spree[1],PRI.Spree[2],PRI.Spree[3],PRI.Spree[4],PRI.Spree[5]);
	ClientSendMultiKills(PRI,PRI.MultiKills[0],PRI.MultiKills[1],PRI.MultiKills[2],PRI.MultiKills[3],PRI.MultiKills[4],PRI.MultiKills[5],PRI.MultiKills[6]);
	ClientSendCombos(PRI,PRI.Combos[0],PRI.Combos[1],PRI.Combos[2],PRI.Combos[3],PRI.Combos[4]);
}

function ServerGetNextWeaponStats(TeamPlayerReplicationInfo PRI, int i)
{
	if ( i >= PRI.WeaponStatsArray.Length )
		return;

	ClientSendWeapon(PRI, PRI.WeaponStatsArray[i].WeaponClass, PRI.WeaponStatsArray[i].kills, PRI.WeaponStatsArray[i].deaths,PRI.WeaponStatsArray[i].deathsholding,i);
}

function ClientSendWeapon(TeamPlayerReplicationInfo PRI, class<Weapon> W, int kills, int deaths, int deathsholding, int i)
{
	PRI.UpdateWeaponStats(PRI,W,Kills,Deaths,DeathsHolding);
	ServerGetNextWeaponStats(PRI,i+1);
}

simulated function ClientSendSprees(TeamPlayerReplicationInfo PRI,byte Spree0,byte Spree1,byte Spree2,byte Spree3,byte Spree4,byte Spree5)
{
	PRI.Spree[0] = Spree0;
	PRI.Spree[1] = Spree1;
	PRI.Spree[2] = Spree2;
	PRI.Spree[3] = Spree3;
	PRI.Spree[4] = Spree4;
	PRI.Spree[5] = Spree5;
}

simulated function ClientSendMultiKills(TeamPlayerReplicationInfo PRI,
								byte MultiKills0, byte MultiKills1, byte MultiKills2, byte MultiKills3, byte MultiKills4, byte MultiKills5, byte MultiKills6)
{
	PRI.MultiKills[0] = MultiKills0;
	PRI.MultiKills[1] = MultiKills1;
	PRI.MultiKills[2] = MultiKills2;
	PRI.MultiKills[3] = MultiKills3;
	PRI.MultiKills[4] = MultiKills4;
	PRI.MultiKills[5] = MultiKills5;
	PRI.MultiKills[6] = MultiKills6;
}

simulated function ClientSendCombos(TeamPlayerReplicationInfo PRI,byte Combos0, byte Combos1, byte Combos2, byte Combos3, byte Combos4)
{
	PRI.Combos[0] = Combos0;
	PRI.Combos[1] = Combos1;
	PRI.Combos[2] = Combos2;
	PRI.Combos[3] = Combos3;
	PRI.Combos[4] = Combos4;

	ServerGetNextWeaponStats(PRI,0);
}

simulated function ClientSendStats(TeamPlayerReplicationInfo PRI, int newgoals, bool bNewFirstBlood, int newkills, int newsuicides, int newFlagTouches, int newFlagReturns, int newFlakCount, int newComboCount, int newHeadCount)
{
	PRI.GoalsScored = newGoals;
	PRI.bFirstBlood = bNewFirstBlood;
	PRI.Kills = NewKills;
	PRI.Suicides = NewSuicides;
	PRI.FlagTouches = NewFlagTouches;
	PRI.FlagReturns = NewFlagReturns;
	PRI.FlakCount = NewFlakCount;
	PRI.ComboCount = NewComboCount;
	PRI.HeadCount = NewHeadCount;

	ServerUpdateStatArrays(PRI);
}

function ClientDelayedAnnouncement(sound AnnouncementSound, byte Delay)
{
	local AnnounceAdrenaline A;
	
	A = spawn(class'AnnounceAdrenaline', self);
	A.AnnounceSound = AnnouncementSound;
	A.settimer(0.1*delay,false);
}

function LogMultiKills(float Reward, bool bEnemyKill)
{
	if ( bEnemyKill && (Level.TimeSeconds - LastKillTime < 4) )
	{
		MultiKillLevel++;
		if (Level.Game.GameStats!=None) 
			Level.Game.GameStats.SpecialEvent(PlayerReplicationInfo,"multikill_"$MultiKillLevel);
	}
	else
		MultiKillLevel=0;
		
	if ( bEnemyKill )
		LastKillTime = Level.TimeSeconds;
}	

exec function ShowAI()
{
	myHUD.ShowDebug();
	if ( UnrealPawn(ViewTarget) != None )
		UnrealPawn(ViewTarget).bSoakDebug = myHUD.bShowDebugInfo;
}

function Possess(Pawn aPawn)
{
	if ( UnrealPawn(aPawn) != None )
	{
		if ( UnrealPawn(aPawn).Default.VoiceType != "" )
			VoiceType = UnrealPawn(aPawn).Default.VoiceType;
		if ( VoiceType != "" )
        {
			PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject(VoiceType,class'Class'));
        }
	}
	Super.Possess(aPawn);
}

function bool AutoTaunt()
{
	return bAutoTaunt; 
}

function bool DontReuseTaunt(int T)
{
	if ( T == LastTaunt )
		return true;

	LastTaunt = T;

	return false;
}

exec function SoakBots()
{
	local Bot B;

	log("Start Soaking");
	UnrealMPGameInfo(Level.Game).bSoaking = true;
	ForEach DynamicActors(class'Bot',B)
		B.bSoaking = true;
}

function SoakPause(Pawn P)
{
	log("Soak pause by "$P);
	SetViewTarget(P);
	SetPause(true);
	bBehindView = true;
	myHud.bShowDebugInfo = true;
	if ( UnrealPawn(P) != None )
		UnrealPawn(P).bSoakDebug = true;
}

exec function BasePath(byte num)
{
	if (PlayerReplicationInfo.Team == None )
		return;
	ServerShowPathToBase(num);
}

function ServerShowPathToBase(int TeamNum)
{
	local GameObjective G,Best;

	if ( (Level.NetMode != NM_Standalone) && (Level.TimeSeconds - LastWhispTime < 0.5) )
		return;
	LastWhispTime = Level.TimeSeconds;
	
	if ( (Pawn == None) || (TeamGame(Level.Game) == None) || !TeamGame(Level.Game).CanShowPathTo(self,TeamNum) )
		return;

	for ( G=TeamGame(Level.Game).Teams[0].AI.Objectives; G!=None; G=G.NextObjective )
		if ( G.BetterObjectiveThan(Best,TeamNum,PlayerReplicationInfo.Team.TeamIndex) )
			Best = G;
	if ( (Best != None) && (FindPathToward(Best,false) != None) )
		spawn(PathWhisps[TeamNum],self,,Pawn.Location);	
}

function byte GetMessageIndex(name PhraseName)
{
	if ( PlayerReplicationInfo.VoiceType == None )
		return 0;
	return PlayerReplicationInfo.Voicetype.Static.GetMessageIndex(PhraseName);
}

exec function Taunt( name Sequence )
{
	if ( (UnrealPawn(Pawn) != None) && (Pawn.Health > 0) && (Level.TimeSeconds - LastTauntAnimTime > 0.3) && UnrealPawn(Pawn).CheckTauntValid(Sequence) )
	{
		ServerTaunt(Sequence);
        LastTauntAnimTime = Level.TimeSeconds;
	}
}

function ServerTaunt(name AnimName )
{
	if ( (UnrealPawn(Pawn) != None) && (Pawn.Health > 0) && (Level.TimeSeconds - LastTauntAnimTime > 0.3) && UnrealPawn(Pawn).CheckTauntValid(AnimName) )
	{
		Pawn.SetAnimAction(AnimName);
        LastTauntAnimTime = Level.TimeSeconds;
	}
}

function PlayStartupMessage(byte StartupStage)
{
	ReceiveLocalizedMessage( class'StartupMessage', StartupStage, PlayerReplicationInfo );
}

exec function CycleLoadout()
{
	if ( UnrealTeamInfo(PlayerReplicationInfo.Team) != None )
		ServerChangeLoadout(string(UnrealTeamInfo(PlayerReplicationInfo.Team).NextLoadOut(PawnClass)));
}

exec function ChangeLoadout(string LoadoutName)
{
	ServerChangeLoadout(LoadoutName);
}

function ServerChangeLoadout(string LoadoutName)
{
	UnrealMPGameInfo(Level.Game).ChangeLoadout(self, LoadoutName);
}

function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	local int iDam;

	Super.NotifyTakeHit(InstigatedBy,HitLocation,Damage,DamageType,Momentum);

	// FIXME_MERGE if ( (Pawn != None) && (Pawn.ShieldStrength > 0) )
	// FIXME_MERGE 	ClientFlash(0.5,vect(700,700,0));
	// FIXME_MERGE else
	if ( Damage > 1 )
		ClientFlash(DamageType.Default.FlashScale,DamageType.Default.FlashFog);

	ShakeView(0.15 + 0.005 * Damage, Damage * 30, Damage * vect(0,0,0.03), 120000, vect(1,1,1), 0.2); 
	iDam = Clamp(Damage,0,250);
	if ( (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer) )
		ClientPlayTakeHit(hitLocation - Pawn.Location, iDam, damageType); 
}

function ClientPlayTakeHit(vector HitLoc, byte Damage, class<DamageType> damageType)
{
	HitLoc += Pawn.Location;
	Pawn.PlayTakeHit(HitLoc, Damage, damageType);
}
	
function PlayWinMessage(bool bWinner)
{
	if ( bWinner )
		bDisplayWinner = true;
	else
		bDisplayLoser = true;
}

// Player movement.
// Player Standing, walking, running, falling.
state PlayerWalking
{
ignores SeePlayer, HearNoise;

	function bool NotifyLanded(vector HitNormal)
	{
		if (DoubleClickDir == DCLICK_Active)
		{
			DoubleClickDir = DCLICK_Done;
			ClearDoubleClick();
			Pawn.Velocity *= Vect(0.1,0.1,1.0);
		}
		else
			DoubleClickDir = DCLICK_None;

		if ( Global.NotifyLanded(HitNormal) )
			return true;

		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		if ( (DoubleClickMove == DCLICK_Active) && (Pawn.Physics == PHYS_Falling) )
			DoubleClickDir = DCLICK_Active;
		else if ( (DoubleClickMove != DCLICK_None) && (DoubleClickMove < DCLICK_Active) )
		{
			if ( UnrealPawn(Pawn).Dodge(DoubleClickMove) )
				DoubleClickDir = DCLICK_Active;
		}

		Super.ProcessMove(DeltaTime,NewAccel,DoubleClickMove,DeltaRot);
	}
}

function ServerSpectate()
{
	GotoState('Spectating');
    bBehindView = true;
    ServerViewNextPlayer();
}

state Dead
{
ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon;

	exec function Fire( optional float F )
	{
		if ( bFrozen )
		{
			if ( (TimerRate <= 0.0) || (TimerRate > 1.0) )
				bFrozen = false;
			return;
		}
		if ( PlayerReplicationInfo.bOutOfLives )
			ServerSpectate();
		else 
			Super.Fire(F);
	}
	
Begin:
    Sleep(3.0);
	if ( (ViewTarget == None) || (ViewTarget == self) || (VSize(ViewTarget.Velocity) < 1.0) )
	{
		Sleep(1.0);
		myHUD.bShowScores = true;
	}
	else
		Goto('Begin');
}

defaultproperties
{
	PathWhisps[0]=Class'WillowWhisp'
	PathWhisps[1]=Class'WillowWhisp'
	PlayerReplicationInfoClass=Class'TeamPlayerReplicationInfo'
}