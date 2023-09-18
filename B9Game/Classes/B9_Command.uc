//=============================================================================
// B9_Command
//=============================================================================
class B9_Command extends B9_TeamGame
	config;

var sound CaptureSound[2];
var sound ReturnSounds[2];
var sound DroppedSounds[2];
var (Command) int fCountDownTimer;
var (Command) int fReplayDelay;


replication
{
	reliable if( Role==ROLE_Authority )
		fCountDownTimer,fReplayDelay;
}


function PreBeginPlay()
{
	BeaconName = "";
	Level.Title = "Black 9 Lunar";

	Super.PreBeginPlay();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(1.0, true);
	fCountDownTimer = 0;
}

event PlayerController Login
(
	string Portal,
	string Options,
	out string Error
)
{
	local Pawn InPawn;
	local PlayerController NewPlayer;

	NewPlayer = Super.Login(Portal,Options,Error);

	InPawn = NewPlayer.Player.Actor.Pawn; // This will most likely result in InPawn==None.

	log("Concluded number is "$B9_PlayerPawn(InPawn).fCharacterConcludedMission);

	return NewPlayer;
}


function AddCommandPoint(TeamInfo Team)
{
	if( Team.Score < GoalScore)
	{
		Team.Score += 1;
	}
}

State MatchInProgress
{
	// This timer is set to once a second don't change without changing the Countdown Timer logic
	function Timer()
	{
		local Controller TeamMate;
		local Controller LevelController;
		local int i;
		local bool PlayerIsDead;
		Super.Timer();
		if (bGameEnded)
			return;
		PlayerIsDead = false;
		For ( LevelController=Level.ControllerList; LevelController!=None; LevelController=LevelController.NextController )
		{
			if ( (LevelController.Pawn == None) && LevelController.IsA('PlayerController') && !LevelController.PlayerReplicationInfo.bOnlySpectator  )
				PlayerIsDead= true;
		}
		if( PlayerIsDead == true )
		{
			fCountDownTimer++;
			B9_CommandGameReplicationInfo(GameReplicationInfo).fCountDown = fCountDownTimer;
		}
			
		// check if the game is over because either team has achieved the goal limit
		if ( GoalScore > 0 )
		{
			for (i = 0; i < 2; i++ )
			{
				if ( Teams[i].Score >= GoalScore )
				{
					EndGame(None,"teamscorelimit");// MARC Perhaps we need to add a scorer
				}
			}
		} 
		if( fCountDownTimer > fReplayDelay )
		{
			For ( LevelController=Level.ControllerList; LevelController!=None; LevelController=LevelController.NextController )
			{
				if ( (LevelController.Pawn == None) && LevelController.IsA('PlayerController') && !LevelController.PlayerReplicationInfo.bOnlySpectator )
					PlayerController(LevelController).ServerReStartPlayer();
			}
			fCountDownTimer = 0;
			B9_CommandGameReplicationInfo(GameReplicationInfo).fCountDown = fCountDownTimer;			
		}

	}

}
function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	if ( (instigatedBy != None) && injured.IsPlayerPawn() && instigatedBy.IsPlayerPawn()
		&& (injured.PlayerReplicationInfo.Team != instigatedBy.PlayerReplicationInfo.Team)
		&& !injured.IsHumanControlled() 
		&& ((injured.health < 35) || (injured.PlayerReplicationInfo.HasFlag != None)) )
			injured.Controller.SendMessage(None, 'OTHER', injured.Controller.GetMessageIndex('INJURED'), 15, 'TEAM');

	return Super.ReduceDamage( Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
}

/* ChangeTeam()
*/
function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
	local B9_UnrealTeamInfo NewTeam;

	if ( Other.IsA('PlayerController') && Other.PlayerReplicationInfo.bOnlySpectator )
	{
		Other.PlayerReplicationInfo.Team = None;
/*		if (StatLog != None)
			StatLog.LogTeamChange(Other);*/
		return true;
	}

	NewTeam = Teams[PickTeam(num,Other)];

	if ( NewTeam.Size >= MaxTeamSize )
		return false;	// no room on either team

	// check if already on this team
	if ( Other.PlayerReplicationInfo.Team == NewTeam )
		return false;

	Log("B9_Command.ChangeTeam team changed");

	Other.StartSpot = None;

	if ( Other.PlayerReplicationInfo.Team != None )
		Other.PlayerReplicationInfo.Team.RemoveFromTeam(Other);

	if ( NewTeam.AddToTeam(Other) )
		BroadcastLocalizedMessage( GameMessageClass, 3, Other.PlayerReplicationInfo, None, NewTeam );
	return true;
}

defaultproperties
{
	fReplayDelay=5
	bScoreTeamKills=true
	B9_LevelRulesClass=Class'B9_LevelGamePlay'
	GoalScore=60
	MaxLives=0
	HUDType="B9Game.B9_COM_HUD"
	MapPrefix="COM"
	BeaconName="COM"
	GameName="Command"
	DeathMessageClass=Class'WarfareGame.WarfareDeathMessage'
	GameReplicationInfoClass=Class'B9_CommandGameReplicationInfo'
}