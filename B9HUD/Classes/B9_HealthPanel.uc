//=============================================================================
// B9_HealthPanel
//
// 
//
// 
//=============================================================================
class B9_HealthPanel extends B9_HUDPanel;

#exec OBJ LOAD FILE=..\textures\B9HUD_textures.utx PACKAGE=B9HUD_textures




var material	fHealthGaugeTex;
var material	fHealthHitGaugeTex;
var material	fFocusGaugeTex;
var material	fFocusHitGaugeTex;
var material	fVehicleGaugeTex;
var material	fVehicleHitGaugeTex;
var material	fFrameTex;
var material	fVehicleFrameTex;
var float				fHealthPctHistory;
var float				fFocusPctHistory;
var float				fVehiclePctHistory;
var globalconfig bool	bNoDrawPanel;

var B9_AdvancedPawn	fPlayerPawn;

// debug info
var bool	fShowInfo;

const	kPanelLeft		= 35;
const	kPanelTop		= 35;
const	kPanelWidth		= 128;
const	kPanelHeight	= 128;
const	kHealthGaugeLeft	= 11;
const	kHealthGaugeTop		= 5;
const	kHealthGaugeWidth	= 16;
const	kHealthGaugeHeight	= 79;
const	kFocusGaugeLeft		= 106;
const	kFocusGaugeTop		= 5;
const	kFocusGaugeWidth	= 16;
const	kFocusGaugeHeight	= 79;
const	kVehicleGaugeLeft	= 32;
const	kVehicleGaugeTop	= 91;
const	kVehicleGaugeWidth	= 64;
const	kVehicleGaugeHeight	= 6;




function B9Debug( String mode, optional String data )
{
	if ( mode == "info" )
	{
		fShowInfo	= !fShowInfo;
	}
}

function bool GetOwnerInfo()
{
	local B9_HUD	myHUD;


	if ( fPlayerPawn == None )
	{
		myHUD	= B9_HUD( Owner );
		if ( myHUD != None )
		{
			fPlayerPawn	= myHUD.GetAdvancedPawn();
		}
	}

	return ( fPlayerPawn != None );
}

