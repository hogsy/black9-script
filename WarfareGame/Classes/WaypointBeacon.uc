// ====================================================================
//  Class:  WarfareGame.WaypointBeacon
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class WaypointBeacon extends Beacons;

simulated function DrawIcon(Canvas C, WarfareHud H, float Scale, float X, float Y)
{
	C.SetPos(X-12,Y-12);
	C.DrawTile(Icon,24,24,0,0,32,32);
}

defaultproperties
{
	Icon=Texture'SG_Hud.HUD.WayPoint'
	bDrawDistance=true
}