// ====================================================================
//  Class:  WarfareGame.RepairBeacon
//  Parent: WarfareGame.Beacons
//
//  <Enter a description here>
// ====================================================================

class RepairBeacon extends Beacons;

simulated function DrawIcon(Canvas C, WarfareHud H, float Scale, float X, float Y)
{
	C.SetPos(X-16*Scale,Y-16*Scale);
	C.DrawTile(Icon,32*Scale,32*Scale,0,0,32,32);
}

defaultproperties
{
	Icon=Texture'SG_Hud.HUD.C_Wrench_T_JW'
}