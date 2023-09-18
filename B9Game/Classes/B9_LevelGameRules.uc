class B9_LevelGameRules extends Info;

var() bool bOnlyObjectivesWin;	// game only won by satisfying level objectives
var() bool bSpawnInTeamArea;	// players spawn in marked team playerstarts
var() int	GoalScore; 
var() int	TimeLimit;			// time limit in minutes
var() int MaxLives;				// max number of lives for match
var() int Rounds;				// number of rounds to play
var() int RecommendedNumPlayers[2];	// number of players recommended for team (bots will fill out in single player)
var() string DefaultRosters[2];
var() string DefaultDMRoster;
var   B9_UnrealTeamInfo Rosters[2];
var   B9_DMRoster B9_DMRoster;

function PreBeginPlay()
{
}

function int GetNumRounds(int DefaultValue)
{
	if ( Rounds < 0 )
		return DefaultValue;

	return Rounds;
}

function int GetGoalScore(int DefaultValue)
{
	if ( GoalScore < 0 )
		return DefaultValue;

	return GoalScore;
}

function int GetTimeLimit(int DefaultValue)
{
	if ( TimeLimit < 0 )
		return DefaultValue;

	return TimeLimit;
}

function int GetMaxLives(int DefaultValue)
{
	if ( MaxLives < 0 )
		return DefaultValue;

	return MaxLives;
}

function B9_UnrealTeamInfo GetRoster(int i)
{
	local B9_UnrealTeamInfo R;

	if ( Rosters[i] == None )
	{
		// first look for Roster in level
		ForEach AllActors(class'B9_UnrealTeamInfo', R)
		{
			if ( R.TeamAlliance == i )
			{
				if ( Rosters[i] == None )
					Rosters[i] = R;
				else
				{
					warn(R$" is duplicate roster");
					R.Destroy();
				}
			}
		}

		// if not found, spawn default roster
		if ( Rosters[i] == None )
			Rosters[i] = spawn(class<B9_UnrealTeamInfo>(DynamicLoadObject(DefaultRosters[i],class'Class')));
	}
	Rosters[i].TeamIndex = i;
	Rosters[i].DesiredTeamSize = RecommendedNumPlayers[i];
	return Rosters[i];
}

function B9_DMRoster GetDMRoster()
{
	if ( B9_DMRoster == None )
	{
		B9_DMRoster = B9_DMRoster(Rosters[0]);
		if ( B9_DMRoster == None )
			B9_DMRoster = spawn(class<B9_DMRoster>(DynamicLoadObject(DefaultDMRoster,class'Class')));
	}
	return B9_DMRoster;
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	Level.Game.EndGame(EventInstigator.PlayerReplicationInfo,"triggered");
} 

defaultproperties
{
	bOnlyObjectivesWin=true
	bSpawnInTeamArea=true
	GoalScore=-1
	TimeLimit=-1
	MaxLives=-1
	rounds=-1
	RecommendedNumPlayers[0]=4
	RecommendedNumPlayers[1]=4
	Event=EndGame
}