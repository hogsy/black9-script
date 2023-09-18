// ====================================================================
//  Class:  WarfareGame.MedicBeacon
//
//  Spawned when a player calls for a Medic's Assistance
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class MedicBeacon extends Beacons;

simulated function DrawIcon(Canvas C, WarfareHud H, float Scale, float X, float Y)
{
	C.SetPos(X-16*Scale,Y-16*Scale);
	C.DrawTile(Icon,32*Scale,32*Scale,0,0,32,32);
}

defaultproperties
{
	Icon=Texture'SG_Hud.HUD.MedicCall'
	LifeSpan=5
}