function Draw( Canvas canvas ) 
{
	local B9_HUD	myHUD;
	local float		healthMax;
	local float		healthPct;
	local float		healthHeight;
	local float		healthHitHeight;
	local float		focusMax;
	local float		focusPct;
	local float		focusHeight;
	local float		focusHitHeight;
	local float		vehicleMax;
	local float		vehiclePct;
	local float		vehicleWidth;
	local float		vehicleHitWidth;
	local int		locX, locY;

	local String	healthText;
	local String	focusText;
	local String	vehicleText;
	local float		width, height;
	local float		textTop;

	local B9_AdvancedPawn	advancedPawn;
	local Pawn				vehiclePawn;


	if ( bNoDrawPanel )
	{
		return;
	}

//////////////////

	Super.Draw( canvas );

	myHUD	= B9_HUD( Owner );

	if ( myHUD != None )
	{
		advancedPawn	= myHUD.GetAdvancedPawn();
		if ( advancedPawn != none )
		{
			healthMax	= advancedPawn.fCharacterMaxHealth;
			healthPct	= Float( advancedPawn.Health ) / healthMax;
			healthPct	= FClamp( healthPct, 0.0, 1.0 );

			focusMax	= advancedPawn.fCharacterMaxFocus;
			focusPct	= advancedPawn.fCharacterFocus / focusMax;
			focusPct	= FClamp( focusPct, 0.0, 1.0 );

			vehiclePawn	= myHUD.GetVehiclePawn();
			if ( vehiclePawn != None )
			{
				vehicleMax	= Float( vehiclePawn.Default.Health );
				vehiclePct	= Float( vehiclePawn.Health ) / vehicleMax;
				vehiclePct	= FClamp( vehiclePct, 0.0, 1.0 );
			}
		}
		else
		{
			// Don't draw if you  don't have a pawn yet.
			return; 
		}
	}
	// no HUD, no draw
	else
	{
		return;
	}

///////////////////////////////////////

	// draw the frame
	canvas.SetDrawColor( 255, 255, 255 );

	canvas.SetPos( kPanelLeft, kPanelTop );
	canvas.DrawTile( fFrameTex, kPanelWidth, kPanelHeight, 0, 0, kPanelWidth, kPanelHeight );		

	// health gauge
	healthHeight	= kHealthGaugeHeight * healthPct;
	healthHitHeight	= kHealthGaugeHeight * fHealthPctHistory - healthHeight;

	if ( healthHitHeight > 0 )
	{
		canvas.Style	= ERenderStyle.STY_Normal;
		canvas.SetPos( kPanelLeft + kHealthGaugeLeft, kPanelLeft + kHealthGaugeTop + ( kHealthGaugeHeight - healthHeight - healthHitHeight ) );
		canvas.DrawTile( fHealthHitGaugeTex, kHealthGaugeWidth, healthHitHeight, 0, kHealthGaugeHeight - healthHeight - healthHitHeight, kHealthGaugeWidth - 1, healthHitHeight - 1 );
	}
	else
	{
		canvas.Style	= ERenderStyle.STY_Normal;
	}

	canvas.SetPos( kPanelLeft + kHealthGaugeLeft, kPanelLeft + kHealthGaugeTop + ( kHealthGaugeHeight - healthHeight ) );
	canvas.DrawTile( fHealthGaugeTex, kHealthGaugeWidth, healthHeight, 0, kHealthGaugeHeight - healthHeight, kHealthGaugeWidth - 1, healthHeight - 1 );

	// chi gauge
	focusHeight	= kFocusGaugeHeight * focusPct;
	focusHitHeight	= kFocusGaugeHeight * fFocusPctHistory - focusHeight;

	if ( focusHitHeight > 0 )
	{
		canvas.Style	= ERenderStyle.STY_Normal;
		canvas.SetPos( kPanelLeft + kFocusGaugeLeft, kPanelLeft + kFocusGaugeTop + ( kFocusGaugeHeight - focusHeight - focusHitHeight ) );
		canvas.DrawTile( fFocusHitGaugeTex, kFocusGaugeWidth, focusHitHeight, 0, kFocusGaugeHeight - focusHeight - focusHitHeight, kFocusGaugeWidth - 1, focusHitHeight - 1 );
	}
	else
	{
		canvas.Style	= ERenderStyle.STY_Normal;
	}

	canvas.SetPos( kPanelLeft + kFocusGaugeLeft, kPanelLeft + kFocusGaugeTop + ( kFocusGaugeHeight - focusHeight ) );
	canvas.DrawTile( fFocusGaugeTex, kFocusGaugeWidth, focusHeight, 0, kFocusGaugeHeight - focusHeight, kFocusGaugeWidth - 1, focusHeight - 1 );

	// vehicle gauge
	if ( vehiclePawn != None )
	{
		// draw the vehicle health frame
		canvas.SetDrawColor( 255, 255, 255 );

		canvas.SetPos( kPanelLeft, kPanelTop );
		canvas.DrawTile( fVehicleFrameTex, kPanelWidth, kPanelHeight, 0, 0, kPanelWidth, kPanelHeight );		

		vehicleWidth	= kVehicleGaugeWidth * vehiclePct;
		vehicleHitWidth	= kVehicleGaugeWidth * fVehiclePctHistory - vehicleWidth;

		if ( focusHitHeight > 0 )
		{
			canvas.Style	= ERenderStyle.STY_Normal;
			canvas.SetPos( kPanelLeft + kFocusGaugeLeft, kPanelLeft + kFocusGaugeTop + ( kFocusGaugeHeight - focusHeight - focusHitHeight ) );
			canvas.DrawTile( fVehicleHitGaugeTex, kVehicleGaugeWidth, focusHitHeight, 0, kFocusGaugeHeight - focusHeight - focusHitHeight, kFocusGaugeWidth - 1, focusHitHeight - 1 );
		}
		else
		{
			canvas.Style	= ERenderStyle.STY_Normal;
		}

		canvas.SetPos( kPanelLeft + kVehicleGaugeLeft, kPanelLeft + kVehicleGaugeTop );
		canvas.DrawTile( fVehicleGaugeTex, vehicleWidth, kVehicleGaugeHeight, 0, 0, vehicleWidth - 1 , kVehicleGaugeHeight - 1);
	}

	// debugging text
	if ( fShowInfo )
	{
		textTop	= 0;

		healthText	= "Health: " $ advancedPawn.Health $ "/" $ advancedPawn.fCharacterMaxHealth;

		canvas.TextSize( healthText, width, height );
		canvas.SetPos( kPanelLeft, kPanelTop + kPanelHeight + textTop );
		canvas.DrawTextClipped( healthText );

		textTop	+= height;

		focusText	= "Chi: " $ advancedPawn.fCharacterFocus $ "/" $ advancedPawn.fCharacterMaxFocus;

		canvas.TextSize( focusText, width, height );
		canvas.SetPos( kPanelLeft, kPanelTop + kPanelHeight + textTop );
		canvas.DrawTextClipped( focusText );

		textTop	+= height;

		if ( vehiclePawn != None )
		{
			vehicleText	= "Vehicle: " $ vehiclePawn.Health $ "/" $ vehiclePawn.Default.Health;

			canvas.TextSize( vehicleText, width, height );
			canvas.SetPos( kPanelLeft, kPanelTop + kPanelHeight + textTop );
			canvas.DrawTextClipped( vehicleText );

			textTop	+= height;
		}
	}
}

