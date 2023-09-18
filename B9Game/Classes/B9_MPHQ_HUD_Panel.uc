//=============================================================================
// B9_CommandHUD
//
// 
//
// 
//=============================================================================

class B9_MPHQ_HUD_Panel extends B9_HUDPanel;




function Draw( canvas Canvas )
{
	local color white;
	local B9_HUD b9HUD;
	local B9_MultiPlayerHQGameInfo HQ;
	local int TimerDisplay;
	Super.Draw(Canvas);
	b9HUD = B9_HUD(Owner);


	if ( b9HUD != None )
	{
		if( b9HUD.PlayerOwner != None )
		{
			white.R = 200;
			white.G = 200;
			white.B = 255;
			Canvas.SetPos( 250, 50);
			Canvas.SetDrawColor(white.R, white.G, white.B);
			Canvas.DrawText("Team A Size:"$b9HUD.PlayerOwner.GameReplicationInfo.Teams[0].Size$"Team B Size:"$b9HUD.PlayerOwner.GameReplicationInfo.Teams[0].Size, false );
			Canvas.SetPos( 250, 60);
			Canvas.DrawText( "ConcludedMission:"$  B9_PlayerPawn(b9HUD.PlayerOwner.Pawn).fCharacterConcludedMission );

			if( b9HUD.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex == 0)
			{
				Canvas.DrawText("Member of Team A");
			}else
			{
				Canvas.DrawText("Member of Team B");
			}

			Canvas.SetPos( 250, 150);
			Canvas.SetDrawColor(white.R, white.G, white.B);
			if( B9_HQGameReplicationInfo(b9HUD.PlayerOwner.GameReplicationInfo).fCountdown > 0 )
			{
				TimerDisplay = B9_HQGameReplicationInfo(b9HUD.PlayerOwner.GameReplicationInfo).fCountdown;
			}
			if( B9_HQGameReplicationInfo(b9HUD.PlayerOwner.GameReplicationInfo).fCanCountdown == true )
			{
				Canvas.DrawText("Max Time Until Game Start:"$TimerDisplay, false );
			}

		}

	}
}

auto state Normal_HUD
{
	function BeginState()
	{
	}

	function DisableFrame()
	{
	}

	function Tick( float deltaTime )
	{
		
	}	

	function Paint( Canvas canvas )
	{
	}
}
