//=============================================================================
// AttributesPanel
//
// 
//
// 
//=============================================================================

class AttributesPanel extends B9_HUDPanel;

#exec OBJ LOAD FILE=..\textures\Black9_Interface.utx PACKAGE=Black9_Interface

// RPG Stats
var public string fCharacterName;
var public string fCharacterOccupation;
var public string fCharacterCompany;
var public int fCharacterStrength;
var public int fCharacterDexterity;
var public int fCharacterAgility;
var public int fCharacterHealth;

var private texture fBackTexture;
var private texture fForeTexture;

function Draw( canvas Canvas )
{
	local int locX, locY, Y;
	local color blue, white, yellow;
	local int w, h;
	local float ClipX, ClipY;

	Super.Draw(Canvas);

	white.R = 255;
	white.G = 255;
	white.B = 255;

	blue.R = 0;
	blue.G = 200;
	blue.B = 245;

	yellow.R = 245;
	yellow.G = 245;
	yellow.B = 200;

	w = 130;
	h = 128;

	GetScreenLocation( locX, locY );


	// Draw textures;
	Canvas.SetPos( locX, locY );
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.DrawTile( fBackTexture, w, h, 0, 0, w, h );
	Canvas.SetPos( locX, locY );
	//Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawTile( fForeTexture, w, h, 0, 0, w, h );

	ClipX = Canvas.ClipX;
	ClipY = Canvas.ClipY;
	Canvas.SetClip( locX + w, locY + h);

	// Print the player's titles
	Y = 12;
	Canvas.SetPos( locX+14, locY + Y );
	Canvas.SetDrawColor(blue.r,blue.g,blue.b);
	Canvas.DrawText( "Name", false );
	Canvas.SetDrawColor(white.r,white.g,white.b);
	Canvas.SetPos( locX + 50, locY + Y );
	Canvas.DrawTextClipped( fCharacterName, false );
	Y += 16;
	Canvas.SetPos( locX+22, locY + Y );
	Canvas.SetDrawColor(blue.r,blue.g,blue.b);
	Canvas.DrawText( "Job", false );
	Canvas.SetPos( locX + 50, locY + Y );
	Canvas.SetDrawColor(white.r,white.g,white.b);
	Canvas.DrawTextClipped( fCharacterOccupation, false );
	Y += 16;
	Canvas.SetPos( locX+30, locY + Y );
	Canvas.SetDrawColor(blue.r,blue.g,blue.b);
	Canvas.DrawText( "Co.", false );
	Canvas.SetPos( locX + 50, locY + Y );
	Canvas.SetDrawColor(white.r,white.g,white.b);
	Canvas.DrawTextClipped( fCharacterCompany, false );

	// Print the player's attributes
	Y += 16;
	Canvas.SetPos( locX, locY + Y );
	Canvas.SetDrawColor(yellow.r,yellow.g,yellow.b);
	Canvas.DrawText( "Str", false );
	Canvas.SetPos( locX+100, locY + Y );
	Canvas.SetDrawColor(white.r,white.g,white.b);
	Canvas.DrawTextClipped( fCharacterStrength, false );
	Y += 16;
	Canvas.SetPos( locX, locY + Y );
	Canvas.SetDrawColor(yellow.r,yellow.g,yellow.b);
	Canvas.DrawText( "Dex", false );
	Canvas.SetPos( locX+100, locY + Y );
	Canvas.SetDrawColor(white.r,white.g,white.b);
	Canvas.DrawTextClipped( fCharacterDexterity, false );
	Y += 16;
	Canvas.SetPos( locX, locY + Y );
	Canvas.SetDrawColor(yellow.r,yellow.g,yellow.b);
	Canvas.DrawText( "Agi", false );
	Canvas.SetPos( locX+100, locY + Y );
	Canvas.SetDrawColor(white.r,white.g,white.b);
	Canvas.DrawTextClipped( fCharacterAgility, false );
	Y += 16;
	Canvas.SetPos( locX, locY + Y );
	Canvas.SetDrawColor(yellow.r,yellow.g,yellow.b);
	Canvas.DrawText( "Spd", false );
	Canvas.SetPos( locX+100, locY + Y );
	Canvas.SetDrawColor(white.r,white.g,white.b);
	Canvas.DrawTextClipped( fCharacterHealth, false );

	Canvas.SetClip( ClipX, ClipY );
}

defaultproperties
{
	fBackTexture=Texture'Black9_Interface.HUD.att-main2'
	fForeTexture=Texture'Black9_Interface.HUD.att-main-lite2'
	fOutX=-140
	fOutY=200
	fInY=200
	fPanelVelocity=1
}