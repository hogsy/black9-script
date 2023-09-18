//=============================================================================
// B9_CommandHUD
//
// 
//
// 
//=============================================================================

class B9_CommandHUD extends B9_HUDPanel;




function Draw( canvas Canvas )
{
	local color white;
	local B9_HUD b9HUD;
	local int yourTeam;
	local int thereTeam;

	Super.Draw(Canvas);
	b9HUD = B9_HUD(Owner);


	if ( b9HUD != None )
	{
		if( b9HUD.PlayerOwner != None && b9HUD.PlayerOwner.GameReplicationInfo.Teams[0] != None && b9HUD.PlayerOwner.GameReplicationInfo.Teams[1] != None)
		{
			yourTeam = b9HUD.PlayerOwner.PlayerReplicationInfo.Team.TeamIndex;
			if( yourTeam == 0 )
				thereTeam = 1;
			else
				thereTeam = 0;
				
			white.R = 200;
			white.G = 200;
			white.B = 255;
			Canvas.SetPos( 250, 10 );
			Canvas.SetDrawColor(white.R, white.G, white.B);
			
			Canvas.DrawText( "Team - "$ int( b9HUD.PlayerOwner.GameReplicationInfo.Teams[ yourTeam ].Score )  $ "       Enemy - " $ int( b9HUD.PlayerOwner.GameReplicationInfo.Teams[ thereTeam ].Score ), false );//".");// , false );
			if( b9HUD.PlayerOwner.Pawn.health == 0 )
			{
				Canvas.SetPos( 250, 250 );
				Canvas.SetDrawColor(white.R, white.G, white.B);
				Canvas.DrawText( "Respawn in  "$5-B9_CommandGameReplicationInfo(b9HUD.PlayerOwner.GameReplicationInfo).fCountdown);
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
