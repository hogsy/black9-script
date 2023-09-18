//=============================================================================
// VisionFX_HERA_Engage
//
//	Fade out for transitioning to pixel shader effect
//
//=============================================================================


class VisionFX_HERA_Engage extends CameraOverlay
	native;


var float		fEffectTime;
var bool		fInitialized;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)


defaultproperties
{
	OverlayColor=(B=0,G=0,R=255,A=255)
	OverlayMaterial=Texture'B9_Effects.SimpleColors.white_alpha'
	Alpha=255
}