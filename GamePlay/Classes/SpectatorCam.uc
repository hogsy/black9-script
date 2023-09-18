//=============================================================================
// SpectatorCam.
//=============================================================================
class SpectatorCam extends KeyPoint;

var() bool bSkipView; // spectators skip this camera when flipping through cams
var() float FadeOutTime;	// fade out time if used as EndCam

defaultproperties
{
	FadeOutTime=5
	Texture=Texture'Engine.S_Camera'
	bClientAnim=true
	CollisionRadius=20
	CollisionHeight=40
	bDirectional=true
}