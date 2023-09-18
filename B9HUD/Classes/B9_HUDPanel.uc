//=============================================================================
// B9_HUDPanel
//
// 
//
// 
//=============================================================================

class B9_HUDPanel extends Actor
	abstract;

var bool bInView;
var private float fToggleInViewTime;

var int fOutX;
var int fOutY;
var int fInX;
var int fInY;

var float fPanelVelocity;

var texture fBackground;
var texture fBackgroundOverlay;

////////////////////////////////////
// Functions
//

event PreBeginPlay()
{
	Super.PreBeginPlay();

	bInView = false;
	fToggleInViewTime = Level.TimeSeconds - fPanelVelocity;
}

function ToggleInView()
{
	bInView = !bInView;
	fToggleInViewTime = Level.TimeSeconds;
}

function GetScreenLocation( out int X, out int Y )
{
	local float percentage;

	if ( fPanelVelocity < 0.0001 )
	{
		percentage = 1;
	}
	else
	{
		percentage = ( Level.TimeSeconds - fToggleInViewTime ) / fPanelVelocity;
	}

	if ( percentage > 1 )
	{
		percentage = 1;
	}

	if ( bInView )
	{
		X = ( fInX - fOutX ) * percentage + fOutX;
		Y = ( fInY - fOutY ) * percentage + fOutY;
	}
	else
	{
		X = ( fOutX - fInX ) * percentage + fInX;
		Y = ( fOutY - fInY ) * percentage + fInY;
	}
}

function Draw( canvas Canvas )
{
	local int x, y;

	if ( Canvas == None )
	{
		return;
	}

	if ( !bInView && ( Level.TimeSeconds - fToggleInViewTime ) > fPanelVelocity )
	{
		return;
	}

	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;

	GetScreenLocation( x, y );

	if ( fBackground != None )
	{
		Canvas.SetPos( x, y );
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.DrawIcon( fBackground, 1.0 );
	}

	if ( fBackgroundOverlay != None )
	{
		Canvas.SetPos( x, y );
		Canvas.Style = ERenderStyle.STY_Alpha;
		Canvas.DrawIcon( fBackgroundOverlay, 1.0 );
	}
}

defaultproperties
{
	bHidden=true
}