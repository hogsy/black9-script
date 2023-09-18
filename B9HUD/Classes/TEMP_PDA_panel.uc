//=============================================================================
// TEMP_PDA_panel.uc
//
// Shows mission objectives
//	
//=============================================================================


class TEMP_PDA_panel extends B9_HUDPanel;

#exec OBJ LOAD FILE=..\textures\B9Menu_textures.utx PACKAGE=B9Menu_textures

var private material			fFrameMaterial;

function Draw( Canvas canvas )
{
	local B9_HUD				b9HUD;
	local B9_BasicPlayerPawn	P;
	local int					i, numObjectives;
	local string				objectiveString;
	local float					strX, strY;
	local int					strPosX, strPosY;
    
	Super.Draw(Canvas);

	b9HUD	= B9_HUD(Owner);
	if( b9HUD != None )
	{
		P = B9_BasicPlayerPawn( b9HUD.PlayerOwner.Pawn );
	}
	if( P == None )
	{
		return;
	}


	// Render a backdrop & a title
	//
	Canvas.SetPos( 100, 100 );
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawTile( fFrameMaterial, Canvas.ClipX - 200 , Canvas.ClipY -200, 0, 0, 32, 32 );

	Canvas.Font = b9HUD.fLargeFont;
	Canvas.SetDrawColor( 160, 160, 160 );
	Canvas.StrLen( "Mission Objectives", strX, strY );
	Canvas.SetPos( ( Canvas.ClipX * 0.5 ) - ( strX * 0.5 ), 120 );
	Canvas.DrawText( "Mission Objectives" );

	// Draw mission objectives
	//
	numObjectives = P.GetNumMissionObjectives();
	
	if( numObjectives == 0 )
	{
		return;
	}

	Canvas.Font = b9HUD.fMediumFont;
	strPosX = 110;
	strPosY	= 150 + int( strY );

	for( i = 0; i < numObjectives; i++ )
	{
		objectiveString = P.GetMissionObjectiveString( i );
		Canvas.StrLen( objectiveString, strX, strY );
		Canvas.SetPos( strPosX, strPosY );

		if( P.IsMissionObjectiveComplete( i ) )
		{
			Canvas.SetDrawColor( 110, 110, 110 );
		}
		else
		{
			Canvas.SetDrawColor( 0, 160, 0 );
		}

		Canvas.DrawText( objectiveString );
		strPosY += int( strY );
	}
}





defaultproperties
{
	fFrameMaterial=Texture'B9Menu_textures.Blank_Panes.full_blank'
}