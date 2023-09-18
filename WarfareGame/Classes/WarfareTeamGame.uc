class WarfareTeamGame extends TeamGame;

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local Controller P;
	local PlayerController player;

	if ( (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
		return false;

	if ( bTeamScoreRounds )
	{
		if ( Winner != None )
			Winner.Team.Score += 1;
	}
	else if ( Teams[1].Score == Teams[0].Score )
	{
		// tie
		BroadcastLocalizedMessage( GameMessageClass, 0 );
		return false;
	}		

	if ( Winner == None )
		GameReplicationInfo.Winner = self;
	else
		GameReplicationInfo.Winner = Winner.Team;

	EndTime = Level.TimeSeconds;

	for ( P=Level.ControllerList; P!=None; P=P.nextController )
	{
		player = PlayerController(P);
		if ( Player != None )
		{
			PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == Winner.Team));
			player.ClientSetBehindView(true);
			if ( Controller(Winner.Owner).Pawn != None )
				Player.SetViewTarget(Controller(Winner.Owner).Pawn);
			player.ClientGameEnded();
		}
		P.GotoState('GameEnded');
	}
	return true;
}


defaultproperties
{
	RestartWait=5
	LevelRulesClass=Class'LevelGamePlay'
	DefaultEnemyRosterClass="WarClassMisc.GeistTeamRoster"
	HUDType="WarfareGame.WarfareTeamHUD"
	BeaconName="WTeam"
	GameName="Warfare Team Game"
	MutatorClass="WarfareGame.WarfareMutator"
}