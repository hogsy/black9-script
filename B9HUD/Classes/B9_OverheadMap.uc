//=============================================================================
// B9_OverheadMap
//
// 
//
// 
//=============================================================================

class B9_OverheadMap extends B9_HUDPanel;

const kOverheadMapSize = 74;

var globalconfig float kMapScaleX;
var globalconfig float kMapScaleY;

var Shader fOverheadMapTexture;
var Texture fOverheadMapIconsTexture;

const kMaxTargets = 32;
var	Vector	Targets[kMaxTargets];
var Controller.eAttitude Attitudes[kMaxTargets];
var int		NumTargets;
var float	NextTimeToDrawTargets;

var bool fCountdownRunning;
var float fCountdownSeconds;
var int fAlertSeconds;
var sound fNormalTickSound;
var sound fAlertTickSound;
var float fLastLevelSeconds;
var float fLastClockWidth;
var string fLastClockDisplay;
var bool fMustRecalcClock;
var localized font fMSA16Font;


function bool WorldToMap( Pawn thePlayer, vector WorldCoord, out vector MapCoord )
{
	local vector center, relpos;
	
	center.x = fInX + kOverheadMapSize / 2;
	center.y = fInY + kOverheadMapSize / 2;
	relpos.x = ( WorldCoord.x - thePlayer.Location.x ) * kMapScaleX;
	relpos.y = ( WorldCoord.y - thePlayer.Location.y ) * kMapScaleY;
	MapCoord.x = center.x + relpos.x;
	MapCoord.y = center.y + relpos.y;
	
	if ( abs(relpos.x) <= kOverheadMapSize / 2 - 8 && abs(relpos.y) <= kOverheadMapSize / 2 - 8 )
	{
		return true;
	}
	else
	{
		return false;
	}
}

function bool RelocateAtMapEdge( out vector MapCoord )
{
	local vector center, relpos;
	local float ratioX, ratioY, ratio;

	center.x = fInX + kOverheadMapSize / 2;
	center.y = fInY + kOverheadMapSize / 2;

	relpos.X = MapCoord.X - center.X;
	relpos.Y = MapCoord.Y - center.Y;

	ratioX = abs(relpos.X / (kOverheadMapSize / 2 - 8));
	ratioY = abs(relpos.Y / (kOverheadMapSize / 2 - 8));
	if (ratioX > ratioY)
		ratio = ratioX;
	else
		ratio = ratioY;

	if (ratio == 0.0f) return false;

	MapCoord.X = relpos.X / ratio + center.X;
	MapCoord.Y = relpos.Y / ratio + center.Y;
	return true;
}

const kFullAngle = 65536;
function vector TransformVertex( float angle, vector translation, vector vertex )
{
	local vector result;
	
	angle *= 2.0 * PI / kFullAngle;
	
	result.x = vertex.x * cos(angle) - vertex.y * sin(angle) + translation.x;
	result.y = vertex.y * cos(angle) + vertex.x * sin(angle) + translation.y;
	
	return result;
}

function ShowCountdownTimer(bool running, int currentSeconds, int alertSeconds, sound normalTick, sound alertTick)
{
	fCountdownRunning = running;
	fCountdownSeconds = currentSeconds;
	fAlertSeconds = alertSeconds;
	fNormalTickSound = normalTick;
	fAlertTickSound = alertTick;
	fMustRecalcClock = true;
}