function UpdatePctHistory( float deltaTime )
{
	local B9_HUD			myHUD;
	local float				healthPct;
	local float				focusPct;
	local float				vehiclePct;
	local float				increment;
	local float				slideRate; // Per delta Time scale (second I think)
	local B9_AdvancedPawn	advancedPawn;
	local Pawn				vehiclePawn;


	slideRate	= 0.1;
	increment	= slideRate * deltaTime;
	myHUD		= B9_HUD( Owner );
	
	if ( myHUD != None )
	{
		advancedPawn	= myHUD.GetAdvancedPawn();
		if ( advancedPawn != None )
		{
			healthPct	= Float( advancedPawn.Health ) / advancedPawn.fCharacterMaxHealth;
			focusPct	= advancedPawn.fCharacterFocus  / advancedPawn.fCharacterMaxFocus;

			vehiclePawn	= myHUD.GetVehiclePawn();
			if ( vehiclePawn != None )
			{
				vehiclePct	= Float( vehiclePawn.Health ) / Float( vehiclePawn.Default.Health );
			}
		}
	}
	else
	{
		healthPct	= 0;
		focusPct	= 0;
		vehiclePct	= 0;
	}

	if ( fHealthPctHistory != healthPct )
	{
		if ( Abs( fHealthPctHistory - healthPct ) < increment )
		{
			fHealthPctHistory	= healthPct;
		}
		else
		if ( fHealthPctHistory < healthPct )
		{
			fHealthPctHistory	+= increment;
		}
		else
		{
			fHealthPctHistory	-= increment;
		}

		fHealthPctHistory	= FClamp( fHealthPctHistory, 0.0, 1.0 );
	}

	if ( fFocusPctHistory != focusPct )
	{
		if ( Abs( fFocusPctHistory - focusPct ) < increment )
		{
			fFocusPctHistory	= focusPct;
		}
		else
		if ( fFocusPctHistory < focusPct )
		{
			fFocusPctHistory	+= increment;
		}
		else
		{
			fFocusPctHistory	-= increment;
		}

		fFocusPctHistory	= FClamp( fFocusPctHistory, 0.0, 1.0 );
	}

	if ( vehiclePawn != None )
	{
		if ( fVehiclePctHistory != vehiclePct )
		{
			if ( Abs( fVehiclePctHistory - vehiclePct ) < increment )
			{
				fVehiclePctHistory	= vehiclePct;
			}
			else
			if ( fVehiclePctHistory < vehiclePct )
			{
				fVehiclePctHistory	+= increment;
			}
			else
			{
				fVehiclePctHistory	-= increment;
			}

			fVehiclePctHistory	= FClamp( fVehiclePctHistory, 0.0, 1.0 );
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
		UpdatePctHistory( deltaTime );
	}	

	function Paint( Canvas canvas )
	{
	}
}




defaultproperties
{
	fHealthGaugeTex=Texture'B9HUD_textures.Map.map_health_tex'
	fHealthHitGaugeTex=Texture'B9HUD_textures.Map.map_damage_tex'
	fFocusGaugeTex=Texture'B9HUD_textures.Map.map_chi_tex'
	fFocusHitGaugeTex=Texture'B9HUD_textures.Map.map_chi_deplete_tex'
	fVehicleGaugeTex=Texture'B9HUD_textures.Map.map_vehicle_tex'
	fVehicleHitGaugeTex=Texture'B9HUD_textures.Map.vehicle_damage_tex'
	fFrameTex=Texture'B9HUD_textures.Map.map_frame01_tex'
	fVehicleFrameTex=Texture'B9HUD_textures.Map.map_frame02_tex'
	fHealthPctHistory=1
	fFocusPctHistory=1
	fVehiclePctHistory=1
}