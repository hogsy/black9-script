//=============================================================================
// B9_DemoHud
//
// 
//
// 
//=============================================================================

class B9_DemoHud extends HUD;


var private material fLogoTexL;
var private material fLogoTexR;
const kMatSize		= 256;
const kDisplaySize	= 128; 
const kYPos		= 0;

function DrawHUD(canvas Canvas)
{
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.SetDrawColor( 80, 80, 80, 80 );

	
	Canvas.SetPos( ( ( Canvas.ClipX * 0.5 ) - kDisplaySize ) , kYPos );
	Canvas.DrawTile( fLogoTexL,
					 kDisplaySize,
					 kDisplaySize, 
					 0,
					 0,
					 kMatSize,
					 kMatSize );
	

	Canvas.SetPos( ( Canvas.ClipX * 0.5 ), kYPos );
	Canvas.DrawTile( fLogoTexR,
					 kDisplaySize,
					 kDisplaySize, 
					 0,
					 0,
					 kMatSize,
					 kMatSize );
}




defaultproperties
{
	fLogoTexL=Shader'B9Menu_tex_std.titles.title_left_unlit'
	fLogoTexR=Shader'B9Menu_tex_std.titles.title_right_unlit'
}