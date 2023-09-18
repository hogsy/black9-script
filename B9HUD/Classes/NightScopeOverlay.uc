//=============================================================================
// NightScopeOverlay.uc
//
// 
//	HUD object, enabled when vision mode is set to NightScope
//	Basically just draws a tile on the screen to make the viewport smaller
// 
//=============================================================================


class NightScopeOverlay extends B9_HUDPanel;


var private material			fMaterial;
var private float				fFrameTimer;
var private int					fTexYL;

const	OVERLAY_SIZE	= 512;
const	kFrameSize		= 64;

function Draw( Canvas canvas )
{
	Super.Draw(Canvas);


	Canvas.SetPos( 0, 0 );
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.SetDrawColor( 0, 255, 0, 128 );
	Canvas.DrawTile( fMaterial,
					 Canvas.ClipX,
					 Canvas.ClipY, 
					 0,
					 Max( 0, fTexYL - 64 ),
					 512,
					 fTexYL );
}


simulated function Tick( float Delta )
{
	fFrameTimer += Delta;
	if( fFrameTimer >= 0.05 )
	{
		fTexYL	+= kFrameSize;
		if( fTexYL > OVERLAY_SIZE )
		{
			fTexYL	= kFrameSize;
		}
		
		fFrameTimer = 0.0;
	}
}





defaultproperties
{
	fMaterial=Texture'B9_Effects.Patterns.night_vision'
	fTexYL=64
}