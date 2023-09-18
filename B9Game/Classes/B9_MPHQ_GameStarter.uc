class B9_MPHQ_GameStarter extends actor
	placeable;

// Currently there is no way to turn off the timer, but if that functionality is desired, just switch states to Stop Ticking
function Trigger( actor Other, pawn EventInstigator )
{
	if( Role == ROLE_Authority )
	{
		Level.Game.bAlreadyChanged = false;
		Level.Game.bChangeLevels = true;
		Level.Game.RestartGame();
	}
}
auto state Ticking
{
	function Timer()
	{
		local B9_MultiPlayerHQGameInfo HQ;
		local int TotalPlayersOnTeams;
		HQ = B9_MultiPlayerHQGameInfo(Level.Game);
		if(  HQ != None )
		{
			if( HQ.fCountDownTimer > 0 && HQ.fCanCountDown == true)
			{
				HQ.fCountDownTimer--;
			}else
			{
				HQ.fCountDownTimer = HQ.fCountDownTimerDuration;
			}
			if( HQ.fCountDownTimer == 0)
			{
				HQ.fCountDownTimer = -1;//Only try to start the level once
				Trigger(None,None);
			}
		}else
		{
			log("##### THE GAME STARTER IS NOT COMPATIBLE WITH THIS GAMETYPE PLEASE MODIFY GAMESTARTER OR REMOVE IT");
		}
	}

	function BeginState()
	{
		SetTimer(1.0,true);
	}
}

state StopTicking
{
	function BeginState()
	{
		SetTimer(0.0, false);
	}
}



defaultproperties
{
	bHidden=true
}