function Draw( Canvas canvas )
{
	local B9_HUD b9HUD;
	local ZoneInfo zone;	
	local Pawn thePlayer;
	local Pawn targetPawn;
	local vector target;
	local bool drawable;
	local B9MissionObjective objective;
	local Canvas.CanvasPolygon2D polygon;
	local array<vector> vertices;
	local Controller.eAttitude attitude;
	local int counter;
	local float deltaTime;
	local float oldSeconds;
	local int n;
	local float ftemp;


	b9HUD = B9_HUD(Owner);
	if ( b9HUD != None )
	{
		thePlayer = b9HUD.GetAdvancedPawn();
	}

	Canvas.SetDrawColor( 255, 255, 255 );
	
	// Draw the Overhead Map Texture
	if (fOverheadMapTexture == None)
		return;

	TexScaler(fOverheadMapTexture.Diffuse).Material = None;
	if ( thePlayer != None )
	{
		zone = thePlayer.Region.Zone;
		if ( Zone == None || Zone.fOverheadMap_Texture == None )
		{
			zone = Level;
		}
		TexScaler(fOverheadMapTexture.Diffuse).UScale = zone.fOverheadMap_ScaleX * kMapScaleX;
		TexScaler(fOverheadMapTexture.Diffuse).VScale = zone.fOverheadMap_ScaleY * kMapScaleY;
		TexScaler(fOverheadMapTexture.Diffuse).UOffset = b9HUD.PlayerOwner.Pawn.Location.x * kMapScaleX + zone.fOverheadMap_OffsetX;
		TexScaler(fOverheadMapTexture.Diffuse).VOffset = b9HUD.PlayerOwner.Pawn.Location.y * kMapScaleY + zone.fOverheadMap_OffsetY;
		TexScaler(fOverheadMapTexture.Diffuse).Material = zone.fOverheadMap_Texture;
	}

	if ( TexScaler(fOverheadMapTexture.Diffuse).Material != None )
	{
		Canvas.Style = ERenderStyle.STY_Translucent;
		Canvas.SetPos( fInX, fInY );
		Canvas.DrawTile( fOverheadMapTexture, kOverheadMapSize, kOverheadMapSize, 0, 0, 
			texture(TexScaler(fOverheadMapTexture.Diffuse).Material).USize, 
			texture(TexScaler(fOverheadMapTexture.Diffuse).Material).VSize );
	}
	
	// Draw possible countdown timer

//	fCountdownRunning = running;
//	fCountdownSeconds = currentSeconds;
//	fAlertSeconds = alertSeconds;
//	fNormalTick = normalTick;
//	fAlertTick = alertTick;

	deltaTime = Level.TimeSeconds - fLastLevelSeconds;

	if (fCountdownSeconds > 0.0f || fCountdownRunning)
	{
		oldSeconds = fCountdownSeconds;
		if (fCountdownRunning && fCountdownSeconds > 0.0f)
			fCountdownSeconds -= deltaTime;
		if (fCountdownSeconds <= 0.0f)
			fCountdownSeconds = 0.0f;

		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.Font = fMSA16Font;

		if (fMustRecalcClock || int(oldSeconds + 0.99) != int(fCountdownSeconds + 0.99))
		{
			n = int(fCountdownSeconds + 0.99);
			fLastClockDisplay = "" $ (n / 60) $ ":";
			n = n % 60;
			if (n < 10) fLastClockDisplay = fLastClockDisplay $ "0" $ n;
			else fLastClockDisplay = fLastClockDisplay $ n;
			Canvas.TextSize(fLastClockDisplay, fLastClockWidth, ftemp);

			n = int(fCountdownSeconds + 0.99);
			if (n <= fAlertSeconds)
				Owner.Owner.PlayOwnedSound(fAlertTickSound);
			else
				Owner.Owner.PlayOwnedSound(fNormalTickSound);

			fMustRecalcClock = false;
		}

		ftemp = (fCountdownSeconds - float(int(fCountdownSeconds))) * 128.0f + 127.0f;

		if (fCountdownSeconds <= fAlertSeconds)
			Canvas.SetDrawColor(ftemp, 0, 0);
		else
			Canvas.SetDrawColor(ftemp, ftemp, ftemp);

		Canvas.SetPos( fInX + kOverheadMapSize / 2 - fLastClockWidth / 2, fInY + kOverheadMapSize + 6);
		Canvas.DrawText(fLastClockDisplay);
	}

	fLastLevelSeconds = Level.TimeSeconds;

	// Draw the Actor Icons

	// EB - Killing the Actor icons
	/*
	if ( thePlayer != None )
	{
		Canvas.Style = ERenderStyle.STY_Alpha;
		
		if (NextTimeToDrawTargets < Level.TimeSeconds)
		{
			NextTimeToDrawTargets = Level.TimeSeconds + 0.70 + frand()*0.10;
			NumTargets = 0;
			foreach thePlayer.VisibleActors( class 'Pawn', targetPawn, 5000, thePlayer.Location )
			{
				if (	targetPawn != none && 
						targetPawn != thePlayer &&
						Vehicle(targetPawn) == None &&
						KVehicle(targetPawn) == None )
				{
					if ( (targetPawn.Health > 0) && (targetPawn.Controller != None) && (NumTargets < kMaxTargets) )
					{
						drawable = WorldToMap( thePlayer, targetPawn.Location, target );
						if ( drawable )
						{
							Canvas.SetPos( target.x - 8, target.y - 8 );
							if ( Bot(targetPawn.Controller) == None )
								attitude = targetPawn.Controller.AttitudeTo( thePlayer );
							else
								attitude = Bot(targetPawn.Controller).AttitudeToQuick(thePlayer);
							if ( attitude < ATTITUDE_Ignore )
								Canvas.SetDrawColor( 255, 64, 64 );
							else
								Canvas.SetDrawColor( 64, 255, 64 );
							Canvas.DrawTile( fOverheadMapIconsTexture, 16, 16, 0, 0, 16, 16 );
							
							Targets[NumTargets] = target;
							Attitudes[NumTargets] = attitude;
							NumTargets++;
						}
					}
				}
			}
		}
		else
		{
			for (counter = 0; counter < NumTargets; counter++)
			{
				target = Targets[counter];
				attitude = Attitudes[counter];

				Canvas.SetPos( target.x - 8, target.y - 8 );
				if ( attitude < ATTITUDE_Ignore )
					Canvas.SetDrawColor( 255, 64, 64 );
				else
					Canvas.SetDrawColor( 64, 255, 64 );
				Canvas.DrawTile( fOverheadMapIconsTexture, 16, 16, 0, 0, 16, 16 );
			}
		}
	}
	*/
	
	// Draw the Waypoint Icons
	
	if ( thePlayer != None && B9_BasicPlayerPawn(thePlayer) != None )
	{
		objective = B9_BasicPlayerPawn(thePlayer).GetActiveObjective();
		if( objective != None && objective.fWaypoint != None )
		{
			drawable = WorldToMap( thePlayer, objective.fWaypoint.Location, target );
			if ( drawable )
			{
				Canvas.SetDrawColor( 255, 255, 255 );
			}
			else
			{
				drawable = RelocateAtMapEdge( target );
				if ( drawable )
				{
					Canvas.SetDrawColor( 128, 128, 128 );
				}
			}
			if ( drawable )
			{
				Canvas.SetPos( target.x - 8, target.y - 8 );	
				Canvas.DrawTile( fOverheadMapIconsTexture, 16, 16, 16, 0, 16, 16 );
			}
		}	
	}

	Canvas.SetDrawColor( 255, 255, 255 );
	
	// Draw the Player Icon
	if ( thePlayer != None )
	{
		target.x = fInX + kOverheadMapSize / 2;
		target.y = fInY + kOverheadMapSize / 2;
		vertices.Length = 4;
		vertices[0] = TransformVertex( thePlayer.Rotation.yaw, target, vect(-8,-8,0) );
		vertices[1] = TransformVertex( thePlayer.Rotation.yaw, target, vect(8,-8,0) );
		vertices[2] = TransformVertex( thePlayer.Rotation.yaw, target, vect(8,8,0) );
		vertices[3] = TransformVertex( thePlayer.Rotation.yaw, target, vect(-8,8,0) );
		polygon.points.Length = 4;
		polygon.points[0] = Canvas.SetPoint2D( vertices[0].x, vertices[0].y, 32, 0, 255, 255, 255 );
		polygon.points[1] = Canvas.SetPoint2D( vertices[1].x, vertices[1].y, 48, 0, 255, 255, 255 );
		polygon.points[2] = Canvas.SetPoint2D( vertices[2].x, vertices[2].y, 48, 16, 255, 255, 255 );
		polygon.points[3] = Canvas.SetPoint2D( vertices[3].x, vertices[3].y, 32, 16, 255, 255, 255 );
		Canvas.Style = ERenderStyle.STY_Translucent;	// Why Doesnt STY_Alpha work!!!!! SCD$$$
		Canvas.DrawPolygon2D( fOverheadMapIconsTexture, polygon );
	}
}

defaultproperties
{
	kMapScaleX=0.02
	kMapScaleY=0.02
	fOverheadMapTexture=Shader'B9_OverheadMapTextures.OverheadMap'
	fOverheadMapIconsTexture=Texture'B9_OverheadMapTextures.OverheadMapIcons'
	fMSA16Font=Font'B9_Fonts.MicroscanA16'
	fOutX=62
	fOutY=42
	fInX=62
	fInY=42
}